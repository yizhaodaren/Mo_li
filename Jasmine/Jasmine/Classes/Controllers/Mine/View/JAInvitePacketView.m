//

//  Jasmine
//
//  Created by moli-2017 on 2017/8/18.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAInvitePacketView.h"
#import "JAUserApiRequest.h"

@interface JAInvitePacketView ()

@property (nonatomic, weak) UIView *downView;  // 底下的view

@property (nonatomic, weak) UILabel *titileLabel;
@property (nonatomic, weak) UILabel *moneyLabel;
@property (nonatomic, weak) UILabel *introduceLabel;
@property (nonatomic, weak) UIButton *getButton;


@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UILabel *label1;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, weak) CAShapeLayer *topShape;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *label4;
@property (nonatomic, weak) CAShapeLayer *bottomShape;

@property (nonatomic, weak) UIButton *openButton;

@property (nonatomic, weak) UIButton *closeButton;
@end

@implementation JAInvitePacketView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPacket];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickView)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupPacket
{
    
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
//    self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    
    UIView *downView = [[UIView alloc] init];
    _downView = downView;
    downView.backgroundColor = HEX_COLOR(0xF0E1D5);
    downView.width = WIDTH_ADAPTER(320);
    downView.height = WIDTH_ADAPTER(400);
    downView.centerX = self.width * 0.5;
    downView.y = 100;
    downView.layer.cornerRadius = 8;
    downView.clipsToBounds = YES;
    [self addSubview:downView];
    
    [self setPacketView];
    
    UIView *topView = [[UIView alloc] init];
    _topView = topView;
    topView.width = downView.width;
    topView.height = WIDTH_ADAPTER(296);
    topView.backgroundColor = [UIColor clearColor];
    [downView addSubview:topView];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView  = bottomView ;
    bottomView.width = downView.width;
    bottomView.height = WIDTH_ADAPTER(160);
    bottomView.y = WIDTH_ADAPTER(240);
    bottomView.backgroundColor = [UIColor clearColor];
    [downView insertSubview:bottomView belowSubview:topView];
    
    // 创建第一个形状层
    CAShapeLayer *bottomCurveLayer = [[CAShapeLayer alloc]init];
    
    UIBezierPath *path = [[UIBezierPath alloc]init];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(0, WIDTH_ADAPTER(240)+1)];
    [path addQuadCurveToPoint:CGPointMake(downView.width, WIDTH_ADAPTER(240)+1) controlPoint:CGPointMake(downView.width / 2, WIDTH_ADAPTER(296) + WIDTH_ADAPTER(35))];
    [path addLineToPoint:CGPointMake(downView.width, 0)];
    [path addLineToPoint:CGPointMake(0, 0)];
    bottomCurveLayer.path = path.CGPath;
    bottomCurveLayer.fillColor = HEX_COLOR(0xD85940).CGColor;
    [topView.layer addSublayer:bottomCurveLayer];
    
    // 创建第二个形状层
    CAShapeLayer *bottomCurveLayer1 = [[CAShapeLayer alloc]init];
    
    UIBezierPath *path1 = [[UIBezierPath alloc]init];
    [path1 moveToPoint:CGPointMake(0, 0)];
    [path1 addLineToPoint:CGPointMake(0, WIDTH_ADAPTER(160))];
    [path1 addLineToPoint:CGPointMake(downView.width, WIDTH_ADAPTER(160))];
    [path1 addLineToPoint:CGPointMake(downView.width, 0)];
    [path1 addQuadCurveToPoint:CGPointMake(0, 0) controlPoint:CGPointMake(downView.width / 2, WIDTH_ADAPTER(56) + WIDTH_ADAPTER(34))];
    bottomCurveLayer1.path = path1.CGPath;
    bottomCurveLayer1.fillColor = HEX_COLOR(0xCD533D).CGColor;
    [bottomView.layer addSublayer:bottomCurveLayer1];
    
    [self setUpViewSubViews];
    
    UIButton *openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _openButton = openBtn;
    [openBtn setImage:[UIImage imageNamed:@"packet_chai"] forState:UIControlStateNormal];
    openBtn.width = WIDTH_ADAPTER(90);
    openBtn.height = openBtn.width;
    openBtn.centerX = downView.width * 0.5;
    openBtn.centerY = topView.bottom - WIDTH_ADAPTER(10);
    [openBtn addTarget:self action:@selector(openPacket) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:openBtn];
    
