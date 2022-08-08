//
//  TypeConversion.m
//  BallMachine
//
//  Created by 李佛军 on 2022/1/17.
//

#import "TypeConversion.h"
#import "BabyDefine.h"

@implementation TypeConversion
+(NSData *)hexString:(NSString *)hexString
{
    int j=0;
    Byte bytes[128];
    ///3ds key的Byte 数组， 128位
    for(int i=0; i<[hexString length]; i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        int_ch = int_ch1+int_ch2;
        NSLog(@"int_ch=%d",int_ch);
        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:126];
    return newData;
}
+(NSString *)convertDataToHexStr:(NSData *)data {
    BabyLog(@"我奔溃了1111%@",data);
    if (!data || [data length] == 0) {
        return @"";
    }
    BabyLog(@"我奔溃了22222%@",data);
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    BabyLog(@"我奔溃了33333%@",data);
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        BabyLog(@"我奔溃了444444%@",data);
        for (NSInteger i = 0; i < byteRange.length; i++) {
            BabyLog(@"我奔溃了555555%@",data);
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                BabyLog(@"我奔溃了666666%@",data);
                [string appendString:hexStr];
            } else {
                BabyLog(@"我奔溃了777777%@",data);
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];

    return string;
}
@end
