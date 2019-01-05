//
//  JACircleDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAoldCircleDetailViewController.h"
#import "JACircleDetailNavBarView.h"
#import "JACircleDetailHeadView.h"
#import "JAStoryTableView.h"
#import "JACommonSectionView.h"

#import "JACircleNetRequest.h"

#import "JACircleInfoViewController.h"
#import "JAPostDetailViewController.h"

#import "JAPreReleaseView.h"
#import "LCActionSheet.h"

@interface JAoldCircleDetailViewController () <JAStoryTableViewDelegate, JACircleDetailHeadViewDelegate>
@property (nonatomic, weak) JACircleDetailNavBarView *navBarView;  // 导航条
@property (nonatomic, weak) JACircleDetailHeadView *headView;  // 头部
@property (nonatomic, strong) JAStoryTableView *tableView;
@property (nonatomic, strong) JACommonSectionView *sectionView;  // 组头
@property (nonatomic, weak) UIButton *publishButton;

@property (nonatomic, strong) JACircleModel *infoModel; // 圈子信息model

@property (nonatomic, assign) NSInteger currentPage;  // 当前页码
@property (nonatomic, assign) long long currentTime;  // 当前请求时间
@property (nonatomic, assign) NSInteger currentSortType;  // 当前排序类型  0 默认  1 倒序
@property (nonatomic, assign) NSInteger currentVoiceType;  // 当前帖子类型 0 全部  1 精华帖
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
@end

@implementation JAoldCircleDetailViewController

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCircleDetailViewControllerUI];
    
    [self request_getCircleInfoAndTopVoice];
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCircleInfoAndTopVoice];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCircleVoiceWithMore:YES];
        
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReleaseVoiceModel:) name:@"refreshVoiceModel" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshNav) name:@"STKAudioPlayer_status" object:nil];
}

- (void)playStatus_refreshNav
{
    [self.navBarView circleDetailNavBarView_changeInfoButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navBarView circleDetailNavBarView_changeInfoButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 网络请求
// 请求圈子资料 所有置顶帖
- (void)request_getCircleInfoAndTopVoice
{
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleInfoWithParameter:nil circleId:self.circleId];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(1);
    dic[@"pageSize"] = @(10);
    JACircleNetRequest *r1 = [[JACircleNetRequest alloc] initRequest_circleStickPostWithParameter:dic circleId:self.circleId];
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[r,r1]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {

        NSArray *requests = batchRequest.requestArray;
        JACircleNetRequest *a = (JACircleNetRequest *)requests[0];
        JACircleNetRequest *b = (JACircleNetRequest *)requests[1];
        NSLog(@"%@ - %@",a,a.responseObject);
        NSLog(@"%@ - %@",b,b.responseObject);
        
        // 解析圈子信息的请求数据
        if ([a.responseObject[@"code"] integerValue] == 10000) {
            JACircleModel *model = [JACircleModel mj_objectWithKeyValues:a.responseObject[@"resBody"]];
            self.infoModel = model;
            self.headView.infoModel = self.infoModel;
            self.navBarView.titleName = self.infoModel.circleName;
        }

        // 解析置顶帖子的请求数据
        if ([b.responseObject[@"code"] integerValue] == 10000) {
            NSArray *topArray = [JANewVoiceModel mj_objectArrayWithKeyValuesArray:b.responseObject[@"resBody"]];
            self.headView.topVoiceArray = topArray;
        }
        
        // 计算headview的高度重新赋值
        self.headView.height = 210 + (iPhoneX ? 24.f : 0.f) + (self.headView.topVoiceArray.count > 0 ? (45 * self.headView.topVoiceArray.count + 40 + 10) : 0);
        self.tableView.tableHeaderView = self.headView;
        
        // 请求圈子帖子列表数据
        [self request_getCircleVoiceWithMore:NO];

    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        [self showBlankPageWithLocationY:64 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRequestCircleInfo) buttonShow:YES];
    }];
}

