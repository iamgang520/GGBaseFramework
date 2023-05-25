//
//  VideoTools.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/3/30.
//

#import "VideoTools.h"

@implementation VideoTools

- (void)compressVideo:(NSURL *)videoUrl
    withVideoSettings:(NSDictionary *)videoSettings
        AudioSettings:(NSDictionary *)audioSettings
             fileType:(AVFileType)fileType
             complete:(void (^)(NSURL * _Nullable, NSError * _Nullable))complete {
//  NSURL *outputUrl = [NSURL fileURLWithPath:[self buildFilePath]];
    NSURL *outputUrl = [NSURL fileURLWithPath:@""];
  
  AVAsset *asset = [AVAsset assetWithURL:videoUrl];
  AVAssetReader *reader = [AVAssetReader assetReaderWithAsset:asset error:nil];
  AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:outputUrl fileType:fileType error:nil];
  
  // video part
  AVAssetTrack *videoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] firstObject];
  AVAssetReaderTrackOutput *videoOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:videoTrack outputSettings:[self configVideoOutput]];
  AVAssetWriterInput *videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
  if ([reader canAddOutput:videoOutput]) {
    [reader addOutput:videoOutput];
  }
  if ([writer canAddInput:videoInput]) {
    [writer addInput:videoInput];
  }
  
  // audio part
  AVAssetTrack *audioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] firstObject];
  AVAssetReaderTrackOutput *audioOutput = [AVAssetReaderTrackOutput assetReaderTrackOutputWithTrack:audioTrack outputSettings:[self configAudioOutput]];
  AVAssetWriterInput *audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
  if ([reader canAddOutput:audioOutput]) {
    [reader addOutput:audioOutput];
  }
  if ([writer canAddInput:audioInput]) {
    [writer addInput:audioInput];
  }
  
  // 开始读写
  [reader startReading];
  [writer startWriting];
  [writer startSessionAtSourceTime:kCMTimeZero];
  
  //创建视频写入队列
  dispatch_queue_t videoQueue = dispatch_queue_create("Video Queue", DISPATCH_QUEUE_SERIAL);
  //创建音频写入队列
  dispatch_queue_t audioQueue = dispatch_queue_create("Audio Queue", DISPATCH_QUEUE_SERIAL);
  //创建一个线程组
  dispatch_group_t group = dispatch_group_create();
  //进入线程组
  dispatch_group_enter(group);
  //队列准备好后 usingBlock
  [videoInput requestMediaDataWhenReadyOnQueue:videoQueue usingBlock:^{
    BOOL completedOrFailed = NO;
    while ([videoInput isReadyForMoreMediaData] && !completedOrFailed) {
          CMSampleBufferRef sampleBuffer = [videoOutput copyNextSampleBuffer];
      if (sampleBuffer != NULL) {
        [videoInput appendSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
      }
      else {
        completedOrFailed = YES;
        [videoInput markAsFinished];
        dispatch_group_leave(group);
      }
    }
  }];
  
  dispatch_group_enter(group);
  //队列准备好后 usingBlock
  [audioInput requestMediaDataWhenReadyOnQueue:audioQueue usingBlock:^{
    BOOL completedOrFailed = NO;
    while ([audioInput isReadyForMoreMediaData] && !completedOrFailed) {
      CMSampleBufferRef sampleBuffer = [audioOutput copyNextSampleBuffer];
      if (sampleBuffer != NULL) {
        BOOL success = [audioInput appendSampleBuffer:sampleBuffer];
        CFRelease(sampleBuffer);
        completedOrFailed = !success;
      }
      else {
        completedOrFailed = YES;
      }
    }
    
    if (completedOrFailed) {
      [audioInput markAsFinished];
      dispatch_group_leave(group);
    }
  }];
  
  //完成压缩
  dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    if ([reader status] == AVAssetReaderStatusReading) {
      [reader cancelReading];
    }
    
    switch (writer.status) {
      case AVAssetWriterStatusWriting: {
        NSLog(@"视频压缩完成");
        [writer finishWritingWithCompletionHandler:^{
          
          // 可以尝试异步回至主线程回调
          if (complete) {
            complete(outputUrl,nil);
          }
          
        }];
      }
        break;
          
      case AVAssetWriterStatusCancelled:
        NSLog(@"取消压缩");
        break;
          
      case AVAssetWriterStatusFailed:
        NSLog(@"===error：%@===", writer.error);
        if (complete) {
          complete(nil,writer.error);
        }
        break;
          
      case AVAssetWriterStatusCompleted: {
        NSLog(@"视频压缩完成");
        [writer finishWritingWithCompletionHandler:^{
          
          // 可以尝试异步回至主线程回调
          if (complete) {
            complete(outputUrl,nil);
          }
        }];
      }
        break;
          
      default:
        break;
    }
  });
}

/** 视频解码 */
- (NSDictionary *)configVideoOutput {

  NSDictionary *videoOutputSetting = @{
    (__bridge NSString *)kCVPixelBufferPixelFormatTypeKey:[NSNumber numberWithUnsignedInt:kCVPixelFormatType_422YpCbCr8],
    (__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey:[NSDictionary dictionary]
  };
    
  return videoOutputSetting;
}

/** 音频解码 */
- (NSDictionary *)configAudioOutput {
  NSDictionary *audioOutputSetting = @{
    AVFormatIDKey: @(kAudioFormatLinearPCM)
  };
  return audioOutputSetting;
}

/// 指定音视频的压缩码率，profile，帧率等关键参数信息，这些参数可以根据要求自行更改
- (NSDictionary *)performanceVideoSettings {
  NSDictionary *compressionProperties = @{
    AVVideoAverageBitRateKey          : @(409600), // 码率 400K
    AVVideoExpectedSourceFrameRateKey : @24, // 帧率
    AVVideoProfileLevelKey            : AVVideoProfileLevelH264HighAutoLevel
  };
  
  NSString *videoCodeec;
  if (@available(iOS 11.0, *)) {
      videoCodeec = AVVideoCodecTypeH264;
  } else {
      videoCodeec = AVVideoCodecH264;
  }
  NSDictionary *videoCompressSettings = @{
    AVVideoCodecKey                 : videoCodeec,
    AVVideoWidthKey                 : @640,
    AVVideoHeightKey                : @360,
    AVVideoCompressionPropertiesKey : compressionProperties,
    AVVideoScalingModeKey           : AVVideoScalingModeResizeAspectFill
  };
  
  return videoCompressSettings;
}

- (NSDictionary *)performanceAudioSettings {
  AudioChannelLayout stereoChannelLayout = {
    .mChannelLayoutTag = kAudioChannelLayoutTag_Stereo,
    .mChannelBitmap = kAudioChannelBit_Left,
    .mNumberChannelDescriptions = 0
  };
  NSData *channelLayoutAsData = [NSData dataWithBytes:&stereoChannelLayout length:offsetof(AudioChannelLayout, mChannelDescriptions)];
  NSDictionary *audioCompressSettings = @{
    AVFormatIDKey         : @(kAudioFormatMPEG4AAC),
    AVEncoderBitRateKey   : @(49152), // 码率 48K
    AVSampleRateKey       : @44100, // 采样率
    AVChannelLayoutKey    : channelLayoutAsData,
    AVNumberOfChannelsKey : @(2)  // 声道
  };
  
  return audioCompressSettings;
}

// 获取视频第一帧
+ (UIImage*)getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}


@end
