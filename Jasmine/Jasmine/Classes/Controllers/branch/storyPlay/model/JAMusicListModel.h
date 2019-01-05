//
//  JAMusicListModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/9.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JANewVoiceModel.h"

@interface JAMusicListModel : JANetBaseModel
@property (nonatomic, assign) NSInteger playType;  // 播放状态
@property (nonatomic, strong) NSArray *musicList;  // 播放列表
@property (nonatomic, assign) NSInteger currentIndex;  // 当前播放的索引
@property (nonatomic, strong) JANewVoiceModel *currentMusic;  // 当前播放的曲目
@property (nonatomic, assign) NSInteger enterType;   // 进入播放器的界面   (type: 1其他界面 2详情 3专辑 4草稿箱)
@property (nonatomic, assign) BOOL playOrder_zheng;   // 播放顺序
@property (nonatomic, assign) NSTimeInterval currentDuration; // 当前音乐播放时间 （相当于进度）
@property (nonatomic, assign) NSTimeInterval totalDuration; // 当前音乐总时长
@property (nonatomic, strong) NSDictionary *albumDic; // 专辑进入时请求数据参数
@end
