//
//  LQAFNetManager.m
//  liqiaobank
//
//  Created by ouyang on 2022/8/23.
//

#import "LQAFNetManager.h"
#import "MJExtension.h"

static LQAFNetManager *_manager = nil;
static const int kRequestTimeoutInterval = 20;

@implementation LQAFNetManager

+ (LQAFNetManager *)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
        [_manager.requestSerializer setTimeoutInterval:kRequestTimeoutInterval];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", @"text/json",@"application/octet-stream", nil];
        [_manager.securityPolicy setAllowInvalidCertificates:YES];
        [_manager.securityPolicy setValidatesDomainName:NO];
    });
    return _manager;
}
#pragma mark - HTTP请求方法
/** GET请求
 *  mapper:映射的Model对象
 */
- (void)getWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure {
    [self requestWithUrl:url method:RequestMethodGet params:params mapper:mapper showHUD:showHUD success:success failure:failure];
}

/** POST请求
 *  mapper:映射的Model对象
 */
- (void)postWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure{
    [self requestWithUrl:url method:RequestMethodPost params:params mapper:mapper showHUD:showHUD success:success failure:failure];
}

/** PUT请求
 *  mapper:映射的Model对象
 */
- (void)putWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure{
    [self requestWithUrl:url method:RequestMethodPut params:params mapper:mapper showHUD:showHUD success:success failure:failure];
}

/** DELETE请求
 *  mapper:映射的Model对象
 */
- (void)deleteWithUrl:(NSString *)url params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)(BaseModel* response))success failure:(void (^)(NSError *error))failure{
    [self requestWithUrl:url method:RequestMethodDelete params:params mapper:mapper showHUD:showHUD success:success failure:failure];
}

/* 接受params */
- (NSURLSessionTask*)requestWithUrl:(NSString *)url method:(RequestMethod)method params:(NSDictionary *)params mapper:(id)mapper showHUD:(BOOL)showHUD success:(void (^)( BaseModel*responseModel))success failure:(void (^)(NSError *error))failure {
    if (method == RequestMethodGet) {
        NSURLSessionDataTask *sessionDataTask = [[LQAFNetManager sharedManager] GET:url parameters:params headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSMutableString *string = [[NSMutableString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
            NSDictionary *responseDic = [self mnhuayi_dictionaryWithJsonString:string];
            if (responseDic) {
                BaseModel *responseModel  = [[BaseModel alloc]init];
                responseModel.data = responseDic;
              //  BaseModel *responseModel = [self processResponse:responseDic mapper:mapper];
                success(responseModel);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"***** urlRequest %@ *****", task.currentRequest.URL.absoluteString);
            NSString *errorMsg = [self returnErrorMsgWithCode:error.code];
            NSError *falerror = [NSError errorWithDomain:errorMsg code:502 userInfo:nil];
            failure(falerror);
        }];
        return sessionDataTask;
    }else{
        NSURLSessionDataTask *sessionDataTask = [[LQAFNetManager sharedManager] POST:url parameters:params headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {

        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *string =  [[NSString alloc] initWithData:responseObject  encoding:NSUTF8StringEncoding];
            NSDictionary *responseDic = [self mnhuayi_dictionaryWithJsonString:string];
            if (responseDic) {
                BaseModel *responseModel  = [[BaseModel alloc]init];
                responseModel.data = responseDic;
              //  BaseModel *responseModel = [self processResponse:responseDic mapper:mapper];
                success(responseModel);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"***** urlRequest %@ *****", task.currentRequest.URL.absoluteString);
            NSString *errorMsg = [self returnErrorMsgWithCode:error.code];
            NSError *falerror = [NSError errorWithDomain:errorMsg code:502 userInfo:nil];
            failure(falerror);
        }];
        return sessionDataTask;
    }
}

/* 处理HTTP RESPONSE */
- (BaseModel *)processResponse:(id)response mapper:(id)mapper {
    if (!response) {
        NSLog(@"服务器返回为空: %@", response);
        return nil;
    }

    NSDictionary *responseDict = nil;
    if ([response isKindOfClass:[NSDictionary class]]) {
        responseDict = response;

    } else {
        responseDict = (NSDictionary *)[NSJSONSerialization JSONObjectWithData:(NSData *)response options:NSJSONReadingMutableContainers error:nil];
    }

    if (!responseDict) {
        NSLog(@"服务器返回非字典: %@", response);
        return nil;
    }

    BaseModel *responseModel = [BaseModel mj_objectWithKeyValues:response];
    if ([responseModel.code integerValue] == 0)  {
        responseModel.data = [self mapperObjectWithResult:responseModel.data mapper:mapper];
        return responseModel;
        
    }  else {
        NSString *message = responseModel.message;
        return  nil;
    }
}

/* 映射对象 */
- (id)mapperObjectWithResult:(id)resultDict mapper:(id)mapper {
    id mapperObject = nil;
    if (!mapper || mapper == [NSDictionary class] || mapper == [NSArray class]) {
        return resultDict;
    }

    if ([resultDict isKindOfClass:[NSDictionary class]]) {
        id model = [[mapper alloc] init];
        [model mj_setKeyValues:resultDict];
        mapperObject = model;

    } else if ([resultDict isKindOfClass:[NSArray class]]) {
        NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:[resultDict count]];
        for (id objDict in resultDict) {
            if ([objDict isKindOfClass:[NSString class]] || [objDict isKindOfClass:[NSValue class]]) {
                [modelArray addObject:objDict];

            } else {
                id model = [[mapper alloc] init];
                [model mj_setKeyValues:objDict];
                [modelArray addObject:model];
            }
        }
        mapperObject = modelArray;

    } else if (mapper == [NSString class]) {
        mapperObject = [NSString stringWithFormat:@"%@", resultDict];
        
    } else {
        mapperObject = resultDict;
    }

    return mapperObject;
}


