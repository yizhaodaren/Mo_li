
//
//  AppDelegate.m
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "AppDelegateModel.h"
#import "JAIMManager.h"
#import "CYLTabBarController.h"

#import <iflyMSC/IFlyMSC.h>
#import <Bugly/Bugly.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WeiboSDK.h"
#import "WXApi.h"
#import "JAUserApiRequest.h"
#import "XDLocationTool.h"
#import "JACommonApi.h"

#import "AppDelegate+JPush.h"
#import "AppDelegate+NIMSDK.h"
#import "FPSDisplay.h"
#import "JADoubleShareView.h"
#import "UIDevice-Hardware.h"
#import "JALaunchADManager.h"
#import "JAWebViewController.h"
#import "JASwitchDefine.h"
#import "JASpeechRecognizerManager.h"
#import "JAPasteboardHelper.h"
#import "JAVoicePlayerManager.h"
#import "JANewPlayTool.h"
#import "JAMusicListModel.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate,TencentSessionDelegate,WeiboSDKDelegate,WXApiDelegate,QQApiInterfaceDelegate>
{
    //后台播放任务Id
    UIBackgroundTaskIdentifier _bgTaskId;
}

@property (nonatomic, strong) AppDelegateModel *appDelegateModel;

@end

@implementation AppDelegate


+ (AppDelegate *)sharedInstance
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _packetArray = [NSMutableArray array];
    
    // 配置app本身参数
    [UIApplication sharedApplication].statusBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self setupApperance];
    
    // 配置ytk
    YTKNetworkAgent *agent = [YTKNetworkAgent sharedAgent];
    NSSet *acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html", @"text/css", nil];
    NSString *keypath = @"jsonResponseSerializer.acceptableContentTypes";
    [agent setValue:acceptableContentTypes forKeyPath:keypath];
    
    // 创建本地通知
    //    [self createLocalizedUserNotification];
    
    // UMengAnalytics
    NSInteger platformType = [[UIDevice currentDevice] platformType];
    if (platformType == UIDeviceSimulator ||
        platformType == UIDeviceSimulatoriPhone ||
        platformType == UIDeviceSimulatoriPad ||
        platformType == UIDeviceSimulatorAppleTV) {
        // 模拟器不初始化友盟统计
    } else {
        UMConfigInstance.appKey = JA_UMENT_ANALYTICS_APPKEY;
        UMConfigInstance.channelId = JA_CHANNEL;
        [MobClick setAppVersion:XcodeAppVersion];
        [MobClick startWithConfigure:UMConfigInstance];
    }
    
    // 三方登录
    TencentOAuth *tencentOAuth = [[TencentOAuth alloc] initWithAppId:JA_Tencent_APPID andDelegate:self];;
    _tencentOAuth = tencentOAuth;
    
    [WeiboSDK enableDebugMode:NO];
    [WeiboSDK registerApp:JA_WEIBO_APPID];
    
    [WXApi registerApp:JA_WECHAT_APPID];
    
    // 初始化云信
    [self setupNIMSDK];
    // 初始化七鱼
    [[QYSDK sharedSDK] registerAppId:JA_QY_APPID appName:@"茉莉"];
    
    // 极光推送
    // 注：苹果推送的权限申请一次即可，所有的推送回调均在JPush里处理
    [self setupJPushWithLaunchOptions:launchOptions];
    
    // bugly
    BuglyConfig * config = [[BuglyConfig alloc] init];
    config.reportLogLevel = BuglyLogLevelWarn;
    config.blockMonitorEnable = YES;
    config.blockMonitorTimeout = 2;
    config.unexpectedTerminatingDetectionEnable = YES;
    config.version = [STSystemHelper getApp_version];
    config.deviceIdentifier = [NSString stringWithFormat:@"%@ %@",[STSystemHelper iphoneNameAndVersion], [[UIDevice currentDevice] systemVersion]];
    NSString *strId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if (strId.length) {
        [Bugly setUserIdentifier:strId];
    }
    [Bugly startWithAppId:@"1e3f04828b" config:config];
    
    // 神策统计
    SensorsAnalyticsDebugMode mode = SensorsAnalyticsDebugOff;
    NSString *serverURL = [JAConfigManager shareInstance].saServerUrl;
    NSString *configureURL = [JAConfigManager shareInstance].saConfigUrl;
