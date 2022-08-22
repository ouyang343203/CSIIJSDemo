//
//  CSIIWKController.m
//  CSIIJSBridge
//
//  Created by Song on 2021/6/25.
//

#import "CSIIWKController.h"
#import "CSIIHybridBridge.h"
#import "GlobalMacro.h"
#import "CSIIWKHybridBridge.h"
#import "CSIIGloballTool.h"
#import "DataStorageManager.h"
typedef NS_ENUM(NSInteger, leftBtnAndRightBtn)
{
    leftBtn,
    rightBtn
};
@interface CSIIWKController ()<WKUIDelegate,WKNavigationDelegate>

@property (nonatomic, strong) progressLineView *lineView;

@end


@implementation CSIIWKController


// 空一行
-(instancetype)initWithPath:(NSString*)path {
    self = [super init];
    if (self) {
        [self loadNativeHFive:path];
    }
    return self;
}
// 空一行
- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.naviBarColor==0) {
//        self.naviBarColor = #E6E6FA;
//        self.navigationController.navigationBar.barTintColor = kCSIIRGBHex(@"#E6E6FA");
    }
    self.lineView= [[progressLineView alloc]initWithFrame:CGRectMake(0,200, KScreenWidth, 3)];
    self.lineView.lineColor = [UIColor redColor];
    [self.view addSubview:self.lineView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    id bridBridge = [CSIIHybridBridge shareManager].bridge;
//
//    if ([bridBridge isKindOfClass:[CSIIWKHybridBridge class]]) {
//
//        bridBridge = (CSIIWKHybridBridge*)bridBridge;
//
//        [bridBridge callHandler:@"storageParams" data:[DataStorageManager shareManager].torageDic responseCallback:^(id responseData) {
//            NSLog(@"titile点击事件");
//        }];
//    }
}

// 页面排版规范
#pragma mark - HTTP Method -- 网络请求

// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法
#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"开始加载");
    [self.lineView startLoadingAnimation];
}
 
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"内容开始返回");
}
 
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"加载完成");
    [self.lineView endLoadingAnimation];
}
 
- (void)webView:(WKWebView *)webView didFailLoadWithError:(nonnull NSError *)error {
    NSLog(@"加载失败 error : %@",error.description);
    [self.lineView endLoadingAnimation];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"页面加载失败时调用");
    [self.lineView endLoadingAnimation];
}

//提交发生错误时调用
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {

    NSLog(@"发生错误时调用");
}
// 接收到服务器跳转请求即服务重定向时之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"接收到服务器跳转请求即服务重定向时之后调用");
}

#pragma mark - Private Method -- 私有方法
//导航栏的设置
-(void)setNavinavigationBar {
    UIButton *button =[self createMiddleBtn];
    if (self.titleStr) {
        [button setTitle:self.titleStr forState:UIControlStateNormal];
    }
    if (self.naviBarColor) {
        self.navigationController.navigationBar.barTintColor = self.naviBarColor;
    }
    if (self.titlefont) {
        [button.titleLabel setFont:[UIFont systemFontOfSize:self.titlefont]];
    }
    if (self.titleColor) {
        
        [button setTitleColor:self.titleColor forState:UIControlStateNormal];

    }
    if (self.left_back_icon||self.left_text) {
        self.navigationItem.hidesBackButton = true;
        UIBarButtonItem *backItem = [self createLeftAndRight:leftBtn];
        UIBarButtonItem *spaceItem = [self createSpaceItem];
        self.navigationItem.leftBarButtonItems = @[spaceItem,backItem];
      
    }
    if (self.right_icon||self.right_text) {
        UIBarButtonItem *rightItem = [self createLeftAndRight:rightBtn];
        UIBarButtonItem *spaceItem = [self createSpaceItem];
        
        self.navigationItem.rightBarButtonItems = @[spaceItem,rightItem];
    }
}

#pragma mark - Action
-(void)titleClickEvent {
    id bridBridge = [CSIIHybridBridge shareManager].bridge;
    if ([bridBridge isKindOfClass:[CSIIWKHybridBridge class]])
    {
        bridBridge = (CSIIWKHybridBridge*)bridBridge;
        
        [bridBridge callHandler:@"titleClick" data:@{} responseCallback:^(id responseData) {
            NSLog(@"titile点击事件");
        }];
    }
}

