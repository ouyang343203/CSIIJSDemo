//
//  CSIITMPFileManager.h
//  CSIIJSBridge
//
//  Created by Song on 2021/6/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSIITMPFileManager : NSObject
//存储临时文件
+(BOOL)inserToPlist:(NSString*)key Object:(NSString*)object;

+(NSString*)getStorage:(NSString*)key;

+(void)removeTemporaryPlist;
//删除临时数据
+(BOOL)deleStorage:(NSString*)key;
@end

NS_ASSUME_NONNULL_END
