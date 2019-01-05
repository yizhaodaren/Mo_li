//
//  JAStoryAlbumViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAStoryAlbumViewController.h"
#import "JAStoryAlbumCell.h"

#import "JAAlbumDetailViewController.h"
#import "JAAlbumNetRequest.h"

#import "JAAlbumGroupModel.h"

@interface JAStoryAlbumViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) NSInteger currentPage;  // 当前页码
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@end

@implementation JAStoryAlbumViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = [NSMutableArray array];
    
    [self setCenterTitle:@"故事专辑"];
    [self setupStoryAlbumViewControllerUI];
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_albumLisetWithMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_albumLisetWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_header beginRefreshing];
}

- (void)setupStoryAlbumViewControllerUI
{
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[JAStoryAlbumCell class] forCellReuseIdentifier:@"JAStoryAlbumCellId"];
    [self.view addSubview:tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin, 0);
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorStoryAlbumViewControllerFrame];
}

- (void)calculatorStoryAlbumViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
}

#pragma mark - 网络请求
- (void)request_albumLisetWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    JAAlbumNetRequest *r = [[JAAlbumNetRequest alloc] initRequest_albumListWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        JAAlbumGroupModel *model = (JAAlbumGroupModel *)responseModel;
        if (model.code != 10000) {
            if (!self.dataSourceArray.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
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
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (!self.dataSourceArray.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JAAlbumModel *model = self.dataSourceArray[indexPath.row];
    JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
    vc.subjectId = model.subjectId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAAlbumModel *model = self.dataSourceArray[indexPath.row];
    JAStoryAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAStoryAlbumCellId"];
    cell.albumModel = model;
    return cell;
}

// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"还没有相关专辑";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_searchnoresult" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

@end
