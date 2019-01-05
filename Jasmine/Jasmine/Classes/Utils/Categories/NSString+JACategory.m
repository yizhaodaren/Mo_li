//
//  NSString+JACategory.m
//  Jasmine
//
//  Created by xujin on 17/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "NSString+JACategory.h"

@implementation NSString (JACategory)

/// 等比缩放，限定在矩形框外:将图缩略成宽度为100，高度为100，按短边优先。
- (NSString *)ja_getFitImageStringWidth:(int)width height:(int)height {
    if (!self.length) {
        return @"";
    }
    if ([self containsString:@"moli2017"] || [self containsString:@"file.xsawe.top"]) {
        width = (int)(width*JA_SCREEN_SCALE);
        height = (int)(height*JA_SCREEN_SCALE);
        
        NSString *fitImageString = [self stringByAppendingFormat:@"?x-oss-process=image/resize,m_mfit,h_%d,w_%d",height,width];
        return fitImageString;
    }
    // 抓取的图片不处理
    return self;
}


/// 固定宽高，自动裁剪:将图自动裁剪成宽度为100，高度为100的效果图
- (NSString *)ja_getFillImageStringWidth:(int)width height:(int)height {
    if (!self.length) {
        return @"";
    }
    if ([self containsString:@"moli2017"] || [self containsString:@"file.xsawe.top"]) {
        width = (int)(width*JA_SCREEN_SCALE);
        height = (int)(height*JA_SCREEN_SCALE);
        
        NSString *fillImageString = [self stringByAppendingFormat:@"?x-oss-process=image/resize,m_fill,h_%d,w_%d",height,width];
        return fillImageString;
    }
    // 抓取的图片不处理
    return self;
}

/// 生成指定位数的随机串
+ (NSString *)randomStringWithLength:(NSInteger)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:(NSUInteger)arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
}

// 自定义加密
// 参数排序
+ (NSString *)sortKey:(NSMutableDictionary *)dicM
{
    NSString *paraStr = nil;
    
    NSArray *keys = [dicM allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    
    for (NSString *categoryId in sortedArray) {
        
        NSString *str = [NSString stringWithFormat:@"%@",[dicM objectForKey:categoryId]];
        if (paraStr) {
            paraStr = [paraStr stringByAppendingString:str];
        }else{
            paraStr = str;
        }
    }
    
    return paraStr;
}

// 参数MD5 - 小写后 拼接 token  再MD5 后小写
+ (NSString *)paraMd5:(NSString *)token para:(NSString *)para
{
    NSString *str = [para md5_origin];
    NSString *str1 = [str stringByAppendingString:token];
    NSString *str2 = [str1 md5_origin];
    return str2;
}

+ (NSString *)ja_getLibraryCachPath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
//    NSArray* pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *dictionaryPath = pathes.lastObject;
//    NSString *filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
//    return filePath;
    
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/MusicAndNewCount"];
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *)ja_getPlistFilePath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/Plist"];
    NSFileManager *filemanager = [NSFileManager new];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingString:fileName];
    return filePath;
}

+ (NSString *)ja_getUploadImageFilePath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadImage"];
    NSFileManager *filemanager = [NSFileManager new];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingFormat:@"/%@",fileName];
    return filePath;
}

+ (NSString *)ja_getUploadVoiceFilePath:(NSString *)fileName {
    if (!fileName.length) {
        return @"";
    }
    NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/UploadVoice"];
    NSFileManager *filemanager = [NSFileManager new];
    if (![filemanager fileExistsAtPath:dictionaryPath]) {
        [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    NSString *filePath = [dictionaryPath stringByAppendingFormat:@"/%@",fileName];
    return filePath;
}

+ (BOOL)ja_removeFilePath:(NSString *)filePath {
    if (!filePath.length) {
        return NO;
    }
    NSFileManager *filemanager = [NSFileManager new];
    if ([filemanager fileExistsAtPath:filePath]) {
        return [filemanager removeItemAtPath:filePath error:nil];
    }
    return NO;
}

+ (NSDateFormatter *)getSensorsAnalyticsDateFormat
{
    static NSDateFormatter *format;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    });
    return format;
}


+ (NSString *)getCurrentDateTimeString {
    NSDateFormatter *format = [self getSensorsAnalyticsDateFormat];
    return [format stringFromDate:[NSDate date]];
}


+ (int)getSeconds:(NSString *)timeString {
    NSString *strTime = timeString;
    NSArray *array = [strTime componentsSeparatedByString:@":"];
    if (array.count == 2) {
        NSString *MM= array.firstObject;
        NSString *ss = array.lastObject;
        NSInteger m = [MM integerValue];
        NSInteger s = [ss integerValue];
        int zonghms = (int)(m*60 +s);
        return zonghms;
    }else{
        NSString *ss = array.lastObject;
        NSInteger s = [ss integerValue];
        int zonghms = (int)(s);
        return zonghms;
    }
    
}

+ (NSString *)getStoryVoiceShowTime:(NSString *)time
{
    NSArray *timeArr = [time componentsSeparatedByString:@":"];
    if (timeArr.count == 2) {
        int min = [timeArr.firstObject intValue];
        int sec = [timeArr.lastObject intValue];
        return [NSString stringWithFormat:@"%02d:%02d",min,sec];
    }else{
        int sec = [timeArr.lastObject intValue];
        return [NSString stringWithFormat:@"%02d\"",sec];
    }
}

+ (NSString *)getShowTime:(NSString *)time
{
    NSArray *timeArr = [time componentsSeparatedByString:@":"];
    if (timeArr.count == 2) {
        int min = [timeArr.firstObject intValue];
        int sec = [timeArr.lastObject intValue];
        if (min > 0) {
            return [NSString stringWithFormat:@"%d'%02d\"",min,sec];
        }else{
            return [NSString stringWithFormat:@"%02d\"",sec];
        }
    }else{
        int sec = [timeArr.lastObject intValue];
        return [NSString stringWithFormat:@"%02d\"",sec];
    }
}

// 数目超过一万后的展示形式
+ (NSString *)convertCountStr:(NSString *)countStr {
    if ([countStr integerValue] > 0) {
        if (countStr.integerValue > 10000) {
            countStr = [NSString stringWithFormat:@"%.1fw",countStr.integerValue / 10000.0];
        }
    } else {
        countStr = @"0";
    }
    return countStr;
}

// 计算字符串的数目
+ (int)caculaterName:(NSString *)strtemp
{
    int strlength = 0;
    char* p = (char*)[strtemp cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i<[strtemp lengthOfBytesUsingEncoding:NSUnicodeStringEncoding] ;i++) {
        if (*p) {
            strlength++;
        }
        p++;
    }
    return (strlength+1)/2;
}

@end
