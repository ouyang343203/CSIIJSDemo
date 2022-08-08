//
//  CSIICheckObject.m
//  CSIIJSBridge
//
//  Created by Song on 2021/9/6.
//

#import "CSIICheckObject.h"

@implementation CSIICheckObject

//距离公里/米 高于999米 显示公里
+ (NSString *)returnSureDistance:(double)distance {
    NSString *distanceStr = @"";
    if (distance < 1000) {
        distanceStr = [NSString stringWithFormat:@"%.2lfm",distance];
        return distanceStr;
    } else {
        distanceStr = [NSString stringWithFormat:@"%.2lfkm",distance/1000.0];
        return distanceStr;
    }
}

//判断是不是汉字
+ (BOOL)isChinese:(NSString *)str {
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:str];
}


+ (NSString *)dictionaryChangeJson:(id )dictionary {
   
    if (dictionary == nil) {
        return @"";
    }
    NSData *data=[NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //DebugLog(@"jsonStr==%@",jsonStr);
    return jsonStr;
    //    }
    //    return dictionary;
}
+ (id)jsontoObject:(NSString *)jsonStr{
    NSError *error = nil;
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}
#pragma mark - 通过汉字获取该汉字的拼音
+ (NSString *)pinyinTransformByChinese:(NSString *)chinese {
    //将NSString装换成NSMutableString
    NSMutableString *pinyin = [chinese mutableCopy];
    //将汉字转换为拼音(带音标)
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformMandarinLatin, NO);
    NSLog(@"%@", pinyin);
    //去掉拼音的音标
    CFStringTransform((__bridge CFMutableStringRef)pinyin, NULL, kCFStringTransformStripCombiningMarks, NO);
    NSLog(@"%@", pinyin);
    //返回最近结果
    return pinyin;
}

//手机号脱敏
+ (NSString *)returnPwdPhone:(NSString *)phone {
    if (phone.length < 9) {
        return phone;
    }
    phone = [NSString stringWithFormat:@"%@****%@",[phone substringToIndex:5],[phone substringFromIndex:phone.length-4]];
    return phone;
}

//邮箱验证
+ (BOOL) validateEmail:(NSString *)email {
    //NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *emailRegex = @"^[A-Za-z\\d]+([-_.][A-Za-z\\d]+)*@([A-Za-z\\d]+[-.])+[A-Za-z\\d]{2,4}$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}


//手机号码验证1
+ (BOOL) validateMobile1:(NSString *)mobile {
    NSString *MOBILE = @"^(13[0-9]|14[5-9]|15[012356789]|166|17[0-8]|18[0-9]|19[8-9])[0-9]{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    return [regextestmobile evaluateWithObject:mobile];
}


//手机号码验证2
+ (BOOL) validateMobile2:(NSString *)mobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^(13[0-9]|14[5-9]|15[012356789]|166|17[0-8]|18[0-9]|19[8-9])[0-9]{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

//密码
+ (BOOL) validatePassword:(NSString *)passWord {
    NSString *passWordRegex = @"^(?![0-9]+$)(?![a-zA-Z]+$)[0-9A-Za-z]{8,16}$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
}


//车牌号验证
+ (BOOL) validateCarNo:(NSString *)carNo
{
    NSString *carRegex = @"^[\u4e00-\u9fa5]{1}[a-zA-Z]{1}[a-zA-Z_0-9]{4}[a-zA-Z_0-9_\u4e00-\u9fa5]$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    //NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}


//昵称
+ (BOOL) validateNickname:(NSString *)nickname {
    
    NSString *nicknameRegex = @"[\u4e00-\u9fa5a-zA-Z0-9]*";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",nicknameRegex];
    return [passWordPredicate evaluateWithObject:nickname];
}

//验证地址只能为 数字字母
+ (BOOL) validateAddress:(NSString *)address {
    address = [address stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *addressRegex = @"[a-zA-Z0-9]*";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",addressRegex];
    return [passWordPredicate evaluateWithObject:address];
}


//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard {
    BOOL flag;
    if (identityCard.length <= 0) {
        flag = NO;
        return flag;
    }
    NSString *regex2 = @"^(\\d{14}|\\d{17})(\\d|[xX])$";
    NSPredicate *identityCardPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex2];
    return [identityCardPredicate evaluateWithObject:identityCard];
}
//银行卡号
+ (BOOL) validateBankCard:(NSString *)cardNumber{
    if(cardNumber.length==0){
        return NO;
    }
    NSString *digitsOnly = @"";
    char c;
    for (int i = 0; i < cardNumber.length; i++){
        c = [cardNumber characterAtIndex:i];
        if (isdigit(c)){
            digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
        }
    }
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = false;
    for (NSInteger i = digitsOnly.length - 1; i >= 0; i--){
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo){
            addend = digit * 2;
            if (addend > 9) {
                addend -= 9;
            }
        }
        else {
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    int modulus = sum % 10;
    return modulus == 0;
}
//是否是纯数字资金密码
+ (BOOL)isNumText:(NSString *)str{
    NSString * regex  = @"[0-9]*";
    NSPredicate * pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch   = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}

//判断是数字值（包含小数）
+ (BOOL)isNumber:(NSString *)str {
    NSString * regex  = @"^(\\-|\\+)?\\d+(\\.\\d+)?$";
    NSPredicate * pred  = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch   = [pred evaluateWithObject:str];
    if (isMatch) {
        return YES;
    }else{
        return NO;
    }
}
//是否有数字和字母
+ (BOOL)isStringContainNumberWith:(NSString *)str {
    
    NSRegularExpression *numberRegular = [NSRegularExpression regularExpressionWithPattern:@"A-Za-z0-9]" options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSInteger count = [numberRegular numberOfMatchesInString:str options:NSMatchingReportProgress range:NSMakeRange(0, str.length)];
    
    //count是str中包含[A-Za-z0-9]数字的个数，只要count>0，说明str中包含数字
    
    if (count > 0) {
        
        return YES;
        
    }
    
    return NO;
    
}

+(BOOL)MatchLetter:(NSString *)str
{
    //判断是否以字母开头
    NSString *ZIMU = @"^[A-Za-z0-9]+$";
    NSPredicate *regextestA = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", ZIMU];
    
    if ([regextestA evaluateWithObject:str] == YES)
        return YES;
    else
        return NO;
}

+ (NSString *)formatNumberDecimalValue:(double)value {
    NSString * string = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble:value]
                                                         numberStyle:NSNumberFormatterDecimalStyle];
    return string;
}

+ (NSString *)formatNumberDecimalValue2:(NSString *)valueStr {
    NSNumberFormatter *moneyFormatter = [[NSNumberFormatter alloc] init];
    moneyFormatter.positiveFormat = @"###,##0.00";
    NSString *formatString = [moneyFormatter stringFromNumber:@([valueStr doubleValue])];
    return formatString;
}

/*
 返回加*的内容
 eg: 手机号 18620831185 == 186****185
 身份证 43849505050505050 == 43849505****050
 */
+ (NSString *)returnSafeStr:(NSString *)str
                 WithIndex1:(NSInteger)index1
                 withIndex2:(NSInteger)index2 {
    if (str.length >= index2 + 4) {
        str = [NSString stringWithFormat:@"%@****%@",[str substringToIndex:index1],[str substringFromIndex:index2]];
    }
    return str;
}


+ (BOOL)isUrl:(NSString *)urlStr {
    if(urlStr == nil)
        return NO;
    
    NSString *urlRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    
    NSPredicate* urlTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegex];
    
    return [urlTest evaluateWithObject:urlStr];
}

+ (BOOL)isSurePayPwd:(NSString *)password {
    //数字不是连续的
    NSString *regres = @"^(?:(\\d)(?!((?<=9)8|(?<=8)7|(?<=7)6|(?<=6)5|(?<=5)4|(?<=4)3|(?<=3)2|(?<=2)1|(?<=1)0){5})(?!\1{5})(?!((?<=0)1|(?<=1)2|(?<=2)3|(?<=3)4|(?<=4)5|(?<=5)6|(?<=6)7|(?<=7)8|(?<=8)9){5})){6}$";
    //数字不是重复的
    NSString *reg = @"^(?=.*\\d+)(?!.*?([\\d])\\1{5})[\\d]{6}$";
    NSPredicate* regresPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regres];
    NSPredicate* regPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", reg];
    if([regresPredicate evaluateWithObject:password] && [regresPredicate evaluateWithObject:regPredicate] ){
        return YES;
    }else{
        return  NO;
    }
}
//计算字符数
+ (int)convertToInt:(NSString*)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];i++) {
        if (*p) {
            p++;
            strlength++;
        }else {
            p++;
        }
    }
    return strlength;
}

