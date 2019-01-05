//
//  NSString+URLEncode.h
//
//  Created by Kevin Renskers on 31-10-13.
//  Copyright (c) 2013 Kevin Renskers. All rights reserved.
//

#import <Foundation/Foundation.h>

#define StringIsNullOrEmpty(str) (str==nil || [(str) isEqual:[NSNull null]] ||[str isEqualToString:@""])
#define F_S(size) [UIFont systemFontOfSize:size]

@interface NSString (URLEncode)

- (NSString *)URLEncode;
- (NSString *)URLEncodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)URLDecode;
- (NSString *)URLDecodeUsingEncoding:(NSStringEncoding)encoding;

@end

@interface NSString (Measure)

//获取某固定文本的显示高度
+(CGRect)heightForString:(NSString*)str size:(CGSize)size font:(UIFont*)font;

+(CGRect)heightForString:(NSString*)str size:(CGSize)size font:(UIFont*)font lines:(int)lines;

@end

@interface NSString (md5)
- (NSString *)UUmd5HexDigest;
@end
