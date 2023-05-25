//
//  BaseViewController.m
//  ChatSDK
//
//  Created by 欧布 on 2021/8/2.
//  Copyright © 2021年 星合互娱 All rights reserved.
//


#import "BaseViewController.h"
#import "Masonry.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self baseInitDataSource];
    [self baseInitUserInterface];
    
    // 设置状态栏颜色
    [self preferredStatusBarStyle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSLog(@"=========================================================================> %@ ---->viewDidAppear", self);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)dealloc
{
    NSLog(@"=========================================================================> %@ ---->dealloc", self);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 主题
/// 是否是白色navgation
- (BOOL)isWhiteNavigation
{
    return [BaseUIConfig shared].isWhiteNavBar;
}

- (UIColor *)navigationBarBackgroundColor
{
    return [self isWhiteNavigation] ? [UIColor whiteColor] : [BaseUIConfig shared].themeColor;
}

- (UIColor *)navigationBarTitleColor
{
    return [self isWhiteNavigation] ? [BaseUIConfig shared].titleColor : [UIColor whiteColor];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self isWhiteNavigation] ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

#pragma mark -
#pragma mark - UI
- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:hidden animated:animated];
        
        if (hidden) {
            
            [self.navBackView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(- self.navBackView.bounds.size.height);
            }];
        } else {
            [self.navBackView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
        }
        [UIView animateWithDuration:animated ? 0.2 : 0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.navBackView.superview layoutIfNeeded];
        } completion:nil];
    }
}

#pragma mark -
#pragma mark - 初始化
- (void)baseInitDataSource
{
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.extendedLayoutIncludesOpaqueBars = YES;
}

- (void)baseInitUserInterface
{
    // 背景色
    if (@available(iOS 13.0, *)) {
        self.view.backgroundColor = [UIColor systemBackgroundColor];
    } else {
        // Fallback on earlier versions
        self.view.backgroundColor = [UIColor whiteColor];
    }
    
    // 添加顶部背景图
    if (self.navigationController) {
        [self.view addSubview:self.navBackView];
        
        __weak typeof(self) weakSelf = self;
        [self.navBackView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.mas_equalTo(0);
            if (@available(iOS 11.0, *)){
                make.height.mas_equalTo(weakSelf.navigationController.navigationBar.frame.size.height + (weakSelf.navigationController.view.safeAreaInsets.top ? weakSelf.navigationController.view.safeAreaInsets.top : (weakSelf.navigationController.modalPresentationStyle == UIModalPresentationFullScreen ? [UIApplication sharedApplication].statusBarFrame.size.height : 0)));
            } else {
                make.height.mas_equalTo(weakSelf.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height);
            }
        }];
        
        // 添加titleView
        [self configureTitleView];
        
        // 添加返回按钮
        if (![self.navigationController.viewControllers.firstObject isEqual:self]) {
            [self configureLeft:@""];
        }
    }
}

#pragma mark - 屏幕旋转
/// 是否允许旋转屏幕
- (BOOL)shouldAutorotate
{
    return NO;
}

//支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self shouldAutorotate] ? (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight) : UIInterfaceOrientationMaskPortrait;
}

//默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

#pragma mark - 回收键盘
/// 是否点击空白处收起键盘：默认YES
- (BOOL)shouldHideKeyboardWhenTouch
{
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self shouldHideKeyboardWhenTouch]) {
        [self.view endEditing:YES];
    }
}

//获取将要旋转的状态
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (!self.navBackView || !self.navBackView.superview) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    
    // 延时一下 获得的高度才正确，要不然是转屏前的宽高
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.navBackView mas_updateConstraints:^(MASConstraintMaker *make) {
            if (@available(iOS 11.0, *)){
                make.height.mas_equalTo(weakSelf.navigationController.navigationBar.frame.size.height + weakSelf.navigationController.view.safeAreaInsets.top);
            } else {
                make.height.mas_equalTo(weakSelf.navigationController.navigationBar.frame.size.height);
            }
        }];
    });
}

