//
//  JAInputRecordManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/12/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAInputRecordManager.h"
#import "JAPermissionHelper.h"

#import <iflyMSC/IFlyPcmRecorder.h>
#import <iflyMSC/IFlyMSC.h>
#import "IATConfig.h"
#import "ISRDataHelper.h"
#import "LameManager.h"
#import "JAPlayLocalVoiceManager.h"
#import "JAVoicePlayerManager.h"
#import "JANewPlayTool.h"
#import "JANewPlaySingleTool.h"

@interface JAInputRecordManager ()<IFlyPcmRecorderDelegate,IFlySpeechRecognizerDelegate>

//@property (nonatomic, strong) MixerHostAudioEngine *recordEngine;

@property (nonatomic, assign, readwrite) JAInputRecordStatusType inputRecordStatus;
@property (nonatomic, strong) CADisplayLink *meterUpdateDisplayLink;

@property (nonatomic, strong) NSString *pcmFilePath;
@property (nonatomic, strong) NSString *mp3FilePath;

@property (nonatomic, assign) CGFloat fileDuration;  // 实时录制的时长（停止的时候会清零）
@property (nonatomic, assign) CGFloat listenDuration;  // 试听的进度时长(试听停止后会清零)
@end

@implementation JAInputRecordManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.pcmFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
        self.mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.mp3"];
        
        self.iflyResults = [NSMutableArray array];
    }
    return self;
}

// 讯飞识别
- (void)iflyDiscriminate
{
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"" forKey:[IFlySpeechConstant PARAMS]];
    
    //set recognition domain
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    
    [IFlySpeechRecognizer sharedInstance].delegate = self;
    
    IATConfig *instance = [IATConfig sharedInstance];
    
    //set timeout of recording
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.speechTimeout forKey:[IFlySpeechConstant SPEECH_TIMEOUT]];
    //set VAD timeout of end of speech(EOS)
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.vadEos forKey:[IFlySpeechConstant VAD_EOS]];
    //set VAD timeout of beginning of speech(BOS)
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.vadBos forKey:[IFlySpeechConstant VAD_BOS]];
    //set network timeout
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"20000" forKey:[IFlySpeechConstant NET_TIMEOUT]];
    
    //set sample rate, 16K as a recommended option
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.sampleRate forKey:[IFlySpeechConstant SAMPLE_RATE]];
    
    //set language
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.language forKey:[IFlySpeechConstant LANGUAGE]];
    //set accent
    [[IFlySpeechRecognizer sharedInstance] setParameter:instance.accent forKey:[IFlySpeechConstant ACCENT]];
    
    //set whether or not to show punctuation in recognition results
    if (self.maxTime) {
        [[IFlySpeechRecognizer sharedInstance] setParameter:[IATConfig noDot] forKey:[IFlySpeechConstant ASR_PTT]];
    }
    
    // 音频流识别
    [[IFlySpeechRecognizer sharedInstance] setParameter:@"json" forKey:[IFlySpeechConstant RESULT_TYPE]];
    [[IFlySpeechRecognizer sharedInstance] setParameter:IFLY_AUDIO_SOURCE_STREAM forKey:@"audio_source"];    //Set audio stream
}

#pragma mark - 讯飞识别
//识别结果返回代理
#warning v2.5.0bug crash，可能是因为弱网导致，此方法还未调用，对象已销毁
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast{
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSString * resultFromJson =  [ISRDataHelper stringFromJson:resultString];
    if (resultFromJson.length) {
        
        [self.iflyResults addObject:resultFromJson];
    }
    if (isLast){
    }
}
//识别会话结束返回代理
- (void)onError: (IFlySpeechError *) error{
    NSLog(@"识别错误%@",error);
}

/// 开始录制
- (void)inputRecordStart
{
    [self pausePlay]; // 暂停播放
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
    
    // 移除原有的文件 2.5.0 bug
    [self removeAvailFile];
    
    //设置屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
    self.inputRecordStatus = JAInputRecordStatusTypeRecording;   // 设置开始录音的状态
  
    // 初始化识别
    [self iflyDiscriminate];
    
    // 初始化录音
    [IFlyPcmRecorder sharedInstance].delegate = self;
    [[IFlyPcmRecorder sharedInstance] setSample:[IATConfig sharedInstance].sampleRate];
    [[IFlyPcmRecorder sharedInstance] setPowerCycle:0.1];
    
    [[IFlyPcmRecorder sharedInstance] setSaveAudioPath:self.pcmFilePath];
    
    [[IFlySpeechRecognizer sharedInstance] startListening];
    
    [IFlyAudioSession initRecordingAudioSession];
    [IFlySpeechRecognizer sharedInstance].delegate = self;
    
    
    [[IFlyPcmRecorder sharedInstance] start];
}

#pragma mark - 讯飞的代理回调

/*!
 *  回调录音音量
 *
 *  @param power 音量值
 */
- (void) onIFlyRecorderVolumeChanged:(int) power
{
    CGFloat vol = (arc4random() % 1000 + 9000) / 10000.0;
    CGFloat volume = vol * (power) * 2 / 3.0;
    self.fileDuration += 0.1;
    if ([self.delegate respondsToSelector:@selector(inputRecordWithDuration:volume:drawVolume:)]) {
        [self.delegate inputRecordWithDuration:self.fileDuration volume:power drawVolume:volume];
    }
    
    // **秒钟以后就停止监听
    if (self.maxTime) {
        if (self.fileDuration >= self.maxTime) {
            
            [self inputIflyStop];
        }
    }else{
        
        if (self.fileDuration >= JA_IFLY_Time) {
            
            [self inputIflyStop];
        }
    }
}

