//
//  JAWithDrawViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawViewController.h"
#import "JAWithDrawRecordViewController.h"
#import "JAWithDrawFinishViewController.h"
#import "JAUserApiRequest.h"
#import "JALoginManager.h"
#import <WechatOpenSDK/WXApi.h>
#import "JABindPhoneViewController.h"
@interface JAWithDrawViewController ()

@property (nonatomic, weak) UIView *greenView;
@property (nonatomic, weak) UILabel *accountTitleLabel;
@property (nonatomic, weak) UILabel *accountLabel;
@property (nonatomic, weak) UILabel *lineView;

@property (nonatomic, weak) UIView *whiteView;
@property (nonatomic, weak) UILabel *withDrawLabel;

@property (nonatomic, strong) UIImageView *firstImageView;

@property (nonatomic, weak) UIButton *withDrawButton;
@property (nonatomic, weak) UIButton *bottomButton;
@property (nonatomic, weak) UILabel *bottomLabel;

@property (nonatomic, strong) NSString *withMoney;
@property (nonatomic, weak) UIButton *frontButton;
@end

@implementation JAWithDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"微信提现"];
    [self setNavRightTitle:@"提现记录" color:HEX_COLOR(JA_Green)];
    self.view.backgroundColor = HEX_COLOR(JA_BtnGrounddColor);
    [self setupWithDrawUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingWXSuccess) name:@"bindingPlatform" object:nil];
}

- (void)setupWithDrawUI
{
    UIView *greenView = [[UIView alloc] init];
    _greenView = greenView;
    greenView.backgroundColor = HEX_COLOR(0xffffff);
    greenView.width = JA_SCREEN_WIDTH;
    greenView.height = 102;
    [self.view addSubview:greenView];
    
    UILabel *accountTitleLabel = [[UILabel alloc] init];
    _accountTitleLabel = accountTitleLabel;
    accountTitleLabel.text = @"当前账户余额（元）";
    accountTitleLabel.textColor = HEX_COLOR(0x4A4A4A);
    accountTitleLabel.font = JA_MEDIUM_FONT(18);
    [accountTitleLabel sizeToFit];
    accountTitleLabel.height = 25;
    accountTitleLabel.x = 14;
    accountTitleLabel.y = 15;
    [greenView addSubview:accountTitleLabel];
    
    UILabel *accountLabel = [[UILabel alloc] init];
    _accountLabel = accountLabel;
    accountLabel.text = [NSString stringWithFormat:@"%@",self.moneyCountString];
    accountLabel.textColor = HEX_COLOR(0x6BD379);
    accountLabel.font = JA_MEDIUM_FONT(36);
    accountLabel.width = JA_SCREEN_WIDTH - accountTitleLabel.x;
    accountLabel.height = 37;
    accountLabel.y = accountTitleLabel.bottom + 10;
    accountLabel.x = accountTitleLabel.x;
    [greenView addSubview:accountLabel];
    
    UIView *lineView1 = [[UIView alloc] init];
    lineView1.backgroundColor = HEX_COLOR(JA_Line);
    lineView1.width = JA_SCREEN_WIDTH - 28;
    lineView1.height = 1;
    lineView1.x = 14;
    lineView1.y = greenView.height - 1;
    [greenView addSubview:lineView1];
    
    UIView *whiteView = [[UIView alloc] init];
    _whiteView = whiteView;
    whiteView.backgroundColor = HEX_COLOR(0xffffff);
    whiteView.width = JA_SCREEN_WIDTH;
//    whiteView.height = 180;
    whiteView.y = greenView.bottom;
    [self.view addSubview:whiteView];
    
    UILabel *withDrawLabel = [[UILabel alloc] init];
    _withDrawLabel = withDrawLabel;
    withDrawLabel.text = @"选择提现金额：";
    withDrawLabel.textColor = HEX_COLOR(0x4A4A4A);
    withDrawLabel.font = JA_MEDIUM_FONT(13);
    [withDrawLabel sizeToFit];
    withDrawLabel.height = 18;
    withDrawLabel.y = 15;
    withDrawLabel.x = 14;
    [whiteView addSubview:withDrawLabel];
    
    UIImageView *firstImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_first_withD"]];
    _firstImageView = firstImageView;
    firstImageView.hidden = YES;
    
    // 布局按钮
    [self setWithDrawButtonUI];
    
    // 底部
    UIButton *withDrawButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _withDrawButton = withDrawButton;
    [withDrawButton addTarget:self action:@selector(applyForWithDraw:) forControlEvents:UIControlEventTouchUpInside];
    withDrawButton.backgroundColor = HEX_COLOR(0x6BD379);
    [self.view addSubview:withDrawButton];
    
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _bottomButton = bottomButton;
    [bottomButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    bottomButton.titleLabel.font = JA_MEDIUM_FONT(12);
    bottomButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [self.view addSubview:bottomButton];
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    _bottomLabel = bottomLabel;
    bottomLabel.text = @"官方将在5个工作日内处理你的提现申请，请耐心等待...";
    bottomLabel.numberOfLines = 0;
    bottomLabel.textColor = HEX_COLOR(0xFF7054);
    bottomLabel.font = JA_MEDIUM_FONT(12);
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:bottomLabel];
}