#ifdef JA_TEST_HOST
    mode = SensorsAnalyticsDebugAndTrack;
    if (!serverURL.length || !configureURL.length) {
        serverURL = @"https://wap.xsawe.top/sa?project=default";
        configureURL = @"https://wap.xsawe.top/config/?project=default";
    }
#else
    if (!serverURL.length || !configureURL.length) {
        serverURL = @"https://wap.xsawe.top/sa?project=production";
        configureURL = @"https://wap.xsawe.top/config/?project=production";
    }
#endif
    
    
    
    [SensorsAnalyticsSDK sharedInstanceWithServerURL:serverURL andLaunchOptions:configureURL andDebugMode:mode];
//    [SensorsAnalyticsSDK sharedInstanceWithServerURL:serverURL
//                                     andConfigureURL:configureURL
//                                        andDebugMode:mode];
    // v2.4.0调用提前
    if (IS_LOGIN) {
        // 登录神策
        [JASensorsAnalyticsManager sensorsAnalytics_login];
        [JASensorsAnalyticsManager sensorsAnalytics_setUser];
    }
    [[SensorsAnalyticsSDK sharedInstance] registerSuperProperties:@{@"platform" : JA_PLATFORM}];
    [[SensorsAnalyticsSDK sharedInstance] enableAutoTrack:SensorsAnalyticsEventTypeAppStart | SensorsAnalyticsEventTypeAppEnd];
    [[SensorsAnalyticsSDK sharedInstance] trackInstallation:JA_Event_AppInstall];
    [[SensorsAnalyticsSDK sharedInstance] addWebViewUserAgentSensorsDataFlag];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // v2.5.0 讯飞语音识别
        [IFlyDebugLog setShowLog:NO];
        NSString *initString = [[NSString alloc] initWithFormat:@"appid=%@",@"5a4f614c"];
        //Configure and initialize iflytek services.(This interface must been invoked in application:didFinishLaunchingWithOptions:)
        [IFlySpeechUtility createUtility:initString];        
    });
    
    // 读取音频列表
    [self getCachMusicList];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.appDelegateModel = [AppDelegateModel shareInstance];
    [self.appDelegateModel setup];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // 创建音量条
    JANewPlayerView *playerView = [[JANewPlayerView alloc] init];
    _playerView = playerView;
    [[self cyl_tabBarController].view addSubview:playerView];
    [playerView playerView_animateAndHidden];
    
    return YES;
}

- (void)setupApperance {
    [[UITextView appearance] setTintColor:HEX_COLOR(JA_Green)];
    [[UITextField appearance] setTintColor:HEX_COLOR(JA_Green)];
    [[UIWebView appearance] setTintColor:HEX_COLOR(JA_Green)];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName:HEX_COLOR(JA_BlackTitle),
                                                           NSFontAttributeName:JA_MEDIUM_FONT(16)}];
//    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
//    [[UIApplication  sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
//    //不能使用imageWithColor，需要UI切图实现1px的线条
//    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"fafafa"]] forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"nav_bottom_line"]];
//    UIImage *backImage = [[UIImage imageNamed:@"fanhui_heise"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    [[UINavigationBar appearance] setBackIndicatorImage:backImage];
//    [[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:backImage];
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-1000, 0)
//                                                         forBarMetrics:UIBarMetricsDefault];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.

    //这样做，可以在按home键进入后台后 ，播放一段时间，几分钟吧。但是不能持续播放网络歌曲，若需要持续播放网络歌曲，还需要申请后台任务id，具体做法是：
//    __bgTaskIdId=[AppDelegate backgroundPlayerID:__bgTaskIdId];
    //其中的__bgTaskIdId是后台任务UIBackgroundTaskIdentifier __bgTaskIdId;
}