- (void)againRequestCircleInfo
{
    [self removeBlankPage];
    [self request_getCircleInfoAndTopVoice];
}

// 请求圈子下的全部帖子
- (void)request_getCircleVoiceWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
        
        NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
        NSTimeInterval time = [date timeIntervalSince1970]*1000;
        self.currentTime = (long long)time;
//        self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    if (self.currentVoiceType) {
        dic[@"essence"] = @(self.currentVoiceType);
    }
    dic[@"orderType"] = @(self.currentSortType);
    dic[@"flushTime"] = [NSString stringWithFormat:@"%lld",self.currentTime];

    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleVoiceListWithParameter:dic circleId:self.circleId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
//        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.code != 10000) {
            if (!self.tableView.voices.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithLocationY:self.headView.height + self.sectionView.height title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            }
            return;
        }
        
        if (!isMore) {
            [self.tableView.voices removeAllObjects];
        }
        
        if (self.tableView.voices.count) {
            NSMutableArray *deWeightArray = [NSMutableArray array];
            for (JANewVoiceModel *voice in model.resBody) {
                [self.tableView.voices enumerateObjectsUsingBlock:^(JANewVoiceModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![voice.storyId isEqualToString:obj.storyId] && ![deWeightArray containsObject:voice]) {
                        [deWeightArray addObject:voice];
                    }
                }];
            }
            [self.tableView.voices addObjectsFromArray:deWeightArray];
        }else{
            // 添加数据
            [self.tableView.voices addObjectsFromArray:model.resBody];
        }
        // 添加数据
//        [self.tableView.voices addObjectsFromArray:model.resBody];
        
        if (!isMore) {
            [self showBlankPage];  // 空数据
        }
        
        if (self.tableView.voices.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
//        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (self.tableView.voices.count == 0) {
            [self showBlankPageWithLocationY:self.sectionView.bottom title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
        
    }];
}

#pragma mark - 按钮的点击i
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
    vc.circleModel = self.infoModel;
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
    
    // 关注圈子
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_focusCircleWithParameter:nil circleId:self.infoModel.circleId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            return;
        }
        NSDictionary *dic = request.responseObject[@"resBody"];
        if ([dic[@"follow"] integerValue]) {
            button.selected = YES;
            if (self.focusAndCancleCircleBlock) {
                self.focusAndCancleCircleBlock(YES);
            }
        }else{
            button.selected = NO;
            if (self.focusAndCancleCircleBlock) {
                self.focusAndCancleCircleBlock(NO);
            }
        }
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

- (void)goToPublish
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    [JAPreReleaseView showPreReleaseViewWithCircle:self.infoModel];
}

#pragma mark - 发布回调
- (void)getReleaseVoiceModel:(NSNotification *)noti
{
    NSDictionary *dic = (NSDictionary *)noti.object;
    if (!dic) {
        return;
    }
    JANewVoiceModel *release_voiceModel = (JANewVoiceModel *)dic[@"data"];
    if (![release_voiceModel.circle.circleName isEqualToString:self.infoModel.circleName]) {
        return;
    }
    if (release_voiceModel) {
        
        [self.tableView.voices insertObject:release_voiceModel atIndex:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.tableView reloadData];
            
            NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:0];
            
            [self.tableView selectRowAtIndexPath:p animated:NO scrollPosition:UITableViewScrollPositionNone];
        });
        
    }
}

#pragma mark - 点击组头按钮
- (void)clickSectionLeftButton:(UIButton *)button  // 全部帖子
{
    self.sectionView.middleButton.selected = NO;
    self.sectionView.middleView.hidden = YES;
    button.selected = YES;
    if (button.selected) {
        self.currentVoiceType = 0;
    }
    self.sectionView.leftView.hidden = NO;
    
    [self request_getCircleVoiceWithMore:NO];
}

