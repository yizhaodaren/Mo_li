//
//  JAPostDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
@class JANewCommentModel;
@interface JAPostDetailViewController : JABaseViewController

// 帖子id
@property (nonatomic, strong) NSString *voiceId;

// 是否是推荐进入详情
@property (nonatomic, strong) NSString *channelId;  // 2 表示推荐进入
@property (nonatomic, assign) NSInteger enterType;  // 1 表示圈子进入

@property (nonatomic, strong) void (^refreshAgreeStatus)(BOOL agreeStatus); // 首页点赞回刷界面
@property (nonatomic, strong) void (^refreshCommentCount)(BOOL deleteComment); // 首页点赞回刷界面

@property (nonatomic, strong) NSString *jump_commentId;  

// 神策用数据（不确定有啥用）
@property (nonatomic, copy) NSString *backSourceName; // 该数据model归属哪个页面
@property (nonatomic, copy) NSString *backRecommendType; // 发现频道的主帖有这个字段（实时内容相似性、定时内容相似性）

// 播放列表
@property (nonatomic, strong) NSArray *musicList;

- (void)postDetail_refreshViewWithId:(NSString *)storyId;

// 神策用数据
@property (nonatomic, strong) NSString *sourcePage;
@property (nonatomic, strong) NSString *sourcePageName;
@end
