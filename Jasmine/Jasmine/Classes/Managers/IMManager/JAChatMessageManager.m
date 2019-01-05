//
//  JAChatMessageManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/17.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAChatMessageManager.h"
#import <NIMSDK/NIMSDK.h>

#define kLimitMessage 20
@implementation JAChatMessageManager


/// 登录云信
+ (void)yx_loginYX:(NSString *)userUid
{
    NSString *account = [NSString stringWithFormat:@"moli%@",userUid];
    NSString *token = account;
    
    [[[NIMSDK sharedSDK] loginManager] login:account
                                       token:token
                                  completion:^(NSError *error) {
                                  
                                      if (error == nil) {
                                          NSLog(@"云信登录成功");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:@"yx_loginSuccess" object:nil];
                                          
                                      }else{
                                          NSLog(@"云信登录失败");
                                      }
                                  
                                  }];
}

/// 自动登录云信
+ (void)yx_autoLoginYX
{
    NSString *account = nil;
    NSString *token = nil;
    if (IS_LOGIN) {
        account = [NSString stringWithFormat:@"moli%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        token = account;
    }
    
    //如果有缓存用户名密码推荐使用自动登录
    if ([account length] && [token length])
    {
        NIMAutoLoginData *loginData = [[NIMAutoLoginData alloc] init];
        loginData.account = account;
        loginData.token = token;
        loginData.forcedMode = YES;
        
        [[[NIMSDK sharedSDK] loginManager] autoLogin:loginData];
        
        NSLog(@"云信自动登录执行");
    }
}

/// 退出云信
+ (void)yx_loginOutYX
{
    [[[NIMSDK sharedSDK] loginManager] logout:^(NSError *error){}];
}

/// 添加监听代理
+ (void)yx_addlistenDelegate:(UIViewController <NIMChatManagerDelegate,NIMConversationManagerDelegate> *)vc
{
    [[NIMSDK sharedSDK].chatManager addDelegate:vc];
    [[NIMSDK sharedSDK].conversationManager addDelegate:vc];
}

/// 移除监听代理
+ (void)yx_removelistenDelegate:(UIViewController <NIMChatManagerDelegate,NIMConversationManagerDelegate> *)vc
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:vc];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:vc];
}

/// 添加通知的监听代理
+ (void)yx_addNotiListenDelegate:(UIViewController <NIMSystemNotificationManagerDelegate, NIMConversationManagerDelegate>*)vc
{
    [[NIMSDK sharedSDK].conversationManager addDelegate:vc];
    id<NIMSystemNotificationManager> systemNotificationManager = [[NIMSDK sharedSDK] systemNotificationManager];
    [systemNotificationManager addDelegate:vc];
    
}

+ (void)yx_removeNotiListenDelegate:(UIViewController <NIMSystemNotificationManagerDelegate, NIMConversationManagerDelegate>*)vc
{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:vc];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:vc];
}

/// 创建会话
+ (NIMSession *)yx_getChatSessionWithUserId:(NSString *)yxUid
{
    NSString *userId = [NSString stringWithFormat:@"moli%@",yxUid];
    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
    
    return session;
}

/// 获取回话列表
+ (NSArray<NIMRecentSession *> *)yx_getAllChatSession
{
    NSArray *sessionArr = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
    
    NSMutableArray *arrM = [NSMutableArray arrayWithArray:sessionArr];
    
    [arrM enumerateObjectsUsingBlock:^(NIMRecentSession *obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if ([obj.session.sessionId isEqualToString:JA_OFFIC_SERVERMOLI]) {
            
            [arrM removeObject:obj];
            
            *stop = YES;
        }
    }];
    
    return arrM;
}

/// 获取茉莉官方的消息通知数据
+ (NIMRecentSession *)yx_getServermoliMessage
{
    NSString *userId = JA_OFFIC_SERVERMOLI;
    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
    NIMRecentSession *serverRecent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
    
    return serverRecent;
}

/// 删除单个会话
+ (void)yx_deleteSession:(NIMRecentSession *)recrntSession
{
    [[NIMSDK sharedSDK].conversationManager deleteRecentSession:recrntSession];

}

/// 获取聊天历史记录
+ (void)yx_getUserHistoryMessageWithSession:(NIMSession *)session message:(NIMMessage *)message complete:(void(^)(NSError *error, NSArray *messages))complete
{
    NIMHistoryMessageSearchOption *searchOpt = [[NIMHistoryMessageSearchOption alloc] init];
    searchOpt.startTime  = 0;
    searchOpt.currentMessage = message;
    searchOpt.endTime = message ? message.timestamp : 0;
    searchOpt.limit      = kLimitMessage;
    searchOpt.sync       = NO;
    [[NIMSDK sharedSDK].conversationManager fetchMessageHistory:session option:searchOpt result:^(NSError *error, NSArray *messages) {
        if (complete) {
            if (message) {
                complete(error,messages);
            }else{
                
                complete(error,messages.reverseObjectEnumerator.allObjects);
            }
            
        };
    }];
}

//// 获取通知消息
+ (NSArray *)yx_getNotiMessage:(id<NIMSystemNotificationManager>)systemNotiManager systemNotiMsg:(NIMSystemNotification *)notiMsg
{
    NSArray *notifications = [systemNotiManager fetchSystemNotifications:notiMsg limit:kLimitMessage];
    
    return notifications;
}

/// 删除单个通知
+ (void)yx_deleteSignNotiMsg:(NIMSystemNotification *)notiMsg
{
   
}

/// 删除全部通知
+ (void)yx_deleteAllNotiMsg
{
    
}

/// 发送文本消息
+ (void)yx_sendMessage:(NSString *)message withSession:(NIMSession *)session
{
    NIMMessage *textMessage = [[NIMMessage alloc] init];
    textMessage.text = message;
    
    //发送消息
    [[NIMSDK sharedSDK].chatManager sendMessage:textMessage toSession:session error:nil];
}

/// 发送图片消息
+ (void)yx_sendPictureMessage:(NSString *)message withSession:(NIMSession *)session
{
    // 待实现
}

/// 发送语音消息
+ (void)yx_sendVoiceMessage:(NSString *)message withSession:(NIMSession *)session
{
    // 待实现
}


/// 接受消息
+ (void)yx_receiveMessage:(NSArray <NIMMessage *> *)textMsgs session:(NIMSession *)session acceptMessage:(void(^)(NIMMessage *message))acceptMessage
{
    NIMMessage *message = textMsgs.firstObject;
    NIMSession *chatSession = message.session;
    if (![chatSession isEqual:session] || !textMsgs.count){
        return;
    }
    
    acceptMessage(message);
    
//    // 只有在聊天界面接收到的消息才需要直接设置为已读
//    [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:session];
    
}

/// 获取用户资料
+ (void)yx_getUserInfo:(NSArray *)userArr complete:(void(^)(NSArray<NIMUser *> * _Nullable users))complete
{
    [[NIMSDK sharedSDK].userManager fetchUserInfos:userArr completion:^(NSArray<NIMUser *> * _Nullable users, NSError * _Nullable error) {
       
        if (error == nil) {
            complete(users);
        }
    }];
}


/// 将用户聊天信息设置为已读
+ (void)yx_MessageRead:(NIMSession *_Nullable)session
{
    [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:session];
}

/// 将用户通知设置为已读
+ (void)yx_NotiMsgRead
{
    [[NIMSDK sharedSDK].systemNotificationManager markAllNotificationsAsRead];
}

/// 获取回话的未读数量
+ (NSInteger)yx_getUnreadCount
{
    return [[NIMSDK sharedSDK].conversationManager allUnreadCount];
}

@end
