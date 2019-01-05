//
//  NSString+Koolistov.m
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


#import "NSString+Extention.h"
#import <CommonCrypto/CommonDigest.h>

#define Md5SecretString      @"2CB3147B-D93C-964B-47AE-EEE448C84E3C"

static NSString *_key = @"139E53F54A1DB2B0C850F728FD828456DABD1849420BC454F5F3CB147356EF369421899328DB3A48DE2A387C57E96949F7D76E2BBC2DFA8BB24764029AB80199";


@implementation NSString (HTML)

// Method based on code obtained from:
// http://www.thinkmac.co.uk/blog/2005/05/removing-entities-from-html-in-cocoa.html
//

- (NSString *)kv_decodeHTMLCharacterEntities {
    if ([self rangeOfString:@"&"].location == NSNotFound) {
        return self;
    } else {
        NSMutableString *escaped = [NSMutableString stringWithString:self];
        NSArray *codes = [NSArray arrayWithObjects:
                          @"&nbsp;", @"&iexcl;", @"&cent;", @"&pound;", @"&curren;", @"&yen;", @"&brvbar;",
                          @"&sect;", @"&uml;", @"&copy;", @"&ordf;", @"&laquo;", @"&not;", @"&shy;", @"&reg;",
                          @"&macr;", @"&deg;", @"&plusmn;", @"&sup2;", @"&sup3;", @"&acute;", @"&micro;",
                          @"&para;", @"&middot;", @"&cedil;", @"&sup1;", @"&ordm;", @"&raquo;", @"&frac14;",
                          @"&frac12;", @"&frac34;", @"&iquest;", @"&Agrave;", @"&Aacute;", @"&Acirc;",
                          @"&Atilde;", @"&Auml;", @"&Aring;", @"&AElig;", @"&Ccedil;", @"&Egrave;",
                          @"&Eacute;", @"&Ecirc;", @"&Euml;", @"&Igrave;", @"&Iacute;", @"&Icirc;", @"&Iuml;",
                          @"&ETH;", @"&Ntilde;", @"&Ograve;", @"&Oacute;", @"&Ocirc;", @"&Otilde;", @"&Ouml;",
                          @"&times;", @"&Oslash;", @"&Ugrave;", @"&Uacute;", @"&Ucirc;", @"&Uuml;", @"&Yacute;",
                          @"&THORN;", @"&szlig;", @"&agrave;", @"&aacute;", @"&acirc;", @"&atilde;", @"&auml;",
                          @"&aring;", @"&aelig;", @"&ccedil;", @"&egrave;", @"&eacute;", @"&ecirc;", @"&euml;",
                          @"&igrave;", @"&iacute;", @"&icirc;", @"&iuml;", @"&eth;", @"&ntilde;", @"&ograve;",
                          @"&oacute;", @"&ocirc;", @"&otilde;", @"&ouml;", @"&divide;", @"&oslash;", @"&ugrave;",
                          @"&uacute;", @"&ucirc;", @"&uuml;", @"&yacute;", @"&thorn;", @"&yuml;", nil];

        NSUInteger i, count = [codes count];

        // Html
        for (i = 0; i < count; i++) {
            NSRange range = [self rangeOfString:[codes objectAtIndex:i]];
            if (range.location != NSNotFound) {
                [escaped replaceOccurrencesOfString:[codes objectAtIndex:i]
                                         withString:[NSString stringWithFormat:@"%C", (unsigned short) (160 + i)]
                                            options:NSLiteralSearch
                                              range:NSMakeRange(0, [escaped length])];
            }
        }

        // The following five are not in the 160+ range

        // @"&amp;"
        NSRange range = [self rangeOfString:@"&amp;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&amp;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 38]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }

        // @"&lt;"
        range = [self rangeOfString:@"&lt;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&lt;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 60]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }

        // @"&gt;"
        range = [self rangeOfString:@"&gt;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&gt;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 62]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }

        // @"&apos;"
        range = [self rangeOfString:@"&apos;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&apos;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 39]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }

        // @"&quot;"
        range = [self rangeOfString:@"&quot;"];
        if (range.location != NSNotFound) {
            [escaped replaceOccurrencesOfString:@"&quot;"
                                     withString:[NSString stringWithFormat:@"%C", (unsigned short) 34]
                                        options:NSLiteralSearch
                                          range:NSMakeRange(0, [escaped length])];
        }

        // Decimal & Hex
        NSRange start, finish, searchRange = NSMakeRange(0, [escaped length]);
        i = 0;

        while (i < [escaped length]) {
            start = [escaped rangeOfString:@"&#"
                                   options:NSCaseInsensitiveSearch
                                     range:searchRange];

            finish = [escaped rangeOfString:@";"
                                    options:NSCaseInsensitiveSearch
                                      range:searchRange];

            if (start.location != NSNotFound && finish.location != NSNotFound &&
                finish.location > start.location) {
                NSRange entityRange = NSMakeRange(start.location, (finish.location - start.location) + 1);
                NSString *entity = [escaped substringWithRange:entityRange];
                NSString *value = [entity substringWithRange:NSMakeRange(2, [entity length] - 2)];

                [escaped deleteCharactersInRange:entityRange];

                if ([value hasPrefix:@"x"]) {
                    unsigned tempInt = 0;
                    NSScanner *scanner = [NSScanner scannerWithString:[value substringFromIndex:1]];
                    [scanner scanHexInt:&tempInt];
                    [escaped insertString:[NSString stringWithFormat:@"%C", (unsigned short) tempInt] atIndex:entityRange.location];
                } else {
                    [escaped insertString:[NSString stringWithFormat:@"%C", (unsigned short) [value intValue]] atIndex:entityRange.location];
                } i = start.location;
            } else { i++; }
            searchRange = NSMakeRange(i, [escaped length] - i);
        }

        return escaped;    // Note this is autoreleased
    }
}

- (NSString *)kv_encodeHTMLCharacterEntities {
    NSMutableString *encoded = [NSMutableString stringWithString:self];

    // @"&amp;"
    NSRange range = [self rangeOfString:@"&"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"&"
                                 withString:@"&amp;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }

    // @"&lt;"
    range = [self rangeOfString:@"<"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@"<"
                                 withString:@"&lt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }

    // @"&gt;"
    range = [self rangeOfString:@">"];
    if (range.location != NSNotFound) {
        [encoded replaceOccurrencesOfString:@">"
                                 withString:@"&gt;"
                                    options:NSLiteralSearch
                                      range:NSMakeRange(0, [encoded length])];
    }

    return encoded;
}

- (NSAttributedString *)attributedStringFromHTML
{
    NSDictionary *options = @{ NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                               NSCharacterEncodingDocumentAttribute :@(NSUTF8StringEncoding)};
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError * error = nil;
    NSAttributedString * attrText = [[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:&error];
    if (error)
    {
    }
    return attrText;
}

@end

@implementation NSString (MD5)
- (NSString *)checkInMd5{
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSUInteger unitFlags = NSCalendarUnitYear| NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *components = [gregorian components:unitFlags fromDate:[NSDate date]];
    NSInteger day = [components day];
    
    NSString *keyPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingFormat:@"/%@",@"checkInKey.txt"];
    
    NSString *keys = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:keyPath]
                                              encoding:NSUTF8StringEncoding
                                                 error:nil];
    
    NSArray *keyArray = [keys componentsSeparatedByString:@","];
    
    NSString *md5Source = [self stringByAppendingFormat:@"%@",keyArray[day]];
    
    return [md5Source md5_origin];
    
}


-(NSString*)md5{
    
    NSString *md5Source = [self stringByAppendingFormat:@"%@",Md5SecretString];
    
    const char *cStr = [md5Source UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString * str = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    return [str lowercaseString];
    
}
- (NSString *)md5_origin{
    const char *cStr = [self UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    NSString * str = [NSString stringWithFormat:
                      @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                      result[0], result[1], result[2], result[3],
                      result[4], result[5], result[6], result[7],
                      result[8], result[9], result[10], result[11],
                      result[12], result[13], result[14], result[15]
                      ];
    
    return [str lowercaseString];
    
}
@end


@implementation NSString (Size)
// 原方法1
-(CGSize)sizeWithFontEx:(UIFont*)font
{
    return [self sizeWithAttributes:@{NSFontAttributeName:font}];
}

-(CGSize)sizeWithSize:(CGSize)size Font:(UIFont *)font Attributes:(NSDictionary *)attributes{
    CGSize s;
    NSMutableDictionary *attr = [[NSMutableDictionary alloc] initWithDictionary:attributes];
    [attr setObjectSafely:font forKey:NSFontAttributeName];
    CGRect frame = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil];
    s.width = frame.size.width;
    s.height = frame.size.height;
    
    return s;
}

// 新增方法2
- (CGSize)sizeOfStringWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    NSDictionary *attrs = @{NSFontAttributeName : font};
    return [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
}

+ (CGSize)sizeWithString:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize {
    return [text sizeOfStringWithFont:font maxSize:maxSize];
}

static UILabel *calLabel = nil;
+ (CGSize)size:(NSString *)string font:(UIFont *)font maxSize:(CGSize)maxSize numberOfLine:(NSInteger)number
{
    if (calLabel == nil)
    {
        calLabel = [[UILabel alloc] init];
        calLabel.numberOfLines = 2;
    }
    calLabel.text = string;
    CGSize size = [calLabel sizeThatFits:maxSize];
    return size;
}
+ (CGSize)sizeWithAttrStr:(NSAttributedString *)attrStr font:(UIFont *)font maxSize:(CGSize)maxSize
{
    if (calLabel == nil)
    {
        calLabel = [[UILabel alloc] init];
        calLabel.numberOfLines = 2;
    }
    calLabel.attributedText = attrStr;
    CGSize size = [calLabel sizeThatFits:maxSize];
    return size;
}


@end

@implementation NSString (Valid)
-(BOOL)isChinese{
    NSString *match=@"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:self];
}
@end

@implementation NSString (Custom)
- (NSString *)capitalizedStringWithoutChangeOtherCharacter
{
    NSMutableString *str = [self mutableCopy];
    NSRange toReplaceRange = NSMakeRange(0, 1);
    if (str.length >= NSMaxRange(toReplaceRange)) {
        NSString *toReplaceStr = [str substringWithRange:toReplaceRange];
        NSString *upperedReplaceStr = [toReplaceStr capitalizedString];
        [str replaceCharactersInRange:toReplaceRange withString:upperedReplaceStr];
        return str;
    }
    else
    {
        return nil;
    }
}

- (BOOL)isEmptyOrWhitespace {
    return !self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (float)floatValueFromItunesAppVersionString{
    
    
    NSArray *components = [self componentsSeparatedByString:@"."];
    if (components.count == 3) {
        NSRange thirdComponentsRange = [self rangeOfString:components[2] options:NSBackwardsSearch];
        NSRange lastDotRange = NSMakeRange(thirdComponentsRange.location-1,1);
        NSString *floatStr = [self stringByReplacingCharactersInRange:lastDotRange
                                                           withString:@""];
        
        return [floatStr floatValue];
    }else{
        return [self floatValue];
    }
    
}

// 字符串截取
- (NSString *)formatStr
{
    NSInteger strlength = 0;
    NSString *modifyStr = @"";
    if (self && self.length) {
        for (int i = 0; i < self.length; i ++) {
            NSString *perStr = [self substringWithRange:NSMakeRange(i, 1)];
            const char *perChar = [perStr UTF8String];
            if (perChar != NULL) {
                if (strlen(perChar) == 1) {
                    strlength ++;
                }
                if (strlen(perChar) == 3) {
                    strlength += 2;
                }
            }else {
                strlength += perStr.length;
            }
            
            if (strlength >= 16) {
                modifyStr = [self substringToIndex:(i+1)];
                break;
            }else {
                modifyStr = self;
            }
        }
    }
    return modifyStr;
}

@end


#define anHour  3600
#define aMinute 60

@implementation NSString (TimeString)

+ (BOOL)isExpried:(NSString *)endTime {
    double endTimeValue = [endTime doubleValue];
    endTimeValue = endTimeValue/1000.0;
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - endTimeValue;
    if (distanceTime >= 0) {
        return YES;
    }
    return NO;
}

// 列表展示时间
+ (NSString *)distanceTimeWithBeforeTime:(double)beTime
{
    beTime = beTime/1000.0;
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double time = now - beTime;
    if (time<60) {
        return @"刚刚";
    }
    // 秒转分钟
    NSInteger minutes = time/60;
    if (minutes<60) {
        return [NSString stringWithFormat:@"%ld分钟前",minutes];
    }
    // 秒转小时
    NSInteger hours = time/3600;
    if (hours<24) {
        return [NSString stringWithFormat:@"%ld小时前",hours];
    }
    //秒转天数
    NSInteger days = time/3600/24;
    if (days < 7) {
        return [NSString stringWithFormat:@"%ld天前",days];
    }
    // 超过一周且在本年内的帖子展示为11-12，不是本年的展示为2016-12-8
    NSString * distanceStr = @"";
    NSDate *currentDate = [[NSDate alloc]initWithTimeIntervalSince1970:beTime];
    if ([currentDate isThisYear]) {
        distanceStr = [[self getMonthDayDateFormat] stringFromDate:currentDate];
    } else {
        distanceStr = [[self getYearMonthDayDateFormat] stringFromDate:currentDate];
    }
    return distanceStr;
//    //秒转月
//    NSInteger months = time/3600/24/30;
//    if (months < 12) {
//        return [NSString stringWithFormat:@"%ld月前",months];
//    }
//    //秒转年
//    NSInteger years = time/3600/24/30/12;
//    return [NSString stringWithFormat:@"%ld年前",years];
}

+ (NSDateFormatter *)getMonthDayDateFormat
{
    static NSDateFormatter *format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MM-dd"];
    });
    return format;
}

+ (NSDateFormatter *)getYearMonthDayDateFormat
{
    static NSDateFormatter *format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd"];
    });
    return format;
}

// 消息的时间展示
+ (NSString *)distanceMessageTimeWithBeforeTime:(double)beTime
{
    beTime = beTime/1000.0;
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
    double distanceTime = now - beTime;
    NSString * distanceStr;
    NSDate * beDate = [NSDate dateWithTimeIntervalSince1970:beTime];
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"HH:mm"];
    NSString * timeStr = [df stringFromDate:beDate];
    
    [df setDateFormat:@"dd"];
    NSString * nowDay = [df stringFromDate:[NSDate date]];
    NSString * lastDay = [df stringFromDate:beDate];
    
    if (distanceTime < 60 || beTime <= 0)
    {
        //小于一分钟
        distanceStr = @"刚刚";
    }
    else if (distanceTime <60*60)
    {
        //时间小于一个小时
        distanceStr = [NSString stringWithFormat:@"%ld分钟前",(long)distanceTime/60];
    }
    else if(distanceTime <24*60*60 && [nowDay integerValue] == [lastDay integerValue])
    {
        //时间小于一天
        distanceStr = [NSString stringWithFormat:@"今天 %@",timeStr];
    }
    else if(distanceTime<24*60*60*2 && [nowDay integerValue] != [lastDay integerValue])
    {
        
        if ([nowDay integerValue] - [lastDay integerValue] ==1 ||
            ([lastDay integerValue] - [nowDay integerValue] > 10 &&
             [nowDay integerValue] == 1))
        {
            distanceStr = [NSString stringWithFormat:@"昨天 %@",timeStr];
        }
        else
        {
            distanceStr = [NSString stringWithFormat:@"前天 %@",timeStr];
        }
        
    }
    else if(distanceTime<24*60*60*3 && [nowDay integerValue] != [lastDay integerValue])
    {
        
        if ([nowDay integerValue] - [lastDay integerValue] ==2 ||
            ([lastDay integerValue] - [nowDay integerValue] > 10 &&
             [nowDay integerValue] == 1))
        {
            distanceStr = [NSString stringWithFormat:@"前天 %@",timeStr];
        }
        else
        {
            [df setDateFormat:@"yyyy.MM.dd"];
            distanceStr = [df stringFromDate:beDate];
        }
        
    }
    else if(distanceTime <24*60*60*365)
    {
        [df setDateFormat:@"yyyy.MM.dd"];
        distanceStr = [df stringFromDate:beDate];
    }
    else
    {
        [df setDateFormat:@"yyyy.MM.dd"];
        distanceStr = [df stringFromDate:beDate];
    }
    return distanceStr;
}
@end

@implementation NSString (Birthday)

// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
+ (NSString *)timeToString:(NSString *)str{
    NSTimeInterval time=[str doubleValue]/1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

// 时间戳转时间,时间戳为13位是精确到毫秒的，10位精确到秒
+ (NSString *)timeAndDateToString:(NSString *)str{
    NSTimeInterval time=[str doubleValue]/1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate=[NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

//勋章获得时间
+ (NSString *)MedalgetDatefromString:(NSString *)str{
    NSTimeInterval time=[str doubleValue]/1000;//传入的时间戳str如果是精确到毫秒的记得要/1000
    NSDate *detailDate = [NSDate dateWithTimeIntervalSince1970:time];
//    [NSDate dateWithTimeIntervalSinceNow:time];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; //实例化一个NSDateFormatter对象
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy.MM.dd"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detailDate];
    return currentDateStr;
}

/**日期 - 字符串*/
+ (NSString *)dateToString:(NSDate *)date
{
    //获取当前的日期
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    //字符串
    NSString *dateString = [fmt stringFromDate:date];
    
    return dateString;
}

/// 草稿箱时间展示
+ (NSString *)draftdateToString:(NSDate *)date {
    //获取当前的日期
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy.MM.dd HH:mm";
    //字符串
    NSString *dateString = [fmt stringFromDate:date];
    return dateString;
}

/**根据日期获取年龄*/
+ (NSString *)ageWithDateString:(NSString *)dateString
{
    if (!dateString.length) return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:dateString];
    
    // 选择的日期
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    
    // 当前日期
    NSDate *now = [NSDate date];
    NSDateComponents *cmps1 = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    
    // 计算年龄
    if (cmps1.year - cmps.year > 0) {
        return [NSString stringWithFormat:@"%ld",cmps1.year - cmps.year];
    }else{
        return @"0";
    }
}

/**根据日期获取星座*/
+ (NSString *)constellationWithDateString:(NSString *)dateString
{
    if (!dateString.length) return nil;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date=[formatter dateFromString:dateString];
    
    // 选择的日期
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmps = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    return [self getConstellationNameByMonthIndex:cmps.month - 1 dayIndex:cmps.day - 1];
}

//+ (BOOL)calculaterDate:(NSString *)currentDate andearlyDate:(NSString *)earlyDate andLaterDate:(NSString *)laterDate
//{
//    NSDateFormatter *farmate = [[NSDateFormatter alloc] init];
//    farmate.dateFormat = @"MM dd";
//    
//    NSDate *date = [farmate dateFromString:currentDate];
//    NSDate *dateEarly = [farmate dateFromString:earlyDate];
//    NSDate *dateLater = [farmate dateFromString:laterDate];
//    
//    if ([[date earlierDate:dateLater] isEqualToDate:date] && [[dateEarly earlierDate:date] isEqualToDate:dateEarly]) {
//        
//        return YES;
//    }else{
//        return NO;
//    }
//}

+ (NSString *)getConstellationNameByMonthIndex:(NSInteger)monthIndex dayIndex:(NSInteger)dayIndex {
    NSArray *constellations = @[@"水瓶座", @"双鱼座", @"白羊座", @"金牛座", @"双子座", @"巨蟹座", @"狮子座", @"处女座", @"天秤座", @"天蝎座", @"射手座", @"摩羯座"];
    NSInteger index;
    NSArray *conIndexs = @[@(20),@(19),@(21),@(20),@(21),@(22),@(23),@(23),@(23),@(24),@(23),@(22)];
    if ([[conIndexs objectAtIndex:monthIndex] integerValue] <= dayIndex + 1) {
        index = monthIndex;
    } else index = (monthIndex - 1 + 12) % 12;
    
    if (index > 11) {
        index = 0;
    }
    
    return [constellations objectAtIndex:index];
}

//+ (NSString *)leftTime:(double)endTime {
//    endTime = endTime/1000.0;
//    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
//    double leftTime = endTime - now;
//    NSInteger days = leftTime/3600/24;
//    if (<#condition#>) {
//        <#statements#>
//    }
//    return [NSString stringWithFormat:@"%ld",days];
//}

@end


@implementation NSString (URL)

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters {
    
//    // 查找参数
//    NSRange range = [self rangeOfString:@"?"];
//    if (range.location == NSNotFound) {
//        return nil;
//    }
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    // 截取参数
//    NSString *parametersString = [self substringFromIndex:range.location + 1];
    
    if (!self.length) {
        return nil;
    }
   
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 截取参数
    NSString *parametersString = self;
    
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

@end
