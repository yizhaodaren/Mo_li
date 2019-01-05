//
//  JASensorsAnalyticsManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASensorsAnalyticsManager.h"
#import "JASwitchDefine.h"

@implementation JASensorsAnalyticsManager

/// 页面浏览统计
+ (void)sensorsAnalytics_browseViewPage:(NSDictionary *)properties
{
//    [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:nil withProperties:properties];   // 2.5.6 取消页面统计
}

/// 事件点击
+ (void)sensorsAnalytics_baseClickEvent:(NSString *)key properties:(NSDictionary *)properties
{
    if (properties) {
        [[SensorsAnalyticsSDK sharedInstance] track:key withProperties:properties];
    }else{
        [[SensorsAnalyticsSDK sharedInstance] track:key];
    }
#ifdef JA_TEST_HOST
    // 测试专用
    // 强制发送数据
    [[SensorsAnalyticsSDK sharedInstance] flush];
#endif
}

+ (void)sensorsAnalytics_baseClickEvent:(NSString *)key
{
    [self sensorsAnalytics_baseClickEvent:key properties:nil];
}

/// 点击搜索框
+ (void)sensorsAnalytics_clickSearch:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_SearchClick properties:properties];
}

/// 发送搜索请求
+ (void)sensorsAnalytics_requestSearch:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_SearchApply properties:properties];
}

/// 点击搜索结果
+ (void)sensorsAnalytics_clickSearchResult:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_SearchResult properties:properties];
}

/// 浏览内容详情页
+ (void)sensorsAnalytics_browseViewControllerDetail:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_ViewContentDetail properties:properties];
}

/// 点击首页banner
+ (void)sensorsAnalytics_clickBanner:(NSDictionary *)properties
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_ClickBanner properties:properties];  // 2.5.6 取消点击首页banner
}

/// 点击邀请回复按钮
+ (void)sensorsAnalytics_clickInvite:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_ClickRequestReply properties:properties];
}
/// 点击确认邀请
+ (void)sensorsAnalytics_InvitePerson:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_RequestReply properties:properties];
}

/// 内容审核
+ (void)sensorsAnalytics_checkContent:(NSDictionary *)properties
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_ContentReview properties:properties];
}

/// 进入私信
+ (void)sensorsAnalytics_enterMessage:(NSDictionary *)properties   // 2.5.6 取消进入私信
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_ViewMessagePage properties:properties];
}

/// 发送私信
+ (void)sensorsAnalytics_sendMessage:(NSDictionary *)properties     // 2.5.6 取消发送私信
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_SendMessage properties:properties];
}

/// 举报
+ (void)sensorsAnalytics_reportPerson:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_Report properties:properties];
}

/// 绑定解绑
+ (void)sensorsAnalytics_bindingOrunBinding:(NSDictionary *)properties
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_BindingSuccess properties:properties];
}

/// 点击绑定解绑
+ (void)sensorsAnalytics_ClickBindingOrunBinding:(NSDictionary *)properties
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_Binding properties:properties];
}

/// 申请提现
+ (void)sensorsAnalytics_withDraw:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_ApplyWithdraw properties:properties];
}

/// 兑换零钱
+ (void)sensorsAnalytics_exchangeMoney:(NSDictionary *)properties   // 2.5.6 取消兑换零钱
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_Exchange properties:properties];
}

/// 邀请好友
+ (void)sensorsAnalytics_inviteFriend:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_Invite properties:properties];
}

/// 唤醒好友
+ (void)sensorsAnalytics_callFriend:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_WakeUpApprentice properties:properties];
}


/// 点击push通知
+ (void)sensorsAnalytics_clickPushContent:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_PushClick properties:properties];
}


/// push通知到达
+ (void)sensorsAnalytics_ReceivePushContent:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_PushArrive properties:properties];
}

/// 浏览常见问题
+ (void)sensorsAnalytics_seeQuestionHelp:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_ViewFAQ properties:properties];
}

/// 浏览视频教程
+ (void)sensorsAnalytics_seevideoHelp:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_VideoTutorial properties:properties];
}

/// 关注用户
+ (void)sensorsAnalytics_followPerson:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_Follow properties:properties];
}


/// 分享
+ (void)sensorsAnalytics_clickShare:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_Share properties:properties];
}

