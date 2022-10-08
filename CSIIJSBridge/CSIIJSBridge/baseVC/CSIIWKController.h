//
//  CSIIWKController.h
//  CSIIJSBridge
//
//  Created by Song on 2021/6/25.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface CSIIWKController : UIViewController

@property (nonatomic, strong) NSString *webPath;
@property (nonatomic, strong) NSString *titleStr;//标题
@property (nonatomic, strong) UIColor *titleColor;//标题颜色
@property (nonatomic, assign) CGFloat titlefont;//标题大小
@property (nonatomic, strong) UIColor *naviBarColor;//导航栏颜色
@property (nonatomic, strong) NSString *left_back_icon;//左侧按钮--修改返回按钮
@property (nonatomic, strong) NSString *left_text;//左侧按钮文字
@property (nonatomic, strong) NSString *right_icon;//右侧按钮
@property (nonatomic, strong) NSString *right_text;//右侧按钮文字
@property (nonatomic, strong) WKWebView *wkWebView;
@property (nonatomic, assign) BOOL IsH5Back; //是否H5自由控制返回
@property (nonatomic, assign) BOOL isH5PopHome; //是否需要直接返回到最前面
@property (nonatomic, assign) NSInteger homePageIndex; //第几层页面
@property (nonatomic, assign) NSInteger pageIndex; //第几层页面

-(void)loadNativeHFive:(NSString*)path;
-(void)loadUrl:(NSString*)url;
-(void)setNaviTitle:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
