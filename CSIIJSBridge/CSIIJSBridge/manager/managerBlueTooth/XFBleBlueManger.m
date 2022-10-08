//
//  XFBleBlueManger.m
//  CSIIJSBridge
//
//  Created by ouyang on 2022/9/26.
//

#import "XFBleBlueManger.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "TypeConversion.h"
#import "CSIICheckObject.h"

@interface XFBleBlueManger ()<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSMutableDictionary *deviceDic;//搜索到的所有设备
@property (nonatomic, copy)   BluetoothStateCallback stateCallBack;//蓝牙状态回调
@property (nonatomic, copy)   BluetoothSearchResultCallback resultCallBack; //搜索结果回调
@property (nonatomic, copy)   BluetoothBLEConnectCallback connectCallBack;//连接蓝牙后的结果
@property (nonatomic, copy)   BluetoothCharacteristicValueChangeCallback characteristicCallBack;//订阅特性改变的通知
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, strong) CBCharacteristic *read;
@property (nonatomic, strong) CBCharacteristic *write;
@property (nonatomic, copy)   BluetoothWriteBLECallback wiriteBLECallBlack;//数据写入

@end

@implementation XFBleBlueManger

+ (instancetype)shareBlueManager {
    static XFBleBlueManger *mg;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mg = [[XFBleBlueManger alloc]init];
    });
    return mg;
}

// 方法和方法之间空一行
#pragma mark - HTTP

#pragma mark - Delegate
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *, id> *)dict {
    
}

// 蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
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
            data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"",@"data":@(false)}];
            break;
    }
    self.stateCallBack(data);
}

// 扫描到外设
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
    NSLog(@"advertisementData:%@，RSSI:%@",advertisementData,RSSI);
    NSLog(@"扫描到外设:%@", peripheral.name); //kCBAdvDataServiceUUIDs
    if([peripheral.name containsString:@"Dana"]){
        NSDictionary *data = @{
            @"code":@"0",
            @"errMsg":@"",
            @"address":peripheral.identifier.UUIDString,
            @"name":peripheral.name,
            @"rssi":@(RSSI.intValue)
        };
        [self.deviceDic setObject:peripheral forKey:[[peripheral identifier] UUIDString]];
        self.resultCallBack(data);
    }
}

//连接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    //连接成功之后寻找服务，传nil会寻找所有服务
    peripheral.delegate = self;//这个方法调用发现服务协议
    [peripheral discoverServices:nil];
    self.connectCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"连接成功",@"data":@"2"}]);//连接成功
}

// 连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.connectCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"连接失败",@"data":@"0"}]);//连接失败
}

// 断开外设连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error {
    self.connectCallBack([CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"断开连接，连接失败",@"data":@"0"}]);//断开连接
}

//发现服务的回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error) {
        for (CBService *service in peripheral.services) {
            NSLog(@"serviceUUID:%@", service.UUID.UUIDString);
            if ([service.UUID.UUIDString isEqualToString:@"FFF0"]) {
                //发现特定服务的特征值
                [service.peripheral discoverCharacteristics:nil forService:service];
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverIncludedServicesForService:(CBService *)service error:(NSError *)error {
    //这个方法并不会被调用，而且如果不实现peripheral代理方法1会报下面的错误
    //API MISUSE: Discovering services for peripheral while delegate is either nil or does not implement peripheral:didDiscoverServices:
    for (CBService *service in peripheral.services) {
        NSLog(@"Discovered service %@",service);
    }
}


//发现characteristics，由发现服务调用（上一步），获取读和写的characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    for (CBCharacteristic *characteristic in service.characteristics) {
        //有时读写的操作是由一个characteristic完成
        NSLog(@"特征值Name:%@", characteristic.UUID.UUIDString);
        if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
            self.read = characteristic;
            self.write = characteristic;
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //[self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //            // 5FB84B8F727DC5F3D383DCE299C7FA55
            //            NSData * data = [TypeConversion hexString:@"5FB84B8F727DC5F3D383DCE299C7FA55"];
            //            NSLog(@"------写入内容:%@-----",data);
            //            //                [peripheral writeValue: data forCharacteristic:findCharcteritic type:CBCharacteristicWriteWithResponse];
            //            [peripheral writeValue: data forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
        } else if ([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]) {
            
        }
    }
}

//是否写入成功的代理
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        NSLog(@"===写入错误：%@",error);
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                               @"errMsg":@"写入特征失败",
                               @"data":@"0"}];
        if (self.wiriteBLECallBlack) {
            self.wiriteBLECallBlack(data);
        }
    }else{
        NSLog(@"===写入成功");
        NSString *data = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",
                               @"errMsg":@"写入特征成功",
                               @"data":@"1"}];
        if (self.wiriteBLECallBlack) {
            self.wiriteBLECallBlack(data);
        }
    }
}

