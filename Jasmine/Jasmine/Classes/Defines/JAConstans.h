//
//  JAConstans.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 播放器通知
UIKIT_EXTERN NSString *const JAPlayNotification;

/// 茉莉官方数量key 及 收到茉莉官方后发的通知名
UIKIT_EXTERN NSString *const moliOfficCount;
/// 通知数量key 及 收到通知后发的通知名
UIKIT_EXTERN NSString *const moliNewNotiCount;
UIKIT_EXTERN NSString *const moliNewNotiComment;
UIKIT_EXTERN NSString *const moliNewNotiAnswer;
UIKIT_EXTERN NSString *const moliNewNotiAgree;
UIKIT_EXTERN NSString *const moliNewNotiFans;
UIKIT_EXTERN NSString *const moliNewNotiInvite;

/// 通知数量key 及 收到通知后发的通知名 - newBranch
UIKIT_EXTERN NSString *const branchNewNoti;
UIKIT_EXTERN NSString *const branchNewNotiReply;
UIKIT_EXTERN NSString *const branchNewNotiAgree;
UIKIT_EXTERN NSString *const branchNewNotiInvite;
UIKIT_EXTERN NSString *const branchNewNotiFocus;

/// 草稿
UIKIT_EXTERN NSString *const branchNewDraft;
// @某人
UIKIT_EXTERN NSString *const branchNewCallPerson;
// 公告
UIKIT_EXTERN NSString *const branchNewAnnouncement;

/// 有新的活动
UIKIT_EXTERN NSString *const branchNewActivity;

/// 有签到
UIKIT_EXTERN NSString *const branchNewSign;

/// 默认查询数量
UIKIT_EXTERN NSString *const selectCount;

/// 需要签到否 （这个通知是为了在左边栏的时候点击了签到）
UIKIT_EXTERN NSString *const NEED_SIGN;

/// 需要注册
UIKIT_EXTERN NSString *const NEED_Regist;
UIKIT_EXTERN NSString *const NEED_PERFECT;

UIKIT_EXTERN NSString *const PlatformLoginSuccess;
UIKIT_EXTERN NSString *const PlatformRegistSuccess;

// 登录成功的通知
UIKIT_EXTERN NSString *const LOGINSUCCESS;
/// 签到成功
UIKIT_EXTERN NSString *const SIGNSUCCESS;
/// 编辑个人资料成功
UIKIT_EXTERN NSString *const EDITUSERINFOSUCCESS;
// 启动配置接口更新
UIKIT_EXTERN NSString *const DATACLIENTUPDATE;

/// 超级管理员
UIKIT_EXTERN NSString *const User_Admin;

/// 用户是否登录 KEY
UIKIT_EXTERN NSString *const User_LoginState;

/// 是否绑定邀请码
UIKIT_EXTERN NSString *const User_InviteUuid;

/// 用户三方登录UID
UIKIT_EXTERN NSString *const User_PlatformUid;
UIKIT_EXTERN NSString *const User_PlatformQQUid;
UIKIT_EXTERN NSString *const User_PlatformWXUid;
UIKIT_EXTERN NSString *const User_PlatformWBUid;

UIKIT_EXTERN NSString *const User_PlatformWXName;
UIKIT_EXTERN NSString *const User_PlatformWBName;
UIKIT_EXTERN NSString *const User_PlatformQQName;

