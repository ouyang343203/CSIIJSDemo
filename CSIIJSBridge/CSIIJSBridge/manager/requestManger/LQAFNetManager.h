//
//  LQAFNetManager.h
//  liqiaobank
//
//  Created by ouyang on 2022/8/23.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "LQAFNetManager.h"
#import "BaseModel.h"
#import "MBProgressHUD.h"
#import "SSZipArchive.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, RequestMethod) {
    RequestMethodGet,
    RequestMethodPost,
    RequestMethodPut,
    RequestMethodDelete
};


@interface LQAFNetManager : AFHTTPSessionManager

+ (LQAFNetManager *)sharedManager;

/** GET请求
 *  mapper:映射的Model对象
 */
- (void)getWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure;

/** POST请求
 *  mapper:映射的Model对象
 */
- (void)postWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure;

/** PUT请求
 *  mapper:映射的Model对象
 */
- (void)putWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure;

/** DELETE请求
 *  mapper:映射的Model对象
 */
- (void)deleteWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure;

/** 下载zip文件
 *  url:下载地址
 *  packageName:文件名称
 *  versionName:版本名称
 */
-(void)downlaodTaskWithUrl:(NSString*)url Progress:(MBProgressHUD*)progress packageName:(NSString*)packageName versionName:(NSString*)versionName success:(void(^)(id response))success failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
