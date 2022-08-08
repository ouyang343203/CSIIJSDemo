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
//    NSArray *titles = @[@"信用卡激活",@"转账汇款",@"手机号登记",@"关于我们",@"百度"];
//    for (int i = 0; i< titles.count; i++) {
//
//        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50,KNavBarHeight + 30 + (50 + 30) * i, self.view.frame.size.width - 100, 50)];
//        [button setTitle:titles[i] forState:UIControlStateNormal];
//        [button setBackgroundColor:[UIColor darkGrayColor]];
//        button.tag = 20 + i;
//        [self.view addSubview:button];
//        [button addTarget:self action:@selector(clickAction:) forControlEvents:UIControlEventTouchUpInside];
//    }
    UIButton *buttons = [[UIButton alloc] initWithFrame:CGRectMake(50, CGRectGetHeight(self.view.frame) - 200, self.view.frame.size.width - 100, 45)];
    [buttons setBackgroundColor:[UIColor darkGrayColor]];
    [buttons setTitle:@"下载" forState:UIControlStateNormal];
    [self.view addSubview:buttons];
    [buttons addTarget:self action:@selector(clickButtons) forControlEvents:UIControlEventTouchUpInside];
//        NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"pluginDown" ofType:@"html"];
//        NSString *appHtml = [NSString stringWithContentsOfFile:htmlPath encoding:NSUTF8StringEncoding error:nil];
//        NSURL *baseURL = [NSURL URLWithString:appHtml];
//        [self.wkWebView loadHTMLString:appHtml baseURL:baseURL];
//        [self.view addSubview:self.wkWebView];

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
-(void)run {
    NSLog(@"广东省深圳市");
}

// 空一行
-(void)clickButtons {
    NSDictionary *Dic = @{ @"area":@"广东省深圳市",
                          @"name":@"BallMachine",
                          @"versionNumber":@"0.0.1",
                          @"systemType":@"0"
                          
    };
    [[PluginUpdateManager shareManager]startH5ViewControllerWithNebulaParams:Dic];
}

- (void)clickAction:(UIButton *)sender {
    NSInteger type = 1;
    NSString *name = @"";
    NSString *titleStr = @"默认标题";
    NSDictionary *pagedata = @{};
    switch (sender.tag - 20) {
        case 0:{
            name = @"creditActivate";
        }
            break;
        case 1:{
            name = @"remittance";
        }
            break;
        case 2:{
            name = @"remittance";
            pagedata = @{@"type":@"phoneRegisterPre"};
        }
            break;
        case 3:{
            name = @"aboutUs";
        }
            break;
        case 4:{
            type = 0;
            titleStr = @"百度";
            name = @"http://www.baidu.com";
        }
            break;
            
        default:
            break;
    }
    NSDictionary *navagation = @{
                               @"titleColor":[UIColor blackColor],
                               @"titleStr":@"项目",
                               @"left_back_icon":@"back"};
    
    NSDictionary *Dic = @{ @"area":@"广东省深圳市",
                          @"name":@"project",
                          @"versionNumber":@"0",
                          @"userId":@"13699750287",
                          @"navagation":navagation,
                           @"name":@"BallMachine"
    };

    if (type == 1) {
        [[PluginUpdateManager shareManager]startH5ViewControllerWithNebulaParams:Dic];
    }else{
        [[PluginUpdateManager shareManager]startH5ViewControllerWithUrlParams:Dic];
    }
//    [PluginUpdateManager shareManager].postUrl = @"http://103.39.218.164:20032/app/issue/resource/getTheNewestIssueStaticPackageDetailByCondition";
}
#pragma mark - Public Method -- 公开方法


#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式

@end
