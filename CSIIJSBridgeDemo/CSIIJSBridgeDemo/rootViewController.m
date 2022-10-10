//
//  rootViewController.m
//  CSIIJSBridgeDemo
//
//  Created by Song on 2021/7/7.
//

#import "rootViewController.h"
#import <CSIIJSBridge/CSIIJSBridge.h>
#import "GlobalMacro.h"

@interface rootViewController ()

@end

@implementation rootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIButton *buttons = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(self.view.frame) - 200, self.view.frame.size.width - 100, 45)];
    [buttons setBackgroundColor:[UIColor darkGrayColor]];
    [buttons setTitle:@"下载" forState:UIControlStateNormal];
    [self.view addSubview:buttons];
    [buttons addTarget:self action:@selector(clickButtons) forControlEvents:UIControlEventTouchUpInside];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
// 页面排版规范
#pragma mark - HTTP Method -- 网络请求

// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法


#pragma mark - Private Method -- 私有方法

-(void)initWXwebView {
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"pluginDown" ofType:@"html"];
    NSURL *webUrl = [NSURL fileURLWithPath:htmlPath];
    [self.wkWebView loadFileURL:webUrl allowingReadAccessToURL:webUrl];
}
#pragma mark - Action
// 空一行
-(void)clickButtons {
    NSDictionary *Dic = @{ @"area":@"广东省深圳市",
                           @"name":@"BallMachine",
                           @"versionNumber":@"0.0.1",
                           @"systemType":@"0"
                          };
    [[PluginUpdateManager shareManager] startH5ViewControllerWithNebulaParams:Dic withController:self];
}
#pragma mark - Public Method -- 公开方法


#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式

@end
