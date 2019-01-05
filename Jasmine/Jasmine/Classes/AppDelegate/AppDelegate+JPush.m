//
//  AppDelegate+JPush.m
//  Jasmine
//
//  Created by xujin on 02/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import <UserNotifications/UserNotifications.h>
#import "JAPostDetailViewController.h"
#import "JAWebViewController.h"
#import "JACenterDrawerViewController.h"
#import "JAHomeLeftView.h"
#import "JASwitchDefine.h"
//#import "JAActivityCenterViewController.h"

#import "JAsynthesizeMessageViewController.h"
#import "JACircleDetailViewController.h"
#import "JAAlbumDetailViewController.h"

#import "CYLTabBarController.h"
#import "JAActivityCenterViewController.h"

@implementation AppDelegate (JPush)

- (void)setupJPushWithLaunchOptions:(NSDictionary *)launchOptions {
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        //    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        //      NSSet<UNNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
        //    else {
        //      NSSet<UIUserNotificationCategory *> *categories;
        //      entity.categories = categories;
        //    }
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    NSString *jpushKey = JA_JPUSH_APPKEY;
#ifdef JA_TEST_HOST

#endif
    // NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:jpushKey
                          channel:JA_CHANNEL
                 apsForProduction:NO
            advertisingIdentifier:nil];
    [JPUSHService setLogOFF];

    // 初始化极光SDK之后，从极光推送获取 Registration Id
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if (resCode == 0) {
            // 将极光推送的 Registration Id 存储在神策分析的用户 Profile "jgiOSId" 中
            [[[SensorsAnalyticsSDK sharedInstance] people] set:@{@"jgiOSId" : registrationID}];
        }
    }];
    
    // 兼容iOS8、9
    if (IOS10) {
//        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
//        NSString *openType = [userInfo valueForKey:@"openType"];
//        NSString *url = [userInfo valueForKey:@"url"];      // openType = 3时 的h5站内跳转地址
//        NSString *type = [userInfo valueForKey:@"type"];     //  answer problem publish story
//        NSString *typeId = [userInfo valueForKey:@"typeId"];   //  站内跳转详情id
//
//        NSMutableDictionary *dic = [NSMutableDictionary new];
//        dic[@"openType"]  = openType;
//        dic[@"url"]  = url;
//        dic[@"type"]  = type;
//        dic[@"typeId"]  = typeId;
//
//        // 展示官方数量
////        [self receiveOfficNoti:openType];
    } else  {
        // ios10以下需要自己处理该内容
        NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        
        //        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"app杀死后" message:[userInfo mj_JSONString] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        //        [alertView show];
        if (userInfo[@"_j_business"]) {
            [self handleJPushNotification:userInfo];
        } else if (userInfo[@"nim"]) {  // 启动处理推送消息
            NSLog(@"nim");
            [self pushArrive_jump:userInfo type:1];
        }
        [self sensorsAnalyticsClickPushContent:[NSString stringWithFormat:@"%@",userInfo[@"_j_msgid"]] title:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]]];
    }
    
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
}

// 极光透传
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    // 解析服务器数据
    NSDictionary *dic = notification.userInfo;
    NSLog(@"%@",dic);
    if ([dic[@"content_type"] integerValue] == 0 || [dic[@"content_type"] integerValue] == 3) {
        // 根据透传消息展示红点
        [self receiveOfficNoti];
    }
}

