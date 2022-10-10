//
//  rootViewController.h
//  CSIIJSBridgeDemo
//
//  Created by Song on 2021/7/7.
//

#import <CSIIJSBridge/CSIIJSBridge.h>
// 空一行
NS_ASSUME_NONNULL_BEGIN

@interface rootViewController : CSIIWKController
// 空一行
- (void)updateName:(NSString *)name age:(int)age; // 方法名必须以小写字母开头
// 空一行
// 页面排版规范
#pragma mark - HTTP Method -- 网络请求

// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法


#pragma mark - Private Method -- 私有方法


#pragma mark - Action


#pragma mark - Public Method -- 公开方法


#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式

@end

NS_ASSUME_NONNULL_END
