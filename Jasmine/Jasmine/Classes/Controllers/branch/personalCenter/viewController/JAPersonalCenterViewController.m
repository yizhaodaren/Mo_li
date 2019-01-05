//
//  JANewPersonalCenterViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalCenterViewController.h"
#import "JAPersonalNavBarView.h"
#import "JAPersonHeaderView.h"
#import "SPPageMenu.h"
#import "JAHorizontalPageView.h"
#import "JAContributeIntroduceView.h"

#import "JAPersonChatView.h"
#import "JAPersonMoliContributeView.h"
#import "JAChatMessageManager.h"
#import "JASessionViewController.h"
#import "JAEditInfoViewController.h"
#import "JAEditIconViewController.h"
#import "KNPhotoBrower.h"
#import "JARelationshipViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAMyContributeViewController.h"
#import "JAOtherPersonMedalController.h"
#import "JAMyMedalViewController.h"

#import "JAVoicePersonApi.h"
#import "JAVoiceCommonApi.h"
#import "JAReportResonModel.h"

#import "JANewPersonVoiceViewController.h"
#import "JANewPersonReplyViewController.h"
#import "LCActionSheet.h"

@interface JAPersonalCenterViewController ()<SPPageMenuDelegate,JAHorizontalPageViewDelegate,KNPhotoBrowerDelegate>

@property (nonatomic, weak) JAPersonalNavBarView *navBarView;   // 导航栏

@property (nonatomic, strong) JAPersonHeaderView *headerView;  // 个人中心的头部

@property (nonatomic, strong) JAHorizontalPageView *pageView;

@property (nonatomic, weak) SPPageMenu *titleView;

@property (nonatomic, weak) JAPersonMoliContributeView *contributeView;  // 底部茉莉投稿view

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) JAConsumer *userModel;

// 好友关系
@property (nonatomic, assign) JAUserRelation userRelation;
// 用户相册
@property (nonatomic, strong) NSArray *userPhotos;
// 是否有相册
@property (nonatomic, assign) BOOL hasPhoto;
// 是否是编辑个人资料发出的通知(不刷新pageView)
@property (nonatomic, assign) BOOL isNoti;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@property (nonatomic, strong) UIButton *backButton;

// 官方状态
@property (nonatomic, strong) NSString *otherOffic;
@property (nonatomic, strong) NSString *myOffic;

@property (nonatomic, strong) NSString *rule_contribute;

@property (nonatomic, assign) BOOL isNeedNoti;
@end

@implementation JAPersonalCenterViewController

- (BOOL)fd_prefersNavigationBarHidden {
    
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.isNeedNoti = NO;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

#pragma mark - 展示底部按钮
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.isNeedNoti = YES;
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    // 查询好友关系
    if (IS_LOGIN && ![self checkIdnetity]) {
        [self getFriendRetation];
    }
    
    [self personalcenter_refreshTitleCount];
    
    [self.navBarView PersonalNavBarView_changeInfoButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}
- (void)playStatus_refreshNav
{
    [self.navBarView PersonalNavBarView_changeInfoButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}

- (void)personalcenter_refreshTitleCount
{
    // 获取帖子、评论数量
    if ([self checkIdnetity]) {
        NSInteger storyCount = [[JAUserInfo userInfo_getUserImfoWithKey:User_storyCount] integerValue];
        if (storyCount<0) {
            storyCount = 0;
        }
        NSInteger commentCount = [[JAUserInfo userInfo_getUserImfoWithKey:User_commentCount] integerValue];
        if (commentCount<0) {
            commentCount = 0;
        }
        NSString *title1 = [NSString stringWithFormat:@"主帖 %zd",storyCount];
        NSString *title2 = [NSString stringWithFormat:@"回复 %zd",commentCount];
        [self.titleView setTitle:title1 forItemAtIndex:0];
        [self.titleView setTitle:title2 forItemAtIndex:1];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isNeedNoti = YES;
    self.userId = self.personalModel.consumerId.length ? self.personalModel.consumerId : self.personalModel.userId;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshBottomRelation) name:LOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUserInfo) name:EDITUSERINFOSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshNav) name:@"STKAudioPlayer_status" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personalcenter_refreshTitleCount) name:@"owner_deleteComment" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(personalcenter_refreshTitleCount) name:@"owner_deleteVoice" object:nil];
    
    if ([self checkMoliDianTai]) {
        // 获取规则
        [self getContributeRule];
    }
    // 获取用户信息
    [self getPersonInfo];
}