#pragma mark - JPUSHRegisterDelegate
// iOS 10 Support 前台
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
//
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"极光前台" message:[userInfo mj_JSONString] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alertView show];
// 
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        if (userInfo[@"_j_business"]) {
            [self handleJPushNotification:userInfo];
        } else if (userInfo[@"nim"]) {  // ios10 前台处理推送消息
            NSLog(@"nim");
            [self pushArrive_jump:userInfo type:1];
        }
        NSLog(@"iOS10 前台收到远程通知:%@", [self logDic:userInfo]);
    }
    else {
        UNNotificationRequest *request = notification.request; // 收到推送的请求
        UNNotificationContent *content = request.content; // 收到推送的消息内容
        
        NSNumber *badge = content.badge;  // 推送消息的角标
        NSString *body = content.body;    // 推送消息体
        UNNotificationSound *sound = content.sound;  // 推送消息的声音
        NSString *subtitle = content.subtitle;  // 推送消息的副标题
        NSString *title = content.title;  // 推送消息的标题
        // 判断为本地通知
        NSLog(@"iOS10 前台收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    [self sensorsAnalyticsPushContentReceive:[NSString stringWithFormat:@"%@",userInfo[@"_j_msgid"]] title:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]]];
    
//    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置

}

// iOS 10 Support 后台或者kill掉
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {

    // Required
    NSDictionary *userInfo = response.notification.request.content.userInfo;
//    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"极光后台" message:[userInfo mj_JSONString] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alertView show];
//    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        if (userInfo[@"_j_business"]) {
            [self handleJPushNotification:userInfo];
        } else if (userInfo[@"nim"]) {  // ios10 后台处理推送
            NSLog(@"nim");
            [self pushArrive_jump:userInfo type:1];
        }
        NSLog(@"iOS10 收到远程JPush通知:%@", [self logDic:userInfo]);
    } else {
        NSDictionary * userInfo = response.notification.request.content.userInfo;
        UNNotificationRequest *request = response.notification.request; // 收到推送的请求
        UNNotificationContent *content = request.content; // 收到推送的消息内容
        
        NSNumber *badge = content.badge;  // 推送消息的角标
        NSString *body = content.body;    // 推送消息体
        UNNotificationSound *sound = content.sound;  // 推送消息的声音
        NSString *subtitle = content.subtitle;  // 推送消息的副标题
        NSString *title = content.title;  // 推送消息的标题
       
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\nbody:%@，\ntitle:%@,\nsubtitle:%@,\nbadge：%@，\nsound：%@，\nuserInfo：%@\n}",body,title,subtitle,badge,sound,userInfo);
    }

    completionHandler();  // 系统要求执行这个方法
    
    
    [self sensorsAnalyticsClickPushContent:[NSString stringWithFormat:@"%@",userInfo[@"_j_msgid"]] title:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]]];
}

// iOS 7、8、9收到本地通知
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

// iOS 7、8、9收到远程通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"ios10以下" message:[userInfo mj_JSONString] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//    [alertView show];
//    
    if (userInfo[@"_j_business"]) {
        [self handleJPushNotification:userInfo];
    } else if (userInfo[@"nim"]) {    // ios7,8,9 处理推送
        NSLog(@"nim");
        [self pushArrive_jump:userInfo type:1];
    }
    completionHandler(UIBackgroundFetchResultNewData);
    
    if (application.applicationState == UIApplicationStateActive) {
        
       [self sensorsAnalyticsPushContentReceive:[NSString stringWithFormat:@"%@",userInfo[@"_j_msgid"]] title:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]]];
    }
    else if (application.applicationState == UIApplicationStateBackground)
    {
        [self sensorsAnalyticsPushContentReceive:[NSString stringWithFormat:@"%@",userInfo[@"_j_msgid"]] title:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]]];
    }
    else if (application.applicationState == UIApplicationStateInactive)
    {
        // 用户点击通知栏打开消息，使用收到推送消息类似的方法，使用 Sensors Analytics 记录 "App 打开消息" 事件
        [self sensorsAnalyticsClickPushContent:[NSString stringWithFormat:@"%@",userInfo[@"_j_msgid"]] title:[NSString stringWithFormat:@"%@",userInfo[@"aps"][@"alert"]]];
    }
}


