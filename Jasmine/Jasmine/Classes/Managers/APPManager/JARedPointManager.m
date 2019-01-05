//
//  JARedPointManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARedPointManager.h"
#define kMyId [JAUserInfo userInfo_getUserImfoWithKey:User_id]

@implementation JARedPointManager

#pragma mark - 获取红点数目
+ (NSInteger)getRedPointNumber:(NSInteger)binary
{
    NSInteger homePageFocus = 0;
    NSInteger activity = 0;
    NSInteger message = 0;
    NSInteger noti_reply = 0;
    NSInteger noti_agree = 0;
    NSInteger noti_invite = 0;
    NSInteger noti_focus = 0;
    NSInteger draft = 0;
    NSInteger callP = 0;
    NSInteger announcementNum = 0;
    
    if (binary & JARedPointTypeHomePageFocus) {
        
        homePageFocus = [self getRedPointNumWithKey:@"FocusKey"];
        
        return homePageFocus;
    }
    if (binary & JARedPointTypeActivity){
        
        activity = [self getRedPointNumWithKey:branchNewActivity];
        
        return activity;
    }
    if (binary & JARedPointTypeMessage){
        
        // 获取会话的未读数量
        NSInteger chatCount = [[NIMSDK sharedSDK].conversationManager allUnreadCount];
        // 获取客服的未读数量
        QYSessionInfo *messageSession =  [[[QYSDK sharedSDK] conversationManager] getSessionList].firstObject;
        NSInteger kefuCount = messageSession.unreadCount;
        
        message = kefuCount + chatCount;
        
        return message;
    }
    if (binary & JARedPointTypeNoti_Reply){
        
        noti_reply = [self getRedPointNumWithKey:branchNewNotiReply];
        
        return noti_reply;
    }
    if (binary & JARedPointTypeNoti_Agree){
        
        noti_agree = [self getRedPointNumWithKey:branchNewNotiAgree];
        
        return noti_agree;
    }
    if (binary & JARedPointTypeNoti_Invite){
        
        noti_invite = [self getRedPointNumWithKey:branchNewNotiInvite];
        
        return noti_invite;
    }
    if (binary & JARedPointTypeNoti_Focus){
        
        noti_focus = [self getRedPointNumWithKey:branchNewNotiFocus];
        
        return noti_focus;
    }
    
    if (binary & JARedPointTypeDraft) {
        
        draft = [self getRedPointNumWithKey:branchNewDraft];
        
        return draft;
    }
    
    if (binary & JARedPointTypeCallPerson) {
        
        callP = [self getRedPointNumWithKey:branchNewCallPerson];
        
        return callP;
    }
    
    if (binary & JARedPointTypeAnnouncement) {
        
        announcementNum = [self getRedPointNumWithKey:branchNewAnnouncement];
        
        return announcementNum;
    }
    
    return 0;
}

#pragma mark - 检查红点
/// 检查红点
+ (BOOL)checkRedPoint:(NSInteger)binary
{
    BOOL homePageFocus = NO;
    BOOL activity = NO;
    BOOL message = NO;
    BOOL noti_reply = NO;
    BOOL noti_agree = NO;
    BOOL noti_invite = NO;
    BOOL noti_focus = NO;
    BOOL draft = NO;
    BOOL callP = NO;
    BOOL announcement = NO;
    
    if (binary & JARedPointTypeHomePageFocus) {
        homePageFocus = [self homePageFocusRedPoint];
    }
    if (binary & JARedPointTypeActivity){
        activity = [self activityRedPoint];
    }
    if (binary & JARedPointTypeMessage){
        message = [self messageRedPoint];
    }
    if (binary & JARedPointTypeNoti_Reply){
        noti_reply = [self noti_replyRedPoint];
    }
    if (binary & JARedPointTypeNoti_Agree){
        noti_agree = [self noti_agreeRedPoint];
    }
    if (binary & JARedPointTypeNoti_Invite){
        noti_invite = [self noti_inviteRedPoint];
    }
    if (binary & JARedPointTypeNoti_Focus){
        noti_focus = [self noti_focusRedPoint];
    }
    
    if (binary & JARedPointTypeDraft) {
        draft = [self draftRedPoint];
    }
    
    if (binary & JARedPointTypeCallPerson) {
        callP = [self callPersonRedPoint];
    }
    
    if (binary & JARedPointTypeAnnouncement) {
        announcement = [self announcementRedPoint];
    }
    
    return homePageFocus || activity || message || noti_reply || noti_agree || noti_invite || noti_focus || draft || callP || announcement;
}

