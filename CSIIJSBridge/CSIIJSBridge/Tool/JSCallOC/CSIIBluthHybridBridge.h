//
//  CSIIBluthHybridBridge.h
//  CSIIJSBridge
//
//  Created by ouyang on 2022/9/5.
//

#import <Foundation/Foundation.h>
#import "WKWebViewJavascriptBridge.h"
NS_ASSUME_NONNULL_BEGIN

@class WKWebView,CSIIWKHybridBridge;

@interface CSIIBluthHybridBridge : NSObject

@property (nonatomic, strong) CSIIWKHybridBridge *bridge;
@property (nonatomic, strong) WKWebView *wkWebView;


+ (instancetype)shareManager;
- (void)bridgeForWebView:(WKWebView*)webView;


@end

NS_ASSUME_NONNULL_END
