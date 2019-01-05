//
//  JAStoryViewController.m
//  Jasmine
//
//  Created by xujin on 2018/5/24.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryViewController.h"
#import "JAStoryTableView.h"
#import "JAVoiceGroupModel.h"
#import "JAVoiceApi.h"
#import "JAPostDetailViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAVoiceReleaseViewController.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceCommentGroupModel.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceFollowView.h"
#import "JAVoiceCommonApi.h"
#import "JAActivityModel.h"
#import "JAWebViewController.h"
#import "JAPersonalTaskViewController.h"
#import "JAPacketViewController.h"
#import "JAPlatformShareManager.h"
#import "JAFunctionToolV.h"
#import "SDCycleScrollView.h"
#import "JANoobPageView.h"
#import "JACenterDrawerViewController.h"
#import "JAHelperViewController.h"
#import "JADIYRefreshHeader.h"
#import "JASampleHelper.h"
#import "JAVoicePersonApi.h"
#import "XDLocationTool.h"
#import "JAUploadProgressView.h"
#import "JAReuploadView.h"
#import "JAReleasePostManager.h"
#import "JARefreshToastView.h"
#import "JATopicApi.h"
#import "JAPersonTopicViewController.h"
#import "NSDictionary+NTESJson.h"
#import "JAPersonTopicViewController.h"
#import "JADataHelper.h"
#import "JAVoicePlayerManager.h"
#import "JAMayLikeView.h"
#import "JAStoryTableView.h"
#import "JARecommendNetRequest.h"
#import "JAStoryAlbumViewController.h"
#import "JAAlbumDetailViewController.h"
#import "JACircleDetailViewController.h"
#import "JAAlbumDetailViewController.h"
#import "CYLTabBarController.h"
#import "JAVoiceTopicGroupModel.h"
#import "JATopicViewController.h"

@interface JAStoryViewController ()<JAPlayerDelegate,SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *activities;
@property (nonatomic, assign) int allCount;
@property (nonatomic, assign) BOOL isPause;
@property (nonatomic, assign) BOOL isSelectedZero;
// 关注人列表
@property (nonatomic, strong) JAVoiceFollowView *followView;

// 已定位过
@property (nonatomic, strong) CLLocation *location;
// v2.5.0
@property (nonatomic, strong) JAUploadProgressView *uploadProgressView;
@property (nonatomic, strong) JAReuploadView *reuploadView;

@property (nonatomic, weak) JARefreshToastView *toastView;  // 弹窗
// v2.5.4
@property (nonatomic, strong) NSMutableArray *topicArray;
@property (nonatomic, assign) NSInteger topicPage;
@property (nonatomic, copy) NSString *sortString;
// v2.6.0
@property (nonatomic, assign) BOOL isFirstLoad;
// v3.0.0
@property (nonatomic, strong) JAMayLikeView *mayLikeView;
@property (nonatomic, strong) JAStoryTableView *storyTableView;

@end

@implementation JAStoryViewController

- (void)dealloc {
    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.topicArray = [NSMutableArray new];
    self.currentPage = 1;
    self.topicPage = 1;
 
    self.view.backgroundColor = HEX_COLOR(JA_Background);
    self.activities = [NSMutableArray new];
    [self setUpUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adminDelVoice:) name:@"AdminDelVoice" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReleaseVoiceModel:) name:@"refreshVoiceModel" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSelectedIndexValue) name:@"selectedZero" object:nil];
    if ([self.model.channelId isEqualToString:@"1"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadState:) name:@"JAUploadState" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(home_refreshCommendList) name:@"JA_HOME_REFRESH_BEGIN" object:nil];
    if ([self.model.channelId isEqualToString:@"2"]) {
    }
}

