//notation: js file can only use this kind of comments
//since comments will cause error when use in webview.loadurl,
//comments will be remove by java use regexp
(function() {
    if (window.UePayJSBridge) {
        return;
    }

    var receiveMessageQueue = [];
    var messageHandlers = {};

    var responseCallbacks = {};
    var uniqueId = 1;

    //set default messageHandler  初始化默认的消息线程
    function init(messageHandler) {
        if (UePayJSBridge._messageHandler) {
            throw new Error('UePayJSBridge.init called twice');
        }
        UePayJSBridge._messageHandler = messageHandler;
        var receivedMessages = receiveMessageQueue;
        receiveMessageQueue = null;
        for (var i = 0; i < receivedMessages.length; i++) {
            _dispatchMessageFromNative(receivedMessages[i]);
        }
    }

    // 发送
    function send(data, responseCallback) {
        _doSend('send', data, responseCallback);
    }

    // 注册线程 往数组里面添加值
    function registerHandler(handlerName, handler) {
        messageHandlers[handlerName] = handler;
    }

    // 调用线程
    function callHandler(handlerName, data, responseCallback) {
        _doSend(handlerName, data, responseCallback);
    }

    //sendMessage add message, 触发native处理 sendMessage
    function _doSend(handlerName, message, responseCallback) {
        var callbackId;
        if(typeof responseCallback === 'string'){
            callbackId = responseCallback;
        } else if (responseCallback) {
            callbackId = 'cb_' + (uniqueId++) + '_' + new Date().getTime();
            responseCallbacks[callbackId] = responseCallback;
        }else{
            callbackId = '';
        }
        try {
             var fn = eval('window.android.' + handlerName);
         } catch(e) {
             console.log(e);
         }
         if (typeof fn === 'function'){
             var responseData = fn.call(this, JSON.stringify(message), callbackId);
             if(responseData != null){
                  console.log('response message: '+ responseData);
                  responseCallback = responseCallbacks[callbackId];
                  if (!responseCallback) {
                      return;
                   }
                  responseCallback(responseData);
                  delete responseCallbacks[callbackId];
             }
         } else {
            window.android.send(handlerName, JSON.stringify(message), callbackId)
         }
    }

    //提供给native使用,
    function _dispatchMessageFromNative(messageJSON) {
        setTimeout(function() {
            var message = JSON.parse(messageJSON);
            var responseCallback;
            //java call finished, now need to call js callback function
            if (message.responseId) {
                responseCallback = responseCallbacks[message.responseId];
                if (!responseCallback) {
                    return;
                }
                responseCallback(message.responseData);
                delete responseCallbacks[message.responseId];
            } else {
                //直接发送
                if (message.callbackId) {
                    var callbackResponseId = message.callbackId;
                    responseCallback = function(responseData) {
                        _doSend('response', responseData, callbackResponseId);
                    };
                }

                var handler = UePayJSBridge._messageHandler;
                if (message.handlerName) {
                    handler = messageHandlers[message.handlerName];
                }
                //查找指定handler
                try {
                    handler(message.data, responseCallback);
                } catch (exception) {
                    if (typeof console != 'undefined') {
                        console.log("UePayJSBridge: WARNING: javascript handler threw.", message, exception);
                    }
                }
            }
        });
    }

    //提供给native调用,receiveMessageQueue 在会在页面加载完后赋值为null,所以
    function _handleMessageFromNative(messageJSON) {
        console.log('handle message: '+ messageJSON);
        if (receiveMessageQueue) {
            receiveMessageQueue.push(messageJSON);
        }
        _dispatchMessageFromNative(messageJSON);
       
    }

    var UePayJSBridge = window.UePayJSBridge = {
        init: init,
        send: send,
        registerHandler: registerHandler,
        callHandler: callHandler,
        _handleMessageFromNative: _handleMessageFromNative
    };

    var doc = document;
    var readyEvent = doc.createEvent('Events');
    readyEvent.initEvent('UePayJSBridgeReady');
    readyEvent.bridge = UePayJSBridge;
    doc.dispatchEvent(readyEvent);
})();
