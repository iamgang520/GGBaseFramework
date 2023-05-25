//
//  GGBaseURLManager.m
//  StarUnionSDK
//
//  Created by 欧布 on 2021/7/12.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import "GGBaseURLManager.h"
#import "WHPingTester.h"

/*
 * 轮训逻辑
 * 先轮训主要url数组中可用的URL
 * 如果已经轮训到最后一个了，则轮训备用url数组
 * 如果启用了备用url，则下次重新从主url数组中从头来
 * 如果是用的主要url，则记录当前启用的序号，下次直接用
 */
@interface GGBaseURLManager ()
/// 主要url集合
@property (nonatomic, strong) NSMutableArray *mainUrls;

/// 当前正在使用主url的index
@property (nonatomic, assign) NSInteger nowMainUrlIndex;

@property (nonatomic, strong) NSString *nowUsedUrl;

@property (nonatomic, strong) NSMutableArray *pingers;

@end

@implementation GGBaseURLManager

- (instancetype)initWithURLs:(NSArray *)urls
{
    self = [super init];
    if (self) {
        self.mainUrls = [urls mutableCopy];
        [self reloadUrl];
        
        [self tryPingURLs];
    }
    return self;
}

- (void)reinitURLs:(NSArray *)urls {
    self.mainUrls = [urls mutableCopy];
    [self reloadUrl];
    
    [self tryPingURLs];
}

- (void)reloadUrl
{
    // 主index默认启用
    self.nowMainUrlIndex = 0;
    self.nowUsedUrl = [self.mainUrls firstObject];
}

/// 获取服务器URL
- (NSString *)serverUrlString
{
    return self.nowUsedUrl;
}

/// 切换URL
- (BOOL)changeUrl
{
    // 先判断主要的url是否用完
    if (self.nowMainUrlIndex < (NSInteger)(self.mainUrls.count - 1)) {
        // 未用完，继续+1
        self.nowMainUrlIndex ++;
        self.nowUsedUrl = [self.mainUrls objectAtIndex:self.nowMainUrlIndex];
        return YES;
    }
    
    // 都用完了，重置
    [self reloadUrl];
    return NO;
}

/// 尝试ping所有的url，进行排序
- (void)tryPingURLs {
    
    if (!self.mainUrls || ![self.mainUrls isKindOfClass:[NSArray class]] || self.mainUrls.count < 2) {
        return;
    }
    NSMutableArray *result = [NSMutableArray array];
    self.pingers = [NSMutableArray array];
    
    __block NSInteger leaveCount = 0;
    dispatch_group_t group = dispatch_group_create();
    [self.mainUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        dispatch_group_enter(group);
        leaveCount ++;
        WHPingTester *ping = [[WHPingTester alloc] initWithHostName:obj];
        // 防止临时变量被释放，无法获取回调信息
        [self.pingers addObject:ping];
        [ping setDidPingSuccessBlock:^(WHPingTester *pinger, float time, NSError *error) {
            [result addObject:@{
                @"url" : pinger.hostName ?: @"",
                @"time" : @(time)
            }];
            
            [pinger stopPing];
            [self.pingers removeObject:pinger];
            if (leaveCount >= 0) {
                leaveCount --;
                dispatch_group_leave(group);
            }
        }];
        [ping startPing];
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        [result sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [[obj1 objectForKey:@"time"] floatValue] - [[obj2 objectForKey:@"time"] floatValue];
        }];
        NSLog(@"ping结果: %@", result);
        
        NSMutableArray *urls = [NSMutableArray array];
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [urls addObject:[obj objectForKey:@"url"] ?: @""];
        }];
        self.mainUrls = [urls mutableCopy];
        [self reloadUrl];
    });
}

@end
