//
//  BaseUIConfig.h
//  SUHelpSDK
//
//  Created by iamgang on 2022/3/24.
//

#import <Foundation/Foundation.h>

#pragma mark - 宏
// Color
#define RGB(r,g,b)                  [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:1.f]
#define RGBA(r,g,b,a)               [UIColor colorWithRed:r / 255.f green:g / 255.f blue:b / 255.f alpha:a]
#define RGB_HEX(hex)                RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),1.f)
#define RGBA_HEX(hex,a)             RGBA((float)((hex & 0xFF0000) >> 16),(float)((hex & 0xFF00) >> 8),(float)(hex & 0xFF),a)

#define COLOR_111111                RGB_HEX(0x111111)
#define COLOR_333333                RGB_HEX(0x333333)
#define COLOR_666666                RGB_HEX(0x666666)
#define COLOR_838383                RGB_HEX(0x838383)
#define COLOR_999999                RGB_HEX(0x999999)
#define COLOR_DDDDDD                RGB_HEX(0xDDDDDD)
#define COLOR_F5F5F9                RGB_HEX(0xF5F5F9)
#define COLOR_A9A9A9                RGB_HEX(0xA9A9A9)

#define SCALE_FONT_SIZE(S) (MIN(MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height), 450.f) / 375.f * S)

#pragma mark - 通知
// 通知字体缩放比例更改
#define kFontScaleChangeNSNotificationKey @"kFontScaleChangeNSNotificationKey"

NS_ASSUME_NONNULL_BEGIN

@interface BaseUIConfig : NSObject

+ (instancetype)shared;
#pragma mark - 主题
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, assign) BOOL isWhiteNavBar;

#pragma mark - 字体缩放
/// 字体缩放比例
@property (nonatomic, assign) CGFloat fontScale;

#pragma mark - Navgation
/// NavgationTitle Font
@property (nonatomic, strong) UIFont *titleFont;

@end

NS_ASSUME_NONNULL_END
