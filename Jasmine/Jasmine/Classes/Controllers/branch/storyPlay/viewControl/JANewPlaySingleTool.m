//
//  JANewPlaySingleTool.m
//  Jasmine
//
//  Created by 刘宏亮 on 2018/6/1.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPlaySingleTool.h"
#import "STKAudioPlayer.h"
#import "JANewPlayTool.h"
#import "JAVoiceCommonApi.h"

@interface JANewPlaySingleTool () <STKAudioPlayerDelegate>
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign, readwrite) NSInteger playType;   // 0未播放 1 播放 2 缓冲中...
@property (nonatomic, assign, readwrite) JANewPlaySingleToolType musicType;

@property (nonatomic, strong, readwrite) JANewCommentModel *currentMusic_comment;
@property (nonatomic, strong, readwrite) JANewReplyModel *currentMusic_reply;
@property (nonatomic, strong, readwrite) JANotiModel *currentMusic_noti;
@property (nonatomic, strong, readwrite) NSString *currentMusic_local;

@property (nonatomic, strong) NSString *currentMusicPath;  // 当前播放的地址

@property (nonatomic, strong) STKAudioPlayer *player;  // 播放器
@end

@implementation JANewPlaySingleTool

+ (instancetype)shareNewPlaySingleTool
{
    static JANewPlaySingleTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JANewPlaySingleTool alloc] init];
            [instance initialPlayer];
            
            // 中断处理
            [[NSNotificationCenter defaultCenter] addObserver:instance
                                                     selector:@selector(handleInterreption:)
                                                         name:AVAudioSessionInterruptionNotification
                                                       object:[AVAudioSession sharedInstance]];
        }
    });
    return instance;
}

// 初始化播放器
- (void)initialPlayer
{
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionAllowBluetooth error:nil];
    [session setActive:YES error:nil];
    
    if (self.player == nil) {
        self.player = [[STKAudioPlayer alloc] init];
        self.player.volume = 1;
        self.player.delegate = self;
        [self startUpdatingMeter];
    }
}
#pragma mark - 中断处理
-(void)handleInterreption:(NSNotification *)sender
{
    AVAudioSessionInterruptionType type = [sender.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self playSingleTool_pause];
    }
}

#pragma mark - 定时器
- (void)startUpdatingMeter {
    if (!self.displayLink) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateMeters)];
        self.displayLink.frameInterval = 6;// 每秒调用10次（60/frameInterval）
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        self.displayLink.paused = YES;
    }
}

- (void)updateMeters
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_process" object:nil];
}

// 暂停定时器
- (void)pauseUpdatingMeter {
    self.displayLink.paused = YES;
}

// 继续定时器
- (void)continueUpdatingMeter {
    self.displayLink.paused = NO;
}

