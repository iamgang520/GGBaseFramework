//
//  GANGActionSheet.m
//  OneGO
//
//  Created by 、GANG on 2017/5/31.
//  Copyright © 2017年 黄国刚. All rights reserved.
//

#import "GANGActionSheet.h"

static NSInteger GANGActionButtonTag = 6482;
static CGFloat GANGActionButtonHeight = 50.f;
static CGFloat GANGActionButtonImageViewHeight = 30.f;
static NSInteger GANGActionSheetTitleFontSize = 15;
static NSInteger GANGActionTitleFontSize = 18;
static NSInteger GANGActionSubTitleFontSize = 12;
#define GANGActionNormalColor ([UIColor blackColor])
#define GANGActionHighlightedColor ([UIColor redColor])

@interface GANGActionSheetButton : UIButton

@end
@implementation GANGActionSheetButton

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (newSuperview)
    {
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        blurEffectView.frame = self.bounds;
        blurEffectView.userInteractionEnabled = NO;
        [self insertSubview:blurEffectView atIndex:0];
    }
}

@end

@interface GANGActionSheet ()

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) void (^block)(NSInteger index);

@end

@implementation GANGActionSheet

+ (instancetype)shareInstance
{
    GANGActionSheet *sheet = [[GANGActionSheet alloc] initWithFrame:[UIScreen mainScreen].bounds];
    return sheet;
}

- (void)showTitle:(NSString *)title actionArr:(NSArray <id> *)actionArr actionBlock:(void (^)(NSInteger index))actionBlock
{
    [self showTitle:title actionArr:actionArr textAlignment:NSTextAlignmentCenter actionBlock:actionBlock];
}

- (void)showTitle:(NSString *)title actionArr:(NSArray <id> *)actionArr textAlignment:(NSTextAlignment)textAlignment actionBlock:(void (^)(NSInteger index))actionBlock
{
    self.block = [actionBlock copy];
    actionBlock = nil;
    NSMutableArray *arr = [NSMutableArray array];
    [actionArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj isKindOfClass:[GANGActionModel class]])
        {
            [arr addObject:obj];
        }
        else if ([obj isKindOfClass:[NSString class]] && ((NSString *)obj).length > 0)
        {
            GANGActionModel *model = [GANGActionModel new];
            model.actionTitle = obj;
            [arr addObject:model];
        }
    }];
    
    if (arr.count == 1)
    {
        GANGActionModel *model = [arr firstObject];
        model.actionType = GANGAlertViewHighlighted;
    }
    
    [self drawUIWithTitle:title textAlignment:textAlignment textArr:arr];
}

- (void)pressBtn:(UIButton *)btn
{
    if (btn.tag >= GANGActionButtonTag)
    {
        if (self.block)
        {
            self.block(btn.tag - GANGActionButtonTag);
        }
    }
    [self hiddenView];
}

