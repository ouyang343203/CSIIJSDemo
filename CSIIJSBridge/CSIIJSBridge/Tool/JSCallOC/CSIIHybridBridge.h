//
//  CSIIHybridBridge.h
//  CSIIPluginDownLoadDemo1
//
//  Created by Song on 2021/6/25.
//

#import <Foundation/Foundation.h>
#import "WKWebViewJavascriptBridge.h"

NS_ASSUME_NONNULL_BEGIN
@class WKWebView,CSIIWKHybridBridge;
@interface CSIIHybridBridge : NSObject

typedef void(^FNHybridBridgeHandler)(CSIIHybridBridge* bridge,id data, WVJBResponseCallback responseCallback);

@property (nonatomic, strong) CSIIWKHybridBridge *bridge;
@property (nonatomic, strong) WKWebView *wkWebView;

+ (instancetype)shareManager;
- (void)bridgeForWebView:(WKWebView*)webView;
- (void)setBridgeAction;

@end

NS_ASSUME_NONNULL_END
