//
//  ATAFNetworkManager.h
//  wallet
//
//  Created by Song on 2018/7/30.
//  Copyright © 2018年 atkj. All rights reserved.
//

#import "AFNetworking.h"


@class MBProgressHUD;
@interface LQAFNetworkManager : AFHTTPSessionManager

+ (instancetype)manager;

-(void)requestPostWithUrl:(NSString*)url
                   params:(NSDictionary*)params
                  success:(void(^)(id response))success
                  failure:(void(^)(NSError *error))failure;

//下载zip文件
-(void)downlaodTaskWithUrl:(NSString*)url
                  Progress:(MBProgressHUD*)progress
               packageName:(NSString*)packageName
               versionName:(NSString*)versionName
                   success:(void(^)(id response))success
                   failure:(void(^)(NSError *error))failure;
@end
