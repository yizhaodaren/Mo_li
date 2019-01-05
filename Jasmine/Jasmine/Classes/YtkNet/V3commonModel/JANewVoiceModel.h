//
//  JANewVoiceModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JALightUserModel.h"
#import "JALightShareModel.h"
#import "JACircleModel.h"

@interface JAVoicePhoto : NSObject

@property (nonatomic, copy) NSString *src; // 图片url
@property (nonatomic, assign) CGFloat width;// 图片宽
@property (nonatomic, assign) CGFloat height;// 图片高

@end

@interface JANewVoiceModel : JANetBaseModel
@property (nonatomic, strong) NSString *searchStoryId;
@property (nonatomic, strong) NSString *agreeCount;  // 点赞数
@property (nonatomic, strong) NSString *audioUrl;    // 音频地址
@property (nonatomic, strong) JACircleModel *circle;  // 圈子信息
@property (nonatomic, strong) NSString *commentCount; // 评论数
@property (nonatomic, strong) NSString *playCount; // 播放数
@property (nonatomic, copy) NSString *content; // 描述
@property (nonatomic, strong) NSString *createTime; // 创建时间
@property (nonatomic, copy) NSString *image; //图片数组
@property (nonatomic, assign) BOOL isAgree; // 是否点赞
@property (nonatomic, assign) BOOL circleTop; // 是否置顶
@property (nonatomic, assign) BOOL essence; // 是否加精
@property (nonatomic, assign) BOOL userCollect; // 是否收藏
@property (nonatomic, strong) NSString *sampleZip; // 音频波形图压缩字段
@property (nonatomic, strong) NSString *shareCount;
@property (nonatomic, strong) NSString *storyId; // 故事（帖子）ID
@property (nonatomic, strong) NSString *time; // 音频时长
@property (nonatomic, strong) NSString *title; // 音频标题
@property (nonatomic, strong) JALightUserModel *user; // 用户信息
@property (nonatomic, strong) JALightShareModel *shareMsg; // 分享信息
@property (nonatomic, strong) NSMutableArray *atList; //@人
@property (nonatomic, copy) NSString *city;  // 城市

@property (nonatomic, strong) NSArray *allPeakLevelQueue; // 解压后的波形图数组

@property (nonatomic, copy) NSString *sourceName; // 该数据model归属哪个页面
@property (nonatomic, copy) NSString *recommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

@property (nonatomic, assign) NSInteger playState;// 0未播放1播放2暂停

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat describeHeight;
@property (nonatomic, assign) CGFloat detailCellHeight;
@property (nonatomic, assign) CGFloat detailDescribeHeight;
@property (nonatomic, assign) CGSize imageViewSize; // 图片view的大小
@property (nonatomic, assign) NSInteger storyType;// 0语音1图文
@property (nonatomic, assign) CGSize imageSize;

// 我的投稿的高度计算
@property (nonatomic, assign) CGFloat contrbuteHeight;
@property (nonatomic, strong) NSArray *imageText; // 图文帖内容数组
@property (nonatomic, strong) NSArray *photos; // 音频帖图片数据

@property (nonatomic, copy) NSString *labelName; // 帖子的主标签
@property (nonatomic, copy) NSString *concernType; // 0关注用户帖子1关注圈子帖子

// 神策统计
@property (nonatomic, strong) NSString *sourcePage;
@property (nonatomic, strong) NSString *sourcePageName;
@end
