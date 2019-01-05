//
//  NSString+JACategory.h
//  Jasmine
//
//  Created by xujin on 17/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JACategory)

/// 等比缩放，限定在矩形框外:将图缩略成宽度为100，高度为100，按短边优先。
- (NSString *)ja_getFitImageStringWidth:(int)width height:(int)height;

/// 固定宽高，自动裁剪:将图自动裁剪成宽度为100，高度为100的效果图
- (NSString *)ja_getFillImageStringWidth:(int)width height:(int)height;

/// 生成指定位数的随机串
+ (NSString *)randomStringWithLength:(NSInteger)len;

// 自定义加密
// 参数排序
+ (NSString *)sortKey:(NSMutableDictionary *)dicM;
// 参数MD5 - 小写后 拼接 token  再MD5 后小写
+ (NSString *)paraMd5:(NSString *)token para:(NSString *)para;

/// 获取cach文件路径
+ (NSString *)ja_getLibraryCachPath:(NSString *)fileName;

+ (NSString *)ja_getPlistFilePath:(NSString *)fileName;
+ (NSString *)ja_getUploadImageFilePath:(NSString *)fileName;
+ (NSString *)ja_getUploadVoiceFilePath:(NSString *)fileName;
+ (BOOL)ja_removeFilePath:(NSString *)filePath;

// 获取毫秒值 yyyy-MM-dd HH:mm:ss.SSS
+ (NSString *)getCurrentDateTimeString;

// 01:30 返回秒数 90
+ (int)getSeconds:(NSString *)timeString;

// 主帖时间展示
+ (NSString *)getStoryVoiceShowTime:(NSString *)time;
// 时间样式转换01:30->01'30“，回复时间展示
+ (NSString *)getShowTime:(NSString *)time;

// 数目超过一万后的展示形式
+ (NSString *)convertCountStr:(NSString *)countStr;

// 计算字符串的个数（汉字算1，字母算0.5）
+ (int)caculaterName:(NSString *)strtemp;

@end
