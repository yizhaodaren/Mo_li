//
//  JALoginViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/17.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JALoginViewController.h"
#import "JAUserApiRequest.h"
#import "JANewRegistrationViewController.h"
#import "JAPlatformBindingPhoneViewController.h"

#import "JALoginManager.h"
#import "JAIMManager.h"

#import "JAResetPasswordVC.h"

#import "JAInputToolBar.h"
#import "JAPlayWaveView.h"
#import "JAAudioPlayer.h"

#import "JASwitchDefine.h"
#import "WXApi.h"
#import "JAVoicePlayerManager.h"

#define KiPhoneSafeArea (iPhoneX ? (64+58) : 64)

static CGFloat const kIconLeadingGap = 22;

@interface JALoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *logoIcon;

@property (nonatomic, strong) UIImageView *phoneImg;
@property (nonatomic, strong) UITextField *phoneNumT;

@property (nonatomic, strong) UIImageView *passwordIcon;
@property (nonatomic, strong) UITextField *passwordT;
@property (nonatomic, strong) UIButton *eyeButton;

@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, strong) UIButton *forgetButton;

@property (nonatomic, strong) NSString *phoneString;

@property (nonatomic, strong) UIView *platformView;
@property (nonatomic, strong) UIButton *qqButton;
@property (nonatomic, strong) UIButton *wxButton;
@property (nonatomic, strong) UIButton *wbButton;

// v2.4.0
@property (nonatomic, strong) JAPlayWaveView *playWaveView;
@property (nonatomic, weak) UIButton *playButton;

@end