- (void)setWithDrawButtonUI
{
    for (UIView *v in self.whiteView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            [v removeFromSuperview];
        }
    }
    
    // 根据传入的数组创建
    CGFloat marginLR = 15;
    CGFloat margin = 20;
    NSInteger count = 3;
    CGFloat buttonW = (JA_SCREEN_WIDTH - 2 * marginLR - (count - 1) * margin) / 3;
    CGFloat buttonH = buttonW * 57 / 100.0;
    CGFloat buttonX = 0;
    CGFloat buttonY = 0;
    
    for (NSInteger i = 0; i < self.moneyArray.count; i++) {
        
        buttonX = marginLR + (buttonW + margin) * (i % count);
        buttonY = 50 + (buttonH + 20) * (i / 3);
        
        NSString *num = [NSString stringWithFormat:@"%@元",self.moneyArray[i]];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = 1314 + i;
        [button setTitle:num forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xffffff)] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0x6BD379)] forState:UIControlStateSelected];
        [button setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
        [button setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
        button.titleLabel.font = JA_REGULAR_FONT(18);
        button.layer.borderColor = HEX_COLOR(0xC6C6C6).CGColor;
        button.layer.borderWidth = 1;
        button.layer.cornerRadius = 3;
        button.layer.masksToBounds = YES;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [button addTarget:self action:@selector(clickMoneyButton:) forControlEvents:UIControlEventTouchUpInside];
        if (i == 0) {
            button.selected = YES;
            button.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
            button.layer.borderWidth = 0;
            self.frontButton = button;
            self.withMoney = [button.currentTitle substringToIndex:button.currentTitle.length - 1];
            [button addSubview:_firstImageView];
            _firstImageView.hidden = !self.isFirstWithDraw;
        }
        [self.whiteView addSubview:button];
    }
    
    UIButton *btn = (UIButton *)self.whiteView.subviews.lastObject;
    self.whiteView.height = btn.bottom + 26;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.withDrawButton.width = 300;
    self.withDrawButton.height = 40;
    self.withDrawButton.y = self.whiteView.bottom + 40;
    self.withDrawButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.withDrawButton.layer.cornerRadius = self.withDrawButton.height * 0.5;
    
    self.bottomButton.width = 105;
    self.bottomButton.height = 20;
    self.bottomButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.bottomButton.y = self.withDrawButton.bottom + 20;
    
    self.bottomLabel.width = 310;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.width = 310;
    self.bottomLabel.y = self.bottomButton.bottom + 15;
    self.bottomLabel.centerX = JA_SCREEN_WIDTH * 0.5;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    

    [self setWithDrawButtonUI]; // 重新布局
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"申请提现";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    
    // 判断按钮的展示文字
    NSString *titleStr = nil;
    NSString *bottomTitleStr = nil;
    NSString *bottomImageStr = nil;
    NSString *wxBinding = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWXUid];   // 是否需要绑定微信
    
    
    if (wxBinding.length) {   // 已经绑定微信
        
        NSString *phone = [JAUserInfo userInfo_getUserImfoWithKey:User_Phone];    // 是否需要绑定手机
        
        if (phone.length) {
            
            titleStr = @"申请提现";
            bottomTitleStr = @"提现到绑定微信";
            bottomImageStr = @"binding_success";
            
        }else{
            
            titleStr = @"绑定手机";
            bottomTitleStr = @"需要绑定手机";
            bottomImageStr = @"binding_wx";
        }
        
    }else{
        
        titleStr = @"绑定微信";
        bottomTitleStr = @"需要绑定微信";
        bottomImageStr = @"binding_wx";
    }
    
     [self.withDrawButton setTitle:titleStr forState:UIControlStateNormal];
    [self.bottomButton setTitle:bottomTitleStr forState:UIControlStateNormal];
    [self.bottomButton setImage:[UIImage imageNamed:bottomImageStr] forState:UIControlStateNormal];
    
}

