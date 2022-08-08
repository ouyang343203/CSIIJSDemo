//
//  BLEBluetoolthManager.m
//  BallMachine
//
//  Created by 李佛军 on 2022/1/19.
#import "BLEBluetoolthManager.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "BabyBluetooth.h"
#import "TypeConversion.h"
#import "BluetoothManager.h"
//#import "CSIIHybridBridge.h"
//#import "CSIIWKHybridBridge.h"
#import "CSIICheckObject.h"
@interface BLEBluetoolthManager()
@property (nonatomic, copy)  BluetoothStateCallback stateCallBack;//蓝牙状态回调
@property (nonatomic, copy)  BluetoothSearchResultCallback searchResultcallBack;//获取到蓝牙的回调
@property (nonatomic, copy)  BluetoothBLEConnectCallback contentCallBack;//连接蓝牙后的结果
@property (nonatomic, copy)  BluetoothWriteBLECallback wiriteBLECallBlack;//数据写入
@property (nonatomic, copy)  BluetoothNotifyCharacteristicCallBlock characteristicCallBack;//订阅特性改变的通知
@property (nonatomic, copy)  BluetoothConnectStatusCallBlock connectStatusCallBack;//连接状态的变化
@property (nonatomic, copy)  BluetoothWriteStatusCallBlock  writeStatusCallBlock;//监听特征值写入状态
//@property (nonatomic,assign) BOOL iscontent;//是否已连接
//@property (nonatomic,assign) BOOL isGetServeceUUID;//是否已经获取服务UUID
@property (nonatomic,strong) BabyBluetooth *centerManager;
@property (nonatomic,strong) CBPeripheral *currPeripheral;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@property (nonatomic,strong) NSMutableDictionary *deviceDic;//搜索到的所有设备
@property (nonatomic,strong) NSMutableArray *serverceArray;//设备的所有服务
@property (nonatomic,strong) NSMutableArray *characteristicArray;//设备的所有特性

