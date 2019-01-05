//
//  JANewLeftDrawerViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANewLeftDrawerViewController.h"
#import "JALeftDrawerCell.h"
#import "JAMaintainView.h"
#import "JANoobPageView.h"
#import "JAMessageRedButton.h"

#import "JAVoicePersonApi.h"

#import "JACreditViewController.h"
#import "JAPersonalLevelViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JAActivityCenterViewController.h"
#import "JAMessageViewController.h"
#import "JAAdminViewController.h"
#import "JASettingViewController.h"
#import "JACenterDrawerViewController.h"
#import "JADraftViewController.h"
#import "JAWebViewController.h"
#import "JAsynthesizeMessageViewController.h"

#import "JANotiModel.h"
#import "JASwitchDefine.h"
#import "JASampleHelper.h"
#import "JAPostDraftModel.h"

@interface JANewLeftDrawerViewController ()<UITableViewDelegate, UITableViewDataSource,NIMSystemNotificationManagerDelegate,NIMConversationManagerDelegate,NIMChatManagerDelegate,QYConversationManagerDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *iconImageView;  // 头像
@property (nonatomic, strong) UILabel *nameLabel;          // 昵称
@property (nonatomic, strong) UIButton *levelButton;      // 等级
@property (nonatomic, strong) UIButton *reputationButton;      // 信用
@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *activityButton;        // 活动
@property (nonatomic, strong) UIButton *notifacationButton; // 通知消息
@property (nonatomic, strong) UIButton *messageButton;        // 私信
@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIView *footView;
@property (nonatomic, strong) UIButton *settingButton;   // 设置
@property (nonatomic, strong) JAMessageRedButton *draftButton;    // 草稿
@property (nonatomic, strong) UIButton *checkButton;    // 审核

@property (nonatomic, strong) NSArray *datasourceArray; // 数据源
@property (nonatomic, assign) int allCount;

@property (nonatomic, assign) BOOL isShowNoob; // 新手引导

@property (readwrite, nonatomic, strong) dispatch_queue_t myConcurrentQueue;
@end

@implementation JANewLeftDrawerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myConcurrentQueue = dispatch_queue_create("myConcurrentQueue", DISPATCH_QUEUE_CONCURRENT); // 需要自己创建
    
    [self setupLeftDrawerViewControllerUI];
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    // 设置代理监听
    [self setNotiListen];
    
    // 签到成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLeftDateSource) name:SIGNSUCCESS object:nil];
    // 这个通知是为了在左边栏出现了的时候点击了签到
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLeftDateSourceNeedSign) name:NEED_SIGN object:nil];
    // 刷新左边UI
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLeftDrawUI) name:DATACLIENTUPDATE object:nil];

    // 草稿箱变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(draftArriveAndDismiss) name:@"JA_DraftCountChange" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self refreshLeftDrawUI];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"个人中心";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

#pragma mark - 刷新界面
// 签到成功 - 清除签到图标
- (void)refreshLeftDateSource
{
    [JAConfigManager shareInstance].signState = 1;
    [self.tableView reloadData];
}

- (void)refreshLeftDateSourceNeedSign
{
    [self.tableView reloadData];
}

- (void)refreshLeftDrawUI
{
    NSString *imageUrl = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
    [self.iconImageView ja_setImageWithURLStr:[imageUrl ja_getFitImageStringWidth:65 height:65] placeholder:[UIImage imageNamed:@"moren_nan"]];
    
#ifdef JA_TEST_HOST
    if (![[JAConfigManager shareInstance].host containsString:@"data.urmoli.com"]) {
        self.nameLabel.text = [NSString stringWithFormat:@"测试-%@",[JAUserInfo userInfo_getUserImfoWithKey:User_Name]];
    } else {
        self.nameLabel.text = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
    }
#else
    self.nameLabel.text = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
#endif
    
    NSString *creditStr = [NSString stringWithFormat:@"信用分 %@",[JAUserInfo userInfo_getUserImfoWithKey:User_score]];
    [self.reputationButton setTitle:creditStr forState:UIControlStateNormal];
    
    NSString *levelStr = [NSString stringWithFormat:@"lv%@",[JAUserInfo userInfo_getUserImfoWithKey:User_LevelId]];
    [self.levelButton setTitle:levelStr forState:UIControlStateNormal];
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//        self.activityButton.hidden = YES;
        self.checkButton.hidden = YES;
        self.reputationButton.hidden = YES;
        self.levelButton.hidden = YES;
        self.iconImageView.y = 40;
    }else{
//        self.activityButton.hidden = NO;
        self.reputationButton.hidden = NO;
        self.levelButton.hidden = NO;
        self.iconImageView.y = 60;
        if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
            self.checkButton.hidden = NO;
        }else{
            self.checkButton.hidden = YES;
        }
    }
    
    self.datasourceArray = [self getDataSource];
    [self.tableView reloadData];
}

