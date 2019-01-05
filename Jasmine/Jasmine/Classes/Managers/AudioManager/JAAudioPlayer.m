//
//  JAAudioPlayer.m
//  Jasmine
//
//  Created by xujin on 04/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface JAAudioPlayer ()<AVAudioPlayerDelegate>

@property (nonatomic, copy) void (^playFinishBlock)(void);

@end

@implementation JAAudioPlayer

+ (JAAudioPlayer *)shareInstance
{
    static JAAudioPlayer *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAAudioPlayer alloc] init];
        }
    });
    return instance;
}
- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void)play:(NSURL *)url finishBlock:(void(^)(void))playFinishBlock
{
    self.playFinishBlock = playFinishBlock;

    if (self.player) {
        [self.player pause];
    }
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    _player.delegate = self;
    if (_player == NULL)
    {
        NSLog(@"fail to play audio :(");
        return;
    }
    
    [_player setVolume:1];
    [_player play];
}

- (void)pause {
    [_player pause];
}

- (void)continuePlay {
    [_player play];
}

- (void)stop {
    [_player pause];
    _player = nil;
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        if (self.playFinishBlock) {
            self.playFinishBlock();
        }
    }
}

@end
