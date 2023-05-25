//
//  GANGAlertView.m
//  OneGO
//
//  Created by 、GANG on 2017/4/17.
//  Copyright © 2017年 黄国刚. All rights reserved.
//

#import "GANGAlertView.h"

#define GANGAlertViewThemeColor  ([UIColor systemBlueColor])

#define GANGAlertViewBackViewWidth MIN((([UIScreen mainScreen].bounds.size.width < [UIScreen mainScreen].bounds.size.height ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height) / 1.5), 300)

#define GANGAlertViewButtonHeight 40.f

@interface GANGAlertView ()

@end


@implementation GANGAlertView

// 自动消失
+ (void)showMessageAutoDismiss:(NSString *)theMsg
{
    [self showMessageAutoDismiss:theMsg withHanderBlock:nil];
}

+ (void)showMessageAutoDismiss:(NSString *)theMsg withHanderBlock:(nullable GANGAlertActionBlock)theBlock
{
    [self showMessageAutoDismissWithTitle:nil withMsg:theMsg withHanderBlock:theBlock];
}

+ (void)showMessageAutoDismissWithTitle:(NSString *)title withMsg:(nullable NSString *)theMsg
{
    [self showMessageAutoDismissWithTitle:title withMsg:theMsg withHanderBlock:nil];
}

+ (void)showMessageAutoDismissWithTitle:(nullable NSString *)title withMsg:(nullable NSString *)theMsg withHanderBlock:(nullable GANGAlertActionBlock)theBlock
{
    GANGAlertView *alert = [GANGAlertView showMessageWithTitle:title withMessage:theMsg withSureButton:nil withSureBlock:theBlock];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alert removeFromSuperview];
    });
}

// 非自动消失
+ (GANGAlertView *)showMessageWithTitle:(nullable NSString *)theTitle withMessage:(nullable NSString *)theMsg withSureButton:(nullable NSString *)theSBtn withSureBlock:(nullable GANGAlertActionBlock)theSBlock
{
    return [self showMessageWithTitle:theTitle withMessage:theMsg withSureButton:theSBtn withSureBlock:theSBlock withCancelButton:nil withCancelBlock:nil];
}

