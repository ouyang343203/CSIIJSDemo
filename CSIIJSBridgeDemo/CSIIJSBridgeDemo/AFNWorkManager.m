//
//  AFNWorkManager.m
//  CSIIJSBridge
//
//  Created by 李佛军 on 2021/10/8.
//

#import "AFNWorkManager.h"
#import "AFNetworking.h"
#import "DataManager.h"
@implementation AFNWorkManager

+ (instancetype)manager {
    static AFNWorkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFNWorkManager alloc]init];
    });
    return manager;
}
-(void)requestWithType:(requestType)requestType
              withUrl:(NSString*)url
               params:(NSDictionary*)params
              success:(void(^)(id response))success
              failure:(void(^)(NSError *error))failure
{

    switch (requestType) {
        case requestTypeGet:
        
            [self requestWithTypeGet:url params:params success:success failure:failure];
        
            break;
        case requestTypePost:
            [self requestWithTypePost:url params:params success:success failure:failure];
            break;
        default:
            break;
    }
}

-(void)requestWithTypeGet:(NSString*)urlStr
                   params:(NSDictionary*)params
                  success:(void(^)(id response))success
                  failure:(void(^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[[DataManager shareManager] getToken] forHTTPHeaderField:@"X-Access-Token"];
//    [manager.requestSerializer setValue:@"1d0ce41d-ebb3-4fec-896d-8b93bedbfb29" forHTTPHeaderField:@"X-Access-Token"];

    [manager GET:urlStr parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject == %@",responseObject);
        if ([responseObject[@"code"] integerValue]==510) {
            NSLog(@"responseObject == %@",responseObject[@"code"]);
        }
        NSString *code = responseObject[@"code"] ;
        if ([responseObject[@"code"] isEqualToNumber:@510]) {
            NSLog(@"error == %@",code);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            success(responseObject);
        });
       
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error == %@",error);
        failure(error);
    }];
    [manager tasks];
}
-(void)requestWithTypePost:(NSString*)urlStr
                   params:(NSDictionary*)params
                  success:(void(^)(id response))success
                  failure:(void(^)(NSError *error))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [manager.requestSerializer setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[[DataManager shareManager] getToken] forHTTPHeaderField:@"X-Access-Token"];
//    [manager.requestSerializer setValue:@"1d0ce41d-ebb3-4fec-896d-8b93bedbfb29" forHTTPHeaderField:@"X-Access-Token"];
    
    
    [manager POST:urlStr parameters:params headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"responseObject = %@",responseObject);
        if ([responseObject[@"code"] integerValue]==510) {
            NSLog(@"responseObject == %@",responseObject[@"code"]);
        }
        NSString *code = responseObject[@"code"] ;
        if ([responseObject[@"code"] isEqualToNumber:@510]) {
            NSLog(@"error == %@",code);
        }
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        failure(error);
    }];
}
@end
