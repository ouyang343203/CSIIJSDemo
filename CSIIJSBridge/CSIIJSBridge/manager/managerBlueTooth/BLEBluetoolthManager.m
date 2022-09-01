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
#import "CSIIHybridBridge.h"
#import "CSIIWKHybridBridge.h"
#import "CSIICheckObject.h"
#import <AudioToolbox/AudioToolbox.h>

#define channelOnPeropheralView @"peripheralView"
#define channelOnCharacteristicView @"CharacteristicView"

@interface BLEBluetoolthManager()
@property (nonatomic, copy)  BluetoothStateCallback stateCallBack;//蓝牙状态回调
@property (nonatomic, copy)  BluetoothSearchResultCallback searchResultcallBack;//获取到蓝牙的回调
@property (nonatomic, copy)  BluetoothBLEConnectCallback contentCallBack;//连接蓝牙后的结果
@property (nonatomic, copy)  BluetoothWriteBLECallback wiriteBLECallBlack;//数据写入
@property (nonatomic, copy)  BluetoothNotifyCharacteristicCallBlock characteristicCallBack;//订阅特性改变的通知
@property (nonatomic, copy)  BluetoothConnectStatusCallBlock connectStatusCallBack;//连接状态的变化
@property (nonatomic, copy)  BluetoothWriteStatusCallBlock  writeStatusCallBlock;//监听特征值写入状态
@property (nonatomic,strong) BabyBluetooth *centerManager;
@property (nonatomic,strong) CBCharacteristic *characteristic;
@property (nonatomic,strong) NSMutableDictionary *deviceDic;//搜索到的所有设备
@property (nonatomic,strong) NSMutableArray *serverceArray;//设备的所有服务
@property (nonatomic,strong) NSMutableArray *characteristicArray;//设备的所有特性
@property (nonatomic,strong) NSString *serviceID;
@property (nonatomic,strong) NSBlockOperation *operation;
@property (nonatomic,strong) NSMutableArray *peripheralDataArray;

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
//1.初始化BabyBluetooth 蓝牙库蓝牙模块
-(void)openBluetoothAdapter:(NSDictionary*)parameter {
   self.centerManager = [BabyBluetooth shareBabyBluetooth];
   [self.centerManager cancelAllPeripheralsConnection];
}

#pragma mark ----------2.获取蓝牙状态------------
//2.获取蓝牙状态（是否开启或者关闭）
-(void)getBluetoothAdapterState:(BluetoothStateCallback)stateCallBack {
    [self centralManagerStateDelegate];
    //初始化蓝牙中心
    [[BluetoothManager manager]initBluetooth:^(id  _Nonnull resultState) {
        stateCallBack(resultState);
    }];
}

#pragma mark ----------3.搜索蓝牙设备------------c
//3.搜索蓝牙设备
-(void)onBluetoothDeviceFound:(NSDictionary*)parameter callBack:(BluetoothSearchResultCallback)searchResultcallBack {
    if (self.centerManager) {
        self.centerManager.scanForPeripherals().begin(30);
    }
    self.searchResultcallBack = searchResultcallBack;
    [self setScanForPeripherals];//设置扫描到设备的委托
}

#pragma mark ----------4.连接指定蓝牙设备------------
-(void)createBLEConnection:(NSString*)parameter callBack:(BluetoothBLEConnectCallback)ConnectCallback {
    self.contentCallBack = ConnectCallback;
    self.serviceID = parameter;
    CBPeripheral * peripheral = (CBPeripheral*)[self.deviceDic objectForKey:parameter];
    NSLog(@"UUIDString:%@",peripheral.identifier.UUIDString);
    if ([parameter isEqualToString:peripheral.identifier.UUIDString]&&peripheral!=nil ) {
        self.centerManager.scanForPeripherals().connectToPeripherals().begin();
        [self didConnectPeripheral];
    }else{
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10030",@"errMsg":@"连接 address 为空或者是格式不正确"}];
        ConnectCallback(data);
    }
}

#pragma mark -------5.数据写入--------------
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter callBack:(BluetoothWriteBLECallback)writeCallBack {
    self.wiriteBLECallBlack = writeCallBack;
    NSString *dataStr = parameter[@"data"];
    NSString *address = parameter[@"mac"];
    NSString *serviceId = parameter[@"serviceUuid"];
    NSString *characteristicId  = parameter[@"characteristicUuid"];
    CBPeripheral *peripheral = [_deviceDic objectForKey:address];
    NSString *data_10002 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10002",@"errMsg":@"没有找到指定设备"}];
    if (peripheral == nil) {writeCallBack(data_10002); return;}
    NSArray<CBService*>*newServices = peripheral.services;
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
        dispatch_async(dispatch_get_main_queue(), ^{
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [peripheral writeValue: [TypeConversion hexString:dataStr] forCharacteristic:findCharcteritic type:CBCharacteristicWriteWithResponse];
                });
             
            });
            
        });
    }
}

