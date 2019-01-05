//
//  JAResetPasswordVC.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/17.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAResetPasswordVC.h"
#import "NSTimer+JABlocksSupport.h"
#import "JAUserApiRequest.h"
#import "JAIMManager.h"


static CGFloat const kIconLeadingGap = 22;

@interface JAResetPasswordVC ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *phoneNumT;
@property (nonatomic, strong) UITextField *vertifyNumT;
@property (nonatomic, strong) UITextField *passwordT;
@property (nonatomic, strong) UIButton *getVertfBtn;
@property (nonatomic, strong) UIButton *resetBtn;
@property (nonatomic, strong) NSTimer *pollTimer;
@property (nonatomic, assign) NSInteger timeNum;

@property (nonatomic, weak) UIButton *eyeButton;
@property (nonatomic, strong) NSString *phoneString;

@end

@implementation JAResetPasswordVC

static NSInteger resetPhoneNumLenght;

- (void)viewDidLoad {
    [super viewDidLoad];
    resetPhoneNumLenght = 0;
    NSDictionary *dic = @{
                          NSFontAttributeName : [UIFont systemFontOfSize:13],
                          NSForegroundColorAttributeName : HEX_COLOR(0x444444)
                          };
    [self setCenterTitle:@"重置密码" withTextAttributes:dic];
    [self setUpUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"重置密码";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)stopPolling{
    [_pollTimer invalidate];
    _pollTimer = nil;
}

- (void)p_doPoll{
    if (self.timeNum>0) {
        [self.getVertfBtn setTitle:[NSString stringWithFormat:@"剩余(%zds)", self.timeNum] forState:UIControlStateDisabled];
        self.timeNum--;
    } else{
        self.getVertfBtn.enabled = YES;
        [self stopPolling];
        [self.getVertfBtn setTitle:[NSString stringWithFormat:@"剩余(60s)"] forState:UIControlStateDisabled];
        [self.getVertfBtn setTitle:[NSString stringWithFormat:@"重新获取"] forState:UIControlStateNormal];
    }
}

- (void)textFieldChanged:(NSNotification *)note{
    //    UITextField *textField = note.object;//6位验证码?
    if (self.phoneNumT.text.length&&self.vertifyNumT.text.length&&self.passwordT.text.length) {
        self.resetBtn.enabled = YES;
    } else{
        self.resetBtn.enabled = NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)setUpUI{
    
    UIImageView *phoneImg = [self imageItemWithFrame:CGRectMake(kIconLeadingGap, 68, 15, 20) imageName:@"shouji_zhuce"];
    [self.view addSubview:phoneImg];
    
    UILabel *eightSixL = [[UILabel alloc] initWithFrame:CGRectMake(phoneImg.right+17, 69, 32, 20)];
    eightSixL.font = [UIFont systemFontOfSize:17];
    eightSixL.textColor = HEX_COLOR(0x444444);
    eightSixL.text = @"+86";
    [self.view addSubview:eightSixL];
    
    UIView *vertiLine = [[UIView alloc] initWithFrame:CGRectMake(eightSixL.right+15, 69, 1, 20)];
    vertiLine.backgroundColor = HEX_COLOR(0xf0f0f0);
    [self.view addSubview:vertiLine];
    
    self.phoneNumT = [self textFieldItemWithFrame:CGRectMake(vertiLine.right+15, phoneImg.top-8, JA_SCREEN_WIDTH-125, 40) placeHolder:@"手机号"];
    [self.phoneNumT addTarget:self action:@selector(inputPhone:) forControlEvents:UIControlEventEditingChanged];
    self.phoneNumT.delegate = self;
    self.phoneNumT.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.phoneNumT];
    
    UIView *separate1 = [self separateLineWithY:self.phoneNumT.bottom];
    [self.view addSubview:separate1];
    
    UIImageView *vertifyImg = [self imageItemWithFrame:CGRectMake(kIconLeadingGap-.5, separate1.bottom+16, 17, 20) imageName:@"login_yanzheng"];
    [self.view addSubview:vertifyImg];
    
    self.vertifyNumT = [self textFieldItemWithFrame:CGRectMake(vertifyImg.right+15, vertifyImg.top-8, JA_SCREEN_WIDTH-140, 40) placeHolder:@"输入验证码"];
    self.vertifyNumT.keyboardType = UIKeyboardTypeNumberPad;
    [self.view addSubview:self.vertifyNumT];
    
    self.getVertfBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.vertifyNumT.right, vertifyImg.top-8, 68, 37)];
    self.getVertfBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.getVertfBtn setTitleColor:HEX_COLOR(0x444444) forState:UIControlStateNormal];
    [self.getVertfBtn setTitleColor:HEX_COLOR(0x7e8392) forState:UIControlStateDisabled];
    [self.getVertfBtn setTitle:[NSString stringWithFormat:@"剩余(60s)"] forState:UIControlStateDisabled];
    [self.getVertfBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
    [self.getVertfBtn addTarget:self action:@selector(getVertfy) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.getVertfBtn];
    
    UIView *separate2 = [self separateLineWithY:self.vertifyNumT.bottom];
    [self.view addSubview:separate2];
    
    UIImageView *passwordImg = [self imageItemWithFrame:CGRectMake(kIconLeadingGap-.5, separate2.bottom+16, 17, 20) imageName:@"mima_zhuce"];
    [self.view addSubview:passwordImg];
    
    self.passwordT = [self textFieldItemWithFrame:CGRectMake(passwordImg.right+15, passwordImg.top-8, JA_SCREEN_WIDTH-65, 40) placeHolder:@"设置新密码（不少于6位）"];
    self.passwordT.secureTextEntry = YES;
    [self.view addSubview:self.passwordT];
    
    UIButton *eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _eyeButton = eyeButton;
    [eyeButton setImage:[UIImage imageNamed:@"暗纹"] forState:UIControlStateNormal];
    [eyeButton setImage:[UIImage imageNamed:@"明文"] forState:UIControlStateSelected];
    [eyeButton addTarget:self action:@selector(pwdShow:) forControlEvents:UIControlEventTouchUpInside];
    eyeButton.frame = CGRectMake(self.getVertfBtn.x, self.passwordT.y, self.getVertfBtn.width, self.passwordT.height);
    [self.view addSubview:eyeButton];
    
    UIView *separate3 =[self separateLineWithY:self.passwordT.bottom];
    [self.view addSubview:separate3];
    
    self.resetBtn = [[UIButton alloc] initWithFrame:CGRectMake((JA_SCREEN_WIDTH-180)*.5, separate3.bottom+65, 180, 50)];
    self.resetBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.resetBtn setBackgroundColor:HEX_COLOR(0x464c56)];
    [self.resetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.resetBtn setTitleColor:HEX_COLOR(0x7d848e) forState:UIControlStateDisabled];
    self.resetBtn.enabled = NO;
    [self.resetBtn setTitle:@"修改密码并登录" forState:UIControlStateNormal];
    [self.resetBtn addTarget:self action:@selector(resetPassword:) forControlEvents:UIControlEventTouchUpInside];
    self.resetBtn.layer.cornerRadius = self.resetBtn.height*.5;
    [self.view addSubview:self.resetBtn];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.phoneNumT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.vertifyNumT];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldChanged:) name:UITextFieldTextDidChangeNotification object:self.passwordT];
    
}

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