@end
@implementation BLEBluetoolthManager
//单例模式
+ (instancetype)shareBabyBluetooth {
    static BLEBluetoolthManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BLEBluetoolthManager alloc]init];
    });
    return manager;
}
#pragma mark --------1.初始化蓝牙模块----------
//1.初始化蓝牙模块
-(void)openBluetoothAdapter:(NSDictionary*)parameter
{
    self.centerManager = [BabyBluetooth shareBabyBluetooth];
   [self.centerManager cancelAllPeripheralsConnection];
}
#pragma mark ----------2.获取蓝牙状态------------
//2.获取蓝牙状态（是否开启或者关闭）
-(void)getBluetoothAdapterState:(BluetoothStateCallback)stateCallBack
{
    [self centralManagerStateDelegate];
    [[BluetoothManager manager]initBluetooth:^(id  _Nonnull resultState) {
        stateCallBack(resultState);
    }];
    
}
#pragma mark ----------3.搜索蓝牙设备------------
//3.搜索蓝牙设备
-(void)onBluetoothDeviceFound:(NSDictionary*)parameter callBack:(BluetoothSearchResultCallback)searchResultcallBack
{
    if (self.centerManager) {
        self.centerManager.scanForPeripherals().begin();
    }
    self.searchResultcallBack = searchResultcallBack;
    [self setScanForPeripherals];
}
#pragma mark ----------4.连接指定蓝牙设备------------
-(void)createBLEConnection:(NSDictionary*)parameter callBack:(BluetoothBLEConnectCallback)ConnectCallback
{
    self.contentCallBack = ConnectCallback;
    
    NSDictionary *diction = (NSDictionary*)parameter;
   
    NSString *identifier = diction[@"address"];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    if (peripheral) {
        self.centerManager.scanForPeripherals().connectToPeripherals().begin();
        [self didConnectPeripheral];
    }else{
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10013",@"errMsg":@"连接 address 为空或者是格式不正确"}];
        ConnectCallback(data);
    }
}
#pragma mark -------5.数据写入--------------
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter callBack:(BluetoothWriteBLECallback)writeCallBack
{
    self.wiriteBLECallBlack = writeCallBack;
    NSString *dataStr = parameter[@"data"];
    NSString *address = parameter[@"address"];
    NSString *serviceId = parameter[@"serviceId"];
    NSString *characteristicId  = parameter[@"characteristicId"];
    CBPeripheral * peripheral = [_deviceDic objectForKey:address];
    NSString *data_10002 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10002",@"errMsg":@"没有找到指定设备"}];
    if (peripheral == nil) {writeCallBack(data_10002); return;}
    NSArray<CBService*>*newServices = peripheral.services;
    NSString *data_10004 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到指定服务"}];
    if (newServices.count == 0){writeCallBack(data_10004); return;}
    CBService *findService = nil;
    CBCharacteristic *findCharcteritic = nil;
    for (CBService *service in newServices)
    {
        if ([service.UUID.UUIDString isEqualToString:serviceId])
        {
            findService = service;
            [peripheral discoverCharacteristics:NULL forService:service];
            NSArray <CBCharacteristic*> *newCharcteritic  = service.characteristics;
            NSString *data_10005 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}];
            if (newCharcteritic.count == 0) {writeCallBack(data_10005); return;}
            for (CBCharacteristic *charcteritic in service.characteristics)
            {
                if ([[[charcteritic UUID] UUIDString] isEqualToString:characteristicId])
                {
                    findCharcteritic = charcteritic;
                    [peripheral discoverDescriptorsForCharacteristic:charcteritic];
                }
            }
        }
    }
    if (findService && findCharcteritic) {
        [peripheral writeValue: [TypeConversion hexString:dataStr] forCharacteristic:findCharcteritic type:CBCharacteristicWriteWithResponse];
    }

}
//6.停止搜索蓝牙
-(void)stopBluetoothDevicesDiscovery
{
    [self.centerManager cancelScan];
}
//7.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)
-(void)getBLEDeviceServices:(NSDictionary*)parameter callBack:(BluetoothServicesCallback)serviceCallBack
{
    NSMutableArray *serverces = [NSMutableArray array];
    NSString *identifier = parameter[@"address"];
    NSString *data_10002 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10002",@"errMsg":@"没有找到指定设备"}];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    if (peripheral == nil){serviceCallBack(data_10002); return;}
      NSArray<CBService*>*newServices = peripheral.services;
    NSString *data_10004 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到服务"}];
    if (newServices.count == 0){serviceCallBack(data_10004); return;}
    for (CBService *service in newServices) {
        NSMutableDictionary *serverceDic = [NSMutableDictionary dictionary];
        [serverceDic setValue:service.UUID.UUIDString forKey:@"uuid"];
        [serverceDic setValue:@(service.isPrimary) forKey:@"isPrimary"];
        [serverces addObject:serverceDic];
    }
    NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":serverces}];
    serviceCallBack(data);
}
//8.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter callBack:(BluetoothCharacteristicsCallback)characteristics
{
    NSString *identifier = parameter[@"mac"];
    NSString *serviceId = parameter[@"serviceUuid"];
    NSMutableArray *charcterArray = [NSMutableArray array];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    
    if (peripheral == nil){
        
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10002",@"errMsg":@"没有找到指定设备"}];
        characteristics(data); return;
    
    }
    NSArray<CBService*>*newServices = peripheral.services;
    if (newServices.count == 0){
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到指定服务"}];
        characteristics(data); return;
    }
    for (CBService *service in newServices) {
        if ([service.UUID.UUIDString isEqualToString:serviceId]) {
            NSArray <CBCharacteristic*> *newCharcteritic  = service.characteristics;
            if (newCharcteritic.count == 0) {
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}];
                characteristics(data); return;
            }
            for (CBCharacteristic *charcteritic in service.characteristics) {
                NSMutableDictionary *charcteriticDic = [NSMutableDictionary dictionary];
                [charcteriticDic setValue:charcteritic.UUID.UUIDString forKey:@"uuid"];
                
                [charcteriticDic setValue:@(0) forKey:@"read"];
                [charcteriticDic setValue:@(0) forKey:@"notify"];
               [charcteriticDic setValue:@(0) forKey:@"indicate"];
                       [charcteriticDic setValue:@(1) forKey:@"write"];
                       [charcterArray addObject:charcteriticDic];
            }
        }else{
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到指定服务"}];
            characteristics(data); return;
        }
    }
    NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@{@"status":@"0",@"data":charcterArray}}];
    characteristics(data);
}
#pragma mark ----------9.订阅特性的通知-----------
-(void)notifyBLECharacteristicValueChange:(NSDictionary*)parameter callBack:(BluetoothNotifyCharacteristicCallBlock)characteristicCallBack
{
    self.characteristicCallBack = characteristicCallBack;
    NSString *identifier = parameter[@"address"];
    NSString *serviceId = parameter[@"serviceId"];
    NSString *characteristicId = parameter[@"characteristicId"];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    if (peripheral == nil){
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10002",@"errMsg":@"没有找到指定设备"}];
        characteristicCallBack(data); return;
    }
    NSArray<CBService*>*newServices = peripheral.services;
    if (newServices.count == 0){
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到指定服务"}];
        characteristicCallBack(data); return;
        
    }
    for (CBService *service in newServices) {
        if (![service.UUID.UUIDString isEqualToString:serviceId]) {
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到指定服务"}];
            characteristicCallBack(data); return;
        }
        NSArray <CBCharacteristic*> *newCharcteritic  = service.characteristics;
        if (newCharcteritic.count == 0) {
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}];
            characteristicCallBack(data); return;
            
        }
        for (CBCharacteristic *charcteritic in newCharcteritic) {
            if (![charcteritic.UUID.UUIDString isEqualToString:characteristicId]) {
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}];

                characteristicCallBack(data);
                
                return;
            }
            [self.centerManager notify:peripheral characteristic:charcteritic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@""}];
                characteristicCallBack(data);
            }];
        }
    }
  
}
#pragma mark --------10-断开所有连接----------
-(void)cancelAllPeripheralsConnection
{
    [self.centerManager cancelScan];
    [self.centerManager cancelAllPeripheralsConnection];
}
#pragma mark ----------11.断开蓝牙连接--------
-(void)closeBLEConnection:(NSDictionary*)parameter
{
    [self.centerManager cancelScan];
    NSString *identifier = parameter[@"address"];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    [self.centerManager cancelPeripheralConnection:peripheral];
}
//12.监听连接状态值的变化
-(void)registerConnectStatusListener:(BluetoothConnectStatusCallBlock)connectStatusCallBack
{
    self.connectStatusCallBack = connectStatusCallBack;
    
}
-(void)characterWriteStatusListener:(NSDictionary*)parameter callBack:(BluetoothWriteStatusCallBlock)WriteStatusCallBlock
{
    self.writeStatusCallBlock = WriteStatusCallBlock;
}
#pragma mark --------------1.1监听蓝牙的状态蓝牙状态代理-------------
-(void)centralManagerStateDelegate
{
//    __weak typeof(self) weakSelf = self;
    [self.centerManager setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {

        NSString *data = nil;
        switch (central.state) {
            case CBCentralManagerStateUnknown:
                 data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0004",@"errMsg":@"状态未知",@"data":@(false)}];
              break;
            case CBCentralManagerStateResetting:
                data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0005",@"errMsg":@"蓝牙断开即将重置",@"data":@(false)}];
              break;
            case CBCentralManagerStateUnsupported:
                data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0002",@"errMsg":@"蓝牙未启",@"data":@(false)}];
              break;
            case CBCentralManagerStateUnauthorized:
                data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0003",@"errMsg":@"蓝牙未被授权",@"data":@(false)}];
              break;
            case CBCentralManagerStatePoweredOff:
                data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0001",@"errMsg":@"蓝牙未启",@"data":@(false)}];
              break;
            case CBCentralManagerStatePoweredOn:
                data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@(true)}];
              break;
            default:
              break;
          }
        //可以调用H5返回给H5
//        weakSelf.stateCallBack(data);
    }];
    
}
#pragma mark -------2.1-设置搜索蓝牙代理--------
-(void)setScanForPeripherals
{
//    id bridBridge = [CSIIHybridBridge shareManager].bridge;
//      bridBridge = (CSIIWKHybridBridge*)bridBridge;
    __weak typeof(self) weakSelf = self;
    [self.centerManager setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        if (![weakSelf.deviceDic objectForKey:[peripheral name]]&&peripheral!=nil&&peripheral.name!=nil) {
            [weakSelf.deviceDic setObject:peripheral forKey:[[peripheral identifier] UUIDString]];
            
            NSDictionary *data = @{@"code":@"0",
                                   @"errMsg":@"",
                                   @"address":peripheral.identifier.UUIDString,
                                   @"name":peripheral.name,
                                   @"rssi":@(RSSI.intValue)
            };
            weakSelf.searchResultcallBack([CSIICheckObject dictionaryChangeJson:data]);
//            [bridBridge callHandler:@"onFoundDevice" data:data responseCallback:^(id responseData) {
//
//                NSLog(@"titile点击事件");
//            }];
            
                    }
    }];
}
#pragma mark -----连接成功和失败回调---------
-(void)didConnectPeripheral
{
    __weak typeof(self) weakSelf = self;
//    id bridBridge = [CSIIHybridBridge shareManager].bridge;
//      bridBridge = (CSIIWKHybridBridge*)bridBridge;
    //连接成功回调
    [self.centerManager setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {

        NSLog(@"设备：%@--连接成功",peripheral.name);
 
        weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                                   @"errMsg":@"",
                                   @"data":@(true)
                                 }]);//连接成功
        [peripheral discoverServices:nil];
        //停止扫描
        [weakSelf.centerManager  cancelScan];
        if (weakSelf.connectStatusCallBack) {
            weakSelf.connectStatusCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@(true)}]);
        }
    }];
    //设置设备连接失败的委托
    [self.centerManager setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10003",@"errMsg":@"连接失败"}];
        
        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack(data);
        }
        NSLog(@"设备：%@--连接失败",peripheral.name);
        if (weakSelf.connectStatusCallBack) {
            weakSelf.connectStatusCallBack(data);
        }
