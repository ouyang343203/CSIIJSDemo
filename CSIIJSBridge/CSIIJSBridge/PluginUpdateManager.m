//
//  PluginUpdateManager.m
//  CSIIJSBridge
//
//  Created by Song on 2021/6/23.
//

#import "PluginUpdateManager.h"
#import "LQAFNetworkManager.h"
#import "MBProgressHUD.h"
#import "CSIIWKController.h"
#import "GlobalMacro.h"
#import "CSIIKeychainTool.h"
#import "CSIIGloballTool.h"
#import "packageManager.h"
#import "CSIITMPFileManager.h"
#import "DataStorageManager.h"
#import "reachabilityManager.h"
#import "DataStorageManager.h"
#import "customAlertControll.h"
#import "CSIITool.h"

NSString *const JGCSIIJumpSuccessfulNotification = @"JumpSuccessfulNotification"; // 跳转成功通知
NSString *const JGCSIILoginOutNotification = @"LoginOutNotification";     // 退出登录跳转通知
NSString *const JGCSIIBackBarButtonItemNotification = @"backNotification";//H5返回页面

@interface PluginUpdateManager()

@end

@implementation PluginUpdateManager

/**
 *  pathUrl
 *  name:myMessage,
 *  projectId:972BF2811A76421BB37D5E93167EC536,
 *  versionNumber:0,
 *  area:广东省深圳市
 */
-(instancetype)init {
    self = [super init];
    if (self) {
        [CSIITMPFileManager removeTemporaryPlist];
    }
    return self;
}

+(instancetype)shareManager {
    static PluginUpdateManager *UpdateManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UpdateManager = [[PluginUpdateManager alloc] init];
    });
    return UpdateManager;
}
// 页面排版规范
#pragma mark - HTTP Method -- 网络请求

// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法

#pragma mark - Public Method -- 公开方法
//初始化配置
// url、projectId
//打开新的页面
/*@{
name:myMessage,
versionNumber:0,
area:广东省深圳市
projectId:972BF2811A76421BB37D5E93167EC536
 postUrl:
 navagation:
 {
 webPath
 titleStr;//标题
 titleColor; //标题颜色(0x111110)(NSInteger)
 titlefont;//标题大小（float）
 naviBarColor;//导航栏颜色
 left_back_icon;//左侧按钮--修改返回按钮
 left_text;//左侧按钮文字
 right_icon;//右侧按钮
 right_text;//右侧按钮文字
 },
 pagedata:
 {
 }
}*/
/*
 *@params
    {
    versionNumber
    area
    }
 *
 */
//native测试用
//----在原有的包上配置好 projectId、postUrl 、appName
- (void)startH5ViewControllerWithNebulaParams:(NSDictionary *)params {
    BOOL dicIsEmpty = kDictIsEmpty(params);
    NSMutableDictionary *diction = [NSMutableDictionary dictionary];
    NSString *appName = params[@"name"];
    [diction setValue:appName forKey:@"name"];
    [diction setValue:self.projectId forKey:@"projectId"];
    [diction setValue:params[@"userId"] forKey:@"userId"];
    [diction setValue:[CSIIKeychainTool getDeviceType]  forKey:@"deviceType"];
    [diction setValue:params[@"versionNumber"] forKey:@"versionNumber"];
    [diction setValue:params[@"area"] forKey:@"area"];
    [DataStorageManager shareManager].torageDic = params[@"pagedata"];
    [PluginUpdateManager shareManager].navDic = params[@"navagation"];
    if (!dicIsEmpty)
    {
        [self jumpDownlaodjumpWithAappName:appName withParams:diction];
    }
}

//在线
- (void)startH5ViewControllerWithUrlParams:(NSDictionary *)params{
    [DataStorageManager shareManager].torageDic = params[@"pagedata"];
    [PluginUpdateManager shareManager].navDic = params[@"navagation"];
    [PluginUpdateManager shareManager].pathUrl = params[@"name"];
    [PluginUpdateManager h5_urlPushViewControllerUrl:params[@"name"]];
}

-(NSString*)getDomian {
    return self.requestDomian;
}

