//
//  JASearchResultViewController.m
//  Jasmine
//
//  Created by xujin on 27/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JASearchResultViewController.h"
#import "JAVoiceCommonApi.h"
#import "JAConsumerGroupModel.h"
#import "JACommonSearchPeopleCell.h"
#import "JASessionViewController.h"
#import "JAPersonalCenterViewController.h"
static NSString *const kCommonSearchPeopleCellIdentifier = @"JACommonSearchPeopleCellIdentifier";


@interface JASearchResultViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *searchList;//满足搜索条件的数组
@property (copy, nonatomic) NSString *searchText;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;

@end

@implementation JASearchResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor clearColor];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;//不加的话，UISearchBar返回后会上移
    
    self.searchList = [NSMutableArray new];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-JA_StatusBarHeight-56) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [[UIView alloc] init];
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getSearchPersonListWithLoadMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ja_hideSearchBar:)];
//    tapGesture.delegate = self;
//    [self.tableView addGestureRecognizer:tapGesture];
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(ja_hideSearchBar:)];
//    panGesture.delegate = self;
//    [self.tableView addGestureRecognizer:panGesture];
}

//- (void)ja_hideSearchBar:(UIGestureRecognizer *)recognizer {
//    if (self.hideSearchBar) {
//        self.hideSearchBar();
//    }
//}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.hideSearchBar) {
        self.hideSearchBar();
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.searchList.count) {
        return NO;
    }
    return YES;
}

#pragma mark - Network

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
    dic[@"title"] = self.searchText;
    dic[@"type"] = @"user";
    dic[@"systemType"] = @"2";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    
    [[JAVoiceCommonApi shareInstance] voice_searchWithParas:dic success:^(NSDictionary *result) {
        // 请求成功
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];

        if (!isLoadMore) {
            [self.searchList removeAllObjects];
        }
        // 解析数据
        JAConsumerGroupModel *groupModel = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"userPageList"]];
        if (groupModel.result.count) {
            [self.searchList addObjectsFromArray:groupModel.result];
        }

        if (!isLoadMore) {
            [self showBlankPage];
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
        //        [self.indicatorView stopAnimating];
        //
        //        if (!self.dataSourceArray.count) {
        //
        //            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        //        }
    }];
}

- (void)showBlankPage
{
    if (self.searchList.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"暂未找到相关搜索结果";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_searchnoresult" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

#pragma mark - tableView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.searchBar resignFirstResponder];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return self.searchList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JACommonSearchPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommonSearchPeopleCellIdentifier];
    if (!cell) {
        cell = [[JACommonSearchPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCommonSearchPeopleCellIdentifier];
    }
    if (indexPath.row < self.searchList.count) {
        JAConsumer *model = self.searchList[indexPath.row];
        cell.data = model;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.searchList.count) {
        JAConsumer *model = self.searchList[indexPath.row];
        
        if (self.fromType == 0) {
            if ([model.userId isEqualToString:@"1000449"]) {
                
                JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
                JAConsumer *model = [[JAConsumer alloc] init];
                model.userId = @"1000449";
                model.name = @"茉莉君";
                model.image = @"http://file.xsawe.top//file/1515057390234cadbc939-94f5-4e51-87ae-ffb49eb116ac.png";
                vc.personalModel = model;
                [self.nav pushViewController:vc animated:YES];
                
                return;
            }
            NIMSession *session = [JAChatMessageManager yx_getChatSessionWithUserId:model.userId];
            [JAYXMessageManager app_getChatLimitsWithYXuserId:session.sessionId finish:^(JAChatLimitsType code) {
                JASessionViewController *vc = [[JASessionViewController alloc] initWithSession:session];
                vc.myOffic = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_AchievementId]];
                vc.otherOffic = model.achievementId;
                [self.nav pushViewController:vc animated:YES];
            }];
        }else if (self.fromType == 1){
            
            if (self.selectBlock) {
                if (model.name.length && model.userId.length) {
                    self.selectBlock(model);
                }
            }
        }
    }
}

#pragma mark - UISearchResultsUpdating
//每输入一个字符都会执行一次
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    searchController.searchResultsController.view.hidden = NO;
    self.searchText = searchController.searchBar.text;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:nil];
    [self performSelector:@selector(myDelayedMethod) withObject:nil afterDelay:0.3];
    
    if (self.searchText.length) {
        self.tableView.userInteractionEnabled = YES;

        self.tableView.backgroundColor = [UIColor whiteColor];
    } else {
        self.tableView.userInteractionEnabled = NO;

        self.tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    }
}

// 延迟调用接口获取数据
- (void)myDelayedMethod {
    if (self.searchText.length) {
        [self getSearchPersonListWithLoadMore:NO];
    } else {
        self.tableView.mj_footer.hidden = YES;
        [self.searchList removeAllObjects];
        [self.tableView reloadData];
    }
}

@end

