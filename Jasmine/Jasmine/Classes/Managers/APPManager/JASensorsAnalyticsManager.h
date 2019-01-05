//
//  JASensorsAnalyticsManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SensorsAnalyticsSDK/SensorsAnalyticsSDK.h>
#import "JAConsumer.h"
#import "JAVoiceModel.h"
#import "JAVoiceCommentModel.h"
#import "JAVoiceReplyModel.h"

@interface JASensorsAnalyticsManager : NSObject

/// 点击搜索框
+ (void)sensorsAnalytics_clickSearch:(NSDictionary *)properties;  // +

/// 发送搜索请求
+ (void)sensorsAnalytics_requestSearch:(NSDictionary *)properties;  // +

/// 点击搜索结果
+ (void)sensorsAnalytics_clickSearchResult:(NSDictionary *)properties;  // +

/// 浏览内容详情页
+ (void)sensorsAnalytics_browseViewControllerDetail:(NSDictionary *)properties;  // +

/// 点击首页banner
+ (void)sensorsAnalytics_clickBanner:(NSDictionary *)properties;  // +

/// 点击邀请回复按钮
+ (void)sensorsAnalytics_clickInvite:(NSDictionary *)properties;   // +

/// 点击确认邀请
+ (void)sensorsAnalytics_InvitePerson:(NSDictionary *)properties;  // +

/// 内容审核
+ (void)sensorsAnalytics_checkContent:(NSDictionary *)properties; // +

/// 进入私信
+ (void)sensorsAnalytics_enterMessage:(NSDictionary *)properties; // +

/// 发送私信
+ (void)sensorsAnalytics_sendMessage:(NSDictionary *)properties; // +

/// 举报
+ (void)sensorsAnalytics_reportPerson:(NSDictionary *)properties; // +

/// 绑定解绑 （小乔让前端都注释掉，不用掉绑定解绑）
+ (void)sensorsAnalytics_bindingOrunBinding:(NSDictionary *)properties; // +

/// 点击绑定解绑
+ (void)sensorsAnalytics_ClickBindingOrunBinding:(NSDictionary *)properties; // + 

/// 申请提现
+ (void)sensorsAnalytics_withDraw:(NSDictionary *)properties; // +

/// 兑换零钱
+ (void)sensorsAnalytics_exchangeMoney:(NSDictionary *)properties; // +

/// 邀请好友
+ (void)sensorsAnalytics_inviteFriend:(NSDictionary *)properties; // +

/// 唤醒好友
+ (void)sensorsAnalytics_callFriend:(NSDictionary *)properties;

/// 点击push通知
+ (void)sensorsAnalytics_clickPushContent:(NSDictionary *)properties; // +

/// push通知到达
+ (void)sensorsAnalytics_ReceivePushContent:(NSDictionary *)properties; // +

/// 浏览常见问题
+ (void)sensorsAnalytics_seeQuestionHelp:(NSDictionary *)properties; // +

/// 浏览视频教程
+ (void)sensorsAnalytics_seevideoHelp:(NSDictionary *)properties; // +

/// 关注用户
+ (void)sensorsAnalytics_followPerson:(NSDictionary *)properties; // +

/// 分享帖子
+ (void)sensorsAnalytics_clickShare:(NSDictionary *)properties;   // +

/// 分享收入
+ (void)sensorsAnalytics_clickShareMoney:(NSDictionary *)properties;   // +

/// 点赞
+ (void)sensorsAnalytics_clickAgree:(NSDictionary *)properties;

/// 注册按钮
+ (void)sensorsAnalytics_clickRegist:(NSDictionary *)properties;

/// 注册验证码按钮
+ (void)sensorsAnalytics_clickRegistCode:(NSDictionary *)properties;

/// 页面浏览统计
+ (void)sensorsAnalytics_browseViewPage:(NSDictionary *)properties;

/// 首页的刷新
+ (void)sensorsAnalytics_homeRefresh:(NSDictionary *)properties;

/// 登录
+ (void)sensorsAnalytics_login;

// 设置用户属性
+ (void)sensorsAnalytics_setUser:(JAConsumer *)user;
// 设置用户属性(本地存储)
+ (void)sensorsAnalytics_setUser;

/// 开始录音
+ (void)sensorsAnalytics_startRecord:(NSDictionary *)properties;

/// 重录提示
+ (void)sensorsAnalytics_rerecording:(NSDictionary *)properties;

/// 完成录音
+ (void)sensorsAnalytics_endRecord:(NSDictionary *)properties;

/// 放弃录音
+ (void)sensorsAnalytics_dropRecord:(NSDictionary *)properties;

/// 发布帖子
+ (void)sensorsAnalytics_post:(NSDictionary *)properties;

/// 放弃发布
+ (void)sensorsAnalytics_dropPost:(NSDictionary *)properties;

/// 开始播放内容
+ (void)sensorsAnalytics_startPlayVoiceModel:(JAVoiceModel *)model method:(NSInteger)method;
+ (void)sensorsAnalytics_startPlayCommentModel:(JAVoiceCommentModel *)model method:(NSInteger)method;
+ (void)sensorsAnalytics_startPlayReplyModel:(JAVoiceReplyModel *)model method:(NSInteger)method;

/// 结束播放内容
+ (void)sensorsAnalytics_endPlayVoiceModel:(JAVoiceModel *)model playDuration:(int)playDuration;
+ (void)sensorsAnalytics_endPlayCommentModel:(JAVoiceCommentModel *)model playDuration:(int)playDuration;
+ (void)sensorsAnalytics_endPlayReplyModel:(JAVoiceReplyModel *)model playDuration:(int)playDuration;

/// 播放跳过
+ (void)sensorsAnalytics_skipPlayVoiceModel:(JAVoiceModel *)model method:(NSInteger)method;
+ (void)sensorsAnalytics_skipPlayCommentModel:(JAVoiceCommentModel *)model method:(NSInteger)method;
+ (void)sensorsAnalytics_skipPlayReplyModel:(JAVoiceReplyModel *)model method:(NSInteger)method;

/// 点击播放进度条
+ (void)sensorsAnalytics_clickPlayBarWithType:(NSInteger)type;

// v2.4.0新增
/// 收藏&取消收藏
+ (void)sensorsAnalytics_collect:(NSDictionary *)properties;
/// 不感兴趣
+ (void)sensorsAnalytics_noInterest:(NSDictionary *)properties;

// v2.4.1新增
/// 关闭欢迎提示音
+ (void)sensorsAnalytics_shutUp:(NSDictionary *)properties;

// 2.5.6 新增统计 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
/// 三方注册
+ (void)sensorsAnalytics_ThirdPartRegister:(NSDictionary *)properties; //
/// 输入验证码
+ (void)sensorsAnalytics_InputValidationCode:(NSDictionary *)properties; //
/// 输入密码
+ (void)sensorsAnalytics_InputPassword:(NSDictionary *)properties; //

/// 活动收徒
+ (void)sensorsAnalytics_shareActivity:(NSDictionary *)properties;   //

// 2.5.6 新增统计 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


// 3.0.0 新增统计 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

/// 注册页面浏览统计
+ (void)sensorsAnalytics_registPagebrowseViewPage:(NSDictionary *)properties;

/// 跳转注册/登录页面
+ (void)sensorsAnalytics_jumpRegistOrLoginPage:(NSDictionary *)properties;

// 3.0.0 新增统计 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


/// 开始播放 - 新逻辑
+ (void)sensorsAnalytics_startPlay:(NSDictionary *)properties;
/// 停止播放 - 新逻辑
+ (void)sensorsAnalytics_stopPlay:(NSDictionary *)properties;
@end
