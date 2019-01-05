//
//  JANewPersonCollectVoiceViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPersonCollectVoiceViewController.h"

#import "JAStoryTableView.h"

#import "JAPersonCenterNetRequest.h"

@interface JANewPersonCollectVoiceViewController ()
@property (nonatomic, weak) JAStoryTableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;  // 当前页码

@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
@end

@implementation JANewPersonCollectVoiceViewController

- (void)loadView{
    
    JAStoryTableView *tableView = [[JAStoryTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT) superVC:self sectionHeaderView:nil];
    _tableView = tableView;
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
  
    [self setupPersonCollectVoiceViewControllerUI];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCollectVoiceWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getCollectVoiceWithMore:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"个人主页-收藏";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

#pragma mark - 网络请求
- (void)request_getCollectVoiceWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
        self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    JAPersonCenterNetRequest *r = [[JAPersonCenterNetRequest alloc] initRequest_personCollectListWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        
        if (model.code != 10000) {
            if (!self.tableView.voices.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithLocationY:0 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            }
            return;
        }
        
        if (!isMore) {
            [self.tableView.voices removeAllObjects];
        }
        
        // 添加数据
        [self.tableView.voices addObjectsFromArray:model.resBody];
        
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
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        if (self.tableView.voices.count == 0) {
            [self showBlankPageWithLocationY:0 title:@"网络请求异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
    }];
}

#pragma mark - UI
- (void)setupPersonCollectVoiceViewControllerUI
{
    
}

// 展示空白页
- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有收藏";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_collect" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

@end