/**
 * 字母、数字、中文
 */
+ (BOOL)isInputRuleAndNumber:(NSString *)str {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    unsigned long len=str.length;
    for(int i=0;i<len;i++)
    {
        unichar a=[str characterAtIndex:i];
        if(!((isalpha(a))
             ||(isalnum(a))
             ||((a >= 0x4e00 && a <= 0x9fa6))
             ||([other rangeOfString:str].location != NSNotFound)
             ) || (a == ','))
            return NO;
    }
    return YES;
}
/**
 * 字母、数字
 */
+ (BOOL)isEnglishAndNumber:(NSString *)str {
    NSString *other = @"➋➌➍➎➏➐➑➒";
    unsigned long len=str.length;
    for(int i=0;i<len;i++)
    {
        unichar a=[str characterAtIndex:i];
        if(!((isalpha(a))
             ||(isalnum(a))
             ||([other rangeOfString:str].location != NSNotFound)
             ) || (a == ','))
            return NO;
    }
    return YES;
}
/**
 *  过滤字符串中的emoji
 */
+ (BOOL)hasEmoji1:(NSString*)str {
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:str];
    return isMatch;
}
 
+ (NSString *)disable_emoji:(NSString *)text {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]"options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}


/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        
        const unichar hs = [substring characterAtIndex:0];
        // surrogate pair
        if (0xd800 <= hs && hs <= 0xdbff) {
            if (substring.length > 1) {
                const unichar ls = [substring characterAtIndex:1];
                const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                if (0x1d000 <= uc && uc <= 0x1f77f) {
                    returnValue = YES;
                }
            }
        } else if (substring.length > 1) {
            const unichar ls = [substring characterAtIndex:1];
            if (ls == 0x20e3) {
                returnValue = YES;
            }
            
        } else {
            // non surrogate
            if (0x2100 <= hs && hs <= 0x27ff) {
                returnValue = YES;
            } else if (0x2B05 <= hs && hs <= 0x2b07) {
                returnValue = YES;
            } else if (0x2934 <= hs && hs <= 0x2935) {
                returnValue = YES;
            } else if (0x3297 <= hs && hs <= 0x3299) {
                returnValue = YES;
            } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                returnValue = YES;
            }
        }
    }];
    
    return returnValue;
}


/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

/**
 判断是不是九宫格
 @param string  输入的字符
 @return YES(是九宫格拼音键盘)
 */
+(BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}

@end
