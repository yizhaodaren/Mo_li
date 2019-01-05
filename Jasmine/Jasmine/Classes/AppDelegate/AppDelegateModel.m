//
//  AppDelegateModel.m
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "AppDelegateModel.h"
#import "AvoidCrash.h"
#import "AppDelegate.h"
#import "JAUserApiRequest.h"
#import "JAIMManager.h"

//#import "JAContactApi.h"
#import "JAVoiceCommonApi.h"

#import "JAVoicePersonApi.h"
#import "JATaskModel.h"
#import "JADBTaskModel.h"
#import "JADeleteReasonModel.h"
#import "JAChannelModel.h"

#import "MMDrawerVisualState.h"

#import "JAChannelModel.h"
#import "JAReleaseStoryCountModel.h"
#import "JACreditRuleModel.h"
#import "JALaunchADManager.h"
#import "JACacheDataManager.h"
#import "JACommonApi.h"
#import "JASwitchDefine.h"

#import "JAVoiceReleaseViewController.h"
#import "JATaskCheckVoiceViewController.h"

#import "CYLTabBarController.h"
#import "JATabBarPlusButton.h"
#import "JATabBarControllerConfig.h"
#import "JAsynthesizeMessageViewController.h"
#import "JAMineViewController.h"
// test


@interface AppDelegateModel()<UITabBarControllerDelegate,CYLTabBarControllerDelegate>
@property (nonatomic, assign) NSInteger selectTabbarIndex;
@property (nonatomic, strong) UIImageView *refreshImageView;
@end

@implementation AppDelegateModel

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init
{
    self = [super init];
    if(self)
    {
        [AvoidCrash becomeEffective];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshImageView_endRefresh) name:@"JA_HOME_REFRESH_END" object:nil];
        //        [self setupUmeng];
    }
    return self;
}

+ (instancetype)shareInstance
{
    static AppDelegateModel *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[AppDelegateModel alloc] init];
        }
    });
    return instance;
}

- (void)setGlobalConfig:(NSDictionary *)dictionary {
    NSDictionary *data = dictionary[@"dataClienturl"];
    NSString *serverwebUrl = data[@"serverwebUrl"];
    if (serverwebUrl.length) {
        [JAConfigManager shareInstance].host = [NSString stringWithFormat:@"%@", serverwebUrl];
        //        [JAConfigManager shareInstance].host = @"http://test.data.urmoli.com/";
    }
#ifndef JA_TEST_HOST
  
    [JAConfigManager shareInstance].isDebug = data[@"isDebug"];
    [JAAPPManager companyPersonnelAccount];
#endif
    [JAConfigManager shareInstance].isMaintain = data[@"isMaintain"];
    [JAConfigManager shareInstance].maintainDate = data[@"maintainDate"];
    [JAConfigManager shareInstance].maintainEndDate = data[@"maintainEndDate"];
    [JAConfigManager shareInstance].operateStat = data[@"operateStat"];
    [JAConfigManager shareInstance].updateUrl = data[@"updateUrl"];
    [JAConfigManager shareInstance].updateContent = data[@"updateContent"];
    [JAConfigManager shareInstance].updateVersion = data[@"updateVersion"];
    
    // 获取频道信息
//    NSArray *channels = dictionary[@"listCategory"];
    // v2.5.0
    NSArray *channels = dictionary[@"categoryListV3"];
    if (channels.count) {
        [JACacheDataManager updateChannels:channels];
    }
    
    // 保存accesstoken和time
    [JAAPPManager saveAccessTokenAndTime:dictionary];
    
    // 已检查更新版本
    [JAConfigManager shareInstance].isCheckNewVersion = YES;
    
    // 神策url
    [JAConfigManager shareInstance].saServerUrl = dictionary[@"saServerUrl"];
    [JAConfigManager shareInstance].saConfigUrl = dictionary[@"saConfigUrl"];
    [JAConfigManager shareInstance].shopSign = [dictionary[@"shopSign"] integerValue];
    [JAConfigManager shareInstance].shopUrl = dictionary[@"shopUrl"];
    
    // 延迟调用激活和启动接口(考虑无网进入，再联网)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BOOL isActived = [[NSUserDefaults standardUserDefaults] boolForKey:@"JAUserActived"];
        if (!isActived) {
            // 激活统计
            [[JACommonApi shareInstance] addDataLogs_activeSuccess:^{
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JAUserActived"];
            }];
        }
        // 启动统计
        NSDictionary *dic = @{@"0":@"phone",@"1":@"qq",@"2":@"wx",@"3":@"wb"};
        [[JACommonApi shareInstance] addDataLogs_loginWithType:dic[[JAUserInfo userInfo_getUserImfoWithKey:User_PlatformType]] type_info:[JAUserInfo userInfo_getUserImfoWithKey:User_Phone]];
    });
}

