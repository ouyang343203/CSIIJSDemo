//
//  progressLineView.m
//  CsiiMobileFinance
//
//  Created by 徐迪华 on 2018/11/15.
//  Copyright © 2018年 Shen Yu. All rights reserved.
//

#import "progressLineView.h"
#import "GlobalMacro.h"

@implementation progressLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.backgroundColor = lineColor;
}
//开始加载
-(void)startLoadingAnimation{
    
    self.hidden = NO;
    self.width = 0;
    
    [UIView animateWithDuration:0.4 animations:^{
        self.width = KScreenWidth * 0.6;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            self.width = KScreenWidth * 0.8;
        }];
        
    }];
}
//结束加载
-(void)endLoadingAnimation{
    [UIView animateWithDuration:0.4 animations:^{
        self.width = KScreenWidth;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }];
}
@end
