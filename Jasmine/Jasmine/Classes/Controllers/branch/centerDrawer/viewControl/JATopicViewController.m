//
//  JATopicViewController.m
//  Jasmine
//
//  Created by xujin on 2018/5/3.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JATopicViewController.h"
#import "JACommonTopicCell.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceTopicGroupModel.h"
#import "JATopicApi.h"
#import "JAPersonTopicViewController.h"
#import "CYLTabBarController.h"

static NSString *const kVoiceTopicCellIdentifier = @"JAVoiceTopicCellIdentifier";

@interface JATopicViewController ()

@end

@interface JATopicViewController ()<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *topics;

@end

@implementation JATopicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setCenterTitle:@"热门话题"];

    self.topics = [NSMutableArray new];
    [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (!self.topics.count) {
        [self getTopicListWithLoadMore:NO];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.height = self.view.height;
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin, 0);
    [self.view addSubview:self.tableView];
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self getTopicListWithLoadMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getTopicListWithLoadMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
}

#pragma mark - Network
- (void)getTopicListWithLoadMore:(BOOL)isLoadMore {
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"type"] = @"1";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    if(IS_LOGIN) dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JATopicApi shareInstance] topic_recommendTopic:dic success:^(NSDictionary *result) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        // 解析数据
        JAVoiceTopicGroupModel *groupModel = [JAVoiceTopicGroupModel mj_objectWithKeyValues:result[@"topicList"]];
        if (!isLoadMore) {
            [self.topics removeAllObjects];
        }
        if (groupModel.result.count) {
            [self.topics addObjectsFromArray:groupModel.result];
            
            if (!isLoadMore) {
                NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData"];
                NSFileManager *filemanager = [NSFileManager new];
                if (![filemanager fileExistsAtPath:dictionaryPath]) {
                    [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
                NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData/hotTopic.data"];
                [NSKeyedArchiver archiveRootObject:groupModel toFile:filepath];
            }
        }
        if (groupModel.nextPage != 0 && groupModel.result.count) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
    } failure:^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self getTopicListWithLoadMore:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.topics.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JACommonTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kVoiceTopicCellIdentifier];
    if (!cell) {
        cell = [[JACommonTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVoiceTopicCellIdentifier type:1];
    }
    if (indexPath.row < self.topics.count) {
        JAVoiceTopicModel *model = self.topics[indexPath.row];
        cell.model = model;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.topics.count) {
        JAVoiceTopicModel *model = self.topics[indexPath.row];
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end


