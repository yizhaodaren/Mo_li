//
//  JAChatMessageManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/17.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN
@interface JAChatMessageManager : NSObject

/*
  系统通知个数的变化 -- (void)onSystemNotificationCountChanged:(NSInteger)unreadCount
  收到消息的回调    -- - (void)onRecvMessages:(NSArray<NIMMessage *> *)messages
 */


/// 登录云信  --- 登录 [NIMSDK sharedSDK].loginManager
+ (void)yx_loginYX:(NSString *)userUid;

/// 退出云信
+ (void)yx_loginOutYX;

/// 自动登录云信
+ (void)yx_autoLoginYX;

/// 添加监听代理 --- 聊天 [NIMSDK sharedSDK].chatManager
+ (void)yx_addlistenDelegate:(UIViewController <NIMChatManagerDelegate,NIMConversationManagerDelegate> *)vc;

/// 移除监听代理
+ (void)yx_removelistenDelegate:(UIViewController <NIMChatManagerDelegate,NIMConversationManagerDelegate> *)vc;

/// 添加通知的监听代理  ---- 通知 [[NIMSDK sharedSDK] systemNotificationManager]
+ (void)yx_addNotiListenDelegate:(UIViewController <NIMSystemNotificationManagerDelegate, NIMConversationManagerDelegate>*)vc;

/// 移除通知监听代理
+ (void)yx_removeNotiListenDelegate:(UIViewController <NIMSystemNotificationManagerDelegate, NIMConversationManagerDelegate>*)vc;

/// 创建会话
+ (NIMSession *)yx_getChatSessionWithUserId:(NSString *)yxUid;

/// 获取回话列表 --- 回话  [NIMSDK sharedSDK].conversationManager 
+ (NSArray<NIMRecentSession *> *)yx_getAllChatSession;

/// 获取茉莉官方的消息通知数据
+ (NIMRecentSession *)yx_getServermoliMessage;

/// 删除单个会话
+ (void)yx_deleteSession:(NIMRecentSession *)session;


/// 删除单个通知
+ (void)yx_deleteSignNotiMsg:(NIMSystemNotification *)notiMsg;

/// 删除全部通知
+ (void)yx_deleteAllNotiMsg;

/// 获取聊天历史记录 --- 根据传入的消息获取更早的消息
+ (void)yx_getUserHistoryMessageWithSession:(NIMSession *)session message:(NIMMessage *)message complete:(void(^)(NSError *error, NSArray *messages))complete;

/// 获取通知消息
+ (NSArray *)yx_getNotiMessage:(id<NIMSystemNotificationManager>)systemNotiManager systemNotiMsg:(NIMSystemNotification *)notiMsg;

/// 发送文本消息
+ (void)yx_sendMessage:(NSString *)message withSession:(NIMSession *)session;

/// 发送图片消息
+ (void)yx_sendPictureMessage:(NSString *)message withSession:(NIMSession *)session;

/// 发送语音消息
+ (void)yx_sendVoiceMessage:(NSString *)message withSession:(NIMSession *)session;

/// 接受消息
+ (void)yx_receiveMessage:(NSArray <NIMMessage *> *)textMsgs session:(NIMSession *)session acceptMessage:(void(^)(NIMMessage *message))acceptMessage;

/// 获取用户资料
+ (void)yx_getUserInfo:(NSArray *)userArr complete:(void(^_Nullable)(NSArray<NIMUser *> * _Nullable users))complete;

/// 将用户聊天信息设置为已读
+ (void)yx_MessageRead:(NIMSession *_Nullable)session;

/// 将用户通知设置为已读
+ (void)yx_NotiMsgRead;

/// 获取回话的未读数量
+ (NSInteger)yx_getUnreadCount;

@property (nonatomic, strong) void (^yx_loginSuccess)();
@end
NS_ASSUME_NONNULL_END