#pragma mark - 设置UI
- (void)setupLeftDrawerViewControllerUI
{
    self.tableView = [[UITableView alloc] init];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.frame = self.view.bounds;
    self.tableView.height = self.view.height - 50;
    [self.tableView registerClass:[JALeftDrawerCell class] forCellReuseIdentifier:@"LeftDrawerCellID"];
    [self.view addSubview:self.tableView];
    
    self.headerView = [[UIView alloc] init];
    self.headerView.backgroundColor = HEX_COLOR(0xffffff);
    self.headerView.width = self.view.width;
    self.headerView.height = 243;
    self.tableView.tableHeaderView = self.headerView;
    
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = HEX_COLOR(0xF5F6F9);
    self.topView.width = self.headerView.width;
    self.topView.height = 140;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPersonalCneter)];
    [self.topView addGestureRecognizer:tap];
    [self.headerView addSubview:self.topView];
    
    self.iconImageView = [[UIImageView alloc] init];
    self.iconImageView.height = 65;
    self.iconImageView.width = self.iconImageView.height;
    self.iconImageView.y = 60;
    self.iconImageView.x = 20;
    self.iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.clipsToBounds = YES;
    [self.headerView addSubview:self.iconImageView];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.text = @" ";
    self.nameLabel.width = 160;
    self.nameLabel.height = 25;
    self.nameLabel.x = self.iconImageView.right + 18;
    self.nameLabel.y = self.iconImageView.top + 3;
    self.nameLabel.textColor = HEX_COLOR(0x1B1B1B);
    self.nameLabel.font = JA_MEDIUM_FONT(18);
    [self.headerView addSubview:self.nameLabel];
    
    self.reputationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.reputationButton setTitleColor:HEX_COLOR(0xFFFFFF) forState:UIControlStateNormal];
    self.reputationButton.titleLabel.font = JA_MEDIUM_FONT(12);
    self.reputationButton.backgroundColor = HEX_COLOR(0x66CCFF);
    self.reputationButton.width = 96;
    self.reputationButton.height = 25;
    self.reputationButton.x = self.nameLabel.x;
    self.reputationButton.y = self.nameLabel.bottom + 8;
    self.reputationButton.layer.cornerRadius = self.reputationButton.height * 0.5;
    [self.reputationButton addTarget:self action:@selector(clickreputationButton:) forControlEvents:UIControlEventTouchUpInside];
    self.reputationButton.hidden = YES;
//    [self.headerView addSubview:self.reputationButton];
    
    self.levelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.levelButton setTitleColor:HEX_COLOR(0x8B572A) forState:UIControlStateNormal];
    self.levelButton.titleLabel.font = JA_MEDIUM_FONT(12);
    self.levelButton.backgroundColor = HEX_COLOR(0xFFDF01);
    self.levelButton.width = 50;
    self.levelButton.height = 25;
