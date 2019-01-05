//
//  JAPersonIncomeHeaderView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonIncomeHeaderView.h"
#import "JAWebViewController.h"
#import "JACheckExchangeDetailViewController.h"

@interface JAPersonIncomeHeaderView ()
@property (nonatomic, strong) UILabel *flowerLabel;
@property (nonatomic, strong) UILabel *moneyLabel;
@property (nonatomic, strong) UILabel *flowerCountLabel;
@property (nonatomic, strong) UILabel *moneyCountLabel;
@property (nonatomic, strong) UIView *lineView;

//@property (nonatomic, strong) UIButton *checkFlowerButton;  // 审核花朵按钮

@property (nonatomic, strong) UIView *grayView;
@property (nonatomic, strong) UILabel *rateLabel;
@property (nonatomic, strong) UILabel *validMoneyLabel;
@property (nonatomic, strong) UILabel *rateCountLabel;
@property (nonatomic, strong) UILabel *validMoneyCountLabel;
@property (nonatomic, strong) UIButton *webButton;
@end

@implementation JAPersonIncomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPersonIncomeUI];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupPersonIncomeUI
{
    self.flowerLabel = [[UILabel alloc] init];
    self.flowerLabel.text = @"茉莉花";
    self.flowerLabel.textColor = HEX_COLOR(JA_Three_Title);
    self.flowerLabel.font = JA_MEDIUM_FONT(18);
    self.flowerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.flowerLabel];
    
    self.moneyLabel = [[UILabel alloc] init];
    self.moneyLabel.text = @"零钱";
    self.moneyLabel.textColor = HEX_COLOR(JA_Three_Title);
    self.moneyLabel.font = JA_MEDIUM_FONT(18);
    self.moneyLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.moneyLabel];
    
    self.flowerCountLabel = [[UILabel alloc] init];
    self.flowerCountLabel.text = @"0";
    self.flowerCountLabel.textColor = HEX_COLOR(0x6BD379);
    self.flowerCountLabel.font = JA_MEDIUM_FONT(36);
    self.flowerCountLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.flowerCountLabel];
    
    self.moneyCountLabel = [[UILabel alloc] init];
    self.moneyCountLabel.text = @"0";
    self.moneyCountLabel.textColor = HEX_COLOR(0x6BD379);
    self.moneyCountLabel.font = JA_MEDIUM_FONT(36);
    self.moneyCountLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.moneyCountLabel];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:self.lineView];
    
//    self.checkFlowerButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [self.checkFlowerButton setTitle:@"0朵花正在审核中" forState:UIControlStateNormal];
//    self.checkFlowerButton.backgroundColor = HEX_COLOR(0xF8E71C);
//    [self.checkFlowerButton setTitleColor:HEX_COLOR(0x8B572A) forState:UIControlStateNormal];
//    self.checkFlowerButton.titleLabel.font = JA_REGULAR_FONT(11);
//    [self.checkFlowerButton addTarget:self action:@selector(enterCheckFlowerVc) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:self.checkFlowerButton];
    
    self.grayView = [[UIView alloc] init];
    self.grayView.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    [self addSubview:self.grayView];
    
    self.rateLabel = [[UILabel alloc] init];
    self.rateLabel.text = @"昨日茉莉花兑换零钱清算:";
    self.rateLabel.textColor = HEX_COLOR(0x454C57);
    self.rateLabel.font = JA_LIGHT_FONT(13);
    [self.grayView addSubview:self.rateLabel];
    
    self.validMoneyLabel = [[UILabel alloc] init];
    self.validMoneyLabel.text = @"*茉莉花满200朵后将于次日凌晨自动兑换为零钱*";
    self.validMoneyLabel.textColor = HEX_COLOR(0xFE9254);
    self.validMoneyLabel.font = JA_LIGHT_FONT(13);
    [self.grayView addSubview:self.validMoneyLabel];
    
    self.rateCountLabel = [[UILabel alloc] init];
    self.rateCountLabel.text = @"0";
    self.rateCountLabel.textColor = HEX_COLOR(0x454C57);
    self.rateCountLabel.font = JA_LIGHT_FONT(13);
    [self.grayView addSubview:self.rateCountLabel];
    
    self.validMoneyCountLabel = [[UILabel alloc] init];
    self.validMoneyCountLabel.text = @"0元";
    self.validMoneyCountLabel.textColor = HEX_COLOR(0xFE9254);
    self.validMoneyCountLabel.font = JA_LIGHT_FONT(13);
    self.validMoneyCountLabel.hidden = YES;
    [self.grayView addSubview:self.validMoneyCountLabel];
    
    self.webButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.webButton setTitle:@"(汇率如何计算)" forState:UIControlStateNormal];
    [self.webButton setTitleColor:HEX_COLOR(0xFE9254) forState:UIControlStateNormal];
    self.webButton.titleLabel.font = JA_LIGHT_FONT(13);
    [self.webButton addTarget:self action:@selector(jumpWebviewRate) forControlEvents:UIControlEventTouchUpInside];
    self.webButton.hidden = YES;
    [self.grayView addSubview:self.webButton];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorPersonIncomeFrame];
}

