//
//  GlobalMacro.h
//  CSIIJSBridge
//
//  Created by Song on 2021/6/23.
//

#ifndef GlobalMacro_h
#define GlobalMacro_h

#define KScreenWidth           [UIScreen mainScreen].bounds.size.width
#define KScreenHeight           [UIScreen mainScreen].bounds.size.height

#define MyFont(FontSize)            [UIFont systemFontOfSize:FontSize]
#define MyBoldFont(FontSize)        [UIFont boldSystemFontOfSize:FontSize]

#define HEXCOLOR(hex)           [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]

#define IS_IPAD             (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE           (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

#define SCREEN_MAX_LENGTH   (MAX(SCREEN_W, SCREEN_H))
#define SCREEN_MIN_LENGTH   (MIN(SCREEN_W, SCREEN_H))
#define IS_IPHONE_5         (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0f)
#define IS_IPhoneX          [[UIScreen mainScreen] bounds].size.width >= 375.0f && [[UIScreen mainScreen] bounds].size.height >= 812.0f && IS_IPHONE

//iphone x适配相关
//iphone x StatusBar+NavgationBar高度
#define KNavBarHeight (IS_IPhoneX ? 88 : 64)
//iphone x 底部圆角区域高度
#define kTabBarBottomHeight (IS_IPhoneX ? 34 : 0)
//iphone x StatusBar高度
#define KStatusBarHeight (IS_IPhoneX ? 44 : 20)
//iphone x TabBar+底部圆角区域高度
#define KTabBarHeight (IS_IPhoneX ? 83 : 49)
//分类标题栏高度
#define kTabTitleViewHeight  45
#define BOUNDS [[UIScreen mainScreen] bounds]



//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

#define __IsStringValid(_str) (_str && [_str isKindOfClass:[NSString class]] && ([_str length] > 0))
#define __IsArrayValid(_array) (_array && [_array isKindOfClass:[NSArray class]] && ([_array count] > 0))
#define __IsDictionaryValid(__dic) (__dic && [__dic isKindOfClass:[NSDictionary class]] && ([__dic count] > 0))

//APP版本号
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//系统版本号
#define kSystemVersion [[UIDevice currentDevice] systemVersion]
//获取当前语言
#define kCurrentLanguage ([[NSLocale preferredLanguages] objectAtIndex:0])
//判断是否为iPhone
#define kISiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//判断是否为iPad
#define kISiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)//屏幕的宽高
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)//屏幕的宽高
//16进制颜色转换
#define kCSIIRGBHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define kCSIIRGBHexAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#ifdef DEBUG
#define NSLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define NSLog(...)
#endif

#endif /* GlobalMacro_h */
