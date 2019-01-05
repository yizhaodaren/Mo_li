//
//  JANewRegistrationViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/16.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANewRegistrationViewController.h"
#import "JARegistSecondViewController.h"
#import "JALoginViewController.h"

#import "SFAttriLab.h"

#import "JAUserApiRequest.h"
#import "JAPlatformBindingPhoneViewController.h"
#import "JACommonApi.h"
#import "JALoginManager.h"
#import "JAWebViewController.h"
#import "JAPlayWaveView.h"
#import "JAAudioPlayer.h"
#import "JASwitchDefine.h"

#import "NSTimer+JABlocksSupport.h"
#import <WXApi.h>
#import "JAVoicePlayerManager.h"

#define KiPhoneSafeArea (iPhoneX ? (64+58) : 64)

static CGFloat const kIconLeadingGap = 22;

@interface JANewRegistrationViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *logoIcon;

@property (nonatomic, strong) UIImageView *phoneImg;
@property (nonatomic, strong) UITextField *phoneNumT;
@property (nonatomic, strong) UIButton *nextBtn;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, strong) NSString *phoneString;

@property (nonatomic, strong) UIView *platformView;
@property (nonatomic, strong) UIButton *qqButton;
@property (nonatomic, strong) UIButton *wxButton;
@property (nonatomic, strong) UIButton *wbButton;

// v2.4.0
@property (nonatomic, strong) JAPlayWaveView *playWaveView;
@property (nonatomic, weak) UIButton *playButton;

@property (nonatomic, strong) NSString *frontPhoneString;

// 定时器 2.5.5
@property (nonatomic, strong) NSTimer *pollTimer;
@property (nonatomic, assign) NSInteger timeNum;

@end

@implementation JANewRegistrationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.timeNum = 59;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needRegistVoice"]){
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
    
    // 隐藏微信按钮
    if ([WXApi isWXAppInstalled]) {
        self.wxButton.hidden = NO;
    }else{
        self.wxButton.hidden = YES;
    }
    [JALoginManager shareInstance].vc = self;
}

// 神策统计
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"注册";
//    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    [JASensorsAnalyticsManager sensorsAnalytics_registPagebrowseViewPage:dic];
    
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needRegistVoice"]){
        NSString *audioFile=[[NSBundle mainBundle] pathForResource:@"signup.mp3" ofType:nil];
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

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needRegistVoice"]){
        [self.playWaveView stopAnimation];
        self.playWaveView.hidden = YES;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"needRegistVoice"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)dealloc
{
    [[JAAudioPlayer shareInstance] stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UI
- (void)setupNavigator
{
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:YES];
    
    // 设置左边的按钮
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"branch_login_close"] highlightImage:[UIImage imageNamed:@"branch_login_close"]];
    // 设置右边的按钮
//    [self setNavRightTitle:@"去登录" color:HEX_COLOR(0x444444)];
    [self setupNavRightButton];
}


// 设置右边导航按钮
- (void)setupNavRightButton
{
    UIButton *goLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [goLoginBtn setTitle:@"去登录" forState:UIControlStateNormal];
    [goLoginBtn setTitleColor:HEX_COLOR(0x444444) forState:UIControlStateNormal];
    goLoginBtn.titleLabel.font = JA_MEDIUM_FONT(15);
    CGSize textSize = [[goLoginBtn titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : goLoginBtn.titleLabel.font}];
    [goLoginBtn setFrame:CGRectMake(0, 0, textSize.width, 30)];
    [goLoginBtn addTarget:self action:@selector(actionRight) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *goLoginItem = [[UIBarButtonItem alloc] initWithCustomView:goLoginBtn];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"needRegistVoice"])
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