// 实现一下backgroundPlayerID:这个方法:
+(UIBackgroundTaskIdentifier)backgroundPlayerID:(UIBackgroundTaskIdentifier)backTaskId
{
    //设置并激活音频会话类别
//    AVAudioSession *session=[AVAudioSession sharedInstance];
//    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
//    [session setActive:YES error:nil];
    //允许应用程序接收远程控制
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    if(newTaskId!=UIBackgroundTaskInvalid&&backTaskId!=UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:backTaskId];
    }
    return newTaskId;
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    _bgTaskId = [application beginBackgroundTaskWithExpirationHandler:^{
        // 10分钟后执行这里，应该进行一些清理工作，如断开和服务器的连接等
         [self saveMusicList];
        // stopped or ending the task outright.
        [application endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
    // 如果没到10分钟又打开了app,结束后台任务
    if (_bgTaskId!=UIBackgroundTaskInvalid) {
        [application endBackgroundTask:_bgTaskId];
        _bgTaskId = UIBackgroundTaskInvalid;
    }
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // 处理pasteboard
    [JAPasteboardHelper handleActiviey];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [self saveMusicList];
    [self.releasevc saveDraft:NO];
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
{
    BOOL handleWXSuccess = NO;
    BOOL handleTencentSuccess = NO;
    BOOL handleQQApiSuccess = NO;
    BOOL handleSinaWeiboSuccess = NO;
    if ([[url absoluteString] hasSuffix:@"platformId=wechat"])
    {
        handleWXSuccess = [WXApi handleOpenURL:url delegate:self];
    }
    if ([[url absoluteString] hasPrefix:@"wx7c1df1136554af6a://oauth"])
    {
        handleWXSuccess = [WXApi handleOpenURL:url delegate:self];
    }
    
    if ([TencentOAuth CanHandleOpenURL:url])
    {
        handleTencentSuccess = [TencentOAuth HandleOpenURL:url];
    }
    
    handleQQApiSuccess = [QQApiInterface handleOpenURL:url delegate:self];
    
    handleSinaWeiboSuccess = [WeiboSDK handleOpenURL:url delegate:self];;
//     [TencentOAuth HandleOpenURL:url];
//    [WXApi handleOpenURL:url delegate:self];
//    [WeiboSDK handleOpenURL:url delegate:self];
//    [QQApiInterface handleOpenURL:url delegate:self];
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
//    BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
//    if (!result) {
//        // 其他如支付等SDK的回调
//    }
    return (handleTencentSuccess || handleWXSuccess || handleQQApiSuccess || handleSinaWeiboSuccess);
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL handleWXSuccess = NO;
    BOOL handleTencentSuccess = NO;
    BOOL handleQQApiSuccess = NO;
    BOOL handleSinaWeiboSuccess = NO;
    if ([[url absoluteString] hasSuffix:@"platformId=wechat"])
    {
        handleWXSuccess = [WXApi handleOpenURL:url delegate:self];
    }
    if ([[url absoluteString] hasPrefix:@"wx7c1df1136554af6a://oauth"])
    {
        handleWXSuccess = [WXApi handleOpenURL:url delegate:self];
    }
    
    if ([TencentOAuth CanHandleOpenURL:url])
    {
        handleTencentSuccess = [TencentOAuth HandleOpenURL:url];
    }
    
    handleQQApiSuccess = [QQApiInterface handleOpenURL:url delegate:self];
    
    handleSinaWeiboSuccess = [WeiboSDK handleOpenURL:url delegate:self];;
//    [TencentOAuth HandleOpenURL:url];
//    [WXApi handleOpenURL:url delegate:self];
//    [WeiboSDK handleOpenURL:url delegate:self];
//    [QQApiInterface handleOpenURL:url delegate:self];
    return (handleTencentSuccess || handleWXSuccess || handleQQApiSuccess || handleSinaWeiboSuccess);
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL handleWXSuccess = NO;
    BOOL handleTencentSuccess = NO;
    BOOL handleQQApiSuccess = NO;
    BOOL handleSinaWeiboSuccess = NO;
    if ([[url absoluteString] hasSuffix:@"platformId=wechat"])
    {
        handleWXSuccess = [WXApi handleOpenURL:url delegate:self];
    }
    if ([[url absoluteString] hasPrefix:@"wx7c1df1136554af6a://oauth"])
    {
        handleWXSuccess = [WXApi handleOpenURL:url delegate:self];
    }
    
    if ([TencentOAuth CanHandleOpenURL:url])
    {
        handleTencentSuccess = [TencentOAuth HandleOpenURL:url];
    }
    
    handleQQApiSuccess = [QQApiInterface handleOpenURL:url delegate:self];
    
    handleSinaWeiboSuccess = [WeiboSDK handleOpenURL:url delegate:self];;
//    [TencentOAuth HandleOpenURL:url];
//    [WXApi handleOpenURL:url delegate:self];
//    [WeiboSDK handleOpenURL:url delegate:self];
//    [QQApiInterface handleOpenURL:url delegate:self];
//    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
//    if (!result) {
//        // 其他如支付等SDK的回调
//    }
    return (handleTencentSuccess || handleWXSuccess || handleQQApiSuccess || handleSinaWeiboSuccess);
}

#pragma  mark - 获取device Token
//获取DeviceToken成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
    [[NIMSDK sharedSDK] updateApnsToken:deviceToken];
}

//获取DeviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

//- (void)jumpNoti:(NSDictionary *)dic
//{
//    NSString *openType = dic[@"openType"];
//    if (!openType.length) {
//        return;
//    }
//    self.notiDic = dic;
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"jumpNoti" object:nil];
//}

//定时推送
- (void)createLocalizedUserNotification
{
    
    // 设置触发条件 UNNotificationTrigger
    UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:7000 repeats:YES];
    
    // 创建通知内容 UNMutableNotificationContent, 注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"Dely 时间提醒 - title";
    content.subtitle = [NSString stringWithFormat:@"Dely 装逼大会竞选时间提醒 - subtitle"];
    content.body = @"Dely 装逼大会总决赛时间到，欢迎你参加总决赛！希望你一统X界 - body";
    content.badge = @666;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
    
    // 创建通知标示
    NSString *requestIdentifier = @"Dely.X.time";
    
    // 创建通知请求 UNNotificationRequest 将触发条件和通知内容添加到请求中
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:timeTrigger];
    
    UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
    // 将通知请求 add 到 UNUserNotificationCenter
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            
        }
    }];
    
}


