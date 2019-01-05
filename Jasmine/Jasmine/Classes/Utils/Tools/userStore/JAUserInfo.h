//
//  JAUserInfo.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAUserInfo : NSObject

/// 保存基本用户信息
+ (void)userInfo_saveUserInfo:(NSDictionary *)dic;

/// 保存用户登录状态
+ (void)userinfo_saveUserLoginState:(BOOL)LoginStat;

/// 保存本地时间-服务器当前时间的值
+ (void)userinfo_saveUserDisTime:(NSString *)time;

/// 保存用户token过期时间
+ (void)userinfo_saveUserAccdessTime:(NSString *)time;

/// 保存用户token
+ (void)userinfo_saveUserToken:(NSString *)token;

/// 更新用户信息
+ (void)userInfo_updataUserInfoWithKey:(NSString *)key value:(NSString *)valueStr;

/// 获取用户信息
+ (NSString *)userInfo_getUserImfoWithKey:(NSString *)key;

/// 删除用户信息
+ (void)userInfo_deleteUserInfo;


@end