// 首页刷新
- (void)home_refreshCommendList
{
    
    if (![self.view isDisplayedInScreen]) {
        return;
    }
    
    if (self.isRequesting) {
        return;
    }
    [self.storyTableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.cycleScrollView adjustWhenControllerViewWillAppera];
    
    NSInteger currentDisplayIndex = self.centerVc.contentView.contentViewCurrentIndex;
    JAChannelModel *currentModel =  self.channels[currentDisplayIndex];
    if ([currentModel.channelId isEqualToString:self.model.channelId]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[JA_Property_ScreenName] = [NSString stringWithFormat:@"首页-%@",self.model.title];
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // v2.6.0
    if (!self.isFirstLoad) {
        self.isFirstLoad = YES;
        [self.storyTableView.mj_header beginRefreshing];
        [self getTopicListWithLoadMore:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)setupFollowView {
    JAVoiceFollowView *followView = [[JAVoiceFollowView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0)];
    followView.hidden = YES;
    followView.vc = self;
    [self.view addSubview:followView];
    @WeakObj(self);
    followView.followSuccess = ^{
        @StrongObj(self);
        self.followView.hidden = YES;
        self.storyTableView.hidden = NO;
        [self getFollowVoiceListWithLoadMore:NO];
    };
    self.followView = followView;
    
    JAUploadProgressView *uploadProgressView = [[JAUploadProgressView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 15)];
    uploadProgressView.hidden = YES;
    [self.view addSubview:uploadProgressView];
    self.uploadProgressView = uploadProgressView;
    
    JAReuploadView *reuploadView = [[JAReuploadView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 35)];
    reuploadView.hidden = YES;
    [self.view addSubview:reuploadView];
    self.reuploadView = reuploadView;
    
    // 先发布，后创建关注页面
    if ([JAReleasePostManager shareInstance].postDraftModel) {
        [self uploadState:nil];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.followView.height = self.view.height-JA_TabbarHeight;
    self.storyTableView.height = self.view.height-JA_TabbarHeight;
}

- (void)setUpUI{
    JANewVoiceGroupModel *model = nil;
    if ([self.model.channelId isEqualToString:@"1"]) {
        // 关注列表（没有关注人，显示人列表；关注后，显示关注人的内容）
        
    } else if ([self.model.channelId isEqualToString:@"2"]) {
        NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/VoiceData/newvoice_%@.data",self.model.channelId]];
        @try {
            model = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        } @catch (NSException *exception) {
            model = nil;
        }
    } else if ([self.model.channelId isEqualToString:@"3"]) {
        NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/VoiceData/newvoice_%@.data",self.model.channelId]];
        @try {
            model = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        } @catch (NSException *exception) {
            model = nil;
        }
    }
   
    self.storyTableView = [[JAStoryTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0) superVC:self sectionHeaderView:nil];
    self.storyTableView.model = self.model;
    [self.view addSubview:self.storyTableView];
    if (model.resBody.count) {
        [self.storyTableView.voices addObjectsFromArray:model.resBody];
        [self.storyTableView reloadData];
    }

    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, WIDTH_ADAPTER(120)) delegate:self placeholderImage:[UIImage imageWithColor:HEX_COLOR(0xffffff)]];
    self.cycleScrollView.backgroundColor = [UIColor whiteColor];
    self.cycleScrollView.pageControlStyle = SDCycleScrollViewPageContolStyleAnimated;
    self.cycleScrollView.currentPageDotImage = [UIImage imageWithColor:HEX_COLOR(0x50E3C2)];
    self.cycleScrollView.pageDotImage = [UIImage imageWithColor:HEX_COLOR_ALPHA(0xffffff, 0.6)];
    self.cycleScrollView.autoScrollTimeInterval = 5.0;
    self.cycleScrollView.pageControlDotSize = CGSizeMake(3, 3);
    self.cycleScrollView.pageControlSelectedDotSize = CGSizeMake(5, 5);
    self.cycleScrollView.pageControlDotSpacing = 6;
    self.cycleScrollView.pageControlBottomOffset = 5;
    //    self.storyTableView.tableHeaderView = self.cycleScrollView;
    self.cycleScrollView.layer.cornerRadius = 4;
    self.cycleScrollView.layer.masksToBounds = YES;
    self.cycleScrollView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
    self.cycleScrollView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
    
    if (self.model.channelId.integerValue == 2) {
        JAAlbumGroupModel *model = nil;
        NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData/album.data"];
        @try {
            model = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
        } @catch (NSException *exception) {
            model = nil;
        }
        // 猜你喜欢
        self.mayLikeView = [[JAMayLikeView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0)];
        @WeakObj(self);
        self.mayLikeView.moreBlock = ^{
            @StrongObj(self);
            JAStoryAlbumViewController *vc = [JAStoryAlbumViewController new];
            [self.navigationController pushViewController:vc animated:YES];
        };
        self.mayLikeView.seeAlbumBlock = ^(JAAlbumModel *model) {
            @StrongObj(self);
            JAAlbumDetailViewController *vc = [JAAlbumDetailViewController new];
            vc.subjectId = model.subjectId;
            [self.navigationController pushViewController:vc animated:YES];
        };
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, self.mayLikeView.height)];
        [headerView addSubview:self.mayLikeView];
        self.storyTableView.tableHeaderView = headerView;
        
        if (model.resBody.count) {
            self.mayLikeView.datas = model.resBody;
        }
    }
    
    @WeakObj(self)
    // v3.1.0
    self.storyTableView.topicView.loadMoreBlock = ^{
        @StrongObj(self);
//        [self getTopicListWithLoadMore:YES];
        JATopicViewController *vc = [JATopicViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    };
    self.storyTableView.topicView.moreBlock = ^{
        @StrongObj(self);
        JATopicViewController *vc = [JATopicViewController new];
        [self.navigationController pushViewController:vc animated:YES];
    };
    self.storyTableView.topicView.selectBlock = ^(JAVoiceTopicModel *topicModel) {
        @StrongObj(self);
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = topicModel.title;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    self.storyTableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
//        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        @StrongObj(self)
        [self sensorsAnalyticsWithMethod:@"下拉刷新"];
        
        if ([self.model.channelId isEqualToString:@"1"]) {
            if (IS_LOGIN) {
                // 获取关注列表
                [self getFollowVoiceListWithLoadMore:NO];
            } else {
                self.storyTableView.hidden = YES;
                self.followView.hidden = NO;
                [self.followView getFollowData];
                
            }
        } else if ([self.model.channelId isEqualToString:@"2"]) {
            [self getHomeBannerData];
            [self getRecommendAlbumList];
            
            // 获取推荐列表
            [self getRecommendVoiceListWithLoadMore:NO];
        } else if ([self.model.channelId isEqualToString:@"3"]) {
            // 获取最新列表
            [self request_getHomeNewVoiceListWithMore:NO];
        }
    }];
    self.storyTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        [[SDImageCache sharedImageCache] setValue:nil forKey:@"memCache"];
        @StrongObj(self)
        
        [self sensorsAnalyticsWithMethod:@"上滑刷新"];
        
        if ([self.model.channelId isEqualToString:@"1"]) {
            // 获取关注列表
            [self getFollowVoiceListWithLoadMore:YES];
        }  else if ([self.model.channelId isEqualToString:@"2"]) {
            // 获取推荐列表
            [self getRecommendVoiceListWithLoadMore:YES];
        } else if ([self.model.channelId isEqualToString:@"3"]) {
            // 获取最新列表
            [self request_getHomeNewVoiceListWithMore:YES];
        }
    }];
    self.storyTableView.mj_footer.hidden = YES;

    if ([self.model.channelId isEqualToString:@"1"]) {
        [self setupFollowView];
        MJRefreshAutoStateFooter *footer = (MJRefreshAutoStateFooter *)self.storyTableView.mj_footer;
        [footer setTitle:@"没有更多了" forState:MJRefreshStateNoMoreData];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ja_loginSuccess) name:LOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ja_loginOut) name:@"app_loginOut" object:nil];

}

