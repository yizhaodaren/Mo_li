//
//  JAVoiceCommentDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAVoiceCommentModel.h"
#import "JAVoiceReplyModel.h"

@interface JAVoiceCommentDetailViewController : JABaseViewController

@property (nonatomic, assign) BOOL isCommentClick; // 点击评论按钮进入页面
@property (nonatomic, strong) NSString *channelId;     // 分享推荐下的帖子算完成任务
@property (nonatomic, strong) NSString *voiceId;


@property (nonatomic, strong) JAVoiceCommentModel *release_commentModel;  // 发布成功后的数据模型
@property (nonatomic, strong) JAVoiceReplyModel *release_replyModel;

// 2.4.0
@property (nonatomic, strong) void (^refreshAgreeStatus)(BOOL agreeStatus); // 首页点赞回刷界面
// 需要展示的第一条评论
@property (nonatomic, strong) JAVoiceCommentModel *first_commentModel;  // 传递第一条数据（通知、个人主页回复）

// 新增数据 -- 回传的RecommendType（和帖子返回的一样）
@property (nonatomic, copy) NSString *backSourceName; // 该数据model归属哪个页面
@property (nonatomic, copy) NSString *backRecommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

// v2.6.4
@property (nonatomic, strong) JAVoiceModel *lastVoiceModel;

@end
