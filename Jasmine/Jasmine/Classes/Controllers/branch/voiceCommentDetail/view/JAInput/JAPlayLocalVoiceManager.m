//
//  JAPlayLocalVoiceManager.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPlayLocalVoiceManager.h"

@interface JAPlayLocalVoiceManager ()
@property (nonatomic, strong) AVAudioPlayer *player;
@property (nonatomic, assign, readwrite) BOOL playLocalVoiceStatus;
@end

@implementation JAPlayLocalVoiceManager

+ (instancetype)sharePlayVoiceManager
{
    static JAPlayLocalVoiceManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAPlayLocalVoiceManager alloc] init];
        }
    });
    return instance;
}

// 播放
- (AVAudioPlayer *)playLocalVoiceWith:(NSString *)audioPath
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];

    NSURL *url = [NSURL URLWithString:audioPath];
    if (url == nil) {
        url = [[NSBundle mainBundle] URLForResource:audioPath.lastPathComponent withExtension:nil];
    }
    
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.player prepareToPlay];
    [self.player play];
    self.playLocalVoiceStatus = JAPlayLocalVoiceStatusListening;
    return self.player;
}

// 暂停
- (void)pauseLocalVoice
{
    self.playLocalVoiceStatus = JAPlayLocalVoiceStatusListening;
    [self.player pause];
}

// 继续
- (void)resumeLocalVoice
{
    self.playLocalVoiceStatus = JAPlayLocalVoiceStatusPause;
    [self.player play];
}

// 停止
- (void)stopLocalVoice
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"stopLocalVoice" object:nil];
    self.playLocalVoiceStatus = JAPlayLocalVoiceStatusStop;
    [self.player stop];
}
@end
