//
//  JAIMManager.h
//  Jasmine
//
//  Created by xujin on 21/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>


@class EMMessage;
@interface JAIMManager : NSObject

+ (JAIMManager *)shareInstance;
//@property (nonatomic, strong) EMConversation *sation;
@property (nonatomic, strong) NSString *toUserName;

///// 登录环信
//- (void)loginHuanXin;
//
///// 退出环信
//- (void)logout;
//
/////
//- (void)createSession:(NSString *)uid name:(NSString *)name;
//
///// 检索消息
//- (void)queryMessage:(void(^)(NSArray *array, NSError * error))block;
//
///// 发送消息
//- (void)sendMessage:(NSString *)msg toUser:(NSString *)userName conversationExt:(NSDictionary *)converExt extInfo:(NSDictionary *)dic success:(void(^)(EMMessage *message))successBlock;
//
///// 获取消息消息
//- (void)im_getChatMessage:(NSString *)userName success:(void(^)(NSArray *messages))successBlock;
//
///// 获取更早的聊天消息
//- (void)im_getEarlyChatMessage:(NSString *)userName messageID:(NSString *)messageID success:(void(^)(NSArray *messages))successBlock;
//
///// 获取好友列表
//- (NSArray *)im_getAllfriendList;
//
///// 好友申请列表
//- (NSArray *)im_friendRequest;
//
//// APP进入后台
//- (void)applicationDidEnterBackground:(UIApplication *)application;
//
//// APP将要从后台返回
//- (void)applicationWillEnterForeground:(UIApplication *)application;

@end