- (void)isOnlineResponse:(NSDictionary *)response {
    
}

// QQ登录的回调
- (void)tencentDidLogin
{
    [self.tencentOAuth getUserInfo];
    
    if (IS_LOGIN) {    // APP 内绑定QQ
        [MBProgressHUD showMessage:nil];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"platformType"] = @"1";
        dic[@"platformUid"] = self.tencentOAuth.openId;
        dic[@"accessToken"] =  self.tencentOAuth.accessToken;
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        [[JAUserApiRequest shareInstance] userWithDrawBindingPlatform:dic success:^(NSDictionary *result) {
            [MBProgressHUD hideHUD];
//            NSLog(@"%@",result);
            [JAUserInfo userInfo_updataUserInfoWithKey:User_PlatformQQUid value:result[@"resMap"][@"platformQqUid"]];
            [JAUserInfo userInfo_updataUserInfoWithKey:User_PlatformQQName value:result[@"resMap"][@"platformQqName"]];
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"绑定成功"];
            [self sensorsAnalyticsWithMothod:@"绑定" type:@"qq" success:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"bindingPlatform" object:nil];
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [self sensorsAnalyticsWithMothod:@"绑定" type:@"qq" success:NO];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"绑定QQ失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"需要帮助" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                JAWebViewController *vc = [[JAWebViewController alloc] init];
                vc.urlString = @"http://www.urmoli.com/newmoli/views/app/about/wx_cash_newquestion.html";
                [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
            }];
            
            [alert addAction:action2];
            [alert addAction:action1];
            
            [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
        }];
        
    }else{
        
        [MBProgressHUD showMessage:nil];
        [[JAUserApiRequest shareInstance] loginUserWithPlatformType:@"1" platformUid:self.tencentOAuth.openId accessToken:self.tencentOAuth.accessToken success:^(NSDictionary *result) {
            if (result[@"resMap"]) {
                [MBProgressHUD hideHUD];
                [JAAPPManager app_loginSuccessWithResult:result loginType:1];
                [[NSNotificationCenter defaultCenter] postNotificationName:PlatformLoginSuccess object:nil userInfo:nil];
                
            }else{
                // 三方注册
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"platformType"] = @"1";
                dic[@"platformUid"] = result[@"platformuserobj"][@"id"];
                dic[@"accessToken"] = result[@"platformuserobj"][@"accessToken"];
                dic[@"platformMark"] = JA_CHANNEL;
                [self platformRegist:dic];
            }
        }];
    }
}
- (void)getUserInfoResponse:(APIResponse *)response
{
    
//    NSLog(@"%@",response.jsonResponse);
}
-(void)tencentDidNotLogin:(BOOL)cancelled
{

}
-(void)tencentDidNotNetWork
{
    
}

