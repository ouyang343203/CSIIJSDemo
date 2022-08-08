//
//  CSIITool.m
//  CSIIJSBridge
//
//  Created by Song on 2021/9/14.
//

#import "CSIITool.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/PHPhotoLibrary.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import <CoreLocation/CLLocationManager.h>
#import <UIKit/UIKit.h>
#import "CSIIGloballTool.h"
#import <Contacts/Contacts.h>
@interface CSIITool()
@property (nonatomic,strong) UIWindow *updateWindow;
@end
@implementation CSIITool

//是否有人脸识别权限
+ (BOOL)canFacePermission {
    if(NSFoundationVersionNumber < NSFoundationVersionNumber_iOS_8_0){
        return NO;
    } else {
        LAContext *context = [LAContext new];
        //3.判断能否使用指纹识别
        if([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]) {
            return YES;
        }else{
            NSLog(@"请确保5s以上机型,TouchID未打开");
            return NO;
        }
    }
}

//是否有推送通知权限
+ (BOOL)canNotificationPermission {
    //iOS8 check if user allow notification
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        return YES;
    }
    return NO;
}

//是否有定位通知权限
+ (BOOL)canLocationPermission {
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        //定位功能可用
        return YES;
        
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        //定位不能用
        return NO;
    }
    return NO;
}

//是否有通讯录通知权限
+ (BOOL)canAddressBookPermission {
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        return NO;
    } else if(status == CNAuthorizationStatusRestricted) {
        return NO;
    } else if (status == CNAuthorizationStatusDenied){
        return NO;
    } else if (status == CNAuthorizationStatusAuthorized){
        //已经授权
        return YES;
    }
    return NO;
}

//是否有相机权限
+(BOOL)canCameraPermission {
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        return NO;
    }
    return YES;
}

//是否有相册权限
+(BOOL)canPhotoPermission {
    //相册权限判断
    PHAuthorizationStatus authStatus = [PHPhotoLibrary authorizationStatus];
    if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}

//是否有麦克风权限
+(BOOL)canRecordPermission {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if(authStatus ==AVAuthorizationStatusRestricted|| authStatus ==AVAuthorizationStatusDenied){
        return NO;
    }
    return YES;
}
+(BOOL)isiPhoneXScreen {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return NO;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger notchValue = size.width / size.height * 100;
    if (216 == notchValue || 46 == notchValue) {
        return YES;
    }
    return NO;
}
////自定义系统弹框
+(void)showCustomAlertView:(NSString*)title
               withContent:(NSString *)content
            withCancelText:(NSString *)cancelText
              withSureText:(NSString *)sureText
                 withState:(void(^)(id responseObject))responseState
{
    CSIITool* new =  [CSIITool new];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:cancelText style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(NO));
        [new removeWindow];
    }];
    [alert addAction:cancleAction];
    //增加确定按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(YES));
        [new removeWindow];
    }];
    [alert addAction:sureAction];

    [new.updateWindow makeKeyAndVisible];
    UIViewController *bgVC = [[UIViewController alloc] init];
    [bgVC.view setBackgroundColor:[UIColor blackColor]];
    new.updateWindow.rootViewController = bgVC;
    bgVC.view.alpha = 0.3;
    [bgVC presentViewController:alert animated:YES completion:nil];
}
//系统 双选按钮弹框
+ (void)showSystemNoticeWithTitle:(NSString *)title
                withContent:(NSString *)content
             withCancelText:(NSString *)cancelText
               withSureText:(NSString *)sureText
                  withState:(void(^)(id responseObject))responseState {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    //增加取消按钮
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:content style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(NO));
    }];
    [alert addAction:cancleAction];
    //增加确定按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(YES));
    }];
    [alert addAction:sureAction];
    [[[CSIIGloballTool shareManager]findCurrentShowingViewController] presentViewController:alert animated:YES completion:nil];
}

//系统 单选按钮弹框
+ (void)showSystemSingleWithTitle:(NSString *)title
                withContent:(NSString *)content
               withSureText:(NSString *)sureText
                  withState:(void(^)(id responseObject))responseState {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    //增加确定按钮
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:sureText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        responseState(@(YES));
    }];
    [alert addAction:sureAction];
    [[[CSIIGloballTool shareManager]findCurrentShowingViewController] presentViewController:alert animated:YES completion:nil];
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
