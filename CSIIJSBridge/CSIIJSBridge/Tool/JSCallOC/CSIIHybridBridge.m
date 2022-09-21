//
//  CSIIHybridBridge.m
//  CSIIPluginDownLoadDemo1
//
//  Created by Song on 2021/6/25.
//

#import "CSIIHybridBridge.h"
#import "WKWebViewJavascriptBridge.h"
#import "CSIIWKHybridBridge.h"
#import "GlobalMacro.h"
#import "CSIITMPFileManager.h"
#import "PluginUpdateManager.h"
#import "CSIIGloballTool.h"
#import "DataStorageManager.h"
#import "PluginUpdateManager.h"
#import "CSIIWKController.h"
#import "SharedItem.h"
#import "AFNWorkManager.h"
#import "DataManager.h"
#import "BLEBluetoolthManager.h"
#import "reachabilityManager.h"
#import "LQAFNetworkManager.h"
#import "JYToastUtils.h"
#import <objc/runtime.h>
#import "HKBabyBluetoothManager.h"
#define  KputKey  @"putKey"
#define  REQUEST_URL_DEFAULT  @"http://183.62.118.51:10088"

#define kFNHybridBridgeRegisterHandlersKey @"kFNHybridBridgeRegisterHandlersKey"
#define kFNHybridBridgeRegisterBridgeHandlersKey @"kFNHybridBridgeRegisterBridgeHandlersKey"

typedef void (^ResponseCallback)(NSString *responseData);

@interface CSIIHybridBridge()<UIDocumentInteractionControllerDelegate,DateTimePickerViewDelegate>

@property (nonatomic, strong) PhotoAlertView *photoView;
@property (nonatomic, strong) WVJBResponseCallback responseCallback;

@end
@implementation CSIIHybridBridge

+(instancetype)shareManager {
    static CSIIHybridBridge *hybridBridge = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hybridBridge = [[CSIIHybridBridge alloc] init];
    });
    return hybridBridge;
}
// 页面排版规范
#pragma mark - HTTP Method -- 网络请求
- (void)loadProxyGetRequestDataHandler:(ResponseCallback)responseCallback {
    [[reachabilityManager manager]monitoringNetWork:^(bool result) {
        NSLog(@"result = %d",result);
        if (result) {
            [[LQAFNetworkManager manager] requestGetWithUrl:REQUEST_URL_DEFAULT success:^(id response) {
                NSDictionary *dic = (NSDictionary*)response[@"data"];
                NSString *datastr = [CSIICheckObject dictionaryChangeJson:dic];
                responseCallback(datastr);
            } failure:^(NSError *error) {
                [JYToastUtils showWithStatus:@"请求失败!"];
            }];
        }else{
            [JYToastUtils showWithStatus:@"网络连接失败!"];
        }
    }];
}

- (void)loadProxyPostRequestDataBy:(NSString*)param responseCallback:(ResponseCallback)responseCallback{
    [[reachabilityManager manager]monitoringNetWork:^(bool result) {
        NSLog(@"result = %d",result);
        if (result) {
            [[LQAFNetworkManager manager]requestPostStrparamsWithUrl:REQUEST_URL_DEFAULT params:param success:^(id response) {
                NSDictionary *dic = (NSDictionary*)response[@"data"];
                NSString *datastr = [CSIICheckObject dictionaryChangeJson:dic];
                responseCallback(datastr);
            } failure:^(NSError *error) {
                [JYToastUtils showWithStatus:@"请求失败!"];
            }];
        }else{
            [JYToastUtils showWithStatus:@"网络连接失败!"];
        }
    }];
}
// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法


#pragma mark - Private Method -- 私有方法

#pragma mark 跳包
-(void)toZipPage{
    [self.bridge registerHandler:@"toZipPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *name = @"";
        NSInteger type = [data[@"type"] intValue];
        NSDictionary *parmas = @{};

        if (!kStringIsEmpty(data[@"name"])) {
            name = data[@"name"];
        }
        if (!kObjectIsEmpty(data[@"params"])) {
            parmas = data[@"params"];
        }

        NSDictionary *Dic = @{@"name":name,
                            @"navagation":[PluginUpdateManager shareManager].navDic,
                            @"pagedata":parmas
        };

        if (name.length) {
            if (type == 1 || type == 2 ) {
                name = [NSString stringWithFormat:@"%@://%@",type == 1 ? @"https" : @"http",name];

                Dic = @{@"name":name,
                        @"navagation":[PluginUpdateManager shareManager].navDic,
                        @"pagedata":parmas
                };
                [[PluginUpdateManager shareManager]startH5ViewControllerWithUrlParams:Dic];

            }else{

                [[PluginUpdateManager shareManager]startH5ViewControllerWithNebulaParams:Dic];
            }
        }
        if (responseCallback) {
            responseCallback(@"这是OC给JS的反馈哦~");
        }
    }];
}

#pragma mark 刷新指定模块
-(void)refreshPage{
    [self.bridge registerHandler:@"refreshPage" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:data[@"refreshClass"] object:nil];
    }];
}

#pragma mark 设置标题
-(void)setTitle{
    [self.bridge registerHandler:@"setTitle" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            [[CSIIGloballTool shareManager] findCurrentShowingViewController].title = data[@"title"];
        } else if ([data isKindOfClass:[NSString class]]){
            CSIIWKController *webStr = (CSIIWKController *)[[CSIIGloballTool shareManager] findCurrentShowingViewController];
            [webStr setNaviTitle:data];
        }
    }];
}

