//
//  DataStorageManager.h
//  PluginPackageDownLoad
//
//  Created by Song on 2021/6/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataStorageManager : NSObject

@property (nonatomic,strong)NSDictionary *torageDic;

+(instancetype)shareManager;
//存储缓存
//+(void)setStorage:(NSString*)key;
//存储数据
+(void)setPackage:(NSString*)key withVule:(NSString*)packageName;
//获取数据
+(NSString*)getPackage:(NSString*)key;
//清楚所有的本地数据慎用
+(void)clearAllUserDefaultsData;
//存储版本号的名字
+(void)setVersion:(NSString*)versionName;
//获取版本号名字
+(NSString*)getVersion;
//缓存首页地址
+(void)seteRootUrl:(NSString*)rootUrl;
//取出首页地址
+(NSString*)getRootUrl;
@end

NS_ASSUME_NONNULL_END
