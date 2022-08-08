//
//  DataManager.m
//  CSIIJSBridge
//
//  Created by 李佛军 on 2021/10/8.
//

#import "DataManager.h"
#define CLOUD_PLA_DATA_TOKEN @"data_cloud_token"
@implementation DataManager
+(instancetype)shareManager
{
    static DataManager *dataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[DataManager alloc] init];
    });
    return dataManager;
}
-(void)setToken:(NSString*)token
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:token forKey:CLOUD_PLA_DATA_TOKEN];
}

-(NSString*)getToken
{
    NSUserDefaults*userDefaults=[NSUserDefaults standardUserDefaults];
    return  [userDefaults objectForKey:CLOUD_PLA_DATA_TOKEN];
}
@end
