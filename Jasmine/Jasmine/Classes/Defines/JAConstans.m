//
//  JAConstans.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAConstans.h"

/// 播放器通知
NSString *const JAPlayNotification = @"JAPlayNotification";

/// 茉莉官方通知数量key
NSString *const moliOfficCount = @"moliOfficCount";
/// 通知数量key 及 收到通知后发的通知名
NSString *const moliNewNotiCount = @"moliNewNotiCount";
NSString *const moliNewNotiComment = @"moliNewNotiComment";
NSString *const moliNewNotiAnswer = @"moliNewNotiAnswer";
NSString *const moliNewNotiAgree = @"moliNewNotiAgree";
NSString *const moliNewNotiFans = @"moliNewNotiFans";
NSString *const moliNewNotiInvite = @"moliNewNotiInvite";

/// 通知数量key 及 收到通知后发的通知名 - newBranch
NSString *const branchNewNoti = @"branchNewNoti";
NSString *const branchNewNotiReply = @"branchNewNotiReply";
NSString *const branchNewNotiAgree = @"branchNewNotiAgree";
NSString *const branchNewNotiInvite = @"branchNewNotiInvite";
NSString *const branchNewNotiFocus = @"branchNewNotiFocus";

/// 草稿
NSString *const branchNewDraft = @"branchNewDraft";
// @某人
NSString *const branchNewCallPerson = @"branchNewCallPerson";
// 公告
NSString *const branchNewAnnouncement = @"branchNewAnnouncement";

/// 有新的活动
NSString *const branchNewActivity = @"branchNewActivity";

/// 有签到
NSString *const branchNewSign = @"branchNewSign";
/// 默认查询数量
NSString *const selectCount = @"30";

/// 需要签到否
NSString *const NEED_SIGN = @"NEED_SIGN";

/// 需要注册
NSString *const NEED_Regist = @"NEED_Regist";
NSString *const NEED_PERFECT = @"NEED_PERFECT";

NSString *const PlatformLoginSuccess = @"PlatformLogin";    // 三方登录成功（作用：用于dimiss控制器)
NSString *const PlatformRegistSuccess = @"PlatformRegist";  // 暂时没用
NSString *const User_LoginState = @"User_LoginState";      // 设置用户的登录状态

// 登录成功
NSString *const LOGINSUCCESS = @"loginSuccess";     // 登录成功的通知
// 签到成功
NSString *const SIGNSUCCESS = @"signSuccess";
/// 编辑个人资料成功
NSString *const EDITUSERINFOSUCCESS = @"changeUserInfo";
// 启动配置接口更新
NSString *const DATACLIENTUPDATE = @"dataClientUpdate";

/// 超级管理员
NSString *const User_Admin = @"User_Admin";


/// 是否绑定邀请码
NSString *const User_InviteUuid = @"User_InviteUuid";

/// 用户三方登录UID   platformWbName
NSString *const User_PlatformUid = @"User_PlatformUid";
NSString *const User_PlatformQQUid = @"User_PlatformQQUid";
NSString *const User_PlatformWXUid = @"User_PlatformWXUid";
NSString *const User_PlatformWBUid = @"User_PlatformWBUid";

NSString *const User_PlatformWXName = @"User_PlatformWXName";
NSString *const User_PlatformWBName = @"User_PlatformWBName";
NSString *const User_PlatformQQName = @"User_PlatformQQName";

NSString *const User_PlatformWXTixian = @"User_platformWXTixian";
NSString *const User_PlatformType = @"User_PlatformType";
/// 用户accessToken
 NSString *const User_AccessToken = @"User_AccessToken";