#pragma mark - 获取投稿规则
- (void)getContributeRule
{
    self.rule_contribute = @"1. 写信给茉莉君需要有完整的故事情节描述与明确的问题才可以得到茉莉君回复。\n2. 故事必须大于60秒，茉莉君才能收到你的投稿。";
    [[JAVoiceCommonApi shareInstance] voice_getContrbuteRule:nil success:^(NSDictionary *result) {
        self.rule_contribute = result[@"contribute_content"];
    } failure:^(NSError *error) {
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (_contributeView) {
        _contributeView.y = self.view.height - _contributeView.height;
    }
}

#pragma mark - JAHorizontalPageView懒加载
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height) delegate:self];
        _pageView.needHeadGestures = YES;
        [self.view insertSubview:_pageView belowSubview:_navBarView];
//        [self.view addSubview:_pageView];
        [self.view insertSubview:_pageView belowSubview:_contributeView];
    }
    return _pageView;
}

- (JAPersonalNavBarView *)navBarView
{
    if (_navBarView == nil) {
        JAPersonalNavBarView *navBarView = [[JAPersonalNavBarView alloc] init];
        _navBarView = navBarView;
        navBarView.backgroundColor = [UIColor clearColor];
        [navBarView.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [navBarView.rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        [navBarView.followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        navBarView.hidden = YES;
        if ([self checkMoliDianTai] || [self checkIdnetity]) {
            navBarView.hiddenRight = YES;
            navBarView.hiddenFollow = YES;
        }
        [self.view addSubview:navBarView];
    }
    return _navBarView;
}

- (JAPersonMoliContributeView *)contributeView
{
    if (_contributeView == nil) {
        JAPersonMoliContributeView *contributeView = [[JAPersonMoliContributeView alloc] init];
        contributeView.backgroundColor = HEX_COLOR(0x141414);
        contributeView.width = JA_SCREEN_WIDTH;
        
        CGFloat bottomM = 0;
        if (iPhoneX) {
            bottomM = 34;
        }
        contributeView.height = 44 + bottomM;
        contributeView.y = self.view.height - contributeView.height;
        
        _contributeView = contributeView;
        [contributeView.myContributeButton addTarget:self action:@selector(goToMyContribute) forControlEvents:UIControlEventTouchUpInside];
        [contributeView.contributeButton addTarget:self action:@selector(goToContribute:) forControlEvents:UIControlEventTouchUpInside];
        contributeView.hidden = YES;
        [self.view addSubview:contributeView];
    }
    return _contributeView;
}

#pragma mark - JAHorizontalPageView代理
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return 2;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if (index == 0) {
        JANewPersonVoiceViewController *vc = [[JANewPersonVoiceViewController alloc] init];
        vc.userId = self.userId;
        vc.sex = self.userModel.sex.integerValue;
        vc.enterType = 0;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }else{
        
        JANewPersonReplyViewController *vc = [[JANewPersonReplyViewController alloc] init];
        vc.userId = self.userId;
        vc.sex = self.userModel.sex.integerValue;
        vc.enterType = 0;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }
    
}

#pragma mark - KNPhotoBrowerDelegate
#pragma mark - 删除头像
- (void)photoBrowerRightOperationDeleteImageSuccessWithAbsoluteIndex:(NSInteger)index
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"managerUserId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"userId"] = self.userId;
    
    [[JAVoicePersonApi shareInstance] voice_adminUpdateIconWithParas:dic success:^(NSDictionary *result) {
        if (self.userModel) {
            self.userModel.image = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png";
        }else{
            self.personalModel.image = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png";
        }
        self.headerView.personModel = self.userModel;
    } failure:^(NSError *error) {
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    JAPersonHeaderView *headerView = [[JAPersonHeaderView alloc] init];
    _headerView = headerView;
    @WeakObj(self);
    headerView.clickPersomalIconImageBlock = ^(UIImage *image, UIImageView *imageView) {  // 编辑头像或者查看大图
        @StrongObj(self);
        if ([self checkIdnetity]) {
            // 跳转编辑头像控制器
            JAEditIconViewController *vc = [[JAEditIconViewController alloc] init];
            vc.image = image;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            
            if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
                
                NSMutableArray *arrM = [NSMutableArray array];
                KNPhotoItems *items = [[KNPhotoItems alloc] init];
                
                items.sourceImage = image;
                items.sourceView = imageView;
                
                [arrM addObject:items];
                // 查看大图
                KNPhotoBrower *photoBrower = [[KNPhotoBrower alloc] init];
                photoBrower.actionSheetArr =  [@[@"删除",@"保存"] copy];
                [photoBrower setIsNeedRightTopBtn:YES];
                [photoBrower setIsNeedPictureLongPress:YES];
                photoBrower.itemsArr = [arrM copy];
                photoBrower.currentIndex = 0;
                [photoBrower present];
                [photoBrower setDelegate:self];
                
            }else{
                
                NSMutableArray *arrM = [NSMutableArray array];
                KNPhotoItems *items = [[KNPhotoItems alloc] init];
                
                items.sourceImage = image;
                items.sourceView = imageView;
                
                [arrM addObject:items];
                // 查看大图
                KNPhotoBrower *photoBrower = [[KNPhotoBrower alloc] init];
                [photoBrower setIsNeedRightTopBtn:NO];
                [photoBrower setIsNeedPictureLongPress:NO];
                photoBrower.itemsArr = [arrM copy];
                photoBrower.currentIndex = 0;
                [photoBrower present];
            }
        }
    };
    headerView.clickPersomalFocusAndFansBlock = ^{   // 关注粉丝列表
        @StrongObj(self);
        JARelationshipViewController *vc = [JARelationshipViewController new];
        vc.isOtherRelation = YES;
        vc.userId = self.userId;
        [self.navigationController pushViewController:vc animated:YES];

    };
    
    headerView.clickPersonalEditAction = ^{   // 编辑个人资料
        @StrongObj(self);
        // 点击的编辑
        JAEditInfoViewController *vc = [[JAEditInfoViewController alloc] init];
        vc.model = self.userModel;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    headerView.clickPersonalFollowAction = ^(UIButton *btn) {   // 关注某人
        @StrongObj(self);
        [self focusPerson:btn];
    };
    
    headerView.clickPersonalContributeAction = ^{  // 投稿须知
        @StrongObj(self);
        [JAContributeIntroduceView showContributeViewWithLoopCount:0 text:self.rule_contribute];
    };
    
    headerView.clickPersonalMessageAction = ^{   // 私信
        @StrongObj(self);
        [self goToChat];
    };
    
    headerView.clickPersonalMedalAction = ^{  // 勋章
        @StrongObj(self);
        if ([self checkIdnetity]) {
            JAMyMedalViewController *vc = [[JAMyMedalViewController alloc] init];
            vc.imageUrl = self.userModel.image;
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            JAOtherPersonMedalController *vc = [[JAOtherPersonMedalController alloc] init];
            vc.userid = self.userId;
            vc.imageUrl = self.userModel.image;
            [self.navigationController pushViewController:vc animated:YES];
        }
    };
    
    CGFloat pageY = 0;
    CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 36, MAXFLOAT);
    NSString *text = self.userModel.introduce.length ? self.userModel.introduce:@"你还没有个性签名";
    CGFloat toptextH = [text boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_LIGHT_FONT(13)} context:nil].size.height;
    CGFloat topH = 228 + 20 + toptextH;
    CGFloat relationH = [self checkMoliDianTai] ? 0 : 50;
    CGFloat medalH = self.userModel.medalList.count ? 50:0; // 是否有勋章
    CGFloat photoH = self.hasPhoto ? 148 : 0;
    pageY = topH + relationH + medalH + photoH;
    headerView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, pageY + 40);
    // 分页tab
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, pageY, JA_SCREEN_WIDTH, 41) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pageMenu.delegate = self;
    });
    pageMenu.itemTitleFont = JA_REGULAR_FONT(17);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    self.titleView = pageMenu;
    [self.headerView addSubview:pageMenu];
    self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    
    headerView.personPhoneArray = self.userPhotos;
    headerView.hasPhoto = self.hasPhoto;
    
    if (self.userModel) {
        headerView.personModel = self.userModel;
    }else{
        headerView.personModel = self.personalModel;
    }
    
    headerView.relationType = self.userRelation;
    
    if ([self checkMoliDianTai]) {
        headerView.locationButton.hidden = YES;
    }else{
        headerView.locationButton.hidden = NO;
    }
    
    // 导航栏
    self.navBarView.hidden = NO;
    if (self.userModel) {
        self.navBarView.name = self.userModel.name;
    }else{
        self.navBarView.name = self.personalModel.name;
    }
    self.navBarView.hiddenOffic = self.otherOffic.integerValue == 1 ? NO : YES;
    self.navBarView.isMe = [self checkIdnetity];
    
    NSInteger storyCount = [self.userModel.storyCount integerValue];
    if (storyCount<0) {
        storyCount = 0;
    }
    NSInteger commentCount = [self.userModel.commentCount integerValue];
    if (commentCount<0) {
        commentCount = 0;
    }
    NSInteger collentCount = [self.userModel.collentCount integerValue];
    if (collentCount<0) {
        collentCount = 0;
    }
    NSString *title1 = [NSString stringWithFormat:@"主帖 %zd",storyCount];
    NSString *title2 = [NSString stringWithFormat:@"回复 %zd",commentCount];
 
    self.titleArray = @[title1,title2];
    
    [self.titleView setItems:self.titleArray selectedItemIndex:0];

    // 底部
    if ([self checkIdnetity]) {
    }else if ([self checkMoliDianTai]){
        self.contributeView.hidden = NO;
    }
    
    return headerView;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    CGFloat pageY = 0;
    CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 36, MAXFLOAT);
    NSString *text = self.userModel.introduce.length ? self.userModel.introduce:@"你还没有个性签名";
    CGFloat toptextH = [text boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_LIGHT_FONT(13)} context:nil].size.height;
    CGFloat topH = 228 + 20 + toptextH;
    CGFloat relationH = [self checkMoliDianTai] ? 0 : 50;
    CGFloat medalH = self.userModel.medalList.count ? 50:0; // 是否有勋章
    CGFloat photoH = self.hasPhoto ? 148 : 0;
    pageY = topH + relationH + medalH + photoH;
    
    return pageY + 40;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView   // 控制在什么地方悬停
{
    return ((iPhoneX) ? 128 : 104);
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{
    self.headerView.topOffY = offset;
    
    // 计算导航条的隐藏
    if (offset > 0) {
        self.navBarView.alphaValue = (offset) / (250 - 64);
        
        if (self.navBarView.alphaValue >= 1) {
            self.navBarView.alphaValue = 1.0;
        }
    }else{
        self.navBarView.alphaValue = 0.0;
    }
    if (self.isNeedNoti) {
        if (self.navBarView.alphaValue >= 1) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
        } else {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
        }
    }
}