// 绑定微信成功
- (void)bindingWXSuccess
{
    [MBProgressHUD hideHUD];
    // 判断按钮的展示文字
    NSString *titleStr = nil;
    NSString *bottomTitleStr = nil;
    NSString *bottomImageStr = nil;
    NSString *wxBinding = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWXUid];
    
    
    if (wxBinding.length) {   // 已经绑定微信
        
        NSString *phone = [JAUserInfo userInfo_getUserImfoWithKey:User_Phone];
        
        if (phone.length) {
            
            titleStr = @"申请提现";
            bottomTitleStr = @"提现到绑定微信";
            bottomImageStr = @"binding_success";
            
        }else{
            
            titleStr = @"绑定手机";
            bottomTitleStr = @"需要绑定手机";
            bottomImageStr = @"binding_wx";
        }
        
    }else{
        
        titleStr = @"绑定微信";
        bottomTitleStr = @"需要绑定微信";
        bottomImageStr = @"binding_wx";
    }
    
    [self.withDrawButton setTitle:titleStr forState:UIControlStateNormal];
    [self.bottomButton setTitle:bottomTitleStr forState:UIControlStateNormal];
    [self.bottomButton setImage:[UIImage imageNamed:bottomImageStr] forState:UIControlStateNormal];
}

#pragma mark - 按钮的点击
- (void)clickMoneyButton:(UIButton *)button
{
    self.frontButton.selected = NO;
    self.frontButton.layer.borderColor = HEX_COLOR(0xC6C6C6).CGColor;
    self.frontButton.layer.borderWidth = 1;
    button.selected = YES;
    button.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
    button.layer.borderWidth = 0;
    self.frontButton = button;
    
    self.withMoney = [button.currentTitle substringToIndex:button.currentTitle.length - 1];
}

// 申请提现按钮
- (void)applyForWithDraw:(UIButton *)btn
{
    NSString *wxBinding = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWXUid];
    NSString *phone = [JAUserInfo userInfo_getUserImfoWithKey:User_Phone];
    
    if (!wxBinding.length) {
        
        // 绑定微信
        [self bindingWX:btn];
        return;
    }
    
    if (!phone.length) {
        
        // 绑定手机
        [self bindingPhone:btn];
        
        return;
    }
    
    
    // 申请提现
    [self withDraw:btn];
}

// 绑定微信
- (void)bindingWX:(UIButton *)btn
{
    // 去绑定微信
    [[JALoginManager shareInstance] loginWithType:JALoginType_Wechat];
}

