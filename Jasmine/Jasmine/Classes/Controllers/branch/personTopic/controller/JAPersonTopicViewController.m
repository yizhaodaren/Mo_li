//
//  JAPersonTopicViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonTopicViewController.h"
#import "JAPersonTopicNavView.h"
#import "JAPersonTopicHeaderView.h"
#import "JAHorizontalPageView.h"
#import "SPPageMenu.h"

#import "JAPersonTopicNewViewController.h"
#import "JAPersonTopicHotViewController.h"

#import "JATopicApi.h"
#import "JAVoiceCommonApi.h"

#import "JAPlatformShareManager.h"
#import "JAFunctionToolV.h"
#import "JAReleasePostManager.h"

#import "JAPreReleaseView.h"

#import "JABottomShareView.h"

@interface JAPersonTopicViewController ()<SPPageMenuDelegate,JAHorizontalPageViewDelegate,PlatformShareDelegate>

@property (nonatomic, weak) JAPersonTopicNavView *navBarView;   // 导航栏
@property (nonatomic, strong) JAPersonTopicHeaderView *headerView;  // 个人中心的头部
@property (nonatomic, strong) JAHorizontalPageView *pageView;
@property (nonatomic, weak) SPPageMenu *titleView;
@property (nonatomic, strong) NSArray *titleArray;
@property (nonatomic, weak) UIButton *bottomButton; // 底部按钮

@property (nonatomic, assign) CGFloat dataHeight;
@property (nonatomic, strong) JAVoiceTopicModel *topicModel;

@property (nonatomic, assign) BOOL requestFaile;  // 判断是否可以右上角分享
@property (nonatomic, assign) BOOL needShare; // 判断是否需要调用分享

@property (nonatomic, strong) UIButton *backButton;
@end

@implementation JAPersonTopicViewController

- (BOOL)fd_prefersNavigationBarHidden {
    
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ReleaseVoiceSuccess:) name:@"refreshVoiceModel" object:nil];
    
    self.bottomButton.hidden = NO;
    self.navBarView.hidden = NO;
    [self getTopicDetail];  // 获取数据刷新界面
}

- (void)ReleaseVoiceSuccess:(NSNotification *)noti
{
    NSDictionary *dic = (NSDictionary *)noti.object;
    if (!dic) {
        return;
    }
    
    JANewVoiceModel *release_voiceModel = (JANewVoiceModel *)dic[@"data"];
    
    if (self.titleView.selectedItemIndex != 0 && [release_voiceModel.content containsString:self.topicTitle]) {
        self.titleView.selectedItemIndex = 0;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - JAHorizontalPageView懒加载
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        _pageView.needHeadGestures = YES;
        [self.view insertSubview:_pageView belowSubview:_bottomButton];
    }
    
    return _pageView;
}

