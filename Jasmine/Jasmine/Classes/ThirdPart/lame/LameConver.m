//
//  LameConver.m
//  RemoteIODemo
//
//  Created by JIANHUI on 2016/11/18.
//  Copyright © 2016年 HaiLife. All rights reserved.
//

#import "LameConver.h"
#include <lame/lame.h>
#import <AVFoundation/AVFoundation.h>
#define kSamplerate 32000

lame_t lame;
FILE *currentFile;

@implementation LameConver

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initLame];
    }
    return self;
}

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [self init];
    if (self) {
        if (filePath.length) {
            [self openFileWithFilePath:filePath];
        }
    }
    return self;
}

- (void)initLame {
    lame = lame_init();
    lame_set_in_samplerate(lame, kSamplerate);
    lame_set_num_channels(lame, 1);
    lame_set_mode(lame, MONO);
    lame_init_params(lame);
}

- (void)openFileWithFilePath:(NSString *)filePath {
    FILE *file = fopen([filePath cStringUsingEncoding:NSASCIIStringEncoding], "a+");
    currentFile = file;
}

- (void)closeFile {
    fclose(currentFile);
}

- (void)convertPcmToMp3:(AudioBuffer)pcmbuffer toPath:(NSString *)path{
    int pcmLength = pcmbuffer.mDataByteSize;
    short *bytes = (short *)pcmbuffer.mData;
    int nSamples = pcmLength/2;
    unsigned char mp3buffer[pcmLength];
    
    int recvLen = lame_encode_buffer(lame, bytes, NULL, nSamples, mp3buffer, pcmLength);
    fwrite(mp3buffer, recvLen, 1, currentFile);
//    fclose(file);
}

- (void)convertQueuePcmToMp3:(AudioQueueBufferRef)pcmbuffer toPath:(NSString *)path {
    int pcmLength = pcmbuffer->mAudioDataByteSize;
    short *bytes = (short *)pcmbuffer->mAudioData;
    int nSamples = pcmLength/2;
    unsigned char mp3buffer[pcmLength];
    
    int recvLen = lame_encode_buffer(lame, bytes, NULL, nSamples, mp3buffer, pcmLength);
    
    FILE *file = fopen([path cStringUsingEncoding:NSASCIIStringEncoding], "a+");
    
    fwrite(mp3buffer, recvLen, 1, file);
    fclose(file);
}

- (void)converWav:(NSString *)wavPath toMp3:(NSString *)mp3Path successBlock:(successBlock)block{
    
    @try {
        FILE *fwav = fopen([wavPath cStringUsingEncoding:NSASCIIStringEncoding], "rb");
        fseek(fwav, 1024*4, SEEK_CUR); //跳过源文件的信息头，不然在开头会有爆破音
        FILE *fmp3 = fopen([mp3Path cStringUsingEncoding:NSASCIIStringEncoding], "wb");
        
        lame = lame_init();
        lame_set_in_samplerate(lame, kSamplerate); //设置wav的采样率
        lame_set_num_channels(lame, 2); //声道，不设置默认为双声道
        //        lame_set_mode(lame, 0);
        lame_init_params(lame);
        
        const int PCM_SIZE = 640 * 2; //双声道*2 单声道640即可
        const int MP3_SIZE = 8800; //计算公式wav_buffer.length * 1.25 + 7200
        short int pcm_buffer[PCM_SIZE];
        unsigned char mp3_buffer[MP3_SIZE];
        
        int read, write;
        
        do {
            read = (int)fread(pcm_buffer, sizeof(short int), PCM_SIZE, fwav);
            if (read == 0) {
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            } else {
                //                write = lame_encode_buffer(lame, pcm_buffer, pcm_buffer, read, mp3_buffer, MP3_SIZE);
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read/2, mp3_buffer, MP3_SIZE);
                //                write = lame_encode_buffer_float(lame, pcm_buffer, pcm_buffer, read/2, mp3_buffer, MP3_SIZE);
            }
            fwrite(mp3_buffer, write, 1, fmp3);
        } while (read != 0);
        lame_close(lame);
        fclose(fmp3);
        fclose(fwav);
    } @catch (NSException *exception) {
        NSLog(@"catch exception");
    } @finally {
        block();
    }
}

- (void )encodeAudioFile:(NSString *)inputPath
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
                
                lame_set_in_samplerate(lame, kSamplerate * 0.5);
                lame_set_VBR(lame, vbr_default);
                lame_set_num_channels(lame,1);
                lame_set_brate(lame,8);
                lame_set_mode(lame,MONO);
                lame_set_quality(lame,2);
                lame_init_params(lame);
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

- (void)lame_dealloc
{
    lame_close(lame);
}

- (void)dealloc {
    lame_close(lame);
}

@end
