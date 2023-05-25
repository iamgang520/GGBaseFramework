//
//  GGMediaSelectManager.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/4/12.
//

#import "GGMediaSelectManager.h"
#import <PhotosUI/PhotosUI.h>
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetImageGenerator.h>
#import <AVFoundation/AVTime.h>
#import "VideoTools.h"

@interface GGMediaSelectManager ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, strong) GGMediaSelectCompltionBlock compltion;

@property (nonatomic, assign) NSTimeInterval videoMaxTimeLength;

@end

@implementation GGMediaSelectManager

+ (GGMediaSelectManager *)shared
{
    static GGMediaSelectManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)selectMediaWithMediaType:(GGMediaType)mediaType
                      sourceType:(GGSourceType)sourceType
                  maxSelectCount:(NSInteger)maxSelectCount
                       compltion:(GGMediaSelectCompltionBlock)compltion
{
    [self selectMediaWithMediaType:mediaType sourceType:sourceType maxSelectCount:maxSelectCount videoTimeMax:10 * 60 compltion:compltion];
}

+ (void)selectMediaWithMediaType:(GGMediaType)mediaType
                      sourceType:(GGSourceType)sourceType
                  maxSelectCount:(NSInteger)maxSelectCount
                    videoTimeMax:(NSTimeInterval)videoTimeMax
                       compltion:(GGMediaSelectCompltionBlock)compltion
{
    [self shared].compltion = compltion;
    [self shared].videoMaxTimeLength = videoTimeMax;
    compltion = nil;
    
    [self showActionSheetWithSourceType:sourceType block:^(GGSourceType sourceType) {
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 14.0 && sourceType != GGSourceType_Camera && mediaType == GGMediaType_Photo) {
            if (@available(iOS 14.0, *)) {
                PHPickerConfiguration *config = [[PHPickerConfiguration alloc] init];
                config.selectionLimit = maxSelectCount > 0 ? maxSelectCount : 1;
                
                switch (mediaType) {
                    case GGMediaType_All:
                        config.filter = [PHPickerFilter anyFilterMatchingSubfilters:@[[PHPickerFilter imagesFilter], [PHPickerFilter videosFilter]]];
                        break;
                    case GGMediaType_Photo:
                        config.filter = [PHPickerFilter imagesFilter];
                        break;
                    case GGMediaType_Video:
                        config.filter = [PHPickerFilter videosFilter];
                        break;
                        
                    default:
                        break;
                }

                PHPickerViewController *pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:config];
                pickerViewController.delegate = [self shared];
                [[GGTools currentViewController] presentViewController:pickerViewController animated:YES completion:nil];
            }
        } else {
            
            UIImagePickerControllerSourceType selectSourceType = sourceType == GGSourceType_Camera ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = [GGMediaSelectManager shared];
            picker.allowsEditing = sourceType == GGSourceType_Camera;
            picker.videoMaximumDuration = videoTimeMax;
            NSArray *mediaTypes = nil;
            switch (mediaType) {
                case GGMediaType_All:
                    mediaTypes = [NSArray arrayWithObjects:@"public.movie", @"public.image",  nil];
                    break;
                case GGMediaType_Photo:
                    mediaTypes = [NSArray arrayWithObjects:@"public.image",  nil];
                    break;
                case GGMediaType_Video:
                    mediaTypes = [NSArray arrayWithObjects:@"public.movie",  nil];
                    break;
                    
                default:
                    break;
            }
            picker.mediaTypes = mediaTypes;
            picker.sourceType = selectSourceType;
            
            [picker setAllowsEditing:NO];
            [[GGTools currentViewController] presentViewController:picker animated:YES completion:nil];
        }
    }];
}

+ (NSString *)getVideoSaveUrlString
{
    NSString *library = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:[library stringByAppendingPathComponent:@"IMSDK"] isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        // 在 library 目录下创建一个 IMSDK 目录
        [fileManager createDirectoryAtPath:[library stringByAppendingPathComponent:@"IMSDK"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    existed = [fileManager fileExistsAtPath:[library stringByAppendingPathComponent:@"IMSDK/Video"] isDirectory:&isDir];
    if (!(isDir == YES && existed == YES) ) {
        // 在 IMSDK 目录下创建一个 Video 目录
        [fileManager createDirectoryAtPath:[library stringByAppendingPathComponent:@"IMSDK/Video"] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *kVideoSavePath = [library stringByAppendingPathComponent:@"IMSDK/Video/"];
    return kVideoSavePath;
}

+ (void)showActionSheetWithSourceType:(GGSourceType)sourceType block:(void (^)(GGSourceType sourceType))block
{
    if (sourceType != GGSourceType_Select) {
        block(sourceType);
        return;
    }
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        [GANGAlertView showMessageWithTitle:@"请选择" withMessage:nil withSureButton:@"相册" withSureBlock:^{
            block(GGSourceType_PhotoLibrary);
        } withCancelButton:@"相机" withCancelBlock:^{
            block(GGSourceType_Camera);
        }];
        
    } else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"请选择" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
        [alert addAction:[UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            block(GGSourceType_PhotoLibrary);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
            block(GGSourceType_Camera);
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }]];
        [[GGTools currentViewController] presentViewController:alert animated:YES completion:nil];
    }
}

    
    
    

#pragma mark -
#pragma mark - <PHPickerViewControllerDelegate>
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
API_AVAILABLE(ios(14)) {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    for (PHPickerResult *result in results)
   {
      // Get UIImage
       if ([result.itemProvider canLoadObjectOfClass:[UIImage class]]) {
           [result.itemProvider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error)
           {
              if ([object isKindOfClass:[UIImage class]])
              {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     // 图片
                     if (self.compltion) {
                         UIImage *image = object;
                         self.compltion(image);
                     }
                 });
              } else {
                  dispatch_async(dispatch_get_main_queue(), ^{
                      [GGProgressHUD showFailure:@"select image fail"];
                  });
              }
           }];
       } else {
           [GGProgressHUD showFailure:@"select image fail"];
       }
   }
}

