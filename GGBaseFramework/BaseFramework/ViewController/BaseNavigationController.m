//
//  BaseNavigationController.m
//  ChatSDK
//
//  Created by 欧布 on 2021/8/2.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import "BaseNavigationController.h"

@interface BaseNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isCanRotate;

@end

@implementation BaseNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self baseInitDataSource];
    [self baseInitUserInterface];
}

#pragma mark -
#pragma mark - 初始化
- (void)baseInitDataSource
{
    self.delegate = self;
    
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)baseInitUserInterface
{
    // 去掉底部横线
    self.navigationBar.shadowImage = [UIImage new];
    
    // 去掉玻璃化，透明
    self.navigationBar.translucent = YES;
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.backgroundColor = [UIColor clearColor];
    
    // 返回手势，由于自定义了返回按钮
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = self;
    }
}

/**
 *  导航控制器 不会统一管理状态栏颜色 会交给控制器自己去控制
 *  @return 状态栏颜色
 */
- (UIViewController*)childViewControllerForStatusBarStyle {
    return self.topViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self.viewControllers count]) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    
    // 判断屏幕方向是否为即将展示的视图控制器默认方向
    if ([GGTools getInterfaceOrientation] != [viewController preferredInterfaceOrientationForPresentation]) {
        self.isCanRotate = YES;
        [GGTools setInterfaceOrientation:[viewController preferredInterfaceOrientationForPresentation]];
        self.isCanRotate = NO;
    }
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    UIViewController *controller = [super popViewControllerAnimated:animated];
    UIViewController *popToController = self.topViewController;
    
    // 当即将展示的视图控制器不支持旋转时
    // 判断屏幕方向是否为即将展示的视图控制器默认方向
    if (![popToController shouldAutorotate]) {
        if ([GGTools getInterfaceOrientation] != [popToController preferredInterfaceOrientationForPresentation]) {
            self.isCanRotate = YES;
            [GGTools setInterfaceOrientation:[popToController preferredInterfaceOrientationForPresentation]];
            self.isCanRotate = NO;
        }
    }
    
    return controller;
}

#pragma mark -
#pragma mark - 旋转屏幕相关
//是否自动旋转
//返回导航控制器的顶层视图控制器的自动旋转属性，因为导航控制器是以栈的原因叠加VC的
//topViewController是其最顶层的视图控制器，
- (BOOL)shouldAutorotate{
    return self.isCanRotate ?: self.topViewController.shouldAutorotate;
}

//支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

//默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

@end