#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self.pageView scrollToIndex:toIndex];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 网络请求
// 登录成功刷新
- (void)refreshBottomRelation
{
    // 查询好友关系
    if (![self checkIdnetity]) {
        [self getFriendRetation];
        if ([self checkMoliDianTai]) {
            self.contributeView.hidden = NO;
        }
    }
}

#pragma mark - 编辑个人资料
// 个人信息编辑
- (void)changeUserInfo
{
    self.isNoti = YES;
    [self getPersonInfo];
}

#pragma mark - 获取个人信息
// 获取用户信息
- (void)getPersonInfo
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    if (!self.isNoti) {
        self.backButton.hidden = NO;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if(IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = self.userId;
    
    [[JAVoicePersonApi shareInstance] voice_personalInfoWithParas:dic success:^(NSDictionary *result) {
        
        self.userModel = [JAConsumer mj_objectWithKeyValues:result[@"user"]];
        
        // 官方信息
        self.otherOffic = self.userModel.achievementId;
        self.myOffic = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_AchievementId]];
        
        // 如果是自己就保存用户数据
        if ([self checkIdnetity]) {
            // 保存用户信息
            [JAUserInfo userInfo_saveUserInfo:result[@"user"]];
        }
        // 获取用户相册
        [self getphotoInfo];
    } failure:^(NSError *error) {
        // 获取用户相册
        [self getphotoInfo];
    }];
}

