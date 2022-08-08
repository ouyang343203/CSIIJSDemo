//
//  ViewController.m
//  CSIIJSBridgeDemo
//
//  Created by Song on 2021/7/6.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

//#import "WebViewJavascriptBridge.h"
//#import "BLEBluetoolthManager.h"
#import "CSIICheckObject.h"
@interface ViewController ()<WKUIDelegate,WKNavigationDelegate>
//@property (nonatomic,strong) WebViewJavascriptBridge *bridge;
//@property (nonatomic,strong) WVJBResponseCallback callBlock;
@property (nonatomic,strong) WKWebView *webView;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self wxWebView];
//    [WebViewJavascriptBridge enableLogging];
////
//    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webView];

//    [self.bridge setWebViewDelegate:self];
    [self JS2OC];
//    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(200, 400, 100, 50)];
//    [button setTitle:@"发送数据" forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor redColor]forState:UIControlStateNormal];
//    [self.view addSubview:button];
//    [button addTarget:self action:@selector(sendMessage) forControlEvents:UIControlEventTouchUpInside];
}
//-(void)sendMessage
//{
//    [self.bridge callHandler:@"onFoundDevice" data:@{} responseCallback:^(id responseData) {
//        NSLog(@"titile点击事件");
//    }];
//}
-(void)JS2OC{
    /*
     含义：JS调用OC
     @param registerHandler 要注册的事件名称(比如这里我们为loginAction)
     @param handel 回调block函数 当后台触发这个事件的时候会执行block里面的代码
     */
//    [self.bridge registerHandler:@"openBluetoothAdapter" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSDictionary *diction = data;
//        [[BLEBluetoolthManager shareBabyBluetooth] openBluetoothAdapter:diction];
//
//    }];
//    [self.bridge registerHandler:@"registerStateChangeListener" handler:^(id data, WVJBResponseCallback responseCallback) {
//        [[BLEBluetoolthManager shareBabyBluetooth] getBluetoothAdapterState:^(id  _Nonnull resultState) {
//            responseCallback(resultState);
//        }];
//    }];
//
    __weak typeof(self) weakSelf = self;
//    [self.bridge registerHandler:@"scanLeDevice" handler:^(id data, WVJBResponseCallback responseCallback) {
//         ;
//        NSDictionary *data_dic = (NSDictionary*)data;
//        [[BLEBluetoolthManager shareBabyBluetooth] onBluetoothDeviceFound:data_dic callBack:^(id  _Nonnull searchResult) {
//            NSLog(@"searchResult = %@",searchResult);
//            NSDictionary *diction = @{@"code":@"0",
//                                      @"errMsg":@""};
//            responseCallback([CSIICheckObject dictionaryChangeJson:diction]);
//
//            [self.bridge callHandler:@"onFoundDevice" data:searchResult responseCallback:^(id responseData) {
//                NSLog(@"titile点击事件");
//            }];
//            responseCallback(searchResult);
//
//        }];
//    }];

//    [self.bridge registerHandler:@"connect" handler:^(id data, WVJBResponseCallback responseCallback) {
//
//        NSDictionary *data_dic = (NSDictionary*)data;
//        [[BLEBluetoolthManager shareBabyBluetooth] createBLEConnection:data_dic callBack:^(id  _Nonnull connectResult) {
//            responseCallback(connectResult);
//        }];
//    }];

//    [self.bridge registerHandler:@"writeCharacteristic" handler:^(id data, WVJBResponseCallback responseCallback) {
//        NSDictionary *diction = (NSDictionary*)data;
//        [[BLEBluetoolthManager shareBabyBluetooth] writeBLECharacteristicValue:diction callBack:^(id  _Nonnull writeValueResult) {
//            responseCallback(writeValueResult);
//        }];
//    }];

}

-(void)wxWebView
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
       configuration.selectionGranularity = WKSelectionGranularityDynamic;
       configuration.allowsInlineMediaPlayback = YES;
       WKPreferences *preferences = [WKPreferences new];
       //是否支持JavaScript
       preferences.javaScriptEnabled = YES;
       //不通过用户交互，是否可以打开窗口
       preferences.javaScriptCanOpenWindowsAutomatically = YES;
       configuration.preferences = preferences;

    // 初始化WKWebView

     // 有两种代理，UIDelegate负责界面弹窗，navigationDelegate负责加载、跳转等
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
        self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 400)];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"index_1" ofType:@"html"];
    NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];

    NSURL * url = [NSURL fileURLWithPath:appHtml];
    [self.webView loadHTMLString:appHtml baseURL:url];
  
    [self.view addSubview:self.webView];

}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"%@",navigationAction.request.URL.absoluteString);
    NSURL *url = navigationAction.request.URL;
    NSString *urlStr = url.absoluteString;
    
    if ([urlStr isEqualToString:@"xxx"]) {
        // do something ;
        
        //不允许跳转
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    //允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

@end
 
 
