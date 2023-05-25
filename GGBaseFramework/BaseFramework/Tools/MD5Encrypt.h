//
//  MD5Encrypt.h
//  飞天钱包
//
//  Created by iamGG on 2020/11/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (MD5)
// MD5加密
/*
*由于MD5加密是不可逆的,多用来进行验证
*/
- (NSString *)MD5;

@end

@interface MD5Encrypt : NSObject

/// 32位小写
+ (NSString *)MD5ForLower32Bate:(NSString *)str;
/// 32位大写
+ (NSString *)MD5ForUpper32Bate:(NSString *)str;

@end

NS_ASSUME_NONNULL_END
