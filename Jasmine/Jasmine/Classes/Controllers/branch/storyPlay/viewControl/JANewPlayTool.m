//
//  JANewPlayTool.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/22.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPlayTool.h"
#import "STKAudioPlayer.h"

#import "JAAlbumNetRequest.h"
#import "JANewPlaySingleTool.h"
#import "JAMusicListModel.h"

#import "JAVoiceCommonApi.h"

#define kSwitch_new 1

@interface JANewPlayTool () <STKAudioPlayerDelegate>

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign, readwrite) NSInteger playType;   // 0未播放 1 播放 2 缓冲中...
@property (nonatomic, assign, readwrite) NSInteger currentIndex;
@property (nonatomic, strong, readwrite) JANewVoiceModel *currentMusic;
/// 上次的进入方式
@property (nonatomic, assign, readwrite) NSInteger enterType;
/// 当前音乐播放时间 （相当于进度）
@property (nonatomic, assign, readwrite) NSTimeInterval currentDuration;
/// 当前音乐总时长
@property (nonatomic, assign, readwrite) NSTimeInterval totalDuration;

/// 上次的播放顺序
@property (nonatomic, assign, readwrite) BOOL playOrder_zheng;  // 默认YES

@property (nonatomic, strong) STKAudioPlayer *player;  // 播放器

/// 播放列表 (开始播放之前必须初始化播放列表)
@property (nonatomic, strong, readwrite) NSMutableArray *musicList;

// ------- 专辑播放加载数据时用字段 ----------
@property (nonatomic, strong, readwrite) NSDictionary *albumDic; // 拉取数据的参数
// 是否加载完成
@property (nonatomic, assign) BOOL isLoad;
@property (nonatomic, assign) BOOL isRequest;
@property (nonatomic, assign) NSInteger currentPage;  // 下次加载更多的页码
@property (nonatomic, assign) NSInteger orderType;  // 请求数据的排序
@property (nonatomic, strong) NSString *subjectId;  // 专辑id
@end

@implementation JANewPlayTool

+ (instancetype)shareNewPlayTool
{
    static JANewPlayTool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JANewPlayTool alloc] init];
            instance.playOrder_zheng = YES;
            instance.musicList = [NSMutableArray array];
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

#pragma mark - 中断处理
-(void)handleInterreption:(NSNotification *)sender
{
    AVAudioSessionInterruptionType type = [sender.userInfo[AVAudioSessionInterruptionTypeKey] intValue];
    if (type == AVAudioSessionInterruptionTypeBegan) {
        [self playTool_pause];
    }
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

#pragma mark - 网络请求（专辑专用）
- (void)request_getMoreAlbumStory
{
    if (self.isRequest) {
        return;
    }
    if (self.isLoad) {
        return;
    }
    
    self.isRequest = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    dic[@"orderType"] = @(self.orderType);
    JAAlbumNetRequest *r = [[JAAlbumNetRequest alloc] initRequest_albumStoryListWithParameter:dic subjectId:self.subjectId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequest = NO;
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.code != 10000) {
            return;
        }
        
        // 添加数据
        [self.musicList addObjectsFromArray:model.resBody];
        
        
        if (self.musicList.count >= model.total || model.resBody.count < 6) {
            self.isLoad = YES;
        }else{
            self.isLoad = NO;
            self.currentPage += 1;
        }
        
        // 数据源变化通知外面刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isLoad = YES;
        self.isRequest = NO;
    }];
}

#pragma mark - 新版逻辑专辑网络请求（专辑专用）(根据播放顺序拉取数据)
- (void)request_getMoreAlbumMusicWithOrder
{
    if (self.isRequest) {
        // 数据源变化通知外面刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
        return;
    }
    if (self.isLoad) {
        // 数据源变化通知外面刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
        return;
    }
    
    self.isRequest = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    dic[@"orderType"] = @(self.orderType);
    JAAlbumNetRequest *r = [[JAAlbumNetRequest alloc] initRequest_albumStoryListWithParameter:dic subjectId:self.subjectId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequest = NO;
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.code != 10000) {
            // 数据源变化通知外面刷新列表
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
            return;
        }
        
        if (!model.resBody.count) {
            self.isLoad = YES;
            // 数据源变化通知外面刷新列表
            [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
            return;
        }
        
        if (self.playOrder_zheng) {
            // 添加数据
            [self.musicList addObjectsFromArray:model.resBody];
        }else{
            NSArray *arr = [[model.resBody reverseObjectEnumerator] allObjects];
            // 要插入的位置
            NSIndexSet *helpIndex = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [arr count])];
            [self.musicList insertObjects:arr atIndexes:helpIndex];
        }
        
        // 获取当前的index
        self.currentIndex = [self.musicList indexOfObject:self.currentMusic];
        
        if (self.musicList.count >= model.total || model.resBody.count < 6) {
            self.isLoad = YES;
        }else{
            self.isLoad = NO;
            self.currentPage += 1;
        }
        
        // 数据源变化通知外面刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isLoad = YES;
        self.isRequest = NO;
        // 数据源变化通知外面刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listupdate" object:nil];
    }];
}

