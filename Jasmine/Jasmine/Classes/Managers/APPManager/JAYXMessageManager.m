//
//  JAYXMessageManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/28.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAYXMessageManager.h"

#import "JAPersonalLevelViewController.h"
#import "AppDelegateModel.h"
#import "JAVoiceCommonApi.h"

@implementation JAYXMessageManager

/// 进入聊天界面权限
+ (void)app_getChatLimitsWithYXuserId:(NSString *)YXuserId finish:(void(^)(JAChatLimitsType code))finish
{
    // 不走该逻辑的情况
    NSString *myOffic = [JAUserInfo userInfo_getUserImfoWithKey:User_AchievementId];
    
    if ([YXuserId isEqualToString:JA_OFFIC_SERVERMOLI] || myOffic.integerValue == 1) {
        
        if (finish) {
            finish(JAChatLimitsTypeFriend);    // 好友可以聊天
        }
        return;
    }
    
    // 1 判断是不是我的好友
    BOOL isFriend = [[NIMSDK sharedSDK].userManager isMyFriend:YXuserId];
    
    if (!isFriend) {  // 不是好友
        // 拉取好友申请列表
        NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
        filter.notificationTypes = @[@(NIMSystemNotificationTypeFriendAdd)];
        NSArray *friendRequest = [[NIMSDK sharedSDK].systemNotificationManager fetchSystemNotifications:nil limit:10000 filter:filter];
        
        __block NIMSystemNotification *notification = nil;
        
        [friendRequest enumerateObjectsUsingBlock:^(NIMSystemNotification *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([YXuserId isEqualToString:obj.sourceID]) {  // 需确认是不是同一个人
                notification = obj;
                *stop = YES;
            }
        }];
        
        if (notification) {  // 有该人的好友申请(表示回复某人) 可以进入聊天
            
            if (finish) {
                finish(JAChatLimitsTypeReply);
            }
            
        }else{   // 没有该人的好友请求  （表示新建会话聊天）
            
            // 等级限制
//            NSString *level = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelId];
//            if (level.integerValue < 5) {
//
//                NSString *megTitle = [NSString stringWithFormat:@"您的等级为Lv%@,无法主动给陌生人发私信，提升至Lv5后可解锁该特权",level];
//
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:megTitle message:nil preferredStyle:UIAlertControllerStyleAlert];
//
//                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                }];
//                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"查看等级特权" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    JAPersonalLevelViewController *vc = [[JAPersonalLevelViewController alloc] init];
//                    [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
//                }];
//
//                [alert addAction:action2];
//                [alert addAction:action1];
//
//                [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
//
//                return;
//            }
            
            // 大于5级 发送请求给服务器查看是否能新建聊天会话
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"imUserId"] = [YXuserId substringFromIndex:4];   // 需要检查
            dic[@"type"] = @"2";
            [MBProgressHUD showMessage:nil];
            [[JAVoiceCommonApi shareInstance] voice_friendLimit:dic success:^(NSDictionary *result) {
                
                [MBProgressHUD hideHUD];
                NSInteger type = [result[@"resType"] integerValue];
                
                if (type == 0) {  // 可以进入聊天界面
                    if (finish) {
                        finish(JAChatLimitsTypeFirstNewChat);       // 没有好友申请（表示第一次新建会话）  可以聊天
                    }
                }else if (type == 1){
                    
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您给陌生人发太多私信了，请明天再试~"];
                    
                }else if (type == 2){   // 表示已经聊过了
                    if (finish) {
                        finish(JAChatLimitsTypeSameChat);    // 没有好友申请（表示不是第一次新建会话）  可以聊天
                    }
                }else if (type == 3){
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"type参数错误 不能发送"];
                    
                }
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUD];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
            }];
            
        }
    }else{
        
        if (finish) {
            finish(JAChatLimitsTypeFriend);
        }
    }
}


