//
//  VideoTools.h
//  SUHelpSDK
//
//  Created by iamgang on 2022/3/30.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoTools : NSObject

// 获取视频第一帧
+ (UIImage*)getVideoPreViewImage:(NSURL *)path;

@end

NS_ASSUME_NONNULL_END
