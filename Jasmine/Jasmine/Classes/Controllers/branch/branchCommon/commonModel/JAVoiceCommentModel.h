//
//  JAVoiceCommentModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@class JAVoiceReplyModel,JAVoiceModel;
@interface JAVoiceCommentModel : JABaseModel

@property (nonatomic, copy) NSString *agreeCount;
@property (nonatomic, copy) NSString *audioUrl;
@property (nonatomic, copy) NSString *categoryId;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *createTime;
@property (nonatomic, copy) NSString *voiceCommendId;
@property (nonatomic, assign) BOOL isAgree;
@property (nonatomic, assign) BOOL isAnonymous;
@property (nonatomic, assign) BOOL isFold;
@property (nonatomic, copy) NSString *anonymousName;
@property (nonatomic, copy) NSString *opposeCount;
@property (nonatomic, copy) NSString *replyCount;
@property (nonatomic, copy) NSString *reportCount;
@property (nonatomic, strong) JAVoiceReplyModel *s2cReplyMsg;
@property (nonatomic, strong) JAVoiceModel *s2cStoryMsg;
@property (nonatomic, strong) JAVoiceModel *s2cContentMsg;  // 只在个人中心的赞过界面有用
@property (nonatomic, copy) NSString *sort;
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *typeId; // 主帖id
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userImage;
@property (nonatomic, copy) NSString *userName;

@property (nonatomic, assign) NSInteger floorCount;

/********************************2.4.0**************************************/
// 帖主的id
@property (nonatomic, strong) NSString *voiceStoryUserId;

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
@property (nonatomic, assign) CGFloat replyPosetsCellHeight;  // 个人中心中复合model的cell的高度

@property (nonatomic, assign) NSInteger playState;// 0未播放1播放2暂停
@property (nonatomic, assign) VoicePlayState finishState;  //  音频是否播放完成
// 波形图数据
@property (nonatomic, copy) NSString *sample;
@property (nonatomic, copy) NSString *sampleZip;
@property (nonatomic, strong) NSMutableArray *displayPeakLevelQueue;
@property (nonatomic, strong) NSMutableArray *currentPeakLevelQueue;

//// v2.4.0新增数据
@property (nonatomic, copy) NSString *sourceName; // 该数据model归属哪个页面
@property (nonatomic, copy) NSString *recommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

// v2.4.1新增参数
@property (nonatomic, assign) NSInteger playMethod;// 0自动播放1手动播放

// v2.6.0
@property (nonatomic, strong) NSMutableArray *atList; //@人

@end
