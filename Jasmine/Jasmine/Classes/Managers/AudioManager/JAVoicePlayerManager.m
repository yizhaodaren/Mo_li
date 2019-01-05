//
//  JAVoicePlayerManager.m
//  Jasmine
//
//  Created by xujin on 09/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoicePlayerManager.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceCommentGroupModel.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JAVoiceCommonApi.h"
#import <MediaPlayer/MediaPlayer.h>
#import "JAPlayLocalVoiceManager.h"
#import "JAVoicePlayerManager.h"
#import "JANewPlayTool.h"
#import "JANewPlaySingleTool.h"

@implementation JAVoicePlayerItem

@end

@interface JAVoicePlayerManager ()<STKAudioPlayerDelegate, AVAudioPlayerDelegate> {
    
    SystemSoundID _soundID;
}

@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isPause;

@property (nonatomic, strong) CADisplayLink *meterUpdateDisplayLink;

@property (nonatomic, strong) NSHashTable *delegateArr;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) AVAudioPlayer *dubPlayer;
@property (nonatomic, assign) BOOL isSkipButtonClick;

@property (nonatomic, strong) JAVoiceModel *voiceModel;
@property (nonatomic, strong) JAVoiceCommentModel *commentModel;
@property (nonatomic, strong) JAVoiceReplyModel *replyModel;

@end

@implementation JAVoicePlayerManager

+ (JAVoicePlayerManager *)shareInstance
{
    static JAVoicePlayerManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAVoicePlayerManager alloc] init];
            instance.delegateArr = [NSHashTable weakObjectsHashTable];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    
//        NSURL *soundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sourcetwo" ofType:@"wav"]];
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)soundUrl, &_soundID);
        
        //处理中断事件的通知
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleInterreption:)
                                                     name:AVAudioSessionInterruptionNotification
                                                   object:[AVAudioSession sharedInstance]];
        //添加通知，拔出耳机后暂停播放
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(routeChange:)
//                                                     name:AVAudioSessionRouteChangeNotification
//                                                   object:nil];
//        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//
//        //远程控制
//        [[MPRemoteCommandCenter sharedCommandCenter].playCommand addTarget:self action:@selector(back_play)];
//        [[MPRemoteCommandCenter sharedCommandCenter].pauseCommand addTarget:self action:@selector(back_pause)];
//        [[MPRemoteCommandCenter sharedCommandCenter].nextTrackCommand addTarget:self action:@selector(back_next)];
//        [[MPRemoteCommandCenter sharedCommandCenter].togglePlayPauseCommand addTarget:self action:@selector(back_headset)];
    }
    return self;
}

- (void)setVoiceModel:(JAVoiceModel *)voiceModel {
    // 播放方式：0点击进度条上的播放按钮 1点击帖子卡片上的播放按钮 2自动播放
    [self setVoiceModel:voiceModel playMethod:1];
}
- (void)setCommentModel:(JAVoiceCommentModel *)commentModel {
    [self setCommentModel:commentModel playMethod:1];
}
- (void)setReplyModel:(JAVoiceReplyModel *)replyModel {
    [self setReplyModel:replyModel playMethod:1];
}

- (void)setVoiceModel:(JAVoiceModel *)voiceModel playMethod:(NSInteger)playMethod {
    if (![JAAPPManager isConnect]) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请检查您的网络！"];
        return;
    }
    if (_voiceModel) {
        _voiceModel.playState = 0;
        if (_voiceModel.finishState == VoicePlayStateBegin) {
            [self voiceGroupEvent];
        }
        _voiceModel = nil;
    }
    
    if (_commentModel) {
        _commentModel.playState = 0;
        if (_commentModel.finishState == VoicePlayStateBegin) {
            [self commentGroupEvent];
        }
        _commentModel = nil;
    }
    
    if (_replyModel) {
        _replyModel.playState = 0;
        if (_replyModel.finishState == VoicePlayStateBegin) {
            [self replyGroupEvent];
        }
        _replyModel = nil;
    }
    
    _voiceModel = voiceModel;
    if (voiceModel) {
        // 播放新的音频，先停止原有的
        [self stop];
        
        _voiceModel.finishState = VoicePlayStateBegin;
//        self.voiceModel.playState = 1;
        self.currentPlayCommentIndex = -1;
        self.currentPlayReplyIndex = -1;
        [self play:[NSURL URLWithString:voiceModel.audioUrl]];
        
        /// 统计播放
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"dataType"] = JA_STORY_TYPE;
        dic[@"type"] = @"play";
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"categoryId"] = voiceModel.categoryId;
        dic[@"typeId"] = voiceModel.voiceId;
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
    
        [JASensorsAnalyticsManager sensorsAnalytics_startPlayVoiceModel:voiceModel method:playMethod];
        
        // v2.4.1新增playMethod
        voiceModel.playMethod = (playMethod == 2)?0:1;
        
        // v2.5.0
        // 停止发布回复时的试听
        [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
        
//        // v2.6.4
//        // 保存播放的帖子
//        [self saveLastVoiceModel:voiceModel];
    }
}