- (void)setUpUI
{
    self.bgView = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.bgView];
    
    self.logoIcon = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH-80)*.5, WIDTH_ADAPTER(20), 80, 80) imageName:@"login_icon"];
    [self.bgView addSubview:self.logoIcon];
    
    self.phoneImg = [self imageItemWithFrame:CGRectMake((JA_SCREEN_WIDTH - 300) * 0.5, self.logoIcon.bottom + 31, 19, 22) imageName:@"branch_login_phone"];
    [self.bgView addSubview:self.phoneImg];
    
    UILabel *eightSixL = [[UILabel alloc] initWithFrame:CGRectMake(self.phoneImg.right+10.5, self.phoneImg.y, 30, 22)];
    eightSixL.font = JA_REGULAR_FONT(14);
    eightSixL.textColor = HEX_COLOR(JA_Three_Title);
    eightSixL.text = @"+86";
    [self.bgView addSubview:eightSixL];
    
    UIView *vertiLine = [[UIView alloc] init];
    vertiLine.x = eightSixL.right + 10;
    vertiLine.width = 1;
    vertiLine.height = 20;
    vertiLine.centerY = eightSixL.centerY;
    vertiLine.backgroundColor = HEX_COLOR(JA_Line);
    [self.bgView addSubview:vertiLine];
    
    self.phoneNumT = [self textFieldItemWithFrame:CGRectMake(vertiLine.right+10, self.phoneImg.top-4, 300 - vertiLine.right+10, 30) placeHolder:@"手机号"];
    [self.phoneNumT addTarget:self action:@selector(inputPhone:) forControlEvents:UIControlEventEditingChanged];
    self.phoneNumT.delegate = self;
    self.phoneNumT.keyboardType = UIKeyboardTypeNumberPad;
    [self.bgView addSubview:self.phoneNumT];
    
    UIView *separate1 = [self separateLineWithY:self.phoneImg.bottom + 10];
    [self.bgView addSubview:separate1];
    
    self.nextBtn = [[UIButton alloc] initWithFrame:CGRectMake((JA_SCREEN_WIDTH-300)*.5, separate1.bottom+40, 300, 40)];
    self.nextBtn.titleLabel.font = JA_MEDIUM_FONT(16);
    [self.nextBtn setBackgroundColor:HEX_COLOR(0xffffff)];
    [self.nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.nextBtn.enabled = NO;
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xE2E2E2)] forState:UIControlStateDisabled];
    [self.nextBtn setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(JA_Green)] forState:UIControlStateNormal];
    [self.nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
    [self.nextBtn addTarget:self action:@selector(registButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    self.nextBtn.layer.cornerRadius = self.nextBtn.height*.5;
    self.nextBtn.clipsToBounds = YES;
    [self.bgView addSubview:self.nextBtn];
    
    if (![[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        if ([JAConfigManager shareInstance].isDebug.integerValue == 0) {
            self.introduceLabel = [[UILabel alloc] init];
            self.introduceLabel.text = @"注册成功可获得1元现金红包支持微信提现";
            self.introduceLabel.textColor = HEX_COLOR(0xFF8743);
            self.introduceLabel.font = JA_REGULAR_FONT(13);
            self.introduceLabel.frame = CGRectMake(0, self.nextBtn.bottom + 16, JA_SCREEN_WIDTH, 14);
            self.introduceLabel.textAlignment = NSTextAlignmentCenter;
            [self.bgView addSubview:self.introduceLabel];
        }
    }
    
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
  
//    if (iPhone4 || iPhone5) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyWillShowNote:) name:UIKeyboardWillChangeFrameNotification object:nil];
//    }
}

- (void)actionRight
{
    [self dismissViewControllerAnimated:NO completion:nil];
//    // 进入登录控制器
//    JALoginViewController *vc = [[JALoginViewController alloc] init];
//    JABaseNavigationController *loginNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
//    [[AppDelegateModel rootviewController] presentViewController:loginNav animated:YES completion:nil];
    
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
        senDic[JA_Property_ScreenName] = @"注册";
        [JASensorsAnalyticsManager sensorsAnalytics_shutUp:senDic];
    } else {
        [self.playWaveView startAnimation];
        self.playWaveView.hidden = NO;
        self.playButton.selected = NO;
        [[JAAudioPlayer shareInstance] continuePlay];
    }
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

#pragma mark - 手机号码输入
// 手机号码输入
- (void)inputPhone:(UITextField *)textField
{
    self.nextBtn.enabled = YES;
    self.phoneString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 注册按钮
- (void)registButtonClick:(UIButton *)btn
{
    
    // 发送验证码
    if (!self.phoneString.length) {
        
        [self.view ja_makeToast:@"请输入手机号"];
        return;
    }
    
    if (![JARegex RegexMobileNumber:self.phoneString]) {
        [self.view ja_makeToast:@"手机号码格式不正确"];
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_Phone] = self.phoneString;
        senDic[JA_Property_CodeType] = @"注册";
        senDic[JA_Property_IsSendRequest] = @(NO);
        [JASensorsAnalyticsManager sensorsAnalytics_clickRegistCode:senDic];
        return;
    }
    
    // 获取验证码在时效内 直接跳转
    if (self.timeNum < 59 && self.timeNum > 0 && [self.frontPhoneString isEqualToString:self.phoneString]) {
        
        JARegistSecondViewController *vc = [[JARegistSecondViewController alloc] init];
        vc.phoneString = self.phoneString;
        vc.timeNum = self.timeNum;
        @WeakObj(self);
        vc.againGetCode = ^{
            @StrongObj(self);
            _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
                @StrongObj(self);
                [self p_doPoll];
            }];
        };
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    if (![self.frontPhoneString isEqualToString:self.phoneString] || self.timeNum == 59) {
        
        [self stopPolling];   // 号码改变就停止定时器，重置
        self.frontPhoneString = self.phoneString;
        
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
            
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"短信验证码已发出"];
            
            @WeakObj(self);
            _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
                @StrongObj(self);
                [self p_doPoll];
            }];
            
            JARegistSecondViewController *vc = [[JARegistSecondViewController alloc] init];
            vc.phoneString = self.phoneString;
            vc.timeNum = self.timeNum;
            vc.againGetCode = ^{
                @StrongObj(self);
                _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
                    @StrongObj(self);
                    [self p_doPoll];
                }];
            };
            [self.navigationController pushViewController:vc animated:YES];
            
        } failure:^(NSError *error) {
            
            [MBProgressHUD hideHUD];
            btn.userInteractionEnabled = YES;
            
            if (error.code == 123500) {
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"手机号码已经注册,是否直接登录？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    [self dismissViewControllerAnimated:NO completion:nil];
//                    //                [JAAPPManager app_modalLogin];
//                    JALoginViewController *vc = [[JALoginViewController alloc] init];
//                    vc.loginPhone = self.phoneNumT.text;
//                    JABaseNavigationController *loginNav = [[JABaseNavigationController alloc] initWithRootViewController:vc];
//                    [[AppDelegateModel rootviewController] presentViewController:loginNav animated:YES completion:nil];
//                }];
//                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//                }];
//                [alert addAction:action1];
//                [alert addAction:action2];
//                [self presentViewController:alert animated:YES completion:nil];
                
                JALoginViewController *vc = [[JALoginViewController alloc] init];
                vc.loginPhone = self.phoneString;
                [self.navigationController pushViewController:vc animated:YES];
                
            }else if (error.code == 122800){
                [[UIApplication sharedApplication].delegate.window ja_makeToast:@"短信验证码已发出"];
                
                @WeakObj(self);
                _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
                    @StrongObj(self);
                    [self p_doPoll];
                }];
                
                JARegistSecondViewController *vc = [[JARegistSecondViewController alloc] init];
                vc.phoneString = self.phoneString;
                vc.timeNum = self.timeNum;
                vc.againGetCode = ^{
                    @StrongObj(self);
                    _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
                        @StrongObj(self);
                        [self p_doPoll];
                    }];
                };
                [self.navigationController pushViewController:vc animated:YES];
            }else{
                
                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
            }
        }];
    }

}