#pragma mark - Notification
// 管理员删除帖子 2.5.5
- (void)adminDelVoice:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *voiceId = dic[@"voiceId"];
    
    [self.storyTableView.voices enumerateObjectsUsingBlock:^(JANewVoiceModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.storyId isEqualToString:voiceId]) {
            [self.storyTableView.voices removeObject:model];
            *stop = YES;
        }
    }];
    
    [self.storyTableView reloadData];
}

- (void)getReleaseVoiceModel:(NSNotification *)noti
{
    NSDictionary *dic = (NSDictionary *)noti.object;
    if (!dic) {
        return;
    }
    NSInteger method = [dic[@"method"] integerValue];
    if (method == 1) {
        if (self.centerVc.titleView.selectedItemIndex != 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.centerVc.titleView.selectedItemIndex = 0;
            });
        }
    }
    
    JANewVoiceModel *release_voiceModel = (JANewVoiceModel *)dic[@"data"];
    if (release_voiceModel) {
        //        release_voiceModel.allPeakLevelQueue = [JASampleHelper getAllPeakLevelQueueWithSampleZip:release_voiceModel.sampleZip];
        // v2.4.0新增
        release_voiceModel.sourceName = [NSString stringWithFormat:@"首页-%@",self.model.title];
        
        if (self.model.channelId.integerValue == 1) {
            
            [self.storyTableView.voices insertObject:release_voiceModel atIndex:0];
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [self.storyTableView reloadData];
                [self.storyTableView setContentOffset:CGPointZero animated:NO];
            });
        }
    }
}