#pragma mark - 外部调用播放
/// 开始播放
- (void)playTool_playWithModel:(JANewVoiceModel *)model
                     storyList:(NSArray *)storyListArray
                     enterType:(NSInteger)type
                albumParameter:(NSDictionary *)albumParameter
{
    if (!model.audioUrl.length) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"播放帖子异常"];
        return;
    }
    
    // 过滤图文贴
    NSArray *storys = [storyListArray mutableCopy];
    
    NSMutableArray *listArray = [NSMutableArray array];
    
    [storys enumerateObjectsUsingBlock:^(JANewVoiceModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        /*
         筛选音频帖
         */
        if (obj.audioUrl.length) {
            [listArray addObject:obj];
        }
        
    }];
    
    
    // 创建播放列表数据
    [self.musicList removeAllObjects];
    [self.musicList addObjectsFromArray:listArray];
    
    
    // 获取当前要播放的帖子在列表中的索引
    [self.musicList enumerateObjectsUsingBlock:^(JANewVoiceModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.storyId isEqualToString:obj.storyId]) {
            self.currentIndex = idx;
            *stop = YES;
        }else{
            self.currentIndex = -1;
        }
    }];
    
    if (self.currentIndex < 0) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"播放帖子异常"];
        return;
    }
    
    self.albumDic = albumParameter;
    self.enterType = type;
    self.isLoad = NO;
    if (kSwitch_new) {
        self.playOrder_zheng = YES;  // 新版逻辑（每次切换的时候要切换到常规的正序）
    }
    [self playTool_playWithMusics:self.musicList index:self.currentIndex];
}

/* --------------------------------------------- 播放帖子（循环列表）---------------------------------------- */
/// 内部 - 播放方法
- (void)playTool_playWithUrlString:(NSString *)urlString
{
    [self.player dispose];
    self.player = nil;
    [self initialPlayer];
    if (self.enterType == 4) {
        [self.player playURL:[NSURL fileURLWithPath:urlString]];
    }else{
        [self.player playURL:[NSURL URLWithString:urlString]];
    }
}

