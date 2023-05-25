//
//  BaseLogConfig.h
//  GGBaseFramework
//
//  Created by iamgang on 2022/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define NSLog(FORMAT, ...) do { \
    if (BaseLogConfig.isShowLog) {\
        fprintf(stderr, "%s:%d\t%s\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:@"%@", [NSDate date]] UTF8String], [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);\
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NSLog" object:[NSString stringWithFormat: FORMAT, ## __VA_ARGS__]];\
    } else{}\
} while (0);

/// 是否打印log信息, 默认不打印
@interface BaseLogConfig : NSObject

/// 获取SDK版本号：用于公共服务网络请求上传
@property (nonatomic, class) BOOL isShowLog;

@end

NS_ASSUME_NONNULL_END
