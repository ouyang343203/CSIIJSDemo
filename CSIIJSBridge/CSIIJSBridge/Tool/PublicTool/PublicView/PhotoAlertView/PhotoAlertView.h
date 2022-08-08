//
//  PhotoAlertView.h
//  wallet
//
//  Created by Song on 2021/9/14.
//  Copyright © 2021年 atkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol  ATAlertDelegate <NSObject>

@optional
- (void)backwithImage:(UIImage *)image
        withImageData:(NSData *)data;

@end

@interface PhotoAlertView : UIView
@property (nonatomic, weak)id <ATAlertDelegate> photoDelegate;

//可供选择
- (void)showAlertViewWithIsEdit:(BOOL)isEdit;

//只需要相机
- (void)checkCamera;

//只需要相册
- (void)checkPhotoLibrary;

+ (CGSize)returnImageSizeWithImage:(UIImage *)image withStandSize:(CGSize)standSize;

//通过视频URL或者filePath 获取第一帧图片
+ (UIImage*)getThumbnailImage:(NSString*)videoURL;

@end
