//
//  BluetoothManager.m
//  CSIIJSBridge
//
//  Created by 李佛军 on 2022/1/4.
//

#import "BluetoothManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <CommonCrypto/CommonCryptor.h>
#import "CSIICheckObject.h"
@interface BluetoothManager()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centerManager;
@property (nonatomic, strong)id<BluetoothDelegate>delegate;//设置蓝牙
@property (nonatomic, copy) BluetoothStateCallback stateCallBack;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic,strong) NSMutableDictionary *deviceDic;

@end
@implementation BluetoothManager
+ (instancetype)manager {
    static BluetoothManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BluetoothManager alloc]init];
        
    });
    return manager;
}
//1.初始化蓝牙功能
-(void)initBluetooth:(BluetoothStateCallback)state {
    _centerManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue() options:nil];
    _deviceDic = [NSMutableDictionary dictionary];
    self.stateCallBack = state;
}

//只要中心管理者初始化 就会触发此代理方法 判断手机蓝牙状态
-(void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateUnknown:
          NSLog(@"CBCentralManagerStateUnknown");
            self.stateCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0004",@"errMsg":@"状态未知",@"data":@(false)}]);
          break;
        case CBCentralManagerStateResetting:
          NSLog(@"CBCentralManagerStateResetting");
            self.stateCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0005",@"errMsg":@"蓝牙断开即将重置",@"data":@(false)}]);
          break;
        case CBCentralManagerStateUnsupported:
          NSLog(@"CBCentralManagerStateUnsupported");//不支持蓝牙
            self.stateCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0002",@"errMsg":@"蓝牙未启",@"data":@(false)}]);
          break;
        case CBCentralManagerStateUnauthorized:
          NSLog(@"CBCentralManagerStateUnauthorized");
            self.stateCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0003",@"errMsg":@"蓝牙未被授权",@"data":@(false)}]);
          break;
        case CBCentralManagerStatePoweredOff:
        {
          NSLog(@"CBCentralManagerStatePoweredOff");//蓝牙未开启
            self.stateCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0001",@"errMsg":@"蓝牙未启",@"data":@(false)}]);
        }
          break;
        case CBCentralManagerStatePoweredOn:
        {
          NSLog(@"CBCentralManagerStatePoweredOn");//蓝牙已开启
            self.stateCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@(true)}]);
        }
          break;
        default:
          break;
      }
}
@end
