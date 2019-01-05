//
//  JASensorsAnalyticsConstants.m
//  Jasmine
//
//  Created by xujin on 22/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASensorsAnalyticsConstants.h"

/*************************神策事件***************************/
/// 启动 App
NSString *const JA_Event_AppStart = @"$AppStart";
/// 退出 App
NSString *const JA_Event_AppEnd = @"$AppEnd";
/// App 激活
NSString *const JA_Event_AppInstall = @"AppInstall";
/// App 浏览页面
NSString *const JA_Event_AppViewScreen = @"$AppViewScreen";
/// 点击注册按钮
NSString *const JA_Event_ClickRegister = @"ClickRegister";
/// 获取验证码
NSString *const JA_Event_GetValidationCode = @"GetValidationCode";
/// 注册成功
NSString *const JA_Event_RegisterSuccess = @"RegisterSuccess";
/// 登录
NSString *const JA_Event_Login = @"Login";
/// 点击搜索框
NSString *const JA_Event_SearchClick = @"SearchClick";
/// 发送搜索请求
NSString *const JA_Event_SearchApply = @"SearchApply";
/// 点击搜索结果
NSString *const JA_Event_SearchResult = @"SearchResult";
/// 开始录音
NSString *const JA_Event_StartRecord = @"StartRecord";
/// 重录提示
NSString *const JA_Event_Rerecording = @"Rerecording";
/// 完成录音
NSString *const JA_Event_EndRecord = @"EndRecord";
/// 放弃录音
NSString *const JA_Event_DropRecord = @"DropRecord";
/// 发布帖子
NSString *const JA_Event_Post = @"Post";
/// 放弃发布
NSString *const JA_Event_DropPost = @"DropPost";
/// 浏览内容详情页
NSString *const JA_Event_ViewContentDetail = @"ViewContentDetail";
/// 点击首页banner
NSString *const JA_Event_ClickBanner = @"ClickBanner";
/// 开始播放内容
NSString *const JA_Event_StartPlay = @"StartPlay";
/// 结束播放内容
NSString *const JA_Event_StopPlay = @"StopPlay";
/// 点赞
NSString *const JA_Event_Like = @"Like";
/// 分享
NSString *const JA_Event_Share = @"Share";
/// 分享晒收入
NSString *const JA_Event_ShareIncome = @"ShareIncome";
/// 跳过
NSString *const JA_Event_Skip = @"Skip";
/// 回复
NSString *const JA_Event_Reply = @"Reply";
/// 被回复
NSString *const JA_Event_BeReplied = @"BeReplied";
/// 关注和取关
NSString *const JA_Event_Follow = @"Follow";
/// 点击邀请回复按钮
NSString *const JA_Event_ClickRequestReply = @"ClickRequestReply";
/// 确定邀请回复
NSString *const JA_Event_RequestReply = @"RequestReply";
/// 内容审核
NSString *const JA_Event_ContentReview = @"ContentReview";
/// 进入私信页面
NSString *const JA_Event_ViewMessagePage = @"ViewMessagePage";
/// 发送私信
NSString *const JA_Event_SendMessage = @"SendMessage";
/// 举报
NSString *const JA_Event_Report = @"Report";
/// 绑定和解绑
NSString *const JA_Event_Binding = @"Binding";
/// 绑定和解绑结果
NSString *const JA_Event_BindingSuccess = @"BindingSuccess";
/// 获得收入
NSString *const JA_Event_GetPay = @"GetPay";
/// 申请提现
NSString *const JA_Event_ApplyWithdraw = @"ApplyWithdraw";
/// 提现审核
NSString *const JA_Event_WithdrawReview = @"WithdrawReview";
/// 提现转账
NSString *const JA_Event_WithdrawTransfer = @"WithdrawTransfer";
/// 兑换零钱
NSString *const JA_Event_Exchange = @"Exchange";
/// 邀请好友
NSString *const JA_Event_Invite = @"Invite";
/// 唤醒好友
NSString *const JA_Event_WakeUpApprentice = @"WakeUpApprentice";
/// 邀请关系达成
NSString *const JA_Event_InviteDone = @"InviteDone";
/// 升级
NSString *const JA_Event_Upgrade = @"Upgrade";
/// 通知到达
NSString *const JA_Event_PushArrive = @"PushArrive";
/// 通知点击
NSString *const JA_Event_PushClick = @"PushClick";
/// 浏览活动页面
NSString *const JA_Event_ViewActivityPage = @"ViewActivityPage";
/// 参与活动
NSString *const JA_Event_TakePartIn = @"TakePartIn";
/// 浏览常见问题
NSString *const JA_Event_ViewFAQ = @"ViewFAQ";
/// 浏览视频教程
NSString *const JA_Event_VideoTutorial = @"VideoTutorial";
/// 获得奖励
NSString *const JA_Event_WinPrize = @"WinPrize";
/// 点击播放进度条
NSString *const JA_Event_ClickPlayBar = @"ClickPlayBar";
/// 首页刷新
NSString *const JA_Event_Reload = @"Reload";