#pragma mark - 定时器
- (void)stopPolling{
    self.timeNum = 59;
    [_pollTimer invalidate];
    _pollTimer = nil;
}

- (void)p_doPoll{
    if (self.timeNum>0) {
       
        self.timeNum--;
    } else{
        [self stopPolling];
    }
}

//- (void)onKeyWillShowNote:(NSNotification *)note{
//    NSValue *value = [note.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    CGRect rect = [value CGRectValue];
//    //    CGRect keyboardRectInkeyView = [self.view convertRect:rect fromView:nil];
//    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    [UIView animateWithDuration:[duration doubleValue] animations:^{
//        if (rect.origin.y == JA_SCREEN_HEIGHT) {
//            self.bgView.y = 0;
//            self.logoIcon.alpha = 1.0;
//        } else {
//            if (iPhone6) {
//                self.bgView.y = -80;
//            } else {
//                self.bgView.y = -110;
//            }
//            self.logoIcon.alpha = 0.0;
//        }
//    }];
//}


#pragma mark - UI相关私有方法
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


#pragma mark - 手机号的输入设置
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


#pragma mark - 计算名字的长度（一个汉字占两个字符）
- (NSInteger)caculaterName:(NSString *)name
{
    NSInteger length = [name lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    length -= (length - name.length) / 2;
    //    length = (length +1) / 2;
    return length;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

@end
