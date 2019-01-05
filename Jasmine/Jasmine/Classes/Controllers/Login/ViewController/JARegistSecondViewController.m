//
//  JARegistSecondViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARegistSecondViewController.h"
#import "JAUserApiRequest.h"
#import "SFAttriLab.h"
#import "JAWebViewController.h"
#import "NSTimer+JABlocksSupport.h"
#import "JACommonApi.h"

#define KiPhoneSafeArea ((iPhoneX) ? (64+58) : 64)

@interface JARegistSecondViewController () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *logoIcon;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, strong) UIImageView *vertifyIcon;
@property (nonatomic, strong) UITextField *vertifyNumT;
@property (nonatomic, strong) UIImageView *passwordIcon;
@property (nonatomic, strong) UITextField *passwordT;
@property (nonatomic, strong) UIButton *getVertfBtn;
@property (nonatomic, strong) UIButton *eyeButton;
@property (nonatomic, strong) SFAttriLab *protocolLabel;
@property (nonatomic, strong) UIButton *registBtn;  // 确定按钮

// 定时器
@property (nonatomic, strong) NSTimer *pollTimer;

@property (nonatomic, strong) NSString *frontCode;  // 前一个验证码
@property (nonatomic, strong) NSString *frontPwd;  // 前一个密码
@property (nonatomic, assign) BOOL beginEditPwd;   // 开始编辑密码

@end


@implementation JARegistSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupRegistSecondViewUI];
    
    [self.vertifyNumT becomeFirstResponder];
    
    self.getVertfBtn.enabled = NO;
    [self.getVertfBtn setTitle:[NSString stringWithFormat:@"重新发送(%zds)", self.timeNum] forState:UIControlStateDisabled];
    
    @WeakObj(self);
    _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
        @StrongObj(self);
        [self p_doPoll];
    }];
    
    // 添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.vertifyNumT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordT];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
}

