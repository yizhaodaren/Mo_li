//
//  JAActivityCenterViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAActivityCenterViewController.h"
#import "JAActivityCenterCell.h"
#import "JAVoicePersonApi.h"
#import "JAActivityModel.h"
#import "JAWebViewController.h"
#import "JAActivityGroupModel.h"

@interface JAActivityCenterViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;

@end

@implementation JAActivityCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = HEX_COLOR(JA_Line);
    
    // 活动页面置为已读
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeActivity];
    
    _dataSourceArray = [NSMutableArray array];
    
    NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/VoiceData/activity.data"]];
    JAActivityGroupModel *model = nil;
    @try {
        model = [NSKeyedUnarchiver unarchiveObjectWithFile:filepath];
    } @catch (NSException *exception) {
        model = nil;
    }
    if (model.result.count) {
//        [_dataSourceArray addObjectsFromArray:model.result];
    }
    
    [self setCenterTitle:@"活动中心"];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.frame = self.view.bounds;
    tableView.height = self.view.height - 64;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JAActivityCenterCell class] forCellReuseIdentifier:@"activityCenterCell"];
    [self.view addSubview:tableView];
    
    [self getActivityData:NO];
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self getActivityData:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self getActivityData:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"活动";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

#pragma mark - 网络请求
- (void)getActivityData:(BOOL)isMore
{
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        
        // 展示空界面
        [self showBlankPage];
        
        return;
    }
    
    if (self.isRequesting) {
        return;
    }
    
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    
    // 开始请求
    self.isRequesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage); // 获取全部活动
    dic[@"pageSize"] = @"10"; // 获取全部活动
    
    [[JAVoicePersonApi shareInstance] voice_activityWithPara:dic success:^(NSDictionary *result) {
//        NSLog(@"%@",result);
        // 结束请求
        self.isRequesting = NO;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        // 之前的数据处理
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        JAActivityGroupModel *groupM = [JAActivityGroupModel mj_objectWithKeyValues:result[@"activityList"]];
        [self.dataSourceArray addObjectsFromArray:groupM.result];
        
        if (groupM.nextPage != 0) {
            self.currentPage = groupM.currentPageNo + 1;
            self.tableView.mj_footer.hidden = NO;
        }else{
            self.tableView.mj_footer.hidden = YES;
        }
        
        [self.tableView reloadData];
        
        if (!isMore && groupM.result.count) {
            NSString *dictionaryPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Caches/VoiceData"];
            NSFileManager *filemanager = [NSFileManager new];
            if (![filemanager fileExistsAtPath:dictionaryPath]) {
                [filemanager createDirectoryAtPath:dictionaryPath withIntermediateDirectories:YES attributes:nil error:NULL];
            }
            NSString *filepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"Library/Caches/VoiceData/activity.data"]];
            [NSKeyedArchiver archiveRootObject:groupM toFile:filepath];
        }
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
        self.isRequesting = NO;
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        if (!self.dataSourceArray.count) {
            
//            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self.tableView.mj_header beginRefreshing];
}

#pragma mark - 数据源代理
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取模型
    JAActivityModel *model = _dataSourceArray[indexPath.row];
    // 分类型跳转
    JAWebViewController *vc = [[JAWebViewController alloc] init];
    
//    vc.urlString = @"http://activity.yourmoli.com/views/app/activity/activity_test.html"; // 测试跳转
//    vc.urlString = @"http://index.yourmoli.com/newmoli/views/app/activity/share-test.html"; // 测试h5分享图片 url
//    vc.urlString = @"http://index.yourmoli.com/newmoli/views/app/activity/share-base64-test.html";  // 测试h5分享图片 base64
//     vc.urlString = @"http://activity.yourmoli.com/views/app/activity/activity_test.html"; // 测试到主页和录制
    
    NSString *str = model.url;
    if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
        vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    }else{
        vc.urlString = str;
    }
    vc.enterType = @"活动中心";
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAActivityCenterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"activityCenterCell"];
    cell.model = _dataSourceArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return WIDTH_ADAPTER(180);
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"活动即将上线，敬请期待";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
    }
}
@end
