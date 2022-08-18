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

@interface BluetoothManager : NSObject

+ (instancetype)manager;
//1.初始化蓝牙设备 openBluetoothAdapter、getBluetoothAdapterState
-(void)initBluetooth:(BluetoothStateCallback)state;
@end

NS_ASSUME_NONNULL_END
