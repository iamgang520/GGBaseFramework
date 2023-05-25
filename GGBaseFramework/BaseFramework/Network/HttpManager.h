//
//  HttpManager.h
//
//  Created by iamGG on 2020/11/19.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

/// 请求响应的状态
typedef NS_ENUM(NSInteger,  RequestStatusCode) {
    /// 请求出错
    RequestStatusCode_Error          = -1,
    /// 请求成功
    RequestStatusCode_OK           = 0,
};

/// 请求的方法类型
typedef NS_ENUM(NSInteger, HttpMethod) {
    HttpMethod_GET         = 0,
    HttpMethod_POST        = 1,
    HttpMethod_PUT,
    HttpMethod_DELETE
};

/// 请求的方法类型
typedef NS_ENUM(NSInteger, NetworkType) {
    /// 未知网络
    NetworkType_NONE    = 0,
    /// 4G移动网络
    NetworkType_WWAN    = 1,
    /// WIFI网络
    NetworkType_WIFI    = 2
};

/// 请求响应Block
typedef void (^HttpManagerRequestResponse)(RequestStatusCode requestStatusCode, _Nullable id JSON);

@interface HttpManager : NSObject

/// 声明单例
+ (HttpManager *)sharedInstance;

@property (nonatomic, strong) AFHTTPSessionManager *jsonManager;
@property (nonatomic, strong) AFHTTPSessionManager *httpManager;

/// 网络状态监听，应用当前是否有网络
/// 是否停止监听
+ (void)networkReachableWithBlock:(BOOL(^)(NetworkType type))block;

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
response:(HttpManagerRequestResponse)theResponse;

/// 发送文件
+ (void)uploadFileWithURLString:(NSString *)URLString
                         method:(HttpMethod)method
                         header:(nullable NSDictionary *)header
                       mimeType:(nullable NSString *)mimeType
                     parameters:(nullable NSDictionary *)parameters
                       fromFile:(nullable NSURL *)fileURL
                     orFromData:(nullable NSData *)bodyData
                  progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                       callBack:(HttpManagerRequestResponse)callback;

/// 下载文件
+ (void)downloadFileWithUrlString:(NSString *)URLString
                     fileSavePath:(NSString *)fileSavePath
                    progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                         callBack:(HttpManagerRequestResponse)callback;

/// 取消掉所有网络请求
+ (void)cancelAllRequest;

@end

NS_ASSUME_NONNULL_END
