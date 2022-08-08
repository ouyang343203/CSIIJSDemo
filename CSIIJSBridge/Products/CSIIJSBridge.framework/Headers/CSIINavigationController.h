//
//  CSIINavigationController.h
//  CSIIJSBridge
//
//  Created by Song on 2021/7/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol DLNoNav
//只要遵守了这个协议，该控制器就会隐藏导航栏
@end

@interface CSIINavigationController : UINavigationController

@end

NS_ASSUME_NONNULL_END