- (void)changeSelectedIndexValue
{
    self.isSelectedZero = YES;
}

- (void)uploadState:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        JAPostDraftModel *currentDraftModel = [JAReleasePostManager shareInstance].postDraftModel;
        switch (currentDraftModel.uploadState) {
            case JAUploadNormalState:
            {
                self.uploadProgressView.hidden = YES;
                self.reuploadView.hidden = YES;
            }
                break;
            case JAUploadUploadingState:
            {
                self.uploadProgressView.hidden = NO;
                self.reuploadView.hidden = YES;
            }
                break;
            case JAUploadSuccessState:
            {
                self.uploadProgressView.hidden = YES;
                self.reuploadView.hidden = YES;
            }
                break;
            case JAUploadFailState:
            {
                // v2.5.5
                if (currentDraftModel.dataType == 2) {
                    self.uploadProgressView.hidden = YES;
                    self.reuploadView.hidden = YES;
                } else {
                    self.uploadProgressView.hidden = YES;
                    self.reuploadView.hidden = NO;
                    self.reuploadView.y = - self.reuploadView.height;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.reuploadView.y = 0;
                    } completion:^(BOOL finished) {
                    }];
                }
            }
                break;
            default:
                break;
        }
    });
}

- (void)ja_loginSuccess {
    [self resetRecommendVC];
    [self resetFollowVC];
}

- (void)ja_loginOut {
    [self resetRecommendVC];
}

// 退出登录和，重新登录需要刷新数据
- (void)resetRecommendVC {
    if ([self.model.channelId isEqualToString:@"2"]) {
        [self.storyTableView setContentOffset:CGPointZero animated:NO];
        [self.storyTableView.voices removeAllObjects];
        [self.storyTableView.mj_header beginRefreshing];
    }
}

// 重新登录需要刷新关注列表
- (void)resetFollowVC {
    if ([self.model.channelId isEqualToString:@"1"]) {
        [self.storyTableView setContentOffset:CGPointZero animated:NO];
        [self.storyTableView.voices removeAllObjects];
        [self.storyTableView.mj_header beginRefreshing];
    }
}

#pragma mark - Public Methods
- (void)needRefreshFocusVC
{
    // v2.5.0bug,有关注红点，但页面还没实例化，导致拉取数据接口调用两次
    if (!self.storyTableView) {
        // 页面未创建，就不执行下面代码
        return;
    }
    if (IS_LOGIN) {
        if (self.storyTableView.voices.count) {
            self.storyTableView.hidden = NO;
            self.followView.hidden = YES;
            // 获取红点的值来修改
            NSString *userKey = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            NSString *key = [NSString stringWithFormat:@"%@_FocusKey",userKey];
            BOOL hasNewFocus = [[NSUserDefaults standardUserDefaults] boolForKey:key];
            if (hasNewFocus) {
                [self getFollowVoiceListWithLoadMore:NO];
            }
        } else {
//            [self getFollowVoiceListWithLoadMore:NO];
//            
//            self.storyTableView.hidden = YES;
//            self.followView.hidden = NO;
//            
//            [self.followView getFollowData];
        }
    }
}

