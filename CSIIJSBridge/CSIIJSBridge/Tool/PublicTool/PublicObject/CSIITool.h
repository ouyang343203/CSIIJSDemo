//
//  CSIITool.h
//  CSIIJSBridge
//
//  Created by Song on 2021/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSIITool : NSObject

//是否有人脸识别权限
+ (BOOL)canFacePermission;
//是否有推送通知权限
+ (BOOL)canNotificationPermission;
//是否有定位通知权限
+ (BOOL)canLocationPermission;
//是否有通讯录通知权限
+ (BOOL)canAddressBookPermission;
//是否有相机权限
+(BOOL)canCameraPermission;
//是否有相册权限
+(BOOL)canPhotoPermission;
//是否有麦克风权限
+(BOOL)canRecordPermission;

/*
 * 判断是否是异形屏
 */
+(BOOL)isiPhoneXScreen;

////新方法系统弹框
+(void)showCustomAlertView:(NSString*)title
               withContent:(NSString *)content
            withCancelText:(NSString *)cancelText
              withSureText:(NSString *)sureText
                 withState:(void(^)(id responseObject))responseState;
/**
 系统 双选按钮弹框
 */
+ (void)showSystemNoticeWithTitle:(NSString *)title
                      withContent:(NSString *)content
                   withCancelText:(NSString *)cancelText
                     withSureText:(NSString *)sureText
                        withState:(void(^)(id responseObject))responseState;
/**
 系统 单选按钮弹框
 */
+ (void)showSystemSingleWithTitle:(NSString *)title
                      withContent:(NSString *)content
                     withSureText:(NSString *)sureText
                        withState:(void(^)(id responseObject))responseState;

@end

NS_ASSUME_NONNULL_END
