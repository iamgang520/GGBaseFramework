//
//  GGTools.m
//  飞天钱包
//
//  Created by iamGG on 2020/11/20.
//

#import "GGTools.h"
#import <sys/utsname.h>//要导入头文件
#import <mach/mach.h>
#import "GGBaseHook.h"

// 网络相关
#import "Reachability.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>

#if __has_include(<YYImage/YYAnimatedImageView.h>)
#import <YYImage/YYAnimatedImageView.h>
#elif __has_include("YYAnimatedImageView.h")
#import "YYAnimatedImageView.h"
#endif

@implementation GGTools

/// 旋转屏幕方向
/// @param orientation orientation description
+ (void)setInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];
    [[UIDevice currentDevice] setValue:@(orientation) forKey:@"orientation"];
}

/// 获取当前屏幕方向
+ (UIInterfaceOrientation)getInterfaceOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    return orientation;
}

+ (NSBundle *)getSDKBundle
{
    return [NSBundle bundleForClass:self];
}

+ (nullable NSDictionary *)getSDKInfoPlist
{
    return [self getSDKBundle].infoDictionary;
}

+ (nullable UIImage *)getSDKImageWithName:(NSString *)imgName
{
    NSBundle *myBundle = [self getSDKBundle];
    return [UIImage imageNamed:imgName inBundle:myBundle compatibleWithTraitCollection:nil];
}

+ (UIEdgeInsets)getSafeAreaInsets
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        edgeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    }
    return edgeInsets;
}

+ (CGFloat)getSafeAreaInsetsBottom
{
    return [self getSafeAreaInsets].bottom;
}

/// 获取调用位置信息
+ (NSString *)getCallLineString
{
    NSString *callLine = @"";
    NSArray *syms = [NSThread  callStackSymbols];
    if ([syms count] > 2) {
        callLine = [syms objectAtIndex:2];
        if ([callLine componentsSeparatedByString:@" +["].count > 1) {
            callLine = [callLine componentsSeparatedByString:@" +["][1];
        }
        callLine = [callLine stringByReplacingOccurrencesOfString:@" + " withString:@" line:"];
        if ([callLine rangeOfString:@" -"].location != NSNotFound && [callLine componentsSeparatedByString:@" -"].count > 1) {
            callLine = [callLine componentsSeparatedByString:@" -"][1];
        }
        callLine = [NSString stringWithFormat:@"%@", callLine];
    }
    return callLine;
}

+ (NSString*)getCurrentTimesWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *datenow = [NSDate date];
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}

+ (NSString*)getCurrentTimes
{
    return [self getCurrentTimesWithFormat:@"YYYY-MM-dd HH:mm:ss"];
}

+ (float)getBatteryLevel
{
    [UIDevice currentDevice].batteryMonitoringEnabled = YES;
    float deviceLevel = [UIDevice currentDevice].batteryLevel;
    if (deviceLevel < 0) {
        deviceLevel = 1.f;
    }
    return deviceLevel;
}

+ (UIDeviceBatteryState)getBatteryState
{
    NSInteger batteryState = [[UIDevice currentDevice] batteryState];
    return batteryState;
}

+ (UIWindow *)getCurrentWindow
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication].windows firstObject];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    if (![window subviews] || [window subviews].count == 0) {
        return [[UIApplication sharedApplication].windows firstObject];
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result.view.window ?: [[UIApplication sharedApplication].windows firstObject];
}

+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetString:(NSString *)targetString
{
    return [self getAttrWithString:originString targetString:targetString targetColor:[UIColor systemBlueColor]];
}

+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetString:(NSString *)targetString targetColor:(UIColor *)targetColor
{
    if (!originString) {
        originString = @"";
    }
    if (!targetString) {
        targetString = @"";
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:originString];
    NSDictionary *attriDic = @{NSForegroundColorAttributeName:targetColor};
    NSRange searchRange = NSMakeRange(0, originString.length);
    while (searchRange.location != NSNotFound) {
        searchRange = [originString rangeOfString:targetString options:0 range:searchRange];
        [attr setAttributes:attriDic range:searchRange];
        if(searchRange.location != NSNotFound){
            searchRange = NSMakeRange(searchRange.location + targetString.length, originString.length - searchRange.location - targetString.length);
        }
    }
    return attr;
}