#pragma mark - 设置UI
- (void)setupRegistSecondViewUI
{
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];

    self.bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.bgView];
    
    self.logoIcon = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH-80)*.5, WIDTH_ADAPTER(20), 80, 80) imageName:@"login_icon"];
    [self.bgView addSubview:self.logoIcon];
    
    
    self.introduceLabel = [[UILabel alloc] init];
    self.introduceLabel.text = [NSString stringWithFormat:@"验证码已发送至+86 %@",_phoneString];
    self.introduceLabel.frame = CGRectMake(0, self.logoIcon.bottom + 21, JA_SCREEN_WIDTH, 17);
    self.introduceLabel.font = JA_REGULAR_FONT(14);
    self.introduceLabel.textColor = HEX_COLOR(JA_Three_Title);
    self.introduceLabel.textAlignment = NSTextAlignmentCenter;
    [self.bgView addSubview:self.introduceLabel];
    
    self.vertifyIcon = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH - 300) * 0.5 + 3, self.introduceLabel.bottom + 28, 19, 22) imageName:@"branch_login_vertify"];
    [self.bgView addSubview:self.vertifyIcon];
    
    self.vertifyNumT = [self textFieldItemWithFrame:CGRectMake(self.vertifyIcon.right+15, self.vertifyIcon.top-4, 150, 30) placeHolder:@"请输入验证码(4位数)"];
    self.vertifyNumT.keyboardType = UIKeyboardTypeNumberPad;
    [self.vertifyNumT addTarget:self action:@selector(inputVertifyNum:) forControlEvents:UIControlEventEditingChanged];
    [self.bgView addSubview:self.vertifyNumT];
    
    self.getVertfBtn = [[UIButton alloc] initWithFrame:CGRectMake((JA_SCREEN_WIDTH - 300) * 0.5 + 200 - 3, self.vertifyNumT.top, 100, 30)];
    self.getVertfBtn.titleLabel.font = JA_REGULAR_FONT(13);
    [self.getVertfBtn setTitleColor:HEX_COLOR(JA_Three_Title) forState:UIControlStateNormal];
    [self.getVertfBtn setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateDisabled];
    [self.getVertfBtn setTitle:[NSString stringWithFormat:@"重新发送(59s)"] forState:UIControlStateDisabled];
    [self.getVertfBtn setTitle:@"重新发送" forState:UIControlStateNormal];
    self.getVertfBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [self.getVertfBtn addTarget:self action:@selector(getVertfy:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.getVertfBtn];
    
    UIView *separate2 = [self separateLineWithY:self.vertifyIcon.bottom + 13];
    [self.bgView addSubview:separate2];
    
    self.passwordIcon = [self imageItemWithFrame:CGRectMake(self.vertifyIcon.x, separate2.bottom+13, 19, 22) imageName:@"branch_login_pwd"];
    [self.bgView addSubview:self.passwordIcon];
    
    self.passwordT = [self textFieldItemWithFrame:CGRectMake(self.vertifyNumT.x, self.passwordIcon.top-4, 230, 30) placeHolder:@"请输入密码(不少于6位)"];
    self.passwordT.secureTextEntry = YES;
    [self.passwordT addTarget:self action:@selector(beginEditPwd:) forControlEvents:UIControlEventEditingDidBegin];
    [self.passwordT addTarget:self action:@selector(EditPwd:) forControlEvents:UIControlEventEditingChanged];
    [self.bgView addSubview:self.passwordT];
    
    self.eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.eyeButton setImage:[UIImage imageNamed:@"branch_login_eyeClose"] forState:UIControlStateNormal];
    [self.eyeButton setImage:[UIImage imageNamed:@"branch_login_eyeOpen"] forState:UIControlStateSelected];
    [self.eyeButton addTarget:self action:@selector(pwdShow:) forControlEvents:UIControlEventTouchUpInside];
    self.eyeButton.frame = CGRectMake(self.getVertfBtn.right - 18, self.passwordT.y, 18, 30);
    [self.bgView addSubview:self.eyeButton];
    
    UIView *separate3 =[self separateLineWithY:self.passwordIcon.bottom + 13];
    [self.bgView addSubview:separate3];
    
    self.registBtn = [[UIButton alloc] initWithFrame:CGRectMake((JA_SCREEN_WIDTH-300)*.5, separate3.bottom+40, 300, 40)];
    self.registBtn.titleLabel.font = JA_MEDIUM_FONT(16);
    [self.registBtn setBackgroundColor:HEX_COLOR(0xffffff)];
    [self.registBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.registBtn.enabled = NO;
    [self.registBtn setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xE2E2E2)] forState:UIControlStateDisabled];
    [self.registBtn setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(JA_Green)] forState:UIControlStateNormal];
    [self.registBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.registBtn addTarget:self action:@selector(registButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.registBtn.layer.cornerRadius = self.registBtn.height*.5;
    self.registBtn.clipsToBounds = YES;
    [self.bgView addSubview:self.registBtn];
    
    self.protocolLabel = [SFAttriLab attriLabInstanceWithInitialFrame:CGRectMake(0, JA_SCREEN_HEIGHT - KiPhoneSafeArea - 35, JA_SCREEN_WIDTH, 12) andFirstName:@"注册代表您已阅读并同意" andContent:@"注册代表您已阅读或同意茉莉用户协议"];
    @WeakObj(self);
    [self.protocolLabel clickcCharacterWithBlock:^(NSInteger index) {
        @StrongObj(self);
        if (index == 1) {
        }else if(index == 2) {
            JAWebViewController *webVC = [JAWebViewController new];
            webVC.titleString = @"茉莉用户协议";
            webVC.urlString = @"https://www.urmoli.com/app/protocol";
            [self.navigationController pushViewController:webVC animated:YES];
        }else {
        }
    }];
    [self.bgView addSubview:self.protocolLabel];
}

#pragma mark - 定时器
- (void)stopPolling{
    [_pollTimer invalidate];
    _pollTimer = nil;
}

- (void)p_doPoll{
    if (self.timeNum>0) {
        self.getVertfBtn.enabled = NO;
        [self.getVertfBtn setTitle:[NSString stringWithFormat:@"重新发送(%zds)", self.timeNum] forState:UIControlStateDisabled];
        self.timeNum--;
    } else{
        self.getVertfBtn.enabled = YES;
        [self stopPolling];
    }
}

#pragma mark - 验证码输入 密码输入
- (void)inputVertifyNum:(UITextField *)field
{
    if (field.text.length >= 4) {
        field.text = [field.text substringToIndex:4];
        
        // 判断是不是验证码变化了  -- 变化了触发神策统计
        if (/*self.frontCode.length &&*/ ![field.text isEqualToString:self.frontCode]) {
            
            [JASensorsAnalyticsManager sensorsAnalytics_InputValidationCode:nil];
            
            self.frontCode = field.text;
        }else{
            self.frontCode = field.text;
        }
        
//        [field resignFirstResponder];
//        [self.passwordT becomeFirstResponder];
        [self.passwordT performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
    }
}

- (void)beginEditPwd:(UITextField *)field
{
    self.beginEditPwd = YES;
}

- (void)EditPwd:(UITextField *)field
{
    if (self.beginEditPwd) {
        self.beginEditPwd = NO;
        if (/*self.frontPwd.length > 0 &&*/ ![field.text isEqualToString:self.frontPwd]) {
            
            [JASensorsAnalyticsManager sensorsAnalytics_InputPassword:nil];
        }
    }
    
    self.frontPwd = field.text;
}

- (void)pwdShow:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.passwordT.secureTextEntry = !self.passwordT.secureTextEntry;
}

#pragma mark - 点击获取验证码
- (void)getVertfy:(UIButton *)btn
{
    [MBProgressHUD showMessage:nil];
    btn.userInteractionEnabled = NO;
    
    NSString *phoneNum = [NSString stringWithFormat:@"%@",self.phoneString];
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_Phone] = phoneNum;
    senDic[JA_Property_CodeType] = @"注册";
    senDic[JA_Property_IsSendRequest] = @(YES);
    [JASensorsAnalyticsManager sensorsAnalytics_clickRegistCode:senDic];
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"phone"] = phoneNum;
    dic[@"functionType"] = @"0";
    dic[@"distinctId"] = [[SensorsAnalyticsSDK sharedInstance] distinctId];
    
    [[JAUserApiRequest shareInstance] getVerifyCodeWithPhone:dic success:^(NSDictionary *result) {
        
        [MBProgressHUD hideHUD];
        btn.userInteractionEnabled = YES;
        
        [self.view ja_makeToast:@"短信验证码已发出"];
        
        self.timeNum = 59;
        @WeakObj(self);
        _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
            @StrongObj(self);
            [self p_doPoll];
        }];
        
        if (self.againGetCode) {
            self.againGetCode();
        }
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUD];
        btn.userInteractionEnabled = YES;
        if (error.code == 123500) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"手机号码已经注册,是否直接登录？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self dismissViewControllerAnimated:NO completion:nil];
                [JAAPPManager app_modalLogin];
            }];
            UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:action1];
            [alert addAction:action2];
            [self presentViewController:alert animated:YES completion:nil];
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
            
        }
    }];
}

