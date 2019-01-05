//
//  JAUserInfo.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAUserInfo.h"
#import "EncryptionTools.h"

//static NSString *AECString = @"moliAECStringBeiJingXiangSong";
//static uint8_t iv[8] = {2,0,1,7,0,7,3,1};

@implementation JAUserInfo

/// 保存用户信息
+ (void)userInfo_saveUserInfo:(NSDictionary *)dic
{
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"createTime"] forKey:User_CreatTime];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"name"] forKey:User_Name];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"birthdayName"] forKey:User_Birthday];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"birthday"] forKey:User_BirthdayTime];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"agreeCount"]] forKey:User_agree];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"password"] forKey:User_Pwd];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"levelId"]] forKey:User_LevelId];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"achievementId"]] forKey:User_AchievementId];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"image"] forKey:User_ImageUrl];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"phone"] forKey:User_Phone];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"age"]] forKey:User_Age];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"sex"]] forKey:User_Sex];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"constellation"] forKey:User_Constellation];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"introduce"] forKey:User_Introduce];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"job"] forKey:User_Job];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"address"] forKey:User_Address];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"longitude"] forKey:User_Longitude];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"latitude"] forKey:User_Latitude];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"flowerCount"]] forKey:User_FlowerCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"userConsernCount"]] forKey:User_userConsernCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"concernUserCount"]] forKey:User_concernUserCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"problemCount"]] forKey:User_problemCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"answerCount"]] forKey:User_answerCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"collentCount"]] forKey:User_collentCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"publishCount"]] forKey:User_publishCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"speakCount"]] forKey:User_speakCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"storyCount"]] forKey:User_storyCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"commentCount"]] forKey:User_commentCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"score"]] forKey:User_score];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"id"]] forKey:User_id];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"uuid"]] forKey:User_uuid];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"platformType"]] forKey:
     User_PlatformType];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入

    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformUid"] forKey:User_PlatformUid];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformQqUid"] forKey:User_PlatformQQUid];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformWxUid"] forKey:User_PlatformWXUid];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformWbUid"] forKey:User_PlatformWBUid];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformWbName"] forKey:User_PlatformWBName];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformWxName"] forKey:User_PlatformWXName];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformQqName"] forKey:User_PlatformQQName];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"platformWXTixian"] forKey:User_PlatformWXTixian];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"inviteUuid"] forKey:User_InviteUuid];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"moliFlowerCount"]] forKey:User_MoliFlowerCount];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"incomeMoney"]] forKey:User_IncomeMoney];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@",dic[@"expenditureMoney"]] forKey:User_expenditureMoney];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"power"] forKey:User_Admin];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"status"] forKey:User_Status];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"validTime"] forKey:User_ValidTime];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"levelScore"] forKey:User_LevelScore];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:dic[@"topScore"] forKey:User_TopScore];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    
    // 用户头衔
    NSDictionary *markDic = dic[@"crown"];
    [[NSUserDefaults standardUserDefaults] setObject:markDic[@"smallImage"] forKey:User_markImage];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    [[NSUserDefaults standardUserDefaults] setObject:markDic[@"name"] forKey:User_markName];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    
    // 用户佩戴勋章
    NSDictionary *medalDic = dic[@"medalConfig"];
    [[NSUserDefaults standardUserDefaults] setObject:medalDic[@"getImgUrl"] forKey:User_medalImage];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    
    // 是否有勋章
    NSArray *medalList = dic[@"medalList"];
    if (medalList.count) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:User_medalList];
        [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:User_medalList];
        [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
    }
}


/// 保存用户token
+ (void)userinfo_saveUserToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:User_AccessToken];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
}

/// 保存本地时间减去服务器当前时间的值
+ (void)userinfo_saveUserDisTime:(NSString *)time {
    [[NSUserDefaults standardUserDefaults] setObject:time forKey:User_DisTime];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
}

/// 保存用户token过期时间
+ (void)userinfo_saveUserAccdessTime:(NSString *)time
{
    [[NSUserDefaults standardUserDefaults] setObject:time forKey:User_AccessTokenServerTime];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入
}

/// 保存用户登录状态
+ (void)userinfo_saveUserLoginState:(BOOL)LoginStat
{
    [[NSUserDefaults standardUserDefaults] setBool:LoginStat forKey:User_LoginState];
   [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入 
}

/// 更新用户信息
+ (void)userInfo_updataUserInfoWithKey:(NSString *)key value:(NSString *)valueStr
{
    [[NSUserDefaults standardUserDefaults] setObject:valueStr forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];  // 立即写入 
}

/// 获取用户信息
+ (NSString *)userInfo_getUserImfoWithKey:(NSString *)key
{
    NSString *valueStr = nil;

    valueStr = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    return valueStr;
}

/// 删除用户信息
+ (void)userInfo_deleteUserInfo
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_CreatTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Name];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_LevelId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_AchievementId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_ImageUrl];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Phone];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Age];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Sex];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Constellation];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Introduce];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Job];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Address];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Longitude];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Latitude];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_FlowerCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_userConsernCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_concernUserCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_problemCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_answerCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_collentCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_publishCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_storyCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_commentCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_score];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformUid];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformQQUid];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWXUid];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWBUid];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWXTixian];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_AccessToken];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Pwd];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_id];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_InviteUuid];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_IncomeMoney];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_MoliFlowerCount];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Admin];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_expenditureMoney];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_AccessTokenServerTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_DisTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_BirthdayTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Birthday];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_Status];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_ValidTime];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_LevelScore];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_TopScore];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWBName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformWXName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_PlatformQQName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_markName];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_markImage];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:User_medalImage];
}

@end
