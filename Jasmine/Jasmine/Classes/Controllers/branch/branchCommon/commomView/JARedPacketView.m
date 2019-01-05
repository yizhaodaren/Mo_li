//
//  JARedPacketView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/18.
//  Copyright © 2017年 xujin. All rights reserved.
/*
    红包弹窗
 */

#import "JARedPacketView.h"
#import "JAUserApiRequest.h"
#import "JAOpenInvitePacketViewController.h"
#import "JAPersonalTaskViewController.h"
#import "JASwitchDefine.h"
#import "CYLTabBarController.h"

@interface JARedPacketView ()

@property (nonatomic, weak) UIView *downView;  // 底下的view

@property (nonatomic, weak) UILabel *titileLabel;
@property (nonatomic, weak) UILabel *moneyLabel;
@property (nonatomic, weak) UILabel *introduceLabel;
@property (nonatomic, weak) UIButton *getButton;


@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UILabel *label1;
@property (nonatomic, weak) UILabel *label2;
@property (nonatomic, weak) UILabel *label3;
@property (nonatomic, weak) CAShapeLayer *topShape;

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *label4;
@property (nonatomic, weak) CAShapeLayer *bottomShape;

@property (nonatomic, weak) UIButton *openButton;

@property (nonatomic, weak) UIButton *closeButton;

@property (nonatomic, assign) BOOL openSuccess;
@end

@implementation JARedPacketView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPacket];
    }
    return self;
}

- (void)setupPacket
{
    
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    
    UIView *downView = [[UIView alloc] init];
    _downView = downView;
    downView.backgroundColor = HEX_COLOR(0xF0E1D5);
    downView.width = WIDTH_ADAPTER(320);
    downView.height = WIDTH_ADAPTER(400);
    downView.centerX = self.width * 0.5;
    downView.centerY = self.height * 0.5;
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
    [openBtn setImage:[UIImage imageNamed:@"packet_open"] forState:UIControlStateNormal];
    openBtn.width = WIDTH_ADAPTER(90);
    openBtn.height = openBtn.width;
    openBtn.centerX = downView.width * 0.5;
    openBtn.centerY = topView.bottom - WIDTH_ADAPTER(10);
    [openBtn addTarget:self action:@selector(openPacket) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:openBtn];
   
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"packet_close"] forState:UIControlStateNormal];
    closeButton.width = 34;
    closeButton.height = 34;
    closeButton.x = downView.width - 15 - closeButton.width;
    closeButton.y = 15;
    [closeButton addTarget:self action:@selector(clickCloseButton) forControlEvents:UIControlEventTouchUpInside];
    [downView addSubview:closeButton];
    
}

