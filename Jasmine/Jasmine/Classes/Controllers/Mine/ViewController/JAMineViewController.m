//
//  JAMineViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/4.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMineViewController.h"

#import "JAMineHeaderView.h"
#import "JAMineTableViewCell.h"

#import "JAPersonalCenterViewController.h"
#import "JASettingViewController.h"
#import "JAPersonalLevelViewController.h"
#import "JAPersonStoryAndReplyViewController.h"
#import "JASubRelationshipViewController.h"
#import "JAAdminViewController.h"
#import "JAWebViewController.h"
#import "JAPersonMarkViewController.h"

#import "JAPostDraftModel.h"

#import "JACollectViewController.h"

@interface JAMineViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JAMineHeaderView *headerView;
@property (nonatomic, strong) NSArray *dataSourceArray;

@end

@implementation JAMineViewController

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.dataSourceArray = [self setupDatasource];
    [self setupMineViewController];
    
    // 草稿箱变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(draftArriveAndDismiss) name:@"JA_DraftCountChange" object:nil];

}

- (void)draftArriveAndDismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.dataSourceArray = [self setupDatasource];
        [self.tableView reloadData];        
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    
    self.dataSourceArray = [self setupDatasource];
    [self.tableView reloadData];
    
    // 获取个人信息
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"image"] = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
    dic[@"name"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
    dic[@"level"] = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelId];
    NSInteger story = [JAUserInfo userInfo_getUserImfoWithKey:User_storyCount].integerValue;
    NSInteger comment = [JAUserInfo userInfo_getUserImfoWithKey:User_commentCount].integerValue;
    dic[@"publish"] = [NSString stringWithFormat:@"%ld",story + comment];
    dic[@"collect"] = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount];
    dic[@"focus"] = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount];
    dic[@"fans"] = [JAUserInfo userInfo_getUserImfoWithKey:User_concernUserCount];
    dic[@"markName"] = [JAUserInfo userInfo_getUserImfoWithKey:User_markName];
    dic[@"markImage"] = [JAUserInfo userInfo_getUserImfoWithKey:User_markImage];
    
    self.headerView.infoDictionary = dic;

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];
}

- (void)setupMineViewController
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[JAMineTableViewCell class] forCellReuseIdentifier:@"JAMineTableViewCellId"];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[JAMineHeaderView alloc] init];
    self.headerView.backgroundColor = HEX_COLOR(JA_Background);
    self.headerView.width = JA_SCREEN_WIDTH;
    self.headerView.height = 177;
    self.tableView.tableHeaderView = self.headerView;
    
    UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenter)];
    self.headerView.iconImageView.userInteractionEnabled = YES;
    [self.headerView.iconImageView addGestureRecognizer:iconTap];
    
    UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonCenter)];
    self.headerView.nameLabel.userInteractionEnabled = YES;
    [self.headerView addGestureRecognizer:nameTap];
    
    [self.headerView.personCenterButton addTarget:self action:@selector(jumpPersonCenter) forControlEvents:UIControlEventTouchUpInside];
    
    [self.headerView.levelButton addTarget:self action:@selector(jumpPersonLevel) forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *publishTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPublishStory)];
    [self.headerView.publishView addGestureRecognizer:publishTap];
    
    UITapGestureRecognizer *collectTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpCollectStory)];
    [self.headerView.collectView addGestureRecognizer:collectTap];
    
    UITapGestureRecognizer *focusTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonFocus)];
    [self.headerView.focusView addGestureRecognizer:focusTap];
    
    UITapGestureRecognizer *fansTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonFans)];
    [self.headerView.fansView addGestureRecognizer:fansTap];
    
    // 设置右边按钮