#pragma mark - 获取个人相册
// 获取用户相册
- (void)getphotoInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = self.userId;
    [[JAVoicePersonApi shareInstance] voice_personalPhotoWithParas:dic success:^(NSDictionary *result) {
        if (_backButton) {
            [_backButton removeFromSuperview];
        }
        [self.currentProgressHUD hideAnimated:NO];
        self.userPhotos = result[@"arraylist"];
        // 是否有相册
        if ([self checkIdnetity]) {
            self.hasPhoto = YES;
        }else{
            
            NSDictionary *dic =  self.userPhotos.firstObject;
            NSString *imageStr = dic[@"image"];
            self.hasPhoto = imageStr.length;
        }
        
        // 刷新页面
        if (!self.isNoti) {
            
            [self.pageView reloadPage];
        }else{
            self.headerView.personPhoneArray = self.userPhotos;
            self.headerView.hasPhoto = self.hasPhoto;
            
            if (self.userModel) {
                self.headerView.personModel = self.userModel;
            }else{
                self.headerView.personModel = self.personalModel;
            }
            
            self.navBarView.hidden = NO;
            if (self.userModel) {
                self.navBarView.name = self.userModel.name;
            }else{
                self.navBarView.name = self.personalModel.name;
            }
            self.navBarView.hiddenOffic = self.otherOffic.integerValue == 1 ? NO : YES;
            self.navBarView.isMe = [self checkIdnetity];
        }
        
    } failure:^(NSError *error) {
        if (_backButton) {
            [_backButton removeFromSuperview];
        }
        [self.currentProgressHUD hideAnimated:NO];
        if ([self checkIdnetity]) {
            self.hasPhoto = YES;
        }else{
            self.hasPhoto = NO;
        }
        // 刷新页面
        if (!self.isNoti) {
            [self.pageView reloadPage];
        }else{
            self.headerView.personPhoneArray = self.userPhotos;
            self.headerView.hasPhoto = self.hasPhoto;
            
            if (self.userModel) {
                self.headerView.personModel = self.userModel;
            }else{
                self.headerView.personModel = self.personalModel;
            }
            
            self.navBarView.hidden = NO;
            if (self.userModel) {
                self.navBarView.name = self.userModel.name;
            }else{
                self.navBarView.name = self.personalModel.name;
            }
            self.navBarView.hiddenOffic = self.otherOffic.integerValue == 1 ? NO : YES;
            self.navBarView.isMe = [self checkIdnetity];
        }
    }];
}

