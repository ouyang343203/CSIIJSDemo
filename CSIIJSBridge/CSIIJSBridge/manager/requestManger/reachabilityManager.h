//
//  reachabilityManager.h
//  CSIIJSBridge
//
//  Created by 李佛军 on 2022/4/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface reachabilityManager : NSObject
+(instancetype)manager;
-(void)monitoringNetWork:(void(^)(bool result))responseState;
@end

NS_ASSUME_NONNULL_END
