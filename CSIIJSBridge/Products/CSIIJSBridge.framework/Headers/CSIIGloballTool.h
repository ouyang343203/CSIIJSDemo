//
//  CSIIGloballTool.h
//  CSIIJSBridge
//
//  Created by Song on 2021/6/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIViewController;
@class UINavigationController;
@class UIView;
@interface CSIIGloballTool : NSObject

+(instancetype)shareManager;
//获取顶层控制器
-(UIViewController *)csii_topViewController;

-(UIViewController *)findCurrentShowingViewController;

-(UINavigationController *)navigationControllerFromView:(UIView *)view;

//判断是push还是modal弹出
- (BOOL)isVCPush;
-(BOOL)closVC;
@end

NS_ASSUME_NONNULL_END
