//
//  NSObject+GGLog.m
//
//  Created by iamgang on 2020/6/8.
//

#import "NSObject+GGLog.h"
#import <objc/runtime.h>

static NSString const *kGGLogSuojin = @"kGGLogSuojin";

@interface NSObject (GGLog)
// 缩进
@property (nonatomic, assign) NSInteger suojinNumber;

@end

@implementation NSObject (GGLog)

static inline void hc_swizzleSelector(Class theClass, SEL originalSelector, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(theClass, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(theClass, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(theClass,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(theClass,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (NSInteger)suojinNumber
{
    NSInteger suojinNumber = [objc_getAssociatedObject(self, &kGGLogSuojin) intValue];
    if (!suojinNumber)
    {
        objc_setAssociatedObject(self, &kGGLogSuojin, @(suojinNumber), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return suojinNumber;
}

- (void)setSuojinNumber:(NSInteger)suojinNumber
{
    objc_setAssociatedObject(self, &kGGLogSuojin, @(suojinNumber), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

@implementation NSArray (GGLog)

- (NSString *)descriptionWithLocale:(id)locale {

    @try {
        NSMutableString *suojin = [NSMutableString string];
        for (NSInteger i = 0; i < self.suojinNumber + 1; i ++) {
            [suojin appendString:@"\t"];
        }
        NSMutableString *str = [NSMutableString stringWithFormat:@"%lu (\n", (unsigned long)self.count];
        for (NSObject *obj in self) {
            if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
                obj.suojinNumber = self.suojinNumber + 1;
            }
            [str appendFormat:@"%@%@, \n", suojin, obj];
        }
        NSMutableString *suojin1 = [NSMutableString string];
        for (NSInteger i = 0; i < self.suojinNumber; i ++) {
            [suojin1 appendString:@"\t"];
        }
        [str appendFormat:@"%@)", suojin1];
        return str;
    } @catch (NSException *exception) {
        
    } @finally {
        return @"";
    }
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hc_swizzleSelector([self class], @selector(descriptionWithLocale:indent:), @selector(hc_descriptionWithLocale:indent:));
    });
}
 
- (NSString *)hc_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    @try {
        if (locale) {
            return [self stringByReplaceUnicode:[self hc_descriptionWithLocale:locale indent:level]];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        return @"";
    }
}
 
- (NSString *)stringByReplaceUnicode:(NSString *)unicodeString {
    NSMutableString *convertedString = [unicodeString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    
    return convertedString;
}

@end

@implementation NSDictionary (GGLog)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    
    @try {
        NSMutableString *suojin = [NSMutableString string];
        for (NSInteger i = 0; i < self.suojinNumber + 1; i ++) {
            [suojin appendString:@"\t"];
        }
        [self enumerateKeysAndObjectsUsingBlock:^(id key,NSObject *obj,BOOL *stop) {
            
            if ([obj isKindOfClass:[NSDictionary class]] || [obj isKindOfClass:[NSArray class]]) {
                obj.suojinNumber = self.suojinNumber + 1;
            }
            [strM appendFormat:@"%@%@ = %@\n", suojin, key, obj];
        }];
        
        NSMutableString *suojin1 = [NSMutableString string];
        for (NSInteger i = 0; i < self.suojinNumber; i ++) {
            [suojin1 appendString:@"\t"];
        }
        [strM appendFormat:@"%@}", suojin1];
    } @catch (NSException *exception) {
        
    }
    return strM;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        hc_swizzleSelector([self class], @selector(descriptionWithLocale:indent:), @selector(hc_descriptionWithLocale:indent:));
    });
}
 
- (NSString *)hc_descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    @try {
        if (locale) {
            return [self stringByReplaceUnicode:[self hc_descriptionWithLocale:locale indent:level]];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        return @"";
    }
}
 
- (NSString *)stringByReplaceUnicode:(NSString *)unicodeString {
    NSMutableString *convertedString = [unicodeString mutableCopy];
    [convertedString replaceOccurrencesOfString:@"\\U" withString:@"\\u" options:0 range:NSMakeRange(0, convertedString.length)];
    CFStringRef transform = CFSTR("Any-Hex/Java");
    CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);
    
    return convertedString;
}

@end
