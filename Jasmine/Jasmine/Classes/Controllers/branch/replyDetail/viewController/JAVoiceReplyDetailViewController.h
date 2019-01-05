//
//  JAVoiceReplyDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@class JANewReplyModel;
@interface JAVoiceReplyDetailViewController : JABaseViewController

@property (nonatomic, strong) NSString *voiceId;    // 帖子id
@property (nonatomic, strong) NSString *voiceCommentId;  // 评论id

@property (nonatomic, assign) BOOL hasRightButton;

@property (nonatomic, strong) NSString *storyUserId;  // 帖主userId


//2.4.0 需要展示的第一条回复
@property (nonatomic, strong) JANewReplyModel *first_replyModel;
@property (nonatomic, strong) void (^refreshCommentAgreeStatus)(BOOL agreeStatus); // 评论点赞回刷

@property (nonatomic, strong) NSString *sourcePage;
@property (nonatomic, strong) NSString *sourcePageName;
@end
