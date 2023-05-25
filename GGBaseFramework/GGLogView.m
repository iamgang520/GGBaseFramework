//
//  GGLogView.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/6/7.
//

#import "GGLogView.h"

@interface GGLogView () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *showBtn;

@property (nonatomic, strong) UILabel *topView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, assign) CGPoint beginPoint;
@property (nonatomic, assign) CGPoint endPoint;

// === 搜索功能
@property (nonatomic, strong) UIView *topSearchView;
@property (nonatomic, assign) BOOL isSearching;
@property (nonatomic, strong) NSMutableArray *searchSignModels;


+ (GGLogView *)shared;

@end

@implementation GGLogView

+ (void)load
{
    // 调试
#if !TARGET_IPHONE_SIMULATOR && IS_TEST
    if ([[GGTools getAppName] isEqualToString:@"星合客服"]) {
        [GGLogView shared];
    }
#endif
}

+ (GGLogView *)shared
{
    static GGLogView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [instance initDataSource];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [instance initUserInterface];
        });
    });
    return instance;
}

- (void)initDataSource
{
    self.dataSource = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"NSLog" object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
       
        if (note.object && [note.object isKindOfClass:[NSString class]]) {
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            format.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
            NSString *date_string = [format stringFromDate:[NSDate date]];
            
            if (self.isSearching) {
                [self.searchSignModels addObject:@{
                    @"string" : note.object,
                    @"date" : date_string
                }];
            } else {
                [self.dataSource addObject:@{
                    @"string" : note.object,
                    @"date" : date_string
                }];
            }
            
            // 最多保留200条消息
            if (self.isSearching) {
                if (self.searchSignModels.count > 500) {
                    [self.searchSignModels removeObjectAtIndex:0];
                }
            } else {
                if (self.dataSource.count > 500) {
                    [self.dataSource removeObjectAtIndex:0];
                }
            }
            
            if (self->_tableView && self.tableView.isHidden == NO && !self.isSearching) {
                
                BOOL isScrollToBottom = self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.bounds.size.height - 250;
                
                [self.tableView reloadData];
                
                if (isScrollToBottom) {
                    // 但界面在底部是才滚动到底部，有可能用户在浏览历史消息
                    NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
                    [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                }
            }
        }
    }];
}

