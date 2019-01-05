//
//  NSString+HTML.h
//  Koolistov
//
//  Created by Johan Kool on 13-11-09.
//  Copyright 2009-2011 Koolistov Pte. Ltd. All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are 
//  permitted provided that the following conditions are met:
//
//  * Redistributions of source code must retain the above copyright notice, this list of 
//    conditions and the following disclaimer.
//  * Neither the name of KOOLISTOV PTE. LTD. nor the names of its contributors may be used to 
//    endorse or promote products derived from this software without specific prior written 
//    permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY 
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
//  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
//  THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) 
//  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, 
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS 
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (HTML)

- (NSString *)kv_decodeHTMLCharacterEntities;
- (NSString *)kv_encodeHTMLCharacterEntities;
- (NSAttributedString *)attributedStringFromHTML;

@end

@interface NSString (Size)
// 原方法1
-(CGSize)sizeWithFontEx:(UIFont*)font;
-(CGSize)sizeWithSize:(CGSize)size Font:(UIFont *)font Attributes:(NSDictionary *)attributes;

// 新增方法2
+ (CGSize)sizeWithString:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize;
- (CGSize)sizeOfStringWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
+ (CGSize)size:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize numberOfLine:(NSInteger)number;
+ (CGSize)sizeWithAttrStr:(NSAttributedString *)attrStr font:(UIFont *)font maxSize:(CGSize)maxSize;
@end

@interface NSString (MD5)

//签到功能用到的签名方法，动态key，按照日期取不同的key
- (NSString *)checkInMd5;

- (NSString *)md5;
- (NSString *)md5_origin;
@end

@interface NSString (Valid)
-(BOOL)isChinese;
@end

@interface NSString (Custom)
//首字母大写，但其他字母不变
- (NSString *)capitalizedStringWithoutChangeOtherCharacter;

- (BOOL)isEmptyOrWhitespace;
- (float)floatValueFromItunesAppVersionString;

// 截取字符串
- (NSString *)formatStr;


@end


@interface NSString (TimeString)

/**将时间戳转换为时间*/
+ (NSString *)distanceTimeWithBeforeTime:(double)beTime;
+ (NSString *)distanceMessageTimeWithBeforeTime:(double)beTime;
+ (BOOL)isExpried:(NSString *)endTime;

@end

@interface NSString (Birthday)

/**根据日期获取年龄*/
+ (NSString *)ageWithDateString:(NSString *)dateString;

/**根据日期获取星座*/
+ (NSString *)constellationWithDateString:(NSString *)dateString;

/**日期 - 字符串*/
+ (NSString *)dateToString:(NSDate *)date;

+ (NSString *)timeToString:(NSString *)str;

+ (NSString *)timeAndDateToString:(NSString *)str;
//勋章获得时间
+ (NSString *)MedalgetDatefromString:(NSString *)str;
/// 返回距解禁言时间
+ (NSString *)leftTime:(double)endTime;

/// 草稿箱时间展示
+ (NSString *)draftdateToString:(NSDate *)date;

@end

@interface NSString (URL)

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters;

@end




