//
//  CSIISelectItemView.m
//  CSIIJSBridge
//
//  Created by 松 on 2021/9/15.
//

#import "CSIISelectItemView.h"
#import "GlobalMacro.h"

#define kDurationTime       0.25

@interface CSIISelectItemView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, strong) UIPickerView    *pickerView;
@property (nonatomic, copy) NSArray          *textArray;
@property (nonatomic, assign) CGFloat        dateHeight;
@property (nonatomic, strong) UIView         *contentV;

@property (nonatomic, assign) CGFloat        component; //列

@property (nonatomic, strong) NSMutableArray  *dataArray;

@end

@implementation CSIISelectItemView

static CGFloat kPickerRowHeight = 50;

- (instancetype)initWithTextArray:(NSArray *)array Title:(NSString *)title
{
    self = [super init];
    if (self) {
        
        self.textArray = array;
        self.component = self.textArray.count;
        self.dataArray = [NSMutableArray array];
        
        for (NSArray *arr in self.textArray) {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            
            if (arr.count > 0) {
                [dic setValue:arr[0] forKey:@"data"];
                [dic setValue:@"0" forKey:@"index"];
                [self.dataArray addObject:dic];
            }
        }
        
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
        UILabel *titleL = [[UILabel alloc] init];
        titleL.frame = CGRectMake(80, 0, contentV.width - 160, 60);
        titleL.text = @"选择日期";
        titleL.font = MyFont(18);
        titleL.textColor = HEXCOLOR(0x242424);
        titleL.textAlignment = 1;
        titleL.numberOfLines = 2;
        [upVeiw addSubview:titleL];
        
        //左边的取消按钮
        UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(0, 0, 60, 60);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:HEXCOLOR(0x242424) forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [upVeiw addSubview:cancelButton];
        
        //右边的确定按钮
        UIButton * chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
    
    }
    return self;
}
//返回列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return self.component;
}
//返回行数
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    NSArray *arr = self.textArray[component];
    return arr.count;
}
//行的文字
- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component{
    
    NSArray *arr = self.textArray[component];
    return arr[row][@"text"];
}
// 选择了某行
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.textArray[component][row] forKey:@"data"];
    [dic setValue:[NSString stringWithFormat:@"%ld",(long)row] forKey:@"index"];
    
    [self.dataArray replaceObjectAtIndex:component withObject:dic];
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return kPickerRowHeight;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textColor = HEXCOLOR(0x242424);
        [pickerLabel setFont:[UIFont systemFontOfSize:16]];
    }
    
    if (@available(iOS 14.0, *)){
    }else{
        [[pickerView.subviews objectAtIndex:1] setHidden:YES];
        [[pickerView.subviews objectAtIndex:2] setHidden:YES];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0,self.pickerView.height/2 - kPickerRowHeight/2, self.width, 1)];
        lineView1.backgroundColor = HEXCOLOR(0xF1F1F9);
        [pickerView addSubview:lineView1];
         
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0,self.pickerView.height/2 - kPickerRowHeight/2 + kPickerRowHeight, self.width, 1)];
        lineView2.backgroundColor = HEXCOLOR(0xF1F1F9);
        [pickerView addSubview:lineView2];
    }
    
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    pickerLabel.textAlignment = NSTextAlignmentCenter;
    return pickerLabel;
}
-(void)clickFinishButton{
    
    NSString *jsonStr = [CSIICheckObject dictionaryChangeJson:self.dataArray];
    if (_FinishClick) {
        _FinishClick(jsonStr);
    }
    [self hideDateTimePickerView];
}
#pragma mark -- show and hidden
- (void)showDateTimePickerView {
    
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 1;
        self.contentV.frame = CGRectMake(0, self.height - self.dateHeight, self.width, self.dateHeight);
    } completion:^(BOOL finished) {
    }];
}
- (void)hideDateTimePickerView {
    [UIView animateWithDuration:0.2f animations:^{
        self.alpha = 0;
        self.contentV.frame = CGRectMake(0, self.height, self.width, self.dateHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
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
    [self hideDateTimePickerView];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self hideDateTimePickerView];
}

@end