- (void)setUpViewSubViews
{
    UILabel *label1 = [[UILabel alloc] init];
    _label1 = label1;
    label1.text = @"恭喜您获得";
    label1.textColor = HEX_COLOR(0xFFE2B1);
    label1.font = JA_REGULAR_FONT(36);
    [label1 sizeToFit];
    label1.height = WIDTH_ADAPTER(50);
    label1.centerX = self.topView.width * 0.5;
    label1.y = WIDTH_ADAPTER(73);
    [self.topView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    _label2 = label2;
    label2.text = @"新手红包一个";
    label2.textColor = HEX_COLOR(0xFFE2B1);
    label2.font = JA_REGULAR_FONT(16);
    [label2 sizeToFit];
    label2.height = WIDTH_ADAPTER(22);
    label2.y = label1.bottom + WIDTH_ADAPTER(13);
    label2.width = self.topView.width;
    label2.centerX = self.topView.width * 0.5;
    label2.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:label2];
    
    UILabel *label3 = [[UILabel alloc] init];
    _label3 = label3;
    label3.text = @"茉莉发来的红包";
    label3.textColor = HEX_COLOR(0xDDBC84);
    label3.font = JA_REGULAR_FONT(16);
    label3.width = self.topView.width;
    label3.height = WIDTH_ADAPTER(22);
    label3.centerX = self.topView.width * 0.5;
    label3.y = label2.bottom + WIDTH_ADAPTER(30);
    label3.textAlignment = NSTextAlignmentCenter;
    [self.topView addSubview:label3];
    
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
    moneyLabel.textAlignment = NSTextAlignmentCenter;
    moneyLabel.width = self.downView.width;
    moneyLabel.height = WIDTH_ADAPTER(67);
    moneyLabel.centerX = titileLabel.centerX;
    moneyLabel.y = titileLabel.bottom;
    [self.downView addSubview:moneyLabel];
    
    UILabel *introduceLabel = [[UILabel alloc] init];
    _introduceLabel = introduceLabel;
    introduceLabel.text = @"已存入您的收入余额";
    introduceLabel.textColor = HEX_COLOR(0x4A4A4A);
    introduceLabel.font = JA_REGULAR_FONT(14);
    [introduceLabel sizeToFit];
    introduceLabel.width = self.downView.width;
    introduceLabel.centerX = titileLabel.centerX;
    introduceLabel.y = moneyLabel.bottom + WIDTH_ADAPTER(20);
    introduceLabel.textAlignment = NSTextAlignmentCenter;
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
    if (!IS_LOGIN) {
        [self removeFromSuperview];
        [JAAPPManager app_modalRegist];
        return;
    }
    
    self.openButton.userInteractionEnabled = NO;
    [self.openButton setImage:[UIImage imageNamed:@"packet_money"] forState:UIControlStateNormal];
    
    [UIView transitionWithView:self.openButton duration:0.2 options:UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionCurveLinear animations:^{
        [UIView setAnimationRepeatCount:MAXFLOAT];//动画的重复次数
        
    } completion:^(BOOL finished) {}];
    
    [self openPacketWithServer:^(BOOL requestSuccess) {
        
        if (requestSuccess) {  // 网络请求成功
            
            self.openSuccess = YES;
            
            // 移除红包
            AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            
            if (myAppDelegate.packetArray.count > 0) {
                
                [myAppDelegate.packetArray removeObjectAtIndex:0];  // 开红包 立即从列表移除红包
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.openButton.layer removeAllAnimations];
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.openButton.y = WIDTH_ADAPTER(56);
                    
                    self.topView.y = WIDTH_ADAPTER(164) - self.topView.height;
                    self.bottomView.y = self.downView.bottom;
                    
                    self.label1.y = -100;
                    self.label2.y = -100;
                    self.label3.centerY = self.closeButton.centerY - self.topView.y;
                }];
            });
        }else{  // 网络请求失败
            
            [self.openButton.layer removeAllAnimations];
            self.openButton.userInteractionEnabled = YES;
            self.openSuccess = NO;
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"红包开启失败，请重试"];
            [self.openButton setImage:[UIImage imageNamed:@"packet_open"] forState:UIControlStateNormal];
        }
    }];
}

// 请求服务器，确定开奖金额
- (void)openPacketWithServer:(void(^)(BOOL requestSuccess))successBlock
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = self.packetDic[@"id"];
    
    [[JAUserApiRequest shareInstance] userOpenPacket:dic success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(YES);
        }
        
    } failure:^(NSError *error) {
        if (successBlock) {
            successBlock(NO);
        }
    }];
    
}


- (void)setPacketDic:(NSDictionary *)packetDic
{
    _packetDic = packetDic;
    
    // 获取展示字段
    NSArray *showTexts = [self.packetDic[@"content"] componentsSeparatedByString:@","];
    
    self.label2.text = [showTexts.firstObject length] ? showTexts.firstObject : @"红包一个";
    self.label3.text = [showTexts[1] length] ? showTexts[1] : @"茉莉发来的红包";
    self.introduceLabel.text = [showTexts.lastObject length] ? showTexts.lastObject : @"已存入您的收入余额";
    
    if ([self.packetDic[@"type"] isEqualToString:@"register"]){    // 开注册红包
        [self.getButton setTitle:@"查看更多赚钱方式" forState:UIControlStateNormal];
    }else{
        [self.getButton setTitle:@"确定" forState:UIControlStateNormal];
    }
    
    self.moneyLabel.text = [NSString stringWithFormat:@"¥%@",[self decimalNumberWithDouble:[self.packetDic[@"money"] doubleValue]]];
}

/** 直接传入精度丢失有问题的Double类型*/
- (NSString *)decimalNumberWithDouble:(double)conversionValue{
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}

- (void)clickButton
{
    if ([self.packetDic[@"type"] isEqualToString:@"register"] && ![self.getButton.currentTitle isEqualToString:@"确定"]){
        JABaseViewController *currentVC = (JABaseViewController *)[self currentViewController];
        [self removeFromSuperview];
        JAPersonalTaskViewController *vc = [JAPersonalTaskViewController new];
        [currentVC.navigationController pushViewController:vc animated:YES];
    }else{
        
        if (self.openClose) {    // 2.6.0 新的逻辑
            self.openClose(YES);
        }
        
        [self removeFromSuperview];
    }
}

- (void)clickCloseButton
{
    
    if (self.openSuccess) {
        if (self.openClose) {    // 2.6.0 新的逻辑
            self.openClose(YES);
        }
    }else{
        
        if (self.unOpenClose) {      // 2.6.0 新的逻辑
            self.unOpenClose();
        }
    }

    [self removeFromSuperview];
}

- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    return [self findBestViewController:tab];
}
@end
