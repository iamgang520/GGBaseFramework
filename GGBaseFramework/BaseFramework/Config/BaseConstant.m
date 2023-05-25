//
//  BaseConstant.m
//  GGBaseFramework
//
//  Created by iamgang on 2022/12/28.
//

#import "BaseConstant.h"


@implementation BaseConstant

/// 设置SDK版本号：用于公共服务网络请求上传
static NSString *kSDKVersion = @"1.0.0";
+ (NSString *)SDKVersion {
    return kSDKVersion;
}

@end