// 绑定手机
- (void)bindingPhone:(UIButton *)btn
{
    JABindPhoneViewController *binePhoneV = [[JABindPhoneViewController alloc] init];
    [self.navigationController pushViewController:binePhoneV animated:YES];
}

// 提现
- (void)withDraw:(UIButton *)btn
{
    if ([self.withMoney floatValue] <= 0 || !self.withMoney.length) {
        
        [self.view ja_makeToast:@"请选择提现金额"];
        return;
    }
    
    // 提现最小金额限制
//    if ([self.withDrawTextField.text floatValue] < [self.maxWithDrawMoney floatValue]) {
//
//        NSString *str = [NSString stringWithFormat:@"提现金额不能低于%@元",self.maxWithDrawMoney];
//        [self.view ja_makeToast:str];
//
//        return;
//    }
    
    if (self.withMoney.floatValue > self.moneyCountString.floatValue) {
        [self.view ja_makeToast:@"可提现金额不足"];
        return;
    }
    
    btn.userInteractionEnabled = NO;
    
    NSString *str = [NSString stringWithFormat:@"确定要提现¥%@元到你绑定的微信账号？",self.withMoney];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        btn.userInteractionEnabled = YES;
       
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_MoneyAmount] = @([self.withMoney doubleValue]);
        [JASensorsAnalyticsManager sensorsAnalytics_withDraw:senDic];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"money"] = self.withMoney;
        
        [[JAUserApiRequest shareInstance] userWithDrawMoney:dic success:^(NSDictionary *result) {
            btn.userInteractionEnabled = YES;
            self.moneyCountString = [NSString stringWithFormat:@"%.2f",[self.moneyCountString floatValue] - [self.withMoney floatValue]];
            self.accountLabel.text = [NSString stringWithFormat:@"%@",self.moneyCountString];
            
            if (self.isFirstWithDraw) {  // 是第一次提现
                self.isFirstWithDraw = NO;
            }
            
            if (self.withDrawSuccess) {
                self.withDrawSuccess(self.moneyCountString);
            }
            
            JAWithDrawFinishViewController *vc = [[JAWithDrawFinishViewController alloc] init];
            vc.moneyString = [NSString stringWithFormat:@"%.2f",[self.withMoney floatValue]];
            [self.navigationController pushViewController:vc animated:YES];
            
        } failure:^(NSError *error) {
            btn.userInteractionEnabled = YES;
            
            if (error.code == 140012) {
                
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:error.localizedDescription message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                    
                }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"去授权" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    
                    UIAlertController *alertController1 = [UIAlertController alertControllerWithTitle:@"\"茉莉\"想要打开\"微信\"" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                        
                    }];
                    
                    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"打开" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        if([WXApi isWXAppInstalled]){
                            
                            //打开微信
//                            JumpToBizProfileReq *req = [[JumpToBizProfileReq alloc]init];
//                            req.profileType =WXBizProfileType_Normal;
//                            req.username = @"gh_d21a4af03071";
//                            [WXApi sendReq:req];
                            
                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
                        }else{
                            [self.view ja_makeToast:@"请安装微信"];
                        }
                    }];
                    [alertController1 addAction:action1];
                    [alertController1 addAction:action2];
                    [self presentViewController:alertController1 animated:YES completion:nil];
                    
                }];
                [alertController addAction:okAction];
                [alertController addAction:cancleAction];
                [self presentViewController:alertController animated:YES completion:nil];
                
            }else{
                
                [self.view ja_makeToast:error.localizedDescription];
            }
        }];
        
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 提现记录
-(void)actionRight
{
    JAWithDrawRecordViewController *vc = [[JAWithDrawRecordViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)withDrawMoney:(UITextField *)textF
{
    if ([textF.text floatValue] > [self.moneyCountString floatValue]) {
        
        textF.text = [NSString stringWithFormat:@"%ld",self.moneyCountString.integerValue];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
