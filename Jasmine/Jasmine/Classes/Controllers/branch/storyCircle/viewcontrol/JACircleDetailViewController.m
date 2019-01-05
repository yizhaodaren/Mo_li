//
//  JANewCircleDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleDetailViewController.h"
#import "JACommonSectionView.h"
#import "JACircleDetailNavBarView.h"
#import "JACircleDetailHeadView.h"
#import "JAPreReleaseView.h"
#import "JAHorizontalPageView.h"
#import "SPPageMenu.h"
#import "PopoverView.h"

#import "JACircleNetRequest.h"

#import "JACircleInfoViewController.h"
#import "JACircleAllStoryListViewController.h"
#import "JACircleEssenceStoryListViewController.h"

@interface JACircleDetailViewController ()<JAHorizontalPageViewDelegate,SPPageMenuDelegate>
@property (nonatomic, weak) JACircleDetailNavBarView *navBarView;  // 导航条
@property (nonatomic, weak) JACircleDetailHeadView *headView;  // 头部
@property (nonatomic, strong) JACommonSectionView *sectionView;  // 组头
@property (nonatomic, weak) UIView *circleHeadView;   // 头部+组头
@property (nonatomic, weak) UIButton *publishButton;
@property (nonatomic, strong) JAHorizontalPageView *pageView;
@property (nonatomic, strong) SPPageMenu *titleView;

@property (nonatomic, strong) JACircleModel *infoModel; // 圈子信息model

@property (nonatomic, assign) NSInteger currentSortType;  // 当前排序类型  0 最新回复  1 最新发表

@property (nonatomic, weak) JACircleAllStoryListViewController *allViewControl;  // 所有
@property (nonatomic, weak) JACircleEssenceStoryListViewController *essenceViewControl; // 精华
@property (nonatomic, weak) JACircleInfoViewController *infoViewControl; // 资料

@property (nonatomic, assign) BOOL requestInfo;
@property (nonatomic, assign) BOOL isNeedNoti;
@end

@implementation JACircleDetailViewController

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isNeedNoti = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNeedNoti = YES;
    [self setupCircleDetailViewControllerUI];
    
    // 请求网络数据-圈子资料
    [self request_getCircleInfoWithToast:NO];
    
//    [self.pageView reloadPage];
//    self.titleView.delegate = self;
//    self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshNav) name:@"STKAudioPlayer_status" object:nil];
}
- (void)playStatus_refreshNav
{
    [self.navBarView circleDetailNavBarView_changeInfoButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isNeedNoti = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    
    [self.navBarView circleDetailNavBarView_changeInfoButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 网络请求
- (void)request_getCircleInfoWithToast:(BOOL)toast
{
    self.requestInfo = YES;
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleInfoWithParameter:nil circleId:self.circleId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.requestInfo = NO;
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            if (_pageView == nil) {
                [self.pageView reloadPage];
                self.titleView.delegate = self;
                self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
            }
            return;
        }
        self.infoModel = (JACircleModel *)responseModel;
        
        if (_pageView == nil) {
            [self.pageView reloadPage];
            self.titleView.delegate = self;
            self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
        }
        
        self.headView.infoModel = self.infoModel;
        self.navBarView.titleName = self.infoModel.circleName;
        self.allViewControl.infoModel = self.infoModel;
        self.essenceViewControl.infoModel = self.infoModel;
        if (self.infoViewControl) {
            self.infoViewControl.circleModel = self.infoModel;
        }
        
        if ([self.infoModel.level integerValue] > 0 && toast) {
            [self.view ja_makeToast:[NSString stringWithFormat:@"获得等级:Lv%@",self.infoModel.level]];
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.requestInfo = NO;
    }];
}

// 关注圈子
- (void)request_followCircle
{
    // 关注圈子
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_focusCircleWithParameter:nil circleId:self.infoModel.circleId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            return;
        }
        NSDictionary *dic = request.responseObject[@"resBody"];
        if ([dic[@"follow"] integerValue]) {
            self.headView.focusButton.selected = YES;
            if (self.focusAndCancleCircleBlock) {
                self.focusAndCancleCircleBlock(YES);
            }
        }else{
            self.headView.focusButton.selected = NO;
            if (self.focusAndCancleCircleBlock) {
                self.focusAndCancleCircleBlock(NO);
            }
        }
        [self request_getCircleInfoWithToast:YES];
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];

}

// 关注圈子签到
- (void)request_followCircleSign
{
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleSignWithParameter:nil circleId:self.infoModel.circleId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
        }

        [self request_getCircleInfoWithToast:YES];
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