- (JAPersonTopicNavView *)navBarView
{
    if (_navBarView == nil) {
        JAPersonTopicNavView *navBarView = [[JAPersonTopicNavView alloc] init];
        _navBarView = navBarView;
        navBarView.backgroundColor = [UIColor clearColor];
        [navBarView.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [navBarView.rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        navBarView.hidden = YES;
        [self.view addSubview:navBarView];
    }
    
    return _navBarView;
}

- (UIButton *)bottomButton
{
    if (_bottomButton == nil) {
        
        UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomButton = publishButton;
        [publishButton setImage:[UIImage imageNamed:@"circle_publish"] forState:UIControlStateNormal];
        [publishButton addTarget:self action:@selector(goToPublishVoice) forControlEvents:UIControlEventTouchUpInside];
        publishButton.width = 50;
        publishButton.height = 50;
        publishButton.centerX = self.view.width * 0.5 - JA_TabbarSafeBottomMargin;
        publishButton.y = self.view.height - publishButton.height;
        [self.view addSubview:publishButton];
    }
    
    return _bottomButton;
}

#pragma mark - JAHorizontalPageView代理
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return 2;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if (index == 0) {
        JAPersonTopicNewViewController *vc1 = [JAPersonTopicNewViewController new];
        vc1.topicTitle = self.topicTitle;
        [self addChildViewController:vc1];
        return (UIScrollView *)vc1.view;
    }else{
        
        JAPersonTopicHotViewController *vc3 = [[JAPersonTopicHotViewController alloc]init];
        vc3.topicTitle = self.topicTitle;
        [self addChildViewController:vc3];
        return (UIScrollView *)vc3.view;
    }
    
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    JAPersonTopicHeaderView *headerView = [[JAPersonTopicHeaderView alloc] init];
    _headerView = headerView;
    self.headerView.topicM  = self.topicModel;
    
    CGFloat pageY = 0;
    if (self.dataHeight) {
        pageY = WIDTH_ADAPTER(195) + 10 + self.dataHeight;
    }else{
        pageY = WIDTH_ADAPTER(195);
    }
    
    // 分页tab
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, pageY, JA_SCREEN_WIDTH, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pageMenu.delegate = self;
    });
    pageMenu.itemTitleFont = JA_REGULAR_FONT(17);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    self.titleView = pageMenu;
    [self.headerView addSubview:pageMenu];
    self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    self.titleArray = @[@"最新",@"最热"];
    [self.titleView setItems:self.titleArray selectedItemIndex:1];
    
    // 导航栏
    self.navBarView.hidden = NO;
    
    
    return headerView;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return WIDTH_ADAPTER(195) + (self.dataHeight == 0 ? 0 : (self.dataHeight + 10)) + 40;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView      // 控制在什么地方悬停
{
    return ((iPhoneX) ? 128 : 104);
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{
    self.headerView.topOffY = offset;

    // 计算导航条的隐藏
    if (offset > 0) {
        self.navBarView.alphaValue = (offset) / (WIDTH_ADAPTER(195) - 64);
        
        if (self.navBarView.alphaValue >= 1) {
            self.navBarView.alphaValue = 1.0;
        }
    }else{
        self.navBarView.alphaValue = 0.0;
    }
    
    if (self.navBarView.alphaValue >= 1) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    
}

#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self.pageView scrollToIndex:toIndex];
}


#pragma mark - 按钮的点击事件
- (void)back   // 返回按钮
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightClick   // 分享按钮
{
    if (self.requestFaile) {
        return;
    }
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    appDelegate.shareDelegate = self;
    
    JABottomShareView *shareView = [[JABottomShareView alloc] initWithShareType:JABottomShareViewTypeOneLine contentType:JABottomShareOneContentTypeNormal twoContentType:JABottomShareTwoContentTypeNormal];
    @WeakObj(self);
    shareView.bottomShareClickButton = ^(JABottomShareClickType clickType, BOOL select, UIButton *button) {
        @StrongObj(self);
        if (clickType == JABottomShareClickTypeWX) {
            
            self.needShare = NO;
            [self sensorsAnalyticsWithModel:self.topicModel mothod:@"微信聊天"];
            [self shareRequestServer:NO];
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.topicModel.shareWxContent;
            model.descripe = self.topicModel.shareTitle;
            model.shareUrl = self.topicModel.shareUrl;
            model.image = self.topicModel.shareImg;
            [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:5];

        }else if (clickType == JABottomShareClickTypeWXSession){
            
            self.needShare = YES;
            [self sensorsAnalyticsWithModel:self.topicModel mothod:@"朋友圈"];
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.topicModel.shareWxContent;
            model.shareUrl = self.topicModel.shareUrl;
            model.image = self.topicModel.shareImg;
            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:5];

        }else if (clickType == JABottomShareClickTypeQQ){
            
            self.needShare = NO;
            [self sensorsAnalyticsWithModel:self.topicModel mothod:@"qq"];
            [self shareRequestServer:NO];
            JAShareModel *model = [JAShareModel new];
            model.title = self.topicModel.shareWxContent;
            model.descripe = self.topicModel.shareTitle;
            model.shareUrl = self.topicModel.shareUrl;
            model.image = self.topicModel.shareImg;
            [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:5];

            
        }else if (clickType == JABottomShareClickTypeQQZone){
            
            self.needShare = YES;
            [self sensorsAnalyticsWithModel:self.topicModel mothod:@"qq空间"];
            JAShareModel *model = [JAShareModel new];
            model.title = self.topicModel.shareWxContent;
            model.descripe = self.topicModel.shareTitle;
            model.shareUrl = self.topicModel.shareUrl;
            model.image = self.topicModel.shareImg;
            [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:5];

            
        }else if (clickType == JABottomShareClickTypeWB){
            self.needShare = YES;
            [self sensorsAnalyticsWithModel:self.topicModel mothod:@"微博"];
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.topicModel.shareWBContent;
            model.shareUrl = self.topicModel.shareUrl;
            model.image = self.topicModel.shareImg;
            [JAPlatformShareManager wbShareWithshareContent:model domainType:5];

        }
        
    };
    [shareView showBottomShareView];
}

