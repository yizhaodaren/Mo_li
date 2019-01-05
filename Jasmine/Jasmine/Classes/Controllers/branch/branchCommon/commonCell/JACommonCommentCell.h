//
//  JACommonCommentCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceCommentModel.h"
#import "JAVoiceReplyModel.h"
#import "JAVoiceWaveView.h"
#import "JAEmitterView.h"
//#import "JACommentAgreeButton.h"
#import "KILabel.h"

#import "JANewCommentModel.h"
#import "JANewReplyModel.h"
typedef NS_ENUM(NSUInteger, VoiceCommentType) {
    VoiceCommentType_comment,
    VoiceCommentType_reply
};


@interface JACommonCommentCell : UITableViewCell

@property (nonatomic, weak) KILabel *title_label;    // 标题或内容

@property (nonatomic, assign) VoiceCommentType cellType;    // 默认是评论

@property (nonatomic, strong) JANewCommentModel *comment_Model;

@property (nonatomic, strong) JANewReplyModel *reply_Model;

@property (nonatomic, weak) JAEmitterView *likeButton; // 点赞
@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞

// 回复详情页中 评论的用户userid
@property (nonatomic, strong) NSString *reply_commentUserId;

// 可点击事件
@property (nonatomic, strong) void(^jumpPersonalViewControlBlock)(JACommonCommentCell *cell);  // 头像和姓名
@property (nonatomic, strong) void(^playCommentBlock)(JACommonCommentCell *cell);  // 播放评论按钮
@property (nonatomic, strong) void(^jumpReplyViewControlBlock)(JACommonCommentCell *cell);  // 跳转回复详情控制器

@property (nonatomic, strong) void(^jumpReplyPersonalViewControlBlock)(JACommonCommentCell *cell);  // 评论界面 底部回复者姓名（暂未用）
@property (nonatomic, strong) void(^jumpBeReplyPersonalViewControlBlock)(JACommonCommentCell *cell);  // 回复页面 被回复者姓名（被指向的）

// 2.4.0
@property (nonatomic, strong) void (^refreshCommentOrReplyAgreeStatus)(BOOL agreeStatus); // 刷新外面的点赞按钮

// 2.4.1
@property (nonatomic, strong) void(^pointClickBlock)(JACommonCommentCell *cell);  // 三个点按钮

/*暂时没用*/
//@property (nonatomic, strong) void(^playReplyBlock)(JACommonCommentCell *cell);  // 播放评论回复按钮
//@property (nonatomic, strong) void(^recordVoiceViewControlBlock)(JACommonCommentCell *cell);  // 录制按钮
//@property (nonatomic, strong) void(^agreeBlock)(JACommonCommentCell *cell);  // 点赞（喜欢）按钮
//@property (nonatomic, strong) void(^reportBlock)(JACommonCommentCell *cell);  // 三个点按钮
// 点击初心
//- (void)showHeardShape;

// 双击点赞
//- (void)doubleClickAgree:(JACommentAgreeButton *)sender;

// v2.6.0
@property (nonatomic, copy) void(^commentAtPersonBlock)(NSString *userName, NSArray *atList);
@property (nonatomic, copy) void(^replyAtPersonBlock)(NSString *userName, NSArray *atList);

// v3.1
@property (nonatomic, copy) void(^goBackBrowseLocation)();
@property (nonatomic, copy) void(^goBackBeginLocation)();
@end
