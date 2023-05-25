//
//  GGProgressHUD.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/5/9.
//

#import "GGProgressHUD.h"

#if __has_include(<LCProgressHUD/LCProgressHUD.h>)
#import <LCProgressHUD/LCProgressHUD.h>
#elif __has_include("LCProgressHUD.h")
#import "LCProgressHUD.h"
#endif

#if __has_include("SULoadingView.h")
#import "SULoadingView.h"
#endif

@implementation GGProgressHUD

#pragma mark - 建议使用的方法

/** 在 window 上添加一个只显示文字的 HUD */
+ (void)showMessage:(NSString *)text
{
    [LCProgressHUD showMessage:text];
}

/** 在 window 上添加一个提示`信息`的 HUD */
+ (void)showInfoMsg:(NSString *)text
{
    [LCProgressHUD showInfoMsg:text];
}

/** 在 window 上添加一个提示`失败`的 HUD */
+ (void)showFailure:(NSString *)text
{
    [LCProgressHUD showFailure:text];
}

/** 在 window 上添加一个提示`成功`的 HUD */
+ (void)showSuccess:(NSString *)text
{
    [LCProgressHUD showSuccess:text];
}

/** 在 window 上添加一个提示`等待`的 HUD, 需要手动关闭 */
+ (void)showLoading:(NSString *)text
{
#if __has_include("SULoadingView.h")
    [SULoadingView show];
#else
    [LCProgressHUD showLoading:text];
#endif
}

/** 手动隐藏 HUD */
+ (void)hide
{
    [[LCProgressHUD sharedHUD] setShowNow:NO];
    [[LCProgressHUD sharedHUD] hide:NO];
}
@end
