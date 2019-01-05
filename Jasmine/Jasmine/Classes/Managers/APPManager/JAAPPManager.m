//
//  JAAPPManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/10.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAPPManager.h"
#import "JANewRegistrationViewController.h"
#import "JAOpenInvitePacketViewController.h"
#import "JAPersonalLevelViewController.h"
#import "AppDelegateModel.h"
#import "JAUserApiRequest.h"
#import "JATaskRowModel.h"
#import "JADeleteReasonModel.h"

#import "JAVoiceCommonApi.h"
#import "JAVoiceCommentApi.h"
#import "JAVoicePersonApi.h"
#import "JAVoiceApi.h"
#import "JAVoiceReplyApi.h"
#import "JAVoiceCommentModel.h"
#import "JAVoiceReplyModel.h"
#import "JADoubleShareView.h"
#import "JAReleaseStoryCountModel.h"
#import "JACreditRuleModel.h"
#import "JACacheDataManager.h"
#import "JAPlatformLoginViewController.h"
#import "JAPacketNotiMsgAnimateView.h"

#import "JASwitchDefine.h"

#import "CYLTabBarController.h"
#import "STSystemHelper.h"
#import "NSDictionary+NTESJson.h"
#import "JALabelSelectNetRequest.h"

#define angle2Radio(angle) ((angle * M_PI) / 180.0)

@implementation JAAPPManager
+ (void)app_modalLogin
{
    // 获取上次的登录状态
    NSInteger type = [[NSUserDefaults standardUserDefaults] integerForKey:JA_LOGIN_RECORDTYPE];
    
    if (type == 1) {   // 0 手机 1 qq 2 wx  3 wb
        JAPlatformLoginViewController *vc = [[JAPlatformLoginViewController alloc] init];
        vc.loginType = JARecordLoginTypeQqLogin;
        JABaseNavigationController *loginNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
        [[AppDelegateModel rootviewController] presentViewController:loginNav animated:YES completion:nil];
        
    }else if (type == 2){
        JAPlatformLoginViewController *vc = [[JAPlatformLoginViewController alloc] init];
        vc.loginType = JARecordLoginTypeWxLogin;
        JABaseNavigationController *loginNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
        [[AppDelegateModel rootviewController] presentViewController:loginNav animated:YES completion:nil];
        
    }else if (type == 3){
        JAPlatformLoginViewController *vc = [[JAPlatformLoginViewController alloc] init];
        vc.loginType = JARecordLoginTypeWbLogin;
        JABaseNavigationController *loginNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
        [[AppDelegateModel rootviewController] presentViewController:loginNav animated:YES completion:nil];
        
    }else{
        [self app_modalRegist];
        
    }
}

+ (void)app_modalRegist
{
    JANewRegistrationViewController *vc = [[JANewRegistrationViewController alloc] init];
    JABaseNavigationController *loginNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
    [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:loginNav animated:YES completion:nil];
}

// 强制退出
+ (void)app_loginOut
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"app_loginOut" object:nil];
    
    [JAUserInfo userinfo_saveUserLoginState:NO];
    [JAUserInfo userInfo_deleteUserInfo];
    // 退出云信
    [JAChatMessageManager yx_loginOutYX];
    [[QYSDK sharedSDK] logout:^(){}];
    
    [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_resetData];
    
    // 删除别名
    [JPUSHService setAlias:nil completion:nil seq:0];
    
    // 回到首页
//    [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
//        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    }];
//    JABaseNavigationController *nav = [AppDelegateModel getBaseNavigationViewControll];
//    [nav popToRootViewControllerAnimated:YES];
    
    [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
    [self cyl_tabBarController].selectedIndex = 0;
    
    [self app_modalLogin];
}

+ (BOOL)isConnect {
    
    Reachability *r = [Reachability reachabilityForInternetConnection];
    
    if (NotReachable != [r currentReachabilityStatus]) {
        return YES;
    }
    return NO;
}

// APP 启动
+ (void)appFirstStart
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JAisFirstStartApp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
// 是否首次启动
+ (BOOL)isFirstStartApp
{
    BOOL start = [[NSUserDefaults standardUserDefaults] boolForKey:@"JAisFirstStartApp"];
    return start;
}

// 内部账户逻辑判断
+ (void)companyPersonnelAccount
{
    if (IS_LOGIN) {
        NSString *localPower = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
        if (localPower.integerValue == JAPOWER) {
            [JAConfigManager shareInstance].isDebug = @"0";
        }
    }
    // 让所有用户的isDebug变为0 就打开
//    [JAConfigManager shareInstance].isDebug = @"0";
}

