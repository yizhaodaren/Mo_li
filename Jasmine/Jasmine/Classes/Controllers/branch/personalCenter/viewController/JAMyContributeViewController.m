//
//  JAMyContributeViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/4/10.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMyContributeViewController.h"
#import "JAContributeCell.h"
#import "JAPersonCenterNetRequest.h"
#import "JAStoryPlayViewController.h"
#import "JANewPlayTool.h"

@interface JAMyContributeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@property (nonatomic, assign) NSInteger currentPage; // 当前页码
@end

@implementation JAMyContributeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMyContributeViewUI];
    
    _dataSourceArray = [NSMutableArray array];
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getContributeListWithMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getContributeListWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self request_getContributeListWithMore:NO];
}

- (void)setupMyContributeViewUI
{
    [self setCenterTitle:@"我的投稿"];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.backgroundColor = HEX_COLOR(0xf9f9f9);
    tableView.frame = self.view.bounds;
    tableView.height = self.view.height - JA_StatusBarAndNavigationBarHeight;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JAContributeCell class] forCellReuseIdentifier:@"ContributeCell"];
    [self.view addSubview:tableView];
 
}

- (void)request_getContributeListWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    JAPersonCenterNetRequest *r = [[JAPersonCenterNetRequest alloc] initRequest_personContributeListWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.code != 10000) {
            if (!self.dataSourceArray.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithLocationY:0 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            }
            return;
        }
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        // 添加数据
        [self.dataSourceArray addObjectsFromArray:model.resBody];
        
        if (!isMore) {
            [self showBlankPage];  // 空数据
        }
        
        if (self.dataSourceArray.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        if (!self.dataSourceArray.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAContributeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContributeCell"];
    cell.storyModel = _dataSourceArray[indexPath.row];
    
    @WeakObj(self);
    cell.playVoiceBlock = ^(JAContributeCell *cell) {
        @StrongObj(self);
        
        NSInteger type = 1;
        [[JANewPlayTool shareNewPlayTool] playTool_playWithModel:cell.storyModel storyList:self.dataSourceArray enterType:type albumParameter:nil];
    };
   
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JANewVoiceModel *model = self.dataSourceArray[indexPath.row];
    return model.contrbuteHeight;
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有投稿，快去投稿吧！";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_nodraft" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

@end