#pragma mark - 分享的点击事件
- (void)wxShare:(int)code
{
    if (self.needShare == NO) {
        return;
    }
    self.needShare = NO;
    if (code == 0) {
        [self shareRequestServer:NO];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else if (code == -1) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信未识别的错误类型，请重试"];
    }else if (code == -2) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -3) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -4) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -5) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信不支持"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)qqShare:(NSString *)error
{
    if (self.needShare == NO) {
        return;
    }
    self.needShare = NO;
    if (error == nil) {
        [self shareRequestServer:NO];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wbShare:(int)code
{
    if (self.needShare == NO) {
        return;
    }
    self.needShare = NO;
    if (code == 0) {
        [self shareRequestServer:NO];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else if (code == -1){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -2){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -3){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -8){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }else if (code == -99){
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请求无效"];
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)shareRequestServer:(BOOL)isWxSession  // 分享接口
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];

    dic[@"dataType"] = @"topic";
    dic[@"type"] = @"share";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"typeId"] = self.topicModel.topicId;

    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:^(NSDictionary *result) {

    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)goToPublishVoice  // 发布帖子
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    [JAPreReleaseView showPreReleaseViewWithTopic:self.topicModel];
}

#pragma mark - 网络请求
- (void)getTopicDetail
{
    [MBProgressHUD showMessage:nil];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"title"] = self.topicTitle;
    dic[@"userId"] = IS_LOGIN ? [JAUserInfo userInfo_getUserImfoWithKey:User_id] : @"0";
    
    [[JATopicApi shareInstance] topic_Detail:dic success:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUD];
        self.requestFaile = NO;   // 判断请求是否失败 - 是否可以分享
        self.topicModel = [JAVoiceTopicModel mj_objectWithKeyValues:result[@"topic"]];

        if (self.topicModel.content.length) {
            
            CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 30, MAXFLOAT);
            CGFloat subHeight = [self.topicModel.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(14)} context:nil].size.height;
            
            self.dataHeight = ceil(subHeight);
        }else{
            self.dataHeight = 0;
        }
        
        self.navBarView.name = self.topicModel.title;
        self.navBarView.shareCount = self.topicModel.shareCount;
        
        [self.pageView reloadPage];
        
        [self.pageView scrollToIndex:1 animation:NO];
        
    } failure:^(NSError *error) {
        
       [MBProgressHUD hideHUD];
        self.requestFaile = YES;
        if (error.code == 200014) {
            [self showBlankPageWithLocationY:0 title:@"该话题已经被删除啦！" subTitle:@"" image:@"blank_delete" buttonTitle:nil selector:nil buttonShow:NO];
            self.backButton.hidden = NO;
        }else{
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateNormal];
        _backButton.width = 45;
        _backButton.height = 60;
        _backButton.y = JA_StatusBarHeight;
        [_backButton addTarget:self action:@selector(backFront) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    
    return _backButton;
}

- (void)backFront
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 神策数据
- (void)sensorsAnalyticsWithModel:(JAVoiceTopicModel *)model mothod:(NSString *)mothod
{
    // 神策数据
//    NSArray *timeArr = [model.time componentsSeparatedByString:@":"];
//    NSString *min = timeArr.firstObject;
//    NSString *sec = timeArr.lastObject;
//    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
//
//    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//    senDic[JA_Property_ContentId] = model.voiceId;
//    senDic[JA_Property_ContentTitle] = model.content;
//    senDic[JA_Property_ContentType] = @"话题";
//    senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
//    senDic[JA_Property_Anonymous] = @(model.isAnonymous);
//    senDic[JA_Property_RecordDuration] = @(sen_time);
//    senDic[JA_Property_PostId] = model.userId;
//    senDic[JA_Property_PostName] = model.userName;
//    senDic[JA_Property_ShareMethod] = mothod;
//    senDic[JA_Property_SourcePage] = model.sourceName;
//    senDic[JA_Property_RecommendType] = model.recommendType;
//    [JASensorsAnalyticsManager sensorsAnalytics_clickShare:senDic];
}
@end