- (void)setCommentModel:(JAVoiceCommentModel *)commentModel playMethod:(NSInteger)playMethod {
    if (![JAAPPManager isConnect]) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请检查您的网络！"];
        return;
    }
    if (_commentModel) {
        _commentModel.playState = 0;
        if (_commentModel.finishState == VoicePlayStateBegin) {
            [self commentGroupEvent];
        }
        _commentModel = nil;
    }
    
    if (_voiceModel) {
        _voiceModel.playState = 0;
        if (_voiceModel.finishState == VoicePlayStateBegin) {
            [self voiceGroupEvent];
        }
        _voiceModel = nil;
    }
    
    if (_replyModel) {
        _replyModel.playState = 0;
        if (_replyModel.finishState == VoicePlayStateBegin) {
            [self replyGroupEvent];
        }
        _replyModel = nil;
    }
    
    _commentModel = commentModel;
    if (commentModel) {
        // 播放新的音频，先停止原有的
        [self stop];
        
//        self.voiceModel.isPlayingComment = YES;
        _commentModel.finishState = VoicePlayStateBegin;
//        self.commentModel.playState = 1;
        self.currentPlayReplyIndex = -1;
        [self play:[NSURL URLWithString:commentModel.audioUrl]];

        /// 统计播放
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"dataType"] = JA_COMMENT_TYPE;
        dic[@"type"] = @"play";
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"categoryId"] = commentModel.categoryId;
        dic[@"typeId"] = commentModel.voiceCommendId;
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
        
        [JASensorsAnalyticsManager sensorsAnalytics_startPlayCommentModel:commentModel method:playMethod];
        
        // v2.4.1新增playMethod
        commentModel.playMethod = (playMethod == 2)?0:1;
        
        // v2.5.0
        // 停止发布回复时的试听
        [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
        
//        // v2.6.4
//        // 保存播放的帖子
//        JAVoiceModel *voiceModel = [JAVoiceModel new];
//        voiceModel.voiceId = commentModel.typeId;
//        voiceModel.userImage = commentModel.userImage;
//        [self saveLastVoiceModel:voiceModel];
    }
}

- (void)setReplyModel:(JAVoiceReplyModel *)replyModel playMethod:(NSInteger)playMethod {
    if (![JAAPPManager isConnect]) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请检查您的网络！"];
        return;
    }
    if (_replyModel) {
        _replyModel.playState = 0;
        if (_replyModel.finishState == VoicePlayStateBegin) {
            [self replyGroupEvent];
        }
        _replyModel = nil;
    }
    
    if (_voiceModel) {
        _voiceModel.playState = 0;
        if (_voiceModel.finishState == VoicePlayStateBegin) {
            [self voiceGroupEvent];
        }
        _voiceModel = nil;
    }
    
    if (_commentModel) {
        _commentModel.playState = 0;
        if (_commentModel.finishState == VoicePlayStateBegin) {
            [self commentGroupEvent];
        }
        _commentModel = nil;
    }
    _replyModel = replyModel;
    if (replyModel) {
        // 播放新的音频，先停止原有的
        [self stop];
        
        _replyModel.finishState = VoicePlayStateBegin;
//        self.replyModel.playState = 1;
        [self play:[NSURL URLWithString:replyModel.audioUrl]];

        /// 统计播放
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"dataType"] = JA_REPLY_TYPE;
        dic[@"type"] = @"play";
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"categoryId"] = replyModel.categoryId;
        dic[@"typeId"] = replyModel.voiceReplyId;
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
        
        [JASensorsAnalyticsManager sensorsAnalytics_startPlayReplyModel:replyModel method:playMethod];
        
        // v2.4.1新增playMethod
        replyModel.playMethod = (playMethod == 2)?0:1;
        
        // v2.5.0
        // 停止发布回复时的试听
        [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
        
//        // v2.6.4
//        // 保存播放的帖子
//        JAVoiceModel *voiceModel = [JAVoiceModel new];
//        voiceModel.voiceId = replyModel.storyId;
//        voiceModel.userImage = replyModel.userImage;
//        [self saveLastVoiceModel:voiceModel];
    }
}

// 主帖播放跳过、结束、时长事件统计
- (void)voiceGroupEvent {
    // 统计跳过
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_STORY_TYPE;
    dic[@"type"] = @"skip";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"categoryId"] = self.voiceModel.categoryId;
    dic[@"typeId"] = self.voiceModel.voiceId;
    
