//
//  JANewPlayTool.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/22.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class JAMusicListModel;
@interface JANewPlayTool : NSObject
+ (instancetype)shareNewPlayTool;

/// 读取缓存数据
- (void)playTool_readCachMusicListWithModel:(JAMusicListModel *)model;

/*
 type           : 1其他界面 2详情 3专辑 4草稿箱
 albumParameter : 专辑时， 传递的请求参数
 @{
 @"currentPage" : @(1)
 @"orderType" : @()
 @"subjectId" : @""
 }
 */
/// 开始播放
- (void)playTool_playWithModel:(JANewVoiceModel *)model
                     storyList:(NSArray *)storyListArray
                     enterType:(NSInteger)type
                albumParameter:(NSDictionary *)albumParameter;

/* --------------------------------------------- 播放帖子（循环列表）---------------------------------------- */
/// 重置播放器 (目前只有在专辑详情点击播放全部的时候使用)
- (void)playTool_resetPlayTool;

/// 暂停播放
- (void)playTool_pause;

/// 继续播放
- (void)playTool_continue;

/// 播放下一曲
- (void)playTool_playNextMusic;

/// 播放上一曲
- (void)playTool_playFrontMusic;

/// 播放指定歌曲
- (void)playTool_playWithMusics:(NSArray *)musicList index:(NSInteger)index;

/// 快进
- (void)playTool_seetValue:(double)value;

/// 切换播放顺序
- (void)playTool_playSortWithOrder:(BOOL)isZheng;

/// 播放器的状态
@property (nonatomic, assign, readonly) NSInteger playType;   // 0未播放 1 播放 2暂停 3 缓冲中...

/// 当前的播放列表
@property (nonatomic, strong, readonly) NSMutableArray *musicList;

/// 当前播放的index
@property (nonatomic, assign, readonly) NSInteger currentIndex;

/// 当前播放曲目
@property (nonatomic, strong, readonly) JANewVoiceModel *currentMusic;

/// 上次的进入方式
@property (nonatomic, assign, readonly) NSInteger enterType;

/// 上次的播放顺序
@property (nonatomic, assign, readonly) BOOL playOrder_zheng;

/// 当前音乐播放时间 （相当于进度）
@property (nonatomic, assign, readonly) NSTimeInterval currentDuration;

/// 当前音乐总时长
@property (nonatomic, assign, readonly) NSTimeInterval totalDuration;
/* --------------------------------------------- 播放帖子（循环列表）---------------------------------------- */

/* --------------------------------------------- 播放专辑专用 ---------------------------------------- */

/// 根据播放顺序拉取专辑帖子
- (void)playTool_getAlbumMusicListWithSort;
@property (nonatomic, strong, readonly) NSDictionary *albumDic; // 拉取数据的参数
/* --------------------------------------------- 播放专辑专用 ---------------------------------------- */

@end
