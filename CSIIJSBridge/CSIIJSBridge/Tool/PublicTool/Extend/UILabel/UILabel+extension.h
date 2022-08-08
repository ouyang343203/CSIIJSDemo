//
//  UILabel+extension.h
//  Label
//
//  Created by 辛忠志 on 15/9/25.
//  Copyright (c) 2015年 X了个J. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (extension)

/**
 *  设置字间距
 */
- (void)setColumnSpace:(CGFloat)columnSpace;
/**
 *  设置行距
 */
- (void)setRowSpace:(CGFloat)rowSpace;

/**
 *  创建label
*/
+ (UILabel *)labelWithFrame:(CGRect)frame Text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor;
+ (UILabel *)labelWithFrame:(CGRect)frame Text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment;
+ (UILabel *)labelWithFrame:(CGRect)frame Text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSInteger)numberOfLines;

/**
 *  设置label富文本
*/
- (void)attributedWithFont:(UIFont *)font range:(NSRange)range;
- (void)attributedWithTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)attributedWithFont:(UIFont *)font textColor:(UIColor *)textColor range:(NSRange)range;

//获取文本高度
+ (CGFloat)getHeightWithFrame:(CGRect)frame
                      title:(NSString *)title
                         font:(UIFont *)font;

//获取文本宽度
+ (CGFloat)getWidthWithFrame:(CGRect)frame
                   withTitle:(NSString *)title
                        font:(UIFont *)font;

@end