/// 分享收入
+ (void)sensorsAnalytics_clickShareMoney:(NSDictionary *)properties
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_ShareIncome properties:properties];  // 2.5.6 取消分享晒收入
}

/// 点赞
+ (void)sensorsAnalytics_clickAgree:(NSDictionary *)properties
{
//    [self sensorsAnalytics_baseClickEvent:JA_Event_Like properties:properties];   // 2.5.6 取消点赞
}

/// 注册按钮
+ (void)sensorsAnalytics_clickRegist:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_ClickRegister properties:properties];
}

/// 注册验证码按钮
+ (void)sensorsAnalytics_clickRegistCode:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_GetValidationCode properties:properties];
}

/// 首页的刷新
+ (void)sensorsAnalytics_homeRefresh:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_Reload properties:properties];
}

/// 登录
+ (void)sensorsAnalytics_login {
    NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if (userId.length && ![userId isEqualToString:@"(null)"]) {
        [[SensorsAnalyticsSDK sharedInstance] login:userId];
    }
}

// 设置用户属性
+ (void)sensorsAnalytics_setUser {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"gender"] = ([[JAUserInfo userInfo_getUserImfoWithKey:User_Sex] integerValue] == 1)?@"男":@"女";
    params[@"age"] = @([[JAUserInfo userInfo_getUserImfoWithKey:User_Age] intValue]);
    params[@"birthday"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Birthday];
    params[@"last_visit_time"] = [NSDate date];
    params[@"money_balance"] = @([[JAUserInfo userInfo_getUserImfoWithKey:User_IncomeMoney] doubleValue]);// 零钱余额
    params[@"flower_balance"] = @([[JAUserInfo userInfo_getUserImfoWithKey:User_MoliFlowerCount] doubleValue]);// 茉莉花余额
    params[@"Withdrawed_money"] = @([[JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney] doubleValue]);// 已提现金额
    params[@"level"] = @([[JAUserInfo userInfo_getUserImfoWithKey:User_LevelId] intValue]);
    params[@"credit_score"] = @([[JAUserInfo userInfo_getUserImfoWithKey:User_score] doubleValue]);
    NSString *name = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
    params[@"$name"] = name.length?name:@"未获取该用户名";
    params[@"$signup_time"] = [NSDate dateWithTimeIntervalSince1970:([[JAUserInfo userInfo_getUserImfoWithKey:User_CreatTime] doubleValue] / 1000.0)];
    [[[SensorsAnalyticsSDK sharedInstance] people] set:params];
}
//params[@"be_invited"] = ;
//params[@"invitation_source"] = ;
//params[@"inviter_id"] = ;
//params[@"first_Withdraw_time"] = ;

// 设置用户属性
+ (void)sensorsAnalytics_setUser:(JAConsumer *)user {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"gender"] = ([user.sex integerValue] == 1)?@"男":@"女";
    params[@"age"] = @([user.age intValue]);
    params[@"birthday"] = user.birthdayName;
//    params[@"phone"] = (user.phone.length)?user.phone:nil;
//    params[@"last_visit_time"] = [self getCurrentDateString:[NSString getCurrentDateTimeString] formatString:@"yyyy-MM-dd HH:mm:ss.SSS"];
    params[@"last_visit_time"] = [NSDate date];
    params[@"money_balance"] = @([user.incomeMoney doubleValue]);// 零钱余额
    params[@"flower_balance"] = @([user.moliFlowerCount doubleValue]);// 茉莉花余额
    params[@"Withdrawed_money"] = @([user.expenditureMoney doubleValue]);// 已提现金额
    params[@"level"] = @([user.levelId intValue]);
    params[@"credit_score"] = @([user.score doubleValue]);
    params[@"total_sign_in_days"] = @(user.accumulativeSignCount);
    params[@"$name"] = user.name.length?user.name:@"未获取该用户名";
    params[@"$signup_time"] = [NSDate dateWithTimeIntervalSince1970:(user.createTime.doubleValue / 1000.0)];
    NSLog(@"登录神策的用户id:%@ 以及属性%@",[[SensorsAnalyticsSDK sharedInstance] loginId],params);
    [[[SensorsAnalyticsSDK sharedInstance] people] set:params];
}

