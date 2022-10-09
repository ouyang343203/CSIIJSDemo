//
//  BaseModel.h
//  liqiaobank
//
//  Created by ouyang on 2022/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseModel : NSObject

@property (nonatomic, copy) NSString *code;
@property (nonatomic, strong) id data;
@property (nonatomic, strong)NSMutableString *message; // 请求返回信息处理

@end

NS_ASSUME_NONNULL_END
