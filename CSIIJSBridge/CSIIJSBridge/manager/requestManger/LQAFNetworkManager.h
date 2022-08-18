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

//post请求请求参数是字典
-(void)requestPostWithUrl:(NSString*)url
                   params:(NSDictionary*)params
                  success:(void(^)(id response))success
                  failure:(void(^)(NSError *error))failure;

//get请求
-(void)requestGetWithUrl:(NSString*)url
                  success:(void(^)(id response))success
                  failure:(void(^)(NSError *error))failure;

//post请求请求参数是string
-(void)requestPostStrparamsWithUrl:(NSString*)url
                    params:(NSString*)params
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