//+ (NSDate *)getCurrentDateString:(NSString *)dateString formatString:(NSString *)formatString
//{
//    NSDateFormatter *format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:formatString];
//    NSDate *date = [format dateFromString:dateString];
//    return [self worldTimeToChinaTime:date];
//}
//
//+ (NSDate *)worldTimeToChinaTime:(NSDate *)date
//{
//    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
//    NSInteger interval = [timeZone secondsFromGMTForDate:date];
//    NSDate *localeDate = [date  dateByAddingTimeInterval:interval];
//    return localeDate;
//}


/// 开始录音
+ (void)sensorsAnalytics_startRecord:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_StartRecord properties:properties];
}

/// 重录提示
+ (void)sensorsAnalytics_rerecording:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_Rerecording properties:properties];
}

/// 完成录音
+ (void)sensorsAnalytics_endRecord:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_EndRecord properties:properties];
}

/// 放弃录音
+ (void)sensorsAnalytics_dropRecord:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_DropRecord properties:properties];
}

/// 发布帖子
+ (void)sensorsAnalytics_post:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_Post properties:properties];
}

/// 放弃发布
+ (void)sensorsAnalytics_dropPost:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_DropPost properties:properties];
}

/// 开始播放内容
+ (void)sensorsAnalytics_startPlayVoiceModel:(JAVoiceModel *)model method:(NSInteger)method {
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = model.voiceId;
    eventParams[JA_Property_ContentTitle] = model.content;
    eventParams[JA_Property_ContentType] = @"主帖";
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
    eventParams[JA_Property_PostId] = model.userId;
    eventParams[JA_Property_PostName] = model.userName;
    if (method == 0) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";//@"点击进度条上的播放按钮";   // 2.5.6 统一主动播放
    } else if (method == 1) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";//@"点击帖子卡片上的播放按钮";  // 2.5.6 统一主动播放
    } else if (method == 2) {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = model.sourceName;
    eventParams[JA_Property_RecommendType] = model.recommendType;

    [self sensorsAnalytics_baseClickEvent:JA_Event_StartPlay properties:eventParams];
}

+ (void)sensorsAnalytics_startPlayCommentModel:(JAVoiceCommentModel *)model method:(NSInteger)method {
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = model.voiceCommendId;
    eventParams[JA_Property_ContentTitle] = model.content;
    eventParams[JA_Property_ContentType] = @"一级回复";
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
    eventParams[JA_Property_PostId] = model.userId;
    eventParams[JA_Property_PostName] = model.userName;
    if (method == 0) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";//@"点击进度条上的播放按钮";  // 2.5.6 统一主动播放
    } else if (method == 1) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";//@"点击帖子卡片上的播放按钮";  // 2.5.6 统一主动播放
    } else if (method == 2) {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = model.sourceName;
    eventParams[JA_Property_RecommendType] = model.recommendType;
    [self sensorsAnalytics_baseClickEvent:JA_Event_StartPlay properties:eventParams];
}

+ (void)sensorsAnalytics_startPlayReplyModel:(JAVoiceReplyModel *)model method:(NSInteger)method {
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = model.voiceReplyId;
    eventParams[JA_Property_ContentTitle] = model.content;
    eventParams[JA_Property_ContentType] = @"二级回复";
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
    eventParams[JA_Property_PostId] = model.userId;
    eventParams[JA_Property_PostName] = model.userName;
    if (method == 0) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";//@"点击进度条上的播放按钮";  // 2.5.6 统一主动播放
    } else if (method == 1) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";//@"点击帖子卡片上的播放按钮";  // 2.5.6 统一主动播放
    } else if (method == 2) {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = model.sourceName;
    eventParams[JA_Property_RecommendType] = model.recommendType;
    [self sensorsAnalytics_baseClickEvent:JA_Event_StartPlay properties:eventParams];
}

