//
//  LameManager.m
//  LameManager
//
//  Created by xujin on 7/14/15.
//  Copyright (c) 2015 xujin. All rights reserved.
//

#import "LameManager.h"

#include <lame/lame.h>

@implementation LameManager

+ (void )encodeAudioFile:(NSString *)inputPath
                  output:(NSString *)outPath
                complete:(void(^)(void))complete
                 failure:(void(^)(NSString *reason))failure
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if([[NSFileManager defaultManager] fileExistsAtPath:inputPath])
        {
            @try {
                int read, write;
                
                //source 被转换的音频文件位置
                FILE *pcm = fopen([inputPath cStringUsingEncoding:1], "rb");
                //skip file header,跳过头文件 有的文件录制会有音爆，加上此句话去音爆
                fseek(pcm, 4*1024, SEEK_CUR);
                //output 输出生成的Mp3文件位置
                FILE *mp3 = fopen([outPath cStringUsingEncoding:1], "wb");
                
                const int PCM_SIZE = 8192;
                const int MP3_SIZE = 8192;
                short int pcm_buffer[PCM_SIZE*2];
                unsigned char mp3_buffer[MP3_SIZE];
                
                lame_t lame = lame_init();
                
                lame_set_in_samplerate(lame, 8000.0);
                lame_set_VBR(lame, vbr_default);
                lame_set_num_channels(lame,1);
                lame_set_brate(lame,8);
                lame_set_mode(lame,MONO);
                lame_set_quality(lame,2);
                lame_init_params(lame);
                
                /* .framework与.a库区别
                // 参数设置后，转码失败
                lame_set_num_channels (lame, 1 ); // 设置 1 为单通道，默认为 2 双通道
                lame_set_VBR(lame, vbr_default);
                lame_set_brate (lame, 8 );
                lame_get_mode(lame, 3 );
                lame_set_quality (lame, 5 ); // 2=high 5 = medium 7=low 音 质
                */
                
                

                do {
                    read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
                    if (read == 0)
                        write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
                    else
                        write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                    
                    fwrite(mp3_buffer, write, 1, mp3);
                    
                } while (read != 0);
                lame_close(lame);
                fclose(mp3);
                fclose(pcm);
            }
            @catch (NSException *exception)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failure([NSString stringWithFormat:@"Error:%@",[exception description]]);
                });
            }
            @finally
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    complete();
                });
            }
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(@"文件不存在");
            });
            
        }
    });
    
}

@end
