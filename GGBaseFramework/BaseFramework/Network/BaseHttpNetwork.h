//
//  BaseHttpNetwork.h
//  GGBaseFramework
//
//  Created by iamgang on 2022/9/13.
//

#import <Foundation/Foundation.h>
#import "HttpManager.h"
#import "GGBaseURLManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^BaseHttpNetworkrResponseBlock)(id response);

@protocol BaseHttpNetworkDataSource <NSObject>

/// BaseURL
/// 为一个数组，可轮训
- (NSArray <NSString *>*)baseURLStrings;

@optional
/// headers
- (NSDictionary *)headers;
/// 请求公共参数
- (NSDictionary *)publicParams;

// ============= 签名相关 =============
/// 是否签名
/// 默认会签名
- (BOOL)hasSignature;
/// 签名秘钥
- (NSString *)rsaKey;
/// 签名方法
/// 默认:星合互娱签名规则
- (NSString *)signatureParams:(NSDictionary *)params;
// ===================================

@end

/// 封装网络请求，子类可继承
@interface BaseHttpNetwork : NSObject <BaseHttpNetworkDataSource>

+ (instancetype)shared;

@property (nonatomic, strong) GGBaseURLManager *urlMgr;
/// 刷新url
/// 适用于切换了服务器 release debug
+ (void)reloadBaseURL;

/// 发送一个请求
+ (void)requestWithPath:(NSString *)path method:(HttpMethod)method params:(nullable NSDictionary *)params success:(BaseHttpNetworkrResponseBlock)success failure:(void (^)(NSError *error))failure;

/// 上传文件
+ (void)uploadFileWithPath:(NSString *)path
                    method:(HttpMethod)method
                    params:(nullable NSDictionary *)params
                   fileUrl:(nullable NSURL *)fileUrl
                orFileData:(nullable NSData *)fileData
             progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                   success:(BaseHttpNetworkrResponseBlock)success
                   failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
