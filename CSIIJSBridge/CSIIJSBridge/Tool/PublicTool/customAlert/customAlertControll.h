//
//  customAlertControll.h
//  CSIIJSBridge
//
//  Created by 李佛军 on 2022/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface customAlertControll : NSObject
+(instancetype)shareManager;
//新方法系统弹框
-(void)showCustomAlertView:(NSString*)title
               withContent:(NSString *)content
            withCancelText:(NSString *)cancelText
              withSureText:(NSString *)sureText
                 withState:(void(^)(id responseObject))responseState;
@end

NS_ASSUME_NONNULL_END