#pragma mark - 红点到达
/// 红点到达
+ (void)hasNewRedPointArrive:(JARedPointType)type
{
    switch (type) {
        case JARedPointTypeHomePageFocus:
        {
            NSString *key = [NSString stringWithFormat:@"%@_FocusKey",kMyId];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:@"FocusKey"];
        }
            break;
        case JARedPointTypeActivity:
        {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:branchNewActivity];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewActivity];
        }
            break;
        case JARedPointTypeMessage:
        {
            
        }
            break;
        case JARedPointTypeNoti_Reply:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiReply];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewNotiReply];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Noti_Reply_Arrive" object:nil];
        }
            break;
        case JARedPointTypeNoti_Agree:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiAgree];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewNotiAgree];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Noti_Agree_Arrive" object:nil];
        }
            break;
        case JARedPointTypeNoti_Invite:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiInvite];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewNotiInvite];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Noti_Invite_Arrive" object:nil];
        }
            break;
        case JARedPointTypeNoti_Focus:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiFocus];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewNotiFocus];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Noti_Focus_Arrive" object:nil];
        }
            break;
        case JARedPointTypeDraft:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewDraft];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewDraft];
        }
            break;
            
        case JARedPointTypeCallPerson:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewCallPerson];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewCallPerson];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"Noti_CallPerson_Arrive" object:nil];
        }
            break;
            
        case JARedPointTypeAnnouncement:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewAnnouncement];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self caculatorRedPointNum:branchNewAnnouncement];
        }
            break;
        default:
            break;
    }
    
    // 红点的通知
    [[NSNotificationCenter defaultCenter] postNotificationName:@"redPointArrive" object:nil];
    
}


#pragma mark - 重置红点
/// 重置红点
+ (void)resetNewRedPointArrive:(JARedPointType)type
{
    switch (type) {
        case JARedPointTypeHomePageFocus:
        {
            NSString *key = [NSString stringWithFormat:@"%@_FocusKey",kMyId];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:@"FocusKey"];
        }
            break;
        case JARedPointTypeActivity:
        {
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:branchNewActivity];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewActivity];
        }
            break;
        case JARedPointTypeMessage:
        {
            
        }
            break;
        case JARedPointTypeNoti_Reply:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiReply];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewNotiReply];
        }
            break;
        case JARedPointTypeNoti_Agree:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiAgree];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewNotiAgree];
        }
            break;
        case JARedPointTypeNoti_Invite:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiInvite];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewNotiInvite];
        }
            break;
        case JARedPointTypeNoti_Focus:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiFocus];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewNotiFocus];
        }
            break;
        case JARedPointTypeDraft:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewDraft];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewDraft];
        }
            break;
        case JARedPointTypeCallPerson:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewCallPerson];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewCallPerson];
        }
            break;
        case JARedPointTypeAnnouncement:
        {
            NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewAnnouncement];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:key];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self cleanRedPointNum:branchNewAnnouncement];
        }
            break;
        default:
            break;
    }
    
    // 红点的消失
    [[NSNotificationCenter defaultCenter] postNotificationName:@"redPointDismiss" object:nil];
    
}


