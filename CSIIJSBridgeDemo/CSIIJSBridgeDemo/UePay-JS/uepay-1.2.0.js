!function(e){var t={};function n(a){if(t[a])return t[a].exports;var d=t[a]={i:a,l:!1,exports:{}};return e[a].call(d.exports,d,d.exports,n),d.l=!0,d.exports}n.m=e,n.c=t,n.d=function(e,t,a){n.o(e,t)||Object.defineProperty(e,t,{enumerable:!0,get:a})},n.r=function(e){"undefined"!=typeof Symbol&&Symbol.toStringTag&&Object.defineProperty(e,Symbol.toStringTag,{value:"Module"}),Object.defineProperty(e,"__esModule",{value:!0})},n.t=function(e,t){if(1&t&&(e=n(e)),8&t)return e;if(4&t&&"object"==typeof e&&e&&e.__esModule)return e;var a=Object.create(null);if(n.r(a),Object.defineProperty(a,"default",{enumerable:!0,value:e}),2&t&&"string"!=typeof e)for(var d in e)n.d(a,d,function(t){return e[t]}.bind(null,d));return a},n.n=function(e){var t=e&&e.__esModule?function(){return e.default}:function(){return e};return n.d(t,"a",t),t},n.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},n.p="",n(n.s=2)}([function(e,t,n){e.exports=n(1)},function(e,t,n){"use strict";function a(){this.data=!1,this.isInit=!1,this.initEvent=new i,this.modifyEvent=new r}function d(){this.data=!1,this.listeners=[]}function i(){d.call(this)}function r(){d.call(this)}a.prototype.setValue=function(e){this.data=e,this.isInit||(this.isInit=!0,this.initEvent.subscribe(e)),this.modifyEvent.subscribe(e)},i.prototype.listener=function(e){this.data?e():this.listeners.push(e)},i.prototype.subscribe=function(e){for(this.data=e;0<this.listeners.length;){this.listeners.pop()(e)}},r.prototype.listener=function(e){this.data&&e(),this.listeners.push(e)},r.prototype.subscribe=function(e){this.data=e;for(let t of this.listeners)t(e)},e.exports=a},function(e,t,n){"use strict";n.r(t);var a=n(0),d=n.n(a);function i(e,t){if(null==e)return{};var n,a,d=function(e,t){if(null==e)return{};var n,a,d={},i=Object.keys(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||(d[n]=e[n]);return d}(e,t);if(Object.getOwnPropertySymbols){var i=Object.getOwnPropertySymbols(e);for(a=0;a<i.length;a++)n=i[a],t.indexOf(n)>=0||Object.prototype.propertyIsEnumerable.call(e,n)&&(d[n]=e[n])}return d}function r(e){this.getUserAgent=o,this.isUePayApp=c,this.onReady=function(e){l.initEvent.listener((function(t){e(t)}))},this.isReady=function(){return u.isUePayApp()&&"undefined"!=typeof UePayJSBridge&&UePayJSBridge.callHandler},e&&(this.callback=e)}r.prototype.payment=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("sendPayReq",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("sendPayReq",n,t)})):UePayJSBridge.callHandler("sendPayReq",n,t)},r.prototype.getLocation=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("getLocation",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("getLocation",n,t)})):UePayJSBridge.callHandler("getLocation",n,t)};var o=function(){var e="undefined"!=typeof navigator&&navigator.userAgent&&navigator.userAgent.toString();if(e){var t=e.match("UePay/[0-9.]*"),n=e.match("UePayClient/[0-9.]*"),a={};if(t&&0<t.length){var d=t[0].split("/");a.UePay=d[1]}if(n&&0<e.length){var i=n[0].split("/");a.UePayClient=i[1]}return!!a.UePay&&a}return!1},c=function(){return!!o()},l=new d.a,u=new r;"undefined"!=typeof window&&(window.onload=function(){u.isUePayApp()&&("undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",l.setValue(r),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",l.setValue(r)):l.setValue(r))}),r.prototype.sendShareReq=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("sendShareReq",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("sendShareReq",n,t)})):UePayJSBridge.callHandler("sendShareReq",n,t)},r.prototype.openLocation=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("openLocation",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("openLocation",n,t)})):UePayJSBridge.callHandler("openLocation",n,t)},r.prototype.scanCode=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{needResult:0},t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("scanCode",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("scanCode",n,t)})):UePayJSBridge.callHandler("scanCode",n,t)},r.prototype.closeWindow=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("closeWindow",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("closeWindow",n,t)})):UePayJSBridge.callHandler("closeWindow",n,t)},r.prototype.openAction=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{action_name:"user_bind_bank_card"},t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("openAction",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("openAction",n,t)})):UePayJSBridge.callHandler("openAction",n,t)},r.prototype.hideTitleBar=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("hideTitleBar",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("hideTitleBar",n,t)})):UePayJSBridge.callHandler("hideTitleBar",n,t)},r.prototype.showTitleBar=function(e){var t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("showTitleBar",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("showTitleBar",n,t)})):UePayJSBridge.callHandler("showTitleBar",n,t)},r.prototype.setStatusBar=function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{style:"1"},t=e.callback,n=i(e,["callback"]);"undefined"==typeof UePayJSBridge?document.addEventListener?document.addEventListener("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("setStatusBar",n,t)}),!1):document.attachEvent&&document.attachEvent("UePayJSBridgeReady",(function(){UePayJSBridge.callHandler("setStatusBar",n,t)})):UePayJSBridge.callHandler("setStatusBar",n,t)},"undefined"!=typeof window&&(window.UePayJsApi=u)}]);