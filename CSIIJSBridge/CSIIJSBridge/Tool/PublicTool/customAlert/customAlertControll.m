//
//  customAlertControll.m
//  CSIIJSBridge
//
//  Created by 李佛军 on 2022/4/8.
//

#import "customAlertControll.h"
#import <UIKit/UIKit.h>
@interface customAlertControll()
@property (nonatomic,strong) UIWindow *updateWindow;
@end
@implementation customAlertControll
+(instancetype)shareManager
{
    static customAlertControll *aletController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        aletController = [[customAlertControll alloc] init];
    });
    return aletController;
}
-(void)showCustomAlertView:(NSString*)title
               withContent:(NSString *)content
            withCancelText:(NSString *)cancelText
              withSureText:(NSString *)sureText
                 withState:(void(^)(id responseObject))responseState
{
 
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(NO));
        [self removeWindow];
    }];
    [alert addAction:cancleAction];
    //增加确定按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(YES));
        [self removeWindow];
    }];
    [alert addAction:sureAction];
    UILabel *label1 = [alert.view valueForKeyPath:@"_messageLabel"];
    if (label1) {label1.textAlignment = NSTextAlignmentLeft;}
    
    [self.updateWindow makeKeyAndVisible];
    UIViewController *bgVC = [[UIViewController alloc] init];
    [bgVC.view setBackgroundColor:[UIColor blackColor]];
    self.updateWindow.rootViewController = bgVC;
    bgVC.view.alpha = 0.3;
    [bgVC presentViewController:alert animated:YES completion:nil];
}
-(UIWindow*)updateWindow
{
    if (_updateWindow == nil) {
        _updateWindow =  [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _updateWindow.backgroundColor = [UIColor clearColor];
        _updateWindow.windowLevel = UIWindowLevelAlert;
    }
    return _updateWindow;
}
-(void)removeWindow
{
    UIViewController *VC = self.updateWindow.rootViewController;
    [VC removeFromParentViewController];
    self.updateWindow.rootViewController = nil;
    [self.updateWindow removeFromSuperview];
    self.updateWindow = nil;
}

@end