//    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
    [self statisticalData:dic];
    
    // 播放时长
    int playTime = (int)self.player.progress;
    if (playTime > 0) {
        dic[@"type"] = @"play_time";
        dic[@"palyTime"] = @((int)self.player.progress);
        // v2.4.1新增参数status（0自动播放，1手动播放）
        dic[@"status"] = @(self.voiceModel.playMethod);
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
    }
    
    [JASensorsAnalyticsManager sensorsAnalytics_endPlayVoiceModel:self.voiceModel playDuration:(int)self.player.progress];
    [JASensorsAnalyticsManager sensorsAnalytics_skipPlayVoiceModel:self.voiceModel method:1];
}

// 一级回复播放事件统计
- (void)commentGroupEvent {
    // 统计跳过
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_COMMENT_TYPE;
    dic[@"type"] = @"skip";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"categoryId"] = self.commentModel.categoryId;
    dic[@"typeId"] = self.commentModel.voiceCommendId;
//    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
    [self statisticalData:dic];
    
    // 播放时长
    int playTime = (int)self.player.progress;
    if (playTime > 0) {
        dic[@"type"] = @"play_time";
        dic[@"palyTime"] = @((int)self.player.progress);
        // v2.4.1新增参数status（0自动播放，1手动播放）
        dic[@"status"] = @(self.commentModel.playMethod);
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
    }

    [JASensorsAnalyticsManager sensorsAnalytics_endPlayCommentModel:self.commentModel playDuration:(int)self.player.progress];
    [JASensorsAnalyticsManager sensorsAnalytics_skipPlayCommentModel:self.commentModel method:1];
}

// 二级回复播放事件统计
- (void)replyGroupEvent {
    // 统计跳过
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_REPLY_TYPE;
    dic[@"type"] = @"skip";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"categoryId"] = self.replyModel.categoryId;
    dic[@"typeId"] = self.replyModel.voiceReplyId;
//    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
    [self statisticalData:dic];
    
    // 播放时长
    int playTime = (int)self.player.progress;
    if (playTime > 0) {
        dic[@"type"] = @"play_time";
        dic[@"palyTime"] = @((int)self.player.progress);
        // v2.4.1新增参数status（0自动播放，1手动播放）
        dic[@"status"] = @(self.replyModel.playMethod);
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
    }
    
    [JASensorsAnalyticsManager sensorsAnalytics_endPlayReplyModel:self.replyModel playDuration:(int)self.player.progress];
    [JASensorsAnalyticsManager sensorsAnalytics_skipPlayReplyModel:self.replyModel method:1];
}

- (void)play:(NSURL *)url
{
    if (!url.path.length) {
        [MBProgressHUD showError:@"文件不存在！"];
        return;
    }
    [self cancelDelayPlayNextVoice];
    [self.dubPlayer stop];

    //    设置后台播放模式
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [audioSession setActive:YES error:nil];
    
    if (!self.player) {
        
        STKAudioPlayer *audioPlayer = [[STKAudioPlayer alloc] init];

//        STKAudioPlayer* audioPlayer = [[STKAudioPlayer alloc] initWithOptions:(STKAudioPlayerOptions){ .flushQueueOnSeek = YES, .enableVolumeMixer = NO, .equalizerBandFrequencies = {50, 100, 200, 400, 800, 1600, 2600, 16000} }];
//        audioPlayer.meteringEnabled = YES;
        audioPlayer.volume = 1.0;
        audioPlayer.delegate = self;
        self.player = audioPlayer;
    }

//    [self.player queueURL:url];
//    //    设置后台播放模式
//    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [audioSession setActive:YES error:nil];
//    
//    [self startUpdatingMeter];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.player queueURL:url];
//        //    设置后台播放模式
//        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
//        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [audioSession setActive:YES error:nil];
//        
//        [self startUpdatingMeter];
//    });

//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playVoice:) object:url];
//    [self performSelector:@selector(playVoice:) withObject:url afterDelay:0.0 inModes:@[NSRunLoopCommonModes]];
    [self playVoice:url];
}

- (void)playVoice:(NSURL *)url {
    [self.player playURL:url];
    // 一定几率导致播放完音频不触发任何callback
//    [self.player queueURL:url];
    [self startUpdatingMeter];
    
    [[JANewPlayTool shareNewPlayTool] playTool_pause];
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];
}

- (void)stop
{
    [self.player stop];
    [self stopUpdatingMeter];
    [self dispose];
}

- (void)dispose {
    [self.player dispose];
    self.player = nil;
    [self stopUpdatingMeter];
}

- (void)pause
{
    [self.player pause];
    [self pauseUI];
}

- (void)resetUI {
    if (self.voiceModel) self.voiceModel.playState = 0;
    if (self.commentModel) self.commentModel.playState = 0;
    if (self.replyModel) self.replyModel.playState = 0;
}

- (void)pauseUI {
    [self pauseUpdatingMeter];
    
    if (self.voiceModel) self.voiceModel.playState = 2;
    if (self.commentModel) self.commentModel.playState = 2;
    if (self.replyModel) self.replyModel.playState = 2;
}