#pragma mark - 计算红点数目  此处的key是字符串常量
// 根据key 存储红点数目
+ (void)caculatorRedPointNum:(NSString *)key
{
    NSString *keyNum = [NSString stringWithFormat:@"%@_%@_num",kMyId,key];
    if ([key isEqualToString:branchNewActivity]) {
        keyNum = [NSString stringWithFormat:@"%@_num",branchNewActivity];
    }
    // 获取红点数目
    NSInteger num = [[NSUserDefaults standardUserDefaults] integerForKey:keyNum];
    // 数目+ 1
    num = num + 1;
    // 存储红点
    [[NSUserDefaults standardUserDefaults] setInteger:num forKey:keyNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+ (NSInteger)getRedPointNumWithKey:(NSString *)key
{
    NSString *keyNum = [NSString stringWithFormat:@"%@_%@_num",kMyId,key];
    if ([key isEqualToString:branchNewActivity]) {
        keyNum = [NSString stringWithFormat:@"%@_num",branchNewActivity];;
    }
    
    // 获取红点数目
    NSInteger num = [[NSUserDefaults standardUserDefaults] integerForKey:keyNum];
    
    return num;
}

// 根据key 清除红点数目
+ (void)cleanRedPointNum:(NSString *)key
{
    NSString *keyNum = [NSString stringWithFormat:@"%@_%@_num",kMyId,key];
    if ([key isEqualToString:branchNewActivity]) {
        keyNum = [NSString stringWithFormat:@"%@_num",branchNewActivity];;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:keyNum];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - 红点是否有值

/// 是否有首页关注红点
+ (BOOL)homePageFocusRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_FocusKey",kMyId];
    BOOL hasNewFocus = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (hasNewFocus) {
        return YES;
    }
    return NO;
}

/// 是否有活动红点
+ (BOOL)activityRedPoint
{
    BOOL activityBool = [[NSUserDefaults standardUserDefaults] boolForKey:branchNewActivity];
    
    if (activityBool) {
        return YES;
    }
    return NO;
}

/// 是否有私信红点
+ (BOOL)messageRedPoint
{
    // 获取会话的未读数量
    NSInteger chatCount = [[NIMSDK sharedSDK].conversationManager allUnreadCount];
    // 获取客服的未读数量
    QYSessionInfo *message =  [[[QYSDK sharedSDK] conversationManager] getSessionList].firstObject;
    NSInteger kefuCount = message.unreadCount;
    
    if (chatCount > 0 || kefuCount > 0) {
        return YES;
    }
    return NO;
}

/// 是否有通知 - 回复红点
+ (BOOL)noti_replyRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiReply];
    BOOL notiCommentBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (notiCommentBool) {
        return YES;
    }
    return NO;
}

/// 是否通知 - 点赞红点
+ (BOOL)noti_agreeRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiAgree];
    BOOL notiCommentBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (notiCommentBool) {
        return YES;
    }
    return NO;
}

/// 是否有通知 - 邀请红点
+ (BOOL)noti_inviteRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiInvite];
    BOOL notiCommentBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (notiCommentBool) {
        return YES;
    }
    return NO;
}

/// 是否有通知 - 关注关注红点
+ (BOOL)noti_focusRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewNotiFocus];
    BOOL notiCommentBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (notiCommentBool) {
        return YES;
    }
    return NO;
}

/// 是否有草稿
+ (BOOL)draftRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewDraft];
    BOOL draftBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (draftBool) {
        return YES;
    }
    return NO;
}

// 是否有被@
+ (BOOL)callPersonRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewCallPerson];
    BOOL callBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (callBool) {
        return YES;
    }
    return NO;
}


// 是否有公告
+ (BOOL)announcementRedPoint
{
    NSString *key = [NSString stringWithFormat:@"%@_%@",kMyId,branchNewAnnouncement];
    BOOL announcementBool = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (announcementBool) {
        return YES;
    }
    return NO;
}
@end
