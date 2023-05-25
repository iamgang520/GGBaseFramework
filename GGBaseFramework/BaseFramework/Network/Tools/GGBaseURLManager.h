//
//  GGBaseURLManager.h
//  StarUnionSDK
//
//  Created by 欧布 on 2021/7/12.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGBaseURLManager : NSObject
/// 初始化
- (instancetype)initWithURLs:(NSArray *)urls;
/// 重置urls
- (void)reinitURLs:(NSArray *)urls;
/// 切换URL
- (BOOL)changeUrl;

/// 获取服务器URL
@property (nonatomic, strong) NSString *serverUrlString;

@end

NS_ASSUME_NONNULL_END
