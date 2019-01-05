//
//  JAPacketViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/19.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPacketViewController.h"
#import "JAPacketInviteFriendViewController.h"
#import "JAPackMyInviteViewController.h"
#import "JAOpenInvitePacketViewController.h"
#import "JAInvitePacketView.h"
#import "JABanner.h"
#import "JAVoiceCommonApi.h"
#import "JAWebViewController.h"
#import "NSDate+Extension.h"
#import "SPPageMenu.h"

@interface JAPacketViewController ()<SPPageMenuDelegate>

@property (nonatomic, strong) JAPacketInviteFriendViewController *inviteFriendVC;
@property (nonatomic, strong) JAPackMyInviteViewController *myInviteVC;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, weak) UIView *bannerView;
@property (nonatomic, weak) UIImageView *bannerImageView;

@property (nonatomic, weak) SPPageMenu *titleView;

@property (nonatomic, strong) JABanner *bannerModel;

@property (nonatomic, strong) NSDictionary *dic;  // 下个界面获取的需要分享的链接
@end

@implementation JAPacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"邀请收徒"];
    
    [self setupUI];
    
    NSString *inviteCode = [JAUserInfo userInfo_getUserImfoWithKey:User_InviteUuid];
    // 计算时间
    NSDate *nowT = [NSDate date];
    NSString *creatTime = [JAUserInfo userInfo_getUserImfoWithKey:User_CreatTime];
    NSDate *frontT = [NSDate dateWithTimeIntervalSince1970:creatTime.floatValue / 1000.0];
    NSInteger day = [frontT distanceInDaysToDate:nowT];
    if (inviteCode.length || day > 3) {
        [self setNavRightTitle:@"" color:HEX_COLOR(0xF6A623)];
    }else{
        [self setNavRightTitle:@"输入邀请码" color:HEX_COLOR(0xF6A623)];
    }
    // 获取banner
    [self getActiveBanner];
}

- (void)setupUI
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.bounces = NO;
    [self.view addSubview:scrollView];
    
    self.bannerView.hidden = YES;
    
    NSArray *titles = @[@"邀请徒弟",@"我的徒弟"];
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 43) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
//    [pageMenu setItems:titles selectedItemIndex:0];
    pageMenu.delegate = self;
    pageMenu.itemTitleFont = JA_REGULAR_FONT(15);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.bridgeScrollView = scrollView;
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    [self.view addSubview:pageMenu];
    self.titleView = pageMenu;
    
    [self addChildViewController:self.inviteFriendVC];
    [self addChildViewController:self.myInviteVC];
    
    [self.scrollView addSubview:self.inviteFriendVC.view];
    [self.scrollView addSubview:self.myInviteVC.view];
    
    if (self.type == 1) {
        [pageMenu setItems:titles selectedItemIndex:1];
    }else{
        [pageMenu setItems:titles selectedItemIndex:0];
    }
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.titleView.width = JA_SCREEN_WIDTH;
    self.titleView.height = 43;
    self.titleView.y = self.bannerView.hidden ? 0 : self.bannerView.bottom;
    
    self.scrollView.width = JA_SCREEN_WIDTH;
    self.scrollView.height = self.view.height - self.titleView.bottom;
    self.scrollView.contentSize = CGSizeMake(2 * JA_SCREEN_WIDTH, 0);
    self.scrollView.y = self.titleView.bottom;
    
    self.inviteFriendVC.view.width = self.scrollView.width;
    self.inviteFriendVC.view.height = self.scrollView.height;
    
    self.myInviteVC.view.width = self.scrollView.width;
    self.myInviteVC.view.height = self.scrollView.height;
    self.myInviteVC.view.x = self.scrollView.width;
    
    if (self.type == 1) {
        [self.scrollView setContentOffset:CGPointMake(JA_SCREEN_WIDTH, 0) animated:NO];
    }
}

