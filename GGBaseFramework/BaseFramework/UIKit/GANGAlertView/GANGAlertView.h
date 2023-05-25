//
//  GANGAlertView.h
//  OneGO
//
//  Created by 、GANG on 2017/4/17.
//  Copyright © 2017年 黄国刚. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^GANGAlertActionBlock)(void);

@interface GANGAlertView : UIView

// === 用户可以自定义显示颜色，字体等
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITextView *contextTextView;
@property (nonatomic, strong) UIButton *sureButton;
@property (nonatomic, strong) UIButton *cancelButton;

// 自动消失
+ (void)showMessageAutoDismiss:(NSString *)theMsg;
+ (void)showMessageAutoDismiss:(NSString *)theMsg withHanderBlock:(nullable GANGAlertActionBlock)theBlock;
+ (void)showMessageAutoDismissWithTitle:(NSString *)title withMsg:(nullable NSString *)theMsg;
+ (void)showMessageAutoDismissWithTitle:(nullable NSString *)title withMsg:(nullable NSString *)theMsg withHanderBlock:(nullable GANGAlertActionBlock)theBlock;

// 非自动消失
+ (GANGAlertView *)showMessageWithTitle:(nullable NSString *)theTitle withMessage:(nullable NSString *)theMsg withSureButton:(nullable NSString *)theSBtn withSureBlock:(nullable GANGAlertActionBlock)theSBlock;
+ (GANGAlertView *)showMessageWithTitle:(nullable NSString *)theTitle withMessage:(nullable NSString *)theMsg withSureButton:(nullable NSString *)theSBtn withSureBlock:(nullable GANGAlertActionBlock)theSBlock withCancelButton:(nullable NSString *)theCBtn  withCancelBlock:(nullable GANGAlertActionBlock)theCBlock;

@end

NS_ASSUME_NONNULL_END
