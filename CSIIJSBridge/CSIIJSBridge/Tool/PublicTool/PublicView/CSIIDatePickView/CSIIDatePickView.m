//
//  CSIIDatePickView.m
//  CSIIJSBridge
//
//  Created by 松 on 2021/9/15.
//

#import "CSIIDatePickView.h"
#import "GlobalMacro.h"

@interface CSIIDatePickView()<UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSInteger yearRange;
    NSInteger dayRange;
    NSInteger startYear;
    NSInteger selectedYear;
    NSInteger selectedMonth;
    NSInteger selectedDay;
    NSInteger selectedHour;
    NSInteger selectedMinute;
    NSInteger selectedSecond;
    NSCalendar *calendar;
    //左边退出按钮
    UIButton *cancelButton;
    //右边的确定按钮
    UIButton *chooseButton;
}

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) UIView *contentV;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) CGFloat dateHeight;
@property (nonatomic, assign) NSInteger row1;
@property (nonatomic, assign) NSInteger row2;
@property (nonatomic, assign)BOOL  isCurrentDateMax;//是否当前时间最大

@end

@implementation CSIIDatePickView

- (instancetype)initIsCurrentDateMax:(BOOL)isCurrentDateMax{
    self = [super init];
    if (self) {
        self.isCurrentDateMax = isCurrentDateMax;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.65];
        self.frame = CGRectMake(0, 0, KScreenWidth, KScreenHeight);
        self.alpha = 0;
        self.dateHeight = 280 + kTabBarBottomHeight;
        UIView *contentV = [[UIView alloc] initWithFrame:CGRectMake(0, self.height, self.width, self.dateHeight)];
        contentV.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentV];
        self.contentV = contentV;
        
        //盛放按钮的View
        UIView *upVeiw = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 60)];
        [contentV addSubview:upVeiw];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, upVeiw.height-1, upVeiw.width, 1)];
        line.backgroundColor = HEXCOLOR(0xF1F1F9);
        [upVeiw addSubview:line];
        
        //标题
        self.titleL = [[UILabel alloc] init];
        self.titleL.frame = CGRectMake(80, 0, contentV.width - 160, 60);
        self.titleL.text = @"选择日期";
        self.titleL.font = MyFont(18);
        self.titleL.textColor = HEXCOLOR(0x242424);
        self.titleL.textAlignment = 1;
        self.titleL.numberOfLines = 2;
        [upVeiw addSubview:self.titleL];
        
        //左边的取消按钮
        cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, 60, 60);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:HEXCOLOR(0x242424) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [upVeiw addSubview:cancelButton];
        
        //右边的确定按钮
        chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        chooseButton.frame = CGRectMake(contentV.width-60, 0, 60, 60);
        [chooseButton setTitleColor:HEXCOLOR(0xE64345) forState:UIControlStateNormal];
        [chooseButton setTitle:@"完成" forState:UIControlStateNormal];
        [chooseButton addTarget:self action:@selector(configButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [upVeiw addSubview:chooseButton];
       
        //时间选择器
        self.pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, upVeiw.bottom, [UIScreen mainScreen].bounds.size.width, self.dateHeight - upVeiw.height)];
        self.pickerView.backgroundColor = [UIColor whiteColor];
        self.pickerView.dataSource=self;
        self.pickerView.delegate=self;
        [contentV addSubview:self.pickerView];
        //时间数据
        NSCalendar *calendar0 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        NSInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
        comps = [calendar0 components:unitFlags fromDate:[NSDate date]];
        NSInteger year=[comps year];
        startYear = year - 99;
        
        if (isCurrentDateMax) {
            yearRange = 100;
        }else{
            yearRange = 200;
        }
        [self setCurrentDate:[NSDate date]];
        
    }
    return self;
}


#pragma mark -- UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinuteSecond) {
        return 6;
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinute) {
        return 5;
    }else if (self.pickerViewMode == DatePickerViewDateYearMonthDay){
        return 3;
    }else if (self.pickerViewMode == DatePickerViewDateYearMonth) {
        return 2;
    } else if (self.pickerViewMode == DatePickerViewDateHourMinute) {
        return 2;
    } else if (self.pickerViewMode == DatePickerViewDateYear) {
        return 1;
    }
    return 0;
}


