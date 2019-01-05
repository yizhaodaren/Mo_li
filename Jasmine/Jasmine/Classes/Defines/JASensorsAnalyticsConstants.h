//
//  JASensorsAnalyticsConstants.h
//  Jasmine
//
//  Created by xujin on 22/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

/*************************神策事件***************************/
/// 启动 App
UIKIT_EXTERN NSString *const JA_Event_AppStart;
/// 退出 App
UIKIT_EXTERN NSString *const JA_Event_AppEnd;
/// App 激活
UIKIT_EXTERN NSString *const JA_Event_AppInstall;
/// App 浏览页面
UIKIT_EXTERN NSString *const JA_Event_AppViewScreen;
/// 点击注册按钮
UIKIT_EXTERN NSString *const JA_Event_ClickRegister;
/// 获取验证码
UIKIT_EXTERN NSString *const JA_Event_GetValidationCode;
/// 注册成功
UIKIT_EXTERN NSString *const JA_Event_RegisterSuccess;
/// 登录
UIKIT_EXTERN NSString *const JA_Event_Login;
/// 点击搜索框
UIKIT_EXTERN NSString *const JA_Event_SearchClick;
/// 发送搜索请求
UIKIT_EXTERN NSString *const JA_Event_SearchApply;
/// 点击搜索结果
UIKIT_EXTERN NSString *const JA_Event_SearchResult;
/// 开始录音
UIKIT_EXTERN NSString *const JA_Event_StartRecord;
/// 重录提示
UIKIT_EXTERN NSString *const JA_Event_Rerecording;
/// 完成录音
UIKIT_EXTERN NSString *const JA_Event_EndRecord;
/// 放弃录音
UIKIT_EXTERN NSString *const JA_Event_DropRecord;
/// 发布帖子
UIKIT_EXTERN NSString *const JA_Event_Post;
/// 放弃发布
UIKIT_EXTERN NSString *const JA_Event_DropPost;
/// 浏览内容详情页
UIKIT_EXTERN NSString *const JA_Event_ViewContentDetail;
/// 点击首页banner
UIKIT_EXTERN NSString *const JA_Event_ClickBanner;
/// 开始播放内容
UIKIT_EXTERN NSString *const JA_Event_StartPlay;
/// 结束播放内容
UIKIT_EXTERN NSString *const JA_Event_StopPlay;
/// 点赞
UIKIT_EXTERN NSString *const JA_Event_Like;
/// 分享
UIKIT_EXTERN NSString *const JA_Event_Share;
/// 分享晒收入
UIKIT_EXTERN NSString *const JA_Event_ShareIncome;
/// 跳过
UIKIT_EXTERN NSString *const JA_Event_Skip;
/// 回复
UIKIT_EXTERN NSString *const JA_Event_Reply;
/// 被回复
UIKIT_EXTERN NSString *const JA_Event_BeReplied;
/// 关注和取关
UIKIT_EXTERN NSString *const JA_Event_Follow;
/// 点击邀请回复按钮
UIKIT_EXTERN NSString *const JA_Event_ClickRequestReply;
/// 确定邀请回复
UIKIT_EXTERN NSString *const JA_Event_RequestReply;
/// 内容审核
UIKIT_EXTERN NSString *const JA_Event_ContentReview;
/// 进入私信页面
UIKIT_EXTERN NSString *const JA_Event_ViewMessagePage;
/// 发送私信
UIKIT_EXTERN NSString *const JA_Event_SendMessage;
/// 举报
UIKIT_EXTERN NSString *const JA_Event_Report;
/// 绑定和解绑
UIKIT_EXTERN NSString *const JA_Event_Binding;
/// 绑定和解绑结果
UIKIT_EXTERN NSString *const JA_Event_BindingSuccess;
/// 获得收入
UIKIT_EXTERN NSString *const JA_Event_GetPay;
/// 申请提现
UIKIT_EXTERN NSString *const JA_Event_ApplyWithdraw;
/// 提现审核
UIKIT_EXTERN NSString *const JA_Event_WithdrawReview;
/// 提现转账
UIKIT_EXTERN NSString *const JA_Event_WithdrawTransfer;
/// 兑换零钱
UIKIT_EXTERN NSString *const JA_Event_Exchange;
/// 邀请好友
UIKIT_EXTERN NSString *const JA_Event_Invite;
/// 唤醒好友
UIKIT_EXTERN NSString *const JA_Event_WakeUpApprentice;
/// 邀请关系达成
UIKIT_EXTERN NSString *const JA_Event_InviteDone;
/// 升级
UIKIT_EXTERN NSString *const JA_Event_Upgrade;
/// 通知到达
UIKIT_EXTERN NSString *const JA_Event_PushArrive;
/// 通知点击
UIKIT_EXTERN NSString *const JA_Event_PushClick;
/// 浏览活动页面
UIKIT_EXTERN NSString *const JA_Event_ViewActivityPage;
/// 参与活动
UIKIT_EXTERN NSString *const JA_Event_TakePartIn;
/// 浏览常见问题
UIKIT_EXTERN NSString *const JA_Event_ViewFAQ;
/// 浏览视频教程
UIKIT_EXTERN NSString *const JA_Event_VideoTutorial;
/// 获得奖励
UIKIT_EXTERN NSString *const JA_Event_WinPrize;
/// 点击播放进度条
UIKIT_EXTERN NSString *const JA_Event_ClickPlayBar;
/// 首页刷新
UIKIT_EXTERN NSString *const JA_Event_Reload;

