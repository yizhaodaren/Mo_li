//
//  JAVoiceModel.h
//  Jasmine
//
//  Created by xujin on 29/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAVoiceModel : JABaseModel

@property (nonatomic, assign) BOOL isShowBanner;
@property (nonatomic, assign) BOOL isAgree;
@property (nonatomic, assign) BOOL isAnonymous;
@property (nonatomic, copy) NSString *anonymousName;
@property (nonatomic, copy) NSString *agreeCount;
@property (nonatomic, copy) NSString *isFoldCount;
@property (nonatomic, copy) NSString *audioUrl;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *commentCount;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *updateTime;
@property (nonatomic, copy) NSString *voiceId;
@property (nonatomic, copy) NSString *pvCount;
@property (nonatomic, copy) NSString *playCount;
@property (nonatomic, copy) NSString *replyCount;
@property (nonatomic, copy) NSString *shareCount;
@property (nonatomic, copy) NSString *shareUrl;
@property (nonatomic, copy) NSString *shareImg;
@property (nonatomic, copy) NSString *shareTitle;
@property (nonatomic, copy) NSString *shareWBContent;
@property (nonatomic, copy) NSString *shareWxContent;
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userImage;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, assign) CGFloat describeHeight;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, strong) NSString *concernType;

@property (nonatomic, assign) NSInteger playState;// 0未播放1播放2暂停3缓冲中
@property (nonatomic, assign) VoicePlayState finishState;  //  音频是否播放完成

// 波形图数据
@property (nonatomic, copy) NSString *sample;
@property (nonatomic, copy) NSString *sampleZip;
@property (nonatomic, strong) NSMutableArray *displayPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *currentPeakLevelQueue;

// v2.4.0新增数据
@property (nonatomic, copy) NSString *sourceName; // 该数据model归属哪个页面
@property (nonatomic, copy) NSString *recommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

// v2.4.1新增参数
@property (nonatomic, assign) NSInteger playMethod;// 0自动播放1手动播放

// 2.5.0 图片数组
@property (nonatomic, copy) NSString *image; //图片数组

@property (nonatomic, strong) NSString *flowerCount;  // 个人中心展示花
// v2.6.0
@property (nonatomic, strong) NSMutableArray *atList; //@人

// v2.6.4
@property (nonatomic, assign) CGFloat playProgress;


@property (nonatomic, assign) NSInteger contentType;// 0语音1图文

@end
