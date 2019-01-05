//
//  JACircleEssenceStoryListViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleEssenceStoryListViewController.h"
#import "JAStoryTableView.h"

#import "JACircleNetRequest.h"

@interface JACircleEssenceStoryListViewController ()
@property (nonatomic, strong) JAStoryTableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;  // 当前页码
@end

@implementation JACircleEssenceStoryListViewController

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
    
    @WeakObj(self);
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin + 50, 0);
    
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCircleEssenceVoiceWithMore:NO];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCircleEssenceVoiceWithMore:YES];
        
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getCircleEssenceVoiceWithMore:NO]; // 获取帖子信息
}

#pragma mark - 网络请求
- (void)listStory_refreshEssenceStory
{
    [self request_getCircleEssenceVoiceWithMore:NO];
}
- (void)request_getCircleEssenceVoiceWithMore:(BOOL)isMore
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
    dic[@"essence"] = @(1);
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

- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
        
    }else{
        NSString *t = @"还没有精华帖";
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