- (void)pwdShow:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.passwordT.secureTextEntry = !self.passwordT.secureTextEntry;
}

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
// 手机号码输入
- (void)inputPhone:(UITextField *)textField
{
    self.phoneString = [textField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
}

// 获取验证码
- (void)getVertfy{
    
    if (!self.phoneString.length) {
        
        NSLog(@"填写手机号");
        [self.view ja_makeToast:@"请输入手机号"];
        
        return;
    }
    
    if (![JARegex RegexMobileNumber:self.phoneString]) {
        [self.view ja_makeToast:@"手机号码格式不正确"];
        return;
    }
    
    NSString *phoneNum = [NSString stringWithFormat:@"%@",self.phoneString];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"phone"] = phoneNum;
    dic[@"functionType"] = @"1";
    dic[@"distinctId"] = [[SensorsAnalyticsSDK sharedInstance] distinctId];
    [[JAUserApiRequest shareInstance] getVerifyCodeWithPhone:dic success:^(NSDictionary *result) {
        [self.view ja_makeToast:@"发送成功"];

        self.timeNum = 59;
        self.getVertfBtn.enabled = NO;
        __weak JAResetPasswordVC *weakSelf = self;
        _pollTimer = [NSTimer ja_scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
            [weakSelf p_doPoll];
        }];
    } failure:^(NSError *error) {
        if (error.code != 123500) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }
    }];

    
}

// 修改密码
- (void)resetPassword:(UIButton *)btn
{
    
    if (!self.phoneString.length) {
        
        [self.view ja_makeToast:@"请输入手机号"];
        
        return;
    }
    
    if (![JARegex RegexMobileNumber:self.phoneString]) {
        [self.view ja_makeToast:@"手机号码格式不正确"];
        return;
    }
    
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
    }
    
    [MBProgressHUD showMessage:nil];
    NSString *pwd = [self.passwordT.text md5_origin];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"phone"] = self.phoneString;
    dic[@"authNum"] = self.vertifyNumT.text;
    dic[@"password"] = pwd;
    [[JAUserApiRequest shareInstance] resetPasswordWithPara:dic success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        // 修改成功后，登录
        [[JAUserApiRequest shareInstance] loginUserWithPhone:self.phoneString password:pwd success:^(NSDictionary * result){
          
            [JAAPPManager app_loginSuccessWithResult:result loginType:0];
            
            [self dismissViewControllerAnimated:YES completion:nil];
           
        } failure:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        
    }];
    
}
@end