- (void)voiceViewVCscrollTop
{
    [self.storyTableView setContentOffset:CGPointZero animated:YES];
}

#pragma mark - Network
- (void)getHomeBannerData
{
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        return;
    }
    
    if (self.model.channelId.integerValue == 2) {
        // 推荐页面才有banner
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        //        dic[@"categoryId"] = self.model.channelId;
        [[JAVoiceCommonApi shareInstance] voice_getHomeBanner:dic success:^(NSDictionary *result) {
            
            NSArray *bannerList = [JAActivityModel mj_objectArrayWithKeyValuesArray:result[@"bannerList"]];
            NSMutableArray *images = [NSMutableArray new];
            self.activities = [NSMutableArray new];
            [bannerList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                JAActivityModel *model = (JAActivityModel *)obj;
                if (model.activityImage.length) {
                    [images addObject:model.activityImage];
                    [self.activities addObject:model];
                }
            }];
            if (images.count) {
                self.cycleScrollView.imageURLStringsGroup = images;
                UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, self.cycleScrollView.height+self.mayLikeView.height)];
                [headerView addSubview:self.cycleScrollView];
                self.mayLikeView.y = self.cycleScrollView.bottom;
                [headerView addSubview:self.mayLikeView];
                self.storyTableView.tableHeaderView = headerView;
            }
        } failure:^(NSError *error) {
        }];
    }
}

// 首页推荐专辑
- (void)getRecommendAlbumList {
    if (self.model.channelId.integerValue == 2) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"pageNum"] = @"1";
        dic[@"pageSize"] = @"10";
        JARecommendNetRequest *request = [[JARecommendNetRequest alloc] initRequest_albumListWithParameter:dic];
        [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
            if (responseModel.code != 10000) {
                return;
            }
            JAAlbumGroupModel *groupModel = (JAAlbumGroupModel *)responseModel;
            if (groupModel.resBody.count) {
                self.mayLikeView.datas = groupModel.resBody;
                
                NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData"];
                NSFileManager *filemanager = [NSFileManager new];
                if (![filemanager fileExistsAtPath:dictionaryPath]) {
                    [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData/album.data"];
                [NSKeyedArchiver archiveRootObject:groupModel toFile:filepath];
            }
            
        } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
            
        }];
    }
}