#pragma mark - 获取用户的好友关系
// 获取用户好友关系
- (void)getFriendRetation
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = self.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_personalRelationParas:dic success:^(NSDictionary *result) {
        if (result) {
            NSString *type = result[@"friend"][@"friendType"];
            if ([type integerValue] == 0) {
                self.userRelation = JAUserRelationFocus;
            }else if([type integerValue] == 1){
                self.userRelation = JAUserRelationFriend;
            }else if(type.integerValue == 2){
                self.userRelation = JAUserRelationNone;
            }else{
                self.userRelation = JAUserRelationBlack;
            }
            self.headerView.relationType = self.userRelation;
        }else{
            self.headerView.relationType = JAUserRelationNone;
        }
    } failure:^(NSError *error) {
    }];
}

#pragma mark - 按钮的点击
#pragma mark - 导航条关注按钮
- (void)followButtonClick:(UIButton *)btn
{
    [self focusPerson:self.headerView.topInfoView.focusButton];
//    btn.hidden = YES;
}

- (void)setUserRelation:(JAUserRelation)userRelation
{
    _userRelation = userRelation;
    if (self.userRelation == 0 || self.userRelation == 1) {
        _navBarView.hiddenFollow = YES;
    }else{
        _navBarView.hiddenFollow = NO;
    }
}

