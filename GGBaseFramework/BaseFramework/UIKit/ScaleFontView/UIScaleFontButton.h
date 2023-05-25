//
//  UIScaleFontButton.h
//  ChatSDK
//
//  Created by 欧布 on 2021/8/20.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import <UIKit/UIKit.h>
#if __has_include(<QMUIKit/QMUIButton.h>)
#import <QMUIKit/QMUIButton.h>
#elif __has_include("QMUIButton.h")
#import "QMUIButton.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if __has_include(<QMUIKit/QMUIButton.h>) || __has_include("QMUIButton.h")
@interface UIScaleFontButton : QMUIButton
#else
@interface UIScaleFontButton : UIButton
#endif

@property (nonatomic, strong) IBInspectable UIFont *scaleFont;

@end

NS_ASSUME_NONNULL_END
