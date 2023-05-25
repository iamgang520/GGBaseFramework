//
//  NSObject+Runtime.m
//  SUHelpSDK
//
//  Created by iamgang on 2022/3/25.
//

#import "NSObject+Runtime.h"

@implementation NSObject (Runtime)

- (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];

    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);

    BOOL didAddMethod = class_addMethod(cls,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