/*!
 *  回调音频数据
 *
 *  @param buffer 音频数据
 *  @param size   表示音频的长度
 */
- (void) onIFlyRecorderBuffer: (const void *)buffer bufferSize:(int)size
{
    NSData *audioBuffer = [NSData dataWithBytes:buffer length:size];
    int ret = [[IFlySpeechRecognizer sharedInstance] writeAudio:audioBuffer];
    if (!ret)
    {
        [[IFlySpeechRecognizer sharedInstance] stopListening];
    }
}

/*!
 *  回调音频的错误码
 *
 *  @param recoder 录音器
 *  @param error   错误码
 */
- (void) onIFlyRecorderError:(IFlyPcmRecorder*)recoder theError:(int) error
{
    
}


/// 结束录制
- (void)inputRecordStop
{
    self.inputRecordStatus = JAInputRecordStatusTypeRecordFinish;  // 设置结束录音的状态
    self.fileDuration = 0.0;
    [[IFlyPcmRecorder sharedInstance] stop];
    
    [MBProgressHUD showMessage:@"录音保存中..."];
    [LameManager encodeAudioFile:self.pcmFilePath output:self.mp3FilePath complete:^{
        [MBProgressHUD hideHUD];
        self.recordFile = self.mp3FilePath;
        // 通知外面录制保存完成
        if ([self.delegate respondsToSelector:@selector(inputRecordFinish)]) {
            [self.delegate inputRecordFinish];
        }
    } failure:^(NSString *reason) {
        [MBProgressHUD hideHUD];
        self.recordFile = nil;
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"保存录音文件失败，请重录"];
        
        [self removeAvailFile];
        // 通知外面录制失败
        if ([self.delegate respondsToSelector:@selector(inputRecordFinishFaile)]) {
            [self.delegate inputRecordFinishFaile];
        }
        
    }];
    
    //取消屏幕常亮
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

/// 开始试听
- (void)inputRecordListenBegin
{
    if (self.recordFile.length) {
       
        [self resetPlayResource];
        self.inputRecordStatus = JAInputRecordStatusTypeListening;
        
        // 播放本地音频
        [[JAPlayLocalVoiceManager sharePlayVoiceManager] playLocalVoiceWith:self.recordFile];
        
        self.meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateListenAnimate)];
        self.meterUpdateDisplayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
        [self.meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"无效的音频文件，请重录"];
    }
}

/// 停止试听
- (void)inputRecordListenStop
{
    self.inputRecordStatus = JAInputRecordStatusTypeListenFinish;
//    停止定时器
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = nil;

    self.listenDuration = 0.0;
    
//    [[JAVoicePlayerManager shareInstance] stop];
    
    // 停止本地音频
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
}

// 开始试听
- (void)updateListenAnimate
{
    if ([self.delegate respondsToSelector:@selector(inputListenWithPlayDuration:)]) {
        [self.delegate inputListenWithPlayDuration:self.listenDuration];
        self.listenDuration += 0.1;
    }
}

/// 暂停试听
- (void)inputRecordListenPause
{
    self.meterUpdateDisplayLink.paused = YES;
    self.inputRecordStatus = JAInputRecordStatusTypeListenPause;
//    [[JAVoicePlayerManager shareInstance] pause];
    
    // 暂停本地音频
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] pauseLocalVoice];
}

/// 继续试听
- (void)inputRecordListenContinue
{
    self.meterUpdateDisplayLink.paused = NO;
    self.inputRecordStatus = JAInputRecordStatusTypeListening;
//    [[JAVoicePlayerManager shareInstance] contiunePlay];
    
    // 继续本地音频
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] resumeLocalVoice];
}

/// 停止讯飞识别
- (void)inputIflyStop
{
    if ([IFlySpeechRecognizer sharedInstance].isListening) {
        [[IFlySpeechRecognizer sharedInstance] stopListening];
    }
}

#pragma mark - 私有方法
/// 清理别人的播放帖子、回复的资源
- (BOOL)resetPlayResource
{
    [[JAVoicePlayerManager shareInstance] beforeLocalPlayResetAll];
    return YES;
}

// 暂停别人的播放（帖子、回复） - 停止播放帖子
- (void)pausePlay
{
    [[JAVoicePlayerManager shareInstance] pause];
    [[JAVoicePlayerManager shareInstance] cancelDelayPlayNextVoice];
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];
    [[JANewPlayTool shareNewPlayTool] playTool_pause];

}

- (void)dealloc
{
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    // 不停止可能导致科大讯飞的crash
    [self inputIflyStop];
}

// 移除文件
- (void)removeAvailFile
{
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *pcmFilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record_pcm"];
    NSString *mp3FilePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/record.mp3"];
    
    BOOL isExists = [manager fileExistsAtPath:pcmFilePath];
    if (isExists) {
        [manager removeItemAtPath:pcmFilePath error:nil];
    }
    BOOL isExists1 = [manager fileExistsAtPath:mp3FilePath];
    if (isExists1) {
        [manager removeItemAtPath:mp3FilePath error:nil];
    }
}
@end