// 废弃定时器
- (void)dealloc {
    [self.displayLink invalidate];
    self.displayLink = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 获取音频时长
// 获取播放音频的总时间
- (NSTimeInterval)totalDuration
{
    return self.player.duration;
}
// 获取播放音频的当前时间
- (NSTimeInterval)currentDuration
{
    return self.player.progress;
}

/* --------------------------------------------- 播放单曲 ---------------------------------------- */
/// 内部播放方法
- (void)playTool_playWithUrlString:(NSString *)urlString
{
    [self.player dispose];
    self.player = nil;
    [self initialPlayer];
    if (self.musicType == JANewPlaySingleToolType_local) {
        [self.player playURL:[NSURL fileURLWithPath:urlString]];
    }else{
        [self.player playURL:[NSURL URLWithString:urlString]];
    }
}
/// 播放
- (void)playSingleTool_playSingleMusicWithFileUrlString:(NSString *)file model:(id)model playType:(JANewPlaySingleToolType)type
{
    /*-------------------------------------- 播放统计 ---------------------------------*/
    if (self.musicType == JANewPlaySingleToolType_comment) {
        [self playTongJi_commentSkipWithModel:self.currentMusic_comment];
        [self playTongJi_commentPlayTimeWithModel:self.currentMusic_comment playMethod:1];
    }else if (self.musicType == JANewPlaySingleToolType_reply){
        [self playTongJi_replySkipWithModel:self.currentMusic_reply];
        [self playTongJi_replyPlayTimeWithModel:self.currentMusic_reply playMethod:1];
    }
    // 神策统计
    [self sensorsAnalytics_stopWithType:self.musicType];
    /*-------------------------------------- 播放统计 ---------------------------------*/
    
    self.musicType = type;
    
    switch (type) {
        case JANewPlaySingleToolType_comment:
            self.currentMusic_comment = model;
            break;
        case JANewPlaySingleToolType_reply:
            self.currentMusic_reply = model;
            break;
        case JANewPlaySingleToolType_noti:
            self.currentMusic_noti = model;
            break;
        case JANewPlaySingleToolType_local:
            self.currentMusic_local = file;
            break;
            
        default:
            break;
    }
    
    if ([self.currentMusicPath isEqualToString:file]) { // 同一条
        [self initialPlayer];
        if (self.player.state == STKAudioPlayerStatePaused) { // 暂停状态
            [self playSingleTool_resume];  // 继续
        }else if (self.player.state == STKAudioPlayerStatePlaying){
            [self playSingleTool_pause];
        }else if (self.player.state == STKAudioPlayerStateBuffering){
            [self playSingleTool_pause];
        }else{
            [self playTool_playWithUrlString:file];
        }
    }else{
        self.currentMusicPath = file;
        [self playTool_playWithUrlString:file];
        
        /*-------------------------------------- 播放统计 ---------------------------------*/
        if (self.musicType == JANewPlaySingleToolType_comment) {
            [self playTongJi_commentPlayWithModel:self.currentMusic_comment];
        }else if (self.musicType == JANewPlaySingleToolType_reply){
            [self playTongJi_replyPlayWithModel:self.currentMusic_reply];
        }
        // 神策统计
        [self sensorsAnalytics_startWithType:self.musicType];
        /*-------------------------------------- 播放统计 ---------------------------------*/
    }
}

/// 暂停
- (void)playSingleTool_pause
{
    [self.player pause];
    [self pauseUpdatingMeter];
}

/// 继续
- (void)playSingleTool_resume
{
    [self.player resume];
    [self continueUpdatingMeter];
}

/* --------------------------------------------- 播放单曲 ---------------------------------------- */

#pragma mark - 播放器代理
/// 开始播放
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [self continueUpdatingMeter];
}

/// 完成加载
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId
{
    [self continueUpdatingMeter]; // 继续定时器
}
/// 播放状态改变
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    if (state == STKAudioPlayerStateBuffering) {
        self.playType = 3;
        [self pauseUpdatingMeter]; // 停止定时器
    } else if (state == STKAudioPlayerStatePlaying) {
        [[JANewPlayTool shareNewPlayTool] playTool_pause];
        self.playType = 1;
        [self continueUpdatingMeter]; // 继续定时器
    } else if (state == STKAudioPlayerStatePaused) {
        self.playType = 2;
        [self pauseUpdatingMeter]; // 继续定时器
    } else {
        self.playType = 0;
        [self pauseUpdatingMeter]; // 停止定时器
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_statusChange" object:nil];
}
/// 播放结束  // stopReason 结束原因
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_finish" object:nil];
    // 暂停定时器
    [self pauseUpdatingMeter];
    
    if (stopReason == STKAudioPlayerStopReasonNone || stopReason == STKAudioPlayerStopReasonEof) {
        
        /*-------------------------------------- 播放统计 ---------------------------------*/
        if (self.musicType == JANewPlaySingleToolType_comment) {
            [self playTongJi_commentSkipWithModel:self.currentMusic_comment];
            [self playTongJi_commentPlayTimeWithModel:self.currentMusic_comment playMethod:1];
        }else if (self.musicType == JANewPlaySingleToolType_reply){
            [self playTongJi_replySkipWithModel:self.currentMusic_reply];
            [self playTongJi_replyPlayTimeWithModel:self.currentMusic_reply playMethod:1];
        }
        /*-------------------------------------- 播放统计 ---------------------------------*/
    }
}
/// 发生错误
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayerSingle_finish" object:nil];
    // 暂停定时器
    [self pauseUpdatingMeter];
}