- (void)contiunePlay
{
    if (![JAAPPManager isConnect]) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请检查您的网络！"];
        return;
    }
    //    设置后台播放模式
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [audioSession setActive:YES error:nil];
    
    [self.player resume];
}

- (void)contiuneUI {
    [self continueUpdatingMeter];
    
    if (self.voiceModel) self.voiceModel.playState = 1;
    if (self.commentModel) self.commentModel.playState = 1;
    if (self.replyModel) self.replyModel.playState = 1;
}

- (void)bufferingUI {
    [self pauseUpdatingMeter];
    
    if (self.voiceModel) self.voiceModel.playState = 3;
    if (self.commentModel) self.commentModel.playState = 3;
    if (self.replyModel) self.replyModel.playState = 3;
}

- (void)cancelDelayPlayNextVoice {
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(delayPlayNextVoice) object:nil];
}

- (void)delayPlayNextVoice {
    if (self.currentPlayIndex > self.voices.count-1) {
        return;
    }
    // v2.4.0 评论和回复不在自动播放---v2.4.1又改回来了
    JAVoiceModel *voiceModel = self.voices[self.currentPlayIndex];
    [self getVoiceCommentListWithTypeId:voiceModel.voiceId];
    [self setVoiceModel:voiceModel playMethod:2];
}

- (JAVoiceCommentModel *)getPlayCommentModel {
    while (YES) {
        JAVoiceCommentModel *commentModel = self.commentVoices[self.currentPlayCommentIndex];
        if (commentModel.audioUrl.length) {
            return commentModel;
        } else {
            ++self.currentPlayCommentIndex;
            if (self.currentPlayCommentIndex >= self.commentVoices.count) {
                self.currentPlayCommentIndex = self.commentVoices.count-1;
                self.commentVoices = nil;
                
                return nil;
            }
        }
    }
    return nil;
}

- (JAVoiceReplyModel *)getPlayReplyModel {
    while (YES) {
        JAVoiceReplyModel *replyModel = self.replyVoices[self.currentPlayReplyIndex];
        if (_commentModel.audioUrl.length) {
            return replyModel;
        } else {
            ++self.currentPlayReplyIndex;
            if (self.currentPlayReplyIndex >= self.replyVoices.count) {
                self.currentPlayReplyIndex = self.replyVoices.count-1;
                self.replyVoices = nil;
                
                return nil;
            }
        }
    }
    return nil;
}

// 播放下一条音频
- (void)playNextMusic
{
    if (self.isInRecord) {
        return;
    }
    // 因播放条需要继续播放，不能清理model
    if (self.voices.count) {
        // 首页主帖跳过
//        if ([JAVoicePlayerManager shareInstance].isHomeData) {
//            [JAVoicePlayerManager shareInstance].commentVoices = nil;
//        }
        BOOL isListData = [JAVoicePlayerManager shareInstance].isHomeData;
        BOOL isNeedHandle = isListData?(self.currentPlayCommentIndex<4):YES;
        if (self.commentVoices.count && isNeedHandle) {
            ++self.currentPlayCommentIndex;
            if (_currentPlayCommentIndex >= self.commentVoices.count) {
                _currentPlayCommentIndex = self.commentVoices.count-1;
                self.commentVoices = nil;
//                self.commentModel = nil;
            } else {
                JAVoiceCommentModel *commentModel = [self getPlayCommentModel];
                if (commentModel) {
                    [self setCommentModel:commentModel playMethod:2];
                    return;
                }
            }
        }
        ++self.currentPlayIndex;
        if (_currentPlayIndex >= self.voices.count) {
            _currentPlayIndex = self.voices.count-1;
            self.voices = nil;
//            self.voiceModel = nil;
            return;
        }
        
        [self.dubPlayer stop];
        
        NSURL *soundUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"sourcetwo" ofType:@"wav"]];
        
        NSError *error;
        self.dubPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:&error];
        self.dubPlayer.volume = 1.0;
        self.dubPlayer.delegate = self;
        [self.dubPlayer prepareToPlay];
        [self.dubPlayer play];
        