//    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _closeButton = closeButton;
//    [closeButton setImage:[UIImage imageNamed:@"packet_close"] forState:UIControlStateNormal];
//    closeButton.width = 34;
//    closeButton.height = 34;
//    closeButton.x = downView.width - 15 - closeButton.width;
//    closeButton.y = 15;
//    [closeButton addTarget:self action:@selector(clickCloseButton) forControlEvents:UIControlEventTouchUpInside];
//    [downView addSubview:closeButton];
    
}

- (void)setUpViewSubViews
{
    UILabel *label1 = [[UILabel alloc] init];
    _label1 = label1;
    label1.numberOfLines = 0;
    label1.text = @"输入好友/推荐人的邀请码即可领取红包";
    label1.textColor = HEX_COLOR(0xDDBC84);
    label1.font = JA_REGULAR_FONT(16);
    [label1 sizeToFit];
    label1.width = 212;
    label1.height = 44;
    label1.centerX = self.topView.width * 0.5;
    label1.y = WIDTH_ADAPTER(48);
    label1.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:label1];
 
    UITextField *textF = [[UITextField alloc] init];
    _textField = textF;
    textF.backgroundColor = [UIColor whiteColor];
    textF.placeholder = @"输入邀请码";
    textF.textAlignment = NSTextAlignmentCenter;
    textF.font = JA_LIGHT_FONT(15);
    textF.width = 215;
    textF.height = 47;
    textF.centerX = label1.centerX;
    textF.y = label1.bottom + WIDTH_ADAPTER(38);
    textF.textColor = HEX_COLOR(JA_BlackSubTitle);
    textF.layer.cornerRadius = textF.height * 0.5;
    textF.layer.borderColor = HEX_COLOR(0xA20000).CGColor;
    textF.layer.borderWidth = 2;
    textF.keyboardType = UIKeyboardTypeNumberPad;
    [textF addTarget:self action:@selector(inputInviteCode) forControlEvents:UIControlEventEditingChanged];
    [self.topView addSubview:textF];
    
    UILabel *label4 = [[UILabel alloc] init];
    _label4 = label4;
    label4.text = @"(可微信提现)";
    label4.textColor = HEX_COLOR(0xDDBC84);
    label4.font = JA_REGULAR_FONT(16);
    [label4 sizeToFit];
    label4.height = WIDTH_ADAPTER(22);
    label4.centerX = self.bottomView.width * 0.5;
    label4.y = self.bottomView.height - WIDTH_ADAPTER(28) - label4.height;;
    [self.bottomView addSubview:label4];
}

// 设置红包数据
- (void)setPacketView
{
    UILabel *titileLabel = [[UILabel alloc] init];
    _titileLabel = titileLabel;
    titileLabel.text = @"恭喜您获得";
    titileLabel.textColor = HEX_COLOR(0xD85940);
    titileLabel.font = JA_REGULAR_FONT(18);
    [titileLabel sizeToFit];
    titileLabel.centerX = self.downView.width * 0.5;
    titileLabel.y = WIDTH_ADAPTER(186);
    [self.downView addSubview:titileLabel];
    
    UILabel *moneyLabel = [[UILabel alloc] init];
    _moneyLabel = moneyLabel;
    moneyLabel.textColor = HEX_COLOR(0x4A4A4A);
    moneyLabel.text = @"¥1.00";
    moneyLabel.font = JA_MEDIUM_FONT(48);
    [moneyLabel sizeToFit];
    moneyLabel.height = WIDTH_ADAPTER(67);
    moneyLabel.y = titileLabel.bottom;
    moneyLabel.width = self.downView.width;
    moneyLabel.centerX = titileLabel.centerX;
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self.downView addSubview:moneyLabel];
    
    UILabel *introduceLabel = [[UILabel alloc] init];
    _introduceLabel = introduceLabel;
    introduceLabel.text = @"已存入您的收入余额";//@"累计签到3天再得0.5元";
    introduceLabel.textColor = HEX_COLOR(0x4A4A4A);
    introduceLabel.font = JA_REGULAR_FONT(14);
    [introduceLabel sizeToFit];
    introduceLabel.centerX = titileLabel.centerX;
    introduceLabel.y = moneyLabel.bottom + WIDTH_ADAPTER(20);
    [self.downView addSubview:introduceLabel];
    
    UIButton *getButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _getButton = getButton;
    getButton.backgroundColor = HEX_COLOR(0xD85940);
    [getButton setTitle:@"确定" forState:UIControlStateNormal];
    [getButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    getButton.titleLabel.font = JA_REGULAR_FONT(20);
    [getButton sizeToFit];
    getButton.height = WIDTH_ADAPTER(50);
    getButton.width = self.downView.width - WIDTH_ADAPTER(30);
    getButton.centerX = titileLabel.centerX;
    getButton.y = introduceLabel.bottom + WIDTH_ADAPTER(17);
    getButton.layer.cornerRadius = getButton.height * 0.5;
    [getButton addTarget:self action:@selector(clickButton) forControlEvents:UIControlEventTouchUpInside];
    [self.downView addSubview:getButton];
    
}

