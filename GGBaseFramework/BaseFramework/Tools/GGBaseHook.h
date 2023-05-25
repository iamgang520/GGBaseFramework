//
//  GGBaseHook.h
//  ZhuruTest
//
//  Created by iamgang on 2023/3/11.
//

#import <UIKit/UIKit.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface GGBaseHook : NSObject

#pragma mark -
#pragma mark - Hook函数
/// hook实例方法，需要子类调用
+ (void)hookMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL andNew:(SEL)newSEL;
/// hook实例方法，直接GGBaseHook调用
+ (void)baseHookMehodWithOldClass:(Class)oldClass oldSEL:(SEL)oldSEL newClass:(Class)newClass andNew:(SEL)newSEL;

/// hook类方法，需要子类调用
+ (void)hookClassMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL andNew:(SEL)newSEL;
/// hook类方法，直接GGBaseHook调用
+ (void)baseHookClassMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL newClass:(Class)newClass andNew:(SEL)newSEL;

@end

NS_ASSUME_NONNULL_END