//数据接收
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"接收到数据:%@", characteristic.UUID.UUIDString);
    if (error) {
        NSLog(@"接收到数据报错:%@", error);
    }
    if([characteristic.UUID.UUIDString isEqualToString:@"FFF1"]){
        //获取订阅特征回复的数据
        NSData *data = characteristic.value;
        NSString *hexStr = [TypeConversion convertDataToHexStr:data];
        NSLog(@"蓝牙回复：%@",hexStr);
        NSString *charData = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"iOS特征值监听数据",@"data":hexStr}];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"didUpdateValueForCharacteristic" object:charData];
    }
}


//特征值的通知设置改变时触发的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"===uid:%@,isNotifying:%@",characteristic.UUID,characteristic.isNotifying?@"on":@"off");
    NSData *data = characteristic.value;
    NSString *dataString;
    if (data!=nil && [characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF1"]]) {
        dataString =  [TypeConversion convertDataToHexStr:data];//data转成16进制字符串
        NSString *charData = [CSIICheckObject dictionaryChangeJson:@{@"code":@"0",@"errMsg":@"返回特征值",@"data":dataString}];
        if(self.characteristicCallBack){
            self.characteristicCallBack(charData);
        }
    }else{
        dataString =@"";
    }
}

//发现特征值的描述信息触发的方法
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    
}

//特征的描述值更新时触发的方法
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

//写描述信息时触发的方法
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForDescriptor:(CBDescriptor *)descriptor error:(nullable NSError *)error {
    
}

//比如我们要获取蓝牙电量，由硬件文档查询得知该指令是**0x1B9901**,那么获取电量的方法就可以写成
//- (void)getBattery{
//    Byte value[3]={0};
//    value[0]=x1B;
//    value[1]=x99;
//    value[2]=x01;
//    NSData * data = [NSData dataWithBytes:&value length:sizeof(value)];
//    //发送数据
//    [self.peripheral writeValue:data forCharacteristic:self.write type:CBCharacteristicWriteWithoutResponse];
//}

#pragma mark - Private
#pragma mark 初始化蓝牙
- (void)initBle {
    dispatch_queue_t centralQueue = dispatch_queue_create("centralQueue",DISPATCH_QUEUE_SERIAL);
    NSDictionary *dic = @{CBCentralManagerOptionShowPowerAlertKey : @(YES),
                          CBCentralManagerOptionRestoreIdentifierKey : @"unique identifier"
    };
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralQueue options:dic];
    self.deviceDic = [NSMutableDictionary dictionary];
}
#pragma mark - Action

#pragma mark - Public
#pragma mark 给前端获取蓝牙状态
- (void)getBleSate:(BluetoothStateCallback)stateCallBack {
    self.stateCallBack = stateCallBack;
}

#pragma mark 开始扫描设备，并将合规格的设备给前端
- (void)scanDeviceCallBack:(BluetoothSearchResultCallback)searchResultcallBack{
    //不重复扫描已发现设备
    self.resultCallBack = searchResultcallBack;
    NSDictionary *option = @{CBCentralManagerScanOptionAllowDuplicatesKey : [NSNumber numberWithBool:NO],CBCentralManagerOptionShowPowerAlertKey:@(YES)};
    [self.centralManager scanForPeripheralsWithServices:nil options:option];
}

#pragma mark H5下达指令需要连接
- (void)connectionBleName:(NSString *)UUIDString
            connectResult:(BluetoothBLEConnectCallback)connectCallBack {
    self.connectCallBack = connectCallBack;
    CBPeripheral * peripheral = (CBPeripheral*)[self.deviceDic objectForKey:UUIDString];
    self.peripheral = peripheral;
   // self.peripheral.delegate = self;
    [self.centralManager stopScan];
    [self.centralManager connectPeripheral:self.peripheral options:nil];//发起连接的命令
}

#pragma mark 取消连接
- (void)stopPeripheral {
    if (self.centralManager.isScanning) {
        [self.centralManager stopScan];
    }
    if (self.centralManager && self.peripheral) {
        [self.centralManager cancelPeripheralConnection:self.peripheral];
    }
}

- (void)stopScan {
    if (self.centralManager.isScanning) {
        [self.centralManager stopScan];
    }
}

#pragma mark --------5.数据写入---------
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter callBack:(BluetoothWriteBLECallback)writeCallBack {
    self.wiriteBLECallBlack = writeCallBack;
    NSString *dataStr = parameter[@"data"];
    NSData * data = [TypeConversion hexString:dataStr];
    NSLog(@"------写入内容:%@-----",data);
    [self.peripheral writeValue: data forCharacteristic:self.write type:CBCharacteristicWriteWithResponse];
}

#pragma mark --------前端要获取服务----------
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

#pragma mark --------8.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)----------
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

//开启监听特征值变化
-(void)getnotifyBLECharacteristicValueChange:(NSDictionary*)parameter callBack:(BluetoothCharacteristicValueChangeCallback)characteristics {
    NSLog(@"有特征值变化");
    self.characteristicCallBack = characteristics;
}
#pragma mark - setupSubViews

@end

