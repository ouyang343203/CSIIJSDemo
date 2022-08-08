//
//  SharedItem.h
//  liqiaobank
//
//  Created by Song on 2021/6/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface SharedItem : NSObject<UIActivityItemSource>

-(instancetype)initWithData:(UIImage*)img andFile:(NSURL*)file;

@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) NSURL *path;

@end