#pragma mark 显示或隐藏导航栏
- (void)showOrHideNav {
    [self.bridge registerHandler:@"operHdNav" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            
            BOOL isShow = [data[@"isShow"] boolValue];
            
            CSIIWKController *webStr = (CSIIWKController *)[[CSIIGloballTool shareManager]findCurrentShowingViewController];
            
            if (isShow) {
                
                webStr.navigationController.navigationBarHidden = NO;
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
                
                webStr.wkWebView.frame = CGRectMake(0, KNavBarHeight, KScreenWidth, KScreenHeight-kTabBarBottomHeight-KNavBarHeight);
            } else {
                webStr.navigationController.navigationBarHidden = YES;
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                webStr.wkWebView.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight-kTabBarBottomHeight);
            }
        }
    }];
}

#pragma mark 右上角按钮
- (void)setRightNav {
    [self.bridge registerHandler:@"setGoBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        CSIIWKController *webStr = (CSIIWKController *)[[CSIIGloballTool shareManager]findCurrentShowingViewController];
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            BOOL isShow = [data[@"isShow"] boolValue];
            UIBarButtonItem *items1;
            UIBarButtonItem *items2;
            if (isShow) {
                //初始化右侧按钮
                if ([data[@"buttons"] isKindOfClass:[NSArray class]]) {
                    NSArray *buttons = data[@"buttons"];
                    if (buttons.count > 1) {
                        //2个按钮以上
                        NSDictionary *dic1 = buttons[0];
                        NSDictionary *dic2 = buttons[1];
                        if ([dic1[@"type"] isEqual:@"img"]) {
                            NSData * imageData = [[NSData alloc]initWithBase64EncodedString:dic1[@"data"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            UIImage *rightImage = [UIImage imageWithData:imageData];
                            rightImage =  [rightImage originScaleToSize:CGSizeMake(20, 20)];
                            items1 = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStyleDone target:self action:@selector(rightAction:)];
                            items1.tag = 10000;
                        } else {
                            items1 = [[UIBarButtonItem alloc]initWithTitle:dic1[@"data"] style:UIBarButtonItemStyleDone target:self action:@selector(rightAction:)];
                            items1.tag = 10000;
                        }
                        if ([dic2[@"type"] isEqual:@"img"]) {
                            NSData * imageData = [[NSData alloc]initWithBase64EncodedString:dic2[@"data"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            UIImage *rightImage = [UIImage imageWithData:imageData];
                            rightImage =  [rightImage originScaleToSize:CGSizeMake(20, 20)];
                            items2 = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStyleDone target:self action:@selector(rightAction:)];
                            items2.tag = 10001;
                        } else {
                            items2 = [[UIBarButtonItem alloc]initWithTitle:dic2[@"data"] style:UIBarButtonItemStyleDone target:self action:@selector(rightAction:)];
                            items2.tag = 10001;
                        }
                        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
                        negativeSpacer.width = -5;
                        UIBarButtonItem *negativeSpacer2 = [[UIBarButtonItem alloc]   initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace   target:nil action:nil];
                        negativeSpacer2.width = 15;
                        
                        webStr.navigationItem.rightBarButtonItems = @[items2,negativeSpacer2,items1,negativeSpacer];
                        
                    } else if(buttons.count > 0) {
                        NSDictionary *dic1 = buttons[0];
                        if ([dic1[@"type"] isEqual:@"img"]) {
                            NSData * imageData = [[NSData alloc]initWithBase64EncodedString:dic1[@"data"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
                            UIImage *rightImage = [UIImage imageWithData:imageData];
                            rightImage =  [rightImage originScaleToSize:CGSizeMake(20, 20)];
                            items1 = [[UIBarButtonItem alloc] initWithImage:rightImage style:UIBarButtonItemStyleDone target:self action:@selector(rightAction:)];
                            items1.tag = 10000;
                        } else {
                            items1 = [[UIBarButtonItem alloc]initWithTitle:dic1[@"data"] style:UIBarButtonItemStyleDone target:self action:@selector(rightAction:)];
                            items1.tag = 10000;
                        }
                        webStr.navigationItem.rightBarButtonItems = @[items1];
                    }
                } else {
                    webStr.navigationItem.rightBarButtonItems = @[];
                }
            } else {
                webStr.navigationItem.rightBarButtonItems = @[];
            }
        } else {
            NSLog(@"setGoBack error");
        }
         
    }];
}

#pragma mark 关掉webview
- (void)closePage   {
    [self.bridge registerHandler:@"closePage" handler:^(id data, WVJBResponseCallback responseCallback) {
    
       [[[CSIIGloballTool shareManager]findCurrentShowingViewController].navigationController popViewControllerAnimated:YES];
    }];
}

#pragma mark 调用手机拨号
- (void)callPhone {
        [self.bridge registerHandler:@"callPhone" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *phoneStr = data[@"telephone"];

        if (phoneStr.length) {
            
            NSString *string = [NSString stringWithFormat:@"telprompt://%@",phoneStr];
            NSURL *url = [NSURL URLWithString:string];
            
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }else{
                NSLog(@"Incorrect format of mobile phone number");
            }
        } else {
            NSLog(@"Incorrect format of mobile phone number");
        }
    }];
}