#pragma mark - 返回按钮
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 去投稿
- (void)goToContribute:(UIButton *)btn
{
    JAVoiceRecordViewController *vc = [[JAVoiceRecordViewController alloc] init];
    vc.fromType = 1;
    vc.noticeString = self.rule_contribute;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 我的投稿
- (void)goToMyContribute
{
    JAMyContributeViewController *vc = [[JAMyContributeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 聊天
- (void)goToChat{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    NIMSession *session = [JAChatMessageManager yx_getChatSessionWithUserId:self.userId];
    
    [JAYXMessageManager app_getChatLimitsWithYXuserId:session.sessionId finish:^(JAChatLimitsType code) {
        JASessionViewController *vc = [[JASessionViewController alloc] initWithSession:session];
        vc.myOffic = self.myOffic;
        vc.otherOffic = self.otherOffic;
        [self.navigationController pushViewController:vc animated:YES];
    }];
}

#pragma mark - 右边按钮点击事件
- (void)rightClick
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    if ([self checkMoliDianTai]) {
        return;
    }
    if ([self checkIdnetity]) {
        // 点击的编辑
        JAEditInfoViewController *vc = [[JAEditInfoViewController alloc] init];
        vc.model = self.userModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        [self popWindow_userAction];
    }
}

- (void)popWindow_userAction
{
    // 判断用户身份
    NSString *power = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    BOOL isPower = power.integerValue == JAPOWER ? YES : NO;
    NSString *status = self.userModel.status;
    
    NSMutableArray *titleButtons = [NSMutableArray array];
    
    [titleButtons addObject:@"举报"];
    [titleButtons addObject:self.userRelation == JAUserRelationBlack ? @"取消拉黑":@"拉黑"];
    
    if (isPower) {
        [titleButtons addObject:status.integerValue == 2 ? @"取消禁言":@"禁言"];
        [titleButtons addObject:@"封停用户"];
    }
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:titleButtons redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex >= titleButtons.count) {
            return;
        }
        NSString *title = titleButtons[buttonIndex];
        if ([title isEqualToString:@"举报"]) {
            // 举报个人
            [self gagActionWith:nil type:@"report"];
        }else if ([title isEqualToString:@"拉黑"]){
            [self middleTipView];
        }else if ([title isEqualToString:@"取消拉黑"]){
            [self deleteBlackAction];
        }else if ([title isEqualToString:@"禁言"]){
            [self banactionUserAction];
        }else if ([title isEqualToString:@"取消禁言"]){
            [self cancleBanactionUserAction];
        }else if ([title isEqualToString:@"封停用户"]){
            [self banUserAction];
        }
    }];
    [actionS show];
}

