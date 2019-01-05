//
//  JAWithDrawFinishViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawFinishViewController.h"

@interface JAWithDrawFinishViewController ()

@property (nonatomic, weak) UIView *view1;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label1;
@property (nonatomic, weak) UILabel *label2;

@property (nonatomic, weak) UIView *view2;
@property (nonatomic, weak) UILabel *labelLeft1;
@property (nonatomic, weak) UILabel *labelRight1;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UILabel *labelLeft2;
@property (nonatomic, weak) UILabel *labelright2;

@end

@implementation JAWithDrawFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"提现申请"];
    self.view.backgroundColor = HEX_COLOR(JA_BtnGrounddColor);
    [self setupWithDrawFinishUI];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"提现成功";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)setupWithDrawFinishUI
{
    UIView *view1 = [[UIView alloc] init];
    _view1 = view1;
    view1.backgroundColor = HEX_COLOR(0xffffff);
    view1.width = JA_SCREEN_WIDTH;
    view1.height = 200;
    [self.view addSubview:view1];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"withDraw_gou_green"]];
    _imageView = imageView;
    imageView.centerX = view1.width * 0.5;
    imageView.y = 20;
    [view1 addSubview:imageView];
    
    UILabel *label1 = [[UILabel alloc] init];
    _label1 = label1;
    label1.text = @"提现申请已提交";
    label1.textColor = HEX_COLOR(JA_Green);
    label1.font = JA_MEDIUM_FONT(18);
    [label1 sizeToFit];
    label1.height = 25;
    label1.centerX = view1.width * 0.5;
    label1.y = imageView.bottom + 15;
    [view1 addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    _label2 = label2;
    label2.text = @"我们会在5个工作日内审核您的提交申请，审核通过后将发红包到您绑定的微信，请耐心等待。";
    label2.textColor = HEX_COLOR(JA_BlackSubTitle);
    label2.font = JA_REGULAR_FONT(13);
    label2.width = JA_SCREEN_WIDTH - 2 * 14;
    label2.textAlignment = NSTextAlignmentCenter;
    label2.numberOfLines = 0;
    [label2 sizeToFit];
    label2.centerX = view1.width * 0.5;
    label2.y = label1.bottom + 25;
    [view1 addSubview:label2];
    
    UIView *view2 = [[UIView alloc] init];
    _view2 = view2;
    view2.backgroundColor = HEX_COLOR(0xffffff);
    view2.width = JA_SCREEN_WIDTH;
    view2.height = 100;
    view2.y = view1.bottom + 5;
    [self.view addSubview:view2];
    
    UILabel *labelLeft1 = [[UILabel alloc] init];
    _labelLeft1 = labelLeft1;
    labelLeft1.textColor = HEX_COLOR(JA_BlackSubTitle);
    labelLeft1.text = @"提现方式：";
    labelLeft1.font = JA_REGULAR_FONT(16);
    [labelLeft1 sizeToFit];
    labelLeft1.height = 22;
    labelLeft1.x = 14;
    labelLeft1.y = 14;
    [view2 addSubview:labelLeft1];
    
    UILabel *labelRight1 = [[UILabel alloc] init];
    _labelRight1 = labelRight1;
    labelRight1.textColor = HEX_COLOR(JA_BlackTitle);
    labelRight1.text = @"微信钱包";
    labelRight1.font = JA_REGULAR_FONT(16);
    [labelRight1 sizeToFit];
    labelRight1.height = 22;
    labelRight1.x = JA_SCREEN_WIDTH - 14 - labelRight1.width;
    labelRight1.y = 14;
    [view2 addSubview:labelRight1];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    lineView.width = JA_SCREEN_WIDTH - 14;
    lineView.height = 1;
    lineView.x = 14;
    lineView.y = labelLeft1.bottom + 14;
    [view2 addSubview:lineView];
    
    UILabel *labelLeft2 = [[UILabel alloc] init];
    _labelLeft2 = labelLeft2;
    labelLeft2.textColor = HEX_COLOR(JA_BlackSubTitle);
    labelLeft2.text = @"提现金额：";
    labelLeft2.font = JA_REGULAR_FONT(16);
    [labelLeft2 sizeToFit];
    labelLeft2.height = 22;
    labelLeft2.x = 14;
    labelLeft2.y = lineView.bottom + 14;
    [view2 addSubview:labelLeft2];
    
    UILabel *labelRight2 = [[UILabel alloc] init];
    _labelright2 = labelRight2;
    labelRight2.textColor = HEX_COLOR(JA_BlackTitle);
    labelRight2.text = [NSString stringWithFormat:@"¥%@元",self.moneyString];
    labelRight2.font = JA_REGULAR_FONT(16);
    [labelRight2 sizeToFit];
    labelRight2.height = 22;
    labelRight2.x = JA_SCREEN_WIDTH - 14 - labelRight2.width;
    labelRight2.y = lineView.bottom + 14;
    [view2 addSubview:labelRight2];
}

//- (void)setMoneyString:(NSString *)moneyString
//{
//    _moneyString = moneyString;
//    
//    self.labelright2.text = ;
//}
@end
