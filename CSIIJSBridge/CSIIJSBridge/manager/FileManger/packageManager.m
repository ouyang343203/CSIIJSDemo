//
//  packageManager.m
//  CSIIPluginDownLoadDemo
//
//  Created by Song on 2021/6/17.
//

#import "packageManager.h"

#define FILEMANAGER [NSFileManager defaultManager]
//获取沙盒文件下的项目文件文件
#define kDocumentPath(packageName) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:packageName]
//获取Document沙盒下面的路径
#define kDocumentDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

@implementation packageManager
//获取Document下面的路径
+(NSString*)getDocumentPath {
    return kDocumentDirectory;
}

//根据项目包获取到所在的路径
+(NSString*)getDownloadFile:(NSString*)packageName{
    return kDocumentPath(packageName);
}

//根据项目包名得到对应版本号的离线包名
+(NSString*)getFilePackageName:(NSString*)packageName versionNumber:(NSString*)versionNumber;{
    return [kDocumentPath(packageName) stringByAppendingPathComponent:versionNumber];
}

//根据离线包名，找到对应的版本号的离线包
+(NSString*)createFilePackageName:(NSString*)packageName versionNumber:(NSString*)versionNumber{
    NSString *pathname = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    pathname =  [pathname stringByAppendingPathComponent:packageName];
    BOOL isExists = [packageManager fileExists:pathname];
    BOOL isSuccess = NO;
    if (!isExists) {
        isSuccess =  [packageManager isFilewasGreatedSuccess:pathname];
    }
    pathname = [pathname stringByAppendingFormat:@"/%@.zip",versionNumber];
    return pathname;
}

//判断历史文件夹文件是否存在
+(BOOL)getHistoryPackage:(NSString*)packageName versionNumber:(NSString*)versionNumber {
  NSString *historyFile = [kDocumentPath(packageName) stringByAppendingPathComponent:versionNumber];
    if ([FILEMANAGER fileExistsAtPath:historyFile]) {
        return YES;
    }else{
        return NO;
    }
}

//判断文件夹是否存在
+(BOOL)fileExists:(NSString*)packageName {
    BOOL isDir;//判断该路径是不是文件夹
    BOOL isExists = [FILEMANAGER fileExistsAtPath:packageName isDirectory:&isDir];//返回文件或文件夹是否存在
    if (isExists && isDir) {
        NSLog(@"%@文件夹已经存在!不需要创建!",packageName);
        return YES;
    }
    return NO;
}

//判断文件夹是否创建成功
+(BOOL)isFilewasGreatedSuccess:(NSString*)packageName {
    NSError *error = nil;
    
    BOOL isSucces=NO;
    
    isSucces=[FILEMANAGER createDirectoryAtPath:packageName withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"创建出错:%@", [error localizedDescription]);
    }else{
        NSLog(@"创建成功！");
    }
    
    return isSucces;
}

//重命名包的名字
+(void)reNamePackageNames:(NSString*)packageName versionNumber:(NSString*)versionNumber {
    NSString *old_path = kDocumentPath(packageName);
    NSArray *fileArray = [packageManager allFilesInFolderPath:old_path];
    BOOL isbool = [fileArray containsObject: versionNumber];
    NSString *finance = @"finance";
    NSString *new_path = versionNumber;
    if (isbool) return;
    new_path = [NSString stringWithFormat:@"%@/%@",old_path,versionNumber];
   // 原来的文件目录
     NSString* fromFileName = [old_path stringByAppendingPathComponent:finance];
   // 改变之后的文件名
     NSString* changedStr = [versionNumber stringByReplacingOccurrencesOfString:new_path withString:@""];
              // 改变之后的文件目录
    NSString* toFileName = [old_path stringByAppendingPathComponent:changedStr];
            
   NSError *error;
   // 替换，其实也是重命名
   BOOL isSuccess = [FILEMANAGER moveItemAtPath:fromFileName toPath:toFileName error:&error];
   if (isSuccess) {
       
       NSLog(@"重命名成功");
   }else
   {
       NSLog(@"重命名失败");
   }
}

//获取文件夹大小
+ (unsigned long long)sizeAtPath:(NSString *)path {
    BOOL isDir = YES;
    if (![FILEMANAGER fileExistsAtPath:path isDirectory:&isDir]) {
        return 0;
    };
    unsigned long long fileSize = 0;
    // directory
    if (isDir) {
        NSDirectoryEnumerator *enumerator = [FILEMANAGER enumeratorAtPath:path];
        while (enumerator.nextObject) {

            fileSize += enumerator.fileAttributes.fileSize;
        }
    } else {
        // file
        fileSize = [FILEMANAGER attributesOfItemAtPath:path error:nil].fileSize;
    }
    return fileSize;
}

//获取文件夹大小
+ (unsigned long long)fileSize:(NSString*)path {
    // 总大小
    unsigned long long size = 0;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:path isDirectory:&isDir];
    
    // 判断路径是否存在
    if (!exist) return size;
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [path stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
            
            }
        }else{ // 是文件
            size += [manager attributesOfItemAtPath:path error:nil].fileSize;
        }
        return size;
}

//删除目录下所有文件和文件夹
+ (void)allfilesDelete:(NSString *)folderPath{
    NSArray *files = [self allFilesInFolderPath:folderPath];
    NSLog(@"files count=%lu", (unsigned long)[files count]);
    for (NSString *file in files) {
        NSString *filePath = [folderPath stringByAppendingPathComponent:file];//转换成url
        BOOL isDir;//判断该路径是不是文件夹
        BOOL isExists = [FILEMANAGER fileExistsAtPath:filePath isDirectory:&isDir];//返回文件或文件夹是否存在
        if (isExists) {
            [self fileDelete:filePath];
        }
    }
}

//删除文件和文件夹
+ (BOOL)fileDelete:(NSString *)filePath{
    NSError *error=nil;
    BOOL isSucces=NO;
    if (![FILEMANAGER fileExistsAtPath:filePath]) {
        NSLog(@"要删除的地址不存在!!!filePath=%@", filePath);
        return NO;
    }
    
    isSucces=[FILEMANAGER removeItemAtPath:filePath error:&error];//调用删除方法
    if (error != nil) {
        NSLog(@"删除出错:%@", [error localizedDescription]);
    }else{
        NSLog(@"删除成功！");
    }
    return isSucces;
}

//返回目录下所有的文件名(不包括路径)数组
+ (NSArray *)allFilesInFolderPath:(NSString *)folderPath{
    return [FILEMANAGER contentsOfDirectoryAtPath:folderPath error:nil];
}

@end
