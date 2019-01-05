//
//  JANewReplyModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/31.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JALightUserModel.h"

@interface JANewReplyModel : JANetBaseModel
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *replyId;
@property (nonatomic, strong) JALightUserModel *replyUser;
@property (nonatomic, strong) JALightUserModel *user;
@property (nonatomic, strong) NSString *sampleZip;
@property (nonatomic, strong) NSMutableArray *atList; //@人

// 自定义字段
@property (nonatomic, strong) NSString *storyUserId;  // 帖主的id (用来做是否是楼主)
@property (nonatomic, strong) NSString *commentUserId;  // 评论者的id（用来做是否有回复指向（回复评论者不展示））

// ------- frame -------
@property (nonatomic, assign) CGRect leftImageFrame;
@property (nonatomic, assign) CGRect iconFrame;
@property (nonatomic, assign) CGRect pointFrame;
@property (nonatomic, assign) CGRect nameFrame;
@property (nonatomic, assign) CGRect arrowFrame;
@property (nonatomic, assign) CGRect beReplyNameFrame;
@property (nonatomic, assign) CGRect nameTagFrame;
@property (nonatomic, assign) CGRect circleTagFrame;
@property (nonatomic, assign) CGRect floorFrame;
@property (nonatomic, assign) CGRect timeFrame;
@property (nonatomic, assign) CGRect agreeFrame;
@property (nonatomic, assign) CGRect annimateFrame;
@property (nonatomic, assign) CGRect titleFrame;
@property (nonatomic, assign) CGRect bottomBeReplyFrame;
@property (nonatomic, assign) CGRect replyPlayFrame;
@property (nonatomic, assign) CGRect replyNameFrame;
@property (nonatomic, assign) CGRect replyNameTagFrame;
@property (nonatomic, assign) CGRect replyTitleFrame;
@property (nonatomic, assign) CGRect allReplyFrame;
@property (nonatomic, assign) CGRect lineFrame;

@property (nonatomic, assign) BOOL refreshModel;  // 是否刷新高度
@property (nonatomic, assign) CGFloat cellHeight;

//// v2.4.0新增数据
//@property (nonatomic, copy) NSString *sourceName; // 该数据model归属哪个页面
//@property (nonatomic, copy) NSString *recommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

// 神策统计
@property (nonatomic, strong) NSString *sourcePage;
@property (nonatomic, strong) NSString *sourcePageName;
@end