#pragma mark - 播放统计
// 评论播放统计
- (void)playTongJi_commentPlayWithModel:(JANewCommentModel *)model
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_COMMENT_TYPE;
    dic[@"type"] = @"play";
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.commentId;
    [self statisticalData:dic];
    
}

// 回复播放统计
- (void)playTongJi_replyPlayWithModel:(JANewReplyModel *)model
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_REPLY_TYPE;
    dic[@"type"] = @"play";
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.replyId;
    [self statisticalData:dic];
    
}

// 评论播放时长统计
- (void)playTongJi_commentPlayTimeWithModel:(JANewCommentModel *)model playMethod:(NSInteger)playMethod
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_COMMENT_TYPE;
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.commentId;
    
    dic[@"type"] = @"play_time";
    dic[@"palyTime"] = [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration ? @([JANewPlaySingleTool shareNewPlaySingleTool].currentDuration) : @([NSString getSeconds:model.time]);
    dic[@"status"] = @(playMethod);
    [self statisticalData:dic];
}

// 回复播放时长统计
- (void)playTongJi_replyPlayTimeWithModel:(JANewReplyModel *)model playMethod:(NSInteger)playMethod
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_REPLY_TYPE;
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.replyId;
    
    dic[@"type"] = @"play_time";
    dic[@"palyTime"] = [JANewPlaySingleTool shareNewPlaySingleTool].totalDuration ? @([JANewPlaySingleTool shareNewPlaySingleTool].currentDuration) : @([NSString getSeconds:model.time]);
    dic[@"status"] = @(playMethod);
    [self statisticalData:dic];
}

// 评论跳过统计
- (void)playTongJi_commentSkipWithModel:(JANewCommentModel *)model
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_COMMENT_TYPE;
    dic[@"type"] = @"skip";
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.commentId;
    [self statisticalData:dic];
}

// 回复跳过统计
- (void)playTongJi_replySkipWithModel:(JANewReplyModel *)model
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_REPLY_TYPE;
    dic[@"type"] = @"skip";
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.replyId;
    [self statisticalData:dic];
}

- (void)statisticalData:(NSMutableDictionary *)dic
{
    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
}


// 开始播放神策统计
- (void)sensorsAnalytics_startWithType:(JANewPlaySingleToolType)type
{
    if (type == JANewPlaySingleToolType_comment) {
        NSMutableDictionary *eventParams = [NSMutableDictionary new];
        eventParams[JA_Property_ContentId] = self.currentMusic_comment.commentId;
        eventParams[JA_Property_ContentTitle] = self.currentMusic_comment.content;
        eventParams[JA_Property_ContentType] = @"一级回复";
        eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:self.currentMusic_comment.time]);
        eventParams[JA_Property_Anonymous] = @(self.currentMusic_comment.user.isAnonymous);
        eventParams[JA_Property_PostId] = self.currentMusic_comment.user.userId;
        eventParams[JA_Property_PostName] = self.currentMusic_comment.user.userName;
        eventParams[JA_Property_PlayMethod] = @"主动播放";
        eventParams[JA_Property_SourcePage] = self.currentMusic_comment.sourcePage;
        eventParams[JA_Property_SourcePageName] = self.currentMusic_comment.sourcePageName;
        [JASensorsAnalyticsManager sensorsAnalytics_startPlay:eventParams];
    }else if (type == JANewPlaySingleToolType_reply){
        
        NSMutableDictionary *eventParams = [NSMutableDictionary new];
        eventParams[JA_Property_ContentId] = self.currentMusic_reply.replyId;
        eventParams[JA_Property_ContentTitle] = self.currentMusic_reply.content;
        eventParams[JA_Property_ContentType] = @"二级回复";
        eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:self.currentMusic_reply.time]);
        eventParams[JA_Property_Anonymous] = @(self.currentMusic_reply.user.isAnonymous);
        eventParams[JA_Property_PostId] = self.currentMusic_reply.user.userId;
        eventParams[JA_Property_PostName] = self.currentMusic_reply.user.userName;
        eventParams[JA_Property_PlayMethod] = @"主动播放";
        eventParams[JA_Property_SourcePage] = self.currentMusic_reply.sourcePage;
        eventParams[JA_Property_SourcePageName] = self.currentMusic_reply.sourcePageName;
        [JASensorsAnalyticsManager sensorsAnalytics_startPlay:eventParams];
    }
}

