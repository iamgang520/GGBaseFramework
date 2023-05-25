//
//  WHPingTester.m
//  BigVPN
//
//  Created by wanghe on 2017/5/11.
//  Copyright © 2017年 wanghe. All rights reserved.
//

#import "WHPingTester.h"

@interface WHPingTester()<SimplePingDelegate>
{
    NSTimer* _timer;
    NSDate* _beginDate;
}
@property(nonatomic, strong) SimplePing* simplePing;

@property(nonatomic, strong) NSMutableArray<WHPingItem*>* pingItems;
/// 前缀
@property (nonatomic, strong) NSString *prefix;

@property (nonatomic, strong) NSTimer *timeoutTimer;
@end

@implementation WHPingTester

- (instancetype) initWithHostName:(NSString*)hostName
{
    if(self = [super init])
    {
        NSArray *prefixs = [hostName componentsSeparatedByString:@"://"];
        if (prefixs.count > 1) {
            self.prefix = prefixs.firstObject;
        }
        self.simplePing = [[SimplePing alloc] initWithHostName:prefixs.lastObject];
        self.simplePing.delegate = self;
        self.simplePing.addressStyle = SimplePingAddressStyleAny;

        self.pingItems = [NSMutableArray new];
    }
    return self;
}

- (void) startPing
{
    [self.simplePing start];
}

- (void) stopPing
{
    [_timer invalidate];
    _timer = nil;
    [self.simplePing stop];
}


- (void) actionTimer
{
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendPingData) userInfo:nil repeats:YES];
}

- (void) sendPingData
{
    
    [self.simplePing sendPingWithData:nil];
    
}

- (NSString *)hostName
{
    if (self.prefix) {
        return [NSString stringWithFormat:@"%@://%@", self.prefix, self.simplePing.hostName];
    }
    return self.simplePing.hostName;
}

#pragma mark Ping Delegate
- (void)simplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address
{
    [self sendPingData];
    [self actionTimer];
}

- (void)simplePing:(SimplePing *)pinger didFailWithError:(NSError *)error
{
    NSLog(@"ping失败--->%@", error);
    [self cleanTimeroutTimer];
    
    if(self.delegate!= nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)])
    {
        [self.delegate didPingSucccessWithTime:0 withError:error];
    }
    if (self.didPingSuccessBlock) {
        self.didPingSuccessBlock(self, 99999, error);
    }
}

- (void)simplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    WHPingItem* item = [WHPingItem new];
    item.sequence = sequenceNumber;
    [self.pingItems addObject:item];
    
    _beginDate = [NSDate date];
    
    __weak typeof(self) weakSelf = self;
    self.timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:NO block:^(NSTimer * _Nonnull timer) {
        [weakSelf cleanTimeroutTimer];
        if([self.pingItems containsObject:item])
        {
            NSLog(@"超时---->:%@", self.hostName);
            [self.pingItems removeObject:item];
            if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)])
            {
                [self.delegate didPingSucccessWithTime:0 withError:[NSError errorWithDomain:NSURLErrorDomain code:111 userInfo:nil]];
            }
            if (self.didPingSuccessBlock) {
                self.didPingSuccessBlock(self, 99999, [NSError errorWithDomain:NSURLErrorDomain code:111 userInfo:nil]);
            }
        }
    }];
}
- (void)simplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    NSLog(@"发包失败--->%@", error);
    [self cleanTimeroutTimer];
    
    [self.pingItems enumerateObjectsUsingBlock:^(WHPingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.sequence == sequenceNumber)
        {
            [self.pingItems removeObject:obj];
        }
    }];
    
    if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)])
    {
        [self.delegate didPingSucccessWithTime:0 withError:error];
    }
    if (self.didPingSuccessBlock) {
        self.didPingSuccessBlock(self, 99999, error);
    }
}

- (void)simplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    [self cleanTimeroutTimer];
    
    float delayTime = [[NSDate date] timeIntervalSinceDate:_beginDate] * 1000;
    [self.pingItems enumerateObjectsUsingBlock:^(WHPingItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(obj.sequence == sequenceNumber)
        {
            [self.pingItems removeObject:obj];
        }
    }];
    if(self.delegate!=nil && [self.delegate respondsToSelector:@selector(didPingSucccessWithTime:withError:)])
    {
        [self.delegate didPingSucccessWithTime:delayTime withError:nil];
    }
    if (self.didPingSuccessBlock) {
        self.didPingSuccessBlock(self, delayTime, nil);
    }
}

- (void)simplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet{
}

- (void)cleanTimeroutTimer {
    if (self.timeoutTimer) {
        [self.timeoutTimer invalidate];
        self.timeoutTimer = nil;
    }
}

@end

@implementation WHPingItem

@end
