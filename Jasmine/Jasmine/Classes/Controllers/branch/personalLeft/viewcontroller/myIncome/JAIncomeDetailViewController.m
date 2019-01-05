//
//  JAIncomeDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAIncomeDetailViewController.h"
#import "JAIncomeDetailCell.h"
#import "JAUserApiRequest.h"
#import "JAWithDrawFlowerGroupModel.h"
#import "JAWithDrawMoneyGroupModel.h"

@interface JAIncomeDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) NSString *currentPage; // 当前页码
@property (nonatomic, assign) BOOL requesting; // 正在请求

@property (nonatomic, strong) UILabel *footLabel; // 底部文字
@end

@implementation JAIncomeDetailViewController

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
    //    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    
    _dataSourceArray = [NSMutableArray array];
    
    [self.tableView registerClass:[JAIncomeDetailCell class] forCellReuseIdentifier:@"JAIncomeDetailCellID_incomeVC"];
    
    @WeakObj(self)
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
     @StrongObj(self)
        [self getIncomDetail:YES];
    }];
    
    [self getIncomDetail:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshDetail) name:@"refreshIncomeDetail" object:nil];
}

- (void)refreshDetail
{
    [self getIncomDetail:NO];
}

- (UILabel *)footLabel
{
    if (_footLabel == nil) {
     
        UILabel *footLabel = [[UILabel alloc] init];
        _footLabel = footLabel;
        footLabel.text = @"系统只保留最近3天的收支明细";
        [footLabel sizeToFit];
        footLabel.textAlignment = NSTextAlignmentCenter;
        footLabel.textColor = HEX_COLOR(0x9b9b9b);
        footLabel.font = JA_REGULAR_FONT(12);
        footLabel.height = 40;
    }
    return _footLabel;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (self.pageMenu.selectedItemIndex == 0 && [self.incomeType isEqualToString:@"flower"]) {
        params[JA_Property_ScreenName] = @"收支-茉莉花";
    } else if (self.pageMenu.selectedItemIndex == 1 && [self.incomeType isEqualToString:@"money"]) {
        params[JA_Property_ScreenName] = @"收支-零钱";
    }
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

// 获取收支明细数据
- (void)getIncomDetail:(BOOL)isMore
{
    if (self.requesting) {
        return;
    }
    
    if (!isMore) {
        self.currentPage = @"1";
        self.tableView.mj_footer.hidden = YES;
    }
    
    self.requesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = self.incomeType;
    dic[@"pageNum"] = self.currentPage;
    dic[@"pageSize"] = selectCount;
    
    [[JAUserApiRequest shareInstance] userWithDrawInfo:dic success:^(NSDictionary *result) {
       
        self.requesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
//        NSLog(@"%@",result);
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        // 解析数据
        if ([self.incomeType isEqualToString:@"flower"]) {
            JAWithDrawFlowerGroupModel *groupM = [JAWithDrawFlowerGroupModel mj_objectWithKeyValues:result[@"arraylist"]];
            [self.dataSourceArray addObjectsFromArray:groupM.result];
            if (groupM.nextPage != 0) {
                self.currentPage = [NSString stringWithFormat:@"%ld",groupM.currentPageNo + 1];
                self.tableView.mj_footer.hidden = NO;    // 有更多数据的时候，展示底部
            }else{
                self.tableView.mj_footer.hidden = YES; // 没有数据的时候 隐藏底部
                //            [self.tableView.mj_footer endRefreshingWithNoMoreData];  // 没有数据的时候 展示没有更多 - (记得第一次请求前要重置)
            }
            
            if (groupM.nextPage == 0) {
                self.tableView.tableFooterView = self.footLabel;
            }
        }else{
            JAWithDrawMoneyGroupModel *groupM = [JAWithDrawMoneyGroupModel mj_objectWithKeyValues:result[@"arraylist"]];
            [self.dataSourceArray addObjectsFromArray:groupM.result];
            if (groupM.nextPage != 0) {
                self.currentPage = [NSString stringWithFormat:@"%ld",groupM.currentPageNo + 1];
                self.tableView.mj_footer.hidden = NO;    // 有更多数据的时候，展示底部
            }else{
                self.tableView.mj_footer.hidden = YES; // 没有数据的时候 隐藏底部
                //            [self.tableView.mj_footer endRefreshingWithNoMoreData];  // 没有数据的时候 展示没有更多 - (记得第一次请求前要重置)
            }
            
            if (groupM.nextPage == 0) {
                self.tableView.tableFooterView = self.footLabel;
            }
        }
        
        if (!isMore) {
            [self showBlankPage];
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        self.requesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!isMore) {
            [self showBlankPageWithHeight:JA_SCREEN_HEIGHT - 235 - JA_StatusBarAndNavigationBarHeight title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO superView:self.view];
        }
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self getIncomDetail:NO];
}

#pragma mark - tableview
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
    JAIncomeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAIncomeDetailCellID_incomeVC"];
    
    if ([self.incomeType isEqualToString:@"flower"]) {
        
        cell.flowerModel = self.dataSourceArray[indexPath.row];
    }else{
        cell.moneyModel = self.dataSourceArray[indexPath.row];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [UIView new];
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = nil;
        NSString *image = nil;
        if ([self.incomeType isEqualToString:@"flower"]) {
            t = @"最近3天没有茉莉花收支记录";
            image = @"blank_molihua";
        } else {
            t = @"最近3天没有零钱收支记录";
            image = @"blank_nomoney";
        }
        [self showBlankPageWithHeight:JA_SCREEN_HEIGHT - 235 - JA_StatusBarAndNavigationBarHeight title:t subTitle:nil image:image buttonTitle:nil selector:nil buttonShow:NO superView:self.view];
    }
}
@end
