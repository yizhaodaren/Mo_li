//
//  JANewSearchAllViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANewSearchAllViewController.h"
#import "JAVoiceCommonApi.h"

#import "JAConsumerGroupModel.h"
#import "JAVoiceTopicGroupModel.h"
#import "JASearchPosGrouptModel.h"


#import "JASearchPostsCell.h"
#import "JASearchPictureTextCell.h"
#import "JACommonTopicCell.h"

#import "JAPaddingLabel.h"

#import "JAPostDetailViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JAPersonTopicViewController.h"

#import "NSDictionary+NTESJson.h"

@interface JANewSearchAllViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;

@property (nonatomic, strong) NSMutableArray *allDatasource;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;    // 帖子的数据源
@property (nonatomic, strong) NSMutableDictionary *voiceDictionary; // 装帖子的字典

@property (nonatomic, strong) NSMutableArray *userDataSourceArray; // 人的数据源
@property (nonatomic, strong) NSMutableArray *topicDataSourceArray; // 话题的数据源

@property (nonatomic, assign) NSInteger searchStatus;  // 0 是没有人的数据 1 是两者都有

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, strong) NSArray *storyKeyWordArray;  // 帖子的关键字
@property (nonatomic, strong) NSString *userKeyWord;       // 人的关键字
@property (nonatomic, strong) NSArray *topicKeyWord;       // 话题的关键字

@end

