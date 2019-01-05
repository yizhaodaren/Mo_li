//
//  JAVoiceReplyModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAVoiceReplyModel : JABaseModel
@property (nonatomic, copy) NSString *agreeCount;
@property (nonatomic, copy) NSString *audioUrl;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *commentId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *voiceReplyId;
@property (nonatomic, assign) BOOL isAgree;
@property (nonatomic, assign) BOOL isAnonymous;
@property (nonatomic, copy) NSString *userAnonymousName;
@property (nonatomic, copy) NSString *storyId; // 主帖id
@property (nonatomic, copy) NSString *userId;     // 回复者
@property (nonatomic, copy) NSString *userImage;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *replyUserId;   // 被回复者
@property (nonatomic, copy) NSString *replyUserName;
@property (nonatomic, copy) NSString *replyAnonymousName;
@property (nonatomic, assign) BOOL replyIsAnonymous;
@property (nonatomic, copy) NSString *reportCount;
@property (nonatomic, copy) NSString *time;

/***********************************2.4.0***********************************/
// 帖主的id
@property (nonatomic, strong) NSString *voiceStoryUserId;
// 评论者的id
@property (nonatomic, strong) NSString *voiceCommentUserId;

@property (nonatomic, assign) CGRect leftImageFrame;
@property (nonatomic, assign) CGRect iconFrame;
@property (nonatomic, assign) CGRect pointFrame;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect arrowFrame;
@property (nonatomic, assign) CGRect beReplyNameFrame;
@property (nonatomic, assign) CGRect nameTagFrame;
@property (nonatomic, assign) CGRect floorFrame;
@property (nonatomic, assign) CGRect timeFrame;
@property (nonatomic, assign) CGRect agreeFrame;
@property (nonatomic, assign) CGRect annimateFrame;
//@property (nonatomic, assign) CGRect playFrame;
//@property (nonatomic, assign) CGRect voiceWaveFrame;
//@property (nonatomic, assign) CGRect durationFrame;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) CGRect bottomBeReplyFrame;
@property (nonatomic, assign) CGRect replyPlayFrame;
@property (nonatomic, assign) CGRect replyNameFrame;
@property (nonatomic, assign) CGRect replyNameTagFrame;
@property (nonatomic, assign) CGRect replyTitleFrame;
@property (nonatomic, assign) CGRect allReplyFrame;
@property (nonatomic, assign) CGRect lineFrame;

@property (nonatomic, assign) BOOL refreshModel;
/**********************************************************************/

@property (nonatomic, assign) CGFloat cellHeight;

@property (nonatomic, assign) NSInteger playState;// 0未播放1播放2暂停
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

// v2.6.0
@property (nonatomic, strong) NSMutableArray *atList; //@人

@end