//        [bridBridge callHandler:@"registerConnectStatusListener" data:data responseCallback:^(id responseData) {
//
//            NSLog(@"设备断开连接");
//        }];
//        weakSelf.iscontent = NO;
    }];
    
    //设备断开连接
    [self.centerManager setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        weakSelf.iscontent = NO;
        
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10006",@"errMsg":@"当前连接已断开"}];
//        [bridBridge callHandler:@"registerConnectStatusListener" data:data responseCallback:^(id responseData) {
//
//            NSLog(@"设备断开连接");
//        }];
        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack(data);
        }
       
        if (weakSelf.wiriteBLECallBlack) {
            weakSelf.wiriteBLECallBlack(data);
        }
        if (weakSelf.connectStatusCallBack) {
            weakSelf.connectStatusCallBack(data);
        }
        NSLog(@"设备：%@--断开连接",peripheral.name);
    }];
    [self.centerManager setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        
        if (peripheral.services.count> 0) {
            // 遍历服务
            [weakSelf.serverceArray addObjectsFromArray:peripheral.services];//保存服务ID的对象
        }else{
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到指定服务"}]);
        }

    }];
    // //设置发现设service的Characteristics的委托
    [self.centerManager setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if (service.characteristics.count> 0) {
            [weakSelf.characteristicArray addObjectsFromArray:service.characteristics];
        }else{
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}]);
        }

    }];
    //设置发现characteristics的descriptors的委托
       [self.centerManager setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
           NSLog(@"===characteristic name:%@",characteristic.service.UUID);
           for (CBDescriptor *d in characteristic.descriptors) {
               NSLog(@"CBDescriptor name is :%@",d.UUID);
           }
       }];
       
       //设置读取Descriptor的委托
       [self.centerManager setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
           NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
       }];
     //写入特征值成功
    [self.centerManager setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (error)
        {
          NSLog(@"Discovered services for %@ with error: %@", characteristic.UUID.UUIDString, [error localizedDescription]);
          return;
        }else{
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                                   @"errMsg":@"",
                                   @"data":@(true)}];