static CGFloat kViewWidth = 50.f;
- (void)initUserInterface
{
    if ([UIScreen mainScreen].bounds.size.width < 430) {
        kViewWidth = 40.f;
    }
    
    self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].windows.firstObject.bounds.size.height - 150, kViewWidth, kViewWidth)];
    if (@available(iOS 11.0, *)) {
        [self.backView gg_radiusWithRadius:kViewWidth / 2 corner:UIRectCornerTopRight | UIRectCornerBottomRight];
    } else {
        self.backView.layer.cornerRadius = kViewWidth / 2;
    }
    
    self.backView.layer.masksToBounds = YES;
    self.backView.backgroundColor = [UIColor darkGrayColor];
    [[UIApplication sharedApplication].windows.firstObject addSubview:self.backView];
    self.endPoint = self.backView.frame.origin;
    
    
    UIView *top = [UIView new];
    top.backgroundColor = [UIColor whiteColor];
    [self.backView addSubview:top];
    [top mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo([UIApplication sharedApplication].statusBarFrame.size.height);
    }];
    
    UILabel *titleLab = [UILabel new];
    titleLab.text = @"打印台";
    titleLab.textColor = COLOR_333333;
    titleLab.font = [UIFont boldSystemFontOfSize:20];
    titleLab.backgroundColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.userInteractionEnabled = YES;
    [self.backView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(top.mas_bottom);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    self.topView = titleLab;
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [closeBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [closeBtn addTarget:self action:@selector(hiddenView) forControlEvents:UIControlEventTouchUpInside];
    [titleLab addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cleanBtn setTitle:@"清空" forState:UIControlStateNormal];
    [cleanBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
    cleanBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [cleanBtn addTarget:self action:@selector(cleanLogs) forControlEvents:UIControlEventTouchUpInside];
    [titleLab addSubview:cleanBtn];
    [cleanBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    searchBtn.tintColor = COLOR_333333;
    if (@available(iOS 13.0, *)) {
        [searchBtn setImage:[UIImage systemImageNamed:@"magnifyingglass"] forState:UIControlStateNormal];
    } else {
        [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    }
    [searchBtn addTarget:self action:@selector(btnSearchOnClick) forControlEvents:UIControlEventTouchUpInside];
    [titleLab addSubview:searchBtn];
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.right.mas_equalTo(cleanBtn.mas_left).offset(-5);
        make.width.mas_greaterThanOrEqualTo(50);
    }];
    
    self.tableView.hidden = YES;
    [self.backView addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLab.mas_bottom);
        make.left.right.bottom.mas_equalTo(0);
    }];
    
    self.showBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.showBtn setTitle:@"🥺" forState:UIControlStateNormal];
    [self.showBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.showBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.showBtn.titleLabel.font = [UIFont systemFontOfSize:[UIScreen mainScreen].bounds.size.width < 430 ? 24 : 32];
    self.showBtn.backgroundColor = [UIColor darkGrayColor];
    [self.showBtn addTarget:self action:@selector(showLogView) forControlEvents:UIControlEventTouchUpInside];
    [self.backView addSubview:self.showBtn];
    [self.showBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    //添加手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.showBtn addGestureRecognizer:panGesture];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.beginPoint = CGPointMake(self.backView.frame.origin.x, self.backView.frame.origin.y);
        
        if (@available(iOS 11.0, *)) {
            self.backView.layer.maskedCorners = (CACornerMask)UIRectCornerAllCorners;
        }
    }
    
    CGPoint panGesturePoint = [gesture translationInView:[UIApplication sharedApplication].windows.firstObject];
    self.backView.frame = CGRectMake(self.beginPoint.x + panGesturePoint.x, self.beginPoint.y + panGesturePoint.y, self.backView.bounds.size.width, self.backView.bounds.size.height);
    
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled || gesture.state == UIGestureRecognizerStateFailed) {
        
        CGFloat y = self.backView.frame.origin.y;
        if (self.backView.frame.origin.y < [UIApplication sharedApplication].statusBarFrame.size.height) {
            y = [UIApplication sharedApplication].statusBarFrame.size.height;
        } else if (self.backView.frame.origin.y > [UIScreen mainScreen].bounds.size.height - 80) {
            y = [UIScreen mainScreen].bounds.size.height - 80;
        }
        
        [UIView animateWithDuration:0.2 animations:^{
           
            self.backView.frame = CGRectMake(self.backView.frame.origin.x < [UIApplication sharedApplication].windows.firstObject.bounds.size.width / 2. ? 0 : [UIApplication sharedApplication].windows.firstObject.bounds.size.width - self.backView.bounds.size.width, y, self.backView.bounds.size.width, self.backView.bounds.size.height);
            
            if (@available(iOS 11.0, *)) {
                [self.backView gg_radiusWithRadius:kViewWidth / 2 corner:self.backView.frame.origin.x < [UIApplication sharedApplication].windows.firstObject.bounds.size.width / 2. ? (UIRectCornerTopRight | UIRectCornerBottomRight) : (UIRectCornerTopLeft | UIRectCornerBottomLeft)];
            }
        } completion:^(BOOL finished) {
            self.endPoint = self.backView.frame.origin;
        }];
    }
}

