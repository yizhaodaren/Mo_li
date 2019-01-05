//
//  JAVoiceCommentHeaderView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAVoiceModel.h"
//#import "JAVoiceWaveView.h"
#import "JANewVoiceWaveView.h"

@interface JAVoiceCommentHeaderView : UIView

@property (nonatomic, strong) JANewVoiceWaveView *voiceWaveView;

@property (nonatomic, strong) JAVoiceModel *data;
@property (nonatomic, copy) void(^headActionBlock)(JAVoiceCommentHeaderView *headV); // 头像姓名点击  个人中心
@property (nonatomic, copy) void(^deleteVoiceBlock)(JAVoiceCommentHeaderView *headV);    // 删除帖子
@property (nonatomic, copy) void(^playBlock)(JAVoiceCommentHeaderView *headV);      // 播放故事
@property (nonatomic, copy) void(^commentBlock)(JAVoiceCommentHeaderView *headV);   // 评论
//@property (nonatomic, strong) void(^adminActionVoicePosts)(JAVoiceCommentHeaderView *headV);  // 管理员操作帖子

@property (nonatomic, strong) void(^adminActionVoicePicture)(JAVoiceCommentHeaderView *headV);  // 管理员删除配图

@property (nonatomic, strong) void(^showPicture_registInut)(JAVoiceCommentHeaderView *headV);  // 查看大图退出键盘


// v2.5.4
@property (nonatomic, strong) void(^topicDetailBlock)(NSString *topicName);  // 跳转话题详情
@property (nonatomic, strong) void (^refreshAgreeStatus)(BOOL agreeStatus); // 刷新外面的点赞按钮

// v2.6.0
@property (nonatomic, copy) void(^atPersonBlock)(NSString *userName, NSArray *atList);

@end
