//
//  HKBabyBluetoothManager.m
//  CSIIJSBridge
//
//  Created by ouyang on 2022/9/2.
//

#import "HKBabyBluetoothManager.h"
#import "BabyBluetooth.h"
#import "CSIICheckObject.h"
#import <AudioToolbox/AudioToolbox.h>
#import "TypeConversion.h"
#import "BluetoothManager.h"

@interface HKBabyBluetoothManager ()

@property (nonatomic, strong) BabyBluetooth    *babyBluetooth;
@property (nonatomic, copy)   BluetoothStateCallback stateCallBack;//蓝牙状态回调
@property (nonatomic, strong) NSMutableDictionary *deviceDic;//搜索到的所有设备
@property (nonatomic, copy)   BluetoothBLEConnectCallback contentCallBack;//连接蓝牙后的结果
@property (nonatomic, copy)   BluetoothWriteBLECallback wiriteBLECallBlack;//数据写入
@property (nonatomic, copy)   BluetoothNotifyCharacteristicCallBlock characteristicCallBack;//订阅特性改变的通知
@property (nonatomic, copy) NSString *serviceUuid;//主服务UUID

@end


@implementation HKBabyBluetoothManager


+ (HKBabyBluetoothManager *)shareBabyBluetooth {
    static HKBabyBluetoothManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HKBabyBluetoothManager alloc] init];
    });
    return instance;
}

#pragma mark - HTTP Method -- 网络请求
// 方法和方法之间空一行
#pragma mark - Delegate Method -- 代理方法

#pragma mark - Public Method -- 公开
#pragma mark --------1.初始化蓝牙模块--------
-(void)openBluetoothAdapter:(NSDictionary*)parameter {

    self.babyBluetooth = [BabyBluetooth shareBabyBluetooth];
    // 2-设置查找设备的过滤器
    [self.babyBluetooth setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        // 最常用的场景是查找某一个前缀开头的设备
        if ([peripheralName hasPrefix:kMyDevicePrefix]) {
            return YES;
        }
        return NO;
    }];
    
    // 查找的规则
    [self.babyBluetooth setFilterOnDiscoverPeripheralsAtChannel:channelOnPeropheralView filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
         // 最常用的场景是查找某一个前缀开头的设备
         if ([peripheralName hasPrefix:kMyDevicePrefix]) {
             return YES;
         }
         return NO;
    }];
    
    //设置连接规则
    [self.babyBluetooth setFilterOnConnectToPeripheralsAtChannel:channelOnPeropheralView filter:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
        return NO;
    }];
    
}

#pragma mark --------2.获取蓝牙状态（是否开启或者关闭）--------
-(void)getBluetoothAdapterState:(BluetoothStateCallback)stateCallBack {
    //初始化蓝牙中心
    [[BluetoothManager manager]initBluetooth:^(id  _Nonnull resultState) {
        stateCallBack(resultState);
    }];
    // 1-系统蓝牙状态
    [self.babyBluetooth setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *data = nil;
            switch (central.state) {
                case CBManagerStateUnknown:
                     data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0004",@"errMsg":@"状态未知",@"data":@(false)}];
                  break;
                case CBManagerStateResetting:
                    data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0005",@"errMsg":@"蓝牙断开即将重置",@"data":@(false)}];
                  break;
                case CBManagerStateUnsupported:
                    data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0002",@"errMsg":@"蓝牙未启",@"data":@(false)}];
                  break;
                case CBManagerStateUnauthorized:
                    data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0003",@"errMsg":@"蓝牙未被授权",@"data":@(false)}];
                  break;
                case CBManagerStatePoweredOff:
                    data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0001",@"errMsg":@"蓝牙未启",@"data":@(false)}];
                  break;
                case CBManagerStatePoweredOn://蓝牙开启
                    data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@(true)}];
                  break;
                default:
                  break;
              }
        });
    }];
}

#pragma mark --------3.搜索蓝牙设备--------
-(void)onBluetoothDeviceFound:(NSDictionary*)parameter callBack:(BluetoothSearchResultCallback)searchResultcallBack {
    __weak typeof(self) weakSelf = self;
    self.babyBluetooth.scanForPeripherals().begin(30);
    //3-设置扫描到设备的委托
    [self.babyBluetooth setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (![weakSelf.deviceDic objectForKey:[peripheral name]]&&peripheral!=nil&&peripheral.name!=nil) {
                [weakSelf.deviceDic setObject:peripheral forKey:peripheral.identifier.UUIDString];
                     NSLog(@"UUIDString:%@",peripheral.identifier.UUIDString);
                     NSDictionary *data = @{
                       @"code":@"0",
                       @"errMsg":@"扫描到设备",
                       @"address":peripheral.identifier.UUIDString,
                       @"name":peripheral.name,
                       @"rssi":@(RSSI.intValue)
                };
                searchResultcallBack(data);
            }
        });
    }];
}