/// 内部 - 自动调用下一首 (为了区分自动手动，单独写了这个内部方法)
- (void)playTool_playNextSelfMotion
{
    if (kSwitch_new) {  // 新版逻辑
        if (self.currentIndex < 0) {
            return;
        }
        
        if (_player == nil) {
            return;
        }
        
        /*------------------------------------- 播放统计 ----------------------------------------*/
        [self playTongJi_skipWithModel:self.currentMusic];
        [self playTongJi_playTimeWithModel:self.currentMusic playMethod:0];  // 0 自动  1 手动
        // 神策统计 - 结束
        [self sensorsAnalytics_stop:0];
        /*------------------------------------- 播放统计 ----------------------------------------*/
        
        if (self.currentIndex >= self.musicList.count - 1) {  // 播放完成
            [self playTool_stop];
            
        }else{  // 开始播放下一曲
            
            self.currentIndex += 1;
            self.currentMusic = self.musicList[self.currentIndex];
            [self playTool_playWithUrlString:self.currentMusic.audioUrl];
            
            // 拉取数据
            [self neiBuFunc_getAlbumMusicListWithOrderSelfMotion];
            
            /*------------------------------------- 播放统计 ----------------------------------------*/
            [self playTongJi_playWithModel:self.currentMusic];
            // 神策统计 - 开始
            [self sensorsAnalytics_start:0];
            /*------------------------------------- 播放统计 ----------------------------------------*/
        }
    }else{
        if (self.currentIndex < 0) {
            return;
        }
        if (self.playOrder_zheng) {
            
            if (_player == nil) {
                return;
            }
            
            /*------------------------------------- 播放统计 ----------------------------------------*/
            [self playTongJi_skipWithModel:self.currentMusic];
            [self playTongJi_playTimeWithModel:self.currentMusic playMethod:0];  // 0 自动  1 手动
            /*------------------------------------- 播放统计 ----------------------------------------*/
            
            if (self.currentIndex >= self.musicList.count - 1) {  // 播放完成
                [self playTool_stop];
                
            }else{  // 开始播放下一曲
                
                self.currentIndex += 1;
                self.currentMusic = self.musicList[self.currentIndex];
                [self playTool_playWithUrlString:self.currentMusic.audioUrl];
                
                // 拉取数据
                [self neiBuFunc_getMoreAlbumStorySelfMotion];
                
                /*------------------------------------- 播放统计 ----------------------------------------*/
                [self playTongJi_playWithModel:self.currentMusic];
                /*------------------------------------- 播放统计 ----------------------------------------*/
            }
        }else{
            
            if (_player == nil) {
                return;
            }
            
            /*------------------------------------- 播放统计 ----------------------------------------*/
            [self playTongJi_skipWithModel:self.currentMusic];
            [self playTongJi_playTimeWithModel:self.currentMusic playMethod:0];  // 0 自动  1 手动
            /*------------------------------------- 播放统计 ----------------------------------------*/
            
            if (self.currentIndex <= 0) {  // 播放完成
                [self playTool_stop];
                
            }else{  // 开始播放下一曲
                self.currentIndex -= 1;
                self.currentMusic = self.musicList[self.currentIndex];
                [self playTool_playWithUrlString:self.currentMusic.audioUrl];
                
                /*------------------------------------- 播放统计 ----------------------------------------*/
                [self playTongJi_playWithModel:self.currentMusic];
                /*------------------------------------- 播放统计 ----------------------------------------*/
            }
        }
    }
}

/// 内部方法 - 自动去拉取album专辑帖子列表
- (void)neiBuFunc_getMoreAlbumStorySelfMotion
{
    if (self.enterType != 3) {
        return;
    }
    if (self.currentIndex >= (self.musicList.count - 3)) {
        [self request_getMoreAlbumStory];
    }
}

/// 内部方法 - 新逻辑自动去拉取album专辑帖子列表
- (void)neiBuFunc_getAlbumMusicListWithOrderSelfMotion
{
    if (self.enterType != 3) {
        return;
    }
    if (self.playOrder_zheng) {
        if (self.currentIndex >= (self.musicList.count - 3)) {
            [self request_getMoreAlbumMusicWithOrder];
        }
    }else{
        if (self.currentIndex <= (3)) {
            [self request_getMoreAlbumMusicWithOrder];
        }
    }
}

/// 停止播放
- (void)playTool_stop
{
    [self.player dispose];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_finish" object:nil];
    
}

/// 重置播放器
- (void)playTool_resetPlayTool
{
    [self.player dispose];
    self.player = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_finish" object:nil];
    self.currentIndex = -1;
    self.currentMusic = nil;
    self.enterType = 0;
    self.playType = 0;
    [self.musicList removeAllObjects];
    self.currentDuration = 0;
    self.albumDic = nil;
}

/// 继续播放
- (void)playTool_continue
{
    [self.player resume];
    [self continueUpdatingMeter];
}

/// 暂停播放
- (void)playTool_pause
{
    [self.player pause];
    [self pauseUpdatingMeter];
}

/// 播放下一曲
- (void)playTool_playNextMusic
{
    if (kSwitch_new) {  // 新版逻辑
        if (self.currentIndex < 0) {
            return;
        }
        [self playTool_playNext];
    }else{
        if (self.currentIndex < 0) {
            return;
        }
        if (self.playOrder_zheng) {
            [self playTool_playNext];
        }else{
            [self playTool_playFront];
        }
    }
}

// 播放上一曲
- (void)playTool_playFrontMusic
{
    if (kSwitch_new) {  // 新版逻辑
        if (self.currentIndex < 0) {
            return;
        }
        [self playTool_playFront];
    }else{
        if (self.currentIndex < 0) {
            return;
        }
        if (self.playOrder_zheng) {
            [self playTool_playFront];
        }else{
            [self playTool_playNext];
        }
    }
}

