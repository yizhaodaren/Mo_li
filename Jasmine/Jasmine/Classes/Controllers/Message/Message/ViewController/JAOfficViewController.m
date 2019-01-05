//
//  JAOfficViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAOfficViewController.h"
#import "JAOfficCell.h"
#import "JAOfficModel.h"
#import "JAOfficModelGroup.h"
#import "JAVoiceCommonApi.h"

#import "JAWebViewController.h"
#import "JAPostDetailViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JAPersonalTaskViewController.h"
#import "JAPacketViewController.h"
#import "JAHelperViewController.h"
#import "JAPersonTopicViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JACircleDetailViewController.h"
#import "JAAlbumDetailViewController.h"

@interface JAOfficViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *officArrM;

@property (nonatomic, strong) NSString *currentPage; // 当前页码

@property (nonatomic, assign) CGSize frontSize;
@end

@implementation JAOfficViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _officArrM = [NSMutableArray array];
    

    [self setup];

    self.currentPage = @"1";
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self creatData:self.currentPage];
    }];
    
//    [self.tableView.mj_header beginRefreshing];
    [self creatData:self.currentPage];
}


- (void)creatData:(NSString *)loadNum
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = loadNum;
    dic[@"pageSize"] = @"10";
    if (IS_LOGIN) dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoiceCommonApi shareInstance] voice_getOffic:dic success:^(NSDictionary *result) {
       
        // 结束请求
        [self.tableView.mj_header endRefreshing];
        
        if (loadNum.integerValue == 1) {
            [self.officArrM removeAllObjects];
        }
        
        JAOfficModelGroup *model = [JAOfficModelGroup mj_objectWithKeyValues:result[@"moliMsgList"]];
        
        
        NSMutableArray *arr = [NSMutableArray arrayWithArray:model.result];
        
        NSRange range = NSMakeRange(0, [arr count]);
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.officArrM insertObjects:arr atIndexes:indexSet];
        if ([model.nextPage integerValue] != 0) {
            self.tableView.mj_header.hidden = NO;
            self.currentPage = [NSString stringWithFormat:@"%ld",[model.currentPageNo integerValue] + 1];
        }else{
            self.tableView.mj_header.hidden = YES;
        }
        
        if (loadNum.integerValue == 1) {
            [self showBlankPage];
            
            // 拉取完数据之后就重置红点
            [JARedPointManager resetNewRedPointArrive:JARedPointTypeAnnouncement];
        }
        
        CGSize oldSize = self.tableView.contentSize;
        CGPoint oldOffset = self.tableView.contentOffset;
        
        [self.tableView reloadData];
        
        CGSize newSize = self.tableView.contentSize;
        
        if (oldSize.height == 0) {
            CGFloat offH = newSize.height - self.view.height > 0 ? newSize.height - self.view.height : 0;
            CGPoint newPoint = CGPointMake(0, offH);
            [self.tableView setContentOffset:newPoint animated:NO];
        }else{
            CGPoint newPoint = CGPointMake(0, oldOffset.y + newSize.height - oldSize.height);
            [self.tableView setContentOffset:newPoint animated:NO];
        }
    } failure:^{
        
        [self.tableView.mj_header endRefreshing];
        
        if (loadNum.integerValue == 1) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

- (void)setup
{
    [self setCenterTitle:@"茉莉君" color:HEX_COLOR(JA_BlackTitle)];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
//
    tableView.delegate = self;
    tableView.dataSource =self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self.view addSubview:tableView];
    // 注册cell
    [tableView registerClass:[JAOfficCell class] forCellReuseIdentifier:@"officCell"];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    _tableView.frame = self.view.bounds;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.officArrM.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAOfficModel *model = self.officArrM[indexPath.row];
    
    return model.cellHeight;
}

