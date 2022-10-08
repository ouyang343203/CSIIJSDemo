//
//  XFBleBlueManger.h
//  CSIIJSBridge
//
//  Created by ouyang on 2022/9/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface XFBleBlueManger : NSObject

typedef void (^BluetoothStateCallback)(id resultState);//蓝牙状态回调
typedef void (^BluetoothSearchResultCallback)(id searchResult);//搜索蓝牙结果的回调
typedef void (^BluetoothBLEConnectCallback)(id connectResult);//蓝牙连接结果
typedef void (^BluetoothWriteBLECallback)(id writeValueResult);//写入数据结果
typedef void (^BluetoothServicesCallback)(id servicesResult);//获取蓝牙低功耗设备所有服务(前提必须建立连接)
typedef void (^BluetoothCharacteristicsCallback)(id characteristicsResult);//获取蓝牙低功耗设备某个服务中所有特征(前提必须建立连接和获取服务UUID)

typedef void (^BluetoothCharacteristicValueChangeCallback)(id characteristicsResult);//获取蓝牙低功耗设备某个服务中所有特征变化

+ (instancetype)shareBlueManager;
// 方法和方法之间空一行
#pragma mark - HTTP

#pragma mark - Delegate

#pragma mark - Private

#pragma mark - Action

#pragma mark - Public
- (void)initBle;
//取消连接
- (void)stopPeripheral;

//取消连接
- (void)stopScan;

//获取设备连接状态
- (void)getBleSate:(BluetoothStateCallback)stateCallBack;

//扫描设备
- (void)scanDeviceCallBack:(BluetoothSearchResultCallback)searchResultcallBack;

//连接设备
- (void)connectionBleName:(NSString *)UUIDString
            connectResult:(BluetoothBLEConnectCallback)connectCallBack;
//写入特征数据
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter callBack:(BluetoothWriteBLECallback)writeCallBack;

//获取服务
-(void)getBLEDeviceServices:(NSString*)parameter callBack:(BluetoothServicesCallback)serviceCallBack;

//获取服务特
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter callBack:(BluetoothCharacteristicsCallback)characteristics;

//开启监听特征值变化
-(void)getnotifyBLECharacteristicValueChange:(NSDictionary*)parameter callBack:(BluetoothCharacteristicValueChangeCallback)characteristics;



#pragma mark - setupSubViews

@end

NS_ASSUME_NONNULL_END
