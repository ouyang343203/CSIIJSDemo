//
//  AppDelegate.m
//  CSIIJSBridgeDemo
//
//  Created by Song on 2021/7/6.
//

#import "AppDelegate.h"
#import <CSIIJSBridge/CSIIJSBridge.h>
#import "rootViewController.h"

#define kCSIIRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = kCSIIRGBHex(0x1F1F27);
    
    CSIINavigationController *navigation = [[CSIINavigationController alloc] initWithRootViewController:[[rootViewController alloc] init]];
    self.window.rootViewController = navigation;
    [self.window makeKeyAndVisible];
    
    [PluginUpdateManager shareManager].postUrl = @"http://192.168.101.3:8888/app/resource/getTheNewestIssueStaticPackageDetailByCondition";
    [PluginUpdateManager shareManager].domainName = @"http://192.168.101.3:8091";
    [PluginUpdateManager shareManager].projectId = @"145";
    return YES;
}

@end
