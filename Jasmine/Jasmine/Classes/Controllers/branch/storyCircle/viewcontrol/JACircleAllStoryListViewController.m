//
//  JACircleAllStoryListViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleAllStoryListViewController.h"
#import "JAStoryTableView.h"
#import "JACircleNewPublishHeadView.h" // 头部
#import "JAPostDetailViewController.h"
#import "JACircleNetRequest.h"

@interface JACircleAllStoryListViewController ()<JACircleNewPublishHeadViewDelegate>
@property (nonatomic, strong) JAStoryTableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;  // 当前页码
@property (nonatomic, weak) JACircleNewPublishHeadView *headView;
@end

@implementation JACircleAllStoryListViewController

- (void)loadView
{
    self.tableView = [[JAStoryTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT) superVC:self sectionHeaderView:nil];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupCircleAllStoryListViewControllerUI];
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCircleVoiceWithMore:NO];
        [self request_getCircleTopVoice];  // 获取置顶帖
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCircleVoiceWithMore:YES];
        
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getCircleTopVoice];  // 获取置顶帖
    [self request_getCircleVoiceWithMore:NO]; // 获取帖子信息
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReleaseVoiceModel:) name:@"refreshVoiceModel" object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark - 网络请求
- (void)listStory_refreshAllStory
{
    [self request_getCircleVoiceWithMore:NO];
}
- (void)request_getCircleVoiceWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
        [self sensorsAnalyticsWithMethod:@"下拉刷新"];
    }else{
        [self sensorsAnalyticsWithMethod:@"上滑刷新"];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    dic[@"essence"] = @(0);
    dic[@"orderType"] = @(self.currentSortType);
    
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleVoiceListWithParameter:dic circleId:self.circleId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.code != 10000) {
            if (!self.tableView.voices.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithHeight:300 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
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
            [self showBlankPageWithHeight:300 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
        
    }];
}

- (void)request_getCircleTopVoice
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(1);
    dic[@"pageSize"] = @(10);
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleStickPostWithParameter:dic circleId:self.circleId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        if (responseModel.code != 10000) {
            return;
        }
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.resBody.count == 0) {
            return;
        }
        
        self.headView.topVoiceArray = model.resBody;
        self.headView.circleName = self.infoModel.circleName;
        self.headView.height = 40 * self.headView.topVoiceArray.count + 10;
        self.tableView.tableHeaderView = self.headView;
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

#pragma mark -
- (void)circleNewPublishHeadView_didSelectWithRow:(NSInteger)row headView:(JACircleNewPublishHeadView *)headView
{
    
    // 获取帖子跳转
    JANewVoiceModel *model = headView.topVoiceArray[row];
    JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
    vc.sourcePage = model.sourcePage;
    vc.sourcePageName = model.sourcePageName;
    vc.enterType = 1;
    vc.voiceId = model.storyId;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UI
- (void)setupCircleAllStoryListViewControllerUI
{
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin + 50, 0);
    
    // 设置头部
    JACircleNewPublishHeadView *headView = [[JACircleNewPublishHeadView alloc] init];
    _headView = headView;
    headView.width = JA_SCREEN_WIDTH;
    headView.height = 10;
    headView.delegate = self;
    self.tableView.tableHeaderView = headView;
}

- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
        
    }else{
        NSString *t = @"还没有相关帖子";
        NSString *st = @"";
        [self showBlankPageWithHeight:300 title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        
    }
}

- (void)sensorsAnalyticsWithMethod:(NSString *)mothod
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"圈子详情";
    params[JA_Property_ReloadMethod] = mothod;
    params[JA_Property_ContentName] = self.infoModel.circleName;
    [JASensorsAnalyticsManager sensorsAnalytics_homeRefresh:params];
}
@end