#pragma mark 回到首页
-(void)toMain{
    [self.bridge registerHandler:@"toMain" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        CSIIWKController *webStr = (CSIIWKController *)[[CSIIGloballTool shareManager]findCurrentShowingViewController];
        
        webStr.navigationController.tabBarController.selectedIndex = 0;
        if (webStr.navigationController.viewControllers.count) {
            webStr.navigationController.navigationBarHidden = YES;
            [webStr.navigationController popToViewController:webStr.navigationController.viewControllers[0] animated:YES];
        } else {
            [webStr.navigationController popToRootViewControllerAnimated:YES];
        }
    }];
}

#pragma mark 获取一些常用信息
-(void)getBaseInfo{
    [self.bridge registerHandler:@"getBaseInfo" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@(KNavBarHeight) forKey:@"navHeight"];
        [dic setValue:[[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] forKey:@"version"];
        NSString *userInfo = [CSIICheckObject dictionaryChangeJson:dic];
        responseCallback(userInfo);
        
    }];
}

#pragma mark 系统分享，保存Pdf
- (void)savePdf {
    [self.bridge registerHandler:@"savePdf" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *titleStr = data[@"title"];
        if (!titleStr.length) {
            titleStr = @"pdfStream";
        }
        
        NSData *pdfData = [[NSData alloc] initWithBase64EncodedString:data[@"pdfStream"] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *strPath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pdf",titleStr]];
        BOOL success = [pdfData writeToFile:strPath atomically:YES];
        if (success) {
           // NSURL *pathUrl1 = [[NSBundle mainBundle] URLForResource:strPath withExtension:@".pdf"];
            NSURL *pathUrl = [NSURL fileURLWithPath:strPath];
            if (pathUrl) {
                UIDocumentInteractionController *documentIntertactionController = [UIDocumentInteractionController interactionControllerWithURL:pathUrl];
                documentIntertactionController.delegate = self;
                [documentIntertactionController presentOptionsMenuFromRect:self.wkWebView.bounds inView:self.wkWebView animated:YES];
            }
        } else {
            NSLog(@"Failed to share pdf");
        }
        
    }];
}

#pragma mark 系统分享图片
- (void)downloadImage {
    [self.bridge registerHandler:@"downloadImage" handler:^(id data, WVJBResponseCallback responseCallback) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            //拿图片数组
            NSArray *listArray = @[];
            if ([data[@"list"] isKindOfClass:[NSArray class]]) {
                listArray = data[@"list"];
            }
            if (listArray.count) {
                NSMutableArray *array = [[NSMutableArray alloc]init];
                for (int i = 0; i <8 && i<listArray.count; i++) {
                    NSString *imageBase64Str  = listArray[i];
                    NSData * imageData = [[NSData alloc]initWithBase64EncodedString:imageBase64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
                        UIImage *imagerang = [UIImage imageWithData:imageData];
                    NSString *path_sandox = NSHomeDirectory();
                    NSString *imagePath = [path_sandox stringByAppendingString:[NSString stringWithFormat:@"/Documents/ShareWX%d.jpg",i]];
                    [UIImagePNGRepresentation(imagerang) writeToFile:imagePath atomically:YES];
                    NSURL *shareobj = [NSURL fileURLWithPath:imagePath];
                     /** 这里做个解释 imagerang : UIimage 对象  shareobj:NSURL 对象 这个方法的实际作用就是 在调起微信的分享的时候 传递给他 UIimage对象,在分享的时候 实际传递的是 NSURL对象 达到我们分享九宫格的目的 */
                    SharedItem *item = [[SharedItem alloc] initWithData:imagerang andFile:shareobj];
                    [array addObject:item];
                    
                }
                UIActivityViewController *activityViewController =[[UIActivityViewController alloc] initWithActivityItems:array
                                                                                                    applicationActivities:nil];
                //尽量不显示其他分享的选项内容
             //   activityViewController.excludedActivityTypes = @[UIActivityTypePostToFacebook,UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypeMessage,UIActivityTypeMail,UIActivityTypePrint,UIActivityTypeCopyToPasteboard,UIActivityTypeAssignToContact,UIActivityTypeSaveToCameraRoll,UIActivityTypeAddToReadingList,UIActivityTypePostToFlickr,UIActivityTypePostToVimeo,UIActivityTypePostToTencentWeibo,UIActivityTypeAirDrop,UIActivityTypeOpenInIBooks];
                if (activityViewController) {
                      [self.wkWebView.superViewController presentViewController:activityViewController animated:TRUE completion:nil];
                }
            }
        } else {
            NSLog(@"downloadImage Failed");
        }
    }];
}

#pragma mark 获取路由和参数
- (void)getToPageUrl {
    [self.bridge registerHandler:@"getToPageUrl" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:[PluginUpdateManager shareManager].pathUrl forKey:@"routerUrl"];
        [dic setValue:[DataStorageManager shareManager].torageDic forKey:@"params"];
        NSString *pageInfo = [CSIICheckObject dictionaryChangeJson:dic];
        responseCallback(pageInfo);
        
    }];
}
#pragma mark 复制内容到剪切板
- (void)copyToClipboard {
    [self.bridge registerHandler:@"copyToClipboard" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        if ([data isKindOfClass:[NSDictionary class]]) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = data[@"content"];
            
            [MBProgressHUD showMessage:@"复制成功"];
        } else {
            NSLog(@"copyToClipboard Failed");
        }
    }];
}