+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetString:(NSString *)targetString targetColor:(UIColor *)targetColor targetFont:(UIFont *)targetFont
{
    if (!originString) {
        originString = @"";
    }
    if (!targetString) {
        targetString = @"";
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:originString];
    NSDictionary *attriDic = @{NSForegroundColorAttributeName:targetColor, NSFontAttributeName : targetFont};
    NSRange searchRange = NSMakeRange(0, originString.length);
    while (searchRange.location != NSNotFound) {
        searchRange = [originString rangeOfString:targetString options:0 range:searchRange];
        [attr setAttributes:attriDic range:searchRange];
        if(searchRange.location != NSNotFound){
            searchRange = NSMakeRange(searchRange.location + targetString.length, originString.length - searchRange.location - targetString.length);
        }
    }
    return attr;
}
+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetStrings:(NSArray <NSString *> *)targetStrings targetColor:(UIColor *)targetColor
{
    return [self getAttrWithString:originString targetStrings:targetStrings targetColor:targetColor font:nil];
}

+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetStrings:(NSArray <NSString *> *)targetStrings font:(nullable UIFont *)font
{
    return [self getAttrWithString:originString targetStrings:targetStrings targetColor:nil font:font];
}

+ (NSMutableAttributedString *)getAttrWithString:(NSString *)originString targetStrings:(NSArray <NSString *> *)targetStrings targetColor:(nullable UIColor *)targetColor font:(nullable UIFont *)font
{
    if (!originString) {
        originString = @"";
    }
    if (!targetStrings) {
        targetStrings = @[];
    }
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:originString];
    NSMutableDictionary *attriDic = [NSMutableDictionary dictionary];
    if (targetColor) {
        [attriDic setObject:targetColor forKey:NSForegroundColorAttributeName];
    }
    if (font) {
        [attriDic setObject:font forKey:NSFontAttributeName];
    }
    
    [targetStrings enumerateObjectsUsingBlock:^(NSString * _Nonnull targetString, NSUInteger idx, BOOL * _Nonnull stop) {
        NSRange searchRange = NSMakeRange(0, originString.length);
        while (searchRange.location != NSNotFound) {
            searchRange = [originString rangeOfString:targetString options:0 range:searchRange];
            [attr setAttributes:attriDic range:searchRange];
            if(searchRange.location != NSNotFound){
                searchRange = NSMakeRange(searchRange.location + targetString.length, originString.length - searchRange.location - targetString.length);
            }
        }
    }];
    
    return attr;
}

/// 转换为星期几
+ (NSString *)getWeekCNString:(NSInteger)week
{
    switch (week) {
        case 1:
            return @"星期日";
            case 2:
            return @"星期一";
            case 3:
            return @"星期二";
            case 4:
            return @"星期三";
            case 5:
            return @"星期四";
            case 6:
            return @"星期五";
            case 7:
            return @"星期六";
            
        default:
            break;
    }
    return @"";
}

///获取手机当前显示的ViewController
+ (UIViewController*)currentViewController
{
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    NSInteger count = 0;
    while (count < 100) {
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        } else{
            break;
        }
        count ++;
    }
    return vc;
}

/// 手机序列号
+ (NSString *)getPhoneIdentifier
{
    return nil;
}
    
/// app版本
+ (NSString *)getShortVersionString
{
    NSString *app_Version = [[self getBundleDictionary] objectForKey:@"CFBundleShortVersionString"];
    return app_Version;
}