//    [self setNavRightTitle:@"设置" color:HEX_COLOR(0x4a4a4a)];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - 点击事件
- (void)jumpPersonCenter   // 跳转个人中心
{
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    JAConsumer *personalModel = [[JAConsumer alloc] init];
    personalModel.consumerId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    personalModel.name = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
    personalModel.image = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
    personalModel.address = [JAUserInfo userInfo_getUserImfoWithKey:User_Address];
    personalModel.age = [JAUserInfo userInfo_getUserImfoWithKey:User_Age];
    personalModel.sex = [JAUserInfo userInfo_getUserImfoWithKey:User_Sex];
    personalModel.constellation = [JAUserInfo userInfo_getUserImfoWithKey:User_Constellation];
    personalModel.concernUserCount = [JAUserInfo userInfo_getUserImfoWithKey:User_concernUserCount];
    personalModel.userConsernCount = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount];
    personalModel.agreeCount = [JAUserInfo userInfo_getUserImfoWithKey:User_agree];
    vc.personalModel = personalModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpPersonLevel   // 跳转个人等级
{
//    JAPersonalLevelViewController *vc = [JAPersonalLevelViewController new];
//    [self.navigationController pushViewController:vc animated:YES];
    JAPersonMarkViewController *vc = [[JAPersonMarkViewController alloc] init];
    vc.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpPublishStory   // 跳转个人发表故事
{
    JAPersonStoryAndReplyViewController *vc = [[JAPersonStoryAndReplyViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpCollectStory   // 跳转个人收藏故事
{
    JACollectViewController *vc = [[JACollectViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpPersonFans   // 跳转个人粉丝
{
    JASubRelationshipViewController *vc = [JASubRelationshipViewController new];
    vc.type = 2;
    vc.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    vc.sex = [JAUserInfo userInfo_getUserImfoWithKey:User_Sex];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [vc getData:nil];
    });
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpPersonFocus   // 跳转个人关注
{
    JASubRelationshipViewController *vc = [JASubRelationshipViewController new];
    vc.type = 1;
    vc.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    vc.sex = [JAUserInfo userInfo_getUserImfoWithKey:User_Sex];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [vc getData:nil];
    });
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void)actionRight
{
    JASettingViewController *vc = [[JASettingViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSArray *)setupDatasource
{
    // 获取是否签到
    NSString *leftT_sign = @"0";
    NSInteger sign = [JAConfigManager shareInstance].signState;
    if (sign == 0) {
        leftT_sign = @"1";
    }
    
    // 获取是否有活动
    NSString *leftT_activity = @"0";
    BOOL activity = [JARedPointManager checkRedPoint:JARedPointTypeActivity];
    if (activity) {
        leftT_activity = @"2";
    }
    
    NSString *rightT = @"0-0";
    NSArray *drafts = [JAPostDraftModel searchWithWhere:nil];
    if (drafts.count) {
        // 获取是否有新的草稿
        NSInteger story_new = [JAPostDraftModel rowCountWithWhere:@{@"isRead":@(NO)}];
        // 获取草稿的数目
        NSInteger story_old = [JAPostDraftModel rowCountWithWhere:@{@"isRead":@(YES)}];
        
        rightT = [NSString stringWithFormat:@"%ld-%ld",story_new,(story_old + story_new)];
    }
    
    // 钱
    NSString *subStr = @"0";
    NSString *money = [JAUserInfo userInfo_getUserImfoWithKey:User_IncomeMoney];
    subStr = [NSString stringWithFormat:@"%@元",[self decimalNumberWithDouble:money.doubleValue]];
    
    // 佩戴的勋章
    NSString *medalImage = [JAUserInfo userInfo_getUserImfoWithKey:User_medalImage];
    NSString *medalList = [JAUserInfo userInfo_getUserImfoWithKey:User_medalList];
    if (medalList.integerValue) {
        medalImage = medalImage.length ? medalImage : @"未佩戴";
    }else{
        medalImage = @"未获得";
    }
    
    NSMutableArray *groupArr = [NSMutableArray array];
    
    NSDictionary *medalDic = @{
                               @"name" : @"我的勋章",
                               @"subName" : medalImage,
                               @"image" : @"branch_mine_medal",
                               @"class" : @"JAMyMedalViewController",
                               @"leftTag" : @"0",
                               @"rightTag" : @"0-0"
                               };
    
    NSDictionary *packetDic = @{
                                @"name" : @"邀请收徒",
                                @"subName" : @"领红包",
                                @"image" : @"branch_mine_packet",
                                @"class" : @"JAPacketViewController",
                                @"leftTag" : @"0",
                                @"rightTag" : @"0-0"
                                };
    
    NSDictionary *taskDic = @{
                              @"name" : @"任务中心",
                              @"subName" : @"赚零花",
                              @"image" : @"branch_mine_task",
                              @"class" : @"JAPersonalTaskViewController",
                              @"leftTag" : leftT_sign,  // 1 签到
                              @"rightTag" : @"0-0"
                              };
    
    NSDictionary *activityDic = @{
                                  @"name" : @"福利活动",
                                  @"subName" : @" ",
                                  @"image" : @"branch_mine_activity",
                                  @"class" : @"JAActivityCenterViewController",
                                  @"leftTag" : leftT_activity,  // 0 不展示    2 活动红点
                                  @"rightTag" : @"0-0"
                                  };
    
    NSDictionary *incomeDic = @{
                                @"name" : @"收入明细",
                                @"subName" : subStr,
                                @"image" : @"branch_mine_money",
                                @"class" : @"JAPersonIncomeViewController",
                                @"leftTag" : @"0",
                                @"rightTag" : @"0-0"
                                };
    
    NSDictionary *shopDic = @{
                              @"name" : @"兑换商城",
                              @"subName" : @" ",
                              @"image" : @"branch_mine_shopping",
                              @"class" : @"JAWebViewController",
                              @"leftTag" : @"0",
                              @"rightTag" : @"0-0"
                              };
    
    NSDictionary *FMDic = @{
                            @"name" : @"茉莉电台",
                            @"subName" : @" ",
                            @"image" : @"branch_mine_FM",
                            @"class" : @"JAPersonalCenterViewController",
                            @"leftTag" : @"0",
                            @"rightTag" : @"0-0"
                            };
    
    NSDictionary *helperDic = @{
                                @"name" : @"新手指南",
                                @"subName" : @" ",
                                @"image" : @"branch_mine_helper",
                                @"class" : @"JAWebViewController",
                                @"leftTag" : @"0",
                                @"rightTag" : @"0-0"
                                };
    
    NSDictionary *draftDic = @{
                               @"name" : @"草稿箱",
                               @"subName" : @" ",
                               @"image" : @"mine_left_draft",
                               @"class" : @"JADraftViewController",
                               @"leftTag" : @"0",
                               @"rightTag" : rightT
                               };
    
    NSDictionary *settingDic = @{
                                 @"name" : @"设置",
                                 @"subName" : @" ",
                                 @"image" : @"branch_mine_setting",
                                 @"class" : @"JASettingViewController",
                                 @"leftTag" : @"0",
                                 @"rightTag" : @"0-0"
                                 };
    
//    NSDictionary *checkDic = @{
//                               @"name" : @"审核",
//                               @"subName" : @" ",
//                               @"image" : @"mine_left_check",
//                               @"class" : @"JAAdminViewController",
//                               @"leftTag" : @"0",
//                               @"rightTag" : @"0-0"
//                               };
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {  // debug中
        [groupArr addObject:@[medalDic]];
        [groupArr addObject:@[FMDic,helperDic,draftDic]];
        [groupArr addObject:@[settingDic]];
        return groupArr;
    }
    
    if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
        [groupArr addObject:@[medalDic]];
        [groupArr addObject:@[packetDic,taskDic,activityDic]];
        if ([JAConfigManager shareInstance].shopSign) {
            [groupArr addObject:@[incomeDic,shopDic]];
        }else{
            [groupArr addObject:@[incomeDic]];
        }
        [groupArr addObject:@[FMDic,helperDic,draftDic]];
        [groupArr addObject:@[settingDic]];
    }else{
        [groupArr addObject:@[medalDic]];
        [groupArr addObject:@[packetDic,taskDic,activityDic]];
        if ([JAConfigManager shareInstance].shopSign) {
            [groupArr addObject:@[incomeDic,shopDic]];
        }else{
            [groupArr addObject:@[incomeDic]];
        }
        [groupArr addObject:@[FMDic,helperDic,draftDic]];
        [groupArr addObject:@[settingDic]];
    }
    
    return groupArr;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *sectionA = self.dataSourceArray[indexPath.section];
    NSDictionary *rowA = sectionA[indexPath.row];
    NSDictionary *cellDic = rowA;
    
    NSString *type = cellDic[@"class"];
    NSString *title = cellDic[@"name"];
    
    JABaseViewController *vc = [NSClassFromString(type) new];
    
    if ([vc isKindOfClass:[JAPersonalCenterViewController class]]) {
        
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *personalModel = [[JAConsumer alloc] init];
        personalModel.consumerId = @"1275";
        personalModel.name = @"茉莉电台";
        personalModel.image = @"http://file.xsawe.top//file/1515057390234cadbc939-94f5-4e51-87ae-ffb49eb116ac.png";
        vc.personalModel = personalModel;
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([vc isKindOfClass:[JAAdminViewController class]]){
        JAAdminViewController *adminVc = [[JAAdminViewController alloc] init];
        adminVc.checkTag = 1;
        [self.navigationController pushViewController:adminVc animated:YES];
    }else if ([vc isKindOfClass:[JAWebViewController class]]){
        
        if ([title isEqualToString:@"新手指南"]) {
            JAWebViewController *help = [[JAWebViewController alloc] init];
            help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
            help.titleString = @"帮助中心";
            help.fromType = 1;
            help.enterType = @"帮助中心";
            [self.navigationController pushViewController:help animated:YES];
        }else{
            JAWebViewController *webVc = [[JAWebViewController alloc] init];
            webVc.urlString = [JAConfigManager shareInstance].shopUrl;
            webVc.enterType = @"兑换商城";
            [self.navigationController pushViewController:webVc animated:YES];
        }
    }
    else{
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataSourceArray[section];
    return arr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEX_COLOR(0xF4F4F4);
    lineV.width = JA_SCREEN_WIDTH;
    lineV.height = 10;
    return lineV;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAMineTableViewCellId"];
    NSArray *sectionA = self.dataSourceArray[indexPath.section];
    NSDictionary *rowA = sectionA[indexPath.row];
    cell.cellDic = rowA;
    if (indexPath.row == sectionA.count-1) {
        [cell setBottomLineHidden:YES];
    } else {
        [cell setBottomLineHidden:NO];
    }
    return cell;
}

/** 直接传入精度丢失有问题的Double类型*/
- (NSString *)decimalNumberWithDouble:(double)conversionValue{
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.headerView.topOffY = scrollView.contentOffset.y;
    if (scrollView.contentOffset.y >= 10) {
        [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];
        [self setCenterTitle:@"我的"];
    } else {
        [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
        [self setCenterTitle:nil];
    }
}

@end
