//
//  progressLineView.h
//  CsiiMobileFinance
//
//  Created by 徐迪华 on 2018/11/15.
//  Copyright © 2018年 Shen Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface progressLineView : UIView
//进度条颜色
@property (nonatomic,strong) UIColor  *lineColor;

//开始加载
-(void)startLoadingAnimation;

//结束加载
-(void)endLoadingAnimation;
@end

NS_ASSUME_NONNULL_END
