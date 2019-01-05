//
//  JAWithDrawRecordViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawRecordViewController.h"
#import "JAWithDrawRecordCell.h"
#import "JAUserApiRequest.h"
#import "JAWithDrawRecordGroupModel.h"

@interface JAWithDrawRecordViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) NSString *currentPage; // 当前页码
@property (nonatomic, assign) BOOL requesting; // 正在请求

@end

@implementation JAWithDrawRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = HEX_COLOR(JA_BtnGrounddColor);
    _dataSourceArray = [NSMutableArray array];
    [self setCenterTitle:@"提现记录"];
    
    [self setupWithDrawRecordUI];
    
    [self getWithDrawRecord:NO];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self getWithDrawRecord:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"提现记录";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)setupWithDrawRecordUI
{
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = [UIColor clearColor];
    topView.width = JA_SCREEN_WIDTH;
    topView.height = 40;
    [self.view addSubview:topView];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"提现金额";
    label1.textColor = HEX_COLOR(JA_ListTitle);
    label1.font = JA_MEDIUM_FONT(15);
    [label1 sizeToFit];
    label1.centerY = topView.height * 0.5;
    label1.x = 20;
    [topView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"提现时间";
    label2.textColor = HEX_COLOR(JA_ListTitle);
    label2.font = JA_MEDIUM_FONT(15);
    [label2 sizeToFit];
    label2.centerY = topView.height * 0.5;
    label2.centerX = topView.width * 0.5;
    [topView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"提现状态";
    label3.textColor = HEX_COLOR(JA_ListTitle);
    label3.font = JA_MEDIUM_FONT(15);
    [label3 sizeToFit];
    label3.centerY = topView.height * 0.5;
    label3.x = JA_SCREEN_WIDTH - 20 - label3.width;
    [topView addSubview:label3];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.width = JA_SCREEN_WIDTH;
    tableView.height = self.view.height - 40 - 64;
    tableView.y = 40;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JAWithDrawRecordCell class] forCellReuseIdentifier:@"withDrawRecordCellID"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}


// 获取提现记录
- (void)getWithDrawRecord:(BOOL)isMore
{
    if (self.requesting) {
        return;
    }
    
    if (!isMore) {
        self.currentPage = @"1";
        self.tableView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"pageNum"] = self.currentPage;
    dic[@"pageSize"] = @"30";
    
    self.requesting = YES;
    
    [[JAUserApiRequest shareInstance] userWithDrawRecord:dic success:^(NSDictionary *result) {
       
//        NSLog(@"%@",result);
        self.requesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        // 解析数据
        JAWithDrawRecordGroupModel *groupM = [JAWithDrawRecordGroupModel mj_objectWithKeyValues:result[@"arraylist"]];
        [self.dataSourceArray addObjectsFromArray:groupM.result];
        
        // 判断是否需要加载更多
        if (groupM.nextPage != 0) {
            
            self.currentPage = [NSString stringWithFormat:@"%zd",groupM.currentPageNo + 1];
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        
        // 如果不是加载更多需要展示空白页面
        if (!isMore) {
            [self showBlankPage];
        }
       
        [self.tableView reloadData];
        
        
    } failure:^(NSError *error) {
        
        self.requesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!isMore) {
//            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}
- (void)retryAction {
    [self removeBlankPage];
    [self getWithDrawRecord:NO];
}

#pragma tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAWithDrawRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"withDrawRecordCellID"];
    cell.model = self.dataSourceArray[indexPath.row];
    return cell;
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"最近1个月内没有提现记录";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_nomoney" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
}
@end
