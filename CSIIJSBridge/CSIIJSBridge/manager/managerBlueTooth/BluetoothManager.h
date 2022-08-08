//
//  BluetoothManager.h
//  CSIIJSBridge
//
//  Created by 李佛军 on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@protocol BluetoothDelegate <NSObject>
//1,搜索到的设备代理
-(void)JG_didDiscoverPeripheral:(NSDictionary*)peripheral;
//连接蓝牙失败
-(void)JG_didFailToConnectPeripheral:(NSDictionary*)faill;
-(void)JG_didConnectDevice:(NSDictionary*)success;

@end
typedef void (^BluetoothStateCallback)(id resultState);//蓝牙状态回调
typedef void (^stopBluetoothSearchCallback)(id result);//停止搜索的回调
typedef void (^ServicesCallBack)(id services);//获取服务的回调
typedef void (^CharacteristicsCallBack)(id Characteristics);//获取到的特征回调
typedef void (^createBLECallback)(id resultBack);//连接蓝牙的回调


//typedef void (^BluetoothPeripheralBlock)(id resultDevice);//获取的蓝牙设备
@interface BluetoothManager : NSObject

+ (instancetype)manager;
//1.初始化蓝牙设备 openBluetoothAdapter、getBluetoothAdapterState
-(void)initBluetooth:(BluetoothStateCallback)state;
//2.搜索蓝牙
-(void)scanForPeripheralsWithServices:(id <BluetoothDelegate>)delegate;
//3.连接之前搜索过的蓝牙
-(void)createBLEConnection:(id)parameter bluetoothDelegage:(id<BluetoothDelegate>)delegate callBack:(createBLECallback) connettioncalBack;
// 4.获取蓝牙低功耗设备所有服务
-(void)getBLEDeviceServices:(NSDictionary*)parameter services:(ServicesCallBack)services;
//5.获取蓝牙低功耗设备某个服务中所有特征
-(void)getBLEDeviceCharacteristics:(NSDictionary*)parameter Characteristics:(CharacteristicsCallBack)Characteristics;
//6,向蓝牙低功耗设备特征值中写入二进制数据
-(void)writeBLECharacteristicValue:(NSDictionary*)parameter;
//7，停止搜索设备
-(void)stopBluetoothDevicesDiscovery:(stopBluetoothSearchCallback)bluetoothState;
//连接指定设备
-(void)connectDeviceWithPeripheral:(id)parameter;

@end

NS_ASSUME_NONNULL_END
