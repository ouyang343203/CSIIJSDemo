//
//  UIImage+colorImage.m
//  CLCollege
//
//  Created by zhongzhi on 2017/5/9.
//  Copyright © 2017年 zhongzhi. All rights reserved.
//

#import "UIImage+colorImage.h"

@implementation UIImage (colorImage)
// 设置图片为不渲染模式
+ (instancetype)imageWithOriginalName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
}

+ (UIImage *)imageWithColor:(UIColor *)color  {
    
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGContextAddEllipseInRect(context, rect);
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage*)scaleToSize:(CGSize)size {
    size = CGSizeMake(size.width  , size.height );
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [self drawInRect:CGRectMake(0, 0, size.width , size.height )];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;

}

/**
 *  压缩图片
 *  image:将要压缩的图片   size：压缩后的尺寸
 */
-(UIImage*)originScaleToSize:(CGSize)size
{
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
 
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
 
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
 
    UIGraphicsEndImageContext();
 
    return scaledImage;   //返回的就是已经改变的图片
}



+ (NSData*)imageData:(UIImage*)image maxSize:(NSInteger)maxSize{
    CGSize iRect = image.size;
    CGSize fRect = CGSizeMake([UIScreen mainScreen].bounds.size.width * [UIScreen mainScreen].scale, [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale);
    CGSize newSize;;
    if (iRect.height / iRect.width >= fRect.height / fRect.width) {
        newSize = CGSizeMake(iRect.width * fRect.height/ iRect.height, fRect.height);
    }else{
        newSize = CGSizeMake(fRect.width, iRect.height * fRect.width/ iRect.width);
    }
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //调整大小
    double q = 1;
    NSData *imageData = UIImageJPEGRepresentation(newImage, q);
    while (imageData.length / maxSize >= 1 && q >= 0) {
        q = q - 0.1;
        imageData = UIImageJPEGRepresentation(newImage, q);
    }
    return imageData;
}
+(UIImage *)NavImage {
    UIImage *image =[UIImage imageNamed:@"NavbarImage.png"];
    CGSize size = CGSizeMake(Device_Width, 64);
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    return scaledImage;
}

+(UIImage *)imageWithColor:(UIColor*)color size:(CGSize)size{
    
    CGRect rect =CGRectMake(0,0, size.width , size.height );
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context =UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    
    CGContextFillRect(context, rect);
    
    UIImage *image =UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
    
}

//添加水印图片
+ (UIImage *)LX_WaterImageWithImage:(UIImage *)image waterImage:(UIImage *)waterImage waterImageRect:(CGRect)rect{
    
    //1.获取图片
    
    //2.开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //3.绘制背景图片
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
    //绘制水印图片到当前上下文
    [waterImage drawInRect:rect];
    
    //4.从上下文中获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5.关闭图形上下文
    UIGraphicsEndImageContext();
    //返回图片
    return newImage;

}
+ (UIImage *)LX_ClipImageWithImage:(UIImage *)image circleRect:(CGRect)rect radious:(CGFloat) radious{
    //1、开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    //2、设置裁剪区域
//    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:rect];
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radious];
    [path addClip];
    //3、绘制图片
    [image drawAtPoint:CGPointZero];
    //4、获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5、关闭上下文
    UIGraphicsEndImageContext();
    //6、返回新图片
    return newImage;
}
//裁剪圆形
+ (UIImage *)LX_ClipCircleImageWithImage:(UIImage *)image circleRect:(CGRect)rect{
    //1、开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    //2.设置剪裁区域
    
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:rect];
    
    [path addClip];
    
    //绘制图片
    
    [image drawAtPoint:CGPointZero];
    
    
    //获取新图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //返回新图片
    
    return  newImage;
    
    
    
}

//裁剪带边框的圆形图片
+ (UIImage *)LX_ClipCircleImageWithImage:(UIImage *)image circleRect:(CGRect)rect borderWidth:(CGFloat)borderW borderColor:( UIColor *)borderColor{
    //1、开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    //2、设置边框
    UIBezierPath * path = [UIBezierPath bezierPathWithOvalInRect:rect];
    [borderColor setFill];
    [path fill];
    
    //3、设置裁剪区域
    UIBezierPath * clipPath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(rect.origin.x + borderW , rect.origin.x + borderW , rect.size.width - borderW * 2, rect.size.height - borderW *2)];
    [clipPath addClip];
    
    //3、绘制图片
    [image drawAtPoint:CGPointZero];
    
    //4、获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5、关闭上下文
    UIGraphicsEndImageContext();
    //6、返回新图片
    return newImage;

}

//裁剪带边框的图片 可设置圆角 边框颜色
+(UIImage *)LX_ClipImageRadiousWithImage:(UIImage *)image circleRect:(CGRect)rect radious:(CGFloat)radious borderWith:(CGFloat)borderW borderColor:( UIColor *)borderColor{
    
   
    //1、开启上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0);
    
    //2、设置边框
    
    UIBezierPath *path =[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radious];
    
    [borderColor setFill];
    
    [path fill];
    
    
    //3、设置裁剪区域
    
    
    UIBezierPath * clipPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x + borderW , rect.origin.x + borderW , rect.size.width - borderW * 2, rect.size.height - borderW *2) cornerRadius:radious];
    
    [clipPath addClip];
    
    //3、绘制图片
    [image drawAtPoint:CGPointZero];
    
    //4、获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    //5、关闭上下文
    UIGraphicsEndImageContext();
    //6、返回新图片
    return newImage;
    
    
    
}
//对View进行截屏
+(void)LX_CutScreenWithView:(UIView *)view successBlock:( void(^)(UIImage * image,NSData * imagedata))block{
    //1、开启上下文
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0);
    
    //2.获取当前上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //3.截屏
    [view.layer renderInContext:ctx];
    
    //4、获取新图片
    UIImage * newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //5.转化成为Data
    //compressionQuality:表示压缩比 0 - 1的取值范围
    NSData * data = UIImageJPEGRepresentation(newImage, 1);
    //6、关闭上下文
    UIGraphicsEndImageContext();
    
    //7.回调
    block(newImage,data);

}
@end
