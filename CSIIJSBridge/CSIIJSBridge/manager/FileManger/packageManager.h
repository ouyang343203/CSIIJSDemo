//
//  packageManager.h
//  CSIIPluginDownLoadDemo
//
//  Created by Song on 2021/6/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface packageManager : NSObject
#pragma mark -----------根据packageName下载到指定的离线包文件夹下，根据versionNumber获取到相应版本号的离线包来加载
//获取Document下面的路径
+(NSString*)getDocumentPath;
//删除文件和文件夹
+ (BOOL)fileDelete:(NSString *)filePath;
//删除目录下所有文件和文件夹
+ (void)allfilesDelete:(NSString *)folderPath;
//根据包名获取到所在的路径
+(NSString*)getDownloadFile:(NSString*)packageName;
//返回文件大小
+ (unsigned long long)fileSize:(NSString*)path;
//返回文件大小
+ (unsigned long long)sizeAtPath:(NSString *)path;
//返回目录下所有的文件名(不包括路径)数组
+ (NSArray *)allFilesInFolderPath:(NSString *)folderPath;
//根据包名下载到指定的包下面文件
+(NSString*)createFilePackageName:(NSString*)packageName versionNumber:(NSString*)versionNumber;
//根据包名和版本号找到对应的文件路径
+(NSString*)getFilePackageName:(NSString*)packageName versionNumber:(NSString*)versionNumber;
//判断历史项目文件夹下的版本号是否存在
+(BOOL)getHistoryPackage:(NSString*)packageName versionNumber:(NSString*)versionNumber;
//重命名包的名字
+(void)reNamePackageNames:(NSString*)packageName versionNumber:(NSString*)versionNumber;
#pragma mark --------------end-------------------------------
@end

NS_ASSUME_NONNULL_END