#pragma mark - 网络请求
- (void)request_getHomeNewVoiceListWithMore:(BOOL)isLoadMore
{
    if (self.isRequesting) {
        return;
    }
    if (!isLoadMore) {
        if (self.toastView) {
            [self.toastView removeFromSuperview];
        }
        self.currentPage = 1;
        self.storyTableView.mj_footer.hidden = YES;
    }
    
    // 开始请求
    self.isRequesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"6";
    JARecommendNetRequest *r = [[JARecommendNetRequest alloc] initRequest_newStoryListWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequesting = NO;
        [self.storyTableView.mj_header endRefreshing];
        [self.storyTableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_END" object:nil];
        
        if (responseModel.code != 10000) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
            return;
        }
        if (!isLoadMore) {
            [self.storyTableView.voices removeAllObjects];
        }
        NSMutableArray *newData = [NSMutableArray new];
        JANewVoiceGroupModel *groupModel = (JANewVoiceGroupModel *)responseModel;
        if (groupModel.resBody.count) {
            for (JANewVoiceModel *model in groupModel.resBody) {
                // v2.4.0新增
                model.sourceName = [NSString stringWithFormat:@"首页-%@",self.model.title];
                __block BOOL isRepeatData = NO;
                [self.storyTableView.voices enumerateObjectsUsingBlock:^(JANewVoiceModel *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj.storyId isEqualToString:model.storyId]) {
                        isRepeatData = YES;
                        *stop = YES;
                    }
                }];
                if (!isRepeatData) {
                    [newData addObject:model];
                }
            }
            if (newData.count) {
                [self.storyTableView.voices addObjectsFromArray:newData];
            }
            if (!isLoadMore) {
                JARefreshToastView *toastV = [[JARefreshToastView alloc] init];
                [self.view addSubview:toastV];
                [toastV refreshContentWithCount:newData.count type:4];
                self.toastView = toastV;
                
//                NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData"];
//                NSFileManager *filemanager = [NSFileManager new];
//                if (![filemanager fileExistsAtPath:dictionaryPath]) {
//                    [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
//                }
//                NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/VoiceData/newvoice_%@.data",self.model.channelId]];
//                [NSKeyedArchiver archiveRootObject:groupModel toFile:filepath];
            }
            if (groupModel.total != self.storyTableView.voices.count) {
                self.currentPage++;
                self.storyTableView.mj_footer.hidden = NO;
            }else{
                self.storyTableView.mj_footer.hidden = YES;
            }
        }
        [self.storyTableView reloadData];
        if (self.storyTableView.voices.count) {
            [self removeBlankPage];
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequesting = NO;
        [self.storyTableView.mj_header endRefreshing];
        [self.storyTableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_END" object:nil];
        if (!self.storyTableView.voices.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

// 首页推荐刷新
- (void)getRecommendVoiceListWithLoadMore:(BOOL)isLoadMore {
    if (self.isRequesting) {
        return;
    }
    // 开始请求
    self.isRequesting = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    if (!isLoadMore) {
        if (self.toastView) {
            [self.toastView removeFromSuperview];
        }
        self.storyTableView.mj_footer.hidden = YES;
    }
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"6";
    JARecommendNetRequest *r = [[JARecommendNetRequest alloc] initRequest_storyListWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequesting = NO;
        [self.storyTableView.mj_header endRefreshing];
        [self.storyTableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_END" object:nil];
        
        if (responseModel.code != 10000) {
            return;
        }
        if (!isLoadMore) {
            [self.storyTableView.voices removeAllObjects];
        }
        NSMutableArray *newData = [NSMutableArray new];
        JANewVoiceGroupModel *groupModel = (JANewVoiceGroupModel *)responseModel;
        if (groupModel.resBody.count) {
            for (JANewVoiceModel *model in groupModel.resBody) {
//                model.allPeakLevelQueue = [JASampleHelper getAllPeakLevelQueueWithSampleZip:model.sampleZip];
                // v2.4.0新增
                model.sourceName = [NSString stringWithFormat:@"首页-%@",self.model.title];
                __block BOOL isRepeatData = NO;
                [self.storyTableView.voices enumerateObjectsUsingBlock:^(JANewVoiceModel *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj.storyId isEqualToString:model.storyId]) {
                        isRepeatData = YES;
                        *stop = YES;
                    }
                }];
                if (!isRepeatData) {
                    [newData addObject:model];
                }
            }
            if (newData.count) {
                [self.storyTableView.voices addObjectsFromArray:newData];
            }
            if (!isLoadMore) {
                JARefreshToastView *toastV = [[JARefreshToastView alloc] init];
                [self.view addSubview:toastV];
                [toastV refreshContentWithCount:newData.count type:2];
                self.toastView = toastV;
                
                NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData"];
                NSFileManager *filemanager = [NSFileManager new];
                if (![filemanager fileExistsAtPath:dictionaryPath]) {
                    [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/VoiceData/newvoice_%@.data",self.model.channelId]];
                [NSKeyedArchiver archiveRootObject:groupModel toFile:filepath];
            }
            if (groupModel.total != self.storyTableView.voices.count) {
                self.currentPage++;
                self.storyTableView.mj_footer.hidden = NO;
            }else{
                self.storyTableView.mj_footer.hidden = YES;
            }
        }
        [self.storyTableView reloadData];
        if (self.storyTableView.voices.count) {
            [self removeBlankPage];
        }
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequesting = NO;
        [self.storyTableView.mj_header endRefreshing];
        [self.storyTableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_END" object:nil];
        if (!self.storyTableView.voices.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self.storyTableView.mj_header beginRefreshing];
}

// 首页关注列表刷新
- (void)getFollowVoiceListWithLoadMore:(BOOL)isLoadMore {
    if (!isLoadMore) {
        if (self.toastView) {
            [self.toastView removeFromSuperview];
        }
        self.currentPage = 1;
        self.storyTableView.mj_footer.hidden = YES;
        // 获取红点的值来修改
        [JARedPointManager resetNewRedPointArrive:JARedPointTypeHomePageFocus];
    }
    // 开始请求
    self.isRequesting = YES;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"6";
    JARecommendNetRequest *request = [[JARecommendNetRequest alloc] initRequest_followListWithParameter:dic];
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequesting = NO;
        [self.storyTableView.mj_header endRefreshing];
        [self.storyTableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_END" object:nil];
       
        if (responseModel.code != 10000) {
            return;
        }
        JANewVoiceGroupModel *groupModel = (JANewVoiceGroupModel *)responseModel;
        if (!isLoadMore) {
            NSInteger Toastcount = [self getToastCount:self.storyTableView.voices.firstObject modelArray:groupModel.resBody];
            JARefreshToastView *toastV = [[JARefreshToastView alloc] init];
            [self.view addSubview:toastV];
            [toastV refreshContentWithCount:Toastcount type:1];
            self.toastView = toastV;
            [self.storyTableView.voices removeAllObjects];
        }
        
        if (groupModel.resBody.count) {
            for (JANewVoiceModel *model in groupModel.resBody) {
//                model.allPeakLevelQueue = [JASampleHelper getAllPeakLevelQueueWithSampleZip:model.sampleZip];
                // v2.4.0新增
                model.sourceName = [NSString stringWithFormat:@"首页-%@",self.model.title];
                __block BOOL isRepeatData = NO;
                [self.storyTableView.voices enumerateObjectsUsingBlock:^(JANewVoiceModel *obj, NSUInteger idx, BOOL *stop) {
                    if ([obj.storyId isEqualToString:model.storyId]) {
                        isRepeatData = YES;
                        *stop = YES;
                    }
                }];
                if (!isRepeatData) {
                    [self.storyTableView.voices addObject:model];
                }
            }
            
            // 判断是否有下一页
            if (groupModel.total != self.storyTableView.voices.count) {
                self.currentPage++;
                self.storyTableView.mj_footer.hidden = NO;
            }else{
                self.storyTableView.mj_footer.hidden = YES;
            }
        }
        [self.storyTableView reloadData];
        
        if (self.storyTableView.voices.count) {
            [self removeBlankPage];
            self.storyTableView.hidden = NO;
            self.followView.hidden = YES;
        } else {
            self.storyTableView.hidden = YES;
            self.followView.hidden = NO;
            [self.followView getFollowData];
        }
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.isRequesting = NO;
        [self.storyTableView.mj_header endRefreshing];
        [self.storyTableView.mj_footer endRefreshing];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_HOME_REFRESH_END" object:nil];
        if (!self.storyTableView.voices.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

// 获取话题列表
- (void)getTopicListWithLoadMore:(BOOL)isLoadMore {
    if (!isLoadMore) {
        self.currentPage = 1;
        self.storyTableView.topicView.loadMoreButton.hidden = YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @"1";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    if(IS_LOGIN) dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JATopicApi shareInstance] topic_recommendTopic:dic success:^(NSDictionary *result) {
        [self.storyTableView.topicView.collectionView.mj_footer endRefreshing];
        // 解析数据
        JAVoiceTopicGroupModel *groupModel = [JAVoiceTopicGroupModel mj_objectWithKeyValues:result[@"topicList"]];
        if (!isLoadMore) {
            [self.storyTableView.topicView.topics removeAllObjects];
        }
        if (groupModel.result.count) {
            [self.storyTableView.topicView.topics addObjectsFromArray:groupModel.result];
        }
        self.storyTableView.topicView.loadMoreButton.hidden = NO;
//        if (groupModel.nextPage != 0 && groupModel.result.count) {
//            self.currentPage = groupModel.currentPageNo + 1;
//            self.storyTableView.topicView.loadMoreButton.hidden = NO;
//        }else{
//            self.storyTableView.topicView.loadMoreButton.hidden = YES;
//        }
        [self.storyTableView.topicView.collectionView reloadData];
        
//        self.storyTableView.topicView.loadMoreButton.hidden = YES;
        CGFloat itemW = WIDTH_ADAPTER(113);
        CGFloat padding = WIDTH_ADAPTER(5);
        CGFloat offsetX = (itemW+padding)*self.storyTableView.topicView.topics.count+15;
        if (offsetX > JA_SCREEN_WIDTH) {
            self.storyTableView.topicView.loadMoreButton.x = offsetX;
        } else {
            self.storyTableView.topicView.loadMoreButton.x = JA_SCREEN_WIDTH;
        }
    } failure:^{
        [self.storyTableView.topicView.collectionView.mj_footer endRefreshing];
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

}
#pragma mark - SDCycleScrollViewDelegate
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index {
    
    JAActivityModel *model = self.activities[index];
    
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BannerId] = model.activityId;
    senDic[JA_Property_BannerPosition] = [NSString stringWithFormat:@"%ld",index];
    senDic[JA_Property_BannerTitle] = model.title;
    [JASensorsAnalyticsManager sensorsAnalytics_clickBanner:senDic];
    
    // 分类型跳转
    if (model.contentType.integerValue == 0 || model.contentType.integerValue == 300) {                                  // web页面
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        NSString *str = model.url;
        if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
            vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        }else{
            vc.urlString = str;
        }
        vc.enterType = @"首页banner";
        [self.navigationController pushViewController:vc animated:YES];
    }else if (model.contentType.integerValue == 1 || model.contentType.integerValue == 127){                           // 帖子详情
        // banner 如果是帖子，分享的话，也算做任务
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        vc.voiceId = model.url;
        vc.channelId = @"2";
        [self.navigationController pushViewController:vc animated:YES];
    }else if (model.contentType.integerValue == 2 || model.contentType.integerValue == 114){                         // 任务页面
        
        if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
            [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
            return;
        }
        
        if (!IS_LOGIN) {
            [JAAPPManager app_modalLogin];
            return;
        }
        
        if ([[JAUserInfo userInfo_getUserImfoWithKey:User_Admin] integerValue] == JAVPOWER) {
            
            return;
        }
        
        JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (model.contentType.integerValue == 3 || model.contentType.integerValue == 110){                                     // 邀请红包页面
        if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
            [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
            return;
        }
        if (!IS_LOGIN) {
            [JAAPPManager app_modalLogin];
            return;
        }
        JAPacketViewController *vc = [[JAPacketViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (model.contentType.integerValue == 4 || model.contentType.integerValue == 118){
        JAWebViewController *help = [[JAWebViewController alloc] init];
        help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
        help.titleString = @"帮助中心";
        help.fromType = 1;
        help.enterType = @"帮助中心";
        [self.navigationController pushViewController:help animated:YES];
        
    }else if (model.contentType.integerValue == 5 || model.contentType.integerValue == 119){
        JAWebViewController *help = [[JAWebViewController alloc] init];
        help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
        help.titleString = @"帮助中心";
        help.fromType = 1;
        help.enterType = @"帮助中心";
        [self.navigationController pushViewController:help animated:YES];
        
    }else if (model.contentType.integerValue == 128){                                     // 话题详情
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = model.url;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (model.contentType.integerValue == 130){                                     // 圈子详情
        
        JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
        vc.circleId = model.url;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (model.contentType.integerValue == 131){                                     // 专辑详情
        
        JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
        vc.subjectId = model.url;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// 获取更新了几条数据
- (NSInteger)getToastCount:(JANewVoiceModel *)model modelArray:(NSArray *)models
{
    __block NSInteger count = models.count;
    
    [models enumerateObjectsUsingBlock:^(JANewVoiceModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.storyId isEqualToString:model.storyId]) {
            
            count = idx;
        }
    }];
    
    return count;
}

// 首页刷新方式
- (void)sensorsAnalyticsWithMethod:(NSString *)mothod
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSInteger currentDisplayIndex = self.centerVc.contentView.contentViewCurrentIndex;
        JAChannelModel *currentModel =  self.channels[currentDisplayIndex];
        if ([currentModel.channelId isEqualToString:self.model.channelId]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[JA_Property_ScreenName] = [NSString stringWithFormat:@"首页-%@",self.model.title];
            params[JA_Property_ReloadMethod] = mothod;
            [JASensorsAnalyticsManager sensorsAnalytics_homeRefresh:params];
        }
    });
    
}

@end

