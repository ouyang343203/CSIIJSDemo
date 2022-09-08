//
//  TypeConversion.m
//  BallMachine
//
//  Created by 李佛军 on 2022/1/17.
//

#import "TypeConversion.h"
#import "BabyDefine.h"

@implementation TypeConversion
+(NSData *)hexString:(NSString *)hexString {
 
    NSLog(@"写入的16进制字符串原始数据:%@",hexString);
    hexString = [hexString uppercaseString];
    if (!hexString || [hexString length] == 0) { return nil; }
    
    if (hexString.length % 2 != 0) {
        hexString = [NSString stringWithFormat:@"0%@",hexString];
    }

    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:20];
    NSRange range;
    
    if ([hexString length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    
    for (NSInteger i = range.location; i < [hexString length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [hexString substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];

        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];

        range.location += range.length;
        range.length = 2;
    }
    Byte *testByte = (Byte *)[hexData bytes];
    for(int i=0;i<[hexData length];i++){
       printf("testByte = %d ",testByte[i]);
    }
    NSLog(@"hexdata: %@", hexData);
       return hexData;
}

+(NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    BabyLog(@"返回的16进制字符串%@",string);
    return string;
}

@end