//    self.levelButton.x = self.reputationButton.right + 5;
//    self.levelButton.y = self.reputationButton.y;
    self.levelButton.x = self.nameLabel.x;
    self.levelButton.y = self.nameLabel.bottom + 8;
    self.levelButton.layer.cornerRadius = self.levelButton.height * 0.5;
    [self.levelButton addTarget:self action:@selector(clickLevelButton:) forControlEvents:UIControlEventTouchUpInside];
    self.levelButton.hidden = YES;
    [self.headerView addSubview:self.levelButton];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = HEX_COLOR(0xffffff);
    self.bottomView.width = self.headerView.width;
    self.bottomView.height = 103;
    self.bottomView.y = self.topView.bottom;
    [self.headerView addSubview:self.bottomView];
    
    
    self.activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.activityButton setTitle:@"活动" forState:UIControlStateNormal];
    [self.activityButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    self.activityButton.titleLabel.font = JA_REGULAR_FONT(13);
    [self.activityButton setImage:[UIImage imageNamed:@"branch_mine_activity"] forState:UIControlStateNormal];
    [self.activityButton setImage:[UIImage imageNamed:@"branch_mine_activityed"] forState:UIControlStateSelected];
    self.activityButton.width = 30;
    self.activityButton.height = 50;
    self.activityButton.x = 20;
    self.activityButton.centerY = self.bottomView.height * 0.5;
//    self.activityButton.hidden = YES;
    [self.activityButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:1];
    [self.activityButton addTarget:self action:@selector(jumpActivity) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.activityButton];
    
    self.notifacationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.notifacationButton setTitle:@"消息" forState:UIControlStateNormal];
    [self.notifacationButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    self.notifacationButton.titleLabel.font = JA_REGULAR_FONT(13);
    [self.notifacationButton setImage:[UIImage imageNamed:@"branch_mine_unnoti"] forState:UIControlStateNormal];
    [self.notifacationButton setImage:[UIImage imageNamed:@"branch_mine_noti"] forState:UIControlStateSelected];
    self.notifacationButton.width = 30;
    self.notifacationButton.height = 50;
    self.notifacationButton.x = self.activityButton.right + 40;
    self.notifacationButton.y = self.activityButton.y;
    [self.notifacationButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:1];
    [self.notifacationButton addTarget:self action:@selector(jumpNotifacation) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.notifacationButton];
    
    self.messageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.messageButton setTitle:@"私信" forState:UIControlStateNormal];
    [self.messageButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    self.messageButton.titleLabel.font = JA_REGULAR_FONT(13);
    [self.messageButton setImage:[UIImage imageNamed:@"branch_mine_unmessage"] forState:UIControlStateNormal];
    [self.messageButton setImage:[UIImage imageNamed:@"branch_mine_message"] forState:UIControlStateSelected];
    self.messageButton.width = 30;
    self.messageButton.height = 50;
    self.messageButton.x = self.notifacationButton.right + 40;
    self.messageButton.y = self.notifacationButton.y;
    [self.messageButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:1];
    [self.messageButton addTarget:self action:@selector(jumpMessage) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.messageButton];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    lineView.width = self.view.width;
    lineView.height = 1;
    lineView.y = self.bottomView.height - 1;
    [self.bottomView addSubview:lineView];
    
    self.footView = [[UIView alloc] init];
    self.footView.width = self.view.width;
    self.footView.height = 48;
    self.footView.y = self.view.height - self.footView.height;
    self.footView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.footView];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = HEX_COLOR(JA_Line);
    lineView1.width = self.view.width;
    lineView1.height = 1;
    [self.footView addSubview:lineView1];
    
    self.settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingButton setImage:[UIImage imageNamed:@"branch_mine_setting"] forState:UIControlStateNormal];
    [self.settingButton setTitle:@"设置" forState:UIControlStateNormal];
    [self.settingButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    self.settingButton.titleLabel.font = JA_REGULAR_FONT(14);
    self.settingButton.width = 70;
    self.settingButton.height = 25;
    self.settingButton.x = 20;
    self.settingButton.centerY = self.footView.height * 0.5;
    self.settingButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.settingButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
    [self.settingButton addTarget:self action:@selector(jumpSetting) forControlEvents:UIControlEventTouchUpInside];
    [self.footView addSubview:self.settingButton];
    
    self.draftButton = [JAMessageRedButton buttonWithType:UIButtonTypeCustom];
    [self.draftButton setImage:[UIImage imageNamed:@"mine_left_draft"] forState:UIControlStateNormal];
    [self.draftButton setTitle:@"草稿箱" forState:UIControlStateNormal];
    [self.draftButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    self.draftButton.titleLabel.font = JA_REGULAR_FONT(14);
    self.draftButton.width = 70;
    self.draftButton.height = 25;
    self.draftButton.x = self.settingButton.right + 10;
    self.draftButton.centerY = self.footView.height * 0.5;
    self.draftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.draftButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, -4);
    [self.draftButton addTarget:self action:@selector(jumpDraftVc) forControlEvents:UIControlEventTouchUpInside];
    [self.footView addSubview:self.draftButton];
    
    self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.checkButton setTitle:@"审核" forState:UIControlStateNormal];
    [self.checkButton setTitleColor:HEX_COLOR(0x0080FF) forState:UIControlStateNormal];
    self.checkButton.titleLabel.font = JA_REGULAR_FONT(18);
    self.checkButton.width = 60;
    self.checkButton.height = 48;
    self.checkButton.x = 200;
    self.checkButton.hidden = YES;
    [self.checkButton addTarget:self action:@selector(jumpCheck) forControlEvents:UIControlEventTouchUpInside];
    [self.footView addSubview:self.checkButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat h = 0;
    if (iPhoneX) {
        h = 34;
    }
    
    self.footView.y = self.view.height - self.footView.height - h;
}