//确定每一列返回的东西
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinuteSecond) {
        switch (component) {
            case 0:
            {
                return yearRange;
            }
                break;
            case 1:
            {
                return 12;
            }
                break;
            case 2:
            {
                return dayRange;
            }
                break;
            case 3:
            {
                return 24;
            }
                break;
            case 4:
            {
                return 60;
            }
                break;
            case 5:
            {
                return 60;
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinute) {
        switch (component) {
            case 0:
            {
                return yearRange;
            }
                break;
            case 1:
            {
                return 12;
            }
                break;
            case 2:
            {
                return dayRange;
            }
                break;
            case 3:
            {
                return 24;
            }
                break;
            case 4:
            {
                return 60;
            }
                break;
                
            default:
                break;
        }
    }else if (self.pickerViewMode == DatePickerViewDateYearMonthDay){
        switch (component) {
            case 0:
            {
                return yearRange;
            }
                break;
            case 1:
            {
                if (self.isCurrentDateMax) {
                    
                    if (self.row1 == (yearRange-1)) {
                        return [[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] integerValue];
                    }
                    
                    return 12;
                }
                return 12;
            }
                break;
            case 2:
            {
                return dayRange;
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateYearMonth) {
        switch (component) {
            case 0:
            {
                return yearRange;
            }
                break;
            case 1:
            {
                if (self.isCurrentDateMax) {
                    
                    if (self.row1 == (yearRange-1)) {
                        return [[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] integerValue];
                    }

                    return 12;
                }
                return 12;
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateHourMinute){
        switch (component) {
            case 0:
            {
                return 24;
            }
                break;
            case 1:
            {
                return 60;
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateYear) {
        switch (component) {
            case 0:
                return yearRange;
                break;
                
            default:
                break;
        }
    }
    return 0;
}

#pragma mark -- UIPickerViewDelegate
// 默认时间的处理
- (void)setCurrentDate:(NSDate *)currentDate
{
    //获取当前时间
    NSCalendar *calendar0 = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags =  NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    comps = [calendar0 components:unitFlags fromDate:currentDate];
    NSInteger year = [comps year];
    NSInteger month = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger minute = [comps minute];
    NSInteger second = [comps second];
    
    selectedYear = year;
    selectedMonth = month;
    selectedDay = day;
    selectedHour = hour;
    selectedMinute = minute;
    selectedSecond = second;
    
    dayRange = [self isAllDay:year andMonth:month];
    if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinuteSecond) {
        [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
        [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
        [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
        [self.pickerView selectRow:hour inComponent:3 animated:NO];
        [self.pickerView selectRow:minute inComponent:4 animated:NO];
        [self.pickerView selectRow:second inComponent:5 animated:NO];
        
        [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
        [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
        [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
        [self pickerView:self.pickerView didSelectRow:hour inComponent:3];
        [self pickerView:self.pickerView didSelectRow:minute inComponent:4];
        [self pickerView:self.pickerView didSelectRow:second inComponent:5];
        
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinute) {
        [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
        [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
        [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
        [self.pickerView selectRow:hour inComponent:3 animated:NO];
        [self.pickerView selectRow:minute inComponent:4 animated:NO];
        
        [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
        [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
        [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
        [self pickerView:self.pickerView didSelectRow:hour inComponent:3];
        [self pickerView:self.pickerView didSelectRow:minute inComponent:4];
        
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDay){
        [self.pickerView selectRow:year-startYear inComponent:0 animated:NO];
        [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
        [self.pickerView selectRow:day-1 inComponent:2 animated:NO];
        
        [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
        [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
        [self pickerView:self.pickerView didSelectRow:day-1 inComponent:2];
    } else if (self.pickerViewMode == DatePickerViewDateYearMonth) {
        [self.pickerView selectRow:year - startYear inComponent:0 animated:NO];
        [self.pickerView selectRow:month-1 inComponent:1 animated:NO];
        
        [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
        [self pickerView:self.pickerView didSelectRow:month-1 inComponent:1];
    }   else if (self.pickerViewMode == DatePickerViewDateHourMinute) {
        [self.pickerView selectRow:hour inComponent:0 animated:NO];
        [self.pickerView selectRow:minute inComponent:1 animated:NO];
        
        [self pickerView:self.pickerView didSelectRow:hour inComponent:0];
        [self pickerView:self.pickerView didSelectRow:minute inComponent:1];
    } else if (self.pickerViewMode == DatePickerViewDateYear) {
        [self.pickerView selectRow:year - startYear inComponent:0 animated:NO];
        [self pickerView:self.pickerView didSelectRow:year-startYear inComponent:0];
    }
    [self.pickerView reloadAllComponents];
}


- (UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel*label=[[UILabel alloc]initWithFrame:CGRectMake(self.width*component/6.0, 0,self.width/6.0, 47)];
    label.font= MyFont(15);
    label.textColor = HEXCOLOR(0x242424);
    label.tag=component*100+row;
    label.textAlignment=NSTextAlignmentCenter;
    if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinuteSecond) {
        switch (component) {
            case 0:
            {
                label.text=[NSString stringWithFormat:@"%ld",(long)(startYear + row)];
            }
                break;
            case 1:
            {
                label.text=[NSString stringWithFormat:@"%ld",(long)row+1];
            }
                break;
            case 2:
            {
                
                label.text=[NSString stringWithFormat:@"%ld",(long)row+1];
            }
                break;
            case 3:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
            case 4:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
            case 5:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinute) {
        switch (component) {
            case 0:
            {
                label.text=[NSString stringWithFormat:@"%ld",(long)(startYear + row)];
            }
                break;
            case 1:
            {
                label.text=[NSString stringWithFormat:@"%ld",(long)row+1];
            }
                break;
            case 2:
            {
                
                label.text=[NSString stringWithFormat:@"%ld",(long)row+1];
            }
                break;
            case 3:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
            case 4:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
            case 5:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
                
            default:
                break;
        }
    }else if (self.pickerViewMode == DatePickerViewDateYearMonthDay){
        switch (component) {
            case 0:
            {
                label.text=[NSString stringWithFormat:@"%ld",(long)(startYear + row)];
            }
                break;
            case 1:
            {
                label.text=[NSString stringWithFormat:@"%.2ld",(long)row+1];
            }
                break;
            case 2:
            {
                label.text=[NSString stringWithFormat:@"%.2ld",(long)row+1];
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateYearMonth) {
        switch (component) {
            case 0:
            {
                label.text=[NSString stringWithFormat:@"%ld",(long)(startYear + row)];
            }
                break;
            case 1:
            {
                label.text=[NSString stringWithFormat:@"%.2ld",(long)row+1];
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateHourMinute){
        switch (component) {
            case 0:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
            case 1:
            {
                label.textAlignment=NSTextAlignmentRight;
                label.text=[NSString stringWithFormat:@"%ld",(long)row];
            }
                break;
                
            default:
                break;
        }
    } else if (self.pickerViewMode == DatePickerViewDateYear) {
        switch (component) {
            case 0:
                label.text = [NSString stringWithFormat:@"%ld",(long)(startYear + row)];
                break;
                
            default:
                break;
        }
    }
    
    return label;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinuteSecond) {
        return ([UIScreen mainScreen].bounds.size.width-40)/6;
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinute) {
        return ([UIScreen mainScreen].bounds.size.width-40)/5;
    }else if (self.pickerViewMode == DatePickerViewDateYearMonthDay){
        return ([UIScreen mainScreen].bounds.size.width-40)/3;
    } else if (self.pickerViewMode == DatePickerViewDateYearMonth) {
        return ([UIScreen mainScreen].bounds.size.width-40)/2;
    } else if (self.pickerViewMode == DatePickerViewDateHourMinute){
        return ([UIScreen mainScreen].bounds.size.width-40)/2;
    } else if (self.pickerViewMode == DatePickerViewDateYear) {
        return [UIScreen mainScreen].bounds.size.width - 40;
    }
    return 0;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 47;
}
// 监听picker的滑动
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if (component == 0) {
        self.row1 = row;
        [self.pickerView reloadAllComponents];
    }else if (component == 1){
        self.row2 = row;
        [self.pickerView reloadAllComponents];
    }
    
    if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinuteSecond) {
        switch (component) {
            case 0:
            {
                selectedYear=startYear + row;
                dayRange = [self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:2];
            }
                break;
            case 1:
            {
                selectedMonth = row+1;
                dayRange = [self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:2];
            }
                break;
            case 2:
            {
                selectedDay=row+1;
            }
                break;
            case 3:
            {
                selectedHour=row;
            }
                break;
            case 4:
            {
                selectedMinute=row;
            }
                break;
            case 5:
            {
                selectedSecond = row;
            }
                break;
                
            default:
                break;
        }
        _string =[NSString stringWithFormat:@"%ld-%.2ld/%.2ld",(long)selectedYear,(long)selectedMonth,(long)selectedDay];
       // _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld:%.2ld",selectedYear,selectedMonth,selectedDay,selectedHour,selectedMinute,selectedSecond];
    } else if (self.pickerViewMode == DatePickerViewDateYearMonthDayHourMinute) {
        switch (component) {
            case 0:
            {
                selectedYear=startYear + row;
                dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:2];
            }
                break;
            case 1:
            {
                selectedMonth=row+1;
                dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:2];
            }
                break;
            case 2:
            {
                selectedDay=row+1;
            }
                break;
            case 3:
            {
                selectedHour=row;
            }
                break;
            case 4:
            {
                selectedMinute=row;
            }
                break;
                
            default:
                break;
        }
        
        _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld %.2ld:%.2ld",selectedYear,selectedMonth,selectedDay,selectedHour,selectedMinute];
    }else if (self.pickerViewMode == DatePickerViewDateYearMonthDay){
        switch (component) {
            case 0:
            {
                selectedYear=startYear + row;
                
                if (self.isCurrentDateMax && (row ==  yearRange - 1) && (selectedMonth > [[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] integerValue])) {
                    selectedMonth = [[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] integerValue];
                    selectedDay = [[CSIIDateHandle returnCurrentimeStrWithFormat:@"d"] integerValue];
                    self.row2 = selectedMonth - 1;
                }
                
                dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:2];
            }
                break;
            case 1:
            {
                selectedMonth=row+1;
                dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:2];
                if (self.isCurrentDateMax && (row ==  selectedMonth - 1) && (selectedDay > [[CSIIDateHandle returnCurrentimeStrWithFormat:@"d"] integerValue])) {
                    selectedDay = [[CSIIDateHandle returnCurrentimeStrWithFormat:@"d"] integerValue];
                }
                
                
            }
                break;
            case 2:
            {
                selectedDay=row+1;
            }
                break;
                
            default:
                break;
        }
        
        _string =[NSString stringWithFormat:@"%ld-%.2ld-%.2ld",selectedYear,selectedMonth,selectedDay];
    } else if (self.pickerViewMode == DatePickerViewDateYearMonth) {
        switch (component) {
            case 0:
            {
                selectedYear = startYear + row;
                
                if (self.isCurrentDateMax && (row ==  yearRange - 1) && (selectedMonth > [[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] integerValue])) {
                    selectedMonth = [[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] integerValue];
                }
                
                dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:0];
                [self.pickerView reloadComponent:1];
            }
                break;
            case 1:
            {
                selectedMonth = row + 1;
                
                dayRange=[self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:1];
            }
                break;
                
            default:
                break;
        }
        _string =[NSString stringWithFormat:@"%ld-%.2ld",selectedYear,selectedMonth];
    } else if (self.pickerViewMode == DatePickerViewDateHourMinute) {
        switch (component) {
            case 0:
            {
                selectedHour=row;
            }
                break;
            case 1:
            {
                selectedMinute=row;
            }
                break;
                
            default:
                break;
        }
        
        _string =[NSString stringWithFormat:@"%.2ld:%.2ld",selectedHour,selectedMinute];
    } else if (self.pickerViewMode == DatePickerViewDateYear) {
        switch (component) {
            case 0:
                selectedYear = startYear + row;
                dayRange = [self isAllDay:selectedYear andMonth:selectedMonth];
                [self.pickerView reloadComponent:0];
                break;
                
            default:
                break;
        }
        _string = [NSString stringWithFormat:@"%ld", selectedYear];
    }
}
#pragma mark -- show and hidden
- (void)showDateTimePickerView {
    [self setCurrentDate:[NSDate date]];
//    self.frame = CGRectMake(0, 0, self.width, self.height);
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        self->_contentV.frame = CGRectMake(0, self.height - self.dateHeight, self.width, self.dateHeight);
    } completion:^(BOOL finished) {
    }];
}
- (void)hideDateTimePickerView {
    
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0;
        self->_contentV.frame = CGRectMake(0, self.height, self.width, self.dateHeight);
    } completion:^(BOOL finished) {
        self.frame = CGRectMake(0, self.height, self.width, self.height);
    }];
}
#pragma mark - private
// 取消的隐藏
- (void)cancelButtonClick
{
    [self hideDateTimePickerView];
}

//确认的隐藏
- (void)configButtonClick
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didClickFinishDateTimePickerView:)]) {
        [self.delegate didClickFinishDateTimePickerView:_string];
    }
    [self hideDateTimePickerView];
}

- (NSInteger)isAllDay:(NSInteger)year andMonth:(NSInteger)month
{
    int day=0;
    switch(month)
    {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            day=31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            day=30;
            break;
        case 2:
        {
            if(((year%4==0)&&(year%100!=0))||(year%400==0))
            {
                day=29;
                break;
            }
            else
            {
                day=28;
                break;
            }
        }
        default:
            break;
    }
    if (self.isCurrentDateMax && (self.row1 ==  yearRange - 1)  && ([[CSIIDateHandle returnCurrentimeStrWithFormat:@"M"] intValue] == month)) {
        day = [[CSIIDateHandle returnCurrentimeStrWithFormat:@"d"] intValue];
    }
    return day;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideDateTimePickerView];
}


@end