// v2.4.0新增事件
/// 收藏&取消收藏
NSString *const JA_Event_Collect = @"collect";
/// 不感兴趣
NSString *const JA_Event_NoInterest = @"NoInterest";

// v2.4.1新增事件
/// 关闭欢迎提示音
NSString *const JA_Event_ShutUp = @"ShutUp";


// 2.5.6 新增事件 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
// 三方注册
NSString *const JA_Event_ThirdPartRegister = @"ThirdPartRegister";
// 输入验证码
NSString *const JA_Event_InputValidationCode = @"InputValidationCode";
// 输入密码
NSString *const JA_Event_InputPassword = @"InputPassword";

/// 活动收徒
NSString *const JA_Event_ActivityInvitation = @"ActivityInvitation";

// 2.5.6 新增事件↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

/// 跳转注册/登录
NSString *const JA_Event_JumpToRegisterPage = @"JumpToRegisterPage";

/*************************神策属性***************************/

/// 是否首日访问 (BOOL)
NSString *const JA_Property_IsFirstDay = @"$is_first_day";
/// 是否首次启动 (BOOL)
NSString *const JA_Property_IsFirstTime = @"$is_first_time";
/// 是否从后台唤醒 (BOOL)
NSString *const JA_Property_ResumeFromBackground = @"$resume_from_background";
/// 启动时长 (数值)
NSString *const JA_Property_EventDuration = @"event_duration";
/// 广告系列名称 (string)
NSString *const JA_Property_UtmCampaign = @"$utm_campaign";
/// 广告系列来源 (string)
NSString *const JA_Property_UtmSource = @"$utm_source";
/// 广告系列媒介 (string)
NSString *const JA_Property_UtmMedium = @"$utm_medium";
/// 广告系列字词 (string)
NSString *const JA_Property_UtmTerm = @"$utm_term";
/// 广告系列内容 (string)
NSString *const JA_Property_UtmContent = @"$utm_content";
/// 页面名称 (string)
NSString *const JA_Property_ScreenName = @"$screen_name";
NSString *const JA_Property_ContentName = @"content_name";
/// 页面标题 (string)
NSString *const JA_Property_Title = @"$title";
/// 注册方式 (string:微信，微博，手机号，qq)
NSString *const JA_Property_SignUpMethod = @"sign_up_method";
/// 手机号 (string)
NSString *const JA_Property_Phone = @"phone";
/// 是否发送请求 (bool)
NSString *const JA_Property_IsSendRequest = @"is_send_request";
/// 失败原因 (string)
NSString *const JA_Property_UnsentReason = @"unsent_reason";
/// 验证码类型 (string)
NSString *const JA_Property_CodeType = @"code_type";
/// 登录方式 (string:微信，微博，手机号，qq)
NSString *const JA_Property_LoginMethod = @"login_method";

/// 活动ID (string)
NSString *const JA_Property_ActivityId = @"activity_id";
/// 活动名称 (string)
NSString *const JA_Property_ActivityTitle = @"activity_title";
/// 奖励类型 (string)
NSString *const JA_Property_PrizeType = @"prize_type";
/// 视频标题 (string)
NSString *const JA_Property_VideoTitle = @"video_title";
/// 问题标题 (string)
NSString *const JA_Property_QuestionTitle = @"question_title";
/// 活动入口 (string)
NSString *const JA_Property_ActivityEntry = @"activity_entry";
/// 推送内容ID (string)
NSString *const JA_Property_PushId = @"push_id";
/// 推送内容标题 (string)
NSString *const JA_Property_PushTitle = @"push_title";
/// 推送内容正文 (string)
NSString *const JA_Property_PushContent = @"push_content";
/// 当前等级 (string)
NSString *const JA_Property_CurrentLevel = @"current_Level";