#pragma mark - 按钮的点击
- (void)clickreputationButton:(UIButton *)btn    // 信用
{
    JACreditViewController *vc = [[JACreditViewController alloc] init];
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)clickLevelButton:(UIButton *)btn    // 等级
{
    JAPersonalLevelViewController *vc = [JAPersonalLevelViewController new];
    //    [[DrawerViewController shareDrawer] LeftViewControllerWithDidSelectController:vc];
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)jumpPersonalCneter   // 个人中心
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
    
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)jumpActivity   // 活动
{
//    JAActivityCenterViewController *vc = [[JAActivityCenterViewController alloc] init];
//    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
//        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    }];
//
//    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
    
    
    JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
    vc.selectIndex = 0;
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)jumpNotifacation   // 通知
{

    JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
    vc.selectIndex = 1;
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)jumpMessage     // 私信
{
//    JAMessageViewController *vc = [[JAMessageViewController alloc] init];
//    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
//        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    }];
//
//    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
    
    JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
    vc.selectIndex = 2;
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)jumpSetting  // 设置
{
    JASettingViewController *vc = [[JASettingViewController alloc] init];
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
}

- (void)jumpDraftVc   // 草稿箱
{
    JADraftViewController *vc = [[JADraftViewController alloc] init];
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
    
}

- (void)jumpCheck   // 审核
{
    JAAdminViewController *adminVc = [[JAAdminViewController alloc] init];
    adminVc.checkTag = 1;
    [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    }];
    [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:adminVc animated:YES];
}