#pragma mark 存储删数据
-(void)setStorageData{
    [self.bridge registerHandler:@"setStorageData" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSInteger type = [data[@"type"] integerValue];
        NSString *key = data[@"key"];
        
        if (type == 1) {//存
            NSString *params = [CSIICheckObject dictionaryChangeJson:data[@"params"]];
            [KUserDefaults  setValue:params forKey:key];
            [KUserDefaults synchronize];

        }else if (type == 2){//取

            NSString *accessText = [KUserDefaults objectForKey:key];
            responseCallback(accessText);

        }else if (type == 3){//删

            [KUserDefaults  setValue:nil forKey:key];
            [KUserDefaults synchronize];
        }
    }];
}

#pragma mark 系统相机相册
-(void)getSystemCameraAlbum{
    [self.bridge registerHandler:@"getSystemCameraAlbum" handler:^(id data, WVJBResponseCallback responseCallback) {

        self.responseCallback = responseCallback;
        
        //0-相机 1-相册 2-相机相册
        NSInteger type = [data[@"type"] integerValue];
        
        switch (type) {
            case 0:
                //相机
                if (![CSIITool canCameraPermission]) {
                    
                    [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"系统相机授权未打开，请先去系统进行授权" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
                    }];
                    return;
                }
                [self.photoView checkCamera];
                break;
            case 1:
                //相册
                if (![CSIITool canPhotoPermission]) {
                    [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"系统相册授权未打开，请先去系统进行授权" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
                    }];
                    return;
                }
                [self.photoView checkPhotoLibrary];
                break;
            default: {
                //相机+相册
                [self.photoView showAlertViewWithIsEdit:YES];
            }
                break;
        }
    }];
}

#pragma mark 调用系统相机相册代理
- (void)backwithImage:(UIImage *)image withImageData:(NSData *)data {
    NSString *imageBase64Str = @"data:image/png;base64,";
    imageBase64Str= [imageBase64Str stringByAppendingString:[data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    NSDictionary *dic = @{@"state":@"Y",@"data":@{@"image":imageBase64Str}};
    self.responseCallback(dic);
}

#pragma mark 时间选择器
-(void)selectDate{
    [self.bridge registerHandler:@"selectDate" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        //0-年  1-年月  2-年月日
        float dateType = [data[@"dateType"] floatValue];
        dateType= 2;
        //0-选择选择今后日期 1-最大选择今天
        float isCurrentDateMax = [data[@"isCurrentDateMax"] floatValue];
        //标题
        NSString *title = data[@"title"];
        
        self.responseCallback = responseCallback;
        
        CSIIDatePickView *dateView = [[CSIIDatePickView alloc] initIsCurrentDateMax:isCurrentDateMax == 1 ? YES : NO];
        dateView.delegate = self;
        dateView.currentDate =  [NSDate date];
        dateView.pickerViewMode = dateType == 0 ? DatePickerViewDateYear : dateType == 1 ? DatePickerViewDateYearMonth : DatePickerViewDateYearMonthDay;
        if (!kStringIsEmpty(title)) {
            dateView.titleL.text = title;
        }
        [[UIApplication sharedApplication].keyWindow  addSubview:dateView];
        
        [dateView showDateTimePickerView];
        
    }];
}

- (void)didClickFinishDateTimePickerView:(NSString*)date{
    self.responseCallback(date);
}
#pragma mark 普通选择器
-(void)ItemsPickView{
    [self.bridge registerHandler:@"ItemsPickView" handler:^(id data, WVJBResponseCallback responseCallback) {
       
        if ([data[@"list"] isKindOfClass:[NSArray class]]) {
            
            NSArray *contextArr = data[@"list"];

            if (contextArr.count > 0) {
                CSIISelectItemView *view = [[CSIISelectItemView alloc] initWithTextArray:contextArr Title:data[@"title"]];
                [view showDateTimePickerView];
                
                view.FinishClick = ^(NSString * _Nonnull jsonStr) {
                    responseCallback(jsonStr);
                };
            }
        }
        
    }];
}

#pragma mark 返回
- (void)setGoBack {
    [self.bridge registerHandler:@"setGoBack" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        BOOL isHome = [data[@"home"] boolValue];
        
        CSIIWKController *webStr = (CSIIWKController *)[[CSIIGloballTool shareManager]findCurrentShowingViewController];
        
        if (isHome) {
            webStr.isH5PopHome = YES;
            webStr.IsH5Back = NO;
            webStr.homePageIndex = webStr.wkWebView.backForwardList.backList.count;
        } else {
            webStr.IsH5Back = YES;
            webStr.isH5PopHome = NO;
            webStr.pageIndex = webStr.wkWebView.backForwardList.backList.count;
            
        }
        
    }];
}

