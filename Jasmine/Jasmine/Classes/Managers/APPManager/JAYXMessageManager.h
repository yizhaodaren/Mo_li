//
//  JAYXMessageManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/28.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAYXMessageManager : NSObject

/// 进入聊天界面权限
+ (void)app_getChatLimitsWithYXuserId:(NSString *)YXuserId finish:(void(^)(JAChatLimitsType code))finish;

/// 发送消息权限
+ (void)app_sendMessageWithYXuserId:(NSString *)YXuserId chatRecord:(NSArray *)records finish:(void(^)())finish;
@end