// v2.4.0新增事件
/// 收藏&取消收藏
UIKIT_EXTERN NSString *const JA_Event_Collect;
/// 不感兴趣
UIKIT_EXTERN NSString *const JA_Event_NoInterest;

// v2.4.1新增事件
/// 关闭欢迎提示音
UIKIT_EXTERN NSString *const JA_Event_ShutUp;

// 2.5.6 新增事件 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
// 三方注册
UIKIT_EXTERN NSString *const JA_Event_ThirdPartRegister;
// 输入验证码
UIKIT_EXTERN NSString *const JA_Event_InputValidationCode;
// 输入密码
UIKIT_EXTERN NSString *const JA_Event_InputPassword;

/// 活动收徒
UIKIT_EXTERN NSString *const JA_Event_ActivityInvitation;

// 2.5.6 新增事件↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

/// 跳转注册/登录
UIKIT_EXTERN NSString *const JA_Event_JumpToRegisterPage;

/*************************神策属性***************************/
/// 是否首日访问 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_IsFirstDay;
/// 是否首次启动 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_IsFirstTime;
/// 是否从后台唤醒 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_ResumeFromBackground;
/// 启动时长 (数值)
UIKIT_EXTERN NSString *const JA_Property_EventDuration;
/// 广告系列名称 (string)
UIKIT_EXTERN NSString *const JA_Property_UtmCampaign;
/// 广告系列来源 (string)
UIKIT_EXTERN NSString *const JA_Property_UtmSource;
/// 广告系列媒介 (string)
UIKIT_EXTERN NSString *const JA_Property_UtmMedium;
/// 广告系列字词 (string)
UIKIT_EXTERN NSString *const JA_Property_UtmTerm;
/// 广告系列内容 (string)
UIKIT_EXTERN NSString *const JA_Property_UtmContent;
/// 页面名称 (string)
UIKIT_EXTERN NSString *const JA_Property_ScreenName;
UIKIT_EXTERN NSString *const JA_Property_ContentName;
/// 页面标题 (string)
UIKIT_EXTERN NSString *const JA_Property_Title;
/// 注册方式 (string:微信，微博，手机号，qq)
UIKIT_EXTERN NSString *const JA_Property_SignUpMethod;
/// 手机号 (string)
UIKIT_EXTERN NSString *const JA_Property_Phone;
/// 是否发送请求 (bool)
UIKIT_EXTERN NSString *const JA_Property_IsSendRequest;
/// 失败原因 (string)
UIKIT_EXTERN NSString *const JA_Property_UnsentReason;
/// 验证码类型 (string)
UIKIT_EXTERN NSString *const JA_Property_CodeType;
/// 登录方式 (string)
UIKIT_EXTERN NSString *const JA_Property_LoginMethod;

