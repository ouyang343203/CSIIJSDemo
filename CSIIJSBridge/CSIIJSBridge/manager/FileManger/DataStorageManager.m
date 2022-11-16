//
//  DataStorageManager.m
//  PluginPackageDownLoad
//
//  Created by Song on 2021/6/22.
//

#import "DataStorageManager.h"
#define oldVersion @"oldVerson"//记录登陆过的版本号
#define roodIndexUrl @"pageRoodUrl"//roodUrl
@implementation DataStorageManager
+(instancetype)shareManager {
    static DataStorageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataStorageManager alloc] init];
    });
    return manager;
}

+(void)setPackage:(NSString*)key withVule:(NSString*)packageName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:packageName forKey:key];
    [userDefaults synchronize];
}

+(NSString*)getPackage:(NSString*)key {
    NSUserDefaults*userDefaults=[NSUserDefaults standardUserDefaults];
    NSString*package=[userDefaults objectForKey:key];
    return package;
}
//清楚所有的本地数据慎用
+(void)clearAllUserDefaultsData {
    NSUserDefaults *defatluts = [NSUserDefaults standardUserDefaults];
    NSDictionary *dictionary = [defatluts dictionaryRepresentation];
    for(NSString *key in [dictionary allKeys]){
        [defatluts removeObjectForKey:key];
        [defatluts synchronize];
    }
}

//存储版本号的名字(记录上一次登陆过的版本号)
+(void)setVersion:(NSString*)versionName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:versionName forKey:oldVersion];
    [userDefaults synchronize];
}

//获取版本号名字
+(NSString*)getVersion {
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:oldVersion];
}

//缓存首页地址
+(void)seteRootUrl:(NSString*)rootUrl {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:rootUrl forKey:roodIndexUrl];
    [userDefaults synchronize];
}

+(NSString*)getRootUrl {
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:roodIndexUrl];
}

@end