#pragma mark - 注册按钮
// 注册按钮
- (void)registButtonClick:(UIButton *)btn
{
    [self.passwordT resignFirstResponder];
    
    if (!self.vertifyNumT.text.length) {
        [self.view ja_makeToast:@"验证码不能为空"];
        return;
    }

    if (self.passwordT.text.length < 6) {
        [self.view ja_makeToast:@"密码太短,请输入6-32位密码"];
        return;
    }

    if (self.passwordT.text.length > 32) {
        [self.view ja_makeToast:@"密码太长,请输入6-32位密码"];
        return;
    }

    // 神策数据 发送注册请求
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_SignUpMethod] = @"手机号";
    senDic[JA_Property_Phone] = self.phoneString;
    [JASensorsAnalyticsManager sensorsAnalytics_clickRegist:senDic];

    // 注册接口
    btn.userInteractionEnabled = NO;
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"platformType"] = @"0";
    dic[@"phone"] = self.phoneString;
    dic[@"authNum"] = self.vertifyNumT.text;
    dic[@"password"] = [self.passwordT.text md5_origin];
    dic[@"platformMark"] = JA_CHANNEL;
    dic[@"distinctId"] = [[SensorsAnalyticsSDK sharedInstance] distinctId];

    [[JAUserApiRequest shareInstance] regisetUserAccount:dic success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        //        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstRegist"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        // 登录成功
        [JAAPPManager app_loginSuccessWithResult:result loginType:0];

        // 因为手机号不能改变，所以只传一次
        [[[SensorsAnalyticsSDK sharedInstance] people] set:@"phone" to:self.phoneString];

        // 统计统计
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [[JACommonApi shareInstance] addDataLogs_registerWithType:@"phone"];
        });
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(NSError *error) {
        btn.userInteractionEnabled = YES;
        [MBProgressHUD hideHUD];
    }];
    
}

#pragma mark - 文本输入
- (void)textFieldChanged:(NSNotification *)note{
    
    if (self.vertifyNumT.text.length&&self.passwordT.text.length) {
        self.registBtn.enabled = YES;
    } else{
        self.registBtn.enabled = NO;
    }
}

#pragma mark - 公用方法
- (UIImageView *)imageItemWithFrame:(CGRect)frame imageName:(NSString *)imageName{
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
    imgV.image = [UIImage imageNamed:imageName];
    return imgV;
}

- (UITextField *)textFieldItemWithFrame:(CGRect)frame placeHolder:(NSString *)placeHolder{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.font = JA_REGULAR_FONT(14);
    textField.textColor = HEX_COLOR(0x444444);
    textField.placeholder = placeHolder;
    return textField;
}

- (UIView *)separateLineWithY:(CGFloat)y{
    UIView *line =[[UIView alloc] initWithFrame:CGRectMake(self.vertifyIcon.x - 3, y, 300, 1)];
    line.backgroundColor = HEX_COLOR(JA_Line);
    return line;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
@end
