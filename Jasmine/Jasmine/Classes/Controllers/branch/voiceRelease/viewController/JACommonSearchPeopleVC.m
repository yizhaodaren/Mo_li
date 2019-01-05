//
//  JACommonSearchPeopleVC.m
//  Jasmine
//
//  Created by xujin on 26/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JACommonSearchPeopleVC.h"
#import "JACommonSearchPeopleCell.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceTopicGroupModel.h"
#import "JAVoicePersonApi.h"
#import "JAConsumerGroupModel.h"
#import "JASessionViewController.h"
#import "JASearchResultViewController.h"
#import "NIMKitInfoFetchOption.h"
#import "NIMKitUtil.h"
#import "JAPersonalCenterViewController.h"

static NSString *const kCommonSearchPeopleCellIdentifier = @"JACommonSearchPeopleCellIdentifier";

@interface JACommonSearchPeopleVC ()

@end

@interface JACommonSearchPeopleVC ()<
UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UISearchControllerDelegate,
UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *persons;
@property (nonatomic, strong) NSMutableArray *recentPersons;
@property (nonatomic, copy) NSString *keyWord;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) JASearchResultViewController *searchVC;

@end

@implementation JACommonSearchPeopleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   

    if (self.fromType == 0) {
        [self setCenterTitle:@"发私信"];
    } else if (self.fromType == 1) {
        [self setCenterTitle:@"@你关注的人"];
    }
    self.persons = [NSMutableArray new];
//    [self getRecentSessions];
    [self setupSearchController];
    [self setupTableView];
    [self getFollowsDataWithLoadMore:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchController.hidesNavigationBarDuringPresentation = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searchController.hidesNavigationBarDuringPresentation = NO;
}

- (void)getRecentSessions {
    self.recentPersons = [NSMutableArray new];
    NSArray *sessionArr = [NIMSDK sharedSDK].conversationManager.allRecentSessions;
    for (int i=0; i<MIN(sessionArr.count, 10); i++) {
        JAConsumer *consumer = [JAConsumer new];
        NIMRecentSession *recentSession = sessionArr[i];
        consumer.name = [NIMKitUtil showNick:recentSession.session.sessionId inSession:recentSession.session];
        NIMKitInfo *info = nil;
        if (recentSession.session.sessionType == NIMSessionTypeTeam) {
            info = [[NIMKit sharedKit] infoByTeam:recentSession.session.sessionId option:nil];
        } else {
            NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
            option.session = recentSession.session;
            info = [[NIMKit sharedKit] infoByUser:recentSession.session.sessionId option:option];
        }
        consumer.image = info.avatarUrlString;
        NSString *userId = [recentSession.session.sessionId substringFromIndex:4];
        consumer.userId = userId;
        
        NIMMessage *lastM = recentSession.lastMessage;
        // 获取最后一个对方的消息 - 判断是不是自己的消息
        NSString *fromId = [lastM.from substringFromIndex:4];
        // 获取自己的id
        NSString *myId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        
        NSString *otherOffic = nil;
        if ([myId isEqualToString:fromId]) {   // 该条消息是自己的
            // 获取对方的官方状态
            if (lastM.remoteExt) {
                NSDictionary *dic = lastM.remoteExt;
                otherOffic = dic[@"otherOffic"];
            }
        }else{
            if (lastM.remoteExt) {
                
                NSDictionary *dic = lastM.remoteExt;
                otherOffic = dic[@"myOffic"];
            }
            
        }
        consumer.achievementId = otherOffic;
        
        [self.recentPersons addObject:consumer];
    }
    [self.persons addObjectsFromArray:self.recentPersons];
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchController.searchBar.height, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-JA_StatusBarAndNavigationBarHeight-self.searchController.searchBar.height) style:UITableViewStylePlain];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // 如果进入预编辑状态,searchBar消失(UISearchController套到TabBarController可能会出现这个情况),请添加下边这句话
    self.definesPresentationContext = YES;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getFollowsDataWithLoadMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    self.tableView.scrollEnabled = NO;
}