+ (GANGAlertView *)showMessageWithTitle:(nullable NSString *)theTitle withMessage:(nullable NSString *)theMsg withSureButton:(nullable NSString *)theSBtn withSureBlock:(nullable GANGAlertActionBlock)theSBlock withCancelButton:(nullable NSString *)theCBtn  withCancelBlock:(nullable GANGAlertActionBlock)theCBlock
{
    if (![NSThread isMainThread]) {
        NSAssert(YES, @"不在主线程");
        return nil;
    }
    GANGAlertView *alertView = [[GANGAlertView alloc] init];
    [[UIApplication sharedApplication].windows.firstObject addSubview:alertView];
    [alertView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    // 中间背景
    UIView *centerBackView = [UIView new];
    centerBackView.backgroundColor = [UIColor whiteColor];
    centerBackView.layer.cornerRadius = 10;
    [alertView addSubview:centerBackView];
    [centerBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(alertView);
        make.width.mas_equalTo(GANGAlertViewBackViewWidth);
    }];
    
    UIView *lastView;
    // 标题
    if (theTitle && theTitle.length) {
        alertView.titleLabel = [UILabel new];
        alertView.titleLabel.text = theTitle;
        alertView.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        alertView.titleLabel.textAlignment = NSTextAlignmentCenter;
        alertView.titleLabel.numberOfLines = 2;
        alertView.titleLabel.textColor = COLOR_111111;
        [centerBackView addSubview:alertView.titleLabel];
        [alertView.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(-20);
            make.top.mas_equalTo(theMsg && theMsg.length ? 10 : 20);
        }];
        lastView = alertView.titleLabel;
    }
    
    // 正文
    if (theMsg && theMsg.length) {
        if ([theMsg isKindOfClass:[NSNumber class]]) {
            theMsg = [NSString stringWithFormat:@"%@", theMsg];
        }
        alertView.contextTextView = [UITextView new];
        alertView.layer.borderWidth = 1;
        alertView.contextTextView.textColor = COLOR_111111;
        alertView.contextTextView.textAlignment = NSTextAlignmentCenter;
        alertView.contextTextView.font = [UIFont systemFontOfSize:15];
        alertView.contextTextView.editable = NO;
        alertView.contextTextView.selectable = NO;
        alertView.contextTextView.backgroundColor = [UIColor clearColor];
        alertView.contextTextView.textContainerInset = UIEdgeInsetsZero;
        [centerBackView addSubview:alertView.contextTextView];
        // 计算高度
        UILabel *signLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, GANGAlertViewBackViewWidth - 20, 0)];
        signLabel.numberOfLines = 0;
        signLabel.font = alertView.contextTextView.font;
        if ([theMsg isKindOfClass:[NSAttributedString class]]) {
            signLabel.attributedText = (NSAttributedString *)theMsg;
            alertView.contextTextView.attributedText = signLabel.attributedText;
        } else {
            signLabel.text = theMsg;
            alertView.contextTextView.text = theMsg;
        }
        [signLabel sizeToFit];
        CGFloat signLabelHeight = signLabel.bounds.size.height;
        if (signLabelHeight > 150) {
            signLabelHeight = 150;
            alertView.contextTextView.userInteractionEnabled = YES;
        } else {
            alertView.contextTextView.userInteractionEnabled = NO;
        }
        [alertView.contextTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(10);
            make.right.mas_equalTo(-10);
            if (lastView) {
                make.top.mas_equalTo(lastView.mas_bottom).offset(10);
            } else {
                make.top.mas_equalTo(20);
            }
            make.height.mas_equalTo(signLabelHeight);
        }];
        lastView = alertView.contextTextView;
    }
    
    if (theCBtn && theCBtn.length) {
        alertView.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        alertView.cancelButton.backgroundColor = [UIColor clearColor];
        [alertView.cancelButton setTitle:theCBtn forState:UIControlStateNormal];
        [alertView.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        alertView.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [alertView.cancelButton jk_addActionHandler:^(NSInteger tag) {
            [alertView removeFromSuperview];
            if (theCBlock) {
                theCBlock();
            }
        }];
        [centerBackView addSubview:alertView.cancelButton];
    }
    
    if (theSBtn && theSBtn.length) {
        alertView.sureButton = [UIButton buttonWithType:UIButtonTypeSystem];
        alertView.sureButton.backgroundColor = [UIColor clearColor];
        [alertView.sureButton setTitle:theSBtn forState:UIControlStateNormal];
        [alertView.sureButton setTitleColor:GANGAlertViewThemeColor forState:UIControlStateNormal];
        alertView.sureButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
        [alertView.sureButton jk_addActionHandler:^(NSInteger tag) {
            [alertView removeFromSuperview];
            if (theSBlock) {
                theSBlock();
            }
        }];
        [centerBackView addSubview:alertView.sureButton];
    }
    
    if (alertView.cancelButton) {
        [alertView.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            if (lastView) {
                make.top.mas_equalTo(lastView.mas_bottom).offset(alertView.titleLabel && alertView.contextTextView ? 15 : 20);
            } else {
                make.top.mas_equalTo(0);
            }
            make.height.mas_equalTo(GANGAlertViewButtonHeight);
            
            if (alertView.sureButton) {
                make.right.mas_equalTo(alertView.sureButton.mas_left);
            } else {
                make.right.mas_equalTo(0);
                make.bottom.mas_equalTo(0);
            }
        }];
    }
    
    if (alertView.sureButton) {
        [alertView.sureButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            if (alertView.cancelButton) {
                make.left.mas_equalTo(alertView.cancelButton.mas_right);
                make.width.mas_equalTo(alertView.cancelButton);
                make.top.mas_equalTo(alertView.cancelButton.mas_top);
                make.height.mas_equalTo(alertView.cancelButton);
            } else {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom).offset(alertView.titleLabel && alertView.contextTextView ? 15 : 20);
                } else {
                    make.top.mas_equalTo(0);
                }
                make.left.mas_equalTo(0);
                make.height.mas_equalTo(GANGAlertViewButtonHeight);
            }
        }];
    }
    
    if (!alertView.cancelButton && !alertView.sureButton) {
        if (lastView) {
            [lastView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (!alertView.titleLabel) {
                    make.bottom.mas_equalTo(-20);
                } else {
                    make.bottom.mas_equalTo(-10);
                }
            }];
        }
    }
    
    if (alertView.cancelButton || alertView.sureButton) {
        
        if (lastView) {
            UIView *line1 = [UIView new];
            line1.backgroundColor = COLOR_DDDDDD;
            [centerBackView addSubview:line1];
            [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                make.bottom.mas_equalTo(- GANGAlertViewButtonHeight);
                make.height.mas_equalTo(0.5);
            }];
        }
        
        if (alertView.cancelButton && alertView.sureButton) {
            UIView *line2 = [UIView new];
            line2.backgroundColor = COLOR_DDDDDD;
            [centerBackView addSubview:line2];
            [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(0.5);
                make.centerX.mas_equalTo(centerBackView);
                make.bottom.mas_equalTo(0);
                make.height.mas_equalTo(GANGAlertViewButtonHeight);
            }];
        }
    }
    
    // 背景变化
    [UIView animateWithDuration:0.3 animations:^{

        alertView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.6];
    }];
    // 大小变化
    centerBackView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    centerBackView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
        centerBackView.transform = CGAffineTransformIdentity;
     } completion:^(BOOL finished) {
         
     }];
    
    return alertView;
}


@end