#pragma mark - tableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JALeftDrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LeftDrawerCellID"];
    
    NSDictionary *dic = self.datasourceArray[indexPath.row];
    
    cell.cellDic = dic;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = self.datasourceArray[indexPath.row];
    
    NSString *type = dic[@"type"];
    
    JABaseViewController *vc = [NSClassFromString(type) new];
    
    if ([vc isKindOfClass:[JAPersonalCenterViewController class]]) {

        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *personalModel = [[JAConsumer alloc] init];
        personalModel.consumerId = @"1275";
        personalModel.name = @"茉莉电台";
        personalModel.image = @"http://file.xsawe.top//file/1515057390234cadbc939-94f5-4e51-87ae-ffb49eb116ac.png";
        vc.personalModel = personalModel;
        
        [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
            // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
            [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        }];
        [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
        
    }else{
        
        [[AppDelegateModel rootviewController] closeDrawerAnimated:YES completion:^(BOOL finished) {
            // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
            [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
        }];
        [[AppDelegateModel getCenterMenuViewController].navigationController pushViewController:vc animated:YES];
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [UIView new];
    v.backgroundColor = [UIColor whiteColor];
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

// 设置消息红点
- (void)setMsg_needRed:(BOOL)msg_needRed
{
    _msg_needRed = msg_needRed;
    
    self.messageButton.selected = msg_needRed;
}

// 设置通知红点
- (void)setNoti_needRed:(BOOL)noti_needRed
{
    _noti_needRed = noti_needRed;
    
    self.notifacationButton.selected = noti_needRed;
}

// 设置活动红点
- (void)setActivity_needRed:(BOOL)activity_needRed
{
    _activity_needRed = activity_needRed;
    
    self.activityButton.selected = activity_needRed;
}

// 设置草稿红点
- (void)setDraft_needRed:(BOOL)draft_needRed
{
    _draft_needRed = draft_needRed;
    
    self.draftButton.showRed = draft_needRed;
}

#pragma mark - 新手引导
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    BOOL personKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"JANoobPersonKey"];
//    BOOL levelKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"JANoobLevelKey"];
//    if (!personKey || !levelKey) {
//        self.isShowNoob = YES;
//    }
}

// 展示新手引导
- (void)setIsShowNoob:(BOOL)isShowNoob
{
    _isShowNoob = isShowNoob;
    
    BOOL personKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"JANoobPersonKey"];
    
    BOOL levelKey = [[NSUserDefaults standardUserDefaults] boolForKey:@"JANoobLevelKey"];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!iPhone4) {
            JANoobPageView *pageV = [[JANoobPageView alloc] init];
            pageV.width = JA_SCREEN_WIDTH;
            pageV.height = JA_SCREEN_HEIGHT;
            [[[[UIApplication sharedApplication] delegate] window] addSubview:pageV];
            
            NSMutableArray *imageArray = [NSMutableArray array];
            if (!personKey) {
                [imageArray addObject:@"noob_personPage"];
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAVPOWER) {
                    
                    [imageArray addObject:@"noob_task"];
                }
                [imageArray addObject:@"noob_help"];
            }
            
            if (!levelKey) {
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_LevelId].integerValue > 1) {
                    [imageArray addObject:@"noob_level"];
                    [imageArray addObject:@"noob_credit"];
                }
            }
            
            NSMutableArray *typeArr = [NSMutableArray array];
            if (!personKey) {
                
                [typeArr addObject:@(JANoobPageTypePersonPage)];
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAVPOWER) {
                    [typeArr addObject:@(JANoobPageTypePersonTask)];
                }
                [typeArr addObject:@(JANoobPageTypeHelpCenter)];
            }
            if (!levelKey) {
                
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_LevelId].integerValue > 1) {
                    [typeArr addObject:@(JANoobPageTypePersonLevel)];
                }
            }
            
            // 获取第2个cell
            NSIndexPath *indexP1 = [NSIndexPath indexPathForRow:2 inSection:0];
            JALeftDrawerCell *taskcell = [self.tableView cellForRowAtIndexPath:indexP1];
            
            // 获取第2个cell
            NSIndexPath *indexP2 = [NSIndexPath indexPathForRow:4 inSection:0];
            JALeftDrawerCell *helpcell = [self.tableView cellForRowAtIndexPath:indexP2];
            
            NSPointerArray *superV = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory];
            if (!personKey) {
                
                [superV addPointer:(__bridge void *)(self.headerView)];
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAVPOWER) {
                    [superV addPointer:(__bridge void *)(taskcell)];
                }
                [superV addPointer:(__bridge void *)(helpcell)];
            }
            if (!levelKey) {
                
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_LevelId].integerValue > 1) {
                    [superV addPointer:(__bridge void *)(self.headerView)];
                    [superV addPointer:(__bridge void *)(self.headerView)];
                }
            }
            
            NSPointerArray *subV = [[NSPointerArray alloc] initWithOptions:NSPointerFunctionsWeakMemory];
            if (!personKey) {
                
                [subV addPointer:(__bridge void *)(self.iconImageView)];
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAVPOWER) {
                    [subV addPointer:(__bridge void *)(taskcell.nameLabel)];
                }
                [subV addPointer:(__bridge void *)(taskcell.nameLabel)];
            }
            if (!levelKey) {
                
                if ([JAUserInfo userInfo_getUserImfoWithKey:User_LevelId].integerValue > 1) {
                    [subV addPointer:(__bridge void *)(self.levelButton)];
                    [subV addPointer:(__bridge void *)(self.reputationButton)];
                }
            }
            
            // 改版后 新手引导 注释掉
//            [pageV converLocation:superV rectView:subV images:imageArray type:typeArr];
//
//            [pageV showNoob];
        }
    });
}