- (void)getGlobalConfigSynchronous:(BOOL)synchronous successBlock:(void(^)(void))successBlock {
    dispatch_semaphore_t semaphore;
    if (synchronous) {
        semaphore = dispatch_semaphore_create(0); //创建信号量
        [JAUserApiRequest httpSessionManager].requestSerializer.timeoutInterval = 3;
    }
    [[JAUserApiRequest shareInstance] getLaunchConfig:^(NSDictionary *dictionary) {
        if (dictionary) {
            [self setGlobalConfig:dictionary];
            // 获取的配置信息存储在本地
            NSString *filePath = [NSString ja_getPlistFilePath:@"/GlobalConfig.plist"];
            [dictionary writeToFile:filePath atomically:YES];
        }
        // 赋值完成后在调用成功回调
        if (successBlock) {
            successBlock();
        }
        if (synchronous) {
            [JAUserApiRequest httpSessionManager].requestSerializer.timeoutInterval = 30;
            dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
        }
    } failure:^(NSError *error) {
        [JAConfigManager shareInstance].isCheckNewVersion = NO;
        
        if (synchronous) {
            [JAUserApiRequest httpSessionManager].requestSerializer.timeoutInterval = 30;
            dispatch_semaphore_signal(semaphore);//不管请求状态是什么，都得发送信号，否则会一直卡着进程
        }
    }];
    if (synchronous) {
        dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);  //等待
    }
}

- (void)setup
{
    /*************************每次更新配置接口*****************************/
    NSString *filePath = [NSString ja_getPlistFilePath:@"/GlobalConfig.plist"];
    NSDictionary *globalConfigDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (globalConfigDic) {
        [self setGlobalConfig:globalConfigDic];
        [self getGlobalConfigSynchronous:NO successBlock:nil];
    } else {
        // 本地没有配置信息，启动APP同步调用
        [self getGlobalConfigSynchronous:YES successBlock:nil];
    }
    
    // 新控制器
    [self showNewMainAppView];
    
    /*************************待优化逻辑(启动app调用N个接口)*****************************/
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGINSUCCESS object:nil];
    
    if (IS_LOGIN) {
        [self loginSuccess];
        // 获取用户信息
        [self getUserInfo];
    }
   
    // 通用配置接口
    [[JAUserApiRequest shareInstance] getUniversalConfig:^(NSDictionary *dictionary) {
        
        [JAConfigManager shareInstance].QQGroup = dictionary[@"moliQQ"][@"title"];
        
        NSArray *cacheConfigArr = dictionary[@"cacheList"];
        for (NSDictionary *dic in cacheConfigArr) {
            NSString *interfaceStr = dic[@"title"];
            NSInteger lastestVersion = [dic[@"content"] integerValue];
            if ([interfaceStr isEqualToString:@"/v2/content/selectContentList?dataType=1"]) {
                // 删除内容、举报内容原因
                [JACacheDataManager getDeleteReason:lastestVersion];
            } else if ([interfaceStr isEqualToString:@"/v2/integral/selectIntegralList"]) {
                // 获取信用信息
                [JACacheDataManager getCreditInfo:lastestVersion];
            } else if ([interfaceStr isEqualToString:@"/v2/grade/selectGradeList"]) {
                // 获取等级信息
                [JACacheDataManager getLevelInfo:lastestVersion];
            } else if ([interfaceStr isEqualToString:@"/v2/content/selectContentList?dataType=2"]) {
                // 举报、禁言人原因
                [JACacheDataManager getReportAndBannedInfo:lastestVersion];
            } else if ([interfaceStr isEqualToString:@"/v2/invite/selectInviteRegisterUrl"]) {
                // 获取分享注册信息（关联个人）
                [JACacheDataManager updateShareRegistInfo:lastestVersion];
            } else if ([interfaceStr isEqualToString:@"/v2/sharefriend/selectAllShareFriendList"]) {
                // 获取分享模板
                [JACacheDataManager getShareTemplate:lastestVersion];
            } else if ([interfaceStr isEqualToString:@"/v2/help/selectAllHelp"]) {
                // 获取帮助中心
                [JACacheDataManager getGuideBookHelp:lastestVersion];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [JACacheDataManager getGuideVideoHelp:lastestVersion];
                });
            }
//            else if ([interfaceStr isEqualToString:@"-----------------"]) {
//                // 获取隐藏和沉帖的原因
//                [JACacheDataManager getHideAndSink:lastestVersion];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [JACacheDataManager getHideAndSink:lastestVersion];
//                });
//            }
        }
    } failure:^(NSError *error) {

    }];
    /*************************待优化逻辑(启动app调用N个接口)*****************************/
    
    [self addListionActionForNetworkState];
}