//            [bridBridge callHandler:@"characterWriteStatusListener" data:data responseCallback:^(id responseData) {
//
//                NSLog(@"写入状态成功");
//            }];
           
            if (weakSelf.wiriteBLECallBlack) {
                weakSelf.wiriteBLECallBlack(data);
            }
            if (weakSelf.writeStatusCallBlock) {
                weakSelf.writeStatusCallBlock(data);
            }
          
        }
    }];
    //订阅特征值变化的通知
    [self.centerManager setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"征值变化的通知");
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":characteristic.value}];
//        [bridBridge callHandler:@"characterWriteStatusListener" data:data responseCallback:^(id responseData) {
//            
//            NSLog(@"写入状态成功");
//        }];
        if (weakSelf.characteristicCallBack) {
            weakSelf.characteristicCallBack(data);
        }
    }];
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    //连接设备->
    [self.centerManager setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
 
    //设置连接的设备的过滤器
     __block BOOL isFirst = YES;
    [self.centerManager setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
       NSString *pheralName = advertisementData[@"kCBAdvDataLocalName"];
        if (isFirst&& [peripheralName isEqualToString:pheralName]) {
            isFirst = NO;
            return YES;
        };
        return NO;
    }];
}
-(NSMutableDictionary*)deviceDic
{
    if (_deviceDic == nil) {
        _deviceDic = [NSMutableDictionary dictionary];
    }
    return _deviceDic;
}
-(NSMutableArray*)serverceArray
{
    if (_serverceArray == nil) {
        _serverceArray = [NSMutableArray array];
    }
    return _serverceArray;
}
-(NSMutableArray*)characteristicArray
{
    if (_characteristicArray == nil) {
        _characteristicArray = [NSMutableArray array];
    }
    return _characteristicArray;
}
@end