#pragma mark - 自定义标题
//自定义标题
- (void)configureTitleView
{
    UILabel *headlinelabel = [UILabel new];
    headlinelabel.font = [BaseUIConfig shared].titleFont;
    headlinelabel.textAlignment = NSTextAlignmentCenter;
    headlinelabel.textColor = [self navigationBarTitleColor];
    
    headlinelabel.text = self.title ?: self.navigationItem.title;
    [headlinelabel sizeToFit];
    headlinelabel.frame = CGRectMake(0, 0, headlinelabel.bounds.size.width, [UIApplication sharedApplication].statusBarFrame.size.height);
    [self.navigationItem setTitleView:headlinelabel];
}

- (void)setCenterTitle:(NSString *)title
{
    if (self.navigationItem && [self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        titleLabel.font = [BaseUIConfig shared].titleFont;
        titleLabel.text = title ?: @"";
        [titleLabel sizeToFit];
    } else {
        self.title = title;
    }
}

/// 获取当前标题
- (NSString *)getNowTitle
{
    NSString *title = self.title ?: self.navigationItem.title;
    if (self.navigationItem && [self.navigationItem.titleView isKindOfClass:[UILabel class]]) {
        UILabel *titleLabel = (UILabel *)self.navigationItem.titleView;
        if (titleLabel.text && titleLabel.text.length) {
            title = titleLabel.text;
        }
    }
    if (!title || !title.length) {
        title = nil;
    }
    return title;
}

#pragma mark - 自定义右边按钮
//自定义导航栏右边按钮--文字
- (void)configureRight:(NSString *)string
{
    [self configureRight:string font:[UIFont systemFontOfSize:16]];
}

- (void)configureRight:(NSString *)string actionBlock:(nullable void (^)(void))theBlock
{
    [self configureRight:string font:[UIFont systemFontOfSize:16] actionBlock:theBlock];
}

- (void)configureRight:(NSString *)string font:(UIFont *)font
{
    [self configureRight:string font:font actionBlock:nil];
}

- (void)configureRight:(NSString *)string font:(UIFont *)font actionBlock:(nullable void (^)(void))theBlock
{
    if (!string || !string.length) {
        return;
    }
    
    UIButton * sender = [UIButton buttonWithType:UIButtonTypeSystem];
    sender.frame = CGRectMake(0, 0, 40, 44);
    [sender setTitle:string forState:UIControlStateNormal];
    [sender.titleLabel setFont:font];
    sender.titleLabel.textAlignment = NSTextAlignmentRight;
    [sender setTitleColor:[self isWhiteNavigation] ? [BaseUIConfig shared].titleColor : [UIColor whiteColor] forState:UIControlStateNormal];
    
    if (theBlock) {
        [sender jk_addActionHandler:^(NSInteger tag) {
            theBlock();
        }];
    } else {
        [sender addTarget:self action:@selector(rightNavAction) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *rightBar = [[UIBarButtonItem alloc] initWithCustomView:sender];
    self.navigationItem.rightBarButtonItem = rightBar;
}

//自定义导航栏右边按钮--文字加图片
- (void)configureRightImage:(NSString *)imgName
{
    [self configureRightImage:imgName actionBlock:nil];
}

static void extracted(void (^ _Nullable theBlock)(void)) {
    theBlock();
}

- (void)configureRightImage:(NSString *)imgName actionBlock:(nullable void (^)(void))theBlock {
    
    UIImage * image = [UIImage new];
    if (imgName) {
        image = [[GGTools getSDKImageWithName:imgName] imageWithRenderingMode:(UIImageRenderingModeAlwaysOriginal)];
    }else{
        image = nil;
    }
    UIButton * button = [UIButton new];
    [button setImage:image forState:(UIControlStateNormal)];
    if (theBlock) {
        [button jk_addActionHandler:^(NSInteger tag) {
           
            extracted(theBlock);
        }];
    } else {
        [button addTarget:self action:@selector(rightNavAction) forControlEvents:(UIControlEventTouchUpInside)];
    }
    
    UIBarButtonItem *rightbar=[[UIBarButtonItem alloc]initWithCustomView:button];
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    space.width = 10;
    self.navigationItem.rightBarButtonItems = @[space, rightbar];
}

- (UIBarButtonItem *)setRightButtonWithTitle:(NSString *)theTitle imgName:(NSString *)theImgName action:(nullable void(^)(void))theAction
{
    UIButton * wechatBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [wechatBtn setFrame:CGRectMake(0, 0, 50, 44)];
    [wechatBtn setTitle:theTitle forState:(UIControlStateNormal)];
    [wechatBtn setTitleColor:[self navigationBarTitleColor] forState:(UIControlStateNormal)];
    [wechatBtn.titleLabel setFont:[UIFont systemFontOfSize:SCALE_FONT_SIZE(10)]];
    if (theImgName) {
        [wechatBtn setImage:[GGTools getSDKImageWithName:theImgName] forState:(UIControlStateNormal)];
    }
    
    __weak typeof(self) weakSelf = self;
    [wechatBtn jk_addActionHandler:^(NSInteger tag) {
        
        if (theAction) {
            theAction();
        } else {
            [weakSelf rightNavAction];
        }
    }];
    UIBarButtonItem *rightWechatBar=[[UIBarButtonItem alloc]initWithCustomView:wechatBtn];
    
    self.navigationItem.rightBarButtonItem = rightWechatBar;
    return rightWechatBar;
}

#pragma mark - 返回按钮
// 自定义返回按钮
- (void)configureLeft:(nullable NSString *)string
{
    [self configureLeft:string actionBlock:nil];
}

- (void)configureLeft:(nullable NSString *)string actionBlock:(nullable void (^)(void))theBlock
{
    UIImage *backImage = [[GGTools getSDKImageWithName:@"ggbase_nav_back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (!string || string.length == 0) {
        UIBarButtonItem *leftbar = [[UIBarButtonItem alloc] initWithImage:backImage style:UIBarButtonItemStyleDone target:self action:@selector(backNavAction)];
        leftbar.tintColor = [self navigationBarTitleColor];
        self.navigationItem.leftBarButtonItem = leftbar;
        return;
    }
    UIButton *sender = [UIButton new];
    sender.tintColor = [self navigationBarTitleColor];
    sender.imageView.contentMode = UIViewContentModeScaleAspectFit;
    if (@available(iOS 11.0, *)) {
        sender.translatesAutoresizingMaskIntoConstraints = NO;
        [sender.widthAnchor constraintGreaterThanOrEqualToConstant:40].active = YES;
        [sender.heightAnchor constraintEqualToConstant:44].active = YES;
    } else {
        sender.frame = CGRectMake(0, 0, 40, 44);
    }
    [sender setImage:backImage forState:UIControlStateNormal];
    [sender setTitleColor:[self navigationBarTitleColor] forState:UIControlStateNormal];
    [sender setTitle:string forState:UIControlStateNormal];
    sender.titleLabel.font = [UIFont systemFontOfSize:SCALE_FONT_SIZE(16)];
    [sender setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
    if (theBlock) {
        [sender jk_addActionHandler:^(NSInteger tag) {
            theBlock();
        }];
    } else {
        [sender addTarget:self action:@selector(backNavAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIBarButtonItem *leftbar = [[UIBarButtonItem alloc] initWithCustomView:sender];
    self.navigationItem.leftBarButtonItem = leftbar;
}

#pragma mark -
#pragma mark - 点击事件
- (void)rightNavAction {
    NSLog(@"点击了导航栏右边按钮");
}

- (void)backNavAction {
    if (self.navigationController && self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark - getter
- (UIImageView *)navBackView
{
    if (!_navBackView) {
        _navBackView = [UIImageView new];
        _navBackView.contentMode = UIViewContentModeScaleToFill;
        _navBackView.backgroundColor = [self navigationBarBackgroundColor];
    }
    return _navBackView;
}

@end