//        [self cancelDelayPlayNextVoice];
//        [self performSelector:@selector(delayPlayNextVoice) withObject:nil afterDelay:0.8 inModes:@[NSRunLoopCommonModes]];
        return;
    }
   
    if (self.commentVoices.count) {
        if (self.replyVoices.count) {
            ++self.currentPlayReplyIndex;
            if (_currentPlayReplyIndex >= self.replyVoices.count) {
                _currentPlayReplyIndex = self.replyVoices.count-1;
                self.replyVoices = nil;
//                self.replyModel = nil;
            } else {
                JAVoiceReplyModel *replyModel = [self getPlayReplyModel];
                if (replyModel) {
                    [self setReplyModel:replyModel playMethod:2];
                    return;
                }
            }
        }
        ++self.currentPlayCommentIndex;
        if (_currentPlayCommentIndex >= self.commentVoices.count) {
            _currentPlayCommentIndex = self.commentVoices.count-1;
            self.commentVoices = nil;
//            self.commentModel = nil;
            return;
        }
        JAVoiceCommentModel *commentModel = [self getPlayCommentModel];
        if (commentModel) {
            [self setCommentModel:commentModel playMethod:2];
        }
        return;
    }
    
    if (self.replyVoices.count) {
        ++self.currentPlayReplyIndex;
        if (_currentPlayReplyIndex >= self.replyVoices.count) {
            _currentPlayReplyIndex = self.replyVoices.count-1;
            self.replyVoices = nil;
//            self.replyModel = nil;
            return;
        }
        JAVoiceReplyModel *replyModel = [self getPlayReplyModel];
        if (replyModel) {
            [self setReplyModel:replyModel playMethod:2];
        }
    }
}

// 手动下一曲，也调用了此方法，不合理(自动、手动播放下一曲都会调用)
- (void)playbackFinished {

    ///  播放完成后 把当前播放的帖子的状态置为完成状态
    if (self.voiceModel.playState == 1) {
        self.voiceModel.finishState = VoicePlayStateFinish;
        
        if (self.player.state == STKAudioPlayerStateStopped) {
            // 播放时长
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"dataType"] = JA_STORY_TYPE;
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"categoryId"] = self.voiceModel.categoryId;
            dic[@"typeId"] = self.voiceModel.voiceId;
            
            dic[@"type"] = @"play_time";
            dic[@"palyTime"] = @([NSString getSeconds:self.voiceModel.time]);
            // v2.4.1新增参数status（0自动播放，1手动播放）
            dic[@"status"] = @(self.voiceModel.playMethod);
//            [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
            [self statisticalData:dic];
            
            [JASensorsAnalyticsManager sensorsAnalytics_endPlayVoiceModel:self.voiceModel playDuration:-1];
        }
    }
    
    if (self.commentModel.playState == 1) {
        self.commentModel.finishState = VoicePlayStateFinish;
        
        if (self.player.state == STKAudioPlayerStateStopped) {
            // 播放时长
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"dataType"] = JA_COMMENT_TYPE;
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"categoryId"] = self.commentModel.categoryId;
            dic[@"typeId"] = _commentModel.voiceCommendId;
            
            dic[@"type"] = @"play_time";
            dic[@"palyTime"] = @([NSString getSeconds:self.commentModel.time]);
            // v2.4.1新增参数status（0自动播放，1手动播放）
            dic[@"status"] = @(self.commentModel.playMethod);
//            [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
            [self statisticalData:dic];
            
            [JASensorsAnalyticsManager sensorsAnalytics_endPlayCommentModel:self.commentModel playDuration:-1];
        }
    }
    
    if (self.replyModel.playState == 1) {
        self.replyModel.finishState = VoicePlayStateFinish;
        
        if (self.player.state == STKAudioPlayerStateStopped) {
            /// 播放时长
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"dataType"] = JA_REPLY_TYPE;
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"categoryId"] = self.replyModel.categoryId;
            dic[@"typeId"] = self.replyModel.voiceReplyId;
            
            dic[@"type"] = @"play_time";
            dic[@"palyTime"] = @([NSString getSeconds:self.replyModel.time]);
            // v2.4.1新增参数status（0自动播放，1手动播放）
            dic[@"status"] = @(self.replyModel.playMethod);
//            [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
            [self statisticalData:dic];
            
            [JASensorsAnalyticsManager sensorsAnalytics_endPlayReplyModel:self.replyModel playDuration:-1];
        }
    }
    
    // 可能没有下一曲，所以要先停止掉定时器
    [self stopUpdatingMeter];
    
    self.voiceModel.playState = 0;
    self.commentModel.playState = 0;
    self.replyModel.playState = 0;

    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
    });
    // 自动播放下一曲
    [self playNextMusic];

//    if(self.delegate && [self.delegate respondsToSelector:@selector(audioPlayerDidPlayFinished)]){
//        [self.delegate performSelector:@selector(audioPlayerDidPlayFinished)];
//    }
    
    // 播放结束
    for (id<JAPlayerDelegate> delegate in _delegateArr) {
        if(delegate && [delegate respondsToSelector:@selector(audioPlayerDidPlayFinished)]){
            [delegate performSelector:@selector(audioPlayerDidPlayFinished)];
        }
    }
}

