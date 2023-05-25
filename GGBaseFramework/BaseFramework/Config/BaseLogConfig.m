//
//  BaseLogConfig.m
//  GGBaseFramework
//
//  Created by iamgang on 2022/10/12.
//

#import "BaseLogConfig.h"

@implementation BaseLogConfig

static BOOL kIsShowLog = NO;
+ (BOOL)isShowLog {
    
    return kIsShowLog;
}

+ (void)setIsShowLog:(BOOL)isShowLog
{
    kIsShowLog = isShowLog;
}

@end
