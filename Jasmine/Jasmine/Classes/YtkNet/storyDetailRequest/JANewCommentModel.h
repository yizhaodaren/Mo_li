//
//  JANewCommentModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JANewReplyModel.h"
#import "JALightUserModel.h"
#import "JALightStoryModel.h"

@interface JANewCommentModel : JANetBaseModel

@property (nonatomic, strong) NSString *agreeCount;
@property (nonatomic, strong) NSString *audioUrl;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *floorNum;
@property (nonatomic, assign) BOOL isAgree;
@property (nonatomic, strong) NSString *replyCount;
@property (nonatomic, strong) NSString *sampleZip;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *storyId;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSArray *replyList;
@property (nonatomic, strong) JALightUserModel *user;
@property (nonatomic, strong) NSMutableArray *atList; //@人
@property (nonatomic, strong) JALightStoryModel *storyMsg;

// 自定义字段
@property (nonatomic, strong) NSString *storyUserId;   // 帖主(用来做判断是否是帖主（楼主）标签)

@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) BOOL refreshModelHeight;

// 个人中心用的高度
@property (nonatomic, assign) CGFloat personCenterCellHeight;

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
@property (nonatomic, assign) CGRect goBackButtonFrame;


//// v2.4.0新增数据
//@property (nonatomic, copy) NSString *sourceName; // 该数据model归属哪个页面
//@property (nonatomic, copy) NSString *recommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

// 神策统计
@property (nonatomic, strong) NSString *sourcePage;
@property (nonatomic, strong) NSString *sourcePageName;

// 3.1
@property (nonatomic, assign) NSInteger needActionButton;  // 需要操作按钮 0 没有 1 返回浏览位置 2 回到顶楼
@end
