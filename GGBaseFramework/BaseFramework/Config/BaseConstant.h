//
//  BaseConstant.h
//  GGBaseFramework
//
//  Created by iamgang on 2022/12/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseConstant : NSObject

/// 获取SDK版本号：用于公共服务网络请求上传
+ (NSString *)SDKVersion;

@end

NS_ASSUME_NONNULL_END
