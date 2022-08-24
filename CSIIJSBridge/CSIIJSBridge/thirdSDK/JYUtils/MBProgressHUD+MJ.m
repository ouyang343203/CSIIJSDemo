//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"
#import "GlobalMacro.h"

@implementation MBProgressHUD (MJ)

#pragma mark 显示加载动画
+ (MBProgressHUD *)showTextAndImage:(NSString *)message view :(UIView *)view {
    return [self showTextImage:message view:view];
   // return [self showLoading:view title:message];
}

+ (MBProgressHUD *)showTextImage:(NSString *)text view:(UIView *)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setY:hud.y-30];
    hud.label.text = text;
    hud.label.font = [UIFont systemFontOfSize:13];
    hud.backgroundColor = [UIColor clearColor];
    hud.mode = MBProgressHUDModeIndeterminate;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

#pragma mark 显示提示信息
+ (MBProgressHUD *)showMessage:(NSString *)message {
    return [self showMessage:message toView:nil];
}

+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setY:hud.y-30];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = HEXCOLOR(0x242424);
    hud.mode = MBProgressHUDModeText;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.label.textColor = [UIColor whiteColor];
    hud.tintColor =  [UIColor whiteColor];
    hud.label.text = message;
    hud.label.numberOfLines = 0;
    [hud.label setRowSpace:7];
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:1.5];
    return hud;
}

#pragma mark 显示成功和错误图标信息
+ (void)showSuccess:(NSString *)success {
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error {
    [self showError:error toView:nil];
}

+ (void)showError:(NSString *)error toView:(UIView *)view {
    [self show:error icon:@"error" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view {
    [self show:success icon:@"successs" view:view];
}

#pragma mark 显示带图片信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view {
    if (view == nil)
        view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud setY:hud.y-30];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = HEXCOLOR(0x242424);
    hud.mode = MBProgressHUDModeText;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.label.numberOfLines = 0;
    [hud.label setRowSpace:7];
    hud.label.textColor = [UIColor whiteColor];
    hud.tintColor =  [UIColor whiteColor];
    hud.label.text = text;
    /*
     // 设置图片
     hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
     // 再设置模式
     hud.mode = MBProgressHUDModeCustomView;
     */
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 0.7秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

+ (void)hideHUDForView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD {
    [self hideHUDForView:nil];
}

@end