// 播放下一曲
- (void)playTool_playNext
{
    if (_player == nil) {
        return;
    }
    
    /*------------------------------------- 播放统计 ----------------------------------------*/
    [self playTongJi_skipWithModel:self.currentMusic];
    [self playTongJi_playTimeWithModel:self.currentMusic playMethod:1];  // 0 自动  1 手动
    // 神策统计 - 开始
    [self sensorsAnalytics_stop:1];
    /*------------------------------------- 播放统计 ----------------------------------------*/
    
    if (self.currentIndex >= self.musicList.count - 1) {  // 播放完成
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"没有更多了"];
//        [self playTool_stop];
        
    }else{  // 开始播放下一曲
        
        self.currentIndex += 1;
        self.currentMusic = self.musicList[self.currentIndex];
        [self playTool_playWithUrlString:self.currentMusic.audioUrl];
        
        if (kSwitch_new) {  // 新版逻辑
            // 拉取数据
            [self neiBuFunc_getAlbumMusicListWithOrderSelfMotion];
        }else{
            // 拉取数据
            [self neiBuFunc_getMoreAlbumStorySelfMotion];
        }
        
        /*------------------------------------- 播放统计 ----------------------------------------*/
        [self playTongJi_playWithModel:self.currentMusic];
        // 神策统计 - 开始
        [self sensorsAnalytics_start:1];
        /*------------------------------------- 播放统计 ----------------------------------------*/
    }
    
}

// 播放上一曲
- (void)playTool_playFront
{
    if (_player == nil) {
        return;
    }
    
    /*------------------------------------- 播放统计 ----------------------------------------*/
    [self playTongJi_skipWithModel:self.currentMusic];
    [self playTongJi_playTimeWithModel:self.currentMusic playMethod:1];  // 0 自动  1 手动
    // 神策统计 - 开始
    [self sensorsAnalytics_stop:1];
    /*------------------------------------- 播放统计 ----------------------------------------*/
    
    if (self.currentIndex <= 0) {  // 播放完成
//        [self playTool_stop];
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"没有更多了"];
        
    }else{  // 开始播放上一曲
        
        self.currentIndex -= 1;
        self.currentMusic = self.musicList[self.currentIndex];
        [self playTool_playWithUrlString:self.currentMusic.audioUrl];
        
        if (kSwitch_new) {  // 新版逻辑
            // 拉取数据
            [self neiBuFunc_getAlbumMusicListWithOrderSelfMotion];
        }
        /*------------------------------------- 播放统计 ----------------------------------------*/
        [self playTongJi_playWithModel:self.currentMusic];
        // 神策统计 - 开始
        [self sensorsAnalytics_start:1];
        /*------------------------------------- 播放统计 ----------------------------------------*/
    }
    
}


/// 播放指定歌曲
- (void)playTool_playWithMusics:(NSArray *)musicList index:(NSInteger)index
{
    if (index < 0 || index >= musicList.count) {
        return;
    }
    // 判断是不是同一条
    JANewVoiceModel *newModel = musicList[index];
    if ([self.currentMusic.storyId isEqualToString:newModel.storyId]) {
        
        [self initialPlayer];
        // 判断播放器的状态
        if (self.player.state == STKAudioPlayerStatePaused) { // 暂停状态
            [self playTool_continue];  // 继续
        }else if (self.player.state == STKAudioPlayerStatePlaying){
            [self playTool_pause];
        }else if (self.player.state == STKAudioPlayerStateBuffering){
            [self playTool_pause];
        }else{
            self.currentMusic = self.musicList[self.currentIndex];
            [self playTool_playWithUrlString:self.currentMusic.audioUrl];
            
            /*------------------------------------- 播放统计 ----------------------------------------*/
            [self playTongJi_playWithModel:self.currentMusic];
            /*------------------------------------- 播放统计 ----------------------------------------*/
        }
        
    }else{
        
        /*------------------------------------- 播放统计 ----------------------------------------*/
        [self playTongJi_skipWithModel:self.currentMusic];
        [self playTongJi_playTimeWithModel:self.currentMusic playMethod:1];  // 0 自动  1 手动
        
        // 神策统计 - 结束
        [self sensorsAnalytics_stop:1];
        /*------------------------------------- 播放统计 ----------------------------------------*/
        
        [self playTool_stop];
        [self initialPlayer];
        
        self.currentIndex = index;
        self.currentMusic = self.musicList[self.currentIndex];
        [self playTool_playWithUrlString:self.currentMusic.audioUrl];
        
        /*------------------------------------- 播放统计 ----------------------------------------*/
        [self playTongJi_playWithModel:self.currentMusic];
        
        // 神策统计 - 开始
        [self sensorsAnalytics_start:1];
        /*------------------------------------- 播放统计 ----------------------------------------*/
        
        if (kSwitch_new) {  // 新版逻辑
            // 拉取数据
            [self neiBuFunc_getAlbumMusicListWithOrderSelfMotion];
        }else{
            // 拉取数据
            [self neiBuFunc_getMoreAlbumStorySelfMotion];
        }
    }
}

