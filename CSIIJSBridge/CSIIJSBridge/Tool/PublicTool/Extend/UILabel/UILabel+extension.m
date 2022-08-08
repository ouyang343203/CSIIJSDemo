//
//  UILabel+extension.m
//  Label
//
//  Created by 辛忠志 on 15/9/25.
//  Copyright (c) 2015年 X了个J. All rights reserved.
//

#import "UILabel+extension.h"
#import <CoreText/CoreText.h>

@implementation UILabel (extension)

- (void)setColumnSpace:(CGFloat)columnSpace
{
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    //调整间距
    [attributedString addAttribute:(__bridge NSString *)kCTKernAttributeName value:@(columnSpace) range:NSMakeRange(0, [attributedString length])];
    self.attributedText = attributedString;
}

- (void)setRowSpace:(CGFloat)rowSpace
{
    self.numberOfLines = 0;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    //调整行距
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = rowSpace;
    paragraphStyle.baseWritingDirection = NSWritingDirectionLeftToRight;
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [self.text length])];
    self.attributedText = attributedString;
}

+ (UILabel *)labelWithFrame:(CGRect)frame Text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor {
    return [self labelWithFrame:frame Text:text font:font textColor:textColor textAlignment:NSTextAlignmentLeft numberOfLines:1];
}

+ (UILabel *)labelWithFrame:(CGRect)frame Text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment {
    return [self labelWithFrame:frame Text:text font:font textColor:textColor textAlignment:textAlignment numberOfLines:1];
}

+ (UILabel *)labelWithFrame:(CGRect)frame Text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor textAlignment:(NSTextAlignment)textAlignment numberOfLines:(NSInteger)numberOfLines {
    UILabel *label = [[UILabel alloc] init];
    label.frame = frame;
    label.text = text;
    label.font = font;
    label.textColor = textColor;
    label.textAlignment = textAlignment;
    label.numberOfLines = numberOfLines;
    return label;
}
- (void)attributedWithFont:(UIFont *)font range:(NSRange)range {
    NSString *labelText = self.text;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    [attributedString setAttributes:@{NSFontAttributeName : font} range:range];
    
    [self setAttributedText:attributedString];
}

- (void)attributedWithTextColor:(UIColor *)textColor range:(NSRange)range {
    NSString *labelText = self.text;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    [attributedString setAttributes:@{NSForegroundColorAttributeName : textColor} range:range];
    
    [self setAttributedText:attributedString];
}

- (void)attributedWithFont:(UIFont *)font textColor:(UIColor *)textColor range:(NSRange)range {
    NSString *labelText = self.text;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
    [attributedString setAttributes:@{NSFontAttributeName : font, NSForegroundColorAttributeName : textColor} range:range];
    
    [self setAttributedText:attributedString];
}

+ (CGFloat)getHeightWithFrame:(CGRect)frame
                        title:(NSString *)title
                         font:(UIFont *)font {
    
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.font = font;
    label.numberOfLines = 0;
    [label sizeToFit];
    CGFloat height = label.frame.size.height;
    return ceil(height);
    
}

+ (CGFloat)getWidthWithFrame:(CGRect)frame
                   withTitle:(NSString *)title
                        font:(UIFont *)font {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.text = title;
    label.font = font;
    [label sizeToFit];
    CGFloat width = label.frame.size.width;
    if (width > frame.size.width) {
        return frame.size.width;
    }
    return ceil(width);
}

@end