// 处理极光推送
- (void)handleJPushNotification:(NSDictionary *)userInfo {
    
    [JPUSHService handleRemoteNotification:userInfo];
    [self pushArrive_jump:userInfo type:0];
//    // 取得 APNs 标准信息内容
//    NSDictionary *aps = [userInfo valueForKey:@"aps"];
//    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
//#warning 2.4.1 区分alert是字符串还是对象
//    if ([[aps valueForKey:@"alert"] isKindOfClass:[NSString class]]) {
//        content = [aps valueForKey:@"alert"];
//    }else if([[aps valueForKey:@"alert"] isKindOfClass:[NSDictionary class]]){
//        if (IOS10) {
//            NSDictionary *alertD = [aps valueForKey:@"alert"];
//            content = alertD[@"title"];
//        }else{
//            NSDictionary *alertD = [aps valueForKey:@"alert"];
//            content = alertD[@"title"];
//        }
//    }
//
//    // 取得Extras字段内容
//    //openType 0 活动中心页  1 App首页  2  内容详情页面 3 h5页面地址
//    if ([userInfo valueForKey:@"openType"]) {
//        NSString *openType = [userInfo valueForKey:@"openType"];
//        NSString *url = [userInfo valueForKey:@"url"];      // openType = 3时 的h5站内跳转地址
//        NSString *type = [userInfo valueForKey:@"type"];     //  answer problem publish story
//        NSString *typeId = [userInfo valueForKey:@"typeId"];   //  站内跳转详情id
//
//        NSMutableDictionary *dic = [NSMutableDictionary new];
//        dic[@"openType"]  = openType;
//        dic[@"url"]  = url;
//        dic[@"type"]  = type;
//        dic[@"typeId"]  = typeId;
//        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
//            switch (openType.integerValue) {
//                case 2:
//                case 3:
//                {
//                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"热门推荐" message:content preferredStyle:UIAlertControllerStyleAlert];
//                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"立即查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        // 通知跳转
//                        [self jumpNoti:dic];
//                    }];
//
//                    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//                    }];
//
//                    [alert addAction:action1];
//                    [alert addAction:action2];
//
//                    if (IS_LOGIN) {
//
//                        [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
//                    }
//                }
//                    break;
//                default:
//                    break;
//            }
//        } else {
//            // 通知跳转
//            [self jumpNoti:dic];
//        }
//    }
}

// 前后台跳转处理
- (void)pushArrive_jump:(NSDictionary *)userInfo type:(NSInteger)type  // 0 极光 1 云信
{
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
#warning 2.4.1 区分alert是字符串还是对象
    if ([[aps valueForKey:@"alert"] isKindOfClass:[NSString class]]) {
        content = [aps valueForKey:@"alert"];
    }else if([[aps valueForKey:@"alert"] isKindOfClass:[NSDictionary class]]){
        if (IOS10) {
            NSDictionary *alertD = [aps valueForKey:@"alert"];
            content = alertD[@"title"];
        }else{
            NSDictionary *alertD = [aps valueForKey:@"alert"];
            content = alertD[@"title"];
        }
    }
    
    // 取得Extras字段内容
    //openType 0 活动中心页  1 App首页  2  内容详情页面 3 h5页面地址
    if ([userInfo valueForKey:@"openType"]) {
        NSString *openType = [userInfo valueForKey:@"openType"];
        NSString *url = [userInfo valueForKey:@"url"];      // openType = 3时 的h5站内跳转地址
        NSString *type = [userInfo valueForKey:@"type"];     //  answer problem publish story
        NSString *typeId = [userInfo valueForKey:@"typeId"];   //  站内跳转详情id
        
        NSMutableDictionary *dic = [NSMutableDictionary new];
        dic[@"openType"]  = openType;
        dic[@"url"]  = url;
        dic[@"type"]  = type;
        dic[@"typeId"]  = typeId;
        if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
            switch (openType.integerValue) {
                case 2:
                case 3:
                {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"热门推荐" message:content preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"立即查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        // 通知跳转
                        [self jumpNoti:dic];
                    }];
                    
                    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    [alert addAction:action1];
                    [alert addAction:action2];
                    
                    if (IS_LOGIN) {
                        
                        [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
                    }
                }
                    break;
                default:
                    break;
            }
        } else {
            // 通知跳转
            [self jumpNoti:dic];
        }
    }
}