@implementation JANewSearchAllViewController

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
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchStatus = -1;
    _dataSourceArray = [NSMutableArray array];
    _userDataSourceArray = [NSMutableArray array];
    _allDatasource = [NSMutableArray array];
    _topicDataSourceArray = [NSMutableArray array];
    
    _voiceDictionary = [NSMutableDictionary dictionary];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    // 设置指示器位置
    self.indicatorView.center = CGPointMake(JA_SCREEN_WIDTH * 0.5, 20);
    // 开启动画，必须调用，否则无法显示
    [self.indicatorView startAnimating];
    [self.view addSubview:self.indicatorView];
    
    [self.tableView registerClass:[JASearchPostsCell class] forCellReuseIdentifier:@"searchP"];
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JASearchPictureTextCell class]) bundle:nil] forCellReuseIdentifier:@"searchU"];
    [self.tableView registerClass:[JACommonTopicCell class] forCellReuseIdentifier:@"searchT"];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        @StrongObj(self);
        [self getSearchAllListWithLoadMore:YES];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self getSearchAllListWithLoadMore:NO];
    });
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.allDatasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = self.allDatasource[section];
    NSArray *array = dic[@"sectionArray"];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    NSDictionary *dic = self.allDatasource[indexPath.section];
    NSString *name = dic[@"sectionName"];
    NSArray *array = dic[@"sectionArray"];
    id keyWord = dic[@"sectionKey"];
    
    if ([name isEqualToString:@"用户"]) {
        JASearchPictureTextCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchU"];
        cell.keyWord = keyWord;
        cell.consumerModel = array[indexPath.row];
        return cell;
    }else if ([name isEqualToString:@"话题"]){
        JACommonTopicCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchT"];
        cell.keyWordArr = keyWord;
        cell.model = array[indexPath.row];
        return cell;
    }else{   // ([name isEqualToString:@"帖子"])
        JASearchPostsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"searchP"];
        
        cell.keyWordArr = keyWord;
        cell.model = array[indexPath.row];
        return cell;
    }
  
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    NSDictionary *dic = self.allDatasource[indexPath.section];
    NSString *name = dic[@"sectionName"];
    if ([name isEqualToString:@"用户"]) {
        return 80;
    }else if ([name isEqualToString:@"话题"]){
        return 70;
    }else{  // ([name isEqualToString:@"帖子"])
        return 90;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    // 获取数据
    NSDictionary *dic = self.allDatasource[section];
    NSArray *array = dic[@"sectionArray"];
    if (array.count) {
        return 30;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    // 获取数据
    NSDictionary *dic = self.allDatasource[section];
    NSString *name = dic[@"sectionName"];
    
    UIView *v = [[UIView alloc] init];
    v.height = 30;
    v.width = JA_SCREEN_WIDTH;
    v.backgroundColor = HEX_COLOR(0xF4F4F4);
    UILabel *label = [[UILabel alloc] init];
    label.width = 35;
    label.height = 20;
    label.x = 15;
    label.centerY = v.height * 0.5;
    label.textAlignment = NSTextAlignmentCenter;

    label.text = name;
    label.textColor = HEX_COLOR(JA_BlackSubTitle);
    label.font = JA_REGULAR_FONT(12);
    [v addSubview:label];
    v.clipsToBounds = YES;
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    // 获取数据
    NSDictionary *dic = self.allDatasource[section];
    NSString *name = dic[@"sectionName"];
    
    if (!self.allDatasource.count) {
        return 0.01;
    }else{
        if (![name isEqualToString:@"帖子"]) {
            return 40;
        }else{
            return 0.01;
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    // 获取数据
    NSDictionary *dic = self.allDatasource[section];
    NSString *name = dic[@"sectionName"];
    
    if (!self.allDatasource.count) {
        return [UIView new];
    }else{
        
        if (![name isEqualToString:@"帖子"]) {
            UIView *v = [[UIView alloc] init];
            v.height = 40;
            v.width = JA_SCREEN_WIDTH;
            UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
            imageV.x = JA_SCREEN_WIDTH - 15 - imageV.width;
            imageV.centerY = v.height * 0.5;
            [v addSubview:imageV];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = [name isEqualToString:@"用户"] ? 0 : 1;
            [btn setImage:[UIImage imageNamed:@"search_search"] forState:UIControlStateNormal];
            [btn setTitle:@"查找更多搜索结果" forState:UIControlStateNormal];
            [btn setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
            btn.titleLabel.font = JA_REGULAR_FONT(12);
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.titleEdgeInsets = UIEdgeInsetsMake(0, 20, 0, -20);
            btn.width = JA_SCREEN_WIDTH - 24;
            btn.height = v.height;
            btn.x = 24;
            btn.centerY = v.height * 0.5;
            [btn addTarget:self action:@selector(seeMorePerson:) forControlEvents:UIControlEventTouchUpInside];
            [v addSubview:btn];
            
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = HEX_COLOR(JA_Line);
            line.width = JA_SCREEN_WIDTH;
            line.height = 1;
            line.y = v.height - 1;
            [v addSubview:line];
            return v;
        }else{
            return [UIView new];
        }
    }
}

- (void)seeMorePerson:(UIButton *)btn
{
    if (btn.tag == 0) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollPerson" object:nil];
    }else if (btn.tag == 1){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"scrollTopic" object:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    NSDictionary *dic = self.allDatasource[indexPath.section];
    NSString *name = dic[@"sectionName"];
    
    if ([name isEqualToString:@"帖子"]) {
        // 获取数据
        JANewVoiceModel *model = self.dataSourceArray[indexPath.row];
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_Keyword] = self.keyWord;
        senDic[JA_Property_ResultCategory] = @"综合";
        senDic[JA_Property_PostId] = model.user.userId;
        senDic[JA_Property_PostName] = model.user.userName;
        senDic[JA_Property_ContentId] = model.searchStoryId;
        senDic[JA_Property_ContentTitle] = model.content;
        [JASensorsAnalyticsManager sensorsAnalytics_clickSearchResult:senDic];
        
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        vc.voiceId = model.searchStoryId;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([name isEqualToString:@"用户"]){
        JAConsumer *model = self.userDataSourceArray[indexPath.row];
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_Keyword] = self.keyWord;
        senDic[JA_Property_ResultCategory] = @"综合";
        senDic[JA_Property_PostId] = model.userId.length ? model.userId : model.consumerId;
        senDic[JA_Property_PostName] = model.name;
        [JASensorsAnalyticsManager sensorsAnalytics_clickSearchResult:senDic];
        
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }else if ([name isEqualToString:@"话题"]){
        JAVoiceTopicModel *model = self.topicDataSourceArray[indexPath.row];
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        
        senDic[JA_Property_Keyword] = self.keyWord;
        senDic[JA_Property_ResultCategory] = @"综合";
        senDic[JA_Property_TopicId] = model.topicId;
        senDic[JA_Property_topicname] = model.title;

        [JASensorsAnalyticsManager sensorsAnalytics_clickSearchResult:senDic];
        
        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
        vc.topicTitle = model.title;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

#pragma mark - 网络请求
- (void)getSearchAllListWithLoadMore:(BOOL)isLoadMore
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
    dic[@"title"] = self.keyWord;
    dic[@"type"] = @"merge";
    dic[@"systemType"] = @"2";
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"10";
    
    [[JAVoiceCommonApi shareInstance] voice_searchWithParas:dic success:^(NSDictionary *result) {

        // 请求成功
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        [self.indicatorView stopAnimating];
        
        if (!isLoadMore) {
           
            // 2.5.4 新逻辑
            // 移除老的数据
            [self.allDatasource removeAllObjects];
            [self.dataSourceArray removeAllObjects];
            [self.topicDataSourceArray removeAllObjects];
            [self.userDataSourceArray removeAllObjects];
            
            // 解析人的数据
            JAConsumerGroupModel *groupModel = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"userPageList"]];
            if (groupModel.result.count) {
                [self.userDataSourceArray addObjectsFromArray:groupModel.result];
//                self.userKeyWord = result[@"userPageList"][@"map"][@"wordArray"];
                self.userKeyWord = [[[result dictForKey:@"userPageList"] dictForKey:@"map"] stringForKey:@"wordArray"];
                NSMutableDictionary *userDic = [NSMutableDictionary dictionary];
                userDic[@"sectionName"] = @"用户";
                userDic[@"sectionArray"] = self.userDataSourceArray;
                userDic[@"sectionKey"] = self.userKeyWord;
                [self.allDatasource addObject:userDic];
            }
            
            // 解析话题的数据  
            JAVoiceTopicGroupModel *topicGroupModel = [JAVoiceTopicGroupModel mj_objectWithKeyValues:result[@"topicPageList"]];
            if (topicGroupModel.result.count) {
                [self.topicDataSourceArray addObjectsFromArray:topicGroupModel.result];
//                self.topicKeyWord = result[@"topicPageList"][@"map"][@"wordArray"];
                self.topicKeyWord = [[[result dictForKey:@"topicPageList"] dictForKey:@"map"] arrayForKey:@"wordArray"];
                NSMutableDictionary *topicDic = [NSMutableDictionary dictionary];
                topicDic[@"sectionName"] = @"话题";
                topicDic[@"sectionArray"] = self.topicDataSourceArray;
                topicDic[@"sectionKey"] = self.topicKeyWord;
                [self.allDatasource addObject:topicDic];
            }
        }
        // 解析数据
        JASearchPosGrouptModel *groupModel = [JASearchPosGrouptModel mj_objectWithKeyValues:result[@"storyPageList"]];
        if (groupModel.result.count) {
            [self.dataSourceArray addObjectsFromArray:groupModel.result];
//            self.storyKeyWordArray = result[@"storyPageList"][@"map"][@"wordArray"];
            self.storyKeyWordArray = [[[result dictForKey:@"storyPageList"] dictForKey:@"map"] arrayForKey:@"wordArray"];
            
            self.voiceDictionary[@"sectionName"] = @"帖子";
            self.voiceDictionary[@"sectionArray"] = self.dataSourceArray;
            self.voiceDictionary[@"sectionKey"] = self.storyKeyWordArray;
            if ([self.allDatasource containsObject:self.voiceDictionary]) {
                [self.allDatasource removeObject:self.voiceDictionary];
            }
            [self.allDatasource addObject:self.voiceDictionary];
        }
        
        
        if (!isLoadMore) {
            [self showBlankPage];
            
            // 神策数据
            NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
            senDic[JA_Property_Keyword] = self.keyWord;
            senDic[JA_Property_IsHistoryWordUsed] = @(self.clickHistory);
            senDic[JA_Property_HasResult] = groupModel.result.count ? @(YES) : @(NO);
            senDic[JA_Property_ResultCategory] = @"综合";
            [JASensorsAnalyticsManager sensorsAnalytics_requestSearch:senDic];
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
        [self.indicatorView stopAnimating];
       
        if (!self.dataSourceArray.count) {
            
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}


// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count || self.userDataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"暂未找到相关搜索结果";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_searchnoresult" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

@end