#pragma mark ---请求类
-(void)request {
    [self.bridge  registerHandler:@"getH5RequestProxy" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *params = (NSDictionary*)data;
        
        NSString *queryJson =params[@"TradeCode"];
        NSString *url = nil;
        if([queryJson rangeOfString:@"queryJson"].location==NSNotFound) {
        NSLog(@"string 不存在 martin");
            url = [NSString stringWithFormat:@"%@%@",[[PluginUpdateManager shareManager] getDomian],params[@"TradeCode"]];
        }else{
            NSRange range = [queryJson rangeOfString:@"queryJson"];
            NSString *subStr = [queryJson substringToIndex:range.location];//字符串之前
            NSString *fromStr = [queryJson substringFromIndex:range.location];
            NSString *reportName = [fromStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"{}\""].invertedSet];
        NSLog(@"string 包含 martin");
            url = [NSString stringWithFormat:@"%@%@%@",[[PluginUpdateManager shareManager] getDomian],subStr,reportName];
        }
        NSDictionary *param = nil;
        if ([[params allKeys]containsObject:@"Param"]) {
            param = params[@"Param"];
        }else{
            param = @{};
        }
        [[AFNWorkManager manager]requestWithType:requestTypeGet withUrl:url params:param success:^(id  _Nonnull response) {
            
            if (responseCallback)
                   {
                    responseCallback(response);
                   }
                } failure:^(NSError * _Nonnull error) {
                    
                    if (responseCallback) {
                        responseCallback(@"没有网络或者请求错误");
                    }
                }];
    }];
    [self.bridge  registerHandler:@"H5RequestProxy" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *params = (NSDictionary*)data;
        NSString *url = [NSString stringWithFormat:@"%@%@",[[PluginUpdateManager shareManager] getDomian],params[@"TradeCode"]];
        NSMutableDictionary *param = [NSMutableDictionary dictionaryWithDictionary:[self dictionaryWithJsonString:params[@"Param"]]];

        [[AFNWorkManager manager]requestWithType:requestTypePost withUrl:url params:param success:^(id  _Nonnull response) {
            
            if (responseCallback)
                   {
                    responseCallback(response);
                   }
                } failure:^(NSError * _Nonnull error) {
                    
                    if (responseCallback) {
                        responseCallback(@"没有网络或者请求错误");
                    }
                }];
    }];
    //注销登录
    [self.bridge registerHandler:@"logout" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[NSNotificationCenter defaultCenter] postNotificationName:JGCSIILoginOutNotification object:nil];
    }];
}