// 获取活动banner
- (void)getActiveBanner
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @"3";
    params[@"platform"] = @"IOS";
    
    [[JAVoiceCommonApi shareInstance] voice_getBanner:params success:^(NSDictionary *result) {
        
        NSArray *arr = [JABanner mj_objectArrayWithKeyValuesArray:result[@"advertisementList"]];
        
        if (arr.count) {
            JABanner *model = arr.firstObject;
            self.bannerModel = model;
            self.bannerView.hidden = NO;
            [self.bannerImageView ja_setImageWithURLStr:model.image];
        }else{
            
            self.bannerView.hidden = YES;
        }
        
        [self.view layoutIfNeeded];
        [self.view setNeedsLayout];
       
    } failure:^(NSError *error) {
        self.bannerView.hidden = YES;
        
        [self.view layoutIfNeeded];
        [self.view setNeedsLayout];
//        self.layoutY = 0;
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    NSString *inviteCode = [JAUserInfo userInfo_getUserImfoWithKey:User_InviteUuid];
    // 计算时间
    NSDate *nowT = [NSDate date];
    NSString *creatTime = [JAUserInfo userInfo_getUserImfoWithKey:User_CreatTime];
    NSDate *frontT = [NSDate dateWithTimeIntervalSince1970:creatTime.floatValue / 1000.0];
    
    NSInteger day = [frontT distanceInDaysToDate:nowT];
    
    if (inviteCode.length || day > 3) {
        
        [self setNavRightTitle:@"" color:HEX_COLOR(0xF6A623)];
    }else{
        [self setNavRightTitle:@"输入邀请码" color:HEX_COLOR(0xF6A623)];
    }
}

- (JAPacketInviteFriendViewController *)inviteFriendVC
{
    if (_inviteFriendVC == nil) {
     
        _inviteFriendVC = [JAPacketInviteFriendViewController new];
        _inviteFriendVC.titleView = self.titleView;
        @WeakObj(self);
        _inviteFriendVC.callFriendBlock = ^{
            @StrongObj(self);
            [self scrollCallFriend];
            
        };
    }
    
    return _inviteFriendVC;
}

- (JAPackMyInviteViewController *)myInviteVC
{
    if (_myInviteVC == nil) {
        
        _myInviteVC = [JAPackMyInviteViewController new];
        _myInviteVC.currentViewPage = self.callFriend;
        _myInviteVC.titleView = self.titleView;
    }
    
    return _myInviteVC;
}

// 跳转召唤好友
- (void)scrollCallFriend
{
    self.myInviteVC.callFriendType = 1;
    [self.scrollView setContentOffset:CGPointMake(JA_SCREEN_WIDTH, 0) animated:NO];
    [self.titleView setSelectedItemIndex:1];
}

- (void)actionRight
{
    NSString *inviteCode = [JAUserInfo userInfo_getUserImfoWithKey:User_InviteUuid];
    
    // 计算时间
    NSDate *nowT = [NSDate date];
    NSString *creatTime = [JAUserInfo userInfo_getUserImfoWithKey:User_CreatTime];
    NSDate *frontT = [NSDate dateWithTimeIntervalSince1970:creatTime.floatValue / 1000.0];
    
    NSInteger day = [frontT distanceInDaysToDate:nowT];
    
    if (inviteCode.length || day > 3) {
        
        [self setNavRightTitle:@"" color:HEX_COLOR(0xF6A623)];
    }else{
        
        [self sensorsAnalyticsInviteFriend:@"邀请码"];
        
        JAOpenInvitePacketViewController *vc = [[JAOpenInvitePacketViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (UIView *)bannerView
{
    if (_bannerView == nil) {
        
        UIView *bannerView = [[UIView alloc] init];
        _bannerView = bannerView;
        bannerView.width = JA_SCREEN_WIDTH;
        bannerView.height = WIDTH_ADAPTER(50);
        [self.view addSubview:bannerView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        _bannerImageView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.frame = bannerView.bounds;
        [bannerView addSubview:imageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoActive)];
        [imageView addGestureRecognizer:tap];
    }
    
    return _bannerView;
}

// 顶部活动页
- (void)gotoActive
{
    JAWebViewController *vc = [[JAWebViewController alloc] init];
//    vc.urlString = [NSString stringWithFormat:@"%@?id=%@",self.bannerModel.url,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    if ([self.bannerModel.url isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
        vc.urlString = [NSString stringWithFormat:@"%@?id=%@",self.bannerModel.url,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
    }else{
        vc.urlString = self.bannerModel.url;
    }
    vc.enterType = @"邀请页面banner";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - SPPageMenu
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.scrollView setContentOffset:CGPointMake((toIndex * 1.0 * JA_SCREEN_WIDTH), 0) animated:YES];
   
}

- (void)sensorsAnalyticsInviteFriend:(NSString *)mothod
{
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_InvitationMethod] = mothod;
    [JASensorsAnalyticsManager sensorsAnalytics_inviteFriend:senDic];
}

@end
