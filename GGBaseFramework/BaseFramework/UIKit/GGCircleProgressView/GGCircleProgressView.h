//
//  GGCircleProgressView.h
//  SUHelpSDK
//
//  Created by iamgang on 2022/7/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGCircleProgressView : UIView

@property (nonatomic, assign) CGFloat progress;

//进度条颜色
@property(nonatomic, strong) UIColor *progerssColor;
//进度条背景颜色
@property(nonatomic, strong) UIColor *progerssBackgroundColor;
//进度条的宽度
@property(nonatomic, assign) CGFloat progerWidth;
//进度数据字体
@property(nonatomic, strong) UIFont *percentageFont;
//进度数字颜色
@property(nonatomic, strong) UIColor *percentFontColor;

@end

NS_ASSUME_NONNULL_END