-(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

-(void)setBluetooth {
    __weak typeof(self) weakSelf = self;
   /* //1.初始化蓝牙设备。
    [self.bridge registerHandler:@"openBluetoothAdapter" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *diction = data;
        [[BLEBluetoolthManager shareBabyBluetooth] openBluetoothAdapter:diction];
        NSDictionary *diction1 = @{@"code":@"0",
                                  @"errMsg":@""};
        responseCallback([CSIICheckObject dictionaryChangeJson:diction1]);
    }];

    //2,获取本机蓝牙适配器状态(监听蓝牙打开和关闭状态)
    [self.bridge registerHandler:@"registerStateChangeListener" handler:^(id data, WVJBResponseCallback responseCallback) {

        [[BLEBluetoolthManager shareBabyBluetooth] getBluetoothAdapterState:^(id  _Nonnull resultState) {
            responseCallback(resultState);
        }];
    }];

    //3.搜索扫描蓝牙设备
    [self.bridge registerHandler:@"scanLeDevice" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *data_dic = (NSDictionary*)data;
        NSDictionary *diction = @{@"code":@"0",
                                  @"errMsg":@""};
        [[BLEBluetoolthManager shareBabyBluetooth] cancelAllPeripheralsConnection];
        responseCallback([CSIICheckObject dictionaryChangeJson:diction]);
        //设置扫描到设备的委托
        [[BLEBluetoolthManager shareBabyBluetooth] onBluetoothDeviceFound:data_dic callBack:^(id  _Nonnull searchResult) {//扫描获取到的外围设备
            NSDictionary *searchResultdic = searchResult;
            NSString *namestr = searchResultdic[@"name"];
            if ([namestr containsString:@"Dana"]) {
                [self.bridge callHandler:@"onFoundDevice" data:[CSIICheckObject dictionaryChangeJson:searchResult] responseCallback:^(id responseData) {}];
            }
        }];
    }];

    //复接口监听扫描到设备事件(备用)
    //4.连接蓝牙设备
    [self.bridge registerHandler:@"connect" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *Dic = @{@"code":@"0",
                              @"errMsg":@"",@"connet":@"连接回掉"};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
        NSString *dataStr = data;//设备号     NSLog(@"设备名称%@",dataStr);
        [[BLEBluetoolthManager shareBabyBluetooth] stopBluetoothDevicesDiscovery];
        [[BLEBluetoolthManager shareBabyBluetooth] createBLEConnection:dataStr callBack:^(id  _Nonnull connectResult) {
            //监听连接状态
            NSLog(@"监听连接状态 = connectResult%@",connectResult);
            [self.bridge callHandler:@"registerConnectStatusListener" data:connectResult responseCallback:^(id responseData) {}];
        }];
    }];

    //5.向蓝牙低功耗设备特征值中写入二进制数据
    [self.bridge registerHandler:@"writeCharacteristic" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *diction = (NSDictionary*)data;
        NSLog(@"向蓝牙低功耗设备特征值中写入二进制数据 ---data =====%@",diction);
        __block int index = 0;// 模拟耗时操作
        // 打印当前线程
        [[BLEBluetoolthManager shareBabyBluetooth] writeBLECharacteristicValue:diction callBack:^(id  _Nonnull writeValueResult) {

            NSString *writestr = writeValueResult;
            NSString * jsonString = writestr;
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
            NSString *states = dic[@"data"];
            NSLog(@"writeValueResult =====%@",states);
            //回传写入成功的和失败的状态
            [self.bridge callHandler:@"characterWriteStatusListener" data:states responseCallback:^(id responseData){}];
            if (index ==0) {
                responseCallback(writeValueResult);
                index+=1;
            }
        }];
    }];

    //6.停止蓝牙搜索(建立连接后需要断开搜索)
    [self.bridge registerHandler:@"stopLeScan" handler:^(id data, WVJBResponseCallback responseCallback) {

        [[BLEBluetoolthManager shareBabyBluetooth] stopBluetoothDevicesDiscovery];
    }];

    //7.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)
    [self.bridge registerHandler:@"getBLEDeviceServices" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSString * dataStr = data;//获取的设备号
        [[BLEBluetoolthManager shareBabyBluetooth] getBLEDeviceServices:dataStr callBack:^(id  _Nonnull servicesResult) {
            NSString * jsonString = servicesResult;
            NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];

            NSArray *serverces = dic[@"data"];
            if (serverces.count > 0) {
                responseCallback(servicesResult);
            }else{
                [JYToastUtils showWithStatus:@"获取服务失败"];
            }
        }];
    }];

    //8.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)
    [self.bridge registerHandler:@"getBLEDeviceCharacteristics" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *diction = (NSDictionary*)data;
        [[BLEBluetoolthManager shareBabyBluetooth] getBLEDeviceCharacteristics:diction callBack:^(id  _Nonnull characteristicsResult) {
            responseCallback(characteristicsResult);
        }];
    }];

    //9.开启特征值变化
    [self.bridge registerHandler:@"startNotifyCharacteristicValueChange" handler:^(id data, WVJBResponseCallback responseCallback) {

        NSDictionary *diction = (NSDictionary*)data;
        NSDictionary *Dic = @{@"code":@"0",@"errMsg":@"获取特征值成功"};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
        [[BLEBluetoolthManager shareBabyBluetooth] notifyBLECharacteristicValueChange:diction callBack:^(id  _Nonnull notifyCharacteristicResult) {
            NSString *notifyCharacteristicResultdata = notifyCharacteristicResult;
            NSLog(@"notifyBLECharacteristicValueChange =%@",notifyCharacteristicResult);
            [weakSelf.bridge callHandler:@"notifyCharacteristicValueChange" data:notifyCharacteristicResultdata responseCallback:^(id responseData) {}];
        }];
    }];

    //10.断开所有蓝牙连接(关闭蓝牙连接)
    [self.bridge registerHandler:@"disconnect" handler:^(id data, WVJBResponseCallback responseCallback) {

        [[BLEBluetoolthManager shareBabyBluetooth] cancelAllPeripheralsConnection];
    }];

    //11.断开当前蓝牙连接
    [self.bridge registerHandler:@"disCurrentconnect" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *diction = (NSDictionary*)data;
        [[BLEBluetoolthManager shareBabyBluetooth] closeBLEConnection:diction];
        NSDictionary *Dic = @{@"code":@"0",
                             @"errMsg":@""};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
    }];

    //================================
//    //12.打开蓝牙
    [self.bridge registerHandler:@"openBluetooth" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        }
    }];

    //13.关闭蓝牙连接
    [self.bridge registerHandler:@"closeBluetooth" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *diction = (NSDictionary*)data;
        [[BLEBluetoolthManager shareBabyBluetooth] closeBLEConnection:diction];
    }];

    //14.询问蓝牙是否打开
    [self.bridge registerHandler:@"isBluetoothOpened" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[BLEBluetoolthManager shareBabyBluetooth] getBluetoothAdapterState:^(id  _Nonnull resultState) {
            responseCallback(resultState);
        }];
    }];

    //15.存储键值对
    [self.bridge registerHandler:@"putKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *putKeydic = (NSDictionary*)data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:putKeydic forKey:KputKey];
        [ud synchronize];
    }];

    //16.获取存储键值对
    [self.bridge registerHandler:@"getKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"获取存储键值对:%@",data);
        NSString*getKey = data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSDictionary *putKeydic = (NSDictionary*)[ud objectForKey:KputKey];
        responseCallback(putKeydic[getKey]);
    }];

    //17.删除键值对
    [self.bridge registerHandler:@"delKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"删除键值对:%@",data);
        NSString*getKey = data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:getKey];
        [ud synchronize];
        responseCallback(@"");
    }];

   /*暂时不用
    //18.获取系统版本号
    [self.bridge registerHandler:@"getVersionName" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(kAppVersion);
    }];

    //19.检测app版本
    [self.bridge registerHandler:@"checkVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self loadcheckVersionData];
    }];

     //20.
     [self.bridge registerHandler:@"proxyGetRequest" handler:^(id data, WVJBResponseCallback responseCallback) {
         [self loadProxyGetRequestDataHandler:^(NSString *responseData) {
             responseCallback(responseData);
         }];
     }];

     //21.
     [self.bridge registerHandler:@"proxyPostRequest" handler:^(id data, WVJBResponseCallback responseCallback) {
         NSString *datastr = data;
         [self loadProxyPostRequestDataBy:datastr responseCallback:^(NSString *responseData) {
             responseCallback(responseData);
         }];
     }];*/
//-------------------------------------------------------------------------------------------------------------------------------------------
    //1.初始化蓝牙设备。
    [self.bridge registerHandler:@"openBluetoothAdapter" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = data;
        [[HKBabyBluetoothManager shareBabyBluetooth] openBluetoothAdapter:diction];
        NSDictionary *diction1 = @{@"code":@"0",
                                  @"errMsg":@""};
        responseCallback([CSIICheckObject dictionaryChangeJson:diction1]);
    }];
    
    //2,获取本机蓝牙适配器状态(监听蓝牙打开和关闭状态)
    [self.bridge registerHandler:@"registerStateChangeListener" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[HKBabyBluetoothManager shareBabyBluetooth] getBluetoothAdapterState:^(id  _Nonnull resultState) {
            responseCallback(resultState);
        }];
    }];
    
    //3.搜索扫描蓝牙设备
    [self.bridge registerHandler:@"scanLeDevice" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *data_dic = (NSDictionary*)data;
        NSDictionary *diction = @{@"code":@"0",
                                  @"errMsg":@""};
        [[HKBabyBluetoothManager shareBabyBluetooth] cancelAllPeripheralsConnection];
        responseCallback([CSIICheckObject dictionaryChangeJson:diction]);
        //设置扫描到设备的委托
        [[HKBabyBluetoothManager shareBabyBluetooth] onBluetoothDeviceFound:data_dic callBack:^(id  _Nonnull searchResult) {//扫描获取到的外围设备

            [self.bridge callHandler:@"onFoundDevice" data:[CSIICheckObject dictionaryChangeJson:searchResult] responseCallback:^(id responseData) {}];
        }];
    }];
    
    //4.连接蓝牙设备
    [self.bridge registerHandler:@"connect" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *Dic = @{@"code":@"0",@"errMsg":@"",@"connet":@"连接回调"};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
        NSString *dataStr = data;//设备号6FDA7EE6-27C5-6161-D32A-867D6E0E9B1D NSLog(@"设备名称%@",dataStr);
        [[HKBabyBluetoothManager shareBabyBluetooth] cancelAllPeripheralsConnection];
        [[HKBabyBluetoothManager shareBabyBluetooth] createBLEConnection:dataStr callBack:^(id  _Nonnull connectResult) {
            //监听连接状态
            NSLog(@"监听连接状态 = connectResult%@",connectResult);
            [self.bridge callHandler:@"registerConnectStatusListener" data:connectResult responseCallback:^(id responseData) {}];
        }];
    }];
    
    //5.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)
    [self.bridge registerHandler:@"getBLEDeviceServices" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString * dataStr = data;//获取的设备号
        [[HKBabyBluetoothManager shareBabyBluetooth] getBLEDeviceServices:dataStr callBack:^(id  _Nonnull servicesResult) {
            NSDictionary *dic = [self dictionaryWithJsonString:servicesResult];
            NSArray *serverces = dic[@"data"];
            serverces.count > 0 ? responseCallback(servicesResult) : [JYToastUtils showWithStatus:@"获取服务失败"];
        }];
    }];
    
    //6.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)
    [self.bridge registerHandler:@"getBLEDeviceCharacteristics" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = (NSDictionary*)data;
        [[HKBabyBluetoothManager shareBabyBluetooth] getBLEDeviceCharacteristics:diction callBack:^(id  _Nonnull characteristicsResult) {
            responseCallback(characteristicsResult);
        }];
    }];
    
    //7.向蓝牙低功耗设备特征值中写入二进制数据
    [self.bridge registerHandler:@"writeCharacteristic" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = (NSDictionary*)data;
        NSLog(@"向蓝牙低功耗设备特征值中写入二进制数据 ---data =====%@",diction);
        __block int index = 0;// 模拟耗时操作
        // 打印当前线程
        [[HKBabyBluetoothManager shareBabyBluetooth] writeBLECharacteristicValue:diction callBack:^(id  _Nonnull writeValueResult) {
            
            NSDictionary *dic = [self dictionaryWithJsonString:writeValueResult];
            NSString *states = dic[@"data"];
            NSLog(@"writeValueResult =====%@",states);
            //回传写入成功的和失败的状态
            [self.bridge callHandler:@"characterWriteStatusListener" data:states responseCallback:^(id responseData){}];
            if (index ==0) {
                responseCallback(writeValueResult);
                index+=1;
            }
        }];
    }];
    
    //8.开启特征值变化
    [self.bridge registerHandler:@"startNotifyCharacteristicValueChange" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = (NSDictionary*)data;
        NSDictionary *Dic = @{@"code":@"0",@"errMsg":@"开始监听特征"};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
        //订阅特征通知
        [[HKBabyBluetoothManager shareBabyBluetooth] notifyBLECharacteristicValueChange:diction callBack:^(id  _Nonnull notifyCharacteristicResult) {
            NSString *notifyCharacteristicResultdata = notifyCharacteristicResult;
            NSLog(@"notifyBLECharacteristicValueChange =%@",notifyCharacteristicResult);
            [weakSelf.bridge callHandler:@"notifyCharacteristicValueChange" data:notifyCharacteristicResultdata responseCallback:^(id responseData) {}];
        }];
    }];
    
    //9.停止蓝牙搜索(建立连接后需要断开搜索)
    [self.bridge registerHandler:@"stopLeScan" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[HKBabyBluetoothManager shareBabyBluetooth] stopBluetoothDevicesDiscovery];
    }];
    
    //10.断开所有蓝牙连接(关闭蓝牙连接)
    [self.bridge registerHandler:@"disconnect" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[HKBabyBluetoothManager shareBabyBluetooth] cancelAllPeripheralsConnection];
    }];
    
    //11.断开当前蓝牙连接
    [self.bridge registerHandler:@"disCurrentconnect" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *diction = (NSDictionary*)data;
        [[HKBabyBluetoothManager shareBabyBluetooth] closeBLEConnection:diction];
        NSDictionary *Dic = @{@"code":@"0",
                             @"errMsg":@""};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
    }];
    
    //================================
