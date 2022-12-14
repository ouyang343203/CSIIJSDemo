//
//  TypeConversion.h
//  BallMachine
//
//  Created by  on 2022/1/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TypeConversion : NSObject
//字符串转成16进制字符串
+(NSData *)hexString:(NSString *)hexString;
//16进制转成字符串
+(NSString *)convertDataToHexStr:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