#pragma mark - 关注用户
- (void)focusPerson:(UIButton *)btn    // 关注某人
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    if (self.userRelation == JAUserRelationBlack) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"关注后，对方将从你的黑名单中移除" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            btn.userInteractionEnabled = NO;
            [self focusUserActionWithButton:btn];
        }];
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    btn.userInteractionEnabled = NO;
    [self focusUserActionWithButton:btn];
}

#pragma mark - 拉黑用户/取消拉黑/取消关注/关注
- (void)refreshUserRelationWithNewType:(NSString *)type
{
    if ([type integerValue] == 0) {
        self.userRelation = JAUserRelationFocus;
    }else if([type integerValue] == 1){
        self.userRelation = JAUserRelationFriend;
    }else if(type.integerValue == 2){
        self.userRelation = JAUserRelationNone;
        
    }else if (type.integerValue == 3){
        self.userRelation = JAUserRelationBlack;
    }
    
    self.headerView.relationType = self.userRelation;
    [self.headerView.topInfoView setNeedsLayout];
    [self.headerView.topInfoView layoutIfNeeded];
}
// 拉黑提示用户
- (void)middleTipView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认将该用户加入黑名单？" message:@"拉黑后，对方将不能关注你、给你发消息、回复你实名发布的内容、邀请你评论等，并自动从你的粉丝和关注列表移除" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = self.userId;
        
        [[JAVoicePersonApi shareInstance] voice_personalAddBlackUserWithParas:dic success:^(NSDictionary *result) {
            
            if (self.userRelation == JAUserRelationFocus || self.userRelation == JAUserRelationFriend) {
                // 数量要减1；
                NSInteger focus = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount].integerValue;
                [JAUserInfo userInfo_updataUserInfoWithKey:User_userConsernCount value:[NSString stringWithFormat:@"%ld",(focus - 1 > 0 ? (focus - 1) : 0)]];
            }
            
            [MBProgressHUD showMessageAMoment:@"拉黑成功"];
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            [self refreshUserRelationWithNewType:type];
        } failure:^(NSError *error) {
            
            [self.view ja_makeToast:error.localizedDescription];
        }];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}
// 取消拉黑
- (void)deleteBlackAction
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"concernId"] = self.userId;
    
    [[JAVoicePersonApi shareInstance] voice_personalDeleteBlackUserWithParas:dic success:^(NSDictionary *result) {
        [self.view ja_makeToast:@"取消成功"];
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        [self refreshUserRelationWithNewType:type];
    } failure:^(NSError *error) {
        
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

// 关注某人
- (void)focusUserActionWithButton:(UIButton *)btn
{
    if (btn.selected) {
        [self cancleFocusUser:btn];  // 取消关注
        return;
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = self.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = self.userId;
    if (self.userModel) {
        senDic[JA_Property_PostName] = self.userModel.name;
    }else{
        senDic[JA_Property_PostName] = self.personalModel.name;
    }
    senDic[JA_Property_FollowMethod] = @"个人主页";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        [MBProgressHUD showMessageAMoment:@"关注成功"];
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        [self refreshUserRelationWithNewType:type];
        
        btn.userInteractionEnabled = YES;
        btn.selected = YES;
        self.navBarView.followButton.hidden = YES;
        [self.headerView.topInfoView setNeedsLayout];
        [self.headerView.topInfoView layoutIfNeeded];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = self.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

// 取消关注某人
- (void)cancleFocusUser:(UIButton *)btn
{
    // 取消关注
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"concernId"] = self.userId;
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"取消关注";
    senDic[JA_Property_PostId] = self.userId;
    if (self.userModel) {
        senDic[JA_Property_PostName] = self.userModel.name;
    }else{
        senDic[JA_Property_PostName] = self.personalModel.name;
    }
    senDic[JA_Property_FollowMethod] = @"个人主页";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    btn.userInteractionEnabled = NO;
    [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
        [MBProgressHUD showMessageAMoment:@"取消关注"];
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        [self refreshUserRelationWithNewType:type];
        btn.selected = NO;
        [self.headerView.topInfoView setNeedsLayout];
        [self.headerView.topInfoView layoutIfNeeded];
        btn.userInteractionEnabled = YES;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = self.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
        
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

#pragma mark - 封停用户/禁言/取消禁言
// 封停用户
- (void)banUserAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要封停用户？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"kickUserId"] = self.userId;
        dic[@"dataType"] = @"freeze";
        [[JAVoiceCommonApi shareInstance] voice_userBanWithParas:dic success:^(NSDictionary *result) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"封停成功"];
        } failure:^(NSError *error) {
            [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
        }];
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 取消禁言
- (void)cancleBanactionUserAction
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"kickUserId"] = self.userId;
    dic[@"dataType"] = @"nogag";
    [[JAVoiceCommonApi shareInstance] voice_userBanWithParas:dic success:^(NSDictionary *result) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"取消禁言成功"];
    } failure:^(NSError *error) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
}

