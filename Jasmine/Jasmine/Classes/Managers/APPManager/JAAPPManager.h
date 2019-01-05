//
//  JAAPPManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/10.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JALevelModel.h"
#import "JARuleWordModel.h"

typedef NS_ENUM(NSUInteger, JAChatLimitsType) {
    JAChatLimitsTypeFriend = 0,     // 好友
    JAChatLimitsTypeFirstNewChat,    //  第一次新建会话
    JAChatLimitsTypeSameChat,       // 同一个人新建会话
    JAChatLimitsTypeReply,          // 回复某人
    JAChatLimitsTypeNot,            // 不能聊天
};

@interface JAAPPManager : NSObject
/// 弹出登录框
+ (void)app_modalLogin;

// 弹出注册
+ (void)app_modalRegist;

// 强制退出
+ (void)app_loginOut;


+ (BOOL)isConnect;

/// 登陆成功 登录方式 0 手机 1 qq 2 wx 3 wb
+ (void)app_loginSuccessWithResult:(NSDictionary *)result loginType:(NSInteger)type;

// APP 启动
+ (void)appFirstStart;

// 是否首次启动
+ (BOOL)isFirstStartApp;

// 内部账户逻辑判断
+ (void)companyPersonnelAccount;

/// 登陆成功
//+ (void)app_loginSuccessWithResult:(NSDictionary *)result;

// 保存AccessToken和ServerTime
+ (void)saveAccessTokenAndTime:(NSDictionary *)dictionary;

/// 检查是否被禁言
+ (BOOL)app_checkGag;
/// 检查该等级是否还能发帖
+ (BOOL)app_checkCanReleaseStory;

/**************************** app状态 ****************************/
/// 是否为第一次打开app
+ (BOOL)isFirstOpenThisAPP;
/// 是否展示引导页
+ (BOOL)isShowUserGuideLoad;
/// 是否弹出标签页
+ (BOOL)isShowLabelsVC;


/**************************** 奖励弹窗 ****************************/
+ (void)app_awardMaskToast:(NSString *)type flower:(id)flowerNum showText:(NSString *)name;

/**************************** 波形图颜色 ****************************/
+ (NSString *)app_waveViewBgImageViewWithType:(int)type;
+ (NSDictionary *)app_waveViewColorWithType:(int)type;

/*******等级逻辑*********/
/// 发帖数
+ (void)app_getReleaseStoryCount;
+ (JALevelModel *)currentLevel; // 等级权限
+ (JARuleModel *)currentNotDepositScore; // 无法提现
+ (JARuleModel *)currentUserMsgScore; // 无法发送私信
+ (JARuleModel *)currentAddStoryCommentScore; // 无法发送主帖、回复

@end