-(void)backBarButtonItemClicked {
    id bridBridge = [CSIIHybridBridge shareManager].bridge;
    if ([bridBridge isKindOfClass:[CSIIWKHybridBridge class]])
    {
        bridBridge = (CSIIWKHybridBridge*)bridBridge;
        [[CSIIGloballTool shareManager]closVC];
        [bridBridge callHandler:@"back" data:@{} responseCallback:^(id responseData) {
            NSLog(@"titile点击事件");
            [[CSIIGloballTool shareManager]closVC];
        }];
    }
}

-(void)rightButtonItemClicked {
    id bridBridge = [CSIIHybridBridge shareManager].bridge;
    
    if ([bridBridge isKindOfClass:[CSIIWKHybridBridge class]]) {
        
        bridBridge = (CSIIWKHybridBridge*)bridBridge;
        
        [bridBridge callHandler:@"optionMenu" data:@{} responseCallback:^(id responseData) {
            NSLog(@"titile点击事件");
        }];
    }
}

//-(void)back
//{
//    [[CSIIGloballTool shareManager]closVC];
//}
-(void)back{
    if ([self.wkWebView canGoBack]) {
           [self.wkWebView goBack];
        }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Public Method -- 公开方法
-(void)setNaviTitle:(NSString*)title {
    self.titleStr = title;
    [self setNavinavigationBar];
}

-(void)loadNativeHFive:(NSString*)path {
    if (path) {
        NSURL *webUrl = [NSURL fileURLWithPath:path];
//        NSURL *webUrl = [NSURL URLWithString:@"http://172.30.100.13:8080"];
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:webUrl]];
        [self.wkWebView reload];
    }

    [[CSIIHybridBridge shareManager] bridgeForWebView:self.wkWebView];
    [self setNavinavigationBar];
}

-(void)loadUrl:(NSString*)url {
    if (url) {
        NSURL *webUrl = [NSURL URLWithString:url];
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:webUrl]];
        [self.wkWebView reload];
    }
    [[CSIIHybridBridge shareManager] bridgeForWebView:self.wkWebView];
    
    [self setNavinavigationBar];
}

#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式
-(WKWebView*)wkWebView{
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, KNavBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT-KNavBarHeight)];
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [_wkWebView backForwardList];
        [_wkWebView goBack];
        [_wkWebView goForward];
        [_wkWebView reload];
        [self.view addSubview:self.wkWebView];
        
        if (@available(iOS 11.0, *)) {
            [_wkWebView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
        }
    }
    return _wkWebView;
}

-(UIBarButtonItem*)createSpaceItem {
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spaceItem.width = -10;
    return spaceItem;
}

-(UIBarButtonItem*)createLeftAndRight:(leftBtnAndRightBtn)state {
    UIButton *buttion = nil;
    if (state ==leftBtn) {
        buttion = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        
        [buttion addTarget:self action:@selector(backBarButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
        [buttion setTitle:self.left_text forState:UIControlStateNormal];
        [buttion.titleLabel setTextColor:[UIColor blackColor]];
        [buttion setImage:[UIImage imageNamed:self.left_back_icon] forState:UIControlStateNormal];
        [buttion addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    }else{
        buttion = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH-45, 35, 35)];
        [buttion addTarget:self action:@selector(rightButtonItemClicked) forControlEvents:UIControlEventTouchUpInside];
        [buttion setTitle:self.right_text forState:UIControlStateNormal];
        [buttion.titleLabel setTextColor:[UIColor blackColor]];
        [buttion setImage:[UIImage imageNamed:self.right_icon] forState:UIControlStateNormal];
    }
    UIBarButtonItem *buttionItem = [[UIBarButtonItem alloc] initWithCustomView:buttion];
    return buttionItem;
}

-(UIButton*)createMiddleBtn {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = 100;
    CGFloat height = 60;
    button.frame =  CGRectMake(x, y, width, height);
    button.titleLabel.text = self.title;
    self.navigationItem.titleView = button;
    [button addTarget:self action:@selector(titleClickEvent) forControlEvents:UIControlEventTouchUpInside];
    [button.titleLabel setFont:[UIFont systemFontOfSize:18]];
    return button;
}

@end