// 微博登录的回调
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        
        //1.0 保存access token
        WBAuthorizeResponse *authRes = (WBAuthorizeResponse *)response;
        _weiboAccessToken = authRes.accessToken;
        NSLog(@"微博登录获取的数据 - %@",authRes.userInfo);
        if (!response.userInfo) return;

        if (IS_LOGIN) {    // APP 内绑定微博
            [MBProgressHUD showMessage:nil];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"platformType"] = @"3";
            dic[@"platformUid"] = authRes.userInfo[@"uid"];
            dic[@"accessToken"] =  authRes.userInfo[@"access_token"];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            [[JAUserApiRequest shareInstance] userWithDrawBindingPlatform:dic success:^(NSDictionary *result) {
                [MBProgressHUD hideHUD];
//                NSLog(@"%@",result);
                [JAUserInfo userInfo_updataUserInfoWithKey:User_PlatformWBUid value:result[@"resMap"][@"platformWbUid"]];
                [JAUserInfo userInfo_updataUserInfoWithKey:User_PlatformWBName value:result[@"resMap"][@"platformWbName"]];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"绑定成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bindingPlatform" object:nil];
                [self sensorsAnalyticsWithMothod:@"绑定" type:@"微博" success:YES];
            } failure:^(NSError *error) {
                [MBProgressHUD hideHUD];
                [self sensorsAnalyticsWithMothod:@"绑定" type:@"微博" success:NO];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"绑定微博失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"需要帮助" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    JAWebViewController *vc = [[JAWebViewController alloc] init];
                    vc.urlString = @"http://www.urmoli.com/newmoli/views/app/about/wx_cash_newquestion.html";
                    [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
                }];
                
                [alert addAction:action2];
                [alert addAction:action1];
                
                [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
                
            }];
            
        }else{
            [MBProgressHUD showMessage:nil];
            [[JAUserApiRequest shareInstance] loginUserWithPlatformType:@"3" platformUid:authRes.userInfo[@"uid"] accessToken:authRes.userInfo[@"access_token"] success:^(NSDictionary *result) {
                if (result[@"resMap"]) {
                    [MBProgressHUD hideHUD];
                    [JAAPPManager app_loginSuccessWithResult:result loginType:3];
                    [[NSNotificationCenter defaultCenter] postNotificationName:PlatformLoginSuccess object:nil userInfo:nil];
                }else{
                    
                    // 三方注册
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    dic[@"platformType"] = @"3";
                    dic[@"platformUid"] = result[@"platformuserobj"][@"id"];
                    dic[@"accessToken"] = result[@"platformuserobj"][@"accessToken"];
                    dic[@"platformMark"] = JA_CHANNEL;
                    [self platformRegist:dic];
                }
            }];
        }
    }else if ([response isKindOfClass:[WBSendMessageToWeiboResponse class]]){
        
        /**
         *  分享到微博完成之后的response
         */
        WBSendMessageToWeiboResponse *sendMessageRes = (WBSendMessageToWeiboResponse *)response;
        _weiboAccessToken = sendMessageRes.authResponse.accessToken;
        // 微博分享后
        if ([_shareDelegate respondsToSelector:@selector(wbShare:)]) {
            
            [_shareDelegate wbShare:sendMessageRes.statusCode];
        }
        
        if (sendMessageRes.statusCode == WeiboSDKResponseStatusCodeSuccess) {
            [[JACommonApi shareInstance] addDataLogs_shareWithType:@"wb"];
        }
    }
}