#pragma mark --------4.连接指定蓝牙设备---------
-(void)createBLEConnection:(NSString*)parameter callBack:(BluetoothBLEConnectCallback)ConnectCallback {
    self.contentCallBack = ConnectCallback;
    CBPeripheral * peripheral = (CBPeripheral*)[self.deviceDic objectForKey:parameter];//parameter 当前的蓝牙设备
    if ([parameter isEqualToString:peripheral.identifier.UUIDString]&&peripheral!=nil ) {
       
        [self.babyBluetooth cancelAllPeripheralsConnection];
        self.babyBluetooth.having(peripheral).and.channel(channelOnPeropheralView).
        then.connectToPeripherals().discoverServices().
        discoverCharacteristics().readValueForCharacteristic().
        discoverDescriptorsForCharacteristic().
        readValueForDescriptors().begin();

        [self didConnectPeripheral];
    }else{
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10030",@"errMsg":@"连接 address 为空或者是格式不正确"}];
        ConnectCallback(data);
    }
}

#pragma mark --------5.数据写入---------
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
        if ([service.UUID.UUIDString isEqualToString:serviceId])//找到主服务id
        {
            findService = service;
            [peripheral discoverCharacteristics:NULL forService:service];
            NSArray <CBCharacteristic*> *newCharcteritic  = service.characteristics;
            NSString *data_10005 = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}];
            if (newCharcteritic.count == 0) {writeCallBack(data_10005); return;}
            
            for (CBCharacteristic *charcteritic in service.characteristics)
            {
                if ([[[charcteritic UUID] UUIDString] isEqualToString:characteristicId])//找到主服务下特征
                {
                    findCharcteritic = charcteritic;
                    [peripheral discoverDescriptorsForCharacteristic:charcteritic];
                }
            }
        }
    }
    if (findService && findCharcteritic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            //向主服务特征写入数据
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [peripheral writeValue: [TypeConversion hexString:dataStr] forCharacteristic:findCharcteritic type:CBCharacteristicWriteWithResponse];
                NSString *datastr = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":[NSString stringWithFormat:@"%@ 写入的原始数据",dataStr]}];
                writeCallBack(datastr);
            });
            
        });
    }
}

#pragma mark --------6.停止搜索蓝牙----------
-(void)stopBluetoothDevicesDiscovery {
    [self.babyBluetooth cancelScan];
}

#pragma mark --------7.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)----------
-(void)getBLEDeviceServices:(NSString*)parameter callBack:(BluetoothServicesCallback)serviceCallBack {
    NSMutableArray *serverces = [NSMutableArray array];
    NSMutableDictionary *serverceDic = [NSMutableDictionary dictionary];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:parameter];
    NSArray<CBService*>*newServices = peripheral.services;
    for (CBService *service in newServices) {
        [serverceDic setValue:service.UUID.UUIDString forKey:@"uuid"];
        [serverceDic setValue:@(service.isPrimary) forKey:@"type"];
        [serverces addObject:serverceDic];
        [peripheral discoverCharacteristics:nil forService:service];
    }
    NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":serverces.count > 0 ? @"获取服务成功":@"获取服务失败",@"data":serverces}];
    NSLog(@"======获取的所有服务%@",data);
    serviceCallBack(data);
}

#pragma mark --------8.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)----------
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter callBack:(BluetoothCharacteristicsCallback)characteristics {
    
    NSString *identifier = parameter[@"mac"];//6FDA7EE6-27C5-6161-D32A-867D6E0E9B1D
    NSString *serviceId = parameter[@"serviceUuid"];//FFF0
    NSLog(@"serviceUuid:%@",serviceId);
    self.serviceUuid = serviceId;
    NSMutableArray *charcterArray = [NSMutableArray array];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    NSArray<CBService*>*newServices = peripheral.services;
    for (CBService *service in newServices) {
        NSLog(@"service.UUID.UUIDString:%@",service.UUID.UUIDString);        
        if ([service.UUID.UUIDString isEqualToString:serviceId]) {
            
            NSArray <CBCharacteristic*> *newCharcteritic  = service.characteristics;
            if (newCharcteritic.count > 0) {
                for (CBCharacteristic *charcteritic in service.characteristics) {
                    NSMutableDictionary *charcteriticDic = [NSMutableDictionary dictionary];
                    [charcteriticDic setValue:charcteritic.UUID.UUIDString forKey:@"uuid"];
                    [charcterArray addObject:charcteriticDic];
                }
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"获取到的服务特征",@"data":charcterArray}];
                characteristics(data);
            }else{
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}];
                characteristics(data);
            }
        
        }else{
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"10004",@"errMsg":@"没有找到服务"}];
            characteristics(data);
        }
    }
}

