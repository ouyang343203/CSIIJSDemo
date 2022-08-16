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

//2.搜索蓝牙设备
-(void)scanForPeripheralsWithServices:(id <BluetoothDelegate>)delegate {
    [_centerManager scanForPeripheralsWithServices:nil options:nil];
    self.delegate = delegate;
}

//3.连接蓝牙
-(void)createBLEConnection:(id)parameter bluetoothDelegage:(id<BluetoothDelegate>)delegate callBack:(createBLECallback) connettioncalBack {
    NSDictionary *diction = (NSDictionary*)parameter;
    CBPeripheral *peripheral = [CBPeripheral init];
    self.delegate = delegate;
    [peripheral setValue:diction[@"deviceId"] forKey:@"identifier"];
    if (_centerManager) {
        [_centerManager connectPeripheral:peripheral options:nil];
        self.peripheral = peripheral;
        [peripheral setDelegate:self];
        [peripheral discoverServices:nil];
    }else{
        connettioncalBack(@{@"code":@"10000"});
    }
}

// 4.获取蓝牙低功耗设备所有服务
-(void)getBLEDeviceServices:(NSDictionary*)parameter {
    NSDictionary *diction = (NSDictionary*)parameter;
    CBPeripheral *peripheral = [CBPeripheral init];
    [peripheral setValue:diction[@"deviceId"] forKey:@"identifier"];
    if (_centerManager) {
        [_centerManager connectPeripheral:peripheral options:nil];
        [peripheral setDelegate:self];
        [peripheral discoverServices:nil];
    }
}
//5.获取蓝牙低功耗设备某个服务中所有特征
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter {
    
}
//4.停止搜寻附近
-(void)stopBluetoothDevicesDiscovery:(stopBluetoothSearchCallback)bluetoothState {
    if (_centerManager == nil) {
        bluetoothState(@{@"code":@"10000"});
    }else
    {
        //10000(未初始化蓝牙适配器)、-1(已连接)、
        if (_centerManager.isScanning) {

            bluetoothState(@{@"code":@"-1"});
        }else{

            [_centerManager stopScan];
        }
      
    }
}

//写入蓝牙设备
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter {
    NSString *deviceID = parameter[@"deviceId"];
    NSString *serviceId = parameter[@"serviceId"];
    NSString *characteristicId = parameter[@"characteristicId"];
    NSArray *valueArray = parameter[@"value"];
    CBPeripheral *peripheral = [CBPeripheral init];
    [peripheral setValue:deviceID forKey:@"identifier"];
    CBService *service = [CBService new];
    [service setValue:[CBUUID UUIDWithString:serviceId] forKey:@"UUID"];
    
    [peripheral discoverCharacteristics:NULL forService:service];
    
    CBCharacteristic *characteristic = [CBCharacteristic new];
    [characteristic setValue:[CBUUID UUIDWithString:characteristicId] forKey:@"CBUUID"];
    
     NSData *data = [NSKeyedArchiver archivedDataWithRootObject:valueArray];
    [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
}

-(void)connectDeviceWithPeripheral:(id)parameter {
    NSDictionary *diction = (NSDictionary*)parameter;
    
    id pheral = diction.allValues[0];
    if ([pheral isKindOfClass:[CBPeripheral class]]) {
        CBPeripheral *peripheral = (CBPeripheral*)pheral;
        [_centerManager connectPeripheral:peripheral options:nil];
    }
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

#pragma mark -------发现外围设备----------
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI {
    if (![_deviceDic objectForKey:[peripheral name]])
    {
        if (peripheral!=nil) {
            if ([peripheral name]!=nil) {
                [_deviceDic setObject:peripheral forKey:[peripheral name]];
                if (self.delegate != nil && [self.delegate respondsToSelector:@selector(JG_didDiscoverPeripheral:)]) {
                    [self.delegate JG_didDiscoverPeripheral:@{@"name":peripheral.name,@"deviceId":peripheral.identifier}];
                }
                NSLog(@"peripheral name = %@",peripheral);
            }
        }
    }
}

#pragma mark --连接成功------
// 中心管理者连接外设成功
- (void)centralManager:(CBCentralManager *)central // 中心管理者
 didConnectPeripheral:(CBPeripheral *)peripheral // 外设
{
    peripheral.delegate = self;
    self.peripheral = peripheral;
  [peripheral discoverServices:nil];
}

#pragma mark -----连接失败
//外设连接失败10003（连接失败）、10004（没有找到制定服务）、10005（没有找到指定特征）、10006（当前已经断开）100013(连接 deviceId 为空或者是格式不正确)
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (self.delegate&&[self.delegate respondsToSelector:@selector(JG_didFailToConnectPeripheral:)]) {
      
        
        [self.delegate JG_didFailToConnectPeripheral:@{@"code":@"10003"}];
    }
  NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
}

#pragma mark ------丢失连接-------
// 丢失连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
  NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
}

#pragma mark ----------发现服务回调---------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    CBService * __nullable findService = nil;
    // 遍历服务
    for (CBService *service in peripheral.services)
    {

        NSLog(@"UUID:%@",service.UUID);
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:@"9FA480E0-4967-4542-9390-D343DC5D04AE"]])
        {
            findService = service;
        }
    }
    NSLog(@"Find Service:%@",findService);
    if (findService)
        [peripheral discoverCharacteristics:NULL forService:findService];
}

#pragma mark --------发现特征回调用---------
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        NSLog(@"c.properties:%lu",(unsigned long)characteristic.properties) ;
        NSLog(@"c.properties:%lu",(unsigned long)characteristic.UUID);
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"AF0BADB1-5B99-43CD-917A-A77BC549E3CC"]]) {

            [peripheral setNotifyValue:YES forCharacteristic:characteristic];

            NSData *data = [@"硬件工程师给我的指令, 发送给蓝牙该指令, 蓝牙会给我返回一条数据" dataUsingEncoding:NSUTF8StringEncoding];
            // 将指令写入蓝牙
                [self.peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        }
        
        /**
         */
        [peripheral discoverDescriptorsForCharacteristic:characteristic];
    }
}
@end
