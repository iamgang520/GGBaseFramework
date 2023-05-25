//
//  VideoDownloadTools.h
//  SUHelpSDK
//
//  Created by iamgang on 2022/5/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 可监听此通知，获取对应URL下载进度
/// noti.object = {
///     @"url" : url,
///     @"progress" : 0.3
/// }
static NSString * const kVideoDownloadProgressNotifationKey = @"kVideoDownloadProgressNotifationKey";

@interface VideoDownloadTools : NSObject

/// 是否在下载中
/// @param videoUrl videoUrl description
+ (BOOL)isDownloadingWithUrl:(NSString *)videoUrl;

/// 移除回调
+ (void)removeCallbackWithUrl:(NSString *)videoUrl;

/// 下载视频
/// 如果本地下载好了，已经有了，就直接返回
/// @param videoUrl 远程视频url
/// @param progress 下载进度
/// @param complete 完成回调
+ (nullable NSString *)downloadVideoWithUrl:(NSString *)videoUrl
                                   progress:(nullable void (^)(NSString *videoUrl, int64_t completedUnitCount, int64_t totalUnitCount))progress
                                   complete:(nullable void (^)(NSString *videoUrl, NSError *_Nullable error, NSString *_Nullable videoLocUrl))complete;

@end

NS_ASSUME_NONNULL_END
