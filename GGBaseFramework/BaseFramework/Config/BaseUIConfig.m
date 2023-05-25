//
//  BaseUIConfig.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/3/24.
//

#import "BaseUIConfig.h"

@implementation BaseUIConfig

+ (void)load
{
    [self shared];
}

+ (instancetype)shared
{
    static BaseUIConfig *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initConfig];
    });
    return instance;
}

- (void)initConfig
{
    _fontScale = [[NSUserDefaults standardUserDefaults] floatForKey:@"BaseConfig_fontScale"] ?: 1.f;
    
#pragma mark - 主题颜色
    self.themeColor = [UIColor systemRedColor];
    self.titleColor = COLOR_333333;
    self.isWhiteNavBar = YES;
    
#pragma mark - NavBar
    self.titleFont = [UIFont boldSystemFontOfSize:SCALE_FONT_SIZE(18)];
    
#pragma mark - UISwitch
#if __has_include(<QMUIKit/QMUIKit.h>)
    QMUICMI.switchOnTintColor = self.themeColor;
#endif
    
#pragma mark - UISlider
    [[UISlider appearance] setTintColor:self.themeColor];
    
#pragma mark - UIProgressView
    [[UIProgressView appearance] setTintColor:self.themeColor];
}

- (void)setFontScale:(CGFloat)fontScale
{
    _fontScale = fontScale;
    [[NSUserDefaults standardUserDefaults] setFloat:fontScale forKey:@"BaseConfig_fontScale"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kFontScaleChangeNSNotificationKey object:nil];
}

@end