#pragma mark - Private Method -- 私有方法
-(void)jumpDownlaodjumpWithAappName:(NSString*) appName withParams:(NSDictionary*)params{
    MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    [hud.label setText:@"加载中..."];
    [hud showAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hud hideAnimated:YES];
    });
    [[[CSIIGloballTool shareManager]csii_topViewController].view addSubview:hud];
    
//    NSString *version = [DataStorageManager getVersion];

    [[reachabilityManager manager]monitoringNetWork:^(bool result) {
                NSLog(@"result = %d",result);
        if (result) {
            [[LQAFNetworkManager manager] requestPostWithUrl:self.postUrl params:params success:^(id response) {
                NSDictionary *data = (NSDictionary*)response[@"data"];
                NSLog(@"msg = %@",response[@"msg"]);
                NSString *resourceUrl = nil;
                if (self.domainName) {
                    resourceUrl = [NSString stringWithFormat:@"%@%@",self.domainName,data[@"resourceUrl"]];
                }
                NSString *versionName = data[@"versionName"];
                [PluginUpdateManager shareManager].pathUrl = data[@"packageRootUrl"];
                //存储版本号
                [DataStorageManager setVersion:versionName];
                //存packageRootUrl地址
                [DataStorageManager seteRootUrl:data[@"packageRootUrl"]];
                
                BOOL isFile = [packageManager getHistoryPackage:appName versionNumber:versionName];
                if (isFile) {
                    [hud hideAnimated:YES];
                    [PluginUpdateManager h5_PackagepushViewControllerAppName:appName withVersionName:versionName];
                }else{
                     [[LQAFNetworkManager manager]downlaodTaskWithUrl:resourceUrl Progress:nil packageName:appName versionName:versionName success:^(id response) {
                         NSLog(@"response - %@",response);
                         //下载成功存储版本号
                         [PluginUpdateManager h5_PackagepushViewControllerAppName:appName withVersionName:versionName];
                         [hud hideAnimated:YES];
                      } failure:^(NSError *error) {
                                 [hud hideAnimated:YES];
                         NSLog(@"error - %@",error);
                            [self jumpToLocalResource:appName];
//                       [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"没有网络请切换到内网模式" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
//                        NSLog(@"没有网络");
//            }];
                        NSLog(@"不存在");
                             }];
                }
            } failure:^(NSError *error) {
                [hud hideAnimated:YES];
                [self jumpToLocalResource:appName];
//                [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"没有网络请切换到内网模式" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
//                    NSLog(@"没有网络");
//                }];
                    NSLog(@"error = %@",error);
            }];
        }else{
            [hud hideAnimated:YES];
            [self jumpToLocalResource:appName];
//            if (!kStringIsEmpty(version)) {
//                [PluginUpdateManager h5_PackagepushViewControllerAppName:appName withVersionName:version];
//                [hud hideAnimated:YES];
//            }else{
//                [hud hideAnimated:YES];
//                [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"没有网络检查一下你的网络" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
//                  NSLog(@"没有网络");
//                }];
//            }
        }
    }];
//    [PluginUpdateManager h5_PackagepushViewControllerAppName:nil withVersionName:nil];
}

/**
 titleStr;//标题
 titleColor; //标题颜色(0x111110)(NSInteger)
 titlefont;//标题大小（float）
 naviBarColor;//导航栏颜色
 left_back_icon;//左侧按钮--修改返回按钮
 left_text;//左侧按钮文字
 right_icon;//右侧按钮
 right_text;//右侧按钮文字
 */
