//
//  CSIIDatePickView.h
//  CSIIJSBridge
//
//  Created by 松 on 2021/9/15.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    DatePickerViewDateYearMonthDayHourMinuteSecond, // 年月日,时分秒
    DatePickerViewDateYearMonthDayHourMinute,//年月日,时分 DatePickerViewDateTimeMode
    DatePickerViewDateYearMonthDay, //年月日 DatePickerViewDateMode
    DatePickerViewDateYearMonth, // 年月
    DatePickerViewDateHourMinute, // 时分
    DatePickerViewDateYear  // 年
} DatePickerViewMode;

@protocol DateTimePickerViewDelegate <NSObject>

@optional
/**
 * 确定按钮
 */
- (void)didClickFinishDateTimePickerView:(NSString*)date;

@end


@interface CSIIDatePickView : UIView

- (instancetype)initIsCurrentDateMax:(BOOL)isCurrentDateMax;

/**
 * 设置当前时间
 */
@property(nonatomic, strong) NSDate *currentDate;

/**
 * 设置中心标题文字
 */
@property(nonatomic, strong)UILabel *titleL;

@property(nonatomic, strong)id<DateTimePickerViewDelegate>delegate;
/**
 * 模式
 */
@property (nonatomic, assign) DatePickerViewMode pickerViewMode;

/**
 * 显示
 */
- (void)showDateTimePickerView;



@end


