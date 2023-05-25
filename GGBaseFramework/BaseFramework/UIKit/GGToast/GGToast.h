//
//  GGToast.h
//
//  Created by iamgang on 2020/7/23.
//  Copyright © 2020 iamgang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, EGGToastLocation) {
    EGGToastLocation_Center,
    EGGToastLocation_Top,
    EGGToastLocation_Bottom
};

@interface GGToast : NSObject

+ (void)show:(NSString *)msg;
+ (void)show:(NSString *)msg location:(EGGToastLocation)location;
+ (void)show:(NSString *)msg location:(EGGToastLocation)location complete:(nullable void (^)(void))complete;
+ (void)show:(NSString *)msg location:(EGGToastLocation)location dismissTime:(NSTimeInterval)dismissTime;
+ (void)show:(NSString *)msg location:(EGGToastLocation)location dismissTime:(NSTimeInterval)dismissTime complete:(nullable void (^)(void))complete;

@end

NS_ASSUME_NONNULL_END
