//
//  JANewSearchPersonViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANewSearchPersonViewController.h"
#import "JASearchPictureTextCell.h"
#import "JAPersonalCenterViewController.h"
#import "JAVoiceCommonApi.h"
#import "JAConsumerGroupModel.h"

@interface JANewSearchPersonViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation JANewSearchPersonViewController

- (void)loadView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // 设置指示器位置
    self.indicatorView.center = CGPointMake(JA_SCREEN_WIDTH * 0.5, 20);
    // 开启动画，必须调用，否则无法显示
    [self.indicatorView startAnimating];
    [self.view addSubview:self.indicatorView];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JASearchPictureTextCell class]) bundle:nil] forCellReuseIdentifier:@"searchU"];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        @StrongObj(self);
        [self getSearchPersonListWithLoadMore:YES];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getSearchPersonListWithLoadMore:NO];
    });
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JASearchPictureTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchU"];
    cell.keyWord = self.keyWord;
    cell.consumerModel = self.dataSourceArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAConsumer *model = self.dataSourceArray[indexPath.row];
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_Keyword] = self.keyWord;
    senDic[JA_Property_ResultCategory] = @"用户";
    senDic[JA_Property_PostId] = model.userId.length ? model.userId : model.consumerId;
    senDic[JA_Property_PostName] = model.name;
    [JASensorsAnalyticsManager sensorsAnalytics_clickSearchResult:senDic];
    
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    vc.personalModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 网络请求
- (void)getSearchPersonListWithLoadMore:(BOOL)isLoadMore
{
    
    if (self.isRequesting) {
        return;
    }
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    
    // 开始请求
    self.isRequesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"title"] = self.keyWord;
    dic[@"type"] = @"user";
    dic[@"systemType"] = @"2";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    
    [[JAVoiceCommonApi shareInstance] voice_searchWithParas:dic success:^(NSDictionary *result) {
        // 请求成功
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.indicatorView stopAnimating];
        
        if (!isLoadMore) {
            [self.dataSourceArray removeAllObjects];
        }
        // 解析数据
        JAConsumerGroupModel *groupModel = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"userPageList"]];
        if (groupModel.result.count) {
            [self.dataSourceArray addObjectsFromArray:groupModel.result];
        }
        
        if (!isLoadMore) {
            [self showBlankPage];
            
            // 神策数据
            NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
            senDic[JA_Property_Keyword] = self.keyWord;
            senDic[JA_Property_IsHistoryWordUsed] = @(self.clickHistory);
            senDic[JA_Property_HasResult] = groupModel.result.count ? @(YES) : @(NO);
            senDic[JA_Property_ResultCategory] = @"用户";
            [JASensorsAnalyticsManager sensorsAnalytics_requestSearch:senDic];
        }
        
        // 判断是否有下一页
        if (groupModel.nextPage != 0) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error){
        // 请求结束
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.indicatorView stopAnimating];
        
        if (!self.dataSourceArray.count) {
            
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}


// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"暂未找到相关搜索结果";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_searchnoresult" buttonTitle:nil selector:nil buttonShow:NO];
    }
}
@end
