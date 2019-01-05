//
//  JABlackPersonViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABlackPersonViewController.h"
#import "JABlackPersonCell.h"
#import "JAConsumerGroupModel.h"
#import "JAPersonalCenterViewController.h"

#import "JAVoicePersonApi.h"

@interface JABlackPersonViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *currentPage;
@property (nonatomic, assign) BOOL requesting; // 正在请求
@end

@implementation JABlackPersonViewController
static NSString *blackCell = @"blackId";
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataArray = [NSMutableArray array];
    [self setupUI];
    
    [self setCenterTitle:@"黑名单管理"];
    [self getBlackPersonWithMore:NO];
}

- (void)setupUI
{
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.frame = self.view.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    // 注册
    [tableView registerClass:[JABlackPersonCell class] forCellReuseIdentifier:blackCell];
    [self.view addSubview:tableView];
    
    @WeakObj(self)
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
     @StrongObj(self)
        
        [self getBlackPersonWithMore:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"黑名单";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

#pragma mark - 网络请求
- (void)getBlackPersonWithMore:(BOOL)loadMore
{
    if (self.requesting) { // 正在请求
        return;
    }
    
    if (!loadMore) {   // 不是加载更多
        self.currentPage = @"1";
        self.tableView.mj_footer.hidden = YES; // 先隐藏底部
    }

    self.requesting = YES;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"pageNum"] = self.currentPage;
    params[@"pageSize"] = @"10";
    params[@"type"] = @"3";
    params[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusAndFansParas:params success:^(NSDictionary *result) {
        self.requesting = NO;
        [self.tableView.mj_footer endRefreshing];
        if (!loadMore) {   // 不是加载更多
            [self.dataArray removeAllObjects];
        }
        
        JAConsumerGroupModel *model = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"friendList"]];
        [self.dataArray addObjectsFromArray:model.result];
        if (model.nextPage != 0) {
            self.currentPage = [NSString stringWithFormat:@"%ld",model.currentPageNo + 1];
            self.tableView.mj_footer.hidden = NO;    // 有更多数据的时候，展示底部
        }else{
            self.tableView.mj_footer.hidden = YES; // 没有数据的时候 隐藏底部
            //            [self.tableView.mj_footer endRefreshingWithNoMoreData];  // 没有数据的时候 展示没有更多 - (记得第一次请求前要重置)
        }
        
        if (!loadMore) {
            
            [self showBlankPage];
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
//        [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        
        self.requesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!loadMore) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self getBlackPersonWithMore:NO];
}


// 移除黑名单
- (void)deleteBlackPerson:(JAConsumer *)model
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"concernId"] = model.userId;
    
    [[JAVoicePersonApi shareInstance] voice_personalDeleteBlackUserWithParas:dic success:^(NSDictionary *result) {
        [self.view ja_makeToast:@"移除成功"];
        [self.dataArray removeObject:model];
        [self.tableView reloadData];
    } failure:^(NSError *error) {
       [self.view ja_makeToast:@"移除失败"];
    }];
    
    
}

// 展示空白页
- (void)showBlankPage
{
    if (self.dataArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有拉黑任何人";
        NSString *st = @"";
        
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
    
}


#pragma mark - tableViewDelegate

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    JABlackPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:blackCell];
    
    cell.data = self.dataArray[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    JAConsumer *info = self.dataArray[indexPath.row];
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    vc.personalModel = info;
    [self.navigationController pushViewController:vc animated:YES];
}

// 编辑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAConsumer *model = self.dataArray[indexPath.row];
    
    [self deleteBlackPerson:model];
}
@end