@implementation JALoginViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needLoginVoice"]){
        // 暂停播放语音
        [[JAVoicePlayerManager shareInstance] pause];
        [[JAVoicePlayerManager shareInstance] cancelDelayPlayNextVoice];
    }
    
    // 设置UI
    [self setupNavigator];
    [self setUpUI];
    
    // 添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindPhone:) name:NEED_Regist object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:PlatformLoginSuccess object:nil];
    
    if ([WXApi isWXAppInstalled]) {
        self.wxButton.hidden = NO;
    }else{
        self.wxButton.hidden = YES;
    }
 
    if (self.loginPhone.length) {
        self.phoneNumT.text = self.loginPhone;
        self.phoneString = [self.loginPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    [JALoginManager shareInstance].vc = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"登录";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needLoginVoice"]){
        NSString *audioFile=[[NSBundle mainBundle] pathForResource:@"login.mp3" ofType:nil];
        NSURL *fileUrl=[NSURL fileURLWithPath:audioFile];
        @WeakObj(self);
        [[JAAudioPlayer shareInstance] play:fileUrl finishBlock:^{
            @StrongObj(self);
            [self.playWaveView stopAnimation];
            self.playWaveView.hidden = YES;
        }];
        
        [self.playWaveView startAnimation];
        self.playWaveView.hidden = NO;
    }else{
        self.playButton.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.passwordT becomeFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needLoginVoice"]){
        [self.playWaveView stopAnimation];
        self.playWaveView.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"needLoginVoice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)dealloc
{
    [[JAAudioPlayer shareInstance] stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 设置UI
- (void)setupNavigator
{
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    
    // 设置左边的按钮
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"circle_back_black"] highlightImage:[UIImage imageNamed:@"circle_back_black"]];
    
    // 设置右边的按钮
//    [self setNavRightTitle:@"去注册" color:HEX_COLOR(0x444444)];
//    [self setupNavRightButton];
}

// 设置右边导航按钮
- (void)setupNavRightButton
{
    UIButton *goLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [goLoginBtn setTitle:@"去注册" forState:UIControlStateNormal];
    [goLoginBtn setTitleColor:HEX_COLOR(0x444444) forState:UIControlStateNormal];
    goLoginBtn.titleLabel.font = JA_MEDIUM_FONT(15);
    CGSize textSize = [[goLoginBtn titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : goLoginBtn.titleLabel.font}];
    [goLoginBtn setFrame:CGRectMake(0, 0, textSize.width, 30)];
    [goLoginBtn addTarget:self action:@selector(actionRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *goLoginItem = [[UIBarButtonItem alloc] initWithCustomView:goLoginBtn];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needLoginVoice"])
    {
        _playButton = playButton;
        [playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [playButton setImage:[UIImage imageNamed:@"login_play_quiet"] forState:UIControlStateSelected];
        [playButton setImage:[UIImage imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        [playButton setFrame:CGRectMake(0, 0, 40, 40)];
        JAPlayWaveView *playWaveView = [JAPlayWaveView new];
        playWaveView.userInteractionEnabled = NO;
        playWaveView.width = 17;
        playWaveView.height = 20;
        playWaveView.centerY = playButton.height * 0.5;
        playWaveView.centerX = playButton.width * 0.5;
        [playButton addSubview:playWaveView];
        self.playWaveView = playWaveView;
        self.playWaveView.hidden = YES;
    }
    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithCustomView:playButton];

    self.navigationItem.rightBarButtonItems = @[playItem];
}

- (void)actionRight
{
    [self dismissViewControllerAnimated:NO completion:nil];
    // 进入登录控制器
    JANewRegistrationViewController *vc = [[JANewRegistrationViewController alloc] init];
    JABaseNavigationController *registNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
    [[AppDelegateModel rootviewController] presentViewController:registNav animated:YES completion:nil];
    
}

- (void)playAction {
    if (self.playButton.hidden == YES) {
        return;
    }
    if (self.playButton.selected == NO && self.playWaveView.hidden == YES) {
        return;
    }
    
    BOOL isPlaying = [JAAudioPlayer shareInstance].player.isPlaying;
    if (isPlaying) {
        [self.playWaveView stopAnimation];
        self.playWaveView.hidden = YES;
        self.playButton.selected = YES;
        [[JAAudioPlayer shareInstance] pause];
        
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_ScreenName] = @"登录";
        [JASensorsAnalyticsManager sensorsAnalytics_shutUp:senDic];
    } else {
        [self.playWaveView startAnimation];
        self.playWaveView.hidden = NO;
        self.playButton.selected = NO;
        [[JAAudioPlayer shareInstance] continuePlay];
    }
}

- (void)setUpUI
{
    self.bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.bgView];
    
    self.logoIcon = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH-80)*.5, WIDTH_ADAPTER(20), 80, 80) imageName:@"login_icon"];
    [self.bgView addSubview:self.logoIcon];
    
//    self.phoneImg = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH - 300) * 0.5, self.logoIcon.bottom + 21, 19, 22) imageName:@"branch_login_phone"];
//    [self.bgView addSubview:self.phoneImg];
//    
//    UILabel *eightSixL = [[UILabel alloc] initWithFrame:CGRectMake(self.phoneImg.right+10.5, self.phoneImg.y, 30, 22)];
//    eightSixL.font = JA_REGULAR_FONT(14);
//    eightSixL.textColor = HEX_COLOR(JA_Three_Title);
//    eightSixL.text = @"+86";
//    [self.bgView addSubview:eightSixL];
//    
//    UIView *vertiLine = [[UIView alloc] init];
//    vertiLine.x = eightSixL.right + 10;
//    vertiLine.width = 1;
//    vertiLine.height = 20;
//    vertiLine.centerY = eightSixL.centerY;
//    vertiLine.backgroundColor = HEX_COLOR(JA_Line);
//    [self.bgView addSubview:vertiLine];
//    
//    self.phoneNumT = [self textFieldItemWithFrame:CGRectMake(vertiLine.right+10, self.phoneImg.top-4, 300 - vertiLine.right+10, 30) placeHolder:@"手机号"];
//    [self.phoneNumT addTarget:self action:@selector(inputPhone:) forControlEvents:UIControlEventEditingChanged];
//    self.phoneNumT.delegate = self;
//    self.phoneNumT.keyboardType = UIKeyboardTypeNumberPad;
//    [self.bgView addSubview:self.phoneNumT];
//
//    UIView *separate1 = [self separateLineWithY:self.phoneImg.bottom + 10];
//    [self.bgView addSubview:separate1];
    
    self.passwordIcon = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH - 300) * 0.5, self.logoIcon.bottom + 21, 19, 22) imageName:@"branch_login_pwd"];
    [self.bgView addSubview:self.passwordIcon];
    
    self.passwordT = [self textFieldItemWithFrame:CGRectMake(self.passwordIcon.right+10.5, self.passwordIcon.top-4, 240, 30) placeHolder:@"请输入密码"];
    self.passwordT.secureTextEntry = YES;
    [self.bgView addSubview:self.passwordT];
    
    self.eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.eyeButton setImage:[UIImage imageNamed:@"branch_login_eyeClose"] forState:UIControlStateNormal];
    [self.eyeButton setImage:[UIImage imageNamed:@"branch_login_eyeOpen"] forState:UIControlStateSelected];
    [self.eyeButton addTarget:self action:@selector(pwdShow:) forControlEvents:UIControlEventTouchUpInside];
    self.eyeButton.frame = CGRectMake(self.bgView.width - 18 - 35, self.passwordT.y, 18, 30);
    self.eyeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.bgView addSubview:self.eyeButton];
    
    UIView *separate3 =[self separateLineWithY:self.passwordIcon.bottom + 13];
    [self.bgView addSubview:separate3];
    
    self.loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.loginBtn.width = 300;
    self.loginBtn.height = 40;
    self.loginBtn.centerX = JA_SCREEN_WIDTH * 0.5;
    self.loginBtn.y = separate3.bottom + 40;
    self.loginBtn.titleLabel.font = JA_MEDIUM_FONT(16);
    self.loginBtn.enabled = NO;
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xE2E2E2)] forState:UIControlStateDisabled];
    [self.loginBtn setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(JA_Green)] forState:UIControlStateNormal];
    [self.loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.loginBtn addTarget:self action:@selector(loginAccount) forControlEvents:UIControlEventTouchUpInside];
    self.loginBtn.layer.cornerRadius = self.loginBtn.height*.5;
    self.loginBtn.clipsToBounds = YES;
    [self.bgView addSubview:self.loginBtn];
    
    self.forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.forgetButton setTitle:@"忘记密码？" forState:UIControlStateNormal];
    [self.forgetButton setTitleColor:HEX_COLOR(0x4A90E2) forState:UIControlStateNormal];
    self.forgetButton.titleLabel.font = JA_REGULAR_FONT(15);
    [self.forgetButton sizeToFit];
    self.forgetButton.right = self.loginBtn.right;
    self.forgetButton.y = self.loginBtn.bottom + 25;
    [self.forgetButton addTarget:self action:@selector(forgetPassword) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.forgetButton];
    
    self.platformView = [[UIView alloc] init];
    self.platformView.backgroundColor = [UIColor clearColor];
    self.platformView.frame = CGRectMake(0, JA_SCREEN_HEIGHT - KiPhoneSafeArea - 70, JA_SCREEN_WIDTH, 40);
    [self.bgView addSubview:self.platformView];
    
    self.wxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.wxButton setImage:[UIImage imageNamed:@"branch_login_wx"] forState:UIControlStateNormal];
    self.wxButton.width = 40;
    self.wxButton.height = 40;
    self.wxButton.centerX = self.platformView.width * 0.5;
    [self.wxButton addTarget:self action:@selector(clickWXButton) forControlEvents:UIControlEventTouchUpInside];
    [self.platformView addSubview:self.wxButton];
    
    self.qqButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.qqButton setImage:[UIImage imageNamed:@"branch_login_qq"] forState:UIControlStateNormal];
    self.qqButton.width = 40;
    self.qqButton.height = 40;
    self.qqButton.x = self.wxButton.x - 100;
    [self.qqButton addTarget:self action:@selector(clickQQButton) forControlEvents:UIControlEventTouchUpInside];
    [self.platformView addSubview:self.qqButton];
    
    self.wbButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.wbButton setImage:[UIImage imageNamed:@"branch_login_wb"] forState:UIControlStateNormal];
    self.wbButton.width = 40;
    self.wbButton.height = 40;
    self.wbButton.x = self.wxButton.right + 60;
    [self.wbButton addTarget:self action:@selector(clickWBButton) forControlEvents:UIControlEventTouchUpInside];
    [self.platformView addSubview:self.wbButton];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.phoneNumT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordT];
    