+ (void)saveAccessTokenAndTime:(NSDictionary *)dictionary {
    NSString *token = dictionary[@"accessToken"];
    if (token.length) {
        [JAUserInfo userinfo_saveUserToken:token];
    }
    NSNumber *serverTime = dictionary[@"serverTime"];
    long long time=[serverTime longLongValue];
    if ([serverTime longLongValue] > 0) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time/1000.0];
        NSDateComponents *comp = [NSDate componentsFromDate:date];
        long long diff = (60 - comp.minute)*60 - comp.second + 1;
        NSDate*date1 = [NSDate dateWithTimeIntervalSinceNow:diff];
        long long localTime = [date1 timeIntervalSince1970]*1000;
        [JAUserInfo userinfo_saveUserAccdessTime:[NSString stringWithFormat:@"%lld",localTime]];
        NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:date]; // 计算出当前时间与服务器时间相差多少秒
        [JAUserInfo userinfo_saveUserDisTime:[NSString stringWithFormat:@"%f",delta]];
    }
}

+ (void)app_loginSuccessWithResult:(NSDictionary *)result loginType:(NSInteger)type
{
    // 存储上次的登录状态
    [[NSUserDefaults standardUserDefaults] setInteger:type forKey:JA_LOGIN_RECORDTYPE];
    
    [JAUserInfo userinfo_saveUserLoginState:YES];
    
    NSDictionary *userDic = result[@"resMap"][@"user"];
    if (userDic) {
        [JAUserInfo userInfo_saveUserInfo:userDic];
        // 登录神策
        [JASensorsAnalyticsManager sensorsAnalytics_login];
        // 设置神策用户信息
        JAConsumer *user = [JAConsumer mj_objectWithKeyValues:userDic];
        if (user) {
            [JASensorsAnalyticsManager sensorsAnalytics_setUser:user];
            
            // v3.0.0 新增游客标签同步
            if (user.isLabel == 0) {
                JALabelSelectNetRequest *request = [[JALabelSelectNetRequest alloc] initRequest_syncLabelsWithParameter:nil];
                [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
                    if (responseModel.code != 10000) {
                        return;
                    }
                } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
                }];
            }
        }
    }
   
    [JAAPPManager saveAccessTokenAndTime:result[@"resMap"]];
    
    // 登录云信
    [[NSNotificationCenter defaultCenter] postNotificationName:app_offic object:nil];
    [JAChatMessageManager yx_loginYX:[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    
    // 设置推送别名
    NSString *moliAlias = [NSString stringWithFormat:@"moli%@",[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    [JPUSHService setAlias:moliAlias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:0];
    
    // 切换账号清理掉获取的已发帖数
    [LKDBHelper clearTableData:[JAReleaseStoryCountModel class]];
    
    /***************************************** 内部账户*****************************************/
    [self companyPersonnelAccount];
    /***************************************** 内部账户*****************************************/
                                
    // 发送通知刷新消息列表 - 我的个人中心
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:LOGINSUCCESS object:nil];
    });
    
    // 分享注册信息
    [JACacheDataManager getShareRegistInfo];
}

/**************************** app状态 ****************************/
/// 是否为第一次打开app
+ (BOOL)isFirstOpenThisAPP{
    BOOL isFirstOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"firstOpenApp"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstOpenApp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return !isFirstOpen;
}

/// 是否展示引导页
+ (BOOL)isShowUserGuideLoad{
#warning 每次替换引导页，需要提升本地版本
    NSInteger currentGuideVersion = 1;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger lastGuideVersion = [defaults integerForKey:@"JALastRunVersonKey"]; // 默认值为0
    if (lastGuideVersion != currentGuideVersion) {
        [defaults setObject:@(currentGuideVersion) forKey:@"JALastRunVersonKey"];
        [defaults synchronize];
        return YES;
    }
    return NO;
}