/// 快进
- (void)playTool_seetValue:(double)value
{
    [self.player seekToTime:value];
}

/// 切换播放顺序
- (void)playTool_playSortWithOrder:(BOOL)isZheng
{
    [[UIApplication sharedApplication].delegate.window ja_makeToast:!isZheng ? @"倒序播放" : @"顺序播放"];
    self.playOrder_zheng = isZheng;
    if (kSwitch_new) { // 新版逻辑
        NSArray *arr = [[self.musicList reverseObjectEnumerator] allObjects];
        [self.musicList removeAllObjects];
        [self.musicList addObjectsFromArray:arr];
        // 获取当前音乐的index
        self.currentIndex = [self.musicList indexOfObject:self.currentMusic];
        // 数据源变化通知外面刷新列表
        [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_listOrderupdate" object:nil];
    }
}

/// 根据播放顺序拉取专辑帖子
- (void)playTool_getAlbumMusicListWithSort
{
    [self request_getMoreAlbumMusicWithOrder];
}
/* --------------------------------------------- 播放帖子（循环列表）---------------------------------------- */

#pragma mark - 开启定时器
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
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_process" object:nil];
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

#pragma mark - 获取时长
// 获取播放音频的总时间
- (NSTimeInterval)totalDuration
{
    if (self.player.duration <= 0) {
        return [NSString getSeconds:self.currentMusic.time];
    }else{
        return self.player.duration;
    }
    
}
// 获取播放音频的当前时间
- (NSTimeInterval)currentDuration
{
    return self.player.progress;
}

#pragma mark - 播放器代理
/// 开始播放
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didStartPlayingQueueItemId:(NSObject*)queueItemId
{
    [self continueUpdatingMeter];
}

/// 完成加载
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishBufferingSourceWithQueueItemId:(NSObject*)queueItemId{}
/// 播放状态改变
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer stateChanged:(STKAudioPlayerState)state previousState:(STKAudioPlayerState)previousState
{
    if (state == STKAudioPlayerStateBuffering) {
        self.playType = 3;
        [self pauseUpdatingMeter]; // 停止定时器
    } else if (state == STKAudioPlayerStatePlaying) {
        [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];
        self.playType = 1;
        [self continueUpdatingMeter]; // 继续定时器
    } else if (state == STKAudioPlayerStatePaused) {
        self.playType = 2;
        [self pauseUpdatingMeter]; // 继续定时器
    } else {
        self.playType = 0;
        [self pauseUpdatingMeter]; // 停止定时器
    }
    [[AppDelegate sharedInstance].playerView playerView_animateAndHidden];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_status" object:nil];
}
/// 播放结束  // stopReason 结束原因
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer didFinishPlayingQueueItemId:(NSObject*)queueItemId withReason:(STKAudioPlayerStopReason)stopReason andProgress:(double)progress andDuration:(double)duration
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_finish" object:nil];
    
    // 暂停定时器
    [self pauseUpdatingMeter];
    
    if (stopReason == STKAudioPlayerStopReasonNone || stopReason == STKAudioPlayerStopReasonEof) {
        // 开始下一曲
        [self playTool_playNextSelfMotion];
    }
}
/// 发生错误
-(void) audioPlayer:(STKAudioPlayer*)audioPlayer unexpectedError:(STKAudioPlayerErrorCode)errorCode
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"STKAudioPlayer_finish" object:nil];
    [self pauseUpdatingMeter]; // 暂停定时器
}

- (void)setAlbumDic:(NSDictionary *)albumDic
{
    _albumDic = albumDic;
    self.currentPage = [albumDic[@"currentPage"] integerValue];
    self.orderType = [albumDic[@"orderType"] integerValue];
    self.subjectId = albumDic[@"subjectId"];
}