// 禁言
- (void)banactionUserAction
{
    NSMutableArray *titleButtons = [NSMutableArray array];
    [titleButtons addObject:@"1天"];
    [titleButtons addObject:@"3天"];
    [titleButtons addObject:@"7天"];
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:titleButtons redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex == 0) {
            [self gagActionWith:@"1" type:@"banaction"];
        }else if (buttonIndex == 1){
            [self gagActionWith:@"3" type:@"banaction"];
        }else if (buttonIndex == 2){
            [self gagActionWith:@"7" type:@"banaction"];
        }
    }];
    [actionS show];
}

// 选择禁言原因
- (void)gagActionWith:(NSString *)time type:(NSString *)type {
    
    NSString *alertString = nil;
    if ([type isEqualToString:@"report"]) {
        alertString = @"选择举报原因";
    }else{
        alertString = @"选择禁言原因";
    }
    NSMutableArray *titleArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].reportArray.count; i++) {
        JAReportResonModel *model = [JAConfigManager shareInstance].reportArray[i];
        [titleArray addObject:model.content];
    }
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:alertString buttonTitles:titleArray redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex >= titleArray.count) {
            return;
        }
        NSString *reason = [JAConfigManager shareInstance].reportArray[buttonIndex];
        if ([type isEqualToString:@"report"]) {
            [self reportUserWithReason:reason];
        }else{
            [self gagNetWorkWithTime:time reason:reason];
        }
    }];
    [actionS show];
}
// 禁言请求
- (void)gagNetWorkWithTime:(NSString *)time reason:(NSString *)reason {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"kickUserId"] = self.userId;
    dic[@"dataType"] = @"gag";
    dic[@"dayNum"] = time;
    dic[@"digest"] = reason;
    [[JAVoiceCommonApi shareInstance] voice_userBanWithParas:dic success:^(NSDictionary *result) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"禁言成功"];
    } failure:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

// 举报请求
- (void)reportUserWithReason:(NSString *)reason
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"user";
    dic[@"reportTypeId"] = self.userId;
    dic[@"content"] = reason;
    [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
        
        [self.view ja_makeToast:@"举报成功"];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 自造返回按钮
- (UIButton *)backButton
{
    if (_backButton == nil) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateNormal];
        _backButton.width = 45;
        _backButton.height = 60;
        _backButton.y = JA_StatusBarHeight;
        [_backButton addTarget:self action:@selector(backFront) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_backButton];
    }
    return _backButton;
}

- (void)backFront
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 是否是自己/是否是茉莉电台、茉莉君
- (BOOL)checkIdnetity
{
    // 获取本地id
    NSString *localID = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if ([localID isEqualToString:self.userId]) {
        return YES;
    }else{
        return NO;
    }
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