UIKIT_EXTERN NSString *const User_PlatformWXTixian;
UIKIT_EXTERN NSString *const User_PlatformType;
/// 用户accessToken
UIKIT_EXTERN NSString *const User_AccessToken;
/// 保存本地时间-服务器当前时间的值
UIKIT_EXTERN NSString *const User_DisTime;
/// 获取accessToken的服务器时间
UIKIT_EXTERN NSString *const User_AccessTokenServerTime;
/// 创建时间
UIKIT_EXTERN NSString *const User_CreatTime;
/// 用户名
UIKIT_EXTERN NSString *const User_Name;
/// 用户生日
UIKIT_EXTERN NSString *const User_Birthday;
/// 用户生日时间戳
UIKIT_EXTERN NSString *const User_BirthdayTime;
/// 点赞数
UIKIT_EXTERN NSString *const User_agree;
/// 用户年龄
UIKIT_EXTERN NSString *const User_Age;
/// 用户星座
UIKIT_EXTERN NSString *const User_Constellation;
/// 用户地址
UIKIT_EXTERN NSString *const User_Address;
/// 用户电话
UIKIT_EXTERN NSString *const User_Phone;
/// 用户密码
UIKIT_EXTERN NSString *const User_Pwd;
/// 用户头像
UIKIT_EXTERN NSString *const User_ImageUrl;
/// 用户性别
UIKIT_EXTERN NSString *const User_Sex;
/// 用户等级
UIKIT_EXTERN NSString *const User_LevelId;
/// 用户工作
UIKIT_EXTERN NSString *const User_Job;
/// 用户成就
UIKIT_EXTERN NSString *const User_AchievementId;
/// 用户个人介绍
UIKIT_EXTERN NSString *const User_Introduce;
/// 用户经度
UIKIT_EXTERN NSString *const User_Longitude;
/// 用户维度
UIKIT_EXTERN NSString *const User_Latitude;
/// 用户花多数
UIKIT_EXTERN NSString *const User_FlowerCount;
/// 用户关注的人数
UIKIT_EXTERN NSString *const User_userConsernCount;
/// 用户被关注的人数
UIKIT_EXTERN NSString *const User_concernUserCount;
/// 用户问题个数
UIKIT_EXTERN NSString *const User_problemCount;
/// 用户回答个数
UIKIT_EXTERN NSString *const User_answerCount;
/// 用户收藏个数
UIKIT_EXTERN NSString *const User_collentCount;
/// 用户发表个数
UIKIT_EXTERN NSString *const User_publishCount;
/// 用户说说个数
UIKIT_EXTERN NSString *const User_speakCount;
/// 用户故事个数
UIKIT_EXTERN NSString *const User_storyCount;
/// 用户回复个数
UIKIT_EXTERN NSString *const User_commentCount;
/// 用户信用值
UIKIT_EXTERN NSString *const User_score;
/// 用户id
UIKIT_EXTERN NSString *const User_id;
/// 用户uuid
UIKIT_EXTERN NSString *const User_uuid;
/// 用户茉莉花
UIKIT_EXTERN NSString *const User_MoliFlowerCount;
/// 用户零钱
UIKIT_EXTERN NSString *const User_IncomeMoney;
UIKIT_EXTERN NSString *const User_expenditureMoney;

/// 用户状态：0正常，1封禁，2禁言
UIKIT_EXTERN NSString *const User_Status;
/// 禁言到期时间
UIKIT_EXTERN NSString *const User_ValidTime;

/// 当前经验值
UIKIT_EXTERN NSString *const User_LevelScore;
/// 下一级经验值
UIKIT_EXTERN NSString *const User_TopScore;

/// 用户头衔名字
UIKIT_EXTERN NSString *const User_markName;
/// 用户头衔图片
UIKIT_EXTERN NSString *const User_markImage;
/// 用户勋章列表
UIKIT_EXTERN NSString *const User_medalList;
/// 用户佩戴勋章
UIKIT_EXTERN NSString *const User_medalImage;

/// 客服信息
UIKIT_EXTERN NSString *const app_customerInfo;
/// 客服通知
UIKIT_EXTERN NSString *const app_offic;

///数据类型:问题、答案、用户、文章、话题、动态、评论
UIKIT_EXTERN NSString *const JA_PROBLEM_TYPE;
UIKIT_EXTERN NSString *const JA_ANSWER_TYPE;
UIKIT_EXTERN NSString *const JA_USER_TYPE;
UIKIT_EXTERN NSString *const JA_PUBLISH_TYPE;
UIKIT_EXTERN NSString *const JA_TOPIC_TYPE;
UIKIT_EXTERN NSString *const JA_DYNAMIC_TYPE;
UIKIT_EXTERN NSString *const JA_STORY_TYPE;
UIKIT_EXTERN NSString *const JA_COMMENT_TYPE;
UIKIT_EXTERN NSString *const JA_REPLY_TYPE;

/// 茉莉通知的云信ID
UIKIT_EXTERN NSString *const JA_OFFIC_SERVERMOLI;

/// 上次的登录状态
UIKIT_EXTERN NSString *const JA_LOGIN_RECORDTYPE;

/// -------------------------------------

/// 详情页 主帖字号
UIKIT_EXTERN CGFloat const JA_CommentDetail_voiceFont;

/// 详情页 评论字号
UIKIT_EXTERN CGFloat const JA_CommentDetail_commentFont;

/// 详情页 评论-回复字号
UIKIT_EXTERN CGFloat const JA_CommentDetail_replyFont;

/// 回复详情页 头部评论字号
UIKIT_EXTERN CGFloat const JA_replyDetail_commentFont;

/// 回复详情页 回复字号
UIKIT_EXTERN CGFloat const JA_replyDetail_replyFont;

/// 详情页 评论-回复的人字号
UIKIT_EXTERN CGFloat const JA_PersonalDetail_replyPersonalFont;

/// 详情页 评论的人字号
UIKIT_EXTERN CGFloat const JA_PersonalDetail_commentPersonalFont;

/// 录音解析文字时长
UIKIT_EXTERN CGFloat const JA_IFLY_Time;

/// 输入文字长度
UIKIT_EXTERN NSInteger const JA_ReplyInput_words;
