//
//  GGToast.m
//
//  Created by iamgang on 2020/7/23.
//  Copyright © 2020 iamgang. All rights reserved.
//

#import "GGToast.h"

@interface GGToastView: UIView

@property (nonatomic, assign) EGGToastLocation location;
@property (nonatomic, strong) NSString *text;

@end

@implementation GGToastView

@end

@implementation GGToast

// 监听屏幕旋转
+ (void)load
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
}

+ (void)deviceOrientationDidChange:(NSNotification *)noti
{
    [self removeOtherToast];
}


/// 默认关闭时间
static NSTimeInterval const defaultTime = 1.5;

+ (void)show:(NSString *)msg
{
    [self show:msg location:EGGToastLocation_Bottom];
}

+ (void)show:(NSString *)msg location:(EGGToastLocation)location
{
    [self show:msg location:location complete:nil];
}

+ (void)show:(NSString *)msg location:(EGGToastLocation)location complete:(nullable void (^)(void))complete
{
    [self show:msg location:location dismissTime:defaultTime complete:complete];
}

+ (void)show:(NSString *)msg location:(EGGToastLocation)location dismissTime:(NSTimeInterval)dismissTime
{
    [self show:msg location:location dismissTime:dismissTime complete:nil];
}

+ (void)show:(NSString *)msg location:(EGGToastLocation)location dismissTime:(NSTimeInterval)dismissTime complete:(nullable void (^)(void))complete
{
    UIWindow *nowWindow = [UIApplication sharedApplication].windows.firstObject;
    // 移除之前的
    [self removeOtherToast];
    
    GGToastView *toast = [GGToastView new];
    toast.location = location;
    toast.text = msg;
    toast.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    toast.layer.cornerRadius = 3;
    
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 0)];
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.font = [UIFont boldSystemFontOfSize:16];
    tipLabel.text = msg ?: @"";
    tipLabel.numberOfLines = 0;
    [tipLabel sizeToFit];
    tipLabel.frame = CGRectMake(10, 5, tipLabel.bounds.size.width, tipLabel.bounds.size.height);
    [toast addSubview:tipLabel];
    
    toast.frame = CGRectMake(0, 0, tipLabel.bounds.size.width + 20, tipLabel.bounds.size.height + 10);
    [nowWindow addSubview:toast];
    
    switch (location) {
        case EGGToastLocation_Top:
            {
                if (@available(iOS 11.0, *)) {
                    toast.center = CGPointMake(toast.superview.bounds.size.width / 2., [UINavigationBar appearance].frame.size.height + [UIApplication sharedApplication].delegate.window.safeAreaInsets.top + 30 + toast.bounds.size.height / 2);
                } else {
                    toast.center = CGPointMake(toast.superview.bounds.size.width / 2., [UINavigationBar appearance].frame.size.height + 30 + toast.bounds.size.height / 2);
                }
            }
            break;
        case EGGToastLocation_Center:
            {
                toast.center = CGPointMake(toast.superview.bounds.size.width / 2., toast.superview.bounds.size.height / 2.);
            }
            break;
        case EGGToastLocation_Bottom:
            {
                if (@available(iOS 11.0, *)) {
                    toast.center = CGPointMake(toast.superview.bounds.size.width / 2., toast.superview.bounds.size.height - [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom  - 30 - toast.bounds.size.height / 2);
                } else {
                    toast.center = CGPointMake(toast.superview.bounds.size.width / 2., toast.superview.bounds.size.height - 30 - toast.bounds.size.height / 2);
                
                }
            }
            break;
            
        default:
            break;
    }
    
    // 动画
    toast.transform = CGAffineTransformMakeScale(0.01, 0.01);
    toast.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         toast.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         [NSTimer scheduledTimerWithTimeInterval:dismissTime repeats:NO block:^(NSTimer * _Nonnull timer) {
                             [toast removeFromSuperview];
                             if (complete) {
                                 complete();
                             }
                         }];
                     }];
}

+ (void)removeOtherToast
{
    UIWindow *nowWindow = [UIApplication sharedApplication].windows.firstObject;
    NSArray *subViews = [nowWindow.subviews copy];
    [subViews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[GGToastView class]]) {
            GGToastView *hud = obj;
            [hud removeFromSuperview];
        }
    }];
}

@end
