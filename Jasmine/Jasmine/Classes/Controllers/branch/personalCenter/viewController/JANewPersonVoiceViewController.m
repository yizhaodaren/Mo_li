//
//  JANewPersonVoiceViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPersonVoiceViewController.h"
#import "JAVoiceRecordViewController.h"

#import "JAReleasePostManager.h"

#import "JAStoryTableView.h"

#import "JAPersonCenterNetRequest.h"

@interface JANewPersonVoiceViewController ()
@property (nonatomic, strong) JAStoryTableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;  // 当前页码
@end

@implementation JANewPersonVoiceViewController

- (void)loadView{
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
    
    [self setupPersonVoiceViewControllerUI];
    
    if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPersonalVoiceInfo:) name:@"refreshVoiceModel" object:nil];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adminDelVoice:) name:@"AdminDelVoice" object:nil];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getVoiceListWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getVoiceListWithMore:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"个人主页-主帖";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

#pragma mark - 发帖通知
- (void)refreshPersonalVoiceInfo:(NSNotification *)noti
{
    NSDictionary *dic = (NSDictionary *)noti.object;
    if (!dic) {
        return;
    }
    [self request_getVoiceListWithMore:NO];
}

- (void)adminDelVoice:(NSNotification *)noti
{
    NSDictionary *dic = noti.object;
    NSString *voiceId = dic[@"voiceId"];
    
    [self.tableView.voices enumerateObjectsUsingBlock:^(JAVoiceModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.voiceId isEqualToString:voiceId]) {
            [self.tableView.voices removeObject:model];
            *stop = YES;
        }
    }];
    
    [self.tableView reloadData];
}

#pragma mark - UI
- (void)setupPersonVoiceViewControllerUI
{
    if ([self checkMoliDianTai]) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44+JA_TabbarSafeBottomMargin, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}
#pragma mark - 网络请求
- (void)request_getVoiceListWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    JAPersonCenterNetRequest *r = [[JAPersonCenterNetRequest alloc] initRequest_personStoryListStoryListWithParameter:dic userId:self.userId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        
        if (model.code != 10000) {
            if (!self.tableView.voices.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                CGFloat height = self.enterType == 0 ? 400 : self.view.height;
                [self showBlankPageWithHeight:height title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
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
        [self.tableView.mj_footer endRefreshing];
        CGFloat height = self.enterType == 0 ? 400 : self.view.height;
        if (self.tableView.voices.count == 0) {
            [self showBlankPageWithHeight:height title:@"网络请求异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
    }];
}

// 展示空白页
- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
    }else{
        
        if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
            NSString *t = @"你还没有主帖，快去发帖吧！";
            NSString *st = @"";
            CGFloat height = self.enterType == 0 ? 400 : self.view.height;
            [self showBlankPageWithHeight:height title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            
        }else{
            NSString *t = self.sex == 2 ? @"她还没有主贴" : @"他还没有主帖";
            NSString *st = @"";
            CGFloat height = self.enterType == 0 ? 400 : self.view.height;
            [self showBlankPageWithHeight:height title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
    }
}

#pragma mark - 发帖
- (void)gotoPublish
{
    if ([JAReleasePostManager shareInstance].postDraftModel.uploadState == JAUploadUploadingState) {
        [self.view ja_makeToast:@"你有帖子正在上传中，请上传完毕后再发帖"];
        return;
    }
    JAVoiceRecordViewController *vc = [[JAVoiceRecordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)checkMoliDianTai
{
    if ([@"1275" isEqualToString:self.userId] || [@"1000449" isEqualToString:self.userId]) {
        return YES;
    }else{
        return NO;
    }
}
@end