//6.停止搜索蓝牙
-(void)stopBluetoothDevicesDiscovery {
    [self.centerManager cancelScan];
}

//7.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)
-(void)getBLEDeviceServices:(NSString*)parameter callBack:(BluetoothServicesCallback)serviceCallBack {
    NSMutableArray *serverces = [NSMutableArray array];
    NSMutableDictionary *serverceDic = [NSMutableDictionary dictionary];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:parameter];
    NSArray<CBService*>*newServices = peripheral.services;
    for (CBService *service in newServices) {
        [serverceDic setValue:service.UUID.UUIDString forKey:@"uuid"];
        [serverceDic setValue:@(service.isPrimary) forKey:@"type"];
        [serverces addObject:serverceDic];
        [peripheral discoverCharacteristics:NULL forService:service];
    }
    NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":serverces.count > 0 ? @"":@"获取服务失败",@"data":serverces}];
    NSLog(@"======获取的所有服务%@",data);
    serviceCallBack(data);
}

//8.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter callBack:(BluetoothCharacteristicsCallback)characteristics {
    NSString *identifier = parameter[@"mac"];
    NSString *serviceId = parameter[@"serviceUuid"];
    NSMutableArray *charcterArray = [NSMutableArray array];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    NSArray<CBService*>*newServices = peripheral.services;
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
                [charcterArray addObject:charcteriticDic];
            }
        }else{
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到服务"}];
            characteristics(data); return;
        }
    }
    NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":charcterArray}];
    characteristics(data);
}

#pragma mark ----------9.订阅特性的通知-----------
-(void)notifyBLECharacteristicValueChange:(NSDictionary*)parameter callBack:(BluetoothNotifyCharacteristicCallBlock)characteristicCallBack {
    self.characteristicCallBack = characteristicCallBack;
    NSString *identifier = parameter[@"address"];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    if (peripheral == nil) {
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0001",@"errMsg":@"其他未知异常"}];
//        characteristicCallBack(data);
        return;
    }
    NSArray<CBService*>*newServices = peripheral.services;
    for (CBService *service in newServices) {
        NSArray <CBCharacteristic*> *newCharcteritic  = service.characteristics;
        for (CBCharacteristic *charcteritic in newCharcteritic) {
            [self.centerManager notify:peripheral characteristic:charcteritic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0002",@"errMsg":@"其他未知异常"}];
//                characteristicCallBack(data);
            }];
        }
    }
}

#pragma mark --------10-断开所有连接----------
-(void)cancelAllPeripheralsConnection {
    [self.centerManager cancelScan];
    [self.centerManager cancelAllPeripheralsConnection];
}

#pragma mark ----------11.断开蓝牙连接--------
-(void)closeBLEConnection:(NSDictionary*)parameter{
    [self.centerManager cancelScan];
    NSString *identifier = parameter[@"address"];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    [self.centerManager cancelPeripheralConnection:peripheral];
}

#pragma mark --------------1.1监听蓝牙的状态蓝牙状态代理-------------
-(void)centralManagerStateDelegate {
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
            case CBCentralManagerStatePoweredOn://设备打开成功
                data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@(true)}];
              break;
            default:
              break;
          }
    }];
}

#pragma mark -------2.1-设置搜索蓝牙代理 找到Peripherals的委托--------
-(void)setScanForPeripherals {
    __weak typeof(self) weakSelf = self;
    //开始扫描设备
    [self.centerManager setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        
        if (![weakSelf.deviceDic objectForKey:[peripheral name]]&&peripheral!=nil&&peripheral.name!=nil) {
            [weakSelf.deviceDic setObject:peripheral forKey:[[peripheral identifier] UUIDString]];
                 NSLog(@"UUIDString:%@",peripheral.identifier.UUIDString);
                 NSDictionary *data = @{
                   @"code":@"0",
                   @"errMsg":@"",
                   @"address":peripheral.identifier.UUIDString,
                   @"name":peripheral.name,
                   @"rssi":@(RSSI.intValue)
            };
            weakSelf.searchResultcallBack(data);
        }
    }];
}

