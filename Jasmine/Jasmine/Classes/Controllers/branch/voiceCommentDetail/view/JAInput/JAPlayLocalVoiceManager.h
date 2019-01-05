//
//  JAPlayLocalVoiceManager.h
//  Jasmine
//
//  Created by moli-2017 on 2018/1/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, JAPlayLocalVoiceStatus) {
    JAPlayLocalVoiceStatusListening,
    JAPlayLocalVoiceStatusPause,
    JAPlayLocalVoiceStatusStop,
};

@interface JAPlayLocalVoiceManager : NSObject
@property (nonatomic, strong, readonly) AVAudioPlayer *player;
@property (nonatomic, assign, readonly) BOOL playLocalVoiceStatus;

+ (instancetype)sharePlayVoiceManager;

// 播放
- (AVAudioPlayer *)playLocalVoiceWith:(NSString *)playPath;

// 暂停
- (void)pauseLocalVoice;

// 继续
- (void)resumeLocalVoice;

// 停止
- (void)stopLocalVoice;

@end
