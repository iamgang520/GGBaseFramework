//
//  UIScaleFontLabel.h
//  ChatSDK
//
//  Created by 欧布 on 2021/8/20.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import <UIKit/UIKit.h>
#if __has_include(<QMUIKit/QMUILabel.h>)
#import <QMUIKit/QMUILabel.h>
#elif __has_include("QMUILabel.h")
#import "QMUILabel.h"
#endif

NS_ASSUME_NONNULL_BEGIN

#if __has_include(<QMUIKit/QMUILabel.h>) || __has_include("QMUILabel.h")
@interface UIScaleFontLabel : QMUILabel
#else
@interface UIScaleFontLabel : UILabel
#endif

@end

NS_ASSUME_NONNULL_END
