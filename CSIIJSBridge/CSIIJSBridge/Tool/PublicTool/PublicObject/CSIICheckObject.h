//
//  CSIICheckObject.h
//  CSIIJSBridge
//
//  Created by Song on 2021/9/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSIICheckObject : NSObject

//距离公里/米 高于999米 显示公里
+ (NSString *)returnSureDistance:(double)distance;
//判断是不是汉字
+ (BOOL)isChinese:(NSString *)str;
//字典、数组转换为 json字符串
+ (NSString *)dictionaryChangeJson:(id )dictionary;
//json字符串换为字典、数组
+ (id)jsontoObject:(NSString *)jsonStr;
#pragma mark - 通过汉字获取该汉字的拼音
+ (NSString *)pinyinTransformByChinese:(NSString *)chinese;
//手机号脱敏
+ (NSString *)returnPwdPhone:(NSString *)phone;
//邮箱验证
+ (BOOL) validateEmail:(NSString *)email;
//手机号码验证1
+ (BOOL) validateMobile1:(NSString *)mobile;
//手机号码验证2
+ (BOOL) validateMobile2:(NSString *)mobile;
//密码
+ (BOOL) validatePassword:(NSString *)passWord;
//身份证号
+ (BOOL) validateIdentityCard: (NSString *)identityCard;
//银行卡号
+ (BOOL) validateBankCard:(NSString *)cardNumber;
//验证是否是纯数字
+ (BOOL)isNumText:(NSString *)str;

//判断是数字值（包含小数）
+ (BOOL)isNumber:(NSString *)str;

+ (BOOL) validateNickname:(NSString *)nickname;

//验证地址只能为 数字字母
+ (BOOL) validateAddress:(NSString *)address;

//是否有数字和字母
+ (BOOL)isStringContainNumberWith:(NSString *)str;

//必须为整数
//+ (BOOL)isPureInt:(NSString*)string;

+(BOOL)MatchLetter:(NSString *)str;

//用，号分割金额
+ (NSString *)formatNumberDecimalValue:(double)value;

+ (NSString *)formatNumberDecimalValue2:(NSString *)valueStr;
/*
 返回加*的内容
 eg: 手机号 18620831185 == 186****185
 身份证 43849505050505050 == 43849505****050
 */
+ (NSString *)returnSafeStr:(NSString *)str
                 WithIndex1:(NSInteger)index1
                 withIndex2:(NSInteger)index2;

+ (BOOL)isUrl:(NSString *)urlStr;

+ (BOOL)isSurePayPwd:(NSString *)password;

//计算字符数
+ (int)convertToInt:(NSString*)strtemp;

/**
 * 字母、数字、中文
 */
+ (BOOL)isInputRuleAndNumber:(NSString *)str;

/**
 * 字母、数字
 */
+ (BOOL)isEnglishAndNumber:(NSString *)str;
/**
 *  过滤字符串中的emoji
 */
+ (BOOL)hasEmoji1:(NSString*)str;

+ (NSString *)disable_emoji:(NSString *)text;

/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)stringContainsEmoji:(NSString *)string;

/**
 *  判断字符串中是否存在emoji
 * @param string 字符串
 * @return YES(含有表情)
 */
+ (BOOL)hasEmoji:(NSString*)string;

/**
 判断是不是九宫格
 @param string  输入的字符
 @return YES(是九宫格拼音键盘)
 */
+(BOOL)isNineKeyBoard:(NSString *)string;
//根据目标自负获取特定的字符串
+(NSString*)substringToString:(NSString*)original withTarget:(NSString*)target;

@end

NS_ASSUME_NONNULL_END