- (BOOL)isPlaying {
    if (self.player.state == STKAudioPlayerStatePlaying) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isPause {
    if (self.player.state == STKAudioPlayerStatePaused) {
        return YES;
    } else {
        return NO;
    }
}

- (void)seekToTimeWithSliderValue:(float)value {
    [self.player seekToTime:value];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Privite
//- (void)saveLastVoiceModel:(JAVoiceModel *)voiceModel {
//    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//    NSString *cachePath = [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"lastVoiceModel"];
//    JAVoiceModel *lastVoiceModel = nil;
//    @try {
//        lastVoiceModel = [NSKeyedUnarchiver unarchiveObjectWithFile:cachePath];
//    } @catch (NSException *exception) {
//        lastVoiceModel = nil;
//    }
//    if (lastVoiceModel) {
//        if (![lastVoiceModel.voiceId isEqualToString:voiceModel.voiceId]) {
//            // 不同帖子需重新记录
//            NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//            NSString *cachePath = [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"lastVoiceModel"];
//            [NSKeyedArchiver archiveRootObject:voiceModel toFile:cachePath];
//        }
//    } else {
//        // 第一次直接保存
//        NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
//        NSString *cachePath = [[cachePaths objectAtIndex:0] stringByAppendingPathComponent:@"lastVoiceModel"];
//        [NSKeyedArchiver archiveRootObject:voiceModel toFile:cachePath];
//    }
//}

#pragma mark - Public
- (void)beforeLocalPlayResetAll {
    [JAVoicePlayerManager shareInstance].voices = nil;
    [JAVoicePlayerManager shareInstance].commentVoices = nil;
    [JAVoicePlayerManager shareInstance].replyVoices = nil;
    
    [JAVoicePlayerManager shareInstance].voiceModel.playState = 0;
    [JAVoicePlayerManager shareInstance].commentModel.playState = 0;
    [JAVoicePlayerManager shareInstance].replyModel.playState = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
    
    [JAVoicePlayerManager shareInstance].voiceModel = nil;
    [JAVoicePlayerManager shareInstance].commentModel = nil;
    [JAVoicePlayerManager shareInstance].replyModel = nil;
    
    [[JAVoicePlayerManager shareInstance] dispose];
}

#pragma mark - 定时器
- (void)startUpdatingMeter {
    if (!self.meterUpdateDisplayLink) {
        self.meterUpdateDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        self.meterUpdateDisplayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
        //    self.meterUpdateDisplayLink.preferredFramesPerSecond = 10;// 模拟器iPhone6崩溃
        [self.meterUpdateDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.meterUpdateDisplayLink.paused = YES;
    }
}

- (void)pauseUpdatingMeter {
    self.meterUpdateDisplayLink.paused = YES;
}

- (void)continueUpdatingMeter {
    self.meterUpdateDisplayLink.paused = NO;
}

- (void)stopUpdatingMeter {
    [self.meterUpdateDisplayLink invalidate];
    self.meterUpdateDisplayLink = nil;
}

- (void)updateMeters {
    if (self.player.duration <= 0.0) {
        // 播放器还未获取到音频信息
        return;
    }
    if (self.player.duration > 0.0) {
        self.playProgress = self.player.progress / self.player.duration;        
    }

    for (id<JAPlayerDelegate> delegate in _delegateArr) {
        if(delegate && [delegate respondsToSelector:@selector(audioPlayerDidCurrentTime:duration:)]){
            [delegate audioPlayerDidCurrentTime:self.player.progress duration:self.player.duration];
        }
    }
    
//    [self updateLockedScreenMusic];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag) {
        // 跳转音播放完成后，自动播放下一曲
        [self delayPlayNextVoice];
    }
}

#pragma mark - STKAudioPlayerDelegate

/// Raised when an item has started playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId {
//    [self contiuneUI];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
//    });
}
/// Raised when an item has finished buffering (may or may not be the currently playing item)
/// This event may be raised multiple times for the same item if seek is invoked on the player
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId {

}
/// Raised when the state of the player has changed
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState {
    
    if (state == STKAudioPlayerStateBuffering) {
        [self bufferingUI];
    } else if (state == STKAudioPlayerStatePaused) {
        [self pauseUI];
    } else if(state == STKAudioPlayerStatePlaying) {
        [self contiuneUI];
    } 
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
    });
}
/// Raised when an item has finished playing
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration {
    //根据实际情况播放完成可以将会话关闭，其他音频应用继续播放
//    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    if (stopReason == STKAudioPlayerStopReasonNone || stopReason == STKAudioPlayerStopReasonEof) {
        // -(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState方法，有时候音频播放完成后还会触发STKAudioPlayerStateBuffering状态。
        [self contiuneUI];
        [self playbackFinished];
    }
}
/// Raised when an unexpected and possibly unrecoverable error has occured (usually best to recreate the STKAudioPlauyer)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode {
    NSError *error = [[NSError alloc] initWithDomain:@"com.jasmine" code:errorCode userInfo:nil];
    for (id<JAPlayerDelegate> delegate in _delegateArr) {
        if (delegate && [delegate respondsToSelector:@selector(audioPlayerUnexpectedError:)]) {
            [delegate audioPlayerUnexpectedError:error];
        }
    }
    
    [self stopUpdatingMeter];
    self.player = nil;
    
    self.voiceModel.playState = 0;
