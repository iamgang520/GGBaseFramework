//
//  GGBaseHook.m
//  ZhuruTest
//
//  Created by iamgang on 2023/3/11.
//

#import "GGBaseHook.h"

@implementation GGBaseHook

#pragma mark -
#pragma mark - Hook函数

/// hook实例方法，需要子类调用
+ (void)hookMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL andNew:(SEL)newSEL
{
    if ([NSStringFromClass([self class]) isEqualToString:@"GGBaseHook"]) {
        NSLog(@"需要GGBaseHook子类调用");
        return;
    }
    [self hookMehodWithClass:oldClass oldSEL:oldSEL newClass:[self class] andNew:newSEL isClassMethod:NO];
}

/// hook实例方法，直接GGBaseHook调用
+ (void)baseHookMehodWithOldClass:(Class)oldClass oldSEL:(SEL)oldSEL newClass:(Class)newClass andNew:(SEL)newSEL
{
    [self hookMehodWithClass:oldClass oldSEL:oldSEL newClass:newClass andNew:newSEL isClassMethod:NO];
}

/// hook类方法，需要子类调用
+ (void)hookClassMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL andNew:(SEL)newSEL
{
    if ([NSStringFromClass([self class]) isEqualToString:@"GGBaseHook"]) {
        NSLog(@"需要GGBaseHook子类调用");
        return;
    }
    [self hookMehodWithClass:oldClass oldSEL:oldSEL newClass:[self class] andNew:newSEL isClassMethod:YES];
}

/// hook类方法，需要子类调用
+ (void)baseHookClassMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL newClass:(Class)newClass andNew:(SEL)newSEL
{
    [self hookMehodWithClass:oldClass oldSEL:oldSEL newClass:newClass andNew:newSEL isClassMethod:YES];
}

+ (void)hookMehodWithClass:(Class)oldClass oldSEL:(SEL)oldSEL newClass:(Class)newClass andNew:(SEL)newSEL isClassMethod:(BOOL)isClassMethod
{
    if (!oldClass || !newClass) {
        return;
    }

    Method oldMethod = isClassMethod ? class_getClassMethod(oldClass, oldSEL) : class_getInstanceMethod(oldClass, oldSEL);
    if (!oldMethod) {
        
        Method newClass_oldMethod = isClassMethod ? class_getClassMethod(newClass, oldSEL) : class_getInstanceMethod(newClass, oldSEL);
        NSAssert(newClass_oldMethod, @"需要交换的类没有实现改方法，请在新类中实现老方法:%@", NSStringFromSelector(oldSEL));
        if (!newClass_oldMethod) {
            return;
        }
        
        NSLog(@"%@ 未实现方法:%@", NSStringFromClass(oldClass), NSStringFromSelector(oldSEL));
        class_addMethod(isClassMethod ? object_getClass(oldClass) : oldClass, oldSEL, class_getMethodImplementation(isClassMethod ? object_getClass(newClass) : newClass, oldSEL), method_getTypeEncoding(isClassMethod ? class_getClassMethod(object_getClass(newClass), newSEL) : class_getInstanceMethod(newClass, newSEL)));
        oldMethod = isClassMethod ? class_getClassMethod(object_getClass(oldClass), oldSEL) : class_getInstanceMethod(oldClass, oldSEL);
        NSLog(@"%@ 添加方法成功:%@", NSStringFromClass(oldClass), NSStringFromSelector(oldSEL));
    }
    assert(oldMethod);
    Method newMethod = isClassMethod ? class_getClassMethod(object_getClass(oldClass), newSEL) : class_getInstanceMethod(oldClass, newSEL);
    if (!newMethod) {
        class_addMethod(isClassMethod ? object_getClass(oldClass) : oldClass, newSEL, class_getMethodImplementation(isClassMethod ? object_getClass(newClass) : newClass, newSEL), method_getTypeEncoding(isClassMethod ? class_getClassMethod(object_getClass(newClass), newSEL) : class_getInstanceMethod(newClass, newSEL)));
        newMethod = isClassMethod ? class_getClassMethod(object_getClass(oldClass), newSEL) : class_getInstanceMethod(oldClass, newSEL);
    }
    assert(newMethod);
    method_exchangeImplementations(oldMethod, newMethod);
}


@end
