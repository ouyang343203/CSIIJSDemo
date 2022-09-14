//
//  TypeConversion.m
//  BallMachine
//
//  Created by  on 2022/1/17.
//

#import "TypeConversion.h"
#import "BabyDefine.h"

@implementation TypeConversion

//16进制字符串转data
+(NSData *)hexString:(NSString *)hexString {
 
    NSLog(@"写入的16进制字符串原始数据:%@",hexString);
    NSMutableData* data = [NSMutableData data];
      int idx;
      for (idx = 0; idx+2 <= hexString.length; idx+=2) {
          NSRange range = NSMakeRange(idx, 2);
          NSString* hexStr = [hexString substringWithRange:range];
          NSScanner* scanner = [NSScanner scannerWithString:hexStr];
          unsigned int intValue;
          [scanner scanHexInt:&intValue];

          [data appendBytes:&intValue length:1];
      }
    Byte *testByte = (Byte *)[data bytes];
    for(int i=0;i<[data length];i++){
        printf("testByte = %d ",testByte[i]);
    }
    return data;
}

//data转16进制字符串
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
