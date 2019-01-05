//
//  JASearchTopicResultViewController.m
//  Jasmine
//
//  Created by xujin on 2018/5/3.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JASearchTopicResultViewController.h"
#import "JACommonTopicCell.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceTopicGroupModel.h"

static NSString *const kVoiceTopicCellIdentifier = @"JAVoiceTopicCellIdentifier";


@interface JASearchTopicResultViewController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>
@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *searchList;//满足搜索条件的数组
@property (copy, nonatomic) NSString *searchText;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;

@end

@implementation JASearchTopicResultViewController

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
        [self getSearchTopicListWithLoadMore:YES];
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
- (void)getSearchTopicListWithLoadMore:(BOOL)isLoadMore
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
    dic[@"type"] = @"topic";
    dic[@"systemType"] = @"2";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    
    [[JAVoiceCommonApi shareInstance] voice_searchWithParas:dic success:^(NSDictionary *result) {
        // 请求成功
        self.isRequesting = NO;
        [self.tableView.mj_footer endRefreshing];
        
        if (!isLoadMore) {
            [self.searchList removeAllObjects];
        }
        
        // 解析数据
        JAVoiceTopicGroupModel *groupModel = [JAVoiceTopicGroupModel mj_objectWithKeyValues:result[@"topicPageList"]];
        if (groupModel.result.count) {
            [self.searchList addObjectsFromArray:groupModel.result];
        }
        
        // 判断是否有下一页
        if (groupModel.nextPage != 0 && groupModel.result.count) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error){
        // 请求结束
        self.isRequesting = NO;
        [self.tableView.mj_footer endRefreshing];
    }];
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
    JACommonTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:kVoiceTopicCellIdentifier];
    if (!cell) {
        cell = [[JACommonTopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVoiceTopicCellIdentifier type:1];
    }
    if (indexPath.row < self.searchList.count) {
        JAVoiceTopicModel *model = self.searchList[indexPath.row];
        cell.model = model;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.searchList.count) {
        if (indexPath.row < self.searchList.count) {
            JAVoiceTopicModel *model = self.searchList[indexPath.row];
            if (self.selectedTopic && model.title.length) {
                self.selectedTopic(model);
                [self.navigationController popViewControllerAnimated:YES];
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
        
        if (!self.searchList.count) {
            self.tableView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];            
        }
    }
}

// 延迟调用接口获取数据
- (void)myDelayedMethod {
    if (self.searchText.length) {
        [self getSearchTopicListWithLoadMore:NO];
    } else {
        self.tableView.mj_footer.hidden = YES;
        [self.searchList removeAllObjects];
        [self.tableView reloadData];
    }
}

@end