/// 结束播放内容
+ (void)sensorsAnalytics_endPlayVoiceModel:(JAVoiceModel *)model playDuration:(int)playDuration {
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = model.voiceId;
    eventParams[JA_Property_ContentTitle] = model.content;
    eventParams[JA_Property_ContentType] = @"主帖";
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
    eventParams[JA_Property_PostId] = model.userId;
    eventParams[JA_Property_PostName] = model.userName;
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
    if (playDuration < 0) {
        // 播放完成
        eventParams[JA_Property_PlayDuration] = eventParams[JA_Property_RecordDuration];
        eventParams[JA_Property_PlayAll] = @(YES);
    } else {
        eventParams[JA_Property_PlayDuration] = @(playDuration);
        eventParams[JA_Property_PlayAll] = @(NO);
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = model.sourceName;
    eventParams[JA_Property_RecommendType] = model.recommendType;
    // 2.5.6新增
    if (model.playMethod == 1) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";
    } else if (model.playMethod == 0) {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }

    [self sensorsAnalytics_baseClickEvent:JA_Event_StopPlay properties:eventParams];
}

+ (void)sensorsAnalytics_endPlayCommentModel:(JAVoiceCommentModel *)model playDuration:(int)playDuration {
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = model.voiceCommendId;
    eventParams[JA_Property_ContentTitle] = model.content;
    eventParams[JA_Property_ContentType] = @"一级回复";
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
    eventParams[JA_Property_PostId] = model.userId;
    eventParams[JA_Property_PostName] = model.userName;
    if (playDuration < 0) {
        // 播放完成
        eventParams[JA_Property_PlayDuration] = eventParams[JA_Property_RecordDuration];
        eventParams[JA_Property_PlayAll] = @(YES);
    } else {
        eventParams[JA_Property_PlayDuration] = @(playDuration);
        eventParams[JA_Property_PlayAll] = @(NO);
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = model.sourceName;
    eventParams[JA_Property_RecommendType] = model.recommendType;
    // 2.5.6新增
    if (model.playMethod == 1) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";
    } else if (model.playMethod == 0) {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    [self sensorsAnalytics_baseClickEvent:JA_Event_StopPlay properties:eventParams];
}

+ (void)sensorsAnalytics_endPlayReplyModel:(JAVoiceReplyModel *)model playDuration:(int)playDuration {
    NSMutableDictionary *eventParams = [NSMutableDictionary new];
    eventParams[JA_Property_ContentId] = model.voiceReplyId;
    eventParams[JA_Property_ContentTitle] = model.content;
    eventParams[JA_Property_ContentType] = @"二级回复";
    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
    eventParams[JA_Property_PostId] = model.userId;
    eventParams[JA_Property_PostName] = model.userName;
    if (playDuration < 0) {
        // 播放完成
        eventParams[JA_Property_PlayDuration] = eventParams[JA_Property_RecordDuration];
        eventParams[JA_Property_PlayAll] = @(YES);
    } else {
        eventParams[JA_Property_PlayDuration] = @(playDuration);
        eventParams[JA_Property_PlayAll] = @(NO);
    }
    // v2.4.0新增
    eventParams[JA_Property_SourcePage] = model.sourceName;
    eventParams[JA_Property_RecommendType] = model.recommendType;
    // 2.5.6新增
   if (model.playMethod == 1) {
        eventParams[JA_Property_PlayMethod] = @"主动播放";
    } else if (model.playMethod == 0) {
        eventParams[JA_Property_PlayMethod] = @"自动播放";
    }
    
    [self sensorsAnalytics_baseClickEvent:JA_Event_StopPlay properties:eventParams];
}

/// 播放跳过
+ (void)sensorsAnalytics_skipPlayVoiceModel:(JAVoiceModel *)model method:(NSInteger)method {    // 2.5.6 取消跳过
//    NSMutableDictionary *eventParams = [NSMutableDictionary new];
//    eventParams[JA_Property_ContentId] = model.voiceId;
//    eventParams[JA_Property_ContentTitle] = model.content;
//    eventParams[JA_Property_ContentType] = @"主帖";
//    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
//    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
//    eventParams[JA_Property_PostId] = model.userId;
//    eventParams[JA_Property_PostName] = model.userName;
//    if (method == 0) {
//        eventParams[JA_Property_SkipMethod] = @"点击跳过按钮";
//    } else {
//        eventParams[JA_Property_SkipMethod] = @"点击播放下一个";
//    }
//    [self sensorsAnalytics_baseClickEvent:JA_Event_Skip properties:eventParams];
}

+ (void)sensorsAnalytics_skipPlayCommentModel:(JAVoiceCommentModel *)model method:(NSInteger)method {   // 2.5.6 取消跳过
//    NSMutableDictionary *eventParams = [NSMutableDictionary new];
//    eventParams[JA_Property_ContentId] = model.voiceCommendId;
//    eventParams[JA_Property_ContentTitle] = model.content;
//    eventParams[JA_Property_ContentType] = @"一级回复";
//    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
//    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
//    eventParams[JA_Property_PostId] = model.userId;
//    eventParams[JA_Property_PostName] = model.userName;
//    if (method == 0) {
//        eventParams[JA_Property_SkipMethod] = @"点击跳过按钮";
//    } else {
//        eventParams[JA_Property_SkipMethod] = @"点击播放下一个";
//    }
//    [self sensorsAnalytics_baseClickEvent:JA_Event_Skip properties:eventParams];
}

+ (void)sensorsAnalytics_skipPlayReplyModel:(JAVoiceReplyModel *)model method:(NSInteger)method {    // 2.5.6 取消跳过
//    NSMutableDictionary *eventParams = [NSMutableDictionary new];
//    eventParams[JA_Property_ContentId] = model.voiceReplyId;
//    eventParams[JA_Property_ContentTitle] = model.content;
//    eventParams[JA_Property_ContentType] = @"二级回复";
//    eventParams[JA_Property_RecordDuration] = @([NSString getSeconds:model.time]);
//    eventParams[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
//    eventParams[JA_Property_Anonymous] = @(model.isAnonymous);
//    eventParams[JA_Property_PostId] = model.userId;
//    eventParams[JA_Property_PostName] = model.userName;
//    if (method == 0) {
//        eventParams[JA_Property_SkipMethod] = @"点击跳过按钮";
//    } else {
//        eventParams[JA_Property_SkipMethod] = @"点击播放下一个";
//    }
//    [self sensorsAnalytics_baseClickEvent:JA_Event_Skip properties:eventParams];
}

/// 点击播放进度条
+ (void)sensorsAnalytics_clickPlayBarWithType:(NSInteger)type {      // 2.5.6 取消点击播放进度条
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    if (type == 0) {
//        params[JA_Property_BarPosition] = @"首页";
//    } else if (type == 1) {
//        params[JA_Property_BarPosition] = @"详情页";
//    }
//    [self sensorsAnalytics_baseClickEvent:JA_Event_ClickPlayBar properties:params];
}

// v2.4.0新增
/// 收藏&取消收藏
+ (void)sensorsAnalytics_collect:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_Collect properties:properties];
}