- (void)didReceiveWeiboRequest:(WBBaseRequest *)request
{
    
}

// 微信登录的回调
- (void)onResp:(id)resp
{
    
    //Sharing response from wechat or mobile qq
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        //this is used to be called after sharing something to WX;
        SendMessageToWXResp *res = (SendMessageToWXResp *)resp;
        if (res.errCode == WXSuccess) {
            [[JACommonApi shareInstance] addDataLogs_shareWithType:@"wx"];
        }
        
        // 微信分享后
        if ([_shareDelegate respondsToSelector:@selector(wxShare:)]) {
            
            [_shareDelegate wxShare:res.errCode];
        }
        
        //        //doesn't matter sharing succeed or not
        //        [self changeLiveStatusBackAfterSharing];
        
        return;
    }
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *sendMsgToQQRes = (SendMessageToQQResp *)resp;
        
        if (sendMsgToQQRes.errorDescription == nil) {
            [[JACommonApi shareInstance] addDataLogs_shareWithType:@"qq"];
        }
        
        // qq分享后
        if ([_shareDelegate respondsToSelector:@selector(qqShare:)]) {
            
            [_shareDelegate qqShare:sendMsgToQQRes.errorDescription];
        }
        
        return;
    }
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *rep = (SendAuthResp *)resp;
        if (rep.errCode == WXErrCodeUserCancel) return;
        
        if (IS_LOGIN) {    // APP 内绑定微信
            [MBProgressHUD showMessage:nil];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"platformType"] = @"2";
            dic[@"accessToken"] =  rep.code;
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            [[JAUserApiRequest shareInstance] userWithDrawBindingPlatform:dic success:^(NSDictionary *result) {
               [MBProgressHUD hideHUD];
//                NSLog(@"%@",result);
                [JAUserInfo userInfo_updataUserInfoWithKey:User_PlatformWXUid value:result[@"resMap"][@"platformWxUid"]];
                [JAUserInfo userInfo_updataUserInfoWithKey:User_PlatformWXName value:result[@"resMap"][@"platformWxName"]];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"绑定成功"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"bindingPlatform" object:nil];
                [self sensorsAnalyticsWithMothod:@"绑定" type:@"微信" success:YES];
            } failure:^(NSError *error) {
               [MBProgressHUD hideHUD]; 

                [self sensorsAnalyticsWithMothod:@"绑定" type:@"微信" success:NO];
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"绑定微信失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                }];
                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"需要帮助" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    JAWebViewController *vc = [[JAWebViewController alloc] init];
                    vc.urlString = @"http://www.urmoli.com/newmoli/views/app/about/wx_cash_newquestion.html";
                    [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
                }];
                
                [alert addAction:action2];
                [alert addAction:action1];
                
                [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
            }];
            
        }else{
           [MBProgressHUD showMessage:nil];
            //        NSLog(@"微信登录获取的数据 - %@",rep.code);
            [[JAUserApiRequest shareInstance] loginUserWithPlatformType:@"2" platformUid:nil accessToken:rep.code success:^(NSDictionary *result) {
                
                if (result[@"resMap"]) {
                    [MBProgressHUD hideHUD];
                    [JAAPPManager app_loginSuccessWithResult:result loginType:2];
                    [[NSNotificationCenter defaultCenter] postNotificationName:PlatformLoginSuccess object:nil userInfo:nil];
                }else{
                    //                    // 三方注册
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    dic[@"platformType"] = @"2";
                    dic[@"platformUid"] = result[@"platformuserobj"][@"id"];
                    dic[@"accessToken"] = result[@"platformuserobj"][@"accessToken"];
                    dic[@"platformMark"] = JA_CHANNEL;
                    [self platformRegist:dic];
                }
                
            }];
        }
    }
}

