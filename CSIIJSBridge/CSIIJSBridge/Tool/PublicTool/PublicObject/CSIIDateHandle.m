//
//  ATDateHandle.h
//  wallet
//
//  Created by Song on 2021/9/15.
//  Copyright © 2021年 Song. All rights reserved.
//

#import "CSIIDateHandle.h"

@implementation CSIIDateHandle

+ (NSString *)returnCreatimeStr {
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString *)returnCreatimeStr:(NSString *)timeStr {
    if (timeStr) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
        NSDate *timeDate = [dateFormatter dateFromString:timeStr];
        NSString *strDate = [dateFormatter stringFromDate:timeDate];
        return strDate;
    } else {
        NSDate *date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        NSString *strDate = [dateFormatter stringFromDate:date];
        return strDate;
    }
}


+ (NSString *)returnCurrentDayStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];// 修改下面提到的北京时间的日期格式
    [formatter setTimeStyle:NSDateFormatterFullStyle];// 修改下面提到的北京时间的时间格式
    [formatter setDateFormat:@"YYYY-MM-dd"];//
    NSDate *datenow = [NSDate date];
    // NSString *dateString = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    NSString *nowtimeStr = [formatter stringFromDate:datenow];
    // 这个时间是北京时间
    return nowtimeStr;
}

+ (NSString *)returnCurrentimeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterFullStyle];// 修改下面提到的北京时间的日期格式
    [formatter setTimeStyle:NSDateFormatterFullStyle];// 修改下面提到的北京时间的时间格式
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];//
    NSDate *datenow = [NSDate date];
    // NSString *dateString = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    NSString *nowtimeStr = [formatter stringFromDate:datenow];
    // 这个时间是北京时间
    return nowtimeStr;
}

+ (NSString *)returnCurrentimeStrWithFormat:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *datenow = [NSDate date];
    NSString *nowtimeStr = [formatter stringFromDate:datenow];
    // 这个时间是北京时间
    return nowtimeStr;
}

#pragma mark - 时间戳(单位:ms)转时间 "yyyy-MM-dd HH:mm:ss"
+ (NSString* )getTimeByTimestamp:(NSString* )timespan formatter:(NSDateFormatter *)formatter accurateSecond:(BOOL)accurate {
    if (timespan.length > 10) {
        timespan = [timespan substringToIndex:timespan.length - 3];
    }
    if (formatter) {
        NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[timespan integerValue]];
        NSString* time = [formatter stringFromDate:createDate];
        //    CHLog(@"timespan-- %@",timespan);
        return time;
    } else {
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        NSDate *createDate = [NSDate dateWithTimeIntervalSince1970:[timespan integerValue]];
        fmt.dateFormat = accurate ? @"MM-dd HH:mm" : @"M.dd yyyy HH:ss";
        NSString* time = [fmt stringFromDate:createDate];
        //    CHLog(@"timespan-- %@",timespan);
        return time;
    }
}

#pragma mark - 将某个时间转化成 时间戳
+(NSInteger)timeSwitchTimestamp:(NSString *)formatTime andFormatter:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    //时间转时间戳的方法:
    
    NSInteger timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] integerValue];
    //NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp); //时间戳的值
    return timeSp;
}

+ (NSString *)timesTampReturnTime:(NSString *)timeSp {
    if (timeSp.length > 10)
        timeSp = [timeSp substringToIndex:10];
    
    NSTimeInterval interval = [timeSp doubleValue];
    NSDate *date               = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString       = [formatter stringFromDate: date];
    return dateString;
}

+ (NSDateComponents *)insertStarTime:(NSDate *)date1 andInsertEndTime:(NSDate *)date2 {
    // 1.将时间转换为date
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval1 = [zone secondsFromGMTForDate:date1];
    date1 = [date1  dateByAddingTimeInterval:interval1];
    NSInteger interval2 = [zone secondsFromGMTForDate:date2];
    date2 = [date2  dateByAddingTimeInterval:interval2];
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    return cmps;  //返回是不是30分钟后
}
//计算两个时间的差值  间隔
+ (NSInteger)timeForStarTime:(NSDate *)starTime andEndTime:(NSDate *)endTime{ 
    NSTimeInterval time = [endTime timeIntervalSinceDate:starTime];
    NSInteger interval = round(time);
    return interval;
}
+ (int)compareOneDay:(NSString *)oneDay withSecondDay:(NSString *)secondDay
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    NSDate *dateA = [dateFormatter dateFromString:oneDay];
    NSDate *dateB = [dateFormatter dateFromString:secondDay];
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedDescending) {
        //oneDay 大
        return 1;
    }
    else if (result == NSOrderedAscending){
        //secondDay 大
        return -1;
    }
    //一样大
    return 0;
}
// 从NSString类型转化为NSDate类型
+ (NSDate *)dateString:(NSString *)dateString withFormatString:(NSString *)formateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formateString];
//    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}
// 从NSDate类型转化为NSString类型
+ (NSString *)stringDate:(NSDate *)date withFormatString:(NSString *)formateString{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formateString];
    NSString *string = [dateFormatter stringFromDate:date];
    return string;
}

//获取当前的时间
+(NSString*)getCurrentTimes{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];
    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    NSLog(@"currentTimeString =  %@",currentTimeString);
    return currentTimeString;
}

//获取当前时间戳 方法1（以秒为单位）
+(NSString *)getNowTimeTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeSp;
}

//获取当前时间戳 方法2 （以秒为单位）
+(NSString *)getNowTimeTimestamp2 {
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

//获取当前时间戳  （以毫秒为单位）
+(NSString *)getNowTimeTimestamp3 {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    return timeSp;
}

+ (NSString *)returnSureTime:(NSString *)timeStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    NSDate *date = [dateFormatter dateFromString:timeStr];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    //设置时区,这个对于时间的处理有时很重要
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter  setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    return  [formatter stringFromDate:date];
    
}
+ (NSString *)getDateWithday:(NSInteger)day {
    
    NSDate *currentDate = [NSDate date];
    NSTimeInterval days = 24 * 60 * 60 * day;  //一天一共有多少秒
    NSDate *appointDate = [currentDate dateByAddingTimeInterval:days];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:appointDate];
    return strDate;
}
@end