- (void)showNewMainAppView
{
    JANewLeftDrawerViewController *left = [[JANewLeftDrawerViewController alloc] init];

//    JATabBarViewController *tabbar = [[JATabBarViewController alloc] init];
    [JATabBarPlusButton registerPlusButton];
    JATabBarControllerConfig *tabBarControllerConfig = [[JATabBarControllerConfig alloc] init];
    CYLTabBarController *tabbar = tabBarControllerConfig.tabBarController;
    tabbar.delegate = self;
    tabbar.fd_prefersNavigationBarHidden = YES;
    JABaseNavigationController *centerNav = [[JABaseNavigationController alloc] initWithRootViewController:tabbar];
    
    self.drawerController = [[MMDrawerController alloc] initWithCenterViewController:centerNav leftDrawerViewController:left];
    self.drawerController.shouldStretchDrawer = NO;
    [self.drawerController setShowsShadow:NO];
    [self.drawerController setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeNone];
    
    [self.drawerController setDrawerVisualStateBlock:^(MMDrawerController *drawerController, MMDrawerSide drawerSide, CGFloat percentVisible) {
        MMDrawerControllerDrawerVisualStateBlock block =  [MMDrawerVisualState slideVisualStateBlock];;
        
        if(block){
            block(drawerController, drawerSide, percentVisible);
        }
    }];
    
    [AppDelegate sharedInstance].window.rootViewController = self.drawerController;
}

/// 获取跟控制器 (DrawerViewController *)
+ (MMDrawerController *)rootviewController
{
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    return vc;
}

/// 获取最基本的控制器 （第二层导航控制器）（JABaseNavigationController *）
+ (JABaseNavigationController *)getBaseNavigationViewControll
{
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    return nav;
}

/// 获取左边控制器
+ (JANewLeftDrawerViewController *)getLeftMenuViewController
{
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JANewLeftDrawerViewController *left = (JANewLeftDrawerViewController *)vc.leftDrawerViewController;
    return left;
}

/// 获取中心控制器
+ (JACenterDrawerViewController *)getCenterMenuViewController
{
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    JABaseNavigationController *nav1 = (JABaseNavigationController *)tab.viewControllers.firstObject;
    JACenterDrawerViewController *center = (JACenterDrawerViewController *)nav1.childViewControllers.firstObject;
    return center;
}

- (void)loginSuccess {
    // 获取已发帖数
    [JAAPPManager app_getReleaseStoryCount];
    
    [self getUserInfo];
}


#pragma networkListener
- (void)addListionActionForNetworkState {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kJAReachabilityChangedNotification object:nil];
    self.reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    
    [self.reach startNotifier];
}

-(void)reachabilityChanged:(NSNotification*)note
{
    Reachability * reach = [note object];
    //    NSParameterAssert([reach isKindOfClass: [Reachability class]]);
    if(![reach isKindOfClass: [Reachability class]]){
        return ;
    }
    NetworkStatus status = [reach currentReachabilityStatus];
    if (status != NotReachable) {
        if (![JAConfigManager shareInstance].isCheckNewVersion) {
            // 无网进入APP调用启动配置接口失败，先赋值为YES防止多次调用
            [JAConfigManager shareInstance].isCheckNewVersion = YES;
            [self getGlobalConfigSynchronous:NO successBlock:^{
                // 更新isDebug状态，显示隐藏的功能
                [[NSNotificationCenter defaultCenter] postNotificationName:DATACLIENTUPDATE object:nil];
                NSInteger isMaintain = [[JAConfigManager shareInstance].isMaintain integerValue];
                if (isMaintain == 1) {
                    [[JALaunchADManager shareInstance] showServermaintain];
                    return;
                }
                NSInteger operateStat = [[JAConfigManager shareInstance].operateStat integerValue];
                if (operateStat == 2) {
                    [[JALaunchADManager shareInstance] checkNewVersion];
                }
            }];
        }
    }
}

