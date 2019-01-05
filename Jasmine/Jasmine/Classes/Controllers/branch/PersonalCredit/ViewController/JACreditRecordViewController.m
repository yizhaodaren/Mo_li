//
//  JACreditRecordViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACreditRecordViewController.h"
#import "JACreditRecordCell.h"
#import "JAUserApiRequest.h"
#import "JACreditRecordGroupModel.h"

@interface JACreditRecordViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, assign) NSInteger currentPage;
@end

@implementation JACreditRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    
    [self setCenterTitle:@"信用分变更记录"];
    
    [self setupCreditRecordUI];
    
    [self getRecordData:NO];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self getRecordData:YES];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"信用变更记录";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

// 获取网络数据
- (void)getRecordData:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"1";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    
    [[JAUserApiRequest shareInstance] userRecordList:dic success:^(NSDictionary *result) {
        
        // J结束刷新
        [self.tableView.mj_footer endRefreshing];
        
        // 处理之前的数据
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        // 解析数据
        JACreditRecordGroupModel *groupModel = [JACreditRecordGroupModel mj_objectWithKeyValues:result[@"listUserInegralRecord"]];
        [self.dataSourceArray addObjectsFromArray:groupModel.result];
        
        // 判断是否展示空白页
        [self showBlankPage];
        
        // 判断是否有下一页
        if (groupModel.nextPage != 0) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        if (!self.dataSourceArray.count) {
//            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self getRecordData:NO];
}

// 设置UI
- (void)setupCreditRecordUI
{
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.frame = self.view.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[JACreditRecordCell class] forCellReuseIdentifier:@"JACreditRecordCellID"];
    [self.view addSubview:tableView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JACreditRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JACreditRecordCellID"];
    cell.recordModel = self.dataSourceArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 计算高度
    JACreditRecordModel *model = self.dataSourceArray[indexPath.row];
    return model.cellHeight;
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"您还没有信用分变更记录";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
}
@end