/// 不感兴趣
+ (void)sensorsAnalytics_noInterest:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_NoInterest properties:properties];
}

// v2.4.1新增
/// 关闭欢迎提示音
+ (void)sensorsAnalytics_shutUp:(NSDictionary *)properties {     // 2.5.6 取消关闭提示音
//    [self sensorsAnalytics_baseClickEvent:JA_Event_ShutUp];
}

// 2.5.6 新增统计 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
// 三方注册
+ (void)sensorsAnalytics_ThirdPartRegister:(NSDictionary *)properties //
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_ThirdPartRegister properties:properties];
}
// 输入验证码
+ (void)sensorsAnalytics_InputValidationCode:(NSDictionary *)properties //
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_InputValidationCode properties:properties];
}
// 输入密码
+ (void)sensorsAnalytics_InputPassword:(NSDictionary *)properties //
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_InputPassword properties:properties];
}

/// 活动收徒
+ (void)sensorsAnalytics_shareActivity:(NSDictionary *)properties {
    [self sensorsAnalytics_baseClickEvent:JA_Event_ActivityInvitation properties:properties];
}

// 2.5.6 新增统计 ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑


/// 跳转注册/登录页面
+ (void)sensorsAnalytics_jumpRegistOrLoginPage:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_JumpToRegisterPage properties:properties];
}

/// 注册页面浏览统计
+ (void)sensorsAnalytics_registPagebrowseViewPage:(NSDictionary *)properties
{
    [[SensorsAnalyticsSDK sharedInstance] trackViewScreen:nil withProperties:properties];
}


/// 开始播放 - 新逻辑
+ (void)sensorsAnalytics_startPlay:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_StartPlay properties:properties];
}

/// 停止播放 - 新逻辑
+ (void)sensorsAnalytics_stopPlay:(NSDictionary *)properties
{
    [self sensorsAnalytics_baseClickEvent:JA_Event_StopPlay properties:properties];
}
@end
