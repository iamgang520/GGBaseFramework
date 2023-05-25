//
//  HttpManager.m
//  飞天钱包
//
//  Created by iamGG on 2020/11/19.
//

#import "HttpManager.h"
#import <JKCategories/JKCategories.h>

@interface HttpManager ()

@property (nonatomic, strong) NSMutableDictionary *tasks;

@end

@implementation HttpManager

// 定义单例
+ (HttpManager *)sharedInstance
{
    static dispatch_once_t once;
    static HttpManager * singleton;
    dispatch_once( &once, ^{
        singleton = [[HttpManager alloc] init];
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.requestSerializer     = [AFJSONRequestSerializer serializer];
        manager.requestSerializer.timeoutInterval = 20;
        manager.responseSerializer    = [AFJSONResponseSerializer serializer];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
        manager.responseSerializer = responseSerializer;
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"application/x-www-form-urlencodem", nil];
        manager.requestSerializer.HTTPMethodsEncodingParametersInURI = [NSSet setWithObjects:@"GET", @"HEAD", nil];
        singleton.jsonManager = manager;
        
        AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
        httpManager.requestSerializer     = [AFHTTPRequestSerializer serializer];
        httpManager.requestSerializer.timeoutInterval = 20;
        httpManager.responseSerializer = responseSerializer;
        httpManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain",@"application/x-www-form-urlencodem", nil];
        singleton.httpManager = httpManager;
        
        singleton.tasks = [NSMutableDictionary dictionary];
    } );
    return singleton;
}

/// 网络状态监听，应用当前是否有网络
/// 是否停止监听
+ (void)networkReachableWithBlock:(BOOL (^)(NetworkType type))block {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        BOOL isStop = NO;
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN: {
                if (block) {
                    isStop = block(NetworkType_WWAN);
                }
                break;
            }
            case AFNetworkReachabilityStatusReachableViaWiFi: {
                if (block) {
                    isStop = block(NetworkType_WIFI);
                }
                break;
            }
            case AFNetworkReachabilityStatusNotReachable: {
                if (block) {
                    isStop = block(NetworkType_NONE);
                }
                break;
            }
            default:
                break;
        }
        //结束监听
        if (isStop) {
            [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
        }
    }];
}

/// 发送请求，返回JSON格式的响应数据
/// @param urlString url
/// @param method method
/// @param params params
+ (void)request:(NSString *)urlString
         method:(HttpMethod)method
         header:(NSDictionary * _Nullable)header
         params:(NSDictionary * _Nullable)params
 uploadProgress:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))theUploadProgress