// log NSSet with UTF8
// if not ,log will be \Uxxx
- (NSString *)logDic:(NSDictionary *)dic {
    if (![dic count]) {
        return nil;
    }
    NSString *tempStr1 =
    [[dic description] stringByReplacingOccurrencesOfString:@"\\u"
                                                 withString:@"\\U"];
    NSString *tempStr2 =
    [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 =
    [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str =
    [NSPropertyListSerialization propertyListFromData:tempData
                                     mutabilityOption:NSPropertyListImmutable
                                               format:NULL
                                     errorDescription:NULL];
    return str;
}

- (void)jumpNoti:(NSDictionary *)dic
{
    NSString *openType = dic[@"openType"];
    if (!openType.length) {
        return;
    }
    [self jump:dic];
}

/*
    0 活动中心
    1 首页
    2 帖子详情
    3 web页面
    4 消息回复
    5 消息关注
    6 消息邀请
    7 首页关注
 */
- (void)jump:(NSDictionary *)notiDic
{
    JABaseNavigationController *nav = [AppDelegateModel getBaseNavigationViewControll];
    
    if (notiDic) {
        NSDictionary *dic = notiDic;
        if ([dic[@"openType"] integerValue] == 0 || [dic[@"openType"] integerValue] == 109) {
//            JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
//            vc.selectIndex = 0;
//            [nav pushViewController:vc animated:YES];
            JAActivityCenterViewController *vc = [[JAActivityCenterViewController alloc] init];
            [nav pushViewController:vc animated:YES];
            
        }else if([dic[@"openType"] integerValue] == 1 || [dic[@"openType"] integerValue] == 123){
            
        }else if ([dic[@"openType"] integerValue] == 2 || [dic[@"openType"] integerValue] == 127){
            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            vc.voiceId = dic[@"typeId"];
            [nav pushViewController:vc animated:YES];
            
        }else if ([dic[@"openType"] integerValue] == 3 || [dic[@"openType"] integerValue] == 300){
            JAWebViewController *vc = [JAWebViewController new];
            NSString *str = dic[@"url"];
            if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
                vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
            }else{
                vc.urlString = str;
            }
            vc.enterType = @"推送";
            [nav pushViewController:vc animated:YES];
            
            
        }else if([dic[@"openType"] integerValue] == 4 || [dic[@"openType"] integerValue] == 104){
 
//            JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
//            vc.selectIndex = 1;
//            [nav pushViewController:vc animated:NO];
            [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
            [self cyl_tabBarController].selectedIndex = 2;
            
            
        }else if([dic[@"openType"] integerValue] == 5 || [dic[@"openType"] integerValue] == 107){
            
//            JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
//            vc.selectIndex = 1;
//            [nav pushViewController:vc animated:NO];
            [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
            [self cyl_tabBarController].selectedIndex = 2;
            
        }else if([dic[@"openType"] integerValue] == 6 || [dic[@"openType"] integerValue] == 106){
            
//            JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
//            vc.selectIndex = 1;
//            [nav pushViewController:vc animated:NO];
            
            [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
            [self cyl_tabBarController].selectedIndex = 2;
            
            
        }else if([dic[@"openType"] integerValue] == 7 || [dic[@"openType"] integerValue] == 124){
            
            // 回到首页
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
                    // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
                    [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                }];
                [nav popToRootViewControllerAnimated:NO];
                
                JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
                [vc.titleView setSelectedItemIndex:0];
            });
        }else if ([dic[@"openType"] integerValue] == 130){
            JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
            vc.circleId = dic[@"typeId"];
            [nav pushViewController:vc animated:YES];
        }else if ([dic[@"openType"] integerValue] == 131){
            JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
            vc.subjectId = dic[@"typeId"];
            [nav pushViewController:vc animated:YES];
        }
    }
}

// push点击
- (void)sensorsAnalyticsClickPushContent:(NSString *)pushid title:(NSString *)title
{
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_PushId] = pushid;
    senDic[JA_Property_PushTitle] = title;
    [JASensorsAnalyticsManager sensorsAnalytics_clickPushContent:senDic];
}

// push到达
- (void)sensorsAnalyticsPushContentReceive:(NSString *)pushid title:(NSString *)title
{
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_PushId] = pushid;
    senDic[JA_Property_PushTitle] = title;
    [JASensorsAnalyticsManager sensorsAnalytics_ReceivePushContent:senDic];
}

// 接受到推送 - 活动
- (void)receiveOfficNoti
{
    [JARedPointManager hasNewRedPointArrive:JARedPointTypeActivity];
}
@end
