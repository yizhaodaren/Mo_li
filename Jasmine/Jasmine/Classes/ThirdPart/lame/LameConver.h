//
//  LameConver.h
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^successBlock)(void);
@interface LameConver : NSObject

- (instancetype)initWithFilePath:(NSString *)filePath;
- (void)openFileWithFilePath:(NSString *)filePath;
- (void)closeFile;

/**
 audio unit PCM流转MP3文件

 @param pcmbuffer pcmbuffer
 @param path 输入路径
 */
- (void)convertPcmToMp3:(AudioBuffer)pcmbuffer toPath:(NSString *)path;


/**
 audio queue PCM流转MP3文件
 
 @param pcmbuffer pcmbuffer
 @param path 输入路径
 */



- (void)convertQueuePcmToMp3:(AudioQueueBufferRef)pcmbuffer toPath:(NSString *)path;

/**
 wav文件转mp3文件
 
 @param wavPath wav文件路径（输入）
 @param mp3Path mp3文件路径（输出）
 */
- (void)converWav:(NSString *)wavPath toMp3:(NSString *)mp3Path successBlock:(successBlock)block;


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
- (void )encodeAudioFile:(NSString *)inputPath
                  output:(NSString *)outPath
                complete:(void(^)(void))complete
                 failure:(void(^)(NSString *reason))failure;

// 关闭
- (void)lame_dealloc;
@end
