//
//  GANGActionSheet.h
//  OneGO
//
//  Created by 、GANG on 2017/5/31.
//  Copyright © 2017年 黄国刚. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GANGActionType) {
    GANGAlertViewNormal,
    GANGAlertViewHighlighted
};

@interface GANGActionModel : NSObject

@property (nonatomic, strong) NSString *actionTitle;
@property (nonatomic, strong) NSString *actionSubTitle;
@property (nonatomic, strong) UIImage *actionLeftImage;
@property (nonatomic, assign) GANGActionType actionType;

@end

@interface GANGActionSheet : UIView

+ (instancetype)shareInstance;

- (void)showTitle:(NSString *)title actionArr:(NSArray <id> *)actionArr actionBlock:(void (^)(NSInteger index))actionBlock;

- (void)showTitle:(NSString *)title actionArr:(NSArray <id> *)actionArr textAlignment:(NSTextAlignment)textAlignment actionBlock:(void (^)(NSInteger index))actionBlock;

@end