//    //12.打开蓝牙
    [self.bridge registerHandler:@"openBluetooth" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        }
    }];

    //13.关闭蓝牙连接
    [self.bridge registerHandler:@"closeBluetooth" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSURL *url = [NSURL URLWithString:@"App-Prefs:root=Bluetooth"];
        if ([[UIApplication sharedApplication]canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:nil];
        }
    }];

    //14.询问蓝牙是否打开
    [self.bridge registerHandler:@"isBluetoothOpened" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[HKBabyBluetoothManager shareBabyBluetooth] getBluetoothAdapterState:^(id  _Nonnull resultState) {
            responseCallback(resultState);
        }];
    }];
    
    //15.存储键值对
    [self.bridge registerHandler:@"putKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *putKeydic = (NSDictionary*)data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:putKeydic forKey:KputKey];
        [ud synchronize];
    }];
    
    //16.获取存储键值对
    [self.bridge registerHandler:@"getKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"获取存储键值对:%@",data);
        NSString*getKey = data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSDictionary *putKeydic = (NSDictionary*)[ud objectForKey:KputKey];
        responseCallback(putKeydic[getKey]);
    }];
    
    //17.删除键值对
    [self.bridge registerHandler:@"delKey" handler:^(id data, WVJBResponseCallback responseCallback) {
        NSLog(@"删除键值对:%@",data);
        NSString*getKey = data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud removeObjectForKey:getKey];
        [ud synchronize];
        responseCallback(@"");
    }];
    
   /*暂时不用
    //18.获取系统版本号
    [self.bridge registerHandler:@"getVersionName" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(kAppVersion);
    }];
    
    //19.检测app版本
    [self.bridge registerHandler:@"checkVersion" handler:^(id data, WVJBResponseCallback responseCallback) {
        [self loadcheckVersionData];
    }];  */

     //20.
     [self.bridge registerHandler:@"proxyGetRequest" handler:^(id data, WVJBResponseCallback responseCallback) {
         [self loadProxyGetRequestDataHandler:^(NSString *responseData) {
             responseCallback(responseData);
         }];
     }];
     
     //21.
     [self.bridge registerHandler:@"proxyPostRequest" handler:^(id data, WVJBResponseCallback responseCallback) {
         NSString *datastr = data;
         [self loadProxyPostRequestDataBy:datastr responseCallback:^(NSString *responseData) {
             responseCallback(responseData);
         }];
     }];
  
}
#pragma mark - 全局 jsbridge
- (void)setBridgeAction{
    // 跳包
    [self toZipPage];
    // 刷新指定模块
    [self refreshPage];
    //设置标题
    [self setTitle];
    // 显示或隐藏导航栏
    [self showOrHideNav];
    // 右上角按钮
    [self setRightNav];
    // 获取一些常用信息
    [self getBaseInfo];
    // 关掉webview
    [self closePage];
    // 回到首页
    [self toMain];
    // 拨打电话号码
    [self callPhone];
    // 系统分享，保存Pdf
    [self savePdf];
    //系统下载并分享图片
    [self downloadImage];
    // 获取路由和参数
    [self getToPageUrl];
    // 复制内容到剪切板
    [self copyToClipboard];
    // 存储删数据
    [self setStorageData];
    // 系统相机相册
    [self getSystemCameraAlbum];
    // 时间选择器
    [self selectDate];
    // 普通选择器
    [self ItemsPickView];
    // 返回
    [self setGoBack];
    //请求
    [self request];
    //蓝牙
    [self setBluetooth];
}

