//
//  JACheckExchangeDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckExchangeDetailViewController.h"
#import "JACheckExchangeCell.h"
#import "JAVoicePersonApi.h"
#import "JACheckExchangeGroupModel.h"
#import "JAWebViewController.h"

@interface JACheckExchangeDetailViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, strong) NSString *currentPage; // 当前页码
@end

@implementation JACheckExchangeDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = HEX_COLOR(JA_BtnGrounddColor);
    _dataSourceArray = [NSMutableArray array];
    [self setCenterTitle:@"茉莉花收入审核"];
    
//    [self setRightNavigationItemImage:[UIImage imageNamed:@"checkFlower_question"] highlightImage:[UIImage imageNamed:@"checkFlower_question"]];
    
    [self setupWithDetailUI];
    
    [self getWithCheckDetail:NO];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self getWithCheckDetail:YES];
    }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"茉莉花审核";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)actionRight
{
    JAWebViewController *vc = [[JAWebViewController alloc] init];
    vc.urlString = @"https://www.urmoli.com/newmoli/views/app/about/wx_cash_question.html";
    [self.navigationController pushViewController:vc animated:YES];
}

// 设置UI
- (void)setupWithDetailUI
{
    UIView *topView = [[UIView alloc] init];
    topView.backgroundColor = HEX_COLOR(0x6BD379);
    topView.width = JA_SCREEN_WIDTH;
    topView.height = 40;
    [self.view addSubview:topView];
    
    UILabel *label1 = [[UILabel alloc] init];
    label1.text = @"收入来源";
    label1.textColor = HEX_COLOR(0xffffff);
    label1.font = JA_MEDIUM_FONT(15);
    [label1 sizeToFit];
    label1.centerY = topView.height * 0.5;
    label1.x = 20;
    [topView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = @"奖励时间";
    label2.textColor = HEX_COLOR(0xffffff);
    label2.font = JA_MEDIUM_FONT(15);
    [label2 sizeToFit];
    label2.centerY = topView.height * 0.5;
    label2.centerX = topView.width * 0.5;
    [topView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] init];
    label3.text = @"审核状态";
    label3.textColor = HEX_COLOR(0xffffff);
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
    [tableView registerClass:[JACheckExchangeCell class] forCellReuseIdentifier:@"JACheckExchangeCellID"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
}

// 网络请求
- (void)getWithCheckDetail:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = @"1";
        self.tableView.mj_footer.hidden = YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"pageNum"] = self.currentPage;
    dic[@"pageSize"] = @"10";
    
    [[JAVoicePersonApi shareInstance] voice_checkFlowerWithPara:dic success:^(NSDictionary *result) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        // 解析数据
        JACheckExchangeGroupModel *groupM = [JACheckExchangeGroupModel mj_objectWithKeyValues:result[@"arraylist"]];
        [self.dataSourceArray addObjectsFromArray:groupM.result];
        
        // 判断是否需要加载更多
        if (groupM.nextPage != 0) {
            
            self.currentPage = [NSString stringWithFormat:@"%ld",groupM.currentPageNo + 1];
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
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (!isMore) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

#pragma tableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JACheckExchangeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JACheckExchangeCellID"];
    cell.model = self.dataSourceArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"您还没有茉莉花收入审核记录";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
}
@end
