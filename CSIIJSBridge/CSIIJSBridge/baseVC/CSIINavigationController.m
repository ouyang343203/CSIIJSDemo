//
//  CSIINavigationController.m
//  CSIIJSBridge
//
//  Created by Song on 2021/7/8.
//

#import "CSIINavigationController.h"

@interface CSIINavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation CSIINavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置代理
    self.delegate = self;
    
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //如果控制器遵守了DLNoNav协议，则需要隐藏导航栏
     BOOL noNav = [[viewController class] conformsToProtocol:@protocol(DLNoNav)];
     
     //隐藏导航栏后会导致边缘右滑返回的手势失效，需要重新设置一下这个代理
     self.interactivePopGestureRecognizer.delegate = self;
     
     //设置控制器是否要隐藏导航栏
     [self setNavigationBarHidden:noNav animated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return self.childViewControllers.count > 1;
}

@end