#pragma mark --------9.监听特征值变化(添加特征值变化的通知NotifyValue)----------
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
            
            NSData *data = charcteritic.value;
            Byte *testByte = (Byte *)[data bytes];
            for(int i=0;i<[data length];i++){
                NSLog(@"testByte = %d ",testByte[i]);
            }
           //开启 characteristic的notify
            
            [self.babyBluetooth notify:peripheral characteristic:charcteritic block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
                NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0002",@"errMsg":@"其他未知异常"}];
//                characteristicCallBack(data);
            }];
        }
    }
}

#pragma mark --------10-断开所有连接----------
-(void)cancelAllPeripheralsConnection {
    [self.babyBluetooth cancelScan];
    [self.babyBluetooth cancelAllPeripheralsConnection];
}

#pragma mark ----------11.断开蓝牙连接--------
-(void)closeBLEConnection:(NSDictionary*)parameter{
    [self.babyBluetooth cancelScan];
    NSString *identifier = parameter[@"address"];
    CBPeripheral * peripheral = (CBPeripheral*)[_deviceDic objectForKey:identifier];
    [self.babyBluetooth cancelPeripheralConnection:peripheral];
}

#pragma mark - Private Method -- 私有方法
//连接成功和失败回调
-(void)didConnectPeripheral{
    __weak typeof(self) weakSelf = self;
    BabyRhythm *rhythm = [[BabyRhythm alloc]init];
    //1-设置设备连接成功的委托,同一个baby对象，使用不同的channel切换委托回调
    [self.babyBluetooth setBlockOnConnectedAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral) {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        NSLog(@"设备：%@--连接成功",peripheral.name);
        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"连接成功",@"data":@"2"}]);//连接成功
        }
        [peripheral discoverServices:nil];
        //停止扫描
        [weakSelf.babyBluetooth  cancelScan];
    }];
    
    // 2-设置设备连接失败的委托
    [self.babyBluetooth setBlockOnFailToConnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"3",@"errMsg":@"连接失败"}];
        [weakSelf.babyBluetooth  cancelScan];
        
        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack(data);
        }
    }];
    
    // 3-设置设备断开连接的委托
    [self.babyBluetooth setBlockOnDisconnectAtChannel:channelOnPeropheralView block:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"3",@"errMsg":@"当前连接已断开"}];

        if (weakSelf.contentCallBack) {
            weakSelf.contentCallBack(data);
        }
    }];
    
    // 4-设置发现设备的Services的委托
    [self.babyBluetooth setBlockOnDiscoverServicesAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, NSError *error) {
        
        CBService * __nullable findService = nil;
        for (CBService *service in peripheral.services)
        {
            if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"FFF0"]])
            {
                NSLog(@"发现设备的Services服务:%@",service.UUID.UUIDString);
                findService = service;
            }
        }
        if (peripheral.services.count> 0) {
            if (findService) {
                [peripheral discoverCharacteristics:NULL forService:findService];
            }

        }else{
            weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"4",@"errMsg":@"没有找到指定服务"}]);
        }
        [rhythm beats];
    }];
    
    
    // 5-设置发现设service的Characteristics的委托
    [self.babyBluetooth setBlockOnDiscoverCharacteristicsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        
        if (service.characteristics.count > 0) {
            NSString *serviceUUID = [NSString stringWithFormat:@"%@",service.UUID];
            if ([serviceUUID isEqualToString:weakSelf.serviceUuid]) {
                for (CBCharacteristic *ch in service.characteristics) {
                    NSString *chUUID = [NSString stringWithFormat:@"%@",ch.UUID];
                    NSLog(@"chUUID:%@",chUUID);
                    // 写数据的特征值
                    if ([chUUID isEqualToString:@"FFF1"]) {
                        [peripheral setNotifyValue:YES forCharacteristic:ch];
                    }
                }
            }else{
                weakSelf.contentCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"10005",@"errMsg":@"没有找到指定特征"}]);
            }
        }
     }];
    
    
    // 6-设置读取characteristics的委托
    [self.babyBluetooth setBlockOnReadValueForCharacteristicAtChannel:channelOnPeropheralView
                                                                block:^(CBPeripheral *peripheral, CBCharacteristic *characteristics, NSError *error) {
        
        NSLog(@"蓝牙发来的characteristic = %@",characteristics.value);
                                                    
                                                                }];
    
    //7-设置发现characteristics的descriptors的委托
    [self.babyBluetooth setBlockOnDiscoverDescriptorsForCharacteristicAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSString *UUID = [NSString stringWithFormat:@"characteristic.UUID:%@",characteristic.UUID];
        NSLog(@"UUID:%@",UUID);
    }];
    
    
    //8-设置读取Descriptor的委托
    [self.babyBluetooth setBlockOnReadValueForDescriptorsAtChannel:channelOnPeropheralView block:^(CBPeripheral *peripheral, CBDescriptor *descriptor, NSError *error) { }];
    
    //9-写入特征值成功的委托
    [self.babyBluetooth setBlockOnDidWriteValueForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        if (error)
        {
          NSLog(@"Discovered services for %@ with error: %@", characteristic.UUID.UUIDString, [error localizedDescription]);
          return;
        }else{
            NSLog(@"characteristic = %@",characteristic.value);
            NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                                   @"errMsg":@"写入特征成功",
                                   @"data":@"0"}];
            if (weakSelf.wiriteBLECallBlack) {
                weakSelf.wiriteBLECallBlack(data);
            }
        }
    }];
    
   //10订阅特征值变化的通知
    [self.babyBluetooth setBlockOnDidUpdateNotificationStateForCharacteristicAtChannel:channelOnPeropheralView block:^(CBCharacteristic *characteristic, NSError *error) {
        NSData *data = characteristic.value;    
        NSString *dataString;
        if (data!=nil) {
            dataString =  [TypeConversion convertDataToHexStr:data];//data转成16进制字符串
            NSString *charData = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"iOS监听返回特征值",@"data":dataString}];
            if (weakSelf.characteristicCallBack) {
                weakSelf.characteristicCallBack(charData);
            }
        }else{
            dataString =@"";
        }
    }];
    
    // 读取rssi的委托d
    [self.babyBluetooth setBlockOnDidReadRSSI:^(NSNumber *RSSI, NSError *error) { }];
    
    // 设置beats break委托
    [rhythm setBlockOnBeatsBreak:^(BabyRhythm *bry) { }];
    
    // 设置beats over委托
    [rhythm setBlockOnBeatsOver:^(BabyRhythm *bry) { }];
    
    
    // 扫描选项->CBCentralManagerScanOptionAllowDuplicatesKey:忽略同一个Peripheral端的多个发现事件被聚合成一个发现事件
    NSDictionary *scanForPeripheralsWithOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    /*连接选项->
     CBConnectPeripheralOptionNotifyOnConnectionKey :当应用挂起时，如果有一个连接成功时，如果我们想要系统为指定的peripheral显示一个提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnDisconnectionKey :当应用挂起时，如果连接断开时，如果我们想要系统为指定的peripheral显示一个断开连接的提示时，就使用这个key值。
     CBConnectPeripheralOptionNotifyOnNotificationKey:
     当应用挂起时，使用该key值表示只要接收到给定peripheral端的通知就显示一个提
     */
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                     CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    
    [self.babyBluetooth setBabyOptionsAtChannel:channelOnPeropheralView
                  scanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                   connectPeripheralWithOptions:connectOptions
                 scanForPeripheralsWithServices:nil
                           discoverWithServices:nil
                    discoverWithCharacteristics:nil];
    
    [self.babyBluetooth setBabyOptionsWithScanForPeripheralsWithOptions:scanForPeripheralsWithOptions
                                           connectPeripheralWithOptions:nil
                                         scanForPeripheralsWithServices:nil
                                                   discoverWithServices:nil
                                            discoverWithCharacteristics:nil];
}

#pragma mark - Action

#pragma mark - setupSubViews -- UI

#pragma mark - Setter/Getter -- Getter尽量写出懒加载形式

-(NSMutableDictionary*)deviceDic {
    if (_deviceDic == nil) {
        _deviceDic = [NSMutableDictionary dictionary];
    }
    return _deviceDic;
}
@end