- (void)drawUIWithTitle:(NSString *)title textAlignment:(NSTextAlignment)textAlignment textArr:(NSArray *)textArr
{
    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 10)];
    
    CGFloat _backViewHeight = 0;
    // 标题
    if (title)
    {
        GANGActionSheetButton *titleLabel = [[GANGActionSheetButton alloc] initWithFrame:CGRectMake(0, _backViewHeight, _backView.bounds.size.width, 10)];
        titleLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        titleLabel.titleLabel.font = [UIFont systemFontOfSize:GANGActionSheetTitleFontSize];
        titleLabel.titleLabel.numberOfLines = 2;
        [titleLabel setTitle:title forState:UIControlStateNormal];
        [titleLabel sizeToFit];
        
        CGFloat height = titleLabel.bounds.size.height;
        if (height < 45)
        {
            height = 45;
        }
        else
        {
            height = height + 15;
        }
        
        titleLabel.frame = CGRectMake(titleLabel.frame.origin.x, titleLabel.frame.origin.y, _backView.bounds.size.width, height);
        [_backView addSubview:titleLabel];
        
        _backViewHeight += titleLabel.bounds.size.height + 0.5;
    }
    
    NSInteger index = 0;
    for (GANGActionModel *model in textArr)
    {
        BOOL isYouSubTitle = model.actionSubTitle && model.actionSubTitle.length;
        
        // 背景
        GANGActionSheetButton *backBtn = [GANGActionSheetButton buttonWithType:UIButtonTypeSystem];
        backBtn.tag = GANGActionButtonTag + index;
        [backBtn addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
        backBtn.frame = CGRectMake(0, _backViewHeight, _backView.bounds.size.width, isYouSubTitle ? GANGActionButtonHeight + 10: GANGActionButtonHeight);
        [_backView addSubview:backBtn];
        
        _backViewHeight += backBtn.bounds.size.height + (index == textArr.count - 1 ? 6 : 0.5);
        
        // 左边图片
        CGFloat left = 20.f;    // 左边距
        CGFloat right = 20.f;
        if (model.actionLeftImage)
        {
            UIButton *image = [UIButton buttonWithType:UIButtonTypeSystem];
            if (model.actionType == GANGAlertViewNormal)
            {
                [image setTintColor:GANGActionNormalColor];
            }
            else
            {
                [image setTintColor:GANGActionHighlightedColor];
            }
            [image setImage:model.actionLeftImage forState:UIControlStateNormal];
            image.frame = CGRectMake(left, (backBtn.bounds.size.height - GANGActionButtonImageViewHeight) / 2, GANGActionButtonImageViewHeight, GANGActionButtonImageViewHeight);
            image.userInteractionEnabled = NO;
            [backBtn addSubview:image];
            
            left = CGRectGetMaxX(image.frame) + 10;
            right = left;
        }
        
        // 主标题
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(left, isYouSubTitle ? 10 : 0, backBtn.bounds.size.width - (left + right), isYouSubTitle ? 20 : GANGActionButtonHeight)];
        title.text = model.actionTitle;
        title.textAlignment = textAlignment;
        title.font = [UIFont systemFontOfSize:GANGActionTitleFontSize];
        if (model.actionType == GANGAlertViewNormal)
        {
            [title setTextColor:GANGActionNormalColor];
        }
        else
        {
            [title setTextColor:GANGActionHighlightedColor];
        }
        [backBtn addSubview:title];
        
        if (isYouSubTitle)
        {
            // 副标题
            UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(title.frame), CGRectGetMaxY(title.frame), title.bounds.size.width, 15)];
            subTitle.text = model.actionSubTitle;
            subTitle.textAlignment = textAlignment;
            subTitle.font = [UIFont systemFontOfSize:GANGActionSubTitleFontSize];
            subTitle.textColor = [UIColor grayColor];
            [backBtn addSubview:subTitle];
        }
       
        index ++;
    }
    
    GANGActionSheetButton *cancelBtn = [GANGActionSheetButton buttonWithType:UIButtonTypeSystem];
    cancelBtn.frame = CGRectMake(0, _backViewHeight, _backView.bounds.size.width, GANGActionButtonHeight);
    cancelBtn.tintColor = GANGActionNormalColor;
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:GANGActionTitleFontSize];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    [_backView addSubview:cancelBtn];
    
    _backViewHeight += cancelBtn.bounds.size.height;
    
    _backView.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, _backViewHeight);
    // 磨砂视图
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    blurEffectView.frame = _backView.bounds;
    blurEffectView.alpha = 0.8;
    [_backView insertSubview:blurEffectView atIndex:0];
    
    [self addSubview:_backView];
    
    [[self getCurrentWindow] endEditing:YES];
    
    [self showWith_backView];
}

- (void)showWith_backView
{
    [[self getCurrentWindow] addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
       
        self.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.7];
        _backView.frame = CGRectMake(0, self.bounds.size.height - _backView.bounds.size.height, _backView.bounds.size.width, _backView.bounds.size.height);
    } completion:^(BOOL finished) {
        
        UIButton *dismiss = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - _backView.bounds.size.height)];
        [dismiss addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:dismiss];
    }];
}

- (void)hiddenView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.backgroundColor = [UIColor clearColor];
        _backView.frame = CGRectMake(0, self.bounds.size.height, _backView.bounds.size.width, _backView.bounds.size.height);
    } completion:^(BOOL finished) {
        
        [self removeFromSuperview];
    }];
}

//获取当前屏幕显示的viewcontroller
- (UIWindow *)getCurrentWindow
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result.view.window ?: [UIApplication sharedApplication].keyWindow;
}


@end

@implementation GANGActionModel

@end