#pragma mark -
#pragma mark - <UIImagePickerControllerDelegate>
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        // 图片
        if (self.compltion) {
            self.compltion([info objectForKey:UIImagePickerControllerOriginalImage]);
        }
        return;
    }
    NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
    if (!url) {
        // 该视频不存在或有误
        [GGProgressHUD showFailure:@"Video Error"];
        return;
    }
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:url options:nil];// url：网络视频的连接
    NSArray *arr = [avAsset tracksWithMediaType:AVMediaTypeVideo];// 项目中是明确媒体类型为视频，其他没试过

    long long dataLength = 0;
    for (AVAssetTrack *track in arr) {
        if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
            
            dataLength = track.totalSampleDataLength / 1024;
        }
    }
    
    // 小于10K，或大于50M
    if (dataLength < 10 || dataLength > 200 * 1024) {
        [GGProgressHUD showFailure:dataLength < 10 ? @"视频太小了" : @"视频大于200M，太大了，扛不住"];
        return;
    }
    CGFloat videoTime = CMTimeGetSeconds(avAsset.duration);
    if (videoTime > self.videoMaxTimeLength) {
        [GGProgressHUD showFailure:@"Video length exceeds limit"];
        return;
    }
    
    // 存到沙盒
    
    NSString *videoName = [NSString stringWithFormat:@"%@.mp4", [NSUUID UUID].UUIDString];
    NSString *documentDirectory = [[GGMediaSelectManager getVideoSaveUrlString] stringByAppendingPathComponent:videoName];
    
    NSURL *videoSaveURL = [NSURL fileURLWithPath:documentDirectory];
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = videoSaveURL;
    exportSession.outputFileType = AVFileTypeMPEG4; // mp4
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        AVAssetExportSessionStatus exportState = exportSession.status;
        switch (exportState) {
            case AVAssetExportSessionStatusFailed: // export failed
                // 主线程执行
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"获取视频失败");
                });
                break;
            case AVAssetExportSessionStatusCompleted: // finish
            {
                // 主线程执行
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.compltion) {
                        UIImage *firstImage = [VideoTools getVideoPreViewImage:url];
                        self.compltion(@{
                            @"type" : @(GGMediaType_Video),
                            @"url" : videoName ?: @"",
                            @"size" : [NSString stringWithFormat:@"%.fx%.f", firstImage ? firstImage.size.width : 1, firstImage ? firstImage.size.height : 1],
                            @"first_frame" : firstImage ?: [UIImage new],
                            @"time" : [NSString stringWithFormat:@"%.2f", videoTime]
                        });
                    }
                });
                
            }
                break;
            default:
                break;
        }
    }];
}

+ (CMVideoCodecType)videoCodecTypeForURL:(NSURL *)url {
    AVURLAsset *videoAsset = (AVURLAsset *)[AVURLAsset URLAssetWithURL:url
                               options:nil];
    
    NSArray *videoAssetTracks = [videoAsset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoAssetTrack = videoAssetTracks.firstObject;
    
    CMFormatDescriptionRef desc = (__bridge CMFormatDescriptionRef)videoAssetTrack.formatDescriptions.firstObject;
    CMVideoCodecType codec = CMVideoFormatDescriptionGetCodecType(desc);
    
    return codec;
}

#pragma mark -
#pragma mark - 工具

/// 指定宽度按比例缩放图片
+ (UIImage *) imageCompressForWidth:(UIImage *)sourceImage targetWidth:(CGFloat)defineWidth
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = defineWidth;
    CGFloat targetHeight = height / (width / targetWidth);
    CGSize size = CGSizeMake(targetWidth, targetHeight);
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    
    if (CGSizeEqualToSize(imageSize, size) == NO) {
        
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor) {
            scaleFactor = widthFactor;
        } else {
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        if (widthFactor > heightFactor) {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        } else if (widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    if(newImage == nil) {
        NSLog(@"scale image fail");
    }
    UIGraphicsEndImageContext();
    return newImage;
}


@end
