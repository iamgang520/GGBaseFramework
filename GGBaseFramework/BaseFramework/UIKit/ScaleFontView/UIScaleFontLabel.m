//
//  UIScaleFontLabel.m
//  ChatSDK
//
//  Created by 欧布 on 2021/8/20.
//  Copyright © 2021年 星合互娱 All rights reserved.
//

#import "UIScaleFontLabel.h"

@interface UIScaleFontLabel ()

@property (nonatomic, assign) CGFloat originalFontSize;

@end

@implementation UIScaleFontLabel

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeFontScale) name:kFontScaleChangeNSNotificationKey object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _originalFontSize = 0;
    }
    return self;
}

+ (instancetype)new
{
    return [[self alloc] init];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setFont:self.font];
}

- (void)setFont:(UIFont *)font
{
    if (!_originalFontSize) {
        _originalFontSize = font.pointSize;
    }
    UIFont *scaleFont = [font fontWithSize:_originalFontSize * [BaseUIConfig shared].fontScale];
    [super setFont:scaleFont];
}

- (void)didChangeFontScale
{
    [self setFont:self.font];
}


@end