- (void)clickSectionMiddleButton:(UIButton *)button  // 精华帖子
{
    self.sectionView.leftButton.selected = NO;
    self.sectionView.leftView.hidden = YES;
    button.selected = YES;
    if (button.selected) {
        self.currentVoiceType = 1;
    }
    self.sectionView.middleView.hidden = NO;
    
    [self request_getCircleVoiceWithMore:NO];
}

// 最新回复、最新发表
- (void)clickSectionRightButton:(UIButton *)button
{
    NSMutableArray *buttonTitle = [NSMutableArray array];
    [buttonTitle addObject:@"按最新回复排序"];
    [buttonTitle addObject:@"按最新发表排序"];
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:buttonTitle redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex == 0) {
            [button setTitle:@"最新回复" forState:UIControlStateNormal];
            self.currentSortType = 0;
            [self requestWithSort];
        }else if (buttonIndex == 1){
            [button setTitle:@"最新发表" forState:UIControlStateNormal];
            self.currentSortType = 1;
            [self requestWithSort];
        }
    }];
    
    [actionS show];
    
}

- (void)requestWithSort
{
    [self request_getCircleVoiceWithMore:NO];
}

#pragma mark -  JAStoryTableViewDelegate
- (void)ja_scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.tableView.mj_header.state == MJRefreshStateRefreshing) {
        return;
    }
//    self.headView.offset = scrollView.contentOffset.y;
    self.navBarView.offset = scrollView.contentOffset.y;
    
    if (scrollView.contentOffset.y >= JA_StatusBarAndNavigationBarHeight) {
        self.tableView.contentInset = UIEdgeInsetsMake(JA_StatusBarAndNavigationBarHeight, 0, self.tableView.contentInset.bottom, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tableView.contentInset.bottom, 0);
    }
    
}

#pragma mark - JACircleDetailHeadViewDelegate
- (void)circleDetailHeadView_didSelectWithRow:(NSInteger)row headView:(JACircleDetailHeadView *)headView
{
    // 获取数据
    JANewVoiceModel *model = headView.topVoiceArray[row];
    JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
    vc.voiceId = model.storyId;
    vc.enterType = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI
- (void)setupCircleDetailViewControllerUI
{
    self.tableView = [[JAStoryTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0) superVC:self sectionHeaderView:self.sectionView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin + 50, 0);
    self.tableView.ja_scrollDelegate = self;
    [self.view addSubview:self.tableView];
    
    JACircleDetailNavBarView *navBarView = [[JACircleDetailNavBarView alloc] init];
    _navBarView = navBarView;
    [navBarView.backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [navBarView.infoButton addTarget:self action:@selector(clickInfoButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navBarView];
    
    JACircleDetailHeadView *headView = [[JACircleDetailHeadView alloc] init];
    _headView = headView;
    headView.delegate = self;
    headView.width = JA_SCREEN_WIDTH;
    headView.height = 210 + (iPhoneX ? 24.f : 0.f);
    [headView.focusButton addTarget:self action:@selector(clickFocusCircle:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView.tableHeaderView = headView;
    
    UIButton *publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _publishButton = publishButton;
    [publishButton setImage:[UIImage imageNamed:@"circle_publish"] forState:UIControlStateNormal];
    [publishButton addTarget:self action:@selector(goToPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:publishButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
    self.navBarView.width = JA_SCREEN_WIDTH;
    self.navBarView.height = JA_StatusBarAndNavigationBarHeight;
    self.publishButton.width = 50;
    self.publishButton.height = 50;
    self.publishButton.centerX = self.view.width * 0.5;
    self.publishButton.y = self.view.height - 50 - JA_TabbarSafeBottomMargin;
}



// 展示空白页
- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
        
    }else{
        NSString *t = self.currentVoiceType == 0 ? @"还没有相关帖子" : @"还没有精华帖";
        NSString *st = @"";
        [self showBlankPageWithLocationY:self.headView.height + self.sectionView.height title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        
    }
}
@end
