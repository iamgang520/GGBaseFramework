//
//  UIScaleFontButton.m
//  ChatSDK
//
//  Created by 欧布 on 2021/8/20.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import "UIScaleFontButton.h"
#import "UIScaleFontLabel.h"

@interface UIScaleFontButton ()

@property (nonatomic, assign) CGFloat originalFontSize;

@end

@implementation UIScaleFontButton

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeFontScale) name:kFontScaleChangeNSNotificationKey object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setScaleFont:self.titleLabel.font];
}

- (void)setScaleFont:(UIFont *)scaleFont
{
    _scaleFont = scaleFont;
    if (!_originalFontSize) {
        _originalFontSize = scaleFont.pointSize;
    }
    UIFont *scaleFont1 = [scaleFont fontWithSize:_originalFontSize * [BaseUIConfig shared].fontScale];
    [self.titleLabel setFont:scaleFont1];
}

- (void)didChangeFontScale
{
    [self setScaleFont:self.scaleFont];
}


@end
