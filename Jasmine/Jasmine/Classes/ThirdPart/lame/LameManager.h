//
//  LameManager.h
//  LameManager
//
//  Created by xujin on 7/14/15.
//  Copyright (c) 2015 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LameManager : NSObject


/*
 * 使用要求:
 * 1:文件必须为双通道
 * 2:文件为pcm格式的 .caf音频文件
 *
 * 编码为mp3格式的文件
 * 参数：
 *    inputPath:原始音频文件路径
 *    outPath: MP3文件路径
 * 返回：
 *    complete:文件编码成功
 *    failure: 返回失败原因
 */
+ (void )encodeAudioFile:(NSString *)inputPath
                  output:(NSString *)outPath
                complete:(void(^)(void))complete
                 failure:(void(^)(NSString *reason))failure;

@end
