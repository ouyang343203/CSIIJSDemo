//
//  PluginUpdateManager.h
//  CSIIJSBridge
//
//  Created by Song on 2021/6/23.
//

#import <Foundation/Foundation.h>
#import <CSIIJSBridge/CSIIJSBridge.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const JGCSIIJumpSuccessfulNotification; // 跳转成功通知
extern NSString *const JGCSIILoginOutNotification;     // 退出登录跳转通知
@class CSIIWKController;

@interface PluginUpdateManager : NSObject
//配置appid 项目ID
@property (nonatomic,strong) NSString *projectId;
//请求的地址
@property (nonatomic,strong) NSString *postUrl;
//导航栏的配置信息
@property (nonatomic,strong) NSDictionary *navDic;
//域名地址
@property (nonatomic,strong) NSString *domainName;

@property (nonatomic,strong) NSString *pathUrl;
//请求post/get的域名信息
@property (nonatomic,strong) NSString *requestDomian;
/* 
 *存储的名字离线包资源的名字
 默认不传按appName存储
 */
@property (nonatomic,strong) NSString *storageName;

//跳转离线包 appName包名 params参数名
+(instancetype)shareManager;

#pragma mark - HTTP Method -- 网络请求

// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法


#pragma mark - Private Method -- 私有方法


#pragma mark - Action


#pragma mark - Public Method -- 公开方法

//离线包
- (void)startH5ViewControllerWithNebulaParams:(NSDictionary *)params;
//离线包
- (void)startH5ViewControllerWithNebulaParams:(NSDictionary *)params withController:(CSIIWKController*)controller;

//在线
- (void)startH5ViewControllerWithUrlParams:(NSDictionary *)params;

-(NSString*)getDomian;

@end

NS_ASSUME_NONNULL_END
