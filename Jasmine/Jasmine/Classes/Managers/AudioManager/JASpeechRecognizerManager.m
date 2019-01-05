//
//  JASpeechRecognizerManager.m
//  Jasmine
//
//  Created by xujin on 13/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JASpeechRecognizerManager.h"
#import <iflyMSC/IFlyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "LameManager.h"

@interface JASpeechRecognizerManager()<IFlySpeechRecognizerDelegate, IFlyPcmRecorderDelegate>

@property (nonatomic, strong) IFlySpeechRecognizer *iFlySpeechRecognizer;
@property (nonatomic, strong) IFlyPcmRecorder *pcmRecorder;

@end

@implementation JASpeechRecognizerManager

+ (JASpeechRecognizerManager *)shareInstance
{
    static JASpeechRecognizerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JASpeechRecognizerManager alloc] init];
            instance.result = [NSMutableString new];
            instance.pcmFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
            instance.mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.mp3"];
        }
    });
    return instance;
}

- (void)setup {
    NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"5a000f0c"];
    //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
    [IFlySpeechUtility createUtility:initString];
}

- (void)createSpeechRecognizer {
    //recognition singleton without view
    if (_iFlySpeechRecognizer == nil) {
        _iFlySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    }
    
    [_iFlySpeechRecognizer setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //set recognition domain
    [_iFlySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    _iFlySpeechRecognizer.delegate = self;
    
    if (_iFlySpeechRecognizer != nil) {
        IATConfig *instance = [IATConfig sharedInstance];
        
        //set timeout of recording
        [_iFlySpeechRecognizer setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
        //set VAD timeout of end of speech(EOS)
        [_iFlySpeechRecognizer setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
        //set VAD timeout of beginning of speech(BOS)
        [_iFlySpeechRecognizer setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
        //set network timeout
        [_iFlySpeechRecognizer setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
        
        //set sample rate, 16K as a recommended option
        [_iFlySpeechRecognizer setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
        
        //set language
        [_iFlySpeechRecognizer setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
        //set accent
        [_iFlySpeechRecognizer setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
        
        //set whether or not to show punctuation in recognition results
        [_iFlySpeechRecognizer setParameter:instance.dot forKey:[IFlySpeechConstant ASR_PTT]];
        
    }
    
    // 音频流识别
    [_iFlySpeechRecognizer setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [_iFlySpeechRecognizer setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //Set audio stream
}

//- (void)createPcmRecord {
//    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
//    [self createPcmRecordFilePath:filePath];
//}
//
//- (void)createPcmRecordFilePath:(NSString *)filePath {
//    self.pcmFilePath = filePath;
//
//    //Initialize recorder
//    if (_pcmRecorder == nil)
//    {
//        _pcmRecorder = [IFlyPcmRecorder sharedInstance];
//    }
//
//    _pcmRecorder.delegate = self;
//
//    [_pcmRecorder setSample:[IATConfig sharedInstance].sampleRate];
//
//    [_pcmRecorder setSaveAudioPath:filePath];    //not save the audio file
//}

- (void)startRecord {
    [self.pcmRecorder start];
}

//     [LameManager encodeAudioFile:self.pcmFilePath output:self.mp3FilePath complete:nil failure:nil];

- (void)stopRecord {
    [self.pcmRecorder stop];
}

- (void)resetRecord {
    self.result = [NSMutableString new];
}

#pragma mark - iFlySpeechRecognizerDelegate

/**
 result callback of recognition without view
 results：recognition results
 isLast：whether or not this is the last result
 **/
//识别结果返回代理
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    if (resultFromJson.length) {
        [self.result appendString:resultFromJson];
    }
    if (isLast){
    }
}
//识别会话结束返回代理
- (void)onError: (IFlySpeechError *) error{}
//停止录音回调
- (void) onEndOfSpeech{}
//开始录音回调
- (void) onBeginOfSpeech{}
//音量回调函数
- (void) onVolumeChanged: (int)volume{}
//会话取消回调
- (void) onCancel{}

#pragma mark - IFlyPcmRecorderDelegate
- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    int ret = [self.iFlySpeechRecognizer writeAudio:audioBuffer];
    if (!ret)
    {
        [self.iFlySpeechRecognizer stopListening];
    }
}

- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}

//range from 0 to 30
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    //    NSLog(@"%s,power=%d",__func__,power);
}

@end