//    self.voiceModel.isPlayingComment = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
    });
}
/// Optionally implemented to get logging information from the STKAudioPlayer (used internally for debugging)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer logInfo:(NSString*)line {
    
}
/// Raised when items queued items are cleared (usually because of a call to play, setDataSource or stop)
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didCancelQueuedItems:(NSArray*)queuedItems {
    
}

#pragma mark -
- (void)addDelegate:(id<JAPlayerDelegate>)delegate {
    if(delegate != nil){
        [_delegateArr addObject:delegate];
    }
}
    
- (void)removeDelegate:(id<JAPlayerDelegate>)delegate {
    if(_delegateArr.count){
        [_delegateArr removeObject:delegate];
    }
}

#pragma mark - Network
// 获取语音评论列表
// v2.4.0 评论和回复不在自动播放---v2.4.1又改回来了
// 获取语音评论列表
- (void)getVoiceCommentListWithTypeId:(NSString *)typeId
{
    if (self.isRequesting) {
        return;
    }
    // 开始请求
    self.isRequesting = YES;

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(1);
    dic[@"pageSize"] = @"6";
    dic[@"type"] = @"story";
    dic[@"typeId"] = typeId;
    dic[@"orderType"] = @"1";

    if (IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];

    [[JAVoiceCommentApi shareInstance] voice_commentListWithParas:dic success:^(NSDictionary *result) {
        self.isRequesting = NO;
        // 解析数据
        JAVoiceCommentGroupModel *groupModel = [JAVoiceCommentGroupModel mj_objectWithKeyValues:result[@"commentPageList"]];
        if (groupModel.result.count) {
            //            [self.commentVoices addObjectsFromArray:groupModel.result];

            [JAVoicePlayerManager shareInstance].commentVoices = [groupModel.result mutableCopy];
        }
    } failure:^(NSError *error) {
        self.isRequesting = NO;
    }];
}

#pragma mark - NSNotification
//-(void)listeningRemoteControl:(NSNotification *)sender{
//
//    NSDictionary *dict=sender.userInfo;
//    NSInteger order=[[dict objectForKey:@"order"] integerValue];
//    switch (order) {
//        case UIEventSubtypeRemoteControlPause:{
//            [self pause];
//            break;
//        }
//        case UIEventSubtypeRemoteControlPlay:{
//
//            [self contiunePlay];
//            break;
//        }
////        case UIEventSubtypeRemoteControlTogglePlayPause:{
////            [self handleInterreption:nil];
////            break;
////        }
//        case UIEventSubtypeRemoteControlNextTrack:{
//            [self removePlayNext];
//            break;
//        }
//        case UIEventSubtypeRemoteControlPreviousTrack:{
////            [self playPreviousMusic];
//            break;
//        }
//        default:
//            break;
//    }
//}
- (void)back_play {
    [self contiunePlay];
}

- (void)back_pause {
    [self pause];
}

- (void)back_next {
    [self removePlayNext];
}

- (void)back_headset {
    if (self.isPlaying) {
        [self pause];
    }else if(self.isPause){
        [self contiunePlay];
    }
}

- (void)removePlayNext {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(remoteDelayPlayNextVoice) object:nil];
    [self performSelector:@selector(remoteDelayPlayNextVoice) withObject:nil afterDelay:0.3 inModes:@[NSRunLoopCommonModes]];
}

