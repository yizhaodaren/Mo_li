//
//  JAPlatformLoginViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPlatformLoginViewController.h"
#import "JALoginManager.h"
#import "JAPlatformBindingPhoneViewController.h"

@interface JAPlatformLoginViewController ()

@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, strong) UIButton *quickButton;
@property (nonatomic, strong) UIButton *otherButton;

@end

@implementation JAPlatformLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupPlatformLoginUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:PlatformLoginSuccess object:nil];
    
    // 添加监听，被解绑了
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindPhone:) name:NEED_Regist object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
}

// 被解绑后，三方绑定手机
- (void)bindPhone:(NSNotification *)noti
{
    JAPlatformBindingPhoneViewController *vc = [[JAPlatformBindingPhoneViewController alloc] init];
    vc.platformInfo = noti.userInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 设置UI
- (void)setupPlatformLoginUI
{
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    
    // 设置左边的按钮
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"branch_login_close"] highlightImage:[UIImage imageNamed:@"branch_login_close"]];
    [self.view addSubview:self.topImageView];
    
    self.topImageView = [[UIImageView alloc] init];
    [self.view addSubview:self.topImageView];
    
    self.introduceLabel = [[UILabel alloc] init];
    self.introduceLabel.textColor = HEX_COLOR(JA_BlackTitle);
    self.introduceLabel.font = JA_REGULAR_FONT(17);
    self.introduceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.introduceLabel];
    
    if (self.loginType == JARecordLoginTypeQqLogin) {
        self.topImageView.image = [UIImage imageNamed:@"record_login_qq"];
        self.introduceLabel.text = @"你已授权QQ登录";
    }else if (self.loginType == JARecordLoginTypeWbLogin){
        self.topImageView.image = [UIImage imageNamed:@"record_login_wb"];
        self.introduceLabel.text = @"你已授权微博登录";
    }else if (self.loginType == JARecordLoginTypeWxLogin){
        self.topImageView.image = [UIImage imageNamed:@"record_login_wx"];
        self.introduceLabel.text = @"你已授权微信登录";
    }
    
    self.quickButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.quickButton setTitle:@"一键登录" forState:UIControlStateNormal];
    self.quickButton.backgroundColor =HEX_COLOR(0x6BD379);
    self.quickButton.titleLabel.font = JA_MEDIUM_FONT(16);
    [self.quickButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    [self.quickButton addTarget:self action:@selector(clickQuickLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.quickButton];
    
    self.otherButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.otherButton setTitle:@"其他方式登录" forState:UIControlStateNormal];
    self.otherButton.backgroundColor =HEX_COLOR(0xE2E2E2);
    self.otherButton.titleLabel.font = JA_REGULAR_FONT(15);
    [self.otherButton setTitleColor:HEX_COLOR(JA_Three_Title) forState:UIControlStateNormal];
    [self.otherButton addTarget:self action:@selector(clickOtherLogin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.otherButton];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.topImageView.width = 80;
    self.topImageView.height = 80;
    self.topImageView.centerX = JA_SCREEN_WIDTH * 0.5;
    self.topImageView.y = 60;
    
    self.introduceLabel.width = JA_SCREEN_WIDTH;
    self.introduceLabel.height = 20;
    self.introduceLabel.y = self.topImageView.bottom + 30;
    
    self.otherButton.width = 300;
    self.otherButton.height = 40;
    self.otherButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.otherButton.y = self.view.height - 60 - self.otherButton.height;
    self.otherButton.layer.cornerRadius = self.otherButton.height * 0.5;
    
    self.quickButton.width = 300;
    self.quickButton.height = 40;
    self.quickButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.quickButton.y = self.otherButton.y - 20 - self.quickButton.height;
    self.quickButton.layer.cornerRadius = self.quickButton.height * 0.5;
}

#pragma mark - 点击事件
- (void)clickQuickLogin
{
    if (self.loginType == JARecordLoginTypeQqLogin) {
        [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
    }else if (self.loginType == JARecordLoginTypeWbLogin){
        [[JALoginManager shareInstance] loginWithType:JALoginType_Weibo];
    }else if (self.loginType == JARecordLoginTypeWxLogin){
        [[JALoginManager shareInstance] loginWithType:JALoginType_Wechat];
    }
}

- (void)clickOtherLogin
{
    [self dismissViewControllerAnimated:NO completion:nil];
    // 进入登录控制器
    [JAAPPManager app_modalRegist];
}

#pragma mark - 通知的监听
- (void)loginSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
