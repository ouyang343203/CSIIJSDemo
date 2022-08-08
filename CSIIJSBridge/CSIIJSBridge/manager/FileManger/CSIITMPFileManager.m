//
//  CSIITMPFileManager.m
//  CSIIJSBridge
//
//  Created by Song on 2021/6/26.
//

#import "CSIITMPFileManager.h"
#define TEMPORARY_FILE @"temporary"//自动清理的临时文件
#define FILEMANAGER [NSFileManager defaultManager]
#define TemporaryDirectory NSTemporaryDirectory()
@implementation CSIITMPFileManager


+(BOOL)inserToPlist:(NSString*)key Object:(NSString*)object
{
    NSString *plistName = [[NSString stringWithFormat:TEMPORARY_FILE] stringByAppendingPathExtension:@"plist"];
    NSString *temporary_plist = [TemporaryDirectory stringByAppendingString:plistName];
    
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithContentsOfFile:temporary_plist];
    //下边if判断很重要，不然会写入失败.
      if (!userDict) {
          userDict = [[NSMutableDictionary alloc] init];
      }
    [userDict setObject:object forKey:key];
    return  [userDict writeToFile:temporary_plist atomically:YES];
}
+(NSString*)getStorage:(NSString*)key
{
    NSString *plistName = [[NSString stringWithFormat:TEMPORARY_FILE] stringByAppendingPathExtension:@"plist"];
    NSString *temporary_plist = [TemporaryDirectory stringByAppendingString:plistName];
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithContentsOfFile:temporary_plist];
    return userDict[key];
}
+(void)removeTemporaryPlist
{
    NSString *plistName = [[NSString stringWithFormat:TEMPORARY_FILE] stringByAppendingPathExtension:@"plist"];
    NSString *temporary_plist = [TemporaryDirectory stringByAppendingString:plistName];
   
    NSError *error;
 BOOL isRemove =  [FILEMANAGER removeItemAtPath:temporary_plist error:&error];
    if (isRemove) {
        NSLog(@"删除成功");
    }else
    {
        NSLog(@"删除成功");
    }
   
}
+(BOOL)deleStorage:(NSString*)key
{
    NSString *plistName = [[NSString stringWithFormat:TEMPORARY_FILE] stringByAppendingPathExtension:@"plist"];
    NSString *temporary_plist = [TemporaryDirectory stringByAppendingString:plistName];
    NSMutableDictionary *userDict = [[NSMutableDictionary alloc] initWithContentsOfFile:temporary_plist];
    if (userDict) {
        [userDict removeObjectForKey:key];
    }
    return [userDict writeToFile:temporary_plist atomically:YES];
}
@end
