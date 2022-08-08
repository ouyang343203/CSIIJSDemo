//
//  UIView+Extension.h
//  SYWeiBo
//
//  Created by Shen Yu on 15/10/10.
//  Copyright © 2015年 Shen Yu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
/**
 * 结构体属性frame.origin.x
 * oc语法规定，不能直接修改对象的结构体属性的成员，只能直接赋值结构体属性
 */
@property (nonatomic,assign) CGFloat x;
/**
 *  构体属性frame.origin.y
 */
@property (nonatomic,assign) CGFloat y;

/**
 *  构体属性view.center.x
 */
@property (nonatomic,assign) CGFloat centerX;
/**
 *  构体属性view.center.y
 */
@property (nonatomic,assign) CGFloat centerY;




/**
 *  构体属性frame.size.height
 */
@property (nonatomic,assign) CGFloat height;
/**
 *  构体属性frame.size.width
 */
@property (nonatomic,assign) CGFloat width;
/**
 *  结构体属性frame.size
 *
 */
@property (nonatomic,assign) CGSize size;
@property (nonatomic,assign) CGPoint origin;

@property (nonatomic) CGFloat left;
@property (nonatomic) CGFloat top;
@property (nonatomic) CGFloat right;
@property (nonatomic) CGFloat bottom;

@end
