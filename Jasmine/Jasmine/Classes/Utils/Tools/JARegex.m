//
//  XDRegex.m
//  SeeYouTimeTwo
//
//  Created by 形点网络 on 16/6/23.
//  Copyright © 2016年 xingdian. All rights reserved.
//

#import "JARegex.h"

@implementation JARegex

+ (BOOL)RegexMobileNumber:(NSString *)mobileNum {
    //判断手机号码是否为11位
//    if (mobileNum.length != 11)
//    {
//        return NO;
//    }
//    /**
//     * 手机号码:
//     * 13[0-9], 14[5,7], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[6, 7, 8], 18[0-9], 170[0-9]
//     * 移动号段: 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
//     * 联通号段: 130,131,132,155,156,185,186,145,176,1709
//     * 电信号段: 133,153,180,181,189,177,1700
//     */
//    NSString *MOBILE             = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|70)\\d{8}$";
//    /**
//     * 中国移动：China Mobile
//     * 134,135,136,137,138,139,150,151,152,157,158,159,182,183,184,187,188,147,178,1705
//     */
//    NSString *CM                 = @"(^1(3[4-9]|4[7]|5[0-27-9]|7[8]|8[2-478])\\d{8}$)|(^1705\\d{7}$)";
//    /**
//     * 中国联通：China Unicom
//     * 130,131,132,155,156,185,186,145,176,1709
//     */
//    NSString *CU                 = @"(^1(3[0-2]|4[5]|5[56]|7[6]|8[56])\\d{8}$)|(^1709\\d{7}$)";
//    /**
//     * 中国电信：China Telecom
//     * 133,153,180,181,189,177,1700
//     */
//    NSString *CT                 = @"(^1(33|53|77|8[019])\\d{8}$)|(^1700\\d{7}$)";
//
//
//    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
//    NSPredicate *regextestcm     = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
//    NSPredicate *regextestcu     = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
//    NSPredicate *regextestct     = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
//
//    //判断是否是手机号码/移动号码/联通号码/电信号码/虚拟运营商号码
//    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
//        || ([regextestcm evaluateWithObject:mobileNum] == YES)
//        || ([regextestct evaluateWithObject:mobileNum] == YES)
//        || ([regextestcu evaluateWithObject:mobileNum] == YES))
//    {
//        return YES;
//    }else{
//        return NO;
//    }
    NSString *userNameRegex = @"^1\\d{10}$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    return [userNamePredicate evaluateWithObject:mobileNum];
}

+ (BOOL)RegexLoginPhoneNum:(NSString *)num
{
    NSString *userNameRegex = @"^1\\d{10}$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    return [userNamePredicate evaluateWithObject:num];
}

+ (BOOL)RegexNumber:(NSString *)num
{
    
    NSString *userNameRegex = @"^[0-9]*$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    return [userNamePredicate evaluateWithObject:num];
}

+ (BOOL)RegexUserName:(NSString *)userName
{
    // ^[\u4e00-\u9fa5]{2,8}$|^[\dA-Za-z_]{3,16}$
    NSString *userNameRegex = @"^[\u4e00-\u9fa5_a-zA-Z0-9]+$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    return [userNamePredicate evaluateWithObject:userName];
}

+ (BOOL)RegexRoomName:(NSString *)roomName
{
    
    NSString *roomNameRegex = @"^(?=[0-9a-zA-Z@_.]+$)";
    NSPredicate *roomNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",roomNameRegex];
    
    return [roomNamePredicate evaluateWithObject:roomName];
    
}

+ (BOOL)RegexSixNumber:(NSString *)num
{
    
    NSString *userNameRegex = @"^[0-9][6]$";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    return [userNamePredicate evaluateWithObject:num];
}

+ (BOOL)RegexPwd:(NSString *)num
{
    
    NSString *userNameRegex = @"^[a-zA-Z0-9]{6,20}";
    NSPredicate *userNamePredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userNameRegex];
    
    return [userNamePredicate evaluateWithObject:num];
}



+ (BOOL)RegexContainText:(NSString *)text
{
    return YES;
}

+ (BOOL)RegexPassword:(NSString *)num
{
    //
    NSString *userPwdRegex = @"^[\u4e00-\u9fa5]";
    NSPredicate *userPwdPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",userPwdRegex];
    
    return [userPwdPredicate evaluateWithObject:num];
}
@end
