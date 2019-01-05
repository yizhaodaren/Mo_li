//
//  XDRegex.h
//  SeeYouTimeTwo
//
//  Created by 形点网络 on 16/6/23.
//  Copyright © 2016年 xingdian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JARegex : NSObject
/**
 *  验证手机号码是否正确
 *
 *  @param mobileNum 需要验证的手机号码
 *
 *  @return 是否是正确的手机号码
 */
+ (BOOL)RegexMobileNumber:(NSString *)mobileNum;

/**
 *  验证登录手机号码是否符合规则
 *
 *  @param mobileNum 需要验证的手机号码
 *
 *  @return 是否是正确的手机号码
 */
+ (BOOL)RegexLoginPhoneNum:(NSString *)num;

/**
 *  验证是否是纯数字
 *
 *  @param num 需要验证的字符串
 *
 *  @return 是否是纯数字
 */
+ (BOOL)RegexNumber:(NSString *)num;

/**
 *  验证用户名
 *
 *  @param userName 需要验证的用户名
 *
 *  @return 用户名是否符合规则
 */
+ (BOOL)RegexUserName:(NSString *)userName;


/**
 *  验证房间名
 *
 *  @param roomName 需要验证的房间
 *
 *  @return 用户名是否符合规则  
 */
+ (BOOL)RegexRoomName:(NSString *)roomName;

/**
 *  验证是否是纯数字
 *
 *  @param num 需要验证的字符串
 *
 *  @return 是否是纯数字
 */
+ (BOOL)RegexSixNumber:(NSString *)num;
/**
 *  验证密码(数字字母)
 *
 *  @param num 需要验证的字符串
 *
 *  @return 是否是纯数字
 */
+ (BOOL)RegexPwd:(NSString *)num;

/**
 *  文字
 *
 *  @param num 需要验证的字符串
 *
 *  @return 是否包含文字
 */
+ (BOOL)RegexContainText:(NSString *)text;

/**
 *  验证密码(没有中文)
 *
 *  @param num 需要验证的字符串
 *
 *  @return 是否包含文字
 */
+ (BOOL)RegexPassword:(NSString *)num;
@end
