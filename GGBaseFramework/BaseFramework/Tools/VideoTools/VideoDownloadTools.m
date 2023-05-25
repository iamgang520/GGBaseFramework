//
//  VideoDownloadTools.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/5/7.
//

#import "VideoDownloadTools.h"
#import "HttpManager.h"
#import "GGMediaSelectManager.h"

@interface VideoDownloadCallbackModel : NSObject

@property (nonatomic, strong, nullable) void (^progress)(NSString *videoUrl, int64_t completedUnitCount, int64_t totalUnitCount);
@property (nonatomic, strong, nullable) void (^complete)(NSString *videoUrl, NSError *_Nullable error, NSString *_Nullable videoLocUrl);

@end

@implementation VideoDownloadCallbackModel

@end

@interface VideoDownloadTools ()

/// 所有下载进度
@property (nonatomic, strong) NSMutableDictionary <NSString *, VideoDownloadCallbackModel *>*downloadsProgress;

@end

@implementation VideoDownloadTools

+ (instancetype)shared
{
    static VideoDownloadTools *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.downloadsProgress = [NSMutableDictionary dictionary];
    });
    return instance;
}

/// 是否在下载中
/// @param videoUrl videoUrl description
+ (BOOL)isDownloadingWithUrl:(NSString *)videoUrl
{
    NSString *videoName = [[[videoUrl componentsSeparatedByString:@"?"].firstObject componentsSeparatedByString:@"/"] lastObject];
    if ([[VideoDownloadTools shared].downloadsProgress objectForKey:videoName]) {
        return YES;
    }
    return NO;
}

/// 移除回调
+ (void)removeCallbackWithUrl:(NSString *)videoUrl
{
    NSString *videoName = [[[videoUrl componentsSeparatedByString:@"?"].firstObject componentsSeparatedByString:@"/"] lastObject];
    VideoDownloadCallbackModel *callbackModel = [[VideoDownloadTools shared].downloadsProgress objectForKey:videoName];
    if (callbackModel) {
        // 这里只是把回调清除，表示依然在下载该连接
        callbackModel.progress = nil;
        callbackModel.complete = nil;
    }
}

/// 下载视频
/// 如果本地下载好了，已经有了，就直接返回
/// @param videoUrl 远程视频url
/// @param progress 下载进度
/// @param complete 完成回调
+ (nullable NSString *)downloadVideoWithUrl:(NSString *)videoUrl
                                   progress:(nullable void (^)(NSString *videoUrl, int64_t completedUnitCount, int64_t totalUnitCount))progress
                                   complete:(nullable void (^)(NSString *videoUrl, NSError *_Nullable error, NSString *_Nullable videoLocUrl))complete
{
    if (!videoUrl || videoUrl.length == 0) {
        return nil;
    }
    NSString *videoName = [[[videoUrl componentsSeparatedByString:@"?"].firstObject componentsSeparatedByString:@"/"] lastObject];
    // 判断本地有没有
    NSString *sandboxSaveUrl = [GGMediaSelectManager getVideoSaveUrlString];
    NSString *videoLocPath = [NSString stringWithFormat:@"%@/%@", sandboxSaveUrl, videoName];
    
    NSFileManager *fileManger = [NSFileManager defaultManager];
    if ([fileManger fileExistsAtPath:videoLocPath]) {
        // 本地有视频
        [[VideoDownloadTools shared].downloadsProgress removeObjectForKey:videoName];
        return videoLocPath;
    }
    
    if (![videoUrl hasPrefix:@"http"]) {
        NSLog(@"不是有效的连接");
        
        if (complete) {
            NSDictionary *userInfo = @{NSLocalizedFailureReasonErrorKey: NSLocalizedStringFromTable(@"不是有效的视频下载链接.", @"VideoDownloadTools", nil)};
            NSError *error = [[NSError alloc] initWithDomain:@"VideoDownloadTools" code:NSURLErrorBadURL userInfo:userInfo];
            complete(videoUrl, error, nil);
        }
        return nil;
    }
    
    // 当前是否在下载中
    VideoDownloadTools *tool = [VideoDownloadTools shared];
    VideoDownloadCallbackModel *callbackModel = [tool.downloadsProgress objectForKey:videoName];
    if (!callbackModel) {
        callbackModel = [VideoDownloadCallbackModel new];
    }
    callbackModel.progress = progress;
    callbackModel.complete = complete;
    
    if (![tool.downloadsProgress objectForKey:videoName]) {
        // 去下载
        [tool.downloadsProgress setObject:callbackModel forKey:videoName];
        [tool downloadVideoWithUrl:videoUrl videoLocPath:videoLocPath];
    }
    return nil;
}

/// 下载视频
/// @param videoUrl 视频下载地址
/// @param videoLocPath 视频下载本地存放地址
- (void)downloadVideoWithUrl:(NSString *)videoUrl videoLocPath:(NSString *)videoLocPath
{
    NSString *videoName = [[[videoUrl componentsSeparatedByString:@"?"].firstObject componentsSeparatedByString:@"/"] lastObject];
    [HttpManager downloadFileWithUrlString:videoUrl fileSavePath:videoLocPath progressBlock:^(int64_t completedUnitCount, int64_t totalUnitCount) {
        VideoDownloadCallbackModel *callbackModel = [self.downloadsProgress objectForKey:videoName];
        if (callbackModel && callbackModel.progress) {
            callbackModel.progress(videoUrl, completedUnitCount, totalUnitCount);
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:kVideoDownloadProgressNotifationKey object:@{
                    @"url" : videoUrl ?: @"",
                    @"progress" : @(completedUnitCount * 1.0 / (totalUnitCount ?: 1))
        }];
        
    } callBack:^(RequestStatusCode requestStatusCode, id  _Nullable JSON) {
        VideoDownloadCallbackModel *callbackModel = [self.downloadsProgress objectForKey:videoName];
        if (callbackModel && callbackModel.complete) {
            
            if (requestStatusCode == RequestStatusCode_OK) {
                NSString *sandboxSaveUrl = [GGMediaSelectManager getVideoSaveUrlString];
                NSString *videoLocPath = [NSString stringWithFormat:@"%@/%@", sandboxSaveUrl, videoName];
                callbackModel.complete(videoUrl, nil, videoLocPath);
            } else {
                callbackModel.complete(videoUrl, JSON, nil);
            }
        }
        [self.downloadsProgress removeObjectForKey:videoName];
    }];
}

@end