#pragma mark - JAHorizontalPageView代理
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return 2;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if (index == 0) {
        JACircleAllStoryListViewController *vc1 = [JACircleAllStoryListViewController new];
        _allViewControl = vc1;
        vc1.currentSortType = self.currentSortType;
        vc1.circleId = self.circleId;
        self.allViewControl.infoModel = self.infoModel;
        [self addChildViewController:vc1];
        return (UIScrollView *)vc1.view;
    }else{
        JACircleEssenceStoryListViewController *vc2 = [[JACircleEssenceStoryListViewController alloc]init];
        _essenceViewControl = vc2;
        vc2.currentSortType = self.currentSortType;
        vc2.circleId = self.circleId;
        self.essenceViewControl.infoModel = self.infoModel;
        [self addChildViewController:vc2];
        return (UIScrollView *)vc2.view;
    }
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    UIView *circleHeadView = [[UIView alloc] init];
    _circleHeadView = circleHeadView;
    circleHeadView.width = JA_SCREEN_WIDTH;
    circleHeadView.height = 230 + (iPhoneX ? 24.f : 0.f);
    
    JACircleDetailHeadView *headView = [[JACircleDetailHeadView alloc] init];
    _headView = headView;
    headView.width = JA_SCREEN_WIDTH;
    headView.height = 180 + (iPhoneX ? 24.f : 0.f);
    [headView.focusButton addTarget:self action:@selector(clickFocusCircle:) forControlEvents:UIControlEventTouchUpInside];
    [circleHeadView addSubview:headView];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    lineView.width = JA_SCREEN_WIDTH;
    lineView.height = 10;
    lineView.y = headView.bottom;
    
    self.sectionView.y = lineView.bottom;
    [circleHeadView addSubview:self.sectionView];
    
    
    return circleHeadView;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return 230 + (iPhoneX ? 24.f : 0.f);
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView      // 控制在什么地方悬停
{
    return ((iPhoneX) ? 128 : 104);
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{
    self.navBarView.offset = offset;
    
    if (self.isNeedNoti) {
        if (offset / JA_StatusBarAndNavigationBarHeight >= 1) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        }
    }
}

#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex
{
    if (toIndex == 0) {
        self.sectionView.middleButton.selected = NO;
        self.sectionView.middleView.hidden = YES;
        
        self.sectionView.leftButton.selected = YES;
        self.sectionView.leftView.hidden = NO;
    }else{
        self.sectionView.leftButton.selected = NO;
        self.sectionView.leftView.hidden = YES;
        
        self.sectionView.middleButton.selected = YES;
        self.sectionView.middleView.hidden = NO;
    }
}

#pragma mark - 按钮点击
- (void)goToPublish
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    [JAPreReleaseView showPreReleaseViewWithCircle:self.infoModel];
}

- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)clickInfoButton
{
    if (!self.infoModel.circleId.length) {
        [self.view ja_makeToast:@"圈子资料获取失败,稍后再试"];
        return;
    }
    
    JACircleInfoViewController *vc = [[JACircleInfoViewController alloc] init];
    self.infoViewControl = vc;
    vc.circleModel = self.infoModel;
    @WeakObj(self);
    vc.followAndCancleCircle = ^(BOOL isFollow) {
        @StrongObj(self);
        self.infoModel.isConcern = isFollow;
        [self request_getCircleInfoWithToast:YES];
        if (self.focusAndCancleCircleBlock) {
            self.focusAndCancleCircleBlock(isFollow);
        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)clickFocusCircle:(UIButton *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }

    if (!self.infoModel.circleId.length) {
        [self.view ja_makeToast:@"圈子资料获取失败,稍后再试"];
        return;
    }
    
    if (self.requestInfo) {
        return;
    }
    
    if (self.infoModel.hasSign) {  // 已经签到
        return;
    }
    
    if (self.infoModel.isConcern) {  // 已经关注
        [self request_followCircleSign];
        return;
    }
    
    [self request_followCircle];
}

- (void)clickSectionLeftButton:(UIButton *)button  // 全部帖子
{
    self.sectionView.middleButton.selected = NO;
    self.sectionView.middleView.hidden = YES;
    button.selected = YES;
    self.sectionView.leftView.hidden = NO;
    
    [self.pageView scrollToIndex:0];
}

- (void)clickSectionMiddleButton:(UIButton *)button  // 精华帖子
{
    self.sectionView.leftButton.selected = NO;
    self.sectionView.leftView.hidden = YES;
    button.selected = YES;
    self.sectionView.middleView.hidden = NO;
    [self.pageView scrollToIndex:1];
}

// 最新回复、最新发表
- (void)clickSectionRightButton:(UIButton *)button
{
    PopoverView *popoverView = [PopoverView popoverView];
    [popoverView showToView:button withActions:[self QQActions:button]];
}
- (NSArray<PopoverAction *> *)QQActions:(UIButton *)button {
    PopoverAction *theNewAction = [PopoverAction actionWithImage:nil title:@"最新回复" handler:^(PopoverAction *action) {
        
        [button setTitle:@"最新回复" forState:UIControlStateNormal];
        self.currentSortType = 0;
        self.allViewControl.currentSortType = self.currentSortType;
        self.essenceViewControl.currentSortType = self.currentSortType;
        [self.allViewControl listStory_refreshAllStory];
        [self.essenceViewControl listStory_refreshEssenceStory];
        
    }];
    PopoverAction *theHotAction = [PopoverAction actionWithImage:nil title:@"最新发表" handler:^(PopoverAction *action) {
        
        [button setTitle:@"最新发表" forState:UIControlStateNormal];
        self.currentSortType = 1;
        self.allViewControl.currentSortType = self.currentSortType;
        self.essenceViewControl.currentSortType = self.currentSortType;
        [self.allViewControl listStory_refreshAllStory];
        [self.essenceViewControl listStory_refreshEssenceStory];
    }];
    
    
    return @[theNewAction, theHotAction];
}

#pragma mark - UI
- (void)setupCircleDetailViewControllerUI
{
    // 分页tab
    self.titleView = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    self.titleView.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    NSArray *arr = @[@"最新",@"最热"];
    [self.titleView setItems:arr selectedItemIndex:0];
    
    JACircleDetailNavBarView *navBarView = [[JACircleDetailNavBarView alloc] init];
    _navBarView = navBarView;
    [navBarView.backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [navBarView.infoButton addTarget:self action:@selector(clickInfoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBarView];
    self.navBarView.width = JA_SCREEN_WIDTH;
    self.navBarView.height = JA_StatusBarAndNavigationBarHeight;
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _publishButton = publishButton;
    [publishButton setImage:[UIImage imageNamed:@"circle_publish"] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(goToPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:publishButton];
}

- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        _pageView.needHeadGestures = YES;
        _pageView.needMiddleRefresh = YES;
        [self.view insertSubview:_pageView belowSubview:_navBarView];
    }
    
    return _pageView;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.publishButton.width = 50;
    self.publishButton.height = 50;
    self.publishButton.centerX = self.view.width * 0.5;
    self.publishButton.y = self.view.height - 50 - JA_TabbarSafeBottomMargin;
}

- (JACommonSectionView *)sectionView
{
    if (_sectionView == nil) {
        
        _sectionView = [[JACommonSectionView alloc] initWithType:JACommonSectionViewType_moreButton];
        _sectionView.backgroundColor = [UIColor whiteColor];
        _sectionView.width = JA_SCREEN_WIDTH;
        _sectionView.height = 40;
        [_sectionView.leftButton setTitle:@"全部帖子" forState:UIControlStateNormal];
        [_sectionView.leftButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        [_sectionView.leftButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateSelected];
        _sectionView.leftButton.titleLabel.font = JA_REGULAR_FONT(14);
        [_sectionView.leftButton addTarget:self action:@selector(clickSectionLeftButton:) forControlEvents:UIControlEventTouchUpInside];
        _sectionView.leftButton.selected = YES;
        
        [_sectionView.middleButton setTitle:@"精华帖" forState:UIControlStateNormal];
        [_sectionView.middleButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        [_sectionView.middleButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateSelected];
        _sectionView.middleButton.titleLabel.font = JA_REGULAR_FONT(14);
        [_sectionView.middleButton addTarget:self action:@selector(clickSectionMiddleButton:) forControlEvents:UIControlEventTouchUpInside];
        _sectionView.middleView.hidden = YES;
        
        [_sectionView.rightButton setImage:[UIImage imageNamed:@"circle_sort"] forState:UIControlStateNormal];
        [_sectionView.rightButton setTitle:@"最新回复" forState:UIControlStateNormal];
        [_sectionView.rightButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        _sectionView.rightButton.titleLabel.font = JA_REGULAR_FONT(13);
        [_sectionView.rightButton addTarget:self action:@selector(clickSectionRightButton:) forControlEvents:UIControlEventTouchUpInside];
        [_sectionView commonSection_layoutView];
        
        _sectionView.verticalLineView.hidden = YES;
    }
    return _sectionView;
}

@end