/// 是否弹出标签页
+ (BOOL)isShowLabelsVC {
    BOOL isShowLabelsVC = [[NSUserDefaults standardUserDefaults] boolForKey:@"isShowLabelsVC"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isShowLabelsVC"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return !isShowLabelsVC;
}

/**************************** 奖励弹窗 ****************************/

/// 展示任务弹窗
+ (void)app_awardMaskToast:(NSString *)type flower:(id)flowerNum showText:(NSString *)name
{
    if (!IS_LOGIN) {
        return;
    }
    NSString *toastName = name.length ? name : @"日常任务";
    NSString *toastKeyWord = name.length ? name : @"日常任务";
    NSString *toastFlower = [NSString stringWithFormat:@"+%@朵花",flowerNum];
    CGFloat toastTime = 0;
    
    if ([name isEqualToString:@"红包"]) {
        CGFloat time = 0.0;
        if ([type isEqualToString:@"prize_money"]) {
            time = 4.5;  // 转盘所以搞延时
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_getPacketCountAndAnimate];
        });
    }else{
        
        if ([type isEqualToString:@"task_share_story"]){         // 分享帖子到社交平台
            
            NSInteger shareAward = [[NSString stringWithFormat:@"%@",flowerNum] integerValue];
            JADoubleShareView *shareView = [[JADoubleShareView alloc] init];
            shareView.flower = shareAward;
            shareView.methodType = [JAConfigManager shareInstance].doubleFloatType;
            [[[[UIApplication sharedApplication] delegate] window] addSubview:shareView];
            
        }else{
            NSString *allName = [NSString stringWithFormat:@"完成%@任务",toastName];
            NSString *keyName = toastKeyWord;
            [[[[UIApplication sharedApplication] delegate] window] ja_taskToastWithTitle:allName keyWord:keyName flower:toastFlower deplay:toastTime];
        }
    }
}

/**************************** 波形图颜色 ****************************/
+ (NSString *)app_waveViewBgImageViewWithType:(int)type {
    NSArray *imageNameArr = @[
                              @"voice_wavebg1",
                              @"voice_wavebg2",
                              @"voice_wavebg3",
                              @"voice_wavebg4",
                              @"voice_wavebg5",
                              @"voice_wavebg6",
                              @"voice_wavebg7"
                              ];
    if (type>=0 && type<=6) {
        return imageNameArr[type];
    }
    return imageNameArr.firstObject;
}

+ (NSDictionary *)app_waveViewColorWithType:(int)type {
    NSMutableArray *colorArr = [NSMutableArray new];
    
    NSMutableDictionary *dic = [NSMutableDictionary new];
    dic[@"vernier_color"] = @"0xD7000D";
    dic[@"wave_color"] = @"0xFF767F";
    dic[@"reply_wave_color"] = @"0xF75549";
    [colorArr addObject:dic];
    
    NSMutableDictionary *dic1 = [NSMutableDictionary new];
    dic1[@"vernier_color"] = @"0x00A7F3";
    dic1[@"wave_color"] = @"0x54C7FC";
    dic1[@"reply_wave_color"] = @"0xFF8743";
    [colorArr addObject:dic1];

    NSMutableDictionary *dic2 = [NSMutableDictionary new];
    dic2[@"vernier_color"] = @"0xECBD00";
    dic2[@"wave_color"] = @"0xF6D700";
    dic2[@"reply_wave_color"] = @"0xF6D700";
    [colorArr addObject:dic2];

    NSMutableDictionary *dic3 = [NSMutableDictionary new];
    dic3[@"vernier_color"] = @"0x31C27C";
    dic3[@"wave_color"] = @"0x7ED321";
    dic3[@"reply_wave_color"] = @"0x6BD379";
    [colorArr addObject:dic3];

    NSMutableDictionary *dic4 = [NSMutableDictionary new];
    dic4[@"vernier_color"] = @"0x7F00FF";
    dic4[@"wave_color"] = @"0xA452F8";
    dic4[@"reply_wave_color"] = @"0x24E1D6";
    [colorArr addObject:dic4];

    NSMutableDictionary *dic5 = [NSMutableDictionary new];
    dic5[@"vernier_color"] = @"0xC2006F";
    dic5[@"wave_color"] = @"0xFF5DBA";
    dic5[@"reply_wave_color"] = @"0x66CCFF";
    [colorArr addObject:dic5];

    NSMutableDictionary *dic6 = [NSMutableDictionary new];
    dic6[@"vernier_color"] = @"0x00A39B";
    dic6[@"wave_color"] = @"0x38EBE2";
    dic6[@"reply_wave_color"] = @"0xCC92FF";
    [colorArr addObject:dic6];

    NSMutableDictionary *dic7 = [NSMutableDictionary new];
    dic7[@"vernier_color"] = @"0xC05500";
    dic7[@"wave_color"] = @"0xFF8828";
    dic7[@"reply_wave_color"] = @"0x6BD379";
    [colorArr addObject:dic7];

    if (type>=0 && type<=7) {
        return colorArr[type];
    }
    return nil;
}