#pragma mark - Network
// 获取用户信息
- (void)getUserInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_personalInfoWithParas:dic success:^(NSDictionary *result) {
        // 设置神策用户信息
        JAConsumer *user = [JAConsumer mj_objectWithKeyValues:result[@"user"]];
        if (user) {
            [JASensorsAnalyticsManager sensorsAnalytics_setUser:user];
        }
        
        [JAUserInfo userInfo_saveUserInfo:result[@"user"]];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if ([JAUserInfo userInfo_getUserImfoWithKey:User_Status].integerValue == 1) {
                
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您的账号违法了相关用户协议，已被禁用"];
                /*
                 退出登录：
                  启动的时候如果发现是禁言直接退出登录
                 */
                [JAAPPManager app_loginOut];
                
//                [JAUserInfo userinfo_saveUserLoginState:NO];
//                [JAUserInfo userInfo_deleteUserInfo];
//                // 退出云信
//                [[QYSDK sharedSDK] logout:^(){}];
//                [JAChatMessageManager yx_loginOutYX];
//                
//                // 删除别名
//                [JPUSHService setAlias:nil completion:nil seq:0];
//                
//                [JAAPPManager app_modalLogin];
            }
        });
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - UITabBarControllerDelegate/CYLTabBarController
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[JABaseNavigationController class]]) {
        JABaseNavigationController *nav = (JABaseNavigationController *)viewController;
        UIViewController *vc = nav.topViewController;
        if ([vc isKindOfClass:[JAsynthesizeMessageViewController class]]) {
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[JA_Property_BindingType] = @"点击消息";
                [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
                return NO;
            }
        }else if ([vc isKindOfClass:[JAMineViewController class]]) {
            if (!IS_LOGIN) {
                [JAAPPManager app_modalLogin];
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[JA_Property_BindingType] = @"点击我的";
                [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
                return NO;
            }
        }
    }
   
    [[self cyl_tabBarController] updateSelectionStatusIfNeededForTabBarController:tabBarController shouldSelectViewController:viewController];
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectControl:(UIControl *)control
{
    if ([control isKindOfClass:[CYLExternPlusButton class]]) {
        return;
    }
    UIView *animationView;
    if ([control isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
        for (UIView *subView in control.subviews) {
            if ([subView isKindOfClass:NSClassFromString(@"UITabBarSwappableImageView")]) {
                animationView = subView;
            }
        }
    }
    
    if ([self cyl_tabBarController].selectedIndex == 0 && self.selectTabbarIndex == [self cyl_tabBarController].selectedIndex) {
        
        // 动画开始
        [self refreshImageView_beginWithSuperView:animationView];
        // 通知刷新
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_BEGIN" object:nil];
        
    }else{
        [self refreshImageView_endRefresh];
    }
    
    self.selectTabbarIndex = [self cyl_tabBarController].selectedIndex;
}

- (void)refreshImageView_beginWithSuperView:(UIView *)supView
{
    if (_refreshImageView == nil) {
        _refreshImageView = [[UIImageView alloc] init];
        _refreshImageView.backgroundColor = [UIColor whiteColor];
        _refreshImageView.frame = supView.bounds;
        _refreshImageView.width += 2;
        _refreshImageView.height += 2;
        _refreshImageView.center = CGPointMake(supView.width * 0.5, supView.height * 0.5);
        _refreshImageView.image = [UIImage imageNamed:@"branch_home_refresh"];
        [supView addSubview:_refreshImageView];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        animation.fromValue = [NSNumber numberWithFloat:0.f];
        animation.toValue = [NSNumber numberWithFloat: M_PI *2];
        animation.duration = 1;
        animation.autoreverses = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
        [_refreshImageView.layer addAnimation:animation forKey:nil];
    }
}

- (void)refreshImageView_endRefresh
{
    if (_refreshImageView) {
        [self.refreshImageView.layer removeAllAnimations];
        [self.refreshImageView removeFromSuperview];
        self.refreshImageView = nil;
    }
}

- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    return [self findBestViewController:tab];
}
@end