#pragma mark -----连接成功和失败回调---------
-(void)didConnectPeripheral{
    __weak typeof(self) weakSelf = self;
    id bridBridge = [CSIIHybridBridge shareManager].bridge;
       bridBridge = (CSIIWKHybridBridge*)bridBridge;
    
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    ///连接设备->
    [self.centerManager setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions connectPeripheralWithOptions:nil scanForPeripheralsWithServices:nil discoverWithServices:nil discoverWithCharacteristics:nil];
    
    ///设置连接的设备的过滤器
     __block BOOL isFirst = YES;
    [self.centerManager setFilterOnConnectToPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
       NSString *pheralName = advertisementData[@"kCBAdvDataLocalName"];
        if (isFirst&& [peripheralName isEqualToString:pheralName]) {
            isFirst = NO;
            return YES;
        };
        return NO;
    }];
    
    ///连接成功回调
    [self.centerManager setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        NSLog(@"设备：%@--连接成功",peripheral.name);
        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                                                                             @"errMsg":@"连接成功",@"data":@"2"
                                     }]);//连接成功
        }
        [peripheral discoverServices:nil];
        //停止扫描
        [weakSelf.centerManager  cancelScan];

    }];
    
    ///设置设备连接失败的委托
    [self.centerManager setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"3",@"errMsg":@"连接失败"}];
        [weakSelf.centerManager  cancelScan];
        
        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack(data);
        }
        NSLog(@"设备：%@--连接失败",peripheral.name);
        if (weakSelf.connectStatusCallBack) {
            weakSelf.connectStatusCallBack(data);
        }
    }];
    
    ///设备断开连接
    [self.centerManager setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"3",@"errMsg":@"当前连接已断开"}];

        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack(data);
        }
        if (weakSelf.connectStatusCallBack) {
            weakSelf.connectStatusCallBack(data);
        }
        [weakSelf.centerManager  cancelScan];
        NSLog(@"设备：%@--断开连接",peripheral.name);
    }];
    
    ///设置查找服务回叫
    [self.centerManager setBlockOnDiscoverServices:^(CBPeripheral *peripheral, NSError *error) {
        CBService * __nullable findService = nil;
        for (CBService *service in peripheral.services)
        {
            NSLog(@"UUID:%@",service.UUID);
            if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"FFF0"]])
            {
                NSLog(@"UUID:%@",service.UUID);
                findService = service;
            }
        }
        if (peripheral.services.count> 0) {
            // 遍历服务
            [weakSelf.serverceArray addObjectsFromArray:peripheral.services];//保存服务ID的对象
            if (findService) {
                [peripheral discoverCharacteristics:NULL forService:findService];
            }
          
        }else{
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"4",@"errMsg":@"没有找到指定服务"}]);
        }

    }];
    
    ///设置发现设service的Characteristics的委托
    [self.centerManager setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        if (service.characteristics.count> 0) {
            [weakSelf.characteristicArray addObjectsFromArray:service.characteristics];
        }else{
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}]);
        }

    }];
    
    ///设置发现characteristics的descriptors的委托
    [self.centerManager setBlockOnDiscoverDescriptorsForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
       NSLog(@"===characteristic name:%@",characteristic.service.UUID);
       for (CBDescriptor *d in characteristic.descriptors) {
           NSLog(@"CBDescriptor name is :%@",d.UUID);
       }
    }];
       
    ///设置读取Descriptor的委托
    [self.centerManager setBlockOnReadValueForDescriptors:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) {
       NSLog(@"Descriptor name:%@ value is:%@",descriptor.characteristic.UUID, descriptor.value);
    }];
    
     ///写入特征值成功
    [self.centerManager setBlockOnDidWriteValueForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        if (error)
        {
          NSLog(@"Discovered services for %@ with error: %@", characteristic.UUID.UUIDString, [error localizedDescription]);
          return;
        }else{
            NSLog(@"characteristic = %@",characteristic.value);
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                                   @"errMsg":@"",
                                   @"data":@"1"}];
            if (weakSelf.wiriteBLECallBlack) {
                weakSelf.wiriteBLECallBlack(data);
            }
        }
    }];
    
    ///订阅特征值变化的通知
    [self.centerManager setBlockOnDidUpdateNotificationStateForCharacteristic:^(CBCharacteristic *characteristic, NSError *error) {
        NSData *data = characteristic.value;
    
        Byte *testByte = (Byte *)[data bytes];
        for(int i=0;i<[data length];i++){
            printf("testByte = %d ",testByte[i]);
        }
    
        NSString *dataString;
        if (data!=nil) {
            dataString =  [TypeConversion convertDataToHexStr:data];//字符串转成16进制字符串
            NSString *charData = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"订阅到的特征值数据",@"data":dataString}];
            if (weakSelf.characteristicCallBack) {
                NSLog(@"获取到特征值变化数据：%@",charData);
                weakSelf.characteristicCallBack(charData);
            }
        }else{
            dataString =@"";
        }

    }];
}

- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)

    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数

        if([newHexStr length]==1)

            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];

        else

            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
 
-(NSMutableDictionary*)deviceDic {
    if (_deviceDic == nil) {
        _deviceDic = [NSMutableDictionary dictionary];
    }
    return _deviceDic;
}

-(NSMutableArray*)serverceArray {
    if (_serverceArray == nil) {
        _serverceArray = [NSMutableArray array];
    }
    return _serverceArray;
}

-(NSMutableArray*)characteristicArray{
    if (_characteristicArray == nil) {
        _characteristicArray = [NSMutableArray array];
    }
    return _characteristicArray;
}

-(NSMutableArray*)peripheralDataArray{
    if (_peripheralDataArray == nil) {
        _peripheralDataArray = [NSMutableArray array];
    }
    return _peripheralDataArray;
}

@end
