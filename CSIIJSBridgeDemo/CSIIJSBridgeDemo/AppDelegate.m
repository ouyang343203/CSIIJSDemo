//
//  AppDelegate.m
//  CSIIJSBridgeDemo
//
//  Created by Song on 2021/7/6.
//

#import "AppDelegate.h"
#import <CSIIJSBridge/CSIIJSBridge.h>
#import "rootViewController.h"
#import "ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    CSIINavigationController *navigation = [[CSIINavigationController alloc] initWithRootViewController:[[rootViewController alloc] init]];
//     self.window.rootViewController = [[ViewController alloc] init];
    self.window.rootViewController = navigation;
     
     [self.window makeKeyAndVisible];
//    [PluginUpdateManager shareManager].postUrl = @"http://192.168.80.8/gidc-api/app/issue/resource/getTheNewestIssueStaticPackageDetailByCondition";
//    [PluginUpdateManager shareManager].projectId = @"431";
//
//   // [PluginUpdateManager shareManager].postUrl = @"http://192.168.101.3:8888/app/resource/getTheNewestIssueStaticPackageDetailByCondition";
//    [PluginUpdateManager shareManager].domainName = @"http://192.168.101.3:8091";
//    //[PluginUpdateManager shareManager].projectId = @"145";
    
    [PluginUpdateManager shareManager].postUrl = @"http://183.62.118.51:10088/app/resource/getTheNewestIssueStaticPackageDetailByCondition";
    [PluginUpdateManager shareManager].projectId =@"145";
    [PluginUpdateManager shareManager].domainName = @"http://183.62.118.51:18091";
    return YES;
}

@end