#pragma mark - 获取数据源
- (NSArray *)getDataSource
{
    NSArray *arr = nil;
    // 钱
    NSString *subStr = nil;
    NSString *money = [JAUserInfo userInfo_getUserImfoWithKey:User_IncomeMoney];

    subStr = [NSString stringWithFormat:@"%@元",[self decimalNumberWithDouble:money.doubleValue]];
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {   // debug中
        
        arr =  @[
                 @{@"image" :@"branch_mine_search" ,@"name":@"查找",@"type":@"JANewSearchViewController",@"subName":@" "},
                 @{@"image" :@"branch_mine_helper" ,@"name":@"新手指南",@"type":@"JAHelperViewController",@"subName":@" "},
                 ];
    }else{
        
        if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAVPOWER){   // 大V
            arr =  @[
                     @{@"image" :@"branch_mine_search" ,@"name":@"查找",@"type":@"JANewSearchViewController",@"subName":@" "},
                     @{@"image" :@"branch_mine_packet" ,@"name":@"邀请收徒",@"type":@"JAPacketViewController",@"subName":@" 领红包"},
                     @{@"image" :@"branch_mine_money" ,@"name":@"我的收入",@"type":@"JAPersonIncomeViewController",@"subName":subStr},
                     @{@"image" :@"branch_mine_helper" ,@"name":@"新手指南",@"type":@"JAHelperViewController",@"subName":@" "},
                     @{@"image" :@"branch_mine_FM" ,@"name":@"茉莉FM",@"type":@"JAPersonalCenterViewController",@"subName":@" "},
                     ];
        }else{      // 正常用户
            arr =  @[
                     @{@"image" :@"branch_mine_search" ,@"name":@"查找",@"type":@"JANewSearchViewController",@"subName":@" "},
                     @{@"image" :@"branch_mine_packet" ,@"name":@"邀请收徒",@"type":@"JAPacketViewController",@"subName":@" 领红包"},
                     @{@"image" :@"branch_mine_task" ,@"name":@"任务中心",@"type":@"JAPersonalTaskViewController",@"subName":@" 赚零花"},
                     @{@"image" :@"branch_mine_money" ,@"name":@"我的收入",@"type":@"JAPersonIncomeViewController",@"subName":subStr},
                     @{@"image" :@"branch_mine_helper" ,@"name":@"新手指南",@"type":@"JAHelperViewController",@"subName":@" "},
                     @{@"image" :@"branch_mine_FM" ,@"name":@"茉莉FM",@"type":@"JAPersonalCenterViewController",@"subName":@" "},
                     ];
        }
        
    }
    
    return arr;
}