// 读取缓存数据
- (void)playTool_readCachMusicListWithModel:(JAMusicListModel *)model
{
    self.playType = model.playType;
    [self.musicList addObjectsFromArray:model.musicList];
    self.currentIndex = model.currentIndex;
    self.currentMusic = model.currentMusic;
    self.enterType = model.enterType;
    self.playOrder_zheng = model.playOrder_zheng;
    self.currentDuration = model.currentDuration;
    self.totalDuration = model.totalDuration;
    self.albumDic = model.albumDic;
}

#pragma mark - 播放统计
// 播放统计
- (void)playTongJi_playWithModel:(JANewVoiceModel *)model
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_STORY_TYPE;
    dic[@"type"] = @"play";
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.storyId;
    [self statisticalData:dic];
    
}

 // 播放时长统计
- (void)playTongJi_playTimeWithModel:(JANewVoiceModel *)model playMethod:(NSInteger)playMethod
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_STORY_TYPE;
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.storyId;
    
    dic[@"type"] = @"play_time";
    dic[@"palyTime"] = self.player.duration ? @((int)[JANewPlayTool shareNewPlayTool].currentDuration) : @((int)[NSString getSeconds:model.time]);
    dic[@"status"] = @(playMethod);
    [self statisticalData:dic];
}

// 跳过统计
- (void)playTongJi_skipWithModel:(JANewVoiceModel *)model
{
    NSString *userId = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"dataType"] = JA_STORY_TYPE;
    dic[@"type"] = @"skip";
    dic[@"userId"] = userId.length ? userId : @"0";
    dic[@"typeId"] = model.storyId;
    [self statisticalData:dic];
}

- (void)statisticalData:(NSMutableDictionary *)dic
{
    if (self.enterType == 4) {
        return;
    }
    NSString *ID = [NSString stringWithFormat:@"%@",dic[@"typeId"]];
    if ([ID containsString:@"-"]) {
        return;
    }
    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:nil failure:nil];
}

// 开始播放神策统计
- (void)sensorsAnalytics_start:(BOOL)isManual
{
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = self.currentMusic.storyId;
    eventParams[JA_Property_ContentTitle] = self.currentMusic.content;
    eventParams[JA_Property_ContentType] = @"主帖";
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:self.currentMusic.time]);
    eventParams[JA_Property_Anonymous] = @(self.currentMusic.user.isAnonymous);
    eventParams[JA_Property_PostId] = self.currentMusic.user.userId;
    eventParams[JA_Property_PostName] = self.currentMusic.user.userName;
    if (isManual) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";
    }else {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = self.currentMusic.sourcePage;
    eventParams[JA_Property_SourcePageName] = self.currentMusic.sourcePageName;
    
    eventParams[JA_Property_storyType] = self.currentMusic.concernType.integerValue == 0 ? @"语音":@"图文";
    
    [JASensorsAnalyticsManager sensorsAnalytics_startPlay:eventParams];
}

// 结束播放神策统计
- (void)sensorsAnalytics_stop:(BOOL)isManual
{
    if (!self.currentMusic.storyId.length) {
        return;
    }
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = self.currentMusic.storyId;
    eventParams[JA_Property_ContentTitle] = self.currentMusic.content;
    eventParams[JA_Property_ContentType] = @"主帖";
    eventParams[JA_Property_Anonymous] = @(self.currentMusic.user.isAnonymous);
    eventParams[JA_Property_PostId] = self.currentMusic.user.userId;
    eventParams[JA_Property_PostName] = self.currentMusic.user.userName;
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:self.currentMusic.time]);
    if (self.currentDuration < 0) {
        // 播放完成
        eventParams[JA_Property_PlayDuration] = eventParams[JA_Property_RecordDuration];
        eventParams[JA_Property_PlayAll] = @(YES);
    } else {
        eventParams[JA_Property_PlayDuration] = @(self.currentDuration);
        eventParams[JA_Property_PlayAll] = @(NO);
    }
    
    if (isManual) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";
    } else {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    
    eventParams[JA_Property_SourcePage] = self.currentMusic.sourcePage;
    eventParams[JA_Property_SourcePageName] = self.currentMusic.sourcePageName;
    
    eventParams[JA_Property_storyType] = self.currentMusic.concernType.integerValue == 0 ? @"语音":@"图文";
    
    [JASensorsAnalyticsManager sensorsAnalytics_stopPlay:eventParams];
}
@end
