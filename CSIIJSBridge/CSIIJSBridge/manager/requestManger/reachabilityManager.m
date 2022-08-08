//
//  reachabilityManager.m
//  CSIIJSBridge
//
//  Created by 李佛军 on 2022/4/8.
//

#import "reachabilityManager.h"
#import "AFNetworking.h"
@implementation reachabilityManager
+(instancetype)manager {
    static reachabilityManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[reachabilityManager alloc]init];
    });
    return manager;
}
-(void)monitoringNetWork:(void(^)(bool result))responseState
{
    
    AFNetworkReachabilityManager *manager=[AFNetworkReachabilityManager sharedManager];
     __block BOOL state = NO;
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
               case AFNetworkReachabilityStatusUnknown:
                state = NO;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                state = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                state = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                state = YES;
                break;
                
            default:
                state = NO;
                break;
        }
        responseState(state);
    }];
    [manager startMonitoring];
    
}
@end
