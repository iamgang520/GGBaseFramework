//
//  BaseHttpNetwork.m
//  GGBaseFramework
//
//  Created by iamgang on 2022/9/13.
//

#import "BaseHttpNetwork.h"
#import "GGBaseIPNRSAUtil.h"
#import "BaseConstant.h"

@interface BaseHttpNetwork ()


@end

@implementation BaseHttpNetwork

/// 这样写单例，可以让之类继承
/// 原来那样写法，无论多少子类，都会生成同一个实例
+ (instancetype)shared
{
    id instance = objc_getAssociatedObject(self, @"instance");

    if (!instance)
    {
        instance = [[super allocWithZone:NULL] init];
        [instance initGGBaseURLManager];
        objc_setAssociatedObject(self, @"instance", instance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [self shared] ;
}

- (id) copyWithZone:(struct _NSZone *)zone
{
    Class selfClass = [self class];
    return [selfClass shared] ;
}

/// 刷新url
/// 适用于切换了服务器 release debug
+ (void)reloadBaseURL
{
    [[self shared] initGGBaseURLManager];
}

- (void)initGGBaseURLManager
{
    self.urlMgr = [[GGBaseURLManager alloc] initWithURLs:[self baseURLStrings]];
}

/// BaseURL
/// 为一个数组，可轮训
- (NSArray <NSString *>*)baseURLStrings
{
    return @[@""];
}

/// headers
- (NSDictionary *)headers
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:@"ios" forKey:@"Xh-Os"];
    if (BaseConstant.SDKVersion && BaseConstant.SDKVersion.length) {
        [dic setObject:BaseConstant.SDKVersion forKey:@"Xh-Sdk-Version"];
    }
    return dic;
}

/// 请求公共参数
- (NSDictionary *)publicParams
{
    return @{};
}

/// 是否签名
- (BOOL)hasSignature
{
    return NO;
}

/// 签名秘钥
- (NSString *)rsaKey
{
    NSString *RSA_KEY = @"";
    return RSA_KEY;
}

+ (void)requestWithPath:(NSString *)path method:(HttpMethod)method params:(nullable NSDictionary *)params success:(BaseHttpNetworkrResponseBlock)success failure:(void (^)(NSError *error))failure
{
    BaseHttpNetwork *net = [self shared];
    if (net.hasSignature) {
        
        NSMutableDictionary *dic = [self addPublicParams:params];
        NSString *signedAture = [[self shared] signatureParams:dic];
        [dic setObject:signedAture ?: @"" forKey:@"signature"];
        params = dic;
    }
    
    [HttpManager request:[NSString stringWithFormat:@"%@%@", net.urlMgr.serverUrlString, path] method:method header:net.headers params:params uploadProgress:nil downloadProgress:nil response:^(RequestStatusCode requestStatusCode, id  _Nullable JSON) {
       
        if (requestStatusCode == RequestStatusCode_OK) {
            if (success) {
                success(JSON);
            }
        } else {
            if ([net.urlMgr changeUrl]) {
                [self requestWithPath:path method:method params:params success:success failure:failure];
            } else {
                if (failure) {
                    failure([JSON isKindOfClass:[NSError class]] ? JSON : [NSError new]);
                }
            }
        }
    }];
}

/// 上传文件
+ (void)uploadFileWithPath:(NSString *)path
                    method:(HttpMethod)method
                    params:(nullable NSDictionary *)params
                   fileUrl:(nullable NSURL *)fileUrl
                orFileData:(nullable NSData *)fileData
             progressBlock:(nullable void (^)(int64_t completedUnitCount, int64_t totalUnitCount))progressBlock
                   success:(BaseHttpNetworkrResponseBlock)success
                   failure:(void (^)(NSError *error))failure
{
    BaseHttpNetwork *net = [self shared];
    if (net.hasSignature) {
        
        NSMutableDictionary *dic = [self addPublicParams:params];
        NSString *signedAture = [[self shared] signatureParams:dic];
        [dic setObject:signedAture ?: @"" forKey:@"signature"];
        params = dic;
    }
    
    [HttpManager uploadFileWithURLString:[NSString stringWithFormat:@"%@%@", net.urlMgr.serverUrlString, path] method:method header:nil mimeType:nil parameters:params fromFile:fileUrl orFromData:fileData progressBlock:progressBlock callBack:^(RequestStatusCode requestStatusCode, id  _Nullable JSON) {
       
        if (requestStatusCode == RequestStatusCode_OK) {
            if (success) {
                success(JSON);
            }
        } else {
            if (failure) {
                failure([JSON isKindOfClass:[NSError class]] ? JSON : [NSError new]);
            }
        }
    }];
}

+ (NSMutableDictionary *)addPublicParams:(nullable NSDictionary *)parameters
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:parameters ?: @{}];
    // =========== 公共参数 =========
    [params addEntriesFromDictionary:[[self shared] publicParams] ?: @{}];
    return params;
}

/// 签名方法
- (NSString *)signatureParams:(NSMutableDictionary *)params
{
    return [GGBaseIPNRSAUtil sign:[self signWithParameters:params] privateKey:[self rsaKey]];
}

/// 对参数进行签名
/// @param params 参数
- (NSString *)signWithParameters:(NSMutableDictionary *)params
{
    NSInteger size = params.count;
    //获取随机数并写入到参数字典里面
    NSInteger seed = (int)(1 + (arc4random() % (size - 1 + 1)));
    [params setObject:@(seed) forKey:@"seed"];
    
    //排序
    NSArray *allKeyArray = [params allKeys];
    NSArray *afterSortKeyArray = [allKeyArray sortedArrayUsingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        NSComparisonResult resuest = [obj1 compare:obj2];
        return resuest;
    }];
    
    //开始生成待签名字符串
    NSMutableArray *stringArray = [NSMutableArray array];
    [stringArray addObject:[NSString stringWithFormat:@"%@$%@", @"ts", [params objectForKey:@"ts"]]];
    int i = 0;
    id last = nil;
    for (NSString *key in afterSortKeyArray) {
        if (![key isEqualToString:@"ts"]) {
            id value = [params objectForKey:key];
            if (@available(iOS 11.0, *)) {
                if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]) {
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value
                                                                       options:NSJSONWritingSortedKeys // Pass 0 if you don't care about the readability of the generated string
                                                                         error:nil];
                    value = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                }
                
            }
            
            if ([NSStringFromClass([value class]) isEqualToString:@"__NSCFBoolean"]) {
                if ([value boolValue]) {
                    value = @"true";
                } else {
                    value = @"false";
                }
            }
            
            if (i == seed) {
                last = [NSString stringWithFormat:@"%@$%@", key, value];
            } else {
                [stringArray addObject:[NSString stringWithFormat:@"%@$%@", key, value]];
            }
        } else {
            if (i == seed) {
                last = [NSString stringWithFormat:@"%@$%@", key, [params objectForKey:key]];
            }
        }
        i ++;
    }
    [stringArray addObject:last ?: @""];
    return [stringArray componentsJoinedByString:@"&"];
}

@end
