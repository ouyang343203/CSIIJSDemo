//
//  HKBabyBluetoothManager.h
//  CSIIJSBridge
//
//  Created by ouyang on 2022/9/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 设置蓝牙的前缀【开发者必须改为自己的蓝牙设备前缀】
#define kMyDevicePrefix (@"Dana")
// 设置蓝牙的channel值【开发者可不做修改】
#define channelOnPeropheralView @"peripheralView"


typedef void (^BluetoothStateCallback)(id resultState);//蓝牙状态回调
typedef void (^BluetoothSearchResultCallback)(id searchResult);//停止搜索的回调
typedef void (^BluetoothBLEConnectCallback)(id connectResult);//蓝牙连接结果
typedef void (^BluetoothWriteBLECallback)(id writeValueResult);//写入数据结果
typedef void (^BluetoothNotifyCharacteristicCallBlock)(id notifyCharacteristicResult);//特征值的变化
typedef void (^BluetoothServicesCallback)(id servicesResult);//获取蓝牙低功耗设备所有服务(前提必须建立连接)
typedef void (^BluetoothCharacteristicsCallback)(id characteristicsResult);//获取蓝牙低功耗设备某个服务中所有特征(前提必须建立连接和获取服务UUID)

@interface HKBabyBluetoothManager : NSObject
+ (HKBabyBluetoothManager *)shareBabyBluetooth;
//1.初始化蓝牙
-(void)openBluetoothAdapter:(NSDictionary*)parameter;
//2.获取本机蓝牙适配器状态(监听蓝牙打开和关闭状态)
-(void)getBluetoothAdapterState:(BluetoothStateCallback)stateCallBack;
//3.搜索设备
-(void)onBluetoothDeviceFound:(NSDictionary*)parameter callBack:(BluetoothSearchResultCallback)searchResultcallBack;
//4.连接蓝牙设备
-(void)createBLEConnection:(NSString*)parameter callBack:(BluetoothBLEConnectCallback)ConnectCallBack;
//5.向蓝牙低功耗设备特征值中写入二进制数据
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter callBack:(BluetoothWriteBLECallback)writeCallBack;
//6.停止蓝牙搜索(建立连接后需要断开搜索)
-(void)stopBluetoothDevicesDiscovery;
//7.获取蓝牙低功耗设备所有服务(需要已经通过 createBLEConnection 建立连接)
-(void)getBLEDeviceServices:(NSString*)parameter callBack:(BluetoothServicesCallback)serviceCallBack;
//8.获取蓝牙低功耗设备某个服务中所有特征(createBLEConnection 建立连接,需要先调用 getBLEDeviceServices 获取)
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter callBack:(BluetoothCharacteristicsCallback)characteristics;
//9.监听特征值变化(添加特征值变化的通知NotifyValue)
-(void)notifyBLECharacteristicValueChange:(NSDictionary*)parameter callBack:(BluetoothNotifyCharacteristicCallBlock)characteristicCallBack;
// 10.断开所有蓝牙连接
-(void)cancelAllPeripheralsConnection;
// 11.断开蓝牙连接
-(void)closeBLEConnection:(NSDictionary*)parameter;
@end

NS_ASSUME_NONNULL_END