downloadProgress:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))theDownloadProgress
       response:(HttpManagerRequestResponse)theResponse
{
    HttpManager *network = [HttpManager sharedInstance];
    NSString *methodString = @"GET";
    if (method == HttpMethod_POST) {
        methodString = @"POST";
    } else if (method == HttpMethod_PUT) {
        methodString = @"PUT";
    } else if (method == HttpMethod_DELETE) {
        methodString = @"DELETE";
    }
    
    NSLog(@"\n====>发送请求:【%@】%@\n参数:%@\n", methodString, urlString, params ? params : @"无");

    NSURLSessionDataTask *dataTask = [network.jsonManager dataTaskWithHTTPMethod:methodString URLString:urlString parameters:params headers:header uploadProgress:^(NSProgress * _Nonnull uploadProgress) {
            
        if (theUploadProgress && uploadProgress) {
            theUploadProgress(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
        }
        
    } downloadProgress:^(NSProgress * _Nonnull downloadProgress) {
        if (theDownloadProgress && downloadProgress) {
            theDownloadProgress(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
        NSLog(@"\n====>请求成功:【%@】%@\n%@\n", methodString, urlString, responseObject);
        if (theResponse) {
            theResponse(RequestStatusCode_OK, responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {

        NSLog(@"\n====>请求失败:【%@】%@\n%@\n", methodString, urlString, error);
        if (theResponse) {
            theResponse(RequestStatusCode_Error, error);
        }
    }];
    [dataTask resume];
}

+ (void)uploadFileWithURLString:(NSString *)URLString
                         method:(HttpMethod)method
                         header:(nullable NSDictionary *)header
                       mimeType:(nullable NSString *)mimeType
                     parameters:(nullable NSDictionary *)parameters
                       fromFile:(nullable NSURL *)fileURL
                     orFromData:(nullable NSData *)bodyData
                  progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                       callBack:(HttpManagerRequestResponse)callback
{
    [self uploadFileWithURLString:URLString method:method header:header mimeType:mimeType parameters:parameters fromFile:fileURL orFromData:bodyData progressBlock:progressBlock callBack:callback errorCount:0];
}

+ (void)uploadFileWithURLString:(NSString *)URLString
                         method:(HttpMethod)method
                         header:(nullable NSDictionary *)header
                       mimeType:(nullable NSString *)mimeType
                     parameters:(nullable NSDictionary *)parameters
                       fromFile:(nullable NSURL *)fileURL
                     orFromData:(nullable NSData *)bodyData
                  progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                       callBack:(HttpManagerRequestResponse)callback
                     errorCount:(NSInteger)errorCount
{
    if (!fileURL && !bodyData) {
        if (callback) {
            callback(RequestStatusCode_Error, [[NSError alloc] initWithDomain:NSItemProviderErrorDomain code:4004 userInfo:nil]);
        }
        return;
    }
    
    void(^completionBlock)(id responseObject,NSError * error) = ^(id responseObject,NSError * error) {
        if (callback) {
            if (error) {
                if (errorCount < 3) {
                    // 重试3次
                    [self uploadFileWithURLString:URLString method:method header:header mimeType:mimeType parameters:parameters fromFile:fileURL orFromData:bodyData progressBlock:progressBlock callBack:callback errorCount:errorCount + 1];
                } else {
                    callback(RequestStatusCode_Error,error);
                }
            }
            else if (!error){
                callback(RequestStatusCode_OK, responseObject);
            }
        }
    };
    
    NSString *methodString = @"POST";
    if (method == HttpMethod_POST) {
        methodString = @"POST";
    } else if (method == HttpMethod_PUT) {
        methodString = @"PUT";
    } else if (method == HttpMethod_DELETE) {
        methodString = @"DELETE";
    }
    
    NSMutableURLRequest *request = nil;
    if (mimeType && [mimeType isEqualToString:@"application/octet-stream"]) {
        NSURL *requestURL = [NSURL URLWithString:URLString];
        request = [[NSMutableURLRequest alloc] init];
        [request setHTTPMethod:methodString];
        [request setValue:mimeType forHTTPHeaderField:@"Content-Type"];
        [request setURL:requestURL];
        request.HTTPBody = bodyData ?: [[NSData alloc] initWithContentsOfURL:fileURL];
        if (header) {
            request.allHTTPHeaderFields = header;
        }
    } else {
        NSString *name = [NSUUID UUID].UUIDString;
        NSError *serializationError = nil;
        request = [[HttpManager sharedInstance].httpManager.requestSerializer multipartFormRequestWithMethod:methodString URLString:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            
            if (fileURL) {
                [formData appendPartWithFileURL:fileURL name:name error:nil];
            } else if (bodyData) {
                [formData appendPartWithFormData:bodyData name:name];
            }
            
        } error:&serializationError];
        for (NSString *headerField in header.keyEnumerator) {
            [request setValue:header[headerField] forHTTPHeaderField:headerField];
        }
        if (serializationError) {
            if (callback) {
                callback(RequestStatusCode_OK, serializationError);
            }
        }
    }
    
    NSURLSessionDataTask *task = [[HttpManager sharedInstance].httpManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progressBlock) {
            NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
            [mainQueue addOperationWithBlock:^{
                progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }];
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        completionBlock(responseObject, error);
    }];
    [task resume];
}

/// 下载文件
+ (void)downloadFileWithUrlString:(NSString *)URLString
                     fileSavePath:(NSString *)fileSavePath
                    progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                         callBack:(HttpManagerRequestResponse)callback
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    // 1. 创建会话管理者
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]  initWithSessionConfiguration:configuration];
    // 2. 创建下载路径和请求对象
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:URLString]];
    // 3.创建下载任务
    /**
      * 第一个参数 - request：请求对象
      * 第二个参数 - progress：下载进度block
      *      其中： downloadProgress.completedUnitCount：已经完成的大小
      *            downloadProgress.totalUnitCount：文件的总大小
      * 第三个参数 - destination：自动完成文件剪切操作
      *      其中： 返回值:该文件应该被剪切到哪里
      *            targetPath：临时路径 tmp NSURL
      *            response：响应头
      * 第四个参数 - completionHandler：下载完成回调
      *      其中： filePath：真实路径 == 第三个参数的返回值
      *            error:错误信息
      */
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress *downloadProgress) {
        // 获取主线程，不然无法正确显示进度。
        NSOperationQueue* mainQueue = [NSOperationQueue mainQueue];
        [mainQueue addOperationWithBlock:^{
            if (progressBlock) {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
        }];

    } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if ([httpResponse isKindOfClass:[NSHTTPURLResponse class]] && httpResponse.statusCode == 200) {
            // 文件下载路径 我们下载的大文件如视频应该放在沙盒的Library文件下
            return [NSURL fileURLWithPath:fileSavePath];
        }
        return nil;
    } completionHandler:^(NSURLResponse *response, NSURL *filePath,  NSError *error) {
        
        if (!error) {
            NSLog(@"下载视频完成:%@", URLString);
        } else {
            NSLog(@"下载视频失败:%@", error);
        }
        if (callback) {
            callback(error ? RequestStatusCode_Error : RequestStatusCode_OK, error ?: filePath);
        }
    }];

    // 4. 开启下载任务
    [downloadTask resume];
}

// 取消掉所有网络请求
+ (void)cancelAllRequest {
    HttpManager *client = [HttpManager sharedInstance];
    if (client.jsonManager) {
        if (client.jsonManager.operationQueue) {
            [client.jsonManager.operationQueue cancelAllOperations];
        }
    }
}

@end