// 转换成字符串信息
- (NSString *)responseToString:(id)response {
    NSData *data = (NSData *)response;
    if (data && [data isKindOfClass:[NSDictionary class]]) {
        data = [NSJSONSerialization dataWithJSONObject:response options:NSJSONWritingPrettyPrinted error:nil];
    }
    
    NSString *responseStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!responseStr) {
        NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        responseStr = [[NSString alloc] initWithData:data encoding:encoding];
    }
    return responseStr;
}


-(NSDictionary *)mnhuayi_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)stringRequestMethod:(RequestMethod)method {
    if (method == RequestMethodGet) {
        return @"GET";

    } else if (method == RequestMethodPost) {
        return @"POST";

    } else if (method == RequestMethodPut) {
        return @"PUT";

    } else if (method == RequestMethodDelete) {
        return @"DELETE";
    }

    return @"WARNING:请设置正确的HTTP请求方法";
}

// 处理错误信息
- (void)processError:(NSError *)error {
    NSInteger errorCode = error.code;
    NSString *errorMessage = error.localizedDescription;
    if (errorCode == -1001) {
        if ([errorMessage containsString:NSLocalizedString(@"请求超时", nil)] ||
            [errorMessage containsString:NSLocalizedString(@"The request timed out", nil)]) {
            return;
        }

    } else if (errorCode == -1004) {
        if ([errorMessage containsString:NSLocalizedString(@"未能连接到服务器", nil)] ||
            [errorMessage containsString:@"Could not connect to the server"]) {
            return;
        }

    } else if (errorCode == -1005) {
        if ([errorMessage containsString:NSLocalizedString(@"网络连接已中断", nil)] ||
            [errorMessage containsString:NSLocalizedString(@"The network connection was lost", nil)]) {
            return;
        }

    } else if (errorCode == -1009) {
        if ([errorMessage containsString:NSLocalizedString(@"似乎已断开与互联网的连接", nil)] ||
            [errorMessage containsString:NSLocalizedString(@"The Internet connection appears to be offline", nil)]) {
            return;
        }

    } else if (errorCode == -1011) {
        if ([errorMessage containsString:NSLocalizedString(@"not found", nil)]) { // 404 500
            NSLog(@"***** 无网络连接: 404 or 500 ***** ");
            return;

        } else if ([errorMessage containsString:NSLocalizedString(@"422", nil)]) { // 422
            NSLog(@"***** 无网络连接: 422 ***** ");
            return;

        } else if ([errorMessage containsString:NSLocalizedString(@"503", nil)]) { // 503
            NSLog(@"***** 无网络连接: 503 ***** ");
            return;
        } else if ([errorMessage containsString:NSLocalizedString(@"401", nil)]) { // 401
            NSLog(@"***** 登录信息过期，请重新登录: 401 ***** ");
            return;
        }
    }
    else{
        NSLog(@"***** 其他 ***** ");
    }
}

- (NSString *)returnErrorMsgWithCode:(NSInteger)errorCode {
    switch (errorCode) {
         case -1001:
            return @"请求超时，请稍后重试";
            break;
        case -1009:
            return @"网络连接错误，请检查网络" ;
            break;
        case 400:
            return @"服务错误，请稍后重试";
            break;
        default:
            return @"服务错误，请稍后重试";;
            break;
    }
}

@end
