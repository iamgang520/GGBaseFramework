//
//  NSObject+Runtime.h
//  SUHelpSDK
//
//  Created by iamgang on 2022/3/25.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (Runtime)

/// 交换方法
/// @param origSelector origSelector description
/// @param newSelector newSelector description
- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector;

@end

NS_ASSUME_NONNULL_END
