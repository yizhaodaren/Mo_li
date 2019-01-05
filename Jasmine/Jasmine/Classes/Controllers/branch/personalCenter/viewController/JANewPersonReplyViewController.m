//
//  JANewPersonReplyViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPersonReplyViewController.h"

#import "JAPersonalReplyCell.h"
#import "JAVoiceRecordViewController.h"
#import "JAPostDetailViewController.h"
#import "JAPersonalCenterViewController.h"

#import "JAPersonCenterNetRequest.h"
#import "JANewPlaySingleTool.h"
#import "JADataHelper.h"

@interface JANewPersonReplyViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation JANewPersonReplyViewController

- (void)loadView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"个人主页-回复";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    [self setupPersonReplyViewControllerUI];
    
    if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        // 监听发评论 + - (刷新列表来同步数据)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshPersonalCommentInfo:) name:@"personalCommentCountChange" object:nil];
    }
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCommentListWihMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getCommentListWihMore:NO];
}

#pragma mark - tableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (self.dataSourceArray.count == 0) {
        return;
    }
    
    // 获取数据
    JANewCommentModel *model = self.dataSourceArray[indexPath.section];
    if (model.storyMsg) {
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        vc.sourcePage = @"个人主页-回复";
        vc.voiceId = model.storyId;
        vc.jump_commentId = model.commentId;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"该帖已被删除"];
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataSourceArray.count == 0) {
        return 1;
    }
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSourceArray.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    
    JAPersonalReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAPersonalReplyCell_id"];
    @WeakObj(self);
    cell.jumpPersonalCenterBlock = ^(JAPersonalReplyCell *cell) {
        @StrongObj(self);
        if (cell.model.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return;
        }
        if ([self.userId isEqualToString:cell.model.user.userId]) {
            return;
        }
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.model.user.userId;
        model.name = cell.model.user.userName;
        model.image = cell.model.user.avatar;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.playCommentOrReplyBlock = ^(JAPersonalReplyCell *cell) {  // 播评论
        [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_playSingleMusicWithFileUrlString:cell.model.audioUrl model:cell.model playType:JANewPlaySingleToolType_comment];
    };
    
    cell.personalPointClickBlock = ^(JAPersonalReplyCell *cell) {
        @StrongObj(self);
        [JADetailClickManager detail_modalChooseWindowWithComment:cell.model standbyParameter:nil needBlock:^(NSInteger actionType) {
            if (actionType == 1) {   // 加神
                cell.model.sort = @"1";
            }else if (actionType == 2){   // 取消神回
                cell.model.sort = @"0";
            }else if (actionType == 3){  // 隐藏
                
            }else if (actionType == 5){  // 删除
                [[NSNotificationCenter defaultCenter] postNotificationName:@"owner_deleteComment" object:nil];
                [self.dataSourceArray removeObject:cell.model];
                [self.tableView reloadData];
            }
        }];
    };
    
    cell.commentAtPersonBlock = ^(NSString *userName, NSArray *atList) {
        @StrongObj(self);
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.model = self.dataSourceArray[indexPath.section];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataSourceArray.count == 0) {
        
        return 300;
    }
    JANewCommentModel *model = self.dataSourceArray[indexPath.section];
    return model.personCenterCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 1;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        UIView *lineV = [[UIView alloc] init];
        lineV.backgroundColor = HEX_COLOR(JA_Line);
        lineV.width = JA_SCREEN_WIDTH;
        lineV.height = 1;
        return lineV;
    }else{
        return [UIView new];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
 
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    return 0.01;
}

#pragma mark - UI
- (void)setupPersonReplyViewControllerUI
{
    [self.tableView registerClass:[JAPersonalReplyCell class] forCellReuseIdentifier:@"JAPersonalReplyCell_id"];
    if ([self checkMoliDianTai]) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 44+JA_TabbarSafeBottomMargin, 0);
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

#pragma mark - 用来做
- (void)refreshPersonalCommentInfo:(NSNotification *)noti
{
    // 刷新列表
    [self request_getCommentListWihMore:NO];
}

#pragma mark - 网络请求
- (void)request_getCommentListWihMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    JAPersonCenterNetRequest *r = [[JAPersonCenterNetRequest alloc] initRequest_personCommentListWithParameter:dic userId:self.userId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [self.tableView.mj_footer endRefreshing];
        JANewCommentGroupModel *groupM = (JANewCommentGroupModel *)responseModel;
        if (groupM.code != 10000) {
            if (self.dataSourceArray.count == 0) {
                [self.view ja_makeToast:groupM.message];
                [self showBlankPageWithHeight:400 title:@"服务器异常" subTitle:nil image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            }
            return;
        }
        NSArray *arr = groupM.resBody;
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        [self.dataSourceArray addObjectsFromArray:arr];
        
        // 展示空白页
        if (!isMore) {
            [self showBlankPage];
        }
        
        // 判断分页
        if (self.dataSourceArray.count >= groupM.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
            
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        if (!self.dataSourceArray.count) {
            [self showBlankPageWithHeight:400 title:@"网络请求失败" subTitle:nil image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
        
    }];
}

#pragma mark - 空白页面
// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        
        
        if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
            NSString *t = @"你还没有任何回复";
            NSString *st = @"";
            CGFloat height = self.enterType == 0 ? 400 : self.view.height;
            [self showBlankPageWithHeight:height title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            
        }else{
            NSString *t = self.sex == 2 ? @"她还没有任何回复" : @"他还没有任何回复";
            NSString *st = @"";
            CGFloat height = self.enterType == 0 ? 400 : self.view.height;
            [self showBlankPageWithHeight:height title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)checkMoliDianTai
{
    if ([@"1275" isEqualToString:self.userId] || [@"1000449" isEqualToString:self.userId]) {
        return YES;
    }else{
        return NO;
    }
}
@end
