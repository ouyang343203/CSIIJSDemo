//
//  ATDateHandle.h
//  wallet
//
//  Created by Song on 2021/9/15.
//  Copyright © 2021年 Song. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSIIDateHandle : NSObject
+ (NSString *)returnCurrentDayStr;
//获取当前的时间
+(NSString*)getCurrentTimes;
//获取当前时间戳 方法2 （以秒为单位）
+(NSString *)getNowTimeTimestamp2;
//获取当前时间戳 （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3;

//返回钱包创建时间
+ (NSString *)returnCreatimeStr;

+ (NSString *)returnCreatimeStr:(NSString *)timeStr;

+ (NSString *)returnCurrentimeStr;

+ (NSString *)returnCurrentimeStrWithFormat:(NSString *)format;

//获取当前时间戳(以毫秒为单位)
+(NSString *)getNowTimeTimestamp;

//判断时间相隔多少秒了，需要刷新否
#pragma mark - 时间戳(单位:ms)转时间 "yyyy-MM-dd HH:mm:ss" accurate:是否精确到秒
+ (NSString* )getTimeByTimestamp:(NSString* )timespan formatter:(NSDateFormatter *)formatter accurateSecond:(BOOL)accurate;

#pragma mark - 将某个时间转化成 时间戳
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format;

+ (NSString *)timesTampReturnTime:(NSString *)timeSp;

//计算两个时间的差值  **时**分**秒
+ (NSDateComponents *)insertStarTime:(NSDate *)date1 andInsertEndTime:(NSDate *)date2 ;

//计算两个时间的差值  间隔
+ (NSInteger)timeForStarTime:(NSDate *)starTime andEndTime:(NSDate *)endTime;
//比较两个日期的大小 1:secondDay>oneDay   -1:econdDay<oneDay 0:secondDay=oneDay
+ (int)compareOneDay:(NSString *)oneDay withSecondDay:(NSString *)secondDay;
// 从NSString类型转化为NSDate类型
+ (NSDate *)dateString:(NSString *)dateString withFormatString:(NSString *)formateString;
// 从NSDate类型转化为NSString类型
+ (NSString *)stringDate:(NSDate *)date withFormatString:(NSString *)formateString;

+ (NSString *)returnSureTime:(NSString *)timeStr;

//获取n天前或后的日期
+ (NSString *)getDateWithday:(NSInteger)day;

@end
