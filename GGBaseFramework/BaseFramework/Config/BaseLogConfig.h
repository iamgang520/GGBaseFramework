//
//  BaseLogConfig.h
//  GGBaseFramework
//
//  Created by iamgang on 2022/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 是否打印log信息, 默认不打印
extern BOOL kIsShowLog;

#define NSLog(FORMAT, ...) do { \
    if (kIsShowLog) {\
        fprintf(stderr, "%s:%d\t%s\t%s\n", [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:@"%@", [NSDate date]] UTF8String], [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);\
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NSLog" object:[NSString stringWithFormat: FORMAT, ## __VA_ARGS__]];\
    } else{}\
} while (0);

NS_ASSUME_NONNULL_END