//  任务中心，帖子详情页，话题详情页，h5,邀请收徒页，新手指南-常见问题，新手指南-视频教程，用户个人主页
/*
 @{
 @"100":@"JAPersonalCenterViewController",  个人中心
 @"101":@"JAEditInfoViewController",        编辑个人资料
 @"102":@"JACreditViewController",          信用分
 @"103":@"JAPersonalLevelViewController",    等级
 @"104":@"", 通知-回复
 @"105":@"", 通知-点赞
 @"106":@"", 通知-邀请
 @"107":@"", 通知-关注
 @"108":@"JAMessageViewController",            私信
 @"109":@"JAActivityCenterViewController",     活动中心
 @"110":@"JAPacketViewController",             邀请徒弟
 @"111":@"JAPacketViewController",             徒弟进贡榜
 @"112":@"JAPacketViewController",             唤醒徒弟
 @"113":@"JAOpenInvitePacketViewController",   输入邀请码
 @"114":@"JAPersonalTaskViewController",       任务中心
 @"115":@"JAPersonIncomeViewController",       我的收入-茉莉花
 @"116":@"JAPersonIncomeViewController",       我的收入-零钱
 @"117":@"JAPersonalSharePictureViewController",  晒输入
 @"118":@"JAHelperViewController",               帮助中心-新手指南
 @"119":@"JAHelperViewController",              帮助中心-视频教程
 @"120":@"JASettingViewController",              设置
 @"121":@"JADraftViewController",               草稿箱
 @"122":@"JAVoiceRecordViewController",         录音
 @"123":@"JACenterDrawerViewController",        首页-推荐
 @"124":@"JACenterDrawerViewController",        首页-关注
 @"125":@"JACenterDrawerViewController",        首页-发现
 @"126":@"JACenterDrawerViewController",        首页-最新
 @"127":@"JAPostDetailViewController",  帖子详情
 @"128":@"JAPersonTopicViewController",         话题详情
 
 300                                             H5
 };
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAOfficCell *cell = [tableView dequeueReusableCellWithIdentifier:@"officCell"];
    
    cell.model = self.officArrM[indexPath.row];
    cell.clickDetailBlock = ^(JAOfficCell *cell) {
      
        JAOfficModel *model = cell.model;
        NSLog(@"%@",model.url);
        if ([model.openType integerValue] == 127){
            
            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            vc.voiceId = model.url;
            [self.navigationController pushViewController:vc animated:YES];

        }else if ([model.openType integerValue] == 300){
            
            JAWebViewController *vc = [[JAWebViewController alloc] init];
            vc.urlString = model.url;
            vc.enterType = @"茉莉君";
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([model.openType integerValue] == 128){   // 话题详情
            
            JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
            vc.topicTitle = model.url;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([model.openType integerValue] == 114){  // 任务中心
            
            if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
                [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
                return;
            }
            
            if ([[JAUserInfo userInfo_getUserImfoWithKey:User_Admin] integerValue] == JAVPOWER) {
                
                return;
            }
            
            JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([model.openType integerValue] == 110){   // 邀请收徒
            
            if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
                [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
                return;
            }
            
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([model.openType integerValue] == 118){
            
//            JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//            vc.currentIndex = 0;
//            [self.navigationController pushViewController:vc animated:YES];
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [self.navigationController pushViewController:help animated:YES];
            
        }else if ([model.openType integerValue] == 119){
            
//            JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//            vc.currentIndex = 1;
//            [self.navigationController pushViewController:vc animated:YES];
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [self.navigationController pushViewController:help animated:YES];
            
        }else if ([model.openType integerValue] == 100){
            
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *personmodel = [[JAConsumer alloc] init];
            personmodel.userId = model.url;
            vc.personalModel = personmodel;
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.openType integerValue] == 130){
            
            JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
            vc.circleId = model.url;
            [self.navigationController pushViewController:vc animated:YES];
        }else if ([model.openType integerValue] == 131){
            
            JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
            vc.subjectId = model.url;
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    
    cell.clickmoliJunBlock = ^(JAOfficCell *cell) {
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = @"1000449";
        model.name = @"茉莉君";
        model.image = @"http://file.xsawe.top//file/1515057390234cadbc939-94f5-4e51-87ae-ffb49eb116ac.png";
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

// 展示空白页
- (void)showBlankPage
{
    if (self.officArrM.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"还没有通知";
        NSString *st = @"";
       [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
}
@end