- (void)setupSearchController {
    @WeakObj(self);
    self.searchVC = [[JASearchResultViewController alloc] init];
    self.searchVC.fromType = self.fromType;
    self.searchVC.selectBlock = ^(JAConsumer *consumer) {
        @StrongObj(self);
        if (self.selectBlock) {
            self.selectBlock(consumer);
            [self.navigationController popViewControllerAnimated:YES];
        }
    };
    self.searchVC.hideSearchBar = ^{
        @StrongObj(self);
        self.searchController.active = NO;
        [self resetSearchBar:self.searchController.searchBar];
    };
    //创建UISearchController
    self.searchController = [[UISearchController alloc]initWithSearchResultsController:self.searchVC];
    self.searchController.searchResultsUpdater = self.searchVC;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = NO; //搜索时，背景变暗色

    self.searchController.searchBar.delegate = self;
    self.searchController.searchBar.placeholder = @"搜索用户昵称";
    [self.searchController.searchBar sizeToFit];

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 55, JA_SCREEN_WIDTH, 1)];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.searchController.searchBar addSubview:lineView];
    
    self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:HEX_COLOR(0xF4F4F4) size:CGSizeMake(1,1)];
    [self.searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(JA_SCREEN_WIDTH-24,30)] forState:UIControlStateNormal];
    UIOffset offset = {10.0,0};
    self.searchController.searchBar.searchTextPositionAdjustment = offset;
    UIOffset offset1 = {5,0};
    [self.searchController.searchBar setPositionAdjustment:offset1 forSearchBarIcon:UISearchBarIconSearch];
    [self.searchController.searchBar setImage:[UIImage imageNamed:@"search_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    [self.searchController.searchBar setImage:[UIImage imageNamed:@"search_search"] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateHighlighted];
    UITextField *searchField = [self.searchController.searchBar valueForKey:@"searchField"];
    if (searchField) {
        searchField.font = JA_REGULAR_FONT(13);
        searchField.textColor = HEX_COLOR(JA_BlackSubTitle);
        searchField.layer.cornerRadius = 15.0f;
        searchField.layer.masksToBounds = YES;
    }
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;//关闭提示
    self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;//关闭自动首字母大写
    
    self.searchVC.nav = self.navigationController;
    self.searchVC.searchBar = self.searchController.searchBar;

    [self.view addSubview:self.searchController.searchBar];
}

#pragma mark - Network
- (void)getFollowsDataWithLoadMore:(BOOL)isLoadMore {
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"pageNum"] = @(self.currentPage);
    params[@"pageSize"] = @"10";
    // 关注
    params[@"type"] = @"0";
    params[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusAndFansParas:params success:^(NSDictionary *result) {
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        JAConsumerGroupModel *groupModel = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"friendList"]];
        for (JAConsumer *model in groupModel.result) {
            __block BOOL isRepeatData = NO;
            [self.recentPersons enumerateObjectsUsingBlock:^(JAConsumer *obj, NSUInteger idx, BOOL *stop) {
                if ([obj.userId isEqualToString:model.userId]) {
                    isRepeatData = YES;
                    *stop = YES;
                }
            }];
            if (!isRepeatData) {
                [self.persons addObject:model];
            }
        }
        
        if (groupModel.nextPage != 0) {
            self.currentPage = groupModel.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        [self.tableView reloadData];
        
        if (!self.persons.count) {
            [self showBlankPageWithLocationY:0 title:@"你还没有关注任何人" subTitle:@"" image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO];
            self.blankView.y = 56;
            self.tableView.scrollEnabled = NO;
        } else {
            [self removeBlankPage];
            self.tableView.scrollEnabled = YES;
        }
        
    } failure:^(NSError *error) {
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
    
        if (!self.persons.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self getFollowsDataWithLoadMore:NO];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.persons.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JACommonSearchPeopleCell *cell = [tableView dequeueReusableCellWithIdentifier:kCommonSearchPeopleCellIdentifier];
    if (!cell) {
        cell = [[JACommonSearchPeopleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCommonSearchPeopleCellIdentifier];
    }
    if (indexPath.row < self.persons.count) {
        JAConsumer *model = self.persons[indexPath.row];
        cell.data = model;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.persons.count) {
        JAConsumer *model = self.persons[indexPath.row];
        if (self.fromType == 0) {
            
            if ([model.userId isEqualToString:@"1000449"]) {
                
                JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
                JAConsumer *model = [[JAConsumer alloc] init];
                model.userId = @"1000449";
                model.name = @"茉莉君";
                model.image = @"http://file.xsawe.top//file/1515057390234cadbc939-94f5-4e51-87ae-ffb49eb116ac.png";
                vc.personalModel = model;
                [self.navigationController pushViewController:vc animated:YES];
                
                return;
            }
            
            NIMSession *session = [JAChatMessageManager yx_getChatSessionWithUserId:model.userId];
            [JAYXMessageManager app_getChatLimitsWithYXuserId:session.sessionId finish:^(JAChatLimitsType code) {
                JASessionViewController *vc = [[JASessionViewController alloc] initWithSession:session];
                vc.myOffic = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_AchievementId]];
                vc.otherOffic = model.achievementId;
                [self.navigationController pushViewController:vc animated:YES];
            }];
        } else if (self.fromType == 1) {
            if (self.selectBlock) {
                if (model.name.length && model.userId.length) {
                    self.selectBlock(model);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }
}


#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    for (id obj in [searchBar subviews]) {
        if ([obj isKindOfClass:[UIView class]]) {
            for (id obj2 in [obj subviews]) {
                if ([obj2 isKindOfClass:[UIButton class]]) {
                    UIButton *btn = (UIButton *)obj2;
                    btn.titleLabel.font = JA_REGULAR_FONT(16);
                    [btn setTitleColor:HEX_COLOR(0x5D5F6A) forState:UIControlStateNormal];
                    [btn setTitle:@"取消" forState:UIControlStateNormal];
                }
            }
        }
    }
    return YES;
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(JA_SCREEN_WIDTH,searchBar.height)];
    [self.searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xF6F6F6) size:CGSizeMake(JA_SCREEN_WIDTH-24,30)] forState:UIControlStateNormal];
    
    self.fd_interactivePopDisabled = YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self resetSearchBar:searchBar];
}

- (void)resetSearchBar:(UISearchBar *)searchBar {
    self.searchController.searchBar.backgroundImage = [UIImage imageWithColor:HEX_COLOR(0xf4f4f4) size:CGSizeMake(JA_SCREEN_WIDTH,searchBar.height)];
    [self.searchController.searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(JA_SCREEN_WIDTH-24,30)] forState:UIControlStateNormal];
    
    self.fd_interactivePopDisabled = NO;
}

@end