- (void)showLogView
{
    self.tableView.hidden = NO;
    [UIView animateWithDuration:0.35 animations:^{
        self.backView.frame = [UIScreen mainScreen].bounds;
        self.backView.layer.cornerRadius = 0;
        self.showBtn.alpha = 0;
        
        [self.backView layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showBtn.hidden = YES;
        
        [self.tableView reloadData];
        [self.tableView setNeedsLayout];
        [self.tableView layoutIfNeeded];
        if (self.dataSource.count) {
            NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:self.dataSource.count - 1 inSection:0];
            [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }];
}

- (void)hiddenView
{
    self.showBtn.hidden = NO;
    self.showBtn.alpha = 0;
    self.tableView.hidden = YES;
    [UIView animateWithDuration:0.35 animations:^{
        self.backView.frame = CGRectMake(self.endPoint.x, self.endPoint.y, kViewWidth, kViewWidth);
        self.backView.layer.cornerRadius = kViewWidth / 2;
        self.showBtn.alpha = 1;
        
        [self.backView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)cleanLogs
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
}

- (void)btnSearchOnClick
{
    if (!self.topSearchView) {
        self.topSearchView = [UIView new];
        self.topSearchView.backgroundColor = [UIColor whiteColor];
        [self.topView addSubview:self.topSearchView];
        [self.topSearchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:COLOR_333333 forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        __weak typeof(self) weakSelf = self;
        [cancelBtn jk_addActionHandler:^(NSInteger tag) {
            [weakSelf.topSearchView removeFromSuperview];
            
            weakSelf.isSearching = NO;
            weakSelf.dataSource = weakSelf.searchSignModels;
            [weakSelf.tableView reloadData];
            [weakSelf.tableView setNeedsLayout];
            [weakSelf.tableView layoutIfNeeded];
            
            if (weakSelf.dataSource.count) {
                NSIndexPath *toIndexPath = [NSIndexPath indexPathForRow:weakSelf.dataSource.count - 1 inSection:0];
                [self.tableView scrollToRowAtIndexPath:toIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }];
        [self.topSearchView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-10);
            make.width.mas_equalTo(50);
        }];
        
        UITextField *textField = [[UITextField alloc] init];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.tintColor = COLOR_333333;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.tag = 1000;
        [self.topSearchView addSubview:textField];
        [textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.right.mas_equalTo(cancelBtn.mas_left).offset(-10);
            make.height.mas_equalTo(35);
            make.centerY.mas_equalTo(self.topSearchView);
        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:textField];
    } else {
        [self.topView addSubview:self.topSearchView];
        [self.topSearchView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    
    UITextField *textfield = [self.topSearchView viewWithTag:1000];
    [textfield becomeFirstResponder];
    
    self.isSearching = YES;
    self.searchSignModels = [self.dataSource mutableCopy];
    [self.tableView reloadData];
}

- (void)textFieldChanged:(NSNotification *)noti
{
    UITextField *textfield = noti.object;
    [self.dataSource removeAllObjects];
    if (textfield.text.length) {
        [self.searchSignModels enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *str = [obj objectForKey:@"string"];
            if ([str containsString:textfield.text]) {
                [self.dataSource addObject:obj];
            }
        }];
    } else {
        self.dataSource = [self.searchSignModels mutableCopy];
    }
    [self.tableView reloadData];
    [self.tableView scrollsToTop];
}

#pragma mark -
#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        cell.textLabel.textColor = COLOR_333333;
        cell.textLabel.numberOfLines = 0;
    }
    NSDictionary *model = [self.dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@", [model objectForKey:@"date"], [model objectForKey:@"string"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *model = [self.dataSource objectAtIndex:indexPath.row];
    [self showCopyViewWithString:[model objectForKey:@"string"]];
}

- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.topView endEditing:YES];
}

#pragma mark -
#pragma mark - 复制
- (void)showCopyViewWithString:(NSString *)string
{
    UIButton *view = [UIButton new];
    [view jk_addActionHandler:^(NSInteger tag) {
        [view removeFromSuperview];
    }];
    view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.backView addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_offset(UIEdgeInsetsZero);
    }];
    [self.backView layoutIfNeeded];
    
    UIFont *contentFont = [UIFont systemFontOfSize:12];
    NSString *contentString = string;
    //首先创建一个字典，在里面定义了文本的文字样式
    //在这里我定义了字体的样式为系统样式，并且字体大小为18
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5 - (contentFont.lineHeight - contentFont.pointSize);
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:paragraphStyle forKey:NSParagraphStyleAttributeName];
    [attributes setObject:contentFont forKey:NSFontAttributeName];
    [attributes setObject:COLOR_333333 forKey:NSForegroundColorAttributeName];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:contentString attributes:attributes];
    //现在最大能够容纳的文本范围
    //如果将来计算的字体的范围超出了最大的范围，计算后返回的就是最大的范围
    //如果将来计算的字体的范围小于最大的范围，计算后返回的就是真实文本真实的范围
    CGSize maxSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 30, 450);
    //计算文本大小
    CGSize textSize = [contentString boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    
    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width - 30, (textSize.height > maxSize.height ? maxSize.height : (textSize.height < 150 ? 150 : textSize.height)) + 20)];
    contentTextView.center = CGPointMake(view.bounds.size.width / 2, view.bounds.size.height / 2);
    contentTextView.backgroundColor = [UIColor whiteColor];
    contentTextView.font = contentFont;
    contentTextView.textColor = COLOR_333333;
    contentTextView.attributedText = attString;
    contentTextView.editable = NO;
    contentTextView.showsVerticalScrollIndicator = NO;
    contentTextView.layer.cornerRadius = 10;
    contentTextView.bounces = NO;
    [view addSubview:contentTextView];
    
    UIButton *close = [UIButton buttonWithType:UIButtonTypeSystem];
    [close setTitle:@"关闭" forState:UIControlStateNormal];
    close.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    close.tintColor = [UIColor whiteColor];
    close.titleLabel.textAlignment = NSTextAlignmentRight;
    [close jk_addActionHandler:^(NSInteger tag) {
        [view removeFromSuperview];
    }];
    [view addSubview:close];
    [close mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(contentTextView.mas_top);
        make.right.mas_equalTo(contentTextView.mas_right).offset(-10);
        make.height.mas_equalTo(50);
    }];
    
    UILabel *titleLab = [UILabel new];
    titleLab.text = @"↓可以长按复制↓";
    titleLab.font = [UIFont systemFontOfSize:16];
    titleLab.textColor = [UIColor whiteColor];
    [view addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(contentTextView.mas_top);
        make.centerX.mas_equalTo(view);
        make.height.mas_equalTo(50);
    }];
}

@end
