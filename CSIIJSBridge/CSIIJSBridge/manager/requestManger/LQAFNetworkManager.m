//
//  LQAFNetworkManager.m
//  wallet
//
//  Created by Song on 2018/7/30.
//  Copyright © 2018年 atkj. All rights reserved.
//

#import "LQAFNetworkManager.h"
#import "packageManager.h"
#import "ZipArchive.h"
#import "UIProgressView+AFNetworking.h"
#import "MBProgressHUD.h"
#import "GlobalMacro.h"
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )

@interface LQAFNetworkManager ()

@end

@implementation LQAFNetworkManager

+ (instancetype)manager {
    static LQAFNetworkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[LQAFNetworkManager alloc]initWithBaseURL:nil];
    });
    return manager;
}


-(void)requestPostWithUrl:(NSString*)url
                   params:(NSDictionary*)params
                  success:(void(^)(id response))success
                  failure:(void(^)(NSError *error))failure
{
    if (kDictIsEmpty(params))
    {
        params = @{};
    }
    [self getdownloadfileUrl:url params:params success:success failure:failure];
}

-(void)requestGetWithUrl:(NSString*)url
                  success:(void(^)(id response))success
                 failure:(void(^)(NSError *error))failure {

    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *httpLink= url;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"GET" URLString:httpLink parameters:nil error:nil];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setTimeoutInterval:15];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[LQAFNetworkManager manager] dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSDictionary *reponseDic = responseObject;
        NSLog(@"responseObject ==%@",responseObject);
        if (error) {
              failure(error);
        }else{
            if ([reponseDic[@"status"] isEqualToString:@"000000"]||[reponseDic[@"code"] isEqualToString:@"200"])
            {
                success(responseObject);
            }
        }
        
    }];
    
    [dataTask resume];
}


-(void)requestPostStrparamsWithUrl:(NSString*)url
                    params:(NSString*)params
                   success:(void(^)(id response))success
                   failure:(void(^)(NSError *error))failure
{

//    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
//    NSData *body = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *httpLink= url;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:httpLink parameters:params error:nil];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
//    [request setHTTPBody:body];
    [request setTimeoutInterval:15];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[LQAFNetworkManager manager] dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSDictionary *reponseDic = responseObject;
        NSLog(@"responseObject ==%@",responseObject);
        if (error) {
              failure(error);
        }else{
            if ([reponseDic[@"status"] isEqualToString:@"000000"]||[reponseDic[@"code"] isEqualToString:@"200"])
            {
                success(responseObject);
            }
        }
        
    }];
    
    [dataTask resume];
}

-(void)getdownloadfileUrl:(NSString*)url
                    params:(NSDictionary*)params
                   success:(void(^)(id response))success
                   failure:(void(^)(NSError *error))failure
{

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    NSData *body = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *httpLink= url;
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] requestWithMethod:@"POST" URLString:httpLink parameters:params error:nil];
    [request setValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPBody:body];
    [request setTimeoutInterval:15];
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [[LQAFNetworkManager manager] dataTaskWithRequest:request uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSDictionary *reponseDic = responseObject;
        NSLog(@"responseObject ==%@",responseObject);
        if (error) {
              failure(error);
        }else{
            if ([reponseDic[@"status"] isEqualToString:@"000000"]||[reponseDic[@"code"] isEqualToString:@"200"])
            {
                success(responseObject);
            }
        }
        
    }];
    
    [dataTask resume];
}


-(void)downlaodTaskWithUrl:(NSString*)url
                  Progress:(MBProgressHUD*)progress
               packageName:(NSString*)packageName
               versionName:(NSString*)versionName
                   success:(void(^)(id response))success
                   failure:(void(^)(NSError *error))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
   
    NSURLSessionDownloadTask *dataTask = nil;
   
    dataTask = [self downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        dispatch_async(dispatch_get_main_queue(), ^{
            
           progress.progress = 1.0 *downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
            if (progress.progress ==1.0) {
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [progress setHidden:YES];
                });
            }
            progress.label.text = [NSString stringWithFormat:@"%.0f%%",(float)downloadProgress.completedUnitCount / downloadProgress.totalUnitCount*100];
        
              });
   
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        NSString *fileName = [packageManager createFilePackageName:packageName versionNumber:versionName];//创建离线包的的地址
        NSURL *fileUrl = [NSURL fileURLWithPath:fileName];
        return fileUrl;
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"completionHandler filePath = %@",filePath);
        NSString *path = [filePath path];
        NSLog(@"completionHandler= %@",path);
        //解压文件
        BOOL isUnzip = [self unzipFileAtPath:path  toFilePaht:[packageManager getFilePackageName:packageName versionNumber:versionName]];
        BOOL isDelete = [self zipFileDelete:path];
        if (isUnzip && isDelete) {
            success(versionName);
        }else{
            failure(error);
        }
    }];
    [dataTask resume];
}

//解压文件是否成功
-(BOOL)unzipFileAtPath:(NSString*)name toFilePaht:(NSString*)toName{
    return [SSZipArchive unzipFileAtPath:name toDestination:toName];
}

-(BOOL)zipFileDelete:(NSString*)name{
    return [packageManager fileDelete:name];
}
@end