//    if (iPhone4 || iPhone5) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyWillShowNote:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
}

#pragma mark - 通知的监听
- (void)loginSuccess
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 三方绑定手机
- (void)bindPhone:(NSNotification *)noti
{
    JAPlatformBindingPhoneViewController *vc = [[JAPlatformBindingPhoneViewController alloc] init];
    vc.platformInfo = noti.userInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)textFieldChanged:(NSNotification *)note{
    if (self.passwordT.text.length) {
        self.loginBtn.enabled = YES;
    } else{
        self.loginBtn.enabled = NO;
    }
}


#pragma mark - 三方点击事件
- (void)clickWXButton
{
    [[JALoginManager shareInstance] loginWithType:JALoginType_Wechat];
}

- (void)clickQQButton
{
    [[JALoginManager shareInstance] loginWithType:JALoginType_QQ];
}

- (void)clickWBButton
{
    [[JALoginManager shareInstance] loginWithType:JALoginType_Weibo];
}

#pragma mark - 按钮点击
- (void)pwdShow:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.passwordT.secureTextEntry = !self.passwordT.secureTextEntry;
}

#pragma mark - 忘记密码
- (void)forgetPassword
{
    JAResetPasswordVC *vc = [[JAResetPasswordVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 手机号码输入
- (void)inputPhone:(UITextField *)textField
{
    self.phoneString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (self.phoneString.length >= 11) {
//        [textField resignFirstResponder];
//        [self.passwordT becomeFirstResponder];
        [self.passwordT performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];

    }
}

#pragma mark - 点击登录
- (void)loginAccount
{
    if (![JAAPPManager isConnect]) {
        [self.view ja_makeToast:@"当前网络不可用"];
        
        return;
    }
    
    if (!self.phoneString.length) {
        
        [self.view ja_makeToast:@"请输入手机号"];
        
        return;
    }
    
    
    if (![JARegex RegexLoginPhoneNum:self.phoneString]) {
        [self.view ja_makeToast:@"手机号码格式不正确"];
        return;
    }
    
    if (!self.passwordT.text) {
        [self.view ja_makeToast:@"密码不能为空"];
        
        return;
    }
    [self.view endEditing:YES];
    NSString *pwd = [self.passwordT.text md5_origin];
    
    [MBProgressHUD showMessage:nil];
    [[JAUserApiRequest shareInstance] loginUserWithPhone:self.phoneString password:pwd success:^(NSDictionary * result){
   
        [MBProgressHUD hideHUD];
        [JAAPPManager app_loginSuccessWithResult:result loginType:0];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
       
    }];
}



#pragma mark - 私有方法
- (UIImageView *)imageItemWithFrame:(CGRect)frame imageName:(NSString *)imageName{
    UIImageView *imgV = [[UIImageView alloc] initWithFrame:frame];
    imgV.image = [UIImage imageNamed:imageName];
    return imgV;
}

- (UITextField *)textFieldItemWithFrame:(CGRect)frame placeHolder:(NSString *)placeHolder{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    textField.font = [UIFont systemFontOfSize:17];
    textField.textColor = HEX_COLOR(0x444444);
    textField.placeholder = placeHolder;
    return textField;
}

- (UIView *)separateLineWithY:(CGFloat)y{
    UIView *line =[[UIView alloc] initWithFrame:CGRectMake(kIconLeadingGap-2, y, JA_SCREEN_WIDTH-2*kIconLeadingGap+4, 1)];
    line.backgroundColor = HEX_COLOR(0xf0f0f0);
    return line;
}

#pragma mark - 手机号码格式化
// 手机号码输入
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField) {
        NSString* text = textField.text;
        //删除
        if([string isEqualToString:@""]){
            
            //删除一位
            if(range.length == 1){
                //最后一位,遇到空格则多删除一次
                if (range.location == text.length-1 ) {
                    if ([text characterAtIndex:text.length-1] == ' ') {
                        [textField deleteBackward];
                    }
                    return YES;
                }
                //从中间删除
                else{
                    NSInteger offset = range.location;
                    
                    if (range.location < text.length && [text characterAtIndex:range.location] == ' ' && [textField.selectedTextRange isEmpty]) {
                        [textField deleteBackward];
                        offset --;
                    }
                    [textField deleteBackward];
                    textField.text = [self parseString:textField.text];
                    UITextPosition *newPos = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
                    textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
                    return NO;
                }
            }
            else if (range.length > 1) {
                BOOL isLast = NO;
                //如果是从最后一位开始
                if(range.location + range.length == textField.text.length ){
                    isLast = YES;
                }
                [textField deleteBackward];
                textField.text = [self parseString:textField.text];
                
                NSInteger offset = range.location;
                if (range.location == 3 || range.location  == 8) {
                    offset ++;
                }
                if (isLast) {
                    //光标直接在最后一位了
                }else{
                    UITextPosition *newPos = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
                    textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
                }
                
                return NO;
            }
            
            else{
                return YES;
            }
        }
        
        else if(string.length >0){
            
            //限制输入字符个数
            if (([self noneSpaseString:textField.text].length + string.length - range.length > 11) ) {
                return NO;
            }
            //判断是否是纯数字(千杀的搜狗，百度输入法，数字键盘居然可以输入其他字符)
            //            if(![string isNum]){
            //                return NO;
            //            }
            [textField insertText:string];
            textField.text = [self parseString:textField.text];
            
            NSInteger offset = range.location + string.length;
            if (range.location == 3 || range.location  == 8) {
                offset ++;
            }
            UITextPosition *newPos = [textField positionFromPosition:textField.beginningOfDocument offset:offset];
            textField.selectedTextRange = [textField textRangeFromPosition:newPos toPosition:newPos];
            return NO;
        }else{
            return YES;
        }
        
    }
    
    
    return YES;
    
}

-(NSString*)noneSpaseString:(NSString*)string
{
    return [string stringByReplacingOccurrencesOfString:@" " withString:@""];
}

- (NSString*)parseString:(NSString*)string
{
    if (!string) {
        return nil;
    }
    NSMutableString* mStr = [NSMutableString stringWithString:[string stringByReplacingOccurrencesOfString:@" " withString:@""]];
    if (mStr.length >3) {
        [mStr insertString:@" " atIndex:3];
    }if (mStr.length > 8) {
        [mStr insertString:@" " atIndex:8];
        
    }
    
    return  mStr;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];

}


//- (void)onKeyWillShowNote:(NSNotification *)note{
//    NSValue *value = [note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect rect = [value CGRectValue];
////    CGRect keyboardRectInkeyView = [self.view convertRect:rect fromView:nil];
//    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    [UIView animateWithDuration:[duration doubleValue] animations:^{
//        if (rect.origin.y == JA_SCREEN_HEIGHT) {
//            self.bgView.y = 0;
//            self.logoIcon.alpha = 1.0;
//        } else {
//            if (iPhone4) {
//                self.bgView.y = -110;
//            } else {
//                self.bgView.y = -70;
//            }
//            self.logoIcon.alpha = 0.0;
//        }
//    }];
//}


@end
