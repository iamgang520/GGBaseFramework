//
//  GGTools.h
//  飞天钱包
//
//  Created by iamGG on 2020/11/20.
//

#import <UIKit/UIKit.h>
#import "MD5Encrypt.h"

NS_ASSUME_NONNULL_BEGIN

@interface GGTools : NSObject

/// 获取当前屏幕方向
+ (UIInterfaceOrientation)getInterfaceOrientation;
/// 旋转屏幕方向
/// @param orientation orientation description
+ (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation;

+ (NSBundle *)getSDKBundle;

+ (nullable NSDictionary *)getSDKInfoPlist;
/// 获取SDK包中图片
+ (nullable UIImage *)getSDKImageWithName:(NSString *)imgName;

+ (UIEdgeInsets)getSafeAreaInsets;
/// 获取底部安全区域
+ (CGFloat)getSafeAreaInsetsBottom;

/// 获取调用位置信息
+ (NSString *)getCallLineString;
/// 获取当前时间
+ (NSString*)getCurrentTimesWithFormat:(NSString *)format;
+ (NSString*)getCurrentTimes;

/// 获取电量
+ (float)getBatteryLevel;

/// 获取电池状态
+ (UIDeviceBatteryState)getBatteryState;

/// 获取当前窗口
+ (UIWindow *)getCurrentWindow;

///获取手机当前显示的ViewController
+ (UIViewController *)currentViewController;

/// 生成富文本
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetString:(NSString *)targetString;
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetString:(NSString *)targetString targetColor:(UIColor *)targetColor;
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetStrings:(NSArray <NSString *> *)targetStrings targetColor:(UIColor *)targetColor;
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetStrings:(NSArray <NSString *> *)targetStrings font:(nullable UIFont *)font;
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetStrings:(NSArray <NSString *> *)targetStrings targetColor:(nullable UIColor *)targetColor font:(nullable UIFont *)font;
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetString:(NSString *)targetString targetColor:(UIColor *)targetColor targetFont:(UIFont *)targetFont;

/// 转换为星期几
+ (NSString *)getWeekCNString:(NSInteger)week;

/// 是否是模拟器
+ (BOOL)isSimuLator;

/// 身份证效验
/// 目前只校验格式，不校验有效性
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString;

/// 清除所有存储数据
+ (void)clearAllUserDefaultsData;

/// 手机序列号
+ (NSString *)getPhoneIdentifier;
/// 获取BundleIdentifier
+ (NSString*)getBundleID;
/// 获取app的名字
+ (NSString*)getAppName;
/// app版本
+ (NSString *)getShortVersionString;
/// 获取设备名称
+ (NSString *)getDeviceModel;
/// 获取系统版本
+ (NSString *)getSysVersion;
/// 获取设备当前地区的代码
+ (NSString *)getLocaleIdentifier;
/// 获取设备当前语言的代码
+ (NSString *)getLanguage;
/// 获取中的存储空间
+ (float)getTotalDiskSpace;
+ (NSString *)getTotalDiskSpaceString;
/// 获取可用存储空间
+ (float)getFreeDiskSpace;
+ (NSString *)getFreeDiskSpaceString;
/// 获取总内存
+ (int64_t)getTotalMemory;
+ (NSString *)getTotalMemoryString;
/// 获取可用内存
+ (long long)getAvailableMemory;
+ (NSString *)getAvailableMemoryString;
/// 获取网络类型
+ (NSString *)getNetType;
/// 获取网络运营商
+ (NSString *)getCarrierInfo;

/// 获取微信支付URLScheme
/// 默认key为:wxPay
+ (NSString *)getPayURLScheme;

/// 获取URLScheme
/// @param key 对应key
+ (NSString *)getURLSchemeWithKey:(NSString *)key;

@end

typedef NS_ENUM(NSInteger, GGOrientation) {
    GGOrientation_Horizontal,
    GGOrientation_Vertical,
};
@interface UIView (GGLayer)
/**
 圆角
 使用自动布局，需要在layoutsubviews 中使用
 @param radius 圆角尺寸
 @param corner 圆角位置
 */
- (void)gg_radiusWithRadius:(CGFloat)radius corner:(UIRectCorner)corner;

/// 创建渐变背景色
- (void)gg_gradientWithOrientation:(GGOrientation)orientation beginColor:(UIColor *)beginColor endColor:(UIColor *)endColor;

@end

@interface NSString (GGFormat)

/// 格式化小数点后两位小数
- (NSString *)GG_formatDecimalString;

/// json转Object
- (id)jsonStringToObject;

/// 去掉头尾空格及换行
- (NSString *)removeSpaceAndNewline;

/// 查找文本（所有）
- (NSArray<NSString *> *)foundStringRanges:(NSString *)foundString;

@end

@interface NSDictionary (JsonCategory)

/// 转jsonString
- (NSString *)toJsonString;
@end

@interface NSArray (JsonCategory)

/// 转jsonString
- (NSString *)toJsonString;
@end

@interface NSObject (GGFormat)

/// 格式化小数点后两位小数
/// 用于保护，防止NSString去调用上面方法的实际调用者不是NSString
- (NSString *)GG_formatDecimalString;

@end

@interface UIImage (GGCategory)

/**
 修正图片，使其显示方向正确
 */
- (UIImage *)fixOriginalImage;

@end

@interface UIButton (GGCategory)

- (void)verticalImageAndTitle:(CGFloat)spacing;

@end

@interface UIColor (GGCategory)

- (UIImage *)toImage;

@end


NS_ASSUME_NONNULL_END
