//
//  PhotoAlertView.h
//  wallet
//
//  Created by Song on 2021/9/14.
//  Copyright © 2021年 atkj. All rights reserved.
//

#import "PhotoAlertView.h"
#import <AVKit/AVKit.h>
#import "GlobalMacro.h"

@interface PhotoAlertView ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (nonatomic, strong) UIAlertController *alert;
@property (nonatomic, assign) BOOL isEdit;
@end

@implementation PhotoAlertView

- (void)showAlertViewWithIsEdit:(BOOL)isEdit {
    _isEdit = isEdit;
    if (_alert) {
        //弹出sheet提示框
        [self.superViewController presentViewController:_alert animated:YES completion:nil];
    } else {
        _alert = [UIAlertController alertControllerWithTitle:@"请选择打开方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        //相机选项
        UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing= _isEdit;
        UIAlertAction * camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (![CSIITool canCameraPermission]) {
                [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"系统相机授权未打开，请先去系统进行授权" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
                }];
                return;
            }
            //选择相机时，设置UIImagePickerController对象相关属性
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
            imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            //跳转到UIImagePickerController控制器弹出相机
            [self.superViewController presentViewController:imagePicker animated:YES completion:nil];
        }];
        //相册选项
        UIAlertAction * photo = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //选择相册时，设置UIImagePickerController对象相关属性
            if (![CSIITool canPhotoPermission]) {
                [CSIITool showSystemSingleWithTitle:@"温馨提示" withContent:@"系统相册授权未打开，请先去系统进行授权" withSureText:@"确定" withState:^(id  _Nonnull responseObject) {
                }];
                return;
            }
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //跳转到UIImagePickerController控制器弹出相册
            [self.superViewController presentViewController:imagePicker animated:YES completion:nil];
        }];
        //取消按钮
        UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self.superViewController dismissViewControllerAnimated:YES completion:nil];
        }];
        //添加各个按钮事件
        [_alert addAction:camera];
        [_alert addAction:photo];
        [_alert addAction:cancel];
        //弹出sheet提示框
        [self.superViewController presentViewController:_alert animated:YES completion:nil];
    }
}

- (void)checkCamera {
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing= _isEdit;
    //选择相机时，设置UIImagePickerController对象相关属性
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    //跳转到UIImagePickerController控制器弹出相机
    [self.superViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)checkPhotoLibrary {
    UIImagePickerController *imagePicker=[[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing= _isEdit;
    //选择相册时，设置UIImagePickerController对象相关属性
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //跳转到UIImagePickerController控制器弹出相册
    [self.superViewController presentViewController:imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage* originImage = info[_isEdit ? UIImagePickerControllerEditedImage : UIImagePickerControllerOriginalImage];
    UIImage *normalImg;
    long imageSize = [self ImageSize:originImage];
    float scaleValue =  imageSize > 30 ? 0.35 : imageSize > 20 ? 0.4 : imageSize >10 ? 0.5 : imageSize > 5 ? 0.7 : imageSize >3 ? 0.8 : imageSize >=2 ? 0.85 :  imageSize>=1 ? 0.95 : 1;
    NSData *data = UIImageJPEGRepresentation(originImage,scaleValue);
    normalImg = [UIImage imageWithData:data];
    [self.photoDelegate backwithImage:normalImg withImageData:data];
    [picker dismissViewControllerAnimated:YES completion:^{}];
}

- (long)ImageSize:(UIImage *)scaleImage {
    int  perMBBytes = 1024*1024;
    CGImageRef cgimage = scaleImage.CGImage;
    size_t bpp = CGImageGetBitsPerPixel(cgimage);
    size_t bpc = CGImageGetBitsPerComponent(cgimage);
    size_t bytes_per_pixel = bpp / bpc;
    long lPixelsPerMB  = perMBBytes/bytes_per_pixel;
    long totalPixel = CGImageGetWidth(scaleImage.CGImage)*CGImageGetHeight(scaleImage.CGImage);
    long totalFileMB = totalPixel/lPixelsPerMB;
    return totalFileMB;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//图片处理
+ (CGSize)returnImageSizeWithImage:(UIImage *)image withStandSize:(CGSize)standSize {
    CGSize size = image.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    if (width == height) {
        return CGSizeMake(200, 344);
    } else if(width > height) {
        CGFloat scale1 = width/height;
        if (width < standSize.width)
            return CGSizeMake(width, width/scale1);
        else {
            // CGFloat scale2 = width/standSize.width;
            return CGSizeMake(standSize.width, standSize.width/scale1);
        }
    } else {
        CGFloat scale1 = height/width;
        if (height < standSize.height)
            return CGSizeMake(height/scale1, height);
        else {
            CGFloat scale2 = height/standSize.height;
            return CGSizeMake(height/scale1/scale2, standSize.height);
        }
    }
}
+ (UIImage*)getThumbnailImage:(NSString*)videoURL {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:videoURL] options:nil];
    
    NSParameterAssert(asset);//断言
    
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    NSTimeInterval time = 0.1;
    CGImageRef thumbnailImageRef =NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError*error =nil;
    thumbnailImageRef =  [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime,60) actualTime:NULL error:&error];
    if( error ) {
        NSLog(@"%@", error );
    }
    
    if( thumbnailImageRef ) {
        return[[UIImage alloc]initWithCGImage:thumbnailImageRef];
    }
    
    return nil;
    
}


@end