- (void)remoteDelayPlayNextVoice {

    JAVoiceModel *voiceM = [JAVoicePlayerManager shareInstance].voiceModel;
    JAVoiceCommentModel *commentM = [JAVoicePlayerManager shareInstance].commentModel;
    JAVoiceReplyModel *replyM = [JAVoicePlayerManager shareInstance].replyModel;
    
    NSString *dataType = nil;
    NSString *category = nil;
    NSInteger playMethod;
    
    if (voiceM && voiceM.playState != 0) {
        
        dataType = JA_STORY_TYPE;
        category = voiceM.categoryId;
    }
    
    if (commentM && commentM.playState != 0) {
        dataType = JA_COMMENT_TYPE;
    }
    
    if (replyM && replyM.playState != 0) {
        dataType = JA_REPLY_TYPE;
    }
    if (dataType.length) {
        /// 统计跳过播放
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"dataType"] = dataType;
        dic[@"type"] = @"skip";
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        if (category.length) dic[@"categoryId"] = category;
        if (voiceM) {
            dic[@"typeId"] = voiceM.voiceId;
            [JASensorsAnalyticsManager sensorsAnalytics_endPlayVoiceModel:voiceM playDuration:(int)self.player.progress];
            [JASensorsAnalyticsManager sensorsAnalytics_skipPlayVoiceModel:voiceM method:0];
        } else if (commentM) {
            dic[@"typeId"] = commentM.voiceCommendId;
            
            [JASensorsAnalyticsManager sensorsAnalytics_endPlayCommentModel:commentM playDuration:(int)self.player.progress];
            [JASensorsAnalyticsManager sensorsAnalytics_skipPlayCommentModel:commentM method:0];
        } else if (replyM) {
            dic[@"typeId"] = replyM.voiceReplyId;
            
            [JASensorsAnalyticsManager sensorsAnalytics_endPlayReplyModel:replyM playDuration:(int)self.player.progress];
            [JASensorsAnalyticsManager sensorsAnalytics_skipPlayReplyModel:replyM method:0];
        }
//        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
        [self statisticalData:dic];
        
        // 播放时长
        int playTime = (int)self.player.progress;
        if (playTime > 0) {
            dic[@"type"] = @"play_time";
            dic[@"palyTime"] = @((int)self.player.progress);
            // v2.4.1新增参数status（0自动播放，1手动播放）
            dic[@"status"] = @(self.voiceModel.playMethod);
//            [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
            [self statisticalData:dic];
        }
    }
    
    [[JAVoicePlayerManager shareInstance] stop];
    [[JAVoicePlayerManager shareInstance] playbackFinished];
    
}

-(void)handleInterreption:(NSNotification *)sender
{
    AVAudioSessionInterruptionType type = [sender.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        if (self.isPlaying) {
            [self pause];
        }
    } else {
        if (self.isPause) {
            [self contiunePlay];
        }
    }
}

- (void)routeChange:(NSNotification *)notification
{
    NSDictionary *dic = notification.userInfo;
    int changeReason= [dic[AVAudioSessionRouteChangeReasonKey] intValue];
    
    //等于AVAudioSessionRouteChangeReasonOldDeviceUnavailable表示旧输出不可用
    if (changeReason == AVAudioSessionRouteChangeReasonOldDeviceUnavailable)
    {
        AVAudioSessionRouteDescription *routeDescription=dic[AVAudioSessionRouteChangePreviousRouteKey];
        AVAudioSessionPortDescription *portDescription= [routeDescription.outputs firstObject];
        //原设备为耳机则暂停
        if ([portDescription.portType isEqualToString:@"Headphones"])
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pause];
            });
        }
    }
}

#pragma mark - 锁屏时候的设置，效果需要在真机上才可以看到
- (void)updateLockedScreenMusic
{
    JAVoiceModel *voiceM = [JAVoicePlayerManager shareInstance].voiceModel;
    JAVoiceCommentModel *commentM = [JAVoicePlayerManager shareInstance].commentModel;
    JAVoiceReplyModel *replyM = [JAVoicePlayerManager shareInstance].replyModel;
    
    NSString *title = nil;
    NSString *artist = nil;
    BOOL isMainVoice = NO;
    if (voiceM) {
        title = voiceM.content;
        artist = voiceM.userName;
        isMainVoice = YES;
    }
    if (commentM) {
        title = commentM.content;
        artist = commentM.userName;
    }
    if (replyM) {
        title = replyM.content;
        artist = replyM.userName;
    }
  
    // 播放信息中心
    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    // 初始化播放信息
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    //    // 专辑名称
    //    info[MPMediaItemPropertyAlbumTitle] = ;
    if (title.length && artist.length) {
        // 歌曲名称
        info[MPMediaItemPropertyTitle] = isMainVoice?title:[NSString stringWithFormat:@"回复：%@",title];
        // 歌手
        info[MPMediaItemPropertyArtist] = artist;
    }
    // 设置图片
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"1024" ofType:@"png"];
    info[MPMediaItemPropertyArtwork] = [[MPMediaItemArtwork alloc] initWithImage:[UIImage imageWithContentsOfFile:filePath]];
    // 设置持续时间（歌曲的总时间）
    [info setObject:[NSNumber numberWithFloat:self.player.duration] forKey:MPMediaItemPropertyPlaybackDuration];
    // 设置当前播放进度
    [info setObject:[NSNumber numberWithFloat:self.player.progress] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    // 切换播放信息
    center.nowPlayingInfo = info;
}

// 后台统计数据的网络请求
- (void)statisticalData:(NSMutableDictionary *)dic
{
    if (self.playEnterType == 0) {
        [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
    }
}

//- (void)setVoices:(NSMutableArray *)voices
//{
//    _voices = [voices mutableCopy];
//}
//
//- (void)setCommentVoices:(NSMutableArray *)commentVoices
//{
//    _commentVoices = [commentVoices mutableCopy];
//}
//
//- (void)setReplyVoices:(NSMutableArray *)replyVoices
//{
//    _replyVoices = [replyVoices mutableCopy];
//}

@end
