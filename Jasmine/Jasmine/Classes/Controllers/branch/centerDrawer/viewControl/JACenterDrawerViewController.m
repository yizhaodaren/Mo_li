//
//  JACenterDrawerViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/28.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACenterDrawerViewController.h"
#import "JAChannelModel.h"
#import "JAVoiceRecordViewController.h"
#import "JAVoiceReleaseViewController.h"
#import "JANewLeftDrawerViewController.h"
#import "JAPostDetailViewController.h"
#import "JAUserApiRequest.h"
#import "JAPersonalCenterViewController.h"
#import "JASwitchDefine.h"
#import "JANotiModel.h"
#import "JANewSearchViewController.h"
#import "CYLTabBarController.h"
#import "JAPostDraftModel.h"
#import "JAStoryViewController.h"
#import "JAVoiceReleaseViewController.h"
#import "JALabelSelectViewController.h"
#import "JAPacketNotiMsgAnimateView.h"
#import "JAHomeSignView.h"

@interface JACenterDrawerViewController ()<SPPageMenuDelegate>

@property (nonatomic, strong) NSMutableArray *channels;
@property (nonatomic, strong) UIButton *loginButton;// 登录按钮
@property (nonatomic, assign) BOOL haveNewFocusNotice;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIImageView *titleIV;


@end

@implementation JACenterDrawerViewController

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 修复instruments中anonymousVM过高问题
    [[SDImageCache sharedImageCache].config setShouldDecompressImages:NO];
    [[SDWebImageDownloader sharedDownloader] setShouldDecompressImages:NO];
    //    [[SDImageCache sharedImageCache].config setShouldCacheImagesInMemory:NO];
    [[SDWebImageManager sharedManager].imageCache setMaxMemoryCountLimit:15];

    self.channels = [NSMutableArray new];
    JAChannelModel *model = [JAChannelModel new];
    model.channelId = @"1";
    model.title = @"关注";
    [self.channels addObject:model];
    JAChannelModel *model1 = [JAChannelModel new];
    model1.channelId = @"2";
    model1.title = @"推荐";
    [self.channels addObject:model1];
    JAChannelModel *model2 = [JAChannelModel new];
    model2.channelId = @"3";
    model2.title = @"最新";
    [self.channels addObject:model2];

    // 添加视图
    [self setupNavigationBar];
//    [self.view addSubview:self.titleView];
    [self.view addSubview:self.contentView];
    
    // 滚动关联
    self.titleView.bridgeScrollView = (UIScrollView *)self.contentView.collectionView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(activityAndSign) name:LOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointArrive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointDismiss" object:nil];
    // 监听广告界面消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adPageDismiss) name:@"JALaunchADDismiss" object:nil];
    
    // 设置草稿箱红点 - 上传中app闪退 需要在启动的时候读一次草稿箱
    NSInteger draftCount = [JAPostDraftModel rowCountWithWhere:@{@"isRead":@(NO)}];
    if (draftCount) {
        [JARedPointManager hasNewRedPointArrive:JARedPointTypeDraft];
    }
    
    // 清理LOGO,默认头像
    [self cacheLogoAndIconImage];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_removeNotLoginAnimateView];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    // 是否需要刷新关注
    if (self.titleView.selectedItemIndex == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedZero" object:nil];
        JAStoryViewController *vc = self.contentView.childsVCs[0];
        [vc needRefreshFocusVC];
    }
    if (IS_LOGIN) {
        self.titleIV.hidden = YES;
        self.titleView.hidden = NO;
        UICollectionView *collect = (UICollectionView *)self.contentView.collectionView;
        collect.scrollEnabled = YES;
    }else{
        self.titleIV.hidden  = NO;
        self.titleView.hidden = YES;
        [self.titleView setSelectedItemIndex:1];
        UICollectionView *collect = (UICollectionView *)self.contentView.collectionView;
        collect.scrollEnabled = NO;
    }
    // 每次展示的时候检查红点
    [self redPointArrive];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (!IS_LOGIN) {
        [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_notLoginShowPacketAnimate];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.topNavView.y = self.view.y; // 后台定位或者录音位置会改变
    self.contentView.y = self.topNavView.bottom;
}

