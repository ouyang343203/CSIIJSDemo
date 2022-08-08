//
//  PluginUpdateManager.h
//  CSIIJSBridge
//
//  Created by Song on 2021/6/23.
//

#import <Foundation/Foundation.h>

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
/*
 *@params
    {
    versionNumber
    area
    }
 *
 */
//----在AppDelegate置好 projectId、postUrl、domainName
//离线包
- (void)startH5ViewControllerWithNebulaParams:(NSDictionary *)params;
//在线
- (void)startH5ViewControllerWithUrlParams:(NSDictionary *)params;

/*
 {
name:myMessage,
versionNumber:0,
area:广东省深圳市
projectId:972BF2811A76421BB37D5E93167EC536
 postUrl:
 navagation:
 {
 webPath
 titleStr;//标题
 titleColor; //标题颜色(0x111110)(NSInteger)
 titlefont;//标题大小（float）
 naviBarColor;//导航栏颜色
 left_back_icon;//左侧按钮--修改返回按钮
 left_text;//左侧按钮文字
 right_icon;//右侧按钮
 right_text;//右侧按钮文字
 }
 */
-(void)startupParams:(NSDictionary*)params;
-(NSString*)getDomian;
@end

NS_ASSUME_NONNULL_END