/// 获取设备名称
+ (NSString *)getDeviceModel
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
       
    if ([deviceModel isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceModel isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceModel isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceModel isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceModel isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceModel isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceModel isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceModel isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceModel isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceModel isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceModel isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceModel isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceModel isEqualToString:@"iPhone10,1"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,4"])   return @"iPhone_8";
    if ([deviceModel isEqualToString:@"iPhone10,2"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,5"])   return @"iPhone_8_Plus";
    if ([deviceModel isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceModel isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceModel isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceModel isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";
    if ([deviceModel isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceModel isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceModel isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone12,8"])   return @"iPhone SE2";
    if ([deviceModel isEqualToString:@"iPhone13,1"])   return @"iPhone 12 Mini";
    if ([deviceModel isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceModel isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceModel isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";
    if ([deviceModel isEqualToString:@"iPhone14,4"])   return @"iPhone 13 Mini";
    if ([deviceModel isEqualToString:@"iPhone14,5"])   return @"iPhone 13";
    if ([deviceModel isEqualToString:@"iPhone14,2"])   return @"iPhone 13 Pro";
    if ([deviceModel isEqualToString:@"iPhone14,3"])   return @"iPhone 13 Pro Max";
    if ([deviceModel isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceModel isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceModel isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceModel isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceModel isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";
    if ([deviceModel isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceModel isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceModel isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceModel isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceModel isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceModel isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceModel isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceModel isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceModel isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceModel isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceModel isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceModel isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    if ([deviceModel isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceModel isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceModel isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    if ([deviceModel isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceModel isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceModel isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";

    if ([deviceModel isEqualToString:@"AppleTV2,1"])      return @"Apple TV 2";
    if ([deviceModel isEqualToString:@"AppleTV3,1"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV3,2"])      return @"Apple TV 3";
    if ([deviceModel isEqualToString:@"AppleTV5,3"])      return @"Apple TV 4";

    if ([deviceModel isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceModel isEqualToString:@"x86_64"])       return @"Simulator";
    
    return deviceModel;
}

/// 获取系统版本
+ (NSString *)getSysVersion
{
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSDictionary *)getBundleDictionary
{
    return [[NSBundle mainBundle] infoDictionary];
}

/// 获取设备当前地区的代码
+ (NSString *)getLocaleIdentifier
{
    NSString *localeIdentifier = [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
    return localeIdentifier ?: @"";
}

/// 获取设备当前语言的代码
+ (NSString *)getLanguage
{
    NSString *preferredLanguage = [[[NSBundle mainBundle] preferredLocalizations] firstObject];
    return preferredLanguage ?: @"";
}

/// 获取中的存储空间
+ (float)getTotalDiskSpace
{
    float totalsize = 0.0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary)
    {
       NSNumber *_total = [dictionary objectForKey:NSFileSystemSize];
       totalsize = [_total unsignedLongLongValue]*1.0;
    } else
    {
       NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalsize;
}

+ (NSString *)getTotalDiskSpaceString
{
    float total = [self getTotalDiskSpace];
    return [NSString stringWithFormat:@"%.f GB", total / (1000. * 1000 * 1000)];
}

/// 获取可用存储空间
+ (float)getFreeDiskSpace
{
    float freesize = 0.0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary)
    {
       NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
       freesize = [_free unsignedLongLongValue] * 1.0;
    } else
    {
       NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return  freesize;
}

+ (NSString *)getFreeDiskSpaceString
{
    float free = [UIDevice jk_freeDiskSpaceBytes];
    return [NSString stringWithFormat:@"%.2f GB", free / (1000. * 1000 * 1000)];
}

+ (int64_t)getTotalMemory {
    int64_t totalMemory = [[NSProcessInfo processInfo] physicalMemory];
    if (totalMemory < -1) totalMemory = -1;
    return totalMemory;
}

+ (NSString *)getTotalMemoryString
{
    return [NSString stringWithFormat:@"%.f GB", [self getTotalMemory] / (1000. * 1000 * 1000)];
}

// 获取当前可用内存
+ (long long)getAvailableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if (kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count + vm_page_size * vmStats.inactive_count));
}

+ (NSString *)getAvailableMemoryString
{
    return [NSString stringWithFormat:@"%.2f GB", [self getAvailableMemory] / (1000. * 1000 * 1000)];
}
 
+ (NSString *)getNetType
{
    NSString *currentNet = @"未知";
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.apple.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:// 没有网络
        {
            currentNet = @"无网络";
        }
            break;
            
        case ReachableViaWiFi:// Wifi
        {
            currentNet = @"WIFI";
        }
            break;
            
        case ReachableViaWWAN:// 手机自带网络
        {
            CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
            /// 注意：没有SIM卡，值为空
            NSString *currentStatus;
            if (@available(iOS 12.1, *)) {
                if (info && [info respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
                    NSDictionary *radioDic = [info serviceCurrentRadioAccessTechnology];
                    if (radioDic.allKeys.count) {
                        currentStatus = [radioDic objectForKey:radioDic.allKeys[0]];
                    }
                }
            }else{
                currentStatus = info.currentRadioAccessTechnology;
            }
            
            if ([currentStatus isEqualToString:CTRadioAccessTechnologyGPRS]) {
                currentNet = @"GPRS";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyEdge]) {
                currentNet = @"2.75G EDGE";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyWCDMA]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSDPA]){
                currentNet = @"3.5G HSDPA";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyHSUPA]){
                currentNet = @"3.5G HSUPA";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMA1x]){
                currentNet = @"2G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]){
                currentNet = @"3G";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyeHRPD]){
                currentNet = @"HRPD";
            }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyLTE]){
                currentNet = @"4G";
            }else if (@available(iOS 14.1, *)) {
                if ([currentStatus isEqualToString:CTRadioAccessTechnologyNRNSA]){
                    currentNet = @"5G NSA";
                }else if ([currentStatus isEqualToString:CTRadioAccessTechnologyNR]){
                    currentNet = @"5G";
                }
            }
        }
            break;
            
        default:
            break;
    }
    return currentNet ?: @"未知";
}

/// 获取网络运营商
+ (NSString *)getCarrierInfo
{
    CTTelephonyNetworkInfo *telephonyInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [telephonyInfo subscriberCellularProvider];
    NSString *carrierName = [carrier carrierName];
    return carrierName ?: @"未知";
}



/// 是否是模拟器
+ (BOOL)isSimuLator
{
    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        //模拟器
        return YES;
    }else{
        //真机
        return NO;
    }
}

/// 身份证效验
/// 目前只校验格式，不校验有效性
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString {

    if (!identityString || identityString.length != 18) return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X|x)$";
  //  NSString *regex = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    BOOL isJiaoyanYouxiaoxing = NO;
    if (!isJiaoyanYouxiaoxing) {
        return [identityStringPredicate evaluateWithObject:identityString];
    }
    
    if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
    
    //** 开始进行校验 *//
    
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
    }
    
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if(idCardMod==2) {
        if(![idCardLast isEqualToString:@"X"]|| ![idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    }
    else{
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;
}

/// 清除所有存储数据
+ (void)clearAllUserDefaultsData
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dic = [userDefaults dictionaryRepresentation];
    for(id key in dic){
        [userDefaults removeObjectForKey:key];
    }
    [userDefaults synchronize];
}

/// 获取BundleIdentifier
+ (NSString*)getBundleID
{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}
 
/// 获取app的名字
+ (NSString*)getAppName
{
    NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
    return appName ?: @"";
}

+ (NSString *)getPayURLScheme
{
    return [self getURLSchemeWithKey:@"payScheme"];
}

+ (NSString *)getURLSchemeWithKey:(NSString *)key
{
    if (!key) {
        return nil;
    }
    NSArray *bundleUrltypes = [[self getBundleDictionary] objectForKey:@"CFBundleURLTypes"];
    
    for (NSDictionary *dic in bundleUrltypes) {
        if ([[dic objectForKey:@"CFBundleURLName"] isEqualToString:key]) {
            return [[dic objectForKey:@"CFBundleURLSchemes"] firstObject];
        }
    }
    return nil;
}

@end

@implementation UIView (GGLayer)
/**
 圆角
 使用自动布局，需要在layoutsubviews 中使用
 @param radius 圆角尺寸
 @param corner 圆角位置
 */
- (void)gg_radiusWithRadius:(CGFloat)radius corner:(UIRectCorner)corner {
    if (@available(iOS 11.0, *)) {
        self.layer.cornerRadius = radius;
        self.layer.maskedCorners = (CACornerMask)corner;
    } else {
        UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = path.CGPath;
        self.layer.mask = maskLayer;
    }
    if ([self isKindOfClass:[UILabel class]]) {
        self.layer.masksToBounds = YES;
    }
}

/// 创建渐变背景色
- (void)gg_gradientWithOrientation:(GGOrientation)orientation beginColor:(UIColor *)beginColor endColor:(UIColor *)endColor
{
    [self layoutIfNeeded];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = @[(__bridge id)beginColor.CGColor, (__bridge id)endColor.CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = orientation == GGOrientation_Horizontal ? CGPointMake(1.0, 0) : CGPointMake(0, 1.0);
    gradientLayer.frame = self.bounds;
    [self.layer addSublayer:gradientLayer];
}

@end

@implementation NSString (GGFormat)

/// 格式化小数点后两位小数
- (NSString *)GG_formatDecimalString
{
    if (!self) {
        return @"";
    }
    if ([self containsString:@"."]) {
        
        if ([self hasSuffix:@".00"]) {
            return [[self componentsSeparatedByString:@"."] firstObject];
        } else if ([self hasSuffix:@"0"]) {
            return [self substringToIndex:self.length - 1];
        }
    }
    return self;
}

/// json转Object
- (id)jsonStringToObject
{
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return @{
            @"string": self
        };
    }
    return dic;
}

/// 去掉头尾空格及换行
- (NSString *)removeSpaceAndNewline
{
    NSString *temp = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *text = [temp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return text;
}
    
- (NSArray<NSString *> *)foundStringRanges:(NSString *)foundString
{
    if (!foundString || ![foundString isKindOfClass:[NSString class]] || foundString.length == 0) {
        return @[];
    }
    NSMutableArray *array = [NSMutableArray array];
    NSRange searchRange = NSMakeRange(0,self.length);
    NSRange foundRange;
    while (searchRange.location < self.length) {
        searchRange.length = self.length - searchRange.location;
        foundRange = [self rangeOfString:foundString options:NSCaseInsensitiveSearch range:searchRange];
        if (foundRange.location != NSNotFound) {
            // found an occurrence of the substring! do stuff here
            searchRange.location = foundRange.location + foundRange.length;
            
            [array addObject:NSStringFromRange(foundRange)];
        } else {
            // no more substring to find
            break;
        }
    }
    return array;
}

@end


@implementation NSDictionary (JsonCategory)

/// 转jsonString
- (NSString *)toJsonString
{
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingFragmentsAllowed // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
@end

@implementation NSArray (JsonCategory)

/// 转jsonString
- (NSString *)toJsonString
{
    NSString *jsonString = @"";
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingFragmentsAllowed // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
@end


@implementation NSObject (GGFormat)

/// 格式化小数点后两位小数
/// 用于保护，防止NSString去调用上面方法的实际调用者不是NSString
- (NSString *)GG_formatDecimalString
{
    return [NSString stringWithFormat:@"%@", self];
}

@end

#if __has_include(<YYImage/YYAnimatedImageView.h>) || __has_include("YYAnimatedImageView.h")

@implementation YYAnimatedImageView (IOS14)

+ (void)load
{
    [GGBaseHook baseHookMehodWithOldClass:self oldSEL:@selector(displayLayer:) newClass:self andNew:@selector(new_displayLayer:)];
}

- (void)new_displayLayer:(CALayer*)layer {

    UIImage *currentFrame = [self valueForKey:@"_curFrame"];
    if(!currentFrame) {
        currentFrame = self.image;
    }
    if(currentFrame) {
        layer.contentsScale = currentFrame.scale;
        layer.contents = (__bridge id)currentFrame.CGImage;
    }
}

@end

#endif

@implementation UIImage (GGCategory)

/**
 修正图片，使其显示方向正确
 */
- (UIImage *)fixOriginalImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

@end

@implementation UIButton (GGCategory)

- (void)verticalImageAndTitle:(CGFloat)spacing
{
    self.titleLabel.backgroundColor = [UIColor greenColor];
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:self.titleLabel.font}];
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width) {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
    
}

@end

@implementation UIColor (GGCategory)

- (UIImage *)toImage
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [self CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
