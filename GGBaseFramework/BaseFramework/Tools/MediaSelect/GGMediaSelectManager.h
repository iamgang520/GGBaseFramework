//
//  GGMediaSelectManager.h
//  SUHelpSDK
//
//  Created by iamgang on 2022/4/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GGMediaType) {
    GGMediaType_All,
    GGMediaType_Photo,
    GGMediaType_Video,
};

typedef NS_ENUM(NSUInteger, GGSourceType) {
    GGSourceType_Select,    // 弹出选择器
    GGSourceType_PhotoLibrary, // 相册
    GGSourceType_Camera,    // 相机
};

typedef void (^GGMediaSelectCompltionBlock)(id __nullable media);

@interface GGMediaSelectManager : NSObject

+ (void)selectMediaWithMediaType:(GGMediaType)mediaType
                      sourceType:(GGSourceType)sourceType
                  maxSelectCount:(NSInteger)maxSelectCount
                       compltion:(GGMediaSelectCompltionBlock)compltion;

+ (void)selectMediaWithMediaType:(GGMediaType)mediaType
                      sourceType:(GGSourceType)sourceType
                  maxSelectCount:(NSInteger)maxSelectCount
                    videoTimeMax:(NSTimeInterval)videoTimeMax
                       compltion:(GGMediaSelectCompltionBlock)compltion;

/// 获取视频本地沙盒存储路径
+ (NSString *)getVideoSaveUrlString;

#pragma mark -
#pragma mark - 工具
/// 指定宽度按比例缩放图片
+ (UIImage *)imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth;

@end

NS_ASSUME_NONNULL_END
