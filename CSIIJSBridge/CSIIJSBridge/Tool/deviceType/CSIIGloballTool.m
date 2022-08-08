//
//  CSIIGloballTool.m
//  CSIIJSBridge
//
//  Created by Song on 2021/6/23.
//

#import "CSIIGloballTool.h"
#import "CSIIWKController.h"
#include "DataStorageManager.h"
#import <UIKit/UIKit.h>
@implementation CSIIGloballTool

+(instancetype)shareManager
{
    static CSIIGloballTool *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[CSIIGloballTool alloc] init];
    });
    return manager;
}
- (UIViewController *)csii_topViewController {
    
    UIViewController *resultVC;
    resultVC = [self csii_topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self csii_topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)csii_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self csii_topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self csii_topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
}
//获取当前显示的是图
-(UIViewController *)findCurrentShowingViewController
{
    //获得当前活动窗口的根视图
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *currentShowingVC = [self findCurrentShowingViewControllerFrom:vc];
    return currentShowingVC;
}

-(UIViewController *)findCurrentShowingViewControllerFrom:(UIViewController *)vc
{
    //方法1：递归方法 Recursive method
    UIViewController *currentShowingVC;
    if ([vc presentedViewController]) { //注要优先判断vc是否有弹出其他视图，如有则当前显示的视图肯定是在那上面
        // 当前视图是被presented出来的
        UIViewController *nextRootVC = [vc presentedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // 根视图为UITabBarController
        UIViewController *nextRootVC = [(UITabBarController *)vc selectedViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else if ([vc isKindOfClass:[UINavigationController class]]){
        // 根视图为UINavigationController
        UIViewController *nextRootVC = [(UINavigationController *)vc visibleViewController];
        currentShowingVC = [self findCurrentShowingViewControllerFrom:nextRootVC];
        
    } else {
        // 根视图为非导航类
        currentShowingVC = vc;
    }
    
    return currentShowingVC;
    /*
    //方法2：遍历方法
    while (1)
    {
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
            
        } else if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
            
        } else if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
            
        //} else if (vc.childViewControllers.count > 0) {
        //    //如果是普通控制器，找childViewControllers最后一个
        //    vc = [vc.childViewControllers lastObject];
        } else {
            break;
        }
    }
    return vc;
    //*/
}
- (BOOL)isVCPush
{
    
    BOOL isPresent;
    
    NSArray *viewcontrollers = [self findCurrentShowingViewController].navigationController.viewControllers;
    
    if (viewcontrollers.count > 1) {
        
            
            isPresent = YES; //push方式
        
    }
    else{
        isPresent = NO;  // modal方式
    }
    
    return isPresent;
}
-(BOOL)closVC
{
    CSIIWKController *VC = (CSIIWKController*)[CSIIGloballTool shareManager].findCurrentShowingViewController ;
      if ([self respondsToSelector:@selector(dismissViewControllerAnimated:completion:)]) {
              //判断1
              [VC dismissViewControllerAnimated:YES completion:nil];
          [DataStorageManager shareManager].torageDic = nil;
          return YES;
          } else if ([VC.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
              //判断2
              [VC.navigationController popViewControllerAnimated:YES];
              [DataStorageManager shareManager].torageDic = nil;
              return YES;
          }else
          {
              return NO;
          }
    return NO;
}
-(UINavigationController *)navigationControllerFromView:(UIView *)view {
    for (UIView *next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UINavigationController class]]) {
            return (UINavigationController *)nextResponder;
        }
    }
    return nil;
}
@end