+(void)h5_PackagepushViewControllerAppName:(NSString*)appName
                           withVersionName:(NSString*)versionName {
    NSString *pathUrl = [PluginUpdateManager shareManager].pathUrl;
    NSString *rootUrl =  [DataStorageManager getRootUrl];
    if (kStringIsEmpty(pathUrl)) {
        pathUrl = rootUrl;
    }
    if (kStringIsEmpty(pathUrl)&&kStringIsEmpty(rootUrl))
    {
        [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"你的资源包没有下载成功，请连接内网下载资源包之后在试" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
        }];
    }
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",[packageManager getFilePackageName:appName versionNumber:versionName],pathUrl];
    id webCV  = [[CSIIGloballTool shareManager] findCurrentShowingViewController];
    CSIIWKController *wxWebCV = (CSIIWKController*)webCV;
    CSIIWKController *new_wxWebCV = [[CSIIWKController alloc] init];
    NSDictionary *navDiction = [PluginUpdateManager shareManager].navDic;
     if(!kArrayIsEmpty(navDiction))
     {
         UIColor *naviBarColor = navDiction[@"naviBarColor"];
         UIColor *titleColor = navDiction[@"titleColor"];
         NSString *titlefont = navDiction[@"titlefont"];
         new_wxWebCV.naviBarColor = naviBarColor;
         new_wxWebCV.titleColor =  titleColor;
         new_wxWebCV.titlefont = [titlefont floatValue];
         new_wxWebCV.titleStr = navDiction[@"titleStr"];
         new_wxWebCV.left_back_icon = navDiction[@"left_back_icon"];
         new_wxWebCV.left_text = navDiction[@"left_text"];
         new_wxWebCV.right_icon = navDiction[@"right_icon"];
         new_wxWebCV.right_text = navDiction[@"right_text"];
     }
    UINavigationController *native = [[CSIIGloballTool shareManager] navigationControllerFromView:wxWebCV.view];
    if (native!=nil) {
        [native pushViewController:new_wxWebCV animated:YES];
        
    }else{
        [[[CSIIGloballTool shareManager]findCurrentShowingViewController] presentViewController:webCV animated:YES completion:nil];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:JGCSIIJumpSuccessfulNotification object:nil];
    [new_wxWebCV loadNativeHFive:filePath];
    
//    id webCV  = [[CSIIGloballTool shareManager] findCurrentShowingViewController];
//    CSIIWKController *wxWebCV = (CSIIWKController*)webCV;
//    CSIIWKController *new_wxWebCV = [[CSIIWKController alloc] init];
//    UINavigationController *native = [[CSIIGloballTool shareManager] navigationControllerFromView:wxWebCV.view];
//    [new_wxWebCV loadNativeHFive:nil];
//    [native pushViewController:new_wxWebCV animated:YES];
}

+(void)h5_urlPushViewControllerUrl:(NSString*)url{
    id webCV  = [[CSIIGloballTool shareManager] findCurrentShowingViewController];
     CSIIWKController *wxWebCV = (CSIIWKController*)webCV;
     CSIIWKController *new_wxWebCV = [[CSIIWKController alloc] init];
     
     NSDictionary *navDiction = [PluginUpdateManager shareManager].navDic;
    
     if(!kArrayIsEmpty(navDiction))
     {
         UIColor *naviBarColor = navDiction[@"naviBarColor"];
         UIColor *titleColor = navDiction[@"titleColor"];
         NSString *titlefont = navDiction[@"titlefont"];
         new_wxWebCV.naviBarColor = naviBarColor;
         new_wxWebCV.titleColor =  titleColor;
         new_wxWebCV.titlefont = [titlefont floatValue];
         new_wxWebCV.titleStr = navDiction[@"titleStr"];
         new_wxWebCV.left_back_icon = navDiction[@"left_back_icon"];
         new_wxWebCV.left_text = navDiction[@"left_text"];
         new_wxWebCV.right_icon = navDiction[@"right_icon"];
         new_wxWebCV.right_text = navDiction[@"right_text"];
        
     }
   UINavigationController *native = [[CSIIGloballTool shareManager] navigationControllerFromView:wxWebCV.view];
    if (native!=nil) {
        [native pushViewController:new_wxWebCV animated:YES];
    }else{
        [[[CSIIGloballTool shareManager]findCurrentShowingViewController] presentViewController:webCV animated:YES completion:nil];
    }
    
    [new_wxWebCV loadUrl:url];
}

//跳转到本地资源包
-(void)jumpToLocalResource:(NSString*)appName {
    NSString *version = [DataStorageManager getVersion];
    
    if (!kStringIsEmpty(version)) {
        [PluginUpdateManager h5_PackagepushViewControllerAppName:appName withVersionName:version];
    }else{
        [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"没有网络检查一下你的网络" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
          NSLog(@"没有网络");
        }];
    }
}


#pragma mark - Action


#pragma mark - Public Method -- 公开方法


#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式

@end
