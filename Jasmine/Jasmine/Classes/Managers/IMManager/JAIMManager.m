//
//  JAIMManager.m
//  Jasmine
//
//  Created by xujin on 21/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAIMManager.h"

#define klimitCount 30


@interface JAIMManager ()

//@property (nonatomic, strong) EMConversation *sation;
//@property (nonatomic, strong) NSString *toUserName;

@end

@implementation JAIMManager

//-(EMConversation *)sation
//{
//    if (_sation == nil) {
//        
//        // 创建单聊会话
//        _sation = [[EMClient sharedClient].chatManager getConversation:self.toUserName type:EMConversationTypeChat createIfNotExist:YES];
//        
//    }
//    
//    return _sation;
//}

//+ (JAIMManager *)shareInstance
//{
//    static JAIMManager *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (instance == nil)
//        {
//            instance = [[JAIMManager alloc] init];
//        }
//    });
//    return instance;
//}
//- (id)init
//{
//    if (self = [super init])
//    {
//        NSString *str = @"1199170525178068#moli";
//#ifdef JA_TEST_HOST
//        str = @"1199170525178068#molitest";
//#endif
//        
//        EMOptions *options = [EMOptions optionsWithAppkey:str];
//        
//        options.apnsCertName = @"iosmolipush";
//        EMError *error = [[EMClient sharedClient] initializeSDKWithOptions:options];
//        
//        if (!error) {
//            
//            NSLog(@"环信初始化成功");
//        }
//        
//        
////        [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
////        
////        //注册消息回调
////        [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
//    }
//    return self;
//}
//
//// APP进入后台
//- (void)applicationDidEnterBackground:(UIApplication *)application
//{
//    [[EMClient sharedClient] applicationDidEnterBackground:application];
//}
//
//// APP将要从后台返回
//- (void)applicationWillEnterForeground:(UIApplication *)application
//{
//    [[EMClient sharedClient] applicationWillEnterForeground:application];
//}
//
//- (void)loginHuanXin
//{
//
//    NSString *userID = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    NSString *huanxinUid = [NSString stringWithFormat:@"moli%@",userID];
//    NSLog(@"环信UID - %@",huanxinUid);
//    
////    NSString *userPwd = [JAUserInfo userInfo_getUserImfoWithKey:User_Pwd];
//    NSString *userPwd = huanxinUid;
//    NSLog(@"环信密码 - %@",userPwd);
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        EMError *error = [[EMClient sharedClient] loginWithUsername:huanxinUid password:userPwd];
//        
//       dispatch_async(dispatch_get_main_queue(), ^{
//           
//           
//            if (!error) {
//                //设置是否自动登录
//                [[EMClient sharedClient].options setIsAutoLogin:YES];
//
//                NSLog(@"环信 - 登录成功");
//                
//            } else {
//                NSLog(@"环信 - 登录失败 %@",error);
//            }
//       });
//        
//    });
//    
//}
//- (void)logout
//{
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        EMError *error = [[EMClient sharedClient] logout:YES];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            
//            if (error != nil) {
//                
//                NSLog(@"环信 - 退出成功");
//            }
//            else{
//                
//                
//            }
//        });
//    });
//}
//
//
//- (void)createSession:(NSString *)uid name:(NSString *)name
//{
//   
//}
//
//- (void)queryMessage:(void(^)(NSArray *array, NSError * error))block
//{
//    
//}
//
//
//
//- (void)sendMessage:(NSString *)msg toUser:(NSString *)userName conversationExt:(NSDictionary *)converExt extInfo:(NSDictionary *)dic success:(void(^)(EMMessage *message))successBlock
//{
//    _toUserName = userName;
//    
//    self.sation.ext = converExt;
////    [self.sation updateConversationExtToDB];
////    NSDictionary *messageExt = dic;
//    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:msg];
//    NSString *from = [[EMClient sharedClient] currentUsername];
//    
//    //生成Message
//    EMMessage *message = [[EMMessage alloc] initWithConversationID:self.sation.conversationId from:from to:userName body:body ext:dic];
//    message.chatType = EMChatTypeChat;// 设置为单聊消息
//    
//    [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
//        //
//    } completion:^(EMMessage *message, EMError *error) {
//        //
//        
//        if (!error && successBlock) {
//            
//            successBlock(message);
//        }
//        
//    }];
//}
//
//
///// 获取消息消息
//- (void)im_getChatMessage:(NSString *)userName success:(void(^)(NSArray *messages))successBlock
//{
//   _toUserName = userName;
//    
//    [self.sation loadMessagesStartFromId:nil count:klimitCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
//       
//        if (!aError && successBlock) {
//            
//            successBlock(aMessages);
//        }
//    }];
//}
//
///// 获取更早的聊天消息
//- (void)im_getEarlyChatMessage:(NSString *)userName messageID:(NSString *)messageID success:(void(^)(NSArray *messages))successBlock
//{
//   _toUserName = userName;
//    
//    [self.sation loadMessagesStartFromId:messageID count:klimitCount searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
//        
//        if (successBlock) {
//            
//            successBlock(aMessages);
//        }
//        
//        NSLog(@"%@",aError);
//        
//    }];
//}
//
//
//// 自动登录返回结果
//- (void)autoLoginDidCompleteWithError:(EMError *)error
//{
//    
//}
//
///*!
// *  SDK连接服务器的状态变化时会接收到该回调
// *  
// *  当掉线时，iOS SDK 会自动重连，只需要监听重连相关的回调，无需进行任何操作。
// *
// *  有以下几种情况，会引起该方法的调用：
// *  1. 登录成功后，手机无法上网时，会调用该回调
// *  2. 登录成功后，网络状态变化时，会调用该回调
// *
// *  @param aConnectionState 当前状态
// */
//- (void)connectionStateDidChange:(EMConnectionState)aConnectionState
//{
//    
//}
//// 当前登录账号在其它设备登录时会接收到该回调
//- (void)userAccountDidLoginFromOtherDevice
//{
//    
//}
//
//// 当前登录账号已经被从服务器端删除时会收到该回调
//- (void)userAccountDidRemoveFromServer
//{
//    
//}
//
//
//
//// 服务被禁用
//- (void)userDidForbidByServer
//{
//    
//}
//
//
//#pragma mark EMChatManagerDelegate methods
//
//// 接收到一条及以上cmd消息
//// 透传(cmd)在线消息
//- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages
//{
//    
//}
//// 收到消息
//// 在线普通消息会走以下回调
//- (void)messagesDidReceive:(NSArray *)aMessages
//{
//    
//}
//
///// 获取好友列表
//- (NSArray *)im_getAllfriendList
//{
//    EMError *error = nil;
//    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
//    if (!error) {
//        NSLog(@"环信获取成功 -- %@",userlist);
//    }else{
//        NSLog(@"环信获取好友失败 -- %@",error);
//    }
//    
//    
//    return userlist;
//}
//
///// 好友申请列表
//- (NSArray *)im_friendRequest
//{
//    return nil;
//}


@end
