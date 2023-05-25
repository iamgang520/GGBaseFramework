//
//  BaseViewController.h
//  ChatSDK
//
//  Created by 欧布 on 2021/8/2.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import <UIKit/UIKit.h>
#import "GGTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : UIViewController

#pragma mark - 主题
/// 是否是白色navgation
- (BOOL)isWhiteNavigation;
/// 是否允许旋转屏幕
- (BOOL)shouldAutorotate;

- (UIColor *)navigationBarBackgroundColor;
- (UIColor *)navigationBarTitleColor;

/// 自定义NavBar背景
@property (nonatomic, strong) UIImageView *navBackView;

#pragma mark - Nav按钮
/// 自定义返回按钮
- (void)configureLeft:(nullable NSString *)string;

/// 设置标题
- (void)setCenterTitle:(NSString *)title;

/// 显示隐藏导航栏
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;

/// 获取当前标题
- (NSString *)getNowTitle;

///自定义导航栏右边按钮--文字
- (void)configureRight:(NSString *)string;
- (void)configureRight:(NSString *)string actionBlock:(nullable void (^)(void))theBlock;
- (void)configureRight:(NSString *)string font:(UIFont *)font;
- (void)configureRight:(NSString *)string font:(UIFont *)font actionBlock:(nullable void (^)(void))theBlock;

///自定义导航栏右边按钮--文字加图片
- (void)configureRightImage:(NSString *)imgName;
- (void)configureRightImage:(NSString *)imgName actionBlock:(nullable void (^)(void))theBlock;
- (UIBarButtonItem *)setRightButtonWithTitle:(NSString *)theTitle imgName:(NSString *)theImgName action:(nullable void(^)(void))theAction;

/// 点击右侧按钮
- (void)rightNavAction;
/// 点击返回按钮
- (void)backNavAction;

/// 是否点击空白处收起键盘：默认YES
- (BOOL)shouldHideKeyboardWhenTouch;

@end

NS_ASSUME_NONNULL_END
