//
//  DataManager.h
//  CSIIJSBridge
//
//  Created by 李佛军 on 2021/10/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DataManager : NSObject
+(instancetype)shareManager;
//获取token
-(void)setToken:(NSString*)token;
-(NSString*)getToken;
@end

NS_ASSUME_NONNULL_END
