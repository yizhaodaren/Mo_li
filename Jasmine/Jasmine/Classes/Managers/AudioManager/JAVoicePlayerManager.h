//
//  JAVoicePlayerManager.h
//  Jasmine
//
//  Created by xujin on 09/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <StreamingKit/STKAudioPlayer.h>
#import "STKAudioPlayer.h"
#import "JAPlayerDelegate.h"
#import "JAVoiceModel.h"    
#import "JAVoiceCommentModel.h"
#import "JAVoiceReplyModel.h"

@interface JAVoicePlayerItem : NSObject

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *voiceId;
@property (nonatomic, assign) BOOL isComment;

@end

@interface JAVoicePlayerManager : NSObject

@property (nonatomic, weak) id<JAPlayerDelegate> delegate;
@property (nonatomic, assign, readonly) BOOL isPlaying;
@property (nonatomic, strong) STKAudioPlayer *player;
//@property (nonatomic, strong) JAVoicePlayerItem *playerItem;
@property (nonatomic, strong, readonly) JAVoiceModel *voiceModel;
@property (nonatomic, strong, readonly) JAVoiceCommentModel *commentModel;
@property (nonatomic, strong, readonly) JAVoiceReplyModel *replyModel;
@property (nonatomic, assign) BOOL isInRecord;
@property (nonatomic, assign) BOOL isHomeData;// 首页主帖跳过,不需要播放帖子的评论

// 播放列表（需要加载更多，能继续播放，所以使用的是strong）
@property (nonatomic, strong) NSMutableArray *voices;
@property (nonatomic, strong) NSMutableArray *commentVoices;
@property (nonatomic, strong) NSMutableArray *replyVoices;
// 当前播放的index
@property (nonatomic, assign) NSInteger currentPlayIndex;
@property (nonatomic, assign) NSInteger currentPlayCommentIndex;
@property (nonatomic, assign) NSInteger currentPlayReplyIndex;

// 2.4.1
@property (nonatomic, assign) CGFloat playProgress;

+ (JAVoicePlayerManager *)shareInstance;

- (void)play:(NSURL *)url;

- (void)stop;

- (void)dispose;

- (void)pause;

- (void)contiunePlay;

- (void)seekToTimeWithSliderValue:(float)value;

- (void)playbackFinished;

- (void)cancelDelayPlayNextVoice;

// 注册一个监听对象到监听列表中
- (void)addDelegate:(id<JAPlayerDelegate>)delegate;
    
// 从监听列表中移除一个监听对象
- (void)removeDelegate:(id<JAPlayerDelegate>)delegate;

- (void)removePlayNext;

//#warning 根据统计需求调用相应的播放方法
// 播放音频方法
- (void)setVoiceModel:(JAVoiceModel *)voiceModel;
- (void)setCommentModel:(JAVoiceCommentModel *)commentModel;
- (void)setReplyModel:(JAVoiceReplyModel *)replyModel;

- (void)setVoiceModel:(JAVoiceModel *)voiceModel playMethod:(NSInteger)playMethod;
- (void)setCommentModel:(JAVoiceCommentModel *)commentModel playMethod:(NSInteger)playMethod;
- (void)setReplyModel:(JAVoiceReplyModel *)replyModel playMethod:(NSInteger)playMethod;

// v2.4.0 bug修复：播放本地音频的时候，重置所有之前播放的状态和UI
- (void)beforeLocalPlayResetAll;

// 2.5.0 区分播放入口，过滤掉审核时的播放统计
/*
    0 默认   需要统计播放等操作
    1 审核区播放  不需要统计
 */
@property (nonatomic, assign) NSInteger playEnterType;

@end