/// 发送消息权限
+ (void)app_sendMessageWithYXuserId:(NSString *)YXuserId chatRecord:(NSArray *)records finish:(void(^)())finish
{
    
    // 不走该逻辑的情况
    if ([YXuserId isEqualToString:JA_OFFIC_SERVERMOLI]) {
        
        if (finish) {
            finish(JAChatLimitsTypeFriend);    // 好友可以聊天
        }
        return;
    }
    
    // 1 判断是不是我的好友
    BOOL isFriend = [[NIMSDK sharedSDK].userManager isMyFriend:YXuserId];
    
    if (!isFriend) {  // 不是好友
        // 拉取好友申请列表
        NIMSystemNotificationFilter *filter = [[NIMSystemNotificationFilter alloc] init];
        filter.notificationTypes = @[@(NIMSystemNotificationTypeFriendAdd)];
        NSArray *friendRequest = [[NIMSDK sharedSDK].systemNotificationManager fetchSystemNotifications:nil limit:10000 filter:filter];
        
        __block NIMSystemNotification *notification = nil;
        
        [friendRequest enumerateObjectsUsingBlock:^(NIMSystemNotification *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([YXuserId isEqualToString:obj.sourceID]) {  // 需确认是不是同一个人
                notification = obj;
                *stop = YES;
            }
        }];
        
        if (notification) {  // 有该人的好友申请(表示回复某人)
            
            // 发送请求给服务器
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"imUserId"] = [YXuserId substringFromIndex:4];   // 需要检查
            dic[@"type"] = @"1";
            [MBProgressHUD showMessage:nil];
            [[JAVoiceCommonApi shareInstance] voice_friendLimit:dic success:^(NSDictionary *result) {
                [MBProgressHUD hideHUD];
                NSInteger type = [result[@"resType"] integerValue];
                if (type == 0) {
                    NIMUserRequest *request = [[NIMUserRequest alloc] init];
                    request.userId = notification.sourceID;
                    request.operation = NIMUserOperationVerify;
                    [[NIMSDK sharedSDK].userManager requestFriend:request completion:^(NSError * _Nullable error) {
                        
                        [[NIMSDK sharedSDK].systemNotificationManager deleteNotification:notification];
                    }];
                    
                    if (finish) {    // 发送聊天
                        finish();
                    }
                }else if(type == 3){
                    
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"type参数错误 不能发送"];
                }else if (type == 4){
                    
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请重新发起聊天"];
                }
            }failure:^(NSError *error) {
                [MBProgressHUD hideHUD];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
            }];
            
        }else{    // 没有好友申请 新建聊天发送消息
            
            //            if (records.count) {   // 有聊天记录（已经发送过聊天对方没有回复）
            //                // 直接聊天
            //                if (finish) {
            //                    finish();
            //                }
            //            }else{
            // 发送请求
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"imUserId"] = [YXuserId substringFromIndex:4];   // 需要检查
            dic[@"type"] = @"0";
            [MBProgressHUD showMessage:nil];
            
            [[JAVoiceCommonApi shareInstance] voice_friendLimit:dic success:^(NSDictionary *result) {
                
                [MBProgressHUD hideHUD];
                NSInteger type = [result[@"resType"] integerValue];
                // 如果是0  发送好友请求  2 的时候也可以进聊天不发好友请求
                if (type == 0) {  // 如果是 0 就发送好友请求 并进入聊天界面
                    NIMUserRequest *request = [[NIMUserRequest alloc] init];
                    request.userId = YXuserId;
                    request.operation = NIMUserOperationRequest;
                    [[NIMSDK sharedSDK].userManager requestFriend:request completion:nil];
                    
                    if (finish) {
                        finish();       // 不是好友 没有好友申请（表示第一次新建会话）  可以聊天
                    }
                }else if (type == 1){
                    
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您给陌生人发太多私信了，请明天再试~"];
                    
                }else if(type == 2){
                    
                    if (finish) {            // 对同一个人新建会话（直接聊天）
                        finish();
                    }
                    
                }else if (type == 3){
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"type参数错误 不能发送"];
                }
                
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUD];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
            }];
            
            //            }
        }
        
    }else{
        // 直接聊天
        if (finish) {
            finish();
        }
    }
}
@end