/// 检查是否被禁言
+ (BOOL)app_checkGag {
    NSString *status = [JAUserInfo userInfo_getUserImfoWithKey:User_Status];
    if (status.integerValue == 2) {
        double endTime = [[JAUserInfo userInfo_getUserImfoWithKey:User_ValidTime] doubleValue];
        endTime = endTime/1000.0;
        NSTimeInterval now = [[NSDate date]timeIntervalSince1970];
        double leftTime = endTime - now;
        
        NSString *dataTime = [NSString timeAndDateToString:[JAUserInfo userInfo_getUserImfoWithKey:User_ValidTime]];
        
        if (leftTime > 0) {
            NSInteger days = leftTime/3600/24;
            if (days == 0) {
                days = 1;
            }
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:[NSString stringWithFormat:@"你好,由于多次发布违规内容，你的账号已被禁言，将于%@解封。禁言期间，你将无法发布主贴、回复和私信。如被系统误封，请联系客服申诉。",dataTime]];
            
            return YES;
        } else {
#warning 客户端自己调用解禁言
            [[JAVoiceCommonApi shareInstance] voice_UnGagUser];
        }
    }
    return NO;
}

#warning todo:卡顿
/// 检查该等级是否还能发帖
+ (BOOL)app_checkCanReleaseStory {
    JALevelModel *currentModel = [self currentLevel];
    if (currentModel) {
        JAReleaseStoryCountModel *model = [JAReleaseStoryCountModel searchSingleWithWhere:nil orderBy:nil];
        if (model.storyCount < [currentModel.rightsNum integerValue]) {
            return YES;
        }
    }
    return NO;
}

+ (JALevelModel *)currentLevel {
    NSInteger currentLevel = [[JAUserInfo userInfo_getUserImfoWithKey:User_LevelId] integerValue];
    NSArray *levels = [JAConfigManager shareInstance].levelArray;
    JALevelModel *currentModel = levels.firstObject;
//    NSArray *levels = [JALevelModel searchWithWhere:@{@"rightsType":@"story"} orderBy:@"gradeNum" offset:0 count:1000];
//    NSArray *levels = [JALevelModel searchWithWhere:@{@"rightsType":@"story"}];
    for (int i=0; i<levels.count; i++) {
        JALevelModel *model = levels[i];
        if (currentLevel >= model.gradeNum) {
            // 寻找自己允许的权限
            currentModel = model;
        } else {
            break;
        }
    }
    return currentModel;
}

+ (JARuleModel *)currentNotDepositScore {
    NSArray *listIntegralInfoConfig = [JAConfigManager shareInstance].creditRuleArray;
    JACreditRuleModel *currentRule = nil;
    for (JARuleModel *model in listIntegralInfoConfig) {
        if ([model.dataType isEqualToString:@"not_deposit"]) {
            currentRule = (JACreditRuleModel *)model;
            break;
        }
    }
    return currentRule;
}

+ (JARuleModel *)currentUserMsgScore {
    NSArray *listIntegralInfoConfig = [JAConfigManager shareInstance].creditRuleArray;
    JARuleModel *currentRule = nil;
    for (JARuleModel *model in listIntegralInfoConfig) {
        if ([model.dataType isEqualToString:@"not_user_msg"]) {
            currentRule = model;
            break;
        }
    }
    return currentRule;
}

+ (JARuleModel *)currentAddStoryCommentScore {
    NSArray *listIntegralInfoConfig = [JAConfigManager shareInstance].creditRuleArray;
    JARuleModel *currentRule = nil;
    for (JARuleModel *model in listIntegralInfoConfig) {
        if ([model.dataType isEqualToString:@"not_add_story_comment"]) {
            currentRule = model;
            break;
        }
    }
    return currentRule;
}

/// 发帖数
+ (void)app_getReleaseStoryCount {
    JAReleaseStoryCountModel *model = [JAReleaseStoryCountModel searchSingleWithWhere:nil orderBy:nil];
    if (!model || ![model.lastDate isToday]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"levelId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelId];
        [[JAUserApiRequest shareInstance] userReleaseCount:dic success:^(NSDictionary *result) {
            JAReleaseStoryCountModel *model = [JAReleaseStoryCountModel mj_objectWithKeyValues:result];
            model.lastDate = [NSDate date];
            if (model) {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    [LKDBHelper clearTableData:[JAReleaseStoryCountModel class]];
                    [model saveToDB];
                });
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

@end
