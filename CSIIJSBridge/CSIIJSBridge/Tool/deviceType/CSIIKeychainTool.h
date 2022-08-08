//
//  CSIIKeychainTool.h
//  JXNXMobileBankingiOS
//
//  Created by Song on 2020/5/7.
//  Copyright © 2020 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Foundation/Foundation.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSIIKeychainTool : NSObject

/**
 本方法是得到 UUID 后存入系统中的 keychain 的方法
 不用添加 plist 文件
 程序删除后重装,仍可以得到相同的唯一标示
 但是当系统升级或者刷机后,系统中的钥匙串会被清空,此时本方法失效
 */
+(NSString *)getDeviceIDInKeychain;

/*
 获取手机型号
 */
+ (NSString *)getDeviceType;

/*
 获取手机别名
 */
+ (NSString *)getDeviceName;

/*
 获取mac地址
 */
+ (NSString *)getMacAddress;
/*
 获取手机IMEI
 */
+ (NSString *)getIMEI;
/*
 获取项目版本号
 */
+ (NSString *)getVersion;

@end

NS_ASSUME_NONNULL_END