#pragma mark - 清理LOGO,默认头像
- (void)cacheLogoAndIconImage
{
    // 清除缓存icon，默认头像
    NSString *currVersion = @"2.5.7";  // 比用户的高 就会清理缓存
    // 获取用户版本
    NSString *userVersion = [STSystemHelper getApp_version];
    
    BOOL cacheLogo = [[NSUserDefaults standardUserDefaults] boolForKey:@"SDImageCacheLogo"];
    // 判断版本的大小
    if ([currVersion compare:userVersion options:NSNumericSearch] == NSOrderedDescending || cacheLogo == NO)  // 降序   currVersion > userVersion
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SDImageCacheLogo"];
        [[SDImageCache sharedImageCache] removeImageForKey:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png" withCompletion:nil];
        [[SDImageCache sharedImageCache] removeImageForKey:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/usergirl_01.png" withCompletion:nil];
        [[SDImageCache sharedImageCache] removeImageForKey:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/20170701/logo.png" withCompletion:nil];
        [[SDImageCache sharedImageCache] removeImageForKey:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/20170701/logo.jpg" withCompletion:nil];
    }
    
    
    // 2.6.0清除用户默认数据
    NSString *currVersion_notiCach = @"2.6.0";
    
    // 获取用户版本
    NSString *userVersion_noti = [STSystemHelper getApp_version];
    
    BOOL cache_noti = [[NSUserDefaults standardUserDefaults] boolForKey:@"Cache_notiFocus"];
    // 判断版本的大小
    if ([currVersion_notiCach compare:userVersion_noti options:NSNumericSearch] == NSOrderedSame && cache_noti == NO)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Cache_notiFocus"];
        
        NSDictionary *dic = @{@"operation" : @"friend"};
        
        [[LKDBHelper getUsingLKDBHelper] deleteWithClass:[JANotiModel class] where:dic];
    }
}

// 广告消失的通知
- (void)adPageDismiss
{
    if (self.adIsDismiss) {
        return;
    }

    // v3.0.0 弹出兴趣标签
    if ([JAAPPManager isShowLabelsVC]) {
        JALabelSelectViewController *vc = [JALabelSelectViewController new];
        [self presentViewController:vc animated:YES completion:nil];        
    }
    
#pragma mark - 3.0.2
    if (IS_LOGIN) {
        // 1 弹签到 -->  活动  --> 弹红包
        [[JAHomeSignView shareHomeSignView] homeSign_getUserSignInfo];
    }
    self.adIsDismiss = YES;
}

// 活动或者签到
- (void)activityAndSign  // 登录成功
{
#pragma mark - 3.0.2
    // 1 弹签到 --> 弹活动 --> 弹红包
    [[JAHomeSignView shareHomeSignView] homeSign_getUserSignInfo];
}

// 设置红点
- (void)redPointArrive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        JANewLeftDrawerViewController *vc = [AppDelegateModel getLeftMenuViewController];
        vc.msg_needRed = ([JARedPointManager checkRedPoint:JARedPointTypeMessage] || [JARedPointManager checkRedPoint:JARedPointTypeAnnouncement]);
        vc.noti_needRed = ([JARedPointManager checkRedPoint:120] || [JARedPointManager checkRedPoint:JARedPointTypeCallPerson]);
        vc.activity_needRed = [JARedPointManager checkRedPoint:JARedPointTypeActivity];
        vc.draft_needRed = [JARedPointManager checkRedPoint:JARedPointTypeDraft];
        self.leftButton.selected = [JARedPointManager checkRedPoint:1022];
        
        
        // 关注
        self.haveNewFocusNotice = [JARedPointManager checkRedPoint:JARedPointTypeHomePageFocus];
        [self.titleView setRedPointViewHidden:!self.haveNewFocusNotice index:0];
        
        if (self.haveNewFocusNotice) {
            UIView *tabBadgePointView = [UIView cyl_tabBadgePointViewWithClolor:[UIColor redColor] radius:4.5];
            
            [[self cyl_tabBarController].viewControllers[0] cyl_setTabBadgePointView:tabBadgePointView];
            [[self cyl_tabBarController].viewControllers[0] cyl_showTabBadgePoint];
            
        }else{
            [[self cyl_tabBarController].viewControllers[0] cyl_removeTabBadgePoint];
        }
        
        // 消息
        NSInteger announceCount = [JARedPointManager getRedPointNumber:JARedPointTypeAnnouncement];
        NSInteger msgCount = [JARedPointManager getRedPointNumber:JARedPointTypeMessage];
        
        NSInteger replyCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Reply];
        NSInteger atCount = [JARedPointManager getRedPointNumber:JARedPointTypeCallPerson];
        NSInteger likeCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Agree];
        NSInteger focusCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Focus];
        NSInteger inviteCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Invite];
        
        NSString *countString = [NSString stringWithFormat:@"%ld",announceCount + msgCount + replyCount + atCount + likeCount + focusCount + inviteCount];
        //    countString = @"100";
        if (countString.integerValue > 0) {
            countString = countString.integerValue > 99 ? @"..." : countString;
            [[self cyl_tabBarController].viewControllers[2].tabBarItem setBadgeValue:countString];
        }else{
            [[self cyl_tabBarController].viewControllers[2].tabBarItem setBadgeValue:nil];
        }
        
        // 活动 || 草稿箱
        BOOL activityStatus = [JARedPointManager checkRedPoint:JARedPointTypeActivity];
        BOOL draftStatus = [JARedPointManager checkRedPoint:JARedPointTypeDraft];
        
        if (activityStatus || draftStatus) {
            [[self cyl_tabBarController].viewControllers[3] cyl_showTabBadgePoint];
        }else{
            [[self cyl_tabBarController].viewControllers[3] cyl_removeTabBadgePoint];
        }
    });
}