/// 邀请方式 (string)
NSString *const JA_Property_InvitationMethod = @"invitation_method";
/// 邀请人id (string)
NSString *const JA_Property_InviterId = @"inviter_id";
/// 今日汇率 (number)
NSString *const JA_Property_TodayRate = @"today_rate";
/// 茉莉花数量 (number) 原：flower_amount
NSString *const JA_Property_FlowerAmount = @"amount_of_flower";
/// 是否转账成功 (BOOL)
NSString *const JA_Property_TransferSucceed = @"transfer_succeed";
/// 零钱数量 (number)
NSString *const JA_Property_MoneyAmount = @"amount_of_money";
/// 是否通过审核 (BOOL)
NSString *const JA_Property_ReviewPass = @"review_pass";
/// 货币类型 (string)
NSString *const JA_Property_MoneyType = @"money_type";
/// 收入来源 (string)
NSString *const JA_Property_IncomeSource = @"income_source";
/// 操作类型 (string)
NSString *const JA_Property_BindingType = @"binding_type";
/// 账号类型 (string)
NSString *const JA_Property_AccountType = @"account_type";
/// 绑定解绑是否成功 (BOOL)
NSString *const JA_Property_BindingSucceed = @"binding_succeed";
/// 举报类型 (string)
NSString *const JA_Property_ReportType = @"report_type";
/// 举报原因 (string)
NSString *const JA_Property_ReportTeason = @"report_reason";
/// 帖主ID (string)
NSString *const JA_Property_PostId = @"post_id";
/// 帖主昵称 (string)
NSString *const JA_Property_PostName = @"post_name";
/// 内容ID (string)
NSString *const JA_Property_ContentId = @"content_id";
/// 内容标题 (string)
NSString *const JA_Property_ContentTitle = @"content_title";
/// 被私信人ID (string)
NSString *const JA_Property_MessageId = @"message_id";
/// 被私信人昵称 (string)
NSString *const JA_Property_MessageName = @"message_name";
/// 是否被限制 (string)
NSString *const JA_Property_BeLimited = @"be_limited";
/// 限制原因 (string)
NSString *const JA_Property_LimitedReason = @"limited_reason";
/// 录音时长 (number)
NSString *const JA_Property_RecordDuration = @"record_duration";
/// 审核方式 (string)
NSString *const JA_Property_ReviewMethod = @"review_method";
/// 审核结果 (string)
NSString *const JA_Property_ReviewResult = @"review_result";
/// 内容类别 (string)
NSString *const JA_Property_ContentType = @"content_type";
/// 所属频道 (string)
NSString *const JA_Property_Category = @"category";
///是否匿名 (BOOL)
NSString *const JA_Property_Anonymous = @"anonymous";
/// 被邀请人id (string)
NSString *const JA_Property_BeRequestedId = @"be_requested_id";
/// 被邀请人昵称 (string)
NSString *const JA_Property_BeRequestedName = @"be_requested_name";
///关注入口 (string)
NSString *const JA_Property_FollowMethod = @"follow_method";
/// 分享方式 (string)
NSString *const JA_Property_ShareMethod = @"share_method";
/// 跳过方式 (string)
NSString *const JA_Property_SkipMethod = @"skip_method";
/// 点赞方式 (string)
NSString *const JA_Property_LikeMethod = @"like_method";
/// 播放时长 (number)
NSString *const JA_Property_PlayDuration = @"play_duration";
/// 是否播完 (BOOL)
NSString *const JA_Property_PlayAll = @"play_all";
/// 播放方式 (string)
NSString *const JA_Property_PlayMethod = @"play_method";
/// bannerID (string)
NSString *const JA_Property_BannerId = @"banner_id";
/// banner位置 (string)
NSString *const JA_Property_BannerPosition = @"banner_position";
/// banner名称 (string)
NSString *const JA_Property_BannerTitle = @"banner_title";
/// 进入页面方式 (string)
NSString *const JA_Property_GotoMethod = @"goto_method";
/// 是否成功发布 (BOOL)
NSString *const JA_Property_PostSucceed = @"post_succeed";
/// 发布方式 (string)
NSString *const JA_Property_PostMethod = @"post_method";
/// 是否重录 (BOOL)
NSString *const JA_Property_Rerecording = @"rerecording";
/// 是否是自动弹出 (BOOL)
NSString *const JA_Property_AutoDialog = @"auto_dialog";

/// 关键词 (string)
NSString *const JA_Property_Keyword = @"keyword";
/// 搜索结果分类 (string)
NSString *const JA_Property_ResultCategory = @"result_category";
/// 是否使用历史词 (BOOL)
NSString *const JA_Property_IsHistoryWordUsed = @"is_history_word_used";
/// 是否有结果 (BOOL)
NSString *const JA_Property_HasResult = @"has_result";

/// 序号 (number)
NSString *const JA_Property_SerialNumber = @"serial_number";
/// 图片ID (string)
NSString *const JA_Property_ImageUrl = @"image_url";
/// 晒收入方式 (string)
NSString *const JA_Property_ShareButton = @"share_button";
/// 播放条位置 (string)
NSString *const JA_Property_BarPosition = @"bar_position";
/// 刷新方式 (string)
NSString *const JA_Property_ReloadMethod = @"reload_method";

// v2.4.0新增属性
/// 推荐类型
NSString *const JA_Property_RecommendType = @"recommend_type";
NSString *const JA_Property_SourcePage = @"source_page";
NSString *const JA_Property_SourcePageName = @"source_page_name";

/// 唤醒方式
NSString *const JA_Property_WakeUpMethod = @"wake_up_method";


// 2.5.6 新增属性 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

/// 话题id
NSString *const JA_Property_TopicId = @"topic_id";
/// 话题名称
NSString *const JA_Property_topicname = @"topic_name";
// 2.5.6 新增属性 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

// 3.0.2
NSString *const JA_Property_storyType = @"story_type";
NSString *const JA_Property_blockedReason = @"blocked_reason";
