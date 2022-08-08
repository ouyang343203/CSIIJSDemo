//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"
#import "MBProgressHUD.h"

@interface MBProgressHUD (MJ)

+ (MBProgressHUD *)showMessage:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

//加载系统默认
+ (MBProgressHUD *)showTextAndImage:(NSString *)message view :(UIView *)view;



@end