- (void)openPacket
{
    [self endEditing:YES];
    if (!IS_LOGIN) {
        [self removeFromSuperview];
        //        [JAAPPManager app_modalLogin];
        [JAAPPManager app_modalRegist];
        return;
    }
    
    NSString *phone = [JAUserInfo userInfo_getUserImfoWithKey:User_Phone];
    
    if (!phone.length) {
        if (self.clickOpenPack) {
            self.clickOpenPack();
        }
        return;
    }
    
    
    
    if (!self.textField.hasText) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请输入邀请码"];
        
        return;
    }
    
    if ([self.textField.text isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_uuid]]) {
        
        [self ja_makeToast:@"不能邀请自己"];
        
        return;
    }
    self.openButton.userInteractionEnabled = NO;
    // 发送邀请绑定拆红包
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"inviteUuid"] = self.textField.text;
    [[JAUserApiRequest shareInstance] userInviteBinding:dic success:^(NSDictionary *result) {
        
        self.openButton.userInteractionEnabled = NO;
        [self.openButton setImage:[UIImage imageNamed:@"packet_money"] forState:UIControlStateNormal];
        
        NSArray *arr = result[@"propertyList"];
        NSDictionary *dic = arr.firstObject;
        
        if ([dic[@"operationType"] isEqualToString:@"be_invitation"]) {
            self.introduceLabel.text = @"已存入您的收入余额";//@"累计签到3天再得0.5元";
            [self.introduceLabel sizeToFit];
        }else{
            self.introduceLabel.text = @"已存入您的收入余额";
            [self.introduceLabel sizeToFit];
        }
        
        NSString *money = [NSString stringWithFormat:@"%@",dic[@"propertyNum"]];
        self.moneyLabel.text = [NSString stringWithFormat:@"¥%@",money];
        
        [JAUserInfo userInfo_updataUserInfoWithKey:User_InviteUuid value:self.textField.text];
        
        [UIView transitionWithView:self.openButton duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveLinear animations:^{
            [UIView setAnimationRepeatCount:5];//动画的重复次数
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                self.openButton.y = WIDTH_ADAPTER(56);
                
                self.topView.y = WIDTH_ADAPTER(164) - self.topView.height;
                self.bottomView.y = self.downView.bottom;
                
                self.label1.y = -100;
                self.textField.y = -100;
                
            }];
        }];
        
    } failure:^(NSError *error) {
        self.openButton.userInteractionEnabled = YES;
        if (error.code == 130200) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"邀请码无效"];
        }else if (error.code == 140007) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"邀请人不能比你更晚注册"];
        }else{
            [self ja_makeToast:error.localizedDescription];
        }
    }];
    
    
}

// 关闭
- (void)clickCloseButton
{
    [self removeFromSuperview];
}

//
- (void)clickButton
{
    if (self.popFrontVc) {
        self.popFrontVc();
    }
}

- (void)clickView
{
    [self endEditing:YES];
}

- (void)inputInviteCode
{
  
}
@end