#pragma mark - Public Method -- 公开方法
-(void)bridgeForWebView:(WKWebView*)webView{
    [WKWebViewJavascriptBridge enableLogging];
    self.wkWebView = webView;
    self.bridge = [CSIIWKHybridBridge bridgeForWebView:webView];
    [self setBridgeAction];
}

#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式


#pragma mark ---设置蓝牙接口

#pragma mark 点击了右上角按钮
- (void)rightAction:(UIButton *)btn {
    NSInteger index = btn.tag -10000;
    NSDictionary *dic = @{@"index":@(index)};
    [self.bridge callHandler:@"rightNavJump" data:[CSIICheckObject dictionaryChangeJson:dic] responseCallback:^(id responseData) {
    }];
}

- (void)loadcheckVersionData{
    //MBProgressHUD *hud = [[MBProgressHUD alloc] init];
    [[reachabilityManager manager]monitoringNetWork:^(bool result) {
        NSLog(@"result = %d",result);
        if (result) {
            [[LQAFNetworkManager manager] requestPostWithUrl:nil params:nil success:^(id response) {
                NSDictionary *data = (NSDictionary*)response[@"data"];
                //NSString *arrayAppStore = data[@"versionNumber"];
                NSString *versionLocal= kAppVersion;
                NSString *versionAppStore = data[@"versionName"];
                NSArray  *arrayAppStore = [versionAppStore componentsSeparatedByString:@"."];
                NSArray *arrayLocal = [versionLocal componentsSeparatedByString:@"."];
                NSInteger shortCount = arrayAppStore.count<arrayLocal.count?arrayAppStore.count:arrayLocal.count;
                
                for (NSInteger i = 0; i < shortCount; i++) {
                    if ([arrayAppStore[i] integerValue] > [arrayLocal[i] integerValue]) {
                        // App Store版本高，需要升级
                    }
                }
                // 在相同位数下没有得到结果，那么位数多的版本高
                if (arrayAppStore.count > arrayLocal.count) {
                    //需要升级
                }
            } failure:^(NSError *error) {
                NSLog(@"error = %@",error);
            }];
        }else{
            //[hud hideAnimated:YES];
        }
    }];
}

@end