- (void)setupNavigationBar {
    CGFloat appddingH = 2;
    
    UIView *fakeNav = [UIView new];
    _topNavView = fakeNav;
    fakeNav.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_StatusBarAndNavigationBarHeight+appddingH-1);
    fakeNav.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fakeNav];
    
    // v2.5.2 去掉背景图
    UIImageView *backgroundIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_StatusBarAndNavigationBarHeight)];
//    backgroundIV.image = iPhoneX?[UIImage imageNamed:@"home_navigationbgX"]:[UIImage imageNamed:@"home_navigationbg"];
    backgroundIV.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_StatusBarAndNavigationBarHeight);
    [fakeNav addSubview:backgroundIV];
    
    UIView *navigationBarView = [[UIView alloc] initWithFrame:CGRectMake(0, JA_StatusBarHeight, JA_SCREEN_WIDTH, 43+appddingH)];
//    navigationBarView.backgroundColor = [UIColor redColor];
    [fakeNav addSubview:navigationBarView];
    
    [navigationBarView addSubview:self.titleView];
    self.titleView.y = navigationBarView.height-self.titleView.height-1;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationBarView.height-1, JA_SCREEN_WIDTH, 1)];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [navigationBarView addSubview:lineView];
    self.lineView = lineView;
    
    UIImageView *titleIV = [UIImageView new];
    titleIV.image = [UIImage imageNamed:@"voice_title"];
    [titleIV sizeToFit];
    titleIV.centerX = JA_SCREEN_WIDTH/2.0;
    titleIV.centerY = navigationBarView.height/2.0-1;
    [navigationBarView addSubview:titleIV];
    self.titleIV = titleIV;
 
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
    [rightButton setImage:[UIImage imageNamed:@"home_search"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"home_search"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(showSearchVC) forControlEvents:UIControlEventTouchUpInside];
    rightButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [navigationBarView addSubview:rightButton];
    rightButton.width = 37;
    rightButton.height = 37;
    rightButton.x = 15;
    rightButton.centerY = navigationBarView.height/2.0-1;

}

// 展示左边控制器
- (void)showLeftDrawerVC
{
    if (IS_LOGIN) {
        [[AppDelegateModel shareInstance].drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideCurrentNotFocusView" object:nil];
    }else{
        [JAAPPManager app_modalLogin];
    }
}

- (void)showSearchVC {

    JANewSearchViewController *vc = [JANewSearchViewController new];
    [self.navigationController pushViewController:vc animated:NO];
}

- (void)showLoginVC {
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
}

#pragma mark - SPPageMenu
// 滚动和点击都会走此回调
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    if (fromIndex != toIndex) {
        self.contentView.contentViewCurrentIndex = toIndex;
        JAStoryViewController *vc = self.contentView.childsVCs[toIndex];
        if (toIndex == 0 && self.haveNewFocusNotice) {
            [vc needRefreshFocusVC];
        }
    }
}

// 点击按钮，滚到顶部
- (void)pageMenu:(SPPageMenu *)pageMenu scrollToTopToIndex:(NSInteger)toIndex {
    JAStoryViewController *vc = _contentView.childsVCs[toIndex];
    [vc voiceViewVCscrollTop];
}

#pragma mark - Lazylaod
- (SPPageMenu *)titleView {
    if (!_titleView) {
        NSMutableArray *titles = [NSMutableArray new];
        for (JAChannelModel *model in self.channels) {
            if (model.title) {
                [titles addObject:model.title];
            }
        }
        SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, 160, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
        [pageMenu setItems:titles selectedItemIndex:((titles.count>1)?1:0)];
        pageMenu.delegate = self;
        pageMenu.itemTitleFont = JA_REGULAR_FONT(18);
        pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
        pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
        pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
//        pageMenu.titleContentInset = UIEdgeInsetsMake(-3, 0, 3, 0);
//        pageMenu.itemPadding = 40;
        pageMenu.dividingLine.hidden = YES;
        _titleView = pageMenu;
//        _titleView.backgroundColor = [UIColor redColor];
        pageMenu.centerX = JA_SCREEN_WIDTH/2.0;
    }
    return _titleView;
}

// 已登录视图
- (FSPageContentView *)contentView {
    if (!_contentView) {
        NSMutableArray *contentVCs = [NSMutableArray new];
        for (JAChannelModel *model in self.channels) {
            JAStoryViewController *vc = [JAStoryViewController new];
            vc.centerVc = self;
            vc.model = model;
            vc.channels = self.channels;
            [contentVCs addObject:vc];
        }
        CGFloat contentViewHeigh = JA_SCREEN_HEIGHT - _topNavView.height;
        _contentView = [[FSPageContentView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, contentViewHeigh)
                                                       childVCs:contentVCs
                                                       parentVC:self
                                                       delegate:nil];
        // 因为重新布局的问题，在此处设置无效
        if (self.channels.count>1) {
            self.contentView.contentViewCurrentIndex = 1;
        }
//        [_contentView setupInitialIndex:1];
    }
    return _contentView;
}

@end