// 结束播放神策统计
- (void)sensorsAnalytics_stopWithType:(JANewPlaySingleToolType)type
{
    if (type == JANewPlaySingleToolType_comment) {
        NSMutableDictionary *eventParams = [NSMutableDictionary new];
        eventParams[JA_Property_ContentId] = self.currentMusic_comment.commentId;
        eventParams[JA_Property_ContentTitle] = self.currentMusic_comment.content;
        eventParams[JA_Property_ContentType] = @"一级回复";
        eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:self.currentMusic_comment.time]);
        eventParams[JA_Property_Anonymous] = @(self.currentMusic_comment.user.isAnonymous);
        eventParams[JA_Property_PostId] = self.currentMusic_comment.user.userId;
        eventParams[JA_Property_PostName] = self.currentMusic_comment.user.userName;
        if (self.currentDuration < 0) {
            // 播放完成
            eventParams[JA_Property_PlayDuration] = eventParams[JA_Property_RecordDuration];
            eventParams[JA_Property_PlayAll] = @(YES);
        } else {
            eventParams[JA_Property_PlayDuration] = @(self.currentDuration);
            eventParams[JA_Property_PlayAll] = @(NO);
        }
        eventParams[JA_Property_SourcePage] = self.currentMusic_comment.sourcePage;
        eventParams[JA_Property_SourcePageName] = self.currentMusic_comment.sourcePageName;
        eventParams[JA_Property_PlayMethod] = @"主动播放";
        
        [JASensorsAnalyticsManager sensorsAnalytics_stopPlay:eventParams];
    }else if (type == JANewPlaySingleToolType_reply){
        NSMutableDictionary *eventParams = [NSMutableDictionary new];
        eventParams[JA_Property_ContentId] = self.currentMusic_reply.replyId;
        eventParams[JA_Property_ContentTitle] = self.currentMusic_reply.content;
        eventParams[JA_Property_ContentType] = @"二级回复";
        eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:self.currentMusic_reply.time]);
        eventParams[JA_Property_Anonymous] = @(self.currentMusic_reply.user.isAnonymous);
        eventParams[JA_Property_PostId] = self.currentMusic_reply.user.userId;
        eventParams[JA_Property_PostName] = self.currentMusic_reply.user.userName;
        if (self.currentDuration < 0) {
            // 播放完成
            eventParams[JA_Property_PlayDuration] = eventParams[JA_Property_RecordDuration];
            eventParams[JA_Property_PlayAll] = @(YES);
        } else {
            eventParams[JA_Property_PlayDuration] = @(self.currentDuration);
            eventParams[JA_Property_PlayAll] = @(NO);
        }
        eventParams[JA_Property_SourcePage] = self.currentMusic_reply.sourcePage;
        eventParams[JA_Property_SourcePageName] = self.currentMusic_reply.sourcePageName;
        eventParams[JA_Property_PlayMethod] = @"主动播放";
        [JASensorsAnalyticsManager sensorsAnalytics_stopPlay:eventParams];
    }
    
}
@end