/// 活动ID (string)
UIKIT_EXTERN NSString *const JA_Property_ActivityId;
/// 活动名称 (string)
UIKIT_EXTERN NSString *const JA_Property_ActivityTitle;
/// 奖励类型 (string)
UIKIT_EXTERN NSString *const JA_Property_PrizeType;
/// 视频标题 (string)
UIKIT_EXTERN NSString *const JA_Property_VideoTitle;
/// 问题标题 (string)
UIKIT_EXTERN NSString *const JA_Property_QuestionTitle;
/// 活动入口 (string)
UIKIT_EXTERN NSString *const JA_Property_ActivityEntry;
/// 推送内容ID (string)
UIKIT_EXTERN NSString *const JA_Property_PushId;
/// 推送内容标题 (string)
UIKIT_EXTERN NSString *const JA_Property_PushTitle;
/// 推送内容正文 (string)
UIKIT_EXTERN NSString *const JA_Property_PushContent;
/// 当前等级 (string)
UIKIT_EXTERN NSString *const JA_Property_CurrentLevel;
/// 邀请方式 (string)
UIKIT_EXTERN NSString *const JA_Property_InvitationMethod;
/// 邀请人id (string)
UIKIT_EXTERN NSString *const JA_Property_InviterId;
/// 今日汇率 (number)
UIKIT_EXTERN NSString *const JA_Property_TodayRate;
/// 茉莉花数量 (number)
UIKIT_EXTERN NSString *const JA_Property_FlowerAmount;
/// 是否转账成功 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_TransferSucceed;
/// 零钱数量 (number)
UIKIT_EXTERN NSString *const JA_Property_MoneyAmount;
/// 是否通过审核 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_ReviewPass;
/// 货币类型 (string)
UIKIT_EXTERN NSString *const JA_Property_MoneyType;
/// 收入来源 (string)
UIKIT_EXTERN NSString *const JA_Property_IncomeSource;
/// 操作类型 (string)
UIKIT_EXTERN NSString *const JA_Property_BindingType;
/// 账号类型 (string)
UIKIT_EXTERN NSString *const JA_Property_AccountType;
/// 绑定解绑是否成功 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_BindingSucceed;
/// 举报类型 (string)
UIKIT_EXTERN NSString *const JA_Property_ReportType;
/// 举报原因 (string)
UIKIT_EXTERN NSString *const JA_Property_ReportTeason;
/// 帖主ID (string)
UIKIT_EXTERN NSString *const JA_Property_PostId;
/// 帖主昵称 (string)
UIKIT_EXTERN NSString *const JA_Property_PostName;
/// 内容ID (string)
UIKIT_EXTERN NSString *const JA_Property_ContentId;
/// 内容标题 (string)
UIKIT_EXTERN NSString *const JA_Property_ContentTitle;
/// 被私信人ID (string)
UIKIT_EXTERN NSString *const JA_Property_MessageId;
/// 被私信人昵称 (string)
UIKIT_EXTERN NSString *const JA_Property_MessageName;
/// 是否被限制 (string)
UIKIT_EXTERN NSString *const JA_Property_BeLimited;
/// 限制原因 (string)
UIKIT_EXTERN NSString *const JA_Property_LimitedReason;
/// 录音时长 (number)
UIKIT_EXTERN NSString *const JA_Property_RecordDuration;
/// 审核方式 (string)
UIKIT_EXTERN NSString *const JA_Property_ReviewMethod;
/// 审核结果 (string)
UIKIT_EXTERN NSString *const JA_Property_ReviewResult;
/// 内容类别 (string)
UIKIT_EXTERN NSString *const JA_Property_ContentType;
/// 所属频道 (string)
UIKIT_EXTERN NSString *const JA_Property_Category;
///是否匿名 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_Anonymous;
/// 被邀请人id (string)
UIKIT_EXTERN NSString *const JA_Property_BeRequestedId;
/// 被邀请人昵称 (string)
UIKIT_EXTERN NSString *const JA_Property_BeRequestedName;
///关注入口 (string)
UIKIT_EXTERN NSString *const JA_Property_FollowMethod;
/// 分享方式 (string)
UIKIT_EXTERN NSString *const JA_Property_ShareMethod;
/// 跳过方式 (string)
UIKIT_EXTERN NSString *const JA_Property_SkipMethod;
/// 点赞方式 (string)
UIKIT_EXTERN NSString *const JA_Property_LikeMethod;
/// 播放时长 (number)
UIKIT_EXTERN NSString *const JA_Property_PlayDuration;
/// 是否播完 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_PlayAll;
/// 播放方式 (string)
UIKIT_EXTERN NSString *const JA_Property_PlayMethod;
/// bannerID (string)
UIKIT_EXTERN NSString *const JA_Property_BannerId;
/// banner位置 (string)
UIKIT_EXTERN NSString *const JA_Property_BannerPosition;
/// banner名称 (string)
UIKIT_EXTERN NSString *const JA_Property_BannerTitle;
/// 进入页面方式 (string:点击播放进度条/点击帖子卡片）
UIKIT_EXTERN NSString *const JA_Property_GotoMethod;
/// 是否成功发布 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_PostSucceed;
/// 发布方式 (string)
UIKIT_EXTERN NSString *const JA_Property_PostMethod;
/// 是否重录 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_Rerecording;
/// 是否是自动弹出 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_AutoDialog;

/// 关键词 (string)
UIKIT_EXTERN NSString *const JA_Property_Keyword;
/// 搜索结果分类 (string)
UIKIT_EXTERN NSString *const JA_Property_ResultCategory;
/// 是否使用历史词 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_IsHistoryWordUsed;
/// 是否有结果 (BOOL)
UIKIT_EXTERN NSString *const JA_Property_HasResult;

/// 序号 (number)
UIKIT_EXTERN NSString *const JA_Property_SerialNumber;
/// 图片ID (string)
UIKIT_EXTERN NSString *const JA_Property_ImageUrl;
/// 晒收入方式 (string)
UIKIT_EXTERN NSString *const JA_Property_ShareButton;

/// 播放条位置 (string)
UIKIT_EXTERN NSString *const JA_Property_BarPosition;
/// 刷新方式 (string)
UIKIT_EXTERN NSString *const JA_Property_ReloadMethod;

// v2.4.0新增属性
/// 推荐类型
UIKIT_EXTERN NSString *const JA_Property_RecommendType;
UIKIT_EXTERN NSString *const JA_Property_SourcePage;
UIKIT_EXTERN NSString *const JA_Property_SourcePageName;

UIKIT_EXTERN NSString *const JA_Property_WakeUpMethod;


// 2.5.6 新增属性 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

/// 话题id
UIKIT_EXTERN NSString *const JA_Property_TopicId;
/// 话题名称
UIKIT_EXTERN NSString *const JA_Property_topicname;

// 2.5.6 新增属性 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

UIKIT_EXTERN NSString *const JA_Property_storyType;
UIKIT_EXTERN NSString *const JA_Property_blockedReason;
