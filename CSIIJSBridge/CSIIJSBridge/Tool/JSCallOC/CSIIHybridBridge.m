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
#import "reachabilityManager.h"
#import "LQAFNetworkManager.h"
#import "JYToastUtils.h"
#import <objc/runtime.h>
#import "XFBleBlueManger.h"

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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notifyValue:) name:@"didUpdateValueForCharacteristic" object:nil];
    
    //1.初始化蓝牙设备。
    [self.bridge registerHandler:@"openBluetoothAdapter" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[XFBleBlueManger shareBlueManager]initBle];
        NSDictionary *diction1 = @{@"code":@"0",
                                  @"errMsg":@""};
        responseCallback([CSIICheckObject dictionaryChangeJson:diction1]);
    }];
    
    //2,获取本机蓝牙适配器状态(监听蓝牙打开和关闭状态)
    [self.bridge registerHandler:@"registerStateChangeListener" handler:^(id data, WVJBResponseCallback responseCallback) {
    
        [[XFBleBlueManger shareBlueManager]getBleSate:^(id  _Nonnull resultState) {
            responseCallback(resultState);
        }];
    }];
    
    //3.搜索扫描蓝牙设备
    [self.bridge registerHandler:@"scanLeDevice" handler:^(id data, WVJBResponseCallback responseCallback) {
    
        NSDictionary *diction = @{@"code":@"0",
                                  @"errMsg":@""};
        responseCallback([CSIICheckObject dictionaryChangeJson:diction]);
        
        //设置扫描到设备的委托
        [[XFBleBlueManger shareBlueManager] stopPeripheral];
        [[XFBleBlueManger shareBlueManager] scanDeviceCallBack:^(id  _Nonnull searchResult) {
            [self.bridge callHandler:@"onFoundDevice" data:[CSIICheckObject dictionaryChangeJson:searchResult]];
        }];
    }];
    
    //4.停止蓝牙搜索(建立连接后需要断开搜索)
    [self.bridge registerHandler:@"stopLeScan" handler:^(id data, WVJBResponseCallback responseCallback) {
    
        [[XFBleBlueManger shareBlueManager]stopScan];
    }];
    
    //5.连接蓝牙设备
    [self.bridge registerHandler:@"connect" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSString *dataStr = data;//设备号6FDA7EE6-27C5-6161-D32A-867D6E0E9B1D NSLog(@"设备名称%@",dataStr);
        [[XFBleBlueManger shareBlueManager]connectionBleName:dataStr connectResult:^(id  _Nonnull connectResult) {
            [self.bridge callHandler:@"registerConnectStatusListener" data:connectResult];
        }];
    }];
    
    //6.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)
    [self.bridge registerHandler:@"getBLEDeviceServices" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[XFBleBlueManger shareBlueManager]getBLEDeviceServices:data callBack:^(id  _Nonnull servicesResult) {

            NSDictionary *dic = [self dictionaryWithJsonString:servicesResult];
            NSArray *serverces = dic[@"data"];
            if (serverces.count > 0) {
                responseCallback(servicesResult);
            }else{
                [JYToastUtils showWithStatus:@"获取服务失败"];
            }
        }];
        
    }];
    
    //7.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)
    [self.bridge registerHandler:@"getBLEDeviceCharacteristics" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = (NSDictionary*)data;
        [[XFBleBlueManger shareBlueManager] getBLEDeviceCharacteristics:diction callBack:^(id  _Nonnull characteristicsResult) {
            responseCallback(characteristicsResult);
        }];
    }];
    
    //8.向蓝牙低功耗设备特征值中写入二进制数据
    [self.bridge registerHandler:@"writeCharacteristic" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = (NSDictionary*)data;
        [[XFBleBlueManger shareBlueManager]writeBLECharacteristicValue:diction callBack:^(id  _Nonnull writeValueResult) {
            [self.bridge callHandler:@"characterWriteStatusListener" data:writeValueResult];
        }];
    }];
    
    //9.开启特征值变化
    [self.bridge registerHandler:@"startNotifyCharacteristicValueChange" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        NSDictionary *diction = (NSDictionary*)data;
        [[XFBleBlueManger shareBlueManager]getnotifyBLECharacteristicValueChange:diction callBack:^(id  _Nonnull characteristicsResult) {
            [self.bridge callHandler:@"notifyCharacteristicValueChange" data:characteristicsResult];
        }];
        NSDictionary *Dic = @{@"code":@"0",@"errMsg":@"开始监听特征"};
        responseCallback([CSIICheckObject dictionaryChangeJson:Dic]);
    }];
    
    //10.断开所有蓝牙连接(关闭蓝牙连接)
    [self.bridge registerHandler:@"disconnect" handler:^(id data, WVJBResponseCallback responseCallback) {
        
        [[XFBleBlueManger shareBlueManager]stopPeripheral];
    }];
    
    //11.断开当前蓝牙连接
    [self.bridge registerHandler:@"disCurrentconnect" handler:^(id data, WVJBResponseCallback responseCallback) {

        [[XFBleBlueManger shareBlueManager]stopPeripheral];
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
        [[XFBleBlueManger shareBlueManager]stopPeripheral];
    }];

    //14.询问蓝牙是否打开
    [self.bridge registerHandler:@"isBluetoothOpened" handler:^(id data, WVJBResponseCallback responseCallback) {
        [[XFBleBlueManger shareBlueManager]getBleSate:^(id  _Nonnull resultState) {
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
        NSLog(@"key:%@",data);
        NSString*getKey = data;
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSDictionary *putKeydic = (NSDictionary*)[ud objectForKey:KputKey];
        NSLog(@"获取的储键值对:%@",putKeydic);
        if([putKeydic isKindOfClass:[NSDictionary class]]){
            responseCallback(putKeydic);
        }
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

//监听到特征值的改变
- (void)notifyValue:(NSNotification *)notification {
    [self.bridge callHandler:@"notifyCharacteristicValueChange" data:notification.object];
}

#pragma mark - 全局 jsbridge
- (void)setBridgeAction{
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