-(void) onReq:(BaseReq*)req
{
    
}

#pragma mark - 三方注册
- (void)platformRegist:(NSDictionary *)platformInfo
{
    [MBProgressHUD hideHUD];
    
    // 获取数据 神策统计三方注册事件
    NSString *platf = platformInfo[@"platformType"];
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    if (platf.integerValue == 1) {
        senDic[JA_Property_SignUpMethod] = @"qq";
        
    }else if (platf.integerValue == 2){
        senDic[JA_Property_SignUpMethod] = @"微信";

    }else if (platf.integerValue == 3){
        senDic[JA_Property_SignUpMethod] = @"微博";

    }
    
    [JASensorsAnalyticsManager sensorsAnalytics_ThirdPartRegister:senDic];
    
    // 需要发通知注册
      [[NSNotificationCenter defaultCenter] postNotificationName:NEED_Regist object:nil userInfo:platformInfo];
}

#pragma mark -
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // 系统内存警告时会自动调用
    [[SDWebImageManager sharedManager] cancelAll];
    [[SDImageCache sharedImageCache] clearMemory];
    if (iPhone4 || iPhone5 || iPhone6) {
        [SDImageCache sharedImageCache].maxMemoryCost = 1024*1024*2;
    } else {
        [SDImageCache sharedImageCache].maxMemoryCost = 1024*1024*8;
    }
}

// 神策数据
- (void)sensorsAnalyticsWithMothod:(NSString *)mothod type:(NSString *)type success:(BOOL)result
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//    senDic[JA_Property_BindingType] = mothod;
//    senDic[JA_Property_AccountType] = type;
    senDic[JA_Property_BindingSucceed] = @(result);
    [JASensorsAnalyticsManager sensorsAnalytics_bindingOrunBinding:senDic];
}

#pragma mark - kill掉APP的处理
- (void)saveMusicList
{
    NSString *fileName = @"MusicListUserListen.data";
    NSString *musicListFile = [NSString ja_getLibraryCachPath:fileName];
    
    // 创建列表模型
    JAMusicListModel *model = [[JAMusicListModel alloc] init];
    model.playType = [JANewPlayTool shareNewPlayTool].playType;
    model.musicList = [JANewPlayTool shareNewPlayTool].musicList;
    model.currentIndex = [JANewPlayTool shareNewPlayTool].currentIndex;
    model.currentMusic = [JANewPlayTool shareNewPlayTool].currentMusic;
    model.enterType = [JANewPlayTool shareNewPlayTool].enterType;
    model.playOrder_zheng = [JANewPlayTool shareNewPlayTool].playOrder_zheng;
    model.currentDuration = [JANewPlayTool shareNewPlayTool].currentDuration;
    model.totalDuration = [JANewPlayTool shareNewPlayTool].totalDuration;
    model.albumDic = [JANewPlayTool shareNewPlayTool].albumDic;
    if (model.musicList.count) {    
        [NSKeyedArchiver archiveRootObject:model toFile:musicListFile];
    }
}

- (void)getCachMusicList
{
    NSString *fileName = @"MusicListUserListen.data";
    NSString *musicListFile = [NSString ja_getLibraryCachPath:fileName];
    JAMusicListModel *model = [NSKeyedUnarchiver unarchiveObjectWithFile:musicListFile];
    if (model.musicList.count) {
        [[JANewPlayTool shareNewPlayTool] playTool_readCachMusicListWithModel:model];
    }
}
@end