/** 直接传入精度丢失有问题的Double类型*/
- (NSString *)decimalNumberWithDouble:(double)conversionValue{
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

#pragma mark - 通知的监听
// 设置通知的监听代理
- (void)setNotiListen
{
    [JAChatMessageManager yx_addNotiListenDelegate:self];
    [[NIMSDK sharedSDK].chatManager addDelegate:self];
    [[QYSDK sharedSDK].conversationManager setDelegate:self];
}

- (void)draftArriveAndDismiss
{
    NSInteger story_new = [JAPostDraftModel rowCountWithWhere:@{@"isRead":@(NO)}];
    if (story_new) {
        [JARedPointManager hasNewRedPointArrive:JARedPointTypeDraft];
    }else{
        [JARedPointManager resetNewRedPointArrive:JARedPointTypeDraft];
    }   
}

// 七鱼收到消息 - 客服
- (void)onReceiveMessage:(QYMessageInfo *)message
{
    self.messageButton.selected = YES;
//    JACenterDrawerViewController *center = [AppDelegateModel getCenterMenuViewController];
//    center.leftButton.selected = YES;
    [JARedPointManager hasNewRedPointArrive:JARedPointTypeMessage];
}

// 接受消息 - 回话聊天
- (void)onRecvMessages:(NSArray<NIMMessage *> *)messages   // 接受到消息
{
    self.messageButton.selected = YES;
//    JACenterDrawerViewController *center = [AppDelegateModel getCenterMenuViewController];
//    center.leftButton.selected = YES;
    [JARedPointManager hasNewRedPointArrive:JARedPointTypeMessage];
}

// 收到通知 - 小铃铛通知
- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
{
    if (!IS_LOGIN) {
        return;
    }
    
    if ([notification.sender isEqualToString:@"servermoli"]) {
        
        // 解析通知数据
        NSDictionary *dic = [self dictionaryWithJsonString:notification.content];
        
        // 获取通知的类型
        NSString *toast = [NSString stringWithFormat:@"%@",dic[@"noticeType"]];
        
        
        if (toast.length && [toast isEqualToString:@"kickuser"]) {          // 1.1 踢人的通知
            
            NSString *kick = [NSString stringWithFormat:@"%@",dic[@"kick"]];
            
            if (kick.length && [kick isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
                
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您的账号违法了相关用户协议，已被禁用"];
                // 退出
                [JAAPPManager app_loginOut];
                
//                [JAUserInfo userinfo_saveUserLoginState:NO];
//                [JAUserInfo userInfo_deleteUserInfo];
//
//                // 退出云信
//                [[QYSDK sharedSDK] logout:^(){}];
//                [JAChatMessageManager yx_loginOutYX];
//
//                // 删除别名
//                [JPUSHService setAlias:nil completion:nil seq:0];
//
//                [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
//                    // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//                    [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//                }];
//                [JAAPPManager app_modalLogin];
                return;
            }
            
        }else if (toast.length && [toast isEqualToString:@"shutupuser"]){     // 1.2 禁言 - 解除禁言
            
            NSString *stateStr = [NSString stringWithFormat:@"%@",dic[@"status"]];
            NSString *timeStr = [NSString stringWithFormat:@"%@",dic[@"validTime"]];
            // 判断禁言 解除禁言
            if ([dic[@"status"] integerValue] == 2){
                [JAUserInfo userInfo_updataUserInfoWithKey:User_Status value:stateStr];
                [JAUserInfo userInfo_updataUserInfoWithKey:User_ValidTime value:timeStr];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"由于违规，您已被禁言"];
            }else{
                [JAUserInfo userInfo_updataUserInfoWithKey:stateStr value:User_Status];
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您已被解除禁言"];
            }
            
        }else if (toast.length && [toast isEqualToString:@"propertyUpdate"]) {  // 1.3 等级 信用变更
            
            NSString *numStr = [NSString stringWithFormat:@"%@",dic[@"num"]];
            
            if ([dic[@"propertyType"] integerValue] == 0) {

            }else if ([dic[@"propertyType"] integerValue] == 1){

            }else if ([dic[@"propertyType"] integerValue] == 2){
                
            }else if ([dic[@"propertyType"] integerValue] == 3){  // 等级
                [JAUserInfo userInfo_updataUserInfoWithKey:User_LevelId value:numStr];
            }else if ([dic[@"propertyType"] integerValue] == 4){   // 信用
                [JAUserInfo userInfo_updataUserInfoWithKey:User_score value:numStr];
            }else if ([dic[@"propertyType"] integerValue] == 5){   // 经验
                [JAUserInfo userInfo_updataUserInfoWithKey:User_LevelScore value:numStr];
            }else if ([dic[@"propertyType"] integerValue] == 6){   // 下一个等级的经验值
                [JAUserInfo userInfo_updataUserInfoWithKey:User_TopScore value:numStr];
            }
            
        }else if (toast.length && [toast isEqualToString:@"income"]) {   // 1.4 弹窗得通知
            
            [JAAPPManager app_awardMaskToast:dic[@"income"] flower:dic[@"num"] showText:dic[@"incomeName"]];
            return;
            
        }else if (toast.length && [toast isEqualToString:@"audiomessage"]){  // 1.5 消息通知
            
            // 解析消息的通知
            JANotiModel *data = [JANotiModel mj_objectWithKeyValues:dic];
            
            if ([data.operation isEqualToString:@"comment"]) {
                data.operation = @"reply";
            }
            
            // 只有回复和邀请有音波条的时候才去计算
            if ([data.operation isEqualToString:@"reply"] || [data.operation isEqualToString:@"invite"] || [data.operation isEqualToString:@"atuser"]) {
                
                // 判断包含逗号，就是老版本数据“0.01,0.01,0.02,0.03”
                if (data.content.audioPlayImg.length &&
                    [data.content.audioPlayImg rangeOfString:@","].location == NSNotFound) {
                    NSData *zipData = [[NSData alloc] initWithBase64EncodedString:data.content.audioPlayImg options:0];
                    NSData *outputData = [zipData gunzippedData];
                    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
                    data.content.audioPlayImg = outputString;
                }
                data.displayPeakLevelQueue = [JASampleHelper getDisplayPeakLevelQueue:nil sample:data.content.audioPlayImg type:JADisplayTypeNotification];
                data.currentPeakLevelQueue = [NSMutableArray new];
            }
            

            dispatch_barrier_async(_myConcurrentQueue, ^{
                [data saveToDB];
                if ([data.operation isEqualToString:@"reply"]) {
                    [JARedPointManager hasNewRedPointArrive:JARedPointTypeNoti_Reply];
                    
                }else if ([data.operation isEqualToString:@"friend"]){
                    [JARedPointManager hasNewRedPointArrive:JARedPointTypeNoti_Focus];
                    
                }else if ([data.operation isEqualToString:@"action"]){
                    [JARedPointManager hasNewRedPointArrive:JARedPointTypeNoti_Agree];
                    
                }else if ([data.operation isEqualToString:@"invite"]){
                    [JARedPointManager hasNewRedPointArrive:JARedPointTypeNoti_Invite];
                    
                }else if ([data.operation isEqualToString:@"atuser"]){
                    [JARedPointManager hasNewRedPointArrive:JARedPointTypeCallPerson];
                }
            });
        }else if (toast.length && [toast isEqualToString:@"friendContent"]){       // 1.6 关注红点的通知
            
            [JARedPointManager hasNewRedPointArrive:JARedPointTypeHomePageFocus];
            
        }else if (toast.length && [toast isEqualToString:@"maintain"]) {    // 1.7 维护统治
            
            
            NSInteger type = [dic[@"maintainType"] integerValue];   // 1 的时候维护
            
            if (type == 0) {
                
            }else if (type == 1){
                // 当前时间
                NSDate *date = [NSDate date];
                
                // 服务器返回的时间
                NSTimeInterval maintainTime = [dic[@"maintainDate"] doubleValue] / 1000.0;
                NSTimeInterval maintainEndTime = [dic[@"maintainEndDate"] doubleValue] / 1000.0;
                
                // 开始维护的时间
                NSDate *maintainDate = [NSDate dateWithTimeIntervalSince1970:maintainTime];
                // 结束维护的时间
                NSDate *maintainEndDate = [NSDate dateWithTimeIntervalSince1970:maintainEndTime];
                
                //获取当前的日期
                NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
                fmt.dateFormat = @"yyyy-MM-dd HH:mm";
                // 开始和结束的字符串
                NSString *beginTime = [fmt stringFromDate:maintainDate];
                NSString *endTime = [fmt stringFromDate:maintainEndDate];
                
                // 展示的字符串
                NSString *str = [[endTime componentsSeparatedByString:@" "] lastObject];
                NSString *showTime = [NSString stringWithFormat:@"%@-%@",beginTime,str];
                
                
                if ([date isEarlierThanDate:maintainDate]) {
                    
                    [JAMaintainView show:showTime];
                }
                
            }
            
            // 获取通知时间
            //            NSTimeInterval time = [dic[@"time"] doubleValue];
            
        }else if (toast.length && [toast isEqualToString:@"moliMsg"]){
            [JARedPointManager hasNewRedPointArrive:JARedPointTypeAnnouncement];
        }
    }
}

//#pragma mark - 用户信息改变
//// 获取用户信息
//- (void)personalInfoChange
//{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    if(IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    dic[@"id"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    [[JAVoicePersonApi shareInstance] voice_personalInfoWithParas:dic success:^(NSDictionary *result) {
//        [JAUserInfo userInfo_saveUserInfo:result[@"user"]];
//    } failure:^(NSError *error) {
//
//    }];
//}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

// 移除通知
- (void)dealloc
{
    [JAChatMessageManager yx_removeNotiListenDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
