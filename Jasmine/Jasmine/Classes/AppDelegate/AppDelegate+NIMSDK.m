//
//  AppDelegate+NIMSDK.m
//  Jasmine
//
//  Created by xujin on 02/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "AppDelegate+NIMSDK.h"
#import "NTESCustomAttachmentDecoder.h"
#import "NTESCellLayoutConfig.h"
#import "AppDelegateModel.h"
#import "JASwitchDefine.h"

@implementation AppDelegate (NIMSDK)

- (void)setupNIMSDK {
    [[NIMSDKConfig sharedConfig] setShouldSyncUnreadCount:YES];
    [[NIMSDKConfig sharedConfig] setMaxAutoLoginRetryTimes:10];
    
    
    
    NSString *yxAppKey = JA_YX_APPKEY;
    NSString *yxApnsCername = @"pushproduct";
#ifdef JA_TEST_HOST
    if (![[JAConfigManager shareInstance].host containsString:@"data.urmoli.com"]) {
        yxAppKey = JA_YX_APPKEY_TEST;
        yxApnsCername = @"developpush";
    } else {
        yxAppKey = JA_YX_APPKEY;
        yxApnsCername = @"pushproduct";
    }
#endif
    // 初始化 云信
    NIMSDKOption *option = [NIMSDKOption optionWithAppKey:yxAppKey];
    option.apnsCername = yxApnsCername;
    option.pkCername = yxApnsCername;
    [[NIMSDK sharedSDK] registerWithOption:option];
    
    [JAChatMessageManager yx_autoLoginYX];
    [[NIMSDK sharedSDK].loginManager addDelegate:self];
    
    //注册自定义消息的解析器
    [NIMCustomObject registerCustomDecoder:[NTESCustomAttachmentDecoder new]];
    //注册 NIMKit 自定义排版配置
    [[NIMKit sharedKit] registerLayoutConfig:[NTESCellLayoutConfig new]];
}

#pragma mark - NIMLoginManagerDelegate
// 自动登录的回调
- (void)onLogin:(NIMLoginStep)step
{
    
    switch (step) {
        case NIMLoginStepLinkOK:
            NSLog(@"云信连接服务器成功");
            break;
        case NIMLoginStepLinkFailed:
            NSLog(@"云信连接服务器失败");
            break;
        case NIMLoginStepLoginOK:
            NSLog(@"云信自动登录成功");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"yx_loginSuccess" object:nil];
            break;
        case NIMLoginStepLoginFailed:
            NSLog(@"云信自动登录失败");
            
        default:
            break;
    }
    
}


// 账号被T
-(void)onKick:(NIMKickReason)code
   clientType:(NIMLoginClientType)clientType
{
    
//#ifdef JA_TEST_HOST
//    [MBProgressHUD showMessage:[NSString stringWithFormat:@"%ld",code]];
//#endif
//    
    [self.window ja_makeToast:@"您的账号已在其他设备登录"];
    
    // 退出登录
    [JAAPPManager app_loginOut];
    
//    [JAUserInfo userinfo_saveUserLoginState:NO];
//    [JAUserInfo userInfo_deleteUserInfo];
//    
//    // 回到首页
////    [[DrawerViewController shareDrawer] closeLeftMenu];
//    [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
//        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    }];
//    JABaseNavigationController *nav = [AppDelegateModel getBaseNavigationViewControll];
//    [nav popToRootViewControllerAnimated:YES];
//    
//    [JAAPPManager app_modalLogin];
}

// 当用户在某个客户端登录时，其他没有被踢掉的端会触发回调:
- (void)onMultiLoginClientsChanged
{
    [self.window ja_makeToast:@"您的账号已在其他设备登录"];
    // 退出登录    
    [JAAPPManager app_loginOut];
    
//    [JAUserInfo userinfo_saveUserLoginState:NO];
//    [JAUserInfo userInfo_deleteUserInfo];
//    // 退出云信
//    [[QYSDK sharedSDK] logout:^(){}];
//    [JAChatMessageManager yx_loginOutYX];
//    
//    // 删除别名
//    [JPUSHService setAlias:nil completion:nil seq:0];
//    
//    // 回到首页
////    [[DrawerViewController shareDrawer] closeLeftMenu];
//    [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
//        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    }];
//    JABaseNavigationController *nav = [AppDelegateModel getBaseNavigationViewControll];
//    [nav popToRootViewControllerAnimated:YES];
//    
//    [JAAPPManager app_modalLogin];
}

// 自动登录失败的回调
- (void)onAutoLoginFailed:(NSError *)error
{
    if (error.code == 417) {
        
        // 表示不同设备登录 -- 不用处理
        NSLog(@"不同设备登录 - 被拒绝");
    }
    
    NSLog(@"云信自动登录失败");
}

@end