- (void)caculatorPersonIncomeFrame
{
    self.flowerLabel.width = JA_SCREEN_WIDTH * 0.5;
    self.flowerLabel.height = 25;
    self.flowerLabel.y = 23;
    
    self.flowerCountLabel.width = self.flowerLabel.width;
    self.flowerCountLabel.height = 36;
    self.flowerCountLabel.y = self.flowerLabel.bottom + 10;
    
//    self.checkFlowerButton.width = 120;
//    self.checkFlowerButton.height = 18;
//    self.checkFlowerButton.layer.cornerRadius = 9;
//    self.checkFlowerButton.layer.masksToBounds = YES;
//    self.checkFlowerButton.centerX = self.flowerCountLabel.centerX;
//    self.checkFlowerButton.y = self.flowerCountLabel.bottom + 8;
    
    self.moneyLabel.width = JA_SCREEN_WIDTH * 0.5;
    self.moneyLabel.height = 25;
    self.moneyLabel.y = 23;
    self.moneyLabel.x = JA_SCREEN_WIDTH * 0.5;
    
    self.moneyCountLabel.width = self.moneyLabel.width;
    self.moneyCountLabel.height = 36;
    self.moneyCountLabel.y = self.moneyLabel.bottom + 10;
    self.moneyCountLabel.x = self.moneyLabel.x;
    
    self.lineView.width = 1;
    self.lineView.height = 60;
    self.lineView.y = 28;
    self.lineView.centerX = JA_SCREEN_WIDTH * 0.5;
    
    self.grayView.width = JA_SCREEN_WIDTH - 30;
    self.grayView.height = 50;
    self.grayView.x = 15;
    self.grayView.y = self.flowerCountLabel.bottom + 35;
    
    [self.rateLabel sizeToFit];
    self.rateLabel.height = 18;
    self.rateLabel.x = 8;
    self.rateLabel.y = 7;
    
    [self.rateCountLabel sizeToFit];
    self.rateCountLabel.height = self.rateLabel.height;
    self.rateCountLabel.x = self.rateLabel.right;
    self.rateCountLabel.y = self.rateLabel.y;
    
    [self.webButton sizeToFit];
    self.webButton.height = self.rateLabel.height;
    self.webButton.x = self.rateCountLabel.right;
    self.webButton.y = self.rateLabel.y;
    
    [self.validMoneyLabel sizeToFit];
    self.validMoneyLabel.height = self.rateLabel.height;
    self.validMoneyLabel.x = self.rateLabel.x;
    self.validMoneyLabel.y = self.rateLabel.bottom;
    
    [self.validMoneyCountLabel sizeToFit];
    self.validMoneyCountLabel.height = self.rateLabel.height;
    self.validMoneyCountLabel.x = self.validMoneyLabel.right;
    self.validMoneyCountLabel.y = self.validMoneyLabel.y;
}

- (void)setTotalMoney:(NSString *)totalMoney
{
    _totalMoney = totalMoney;
    self.moneyCountLabel.text = totalMoney;
    [self.moneyCountLabel sizeToFit];
}

- (void)setTotalFlower:(NSString *)totalFlower
{
    _totalFlower = totalFlower;
    self.flowerCountLabel.text = totalFlower;
    [self.flowerCountLabel sizeToFit];
}
- (void)setRateMoney:(NSString *)rateMoney
{
    _rateMoney = rateMoney;
    self.rateCountLabel.text = [NSString stringWithFormat:@"%@朵=%@元",self.rateFlower,rateMoney];
    [self.rateCountLabel sizeToFit];
}

//- (void)setCheckFlower:(NSString *)checkFlower
//{
//    _checkFlower = checkFlower;
//    NSString *name = [NSString stringWithFormat:@"%@朵花正在审核中",checkFlower];
//    [self.checkFlowerButton setTitle:name forState:UIControlStateNormal];
//}

- (void)setRate:(NSString *)rate
{
    _rate = rate;
    self.rateCountLabel.text = rate;
    [self.rateCountLabel sizeToFit];
}


- (void)setEnableMoney:(NSString *)enableMoney
{
    _enableMoney = enableMoney;
    self.validMoneyCountLabel.text = [NSString stringWithFormat:@"%@元",enableMoney];
    [self.validMoneyCountLabel sizeToFit];
}

// 汇率
- (void)jumpWebviewRate
{
    JAWebViewController *vc = [[JAWebViewController alloc] init];
    vc.urlString = @"http://www.urmoli.com/newmoli/views/app/about/jasmine.html";
    [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
}

- (void)enterCheckFlowerVc
{
    JACheckExchangeDetailViewController *vc =[[JACheckExchangeDetailViewController alloc] init];
    [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
}
@end