/// 保存本地时间-服务器当前时间的值
NSString *const User_DisTime = @"User_DisTime";
/// 获取accessToken的服务器时间
NSString *const User_AccessTokenServerTime = @"User_AccessTokenServerTime";
/// 创建时间
NSString *const User_CreatTime = @"User_CreatTime";
/// 用户名
NSString *const User_Name = @"User_Name";
/// 用户生日
NSString *const User_Birthday = @"User_Birthday";
/// 用户生日时间戳
NSString *const User_BirthdayTime = @"User_BirthdayTime";
/// 点赞数
NSString *const User_agree = @"User_agree";
/// 用户年龄
NSString *const User_Age = @"User_Age";
/// 用户星座
NSString *const User_Constellation = @"User_Constellation";
/// 用户地址
NSString *const User_Address = @"User_Address";
/// 用户电话
NSString *const User_Phone = @"User_Phone";
/// 用户密码
NSString *const User_Pwd = @"User_Pwd";
/// 用户头像
NSString *const User_ImageUrl = @"User_ImageUrl";
/// 用户性别
NSString *const User_Sex = @"User_Sex";
/// 用户等级
NSString *const User_LevelId = @"User_LevelId";
/// 用户工作
NSString *const User_Job = @"User_Job";
/// 用户成就
NSString *const User_AchievementId = @"User_AchievementId";
/// 用户个人介绍
NSString *const User_Introduce = @"User_Introduce";
/// 用户经度
NSString *const User_Longitude = @"User_Longitude";
/// 用户维度
NSString *const User_Latitude = @"User_Latitude";
/// 用户花多数
NSString *const User_FlowerCount = @"User_FlowerCount";
/// 用户关注的人数
NSString *const User_userConsernCount = @"User_userConsernCount";
/// 用户被关注的人数
NSString *const User_concernUserCount = @"User_concernUserCount";
/// 用户问题个数
NSString *const User_problemCount = @"User_problemCount";
/// 用户回答个数
NSString *const User_answerCount = @"User_answerCount";
/// 用户收藏个数
NSString *const User_collentCount = @"User_collentCount";
/// 用户发表个数
NSString *const User_publishCount = @"User_publishCount";
/// 用户说说个数
NSString *const User_speakCount = @"User_speakCount";
/// 用户故事个数
NSString *const User_storyCount = @"User_storyCount";
/// 用户回复个数
NSString *const User_commentCount = @"User_commentCount";
/// 用户积分
NSString *const User_score = @"User_score";
/// 用户id
NSString *const User_id = @"User_id";
/// 用户uuid
NSString *const User_uuid = @"User_uuid";
/// 用户茉莉花
NSString *const User_MoliFlowerCount = @"User_MoliFlowerCount";
/// 用户零钱
NSString *const User_IncomeMoney = @"User_IncomeMoney";
/// 用户提现
NSString *const User_expenditureMoney = @"User_expenditureMoney";

/// 用户状态：0正常，1封禁，2禁言
NSString *const User_Status = @"User_Status";
/// 禁言到期时间
NSString *const User_ValidTime = @"User_ValidTime";

/// 当前经验值
NSString *const User_LevelScore = @"User_LevelScore";
/// 下一级的经验值
NSString *const User_TopScore = @"User_TopScore";

/// 用户头衔名字
NSString *const User_markName = @"User_markName";
/// 用户头衔图片
NSString *const User_markImage = @"User_markImage";
/// 用户勋章列表
NSString *const User_medalList = @"User_medalList";
/// 用户佩戴勋章
NSString *const User_medalImage = @"User_medalImage";

/// 客服信息
NSString *const app_customerInfo = @"app_customerInfo";
/// 客服通知
NSString *const app_offic = @"app_offic";

///数据类型:问题、答案、用户、文章、动态、故事、评论
NSString *const JA_PROBLEM_TYPE = @"problem";
NSString *const JA_ANSWER_TYPE = @"answer";
NSString *const JA_USER_TYPE = @"user";
NSString *const JA_PUBLISH_TYPE = @"publish";
NSString *const JA_TOPIC_TYPE = @"topic";
NSString *const JA_DYNAMIC_TYPE = @"dynamic";
NSString *const JA_STORY_TYPE = @"story";
NSString *const JA_COMMENT_TYPE = @"comment";
NSString *const JA_REPLY_TYPE = @"reply";

/// 茉莉通知的云信ID
NSString *const JA_OFFIC_SERVERMOLI = @"servermoli";

/// 上次的登录状态
NSString *const JA_LOGIN_RECORDTYPE = @"JA_LOGIN_RECORDTYPE";

/// -------------------------------------

/// 详情页 主帖字号
CGFloat const JA_CommentDetail_voiceFont = 18;

/// 详情页 评论字号
CGFloat const JA_CommentDetail_commentFont = 16;

/// 详情页 评论-回复字号
CGFloat const JA_CommentDetail_replyFont = 14;

/// 回复详情页 头部评论字号
CGFloat const JA_replyDetail_commentFont = 15;

/// 回复详情页 回复字号
CGFloat const JA_replyDetail_replyFont = 15;

/// 详情页 评论的人字号(这个表示大的字号)
CGFloat const JA_PersonalDetail_commentPersonalFont = 14;

/// 详情页 评论-回复的人字号(这个表示小的字号)
CGFloat const JA_PersonalDetail_replyPersonalFont = 14;

/// 录音解析文字时长
CGFloat const JA_IFLY_Time = 30;

/// 输入文字长度
NSInteger const JA_ReplyInput_words = 140;
