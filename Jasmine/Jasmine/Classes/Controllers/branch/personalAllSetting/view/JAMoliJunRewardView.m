//
//  JAMoliJunRewardView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/4/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMoliJunRewardView.h"

@interface JAMoliJunRewardView ()

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *titleLabel;

//@property (nonatomic, weak) UILabel *timeLabel;
@end

@implementation JAMoliJunRewardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMoliJunRewardViewUI];
    }
    return self;
}

- (void)setupMoliJunRewardViewUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    backView.backgroundColor = HEX_COLOR(0xffffff);
    [self addSubview:backView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"branch_moliDiantai_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeRewardView) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    imageView.image = [UIImage imageNamed:@"branch_moliJun_travelOver"];
    [backView addSubview:imageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @" ";
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = HEX_COLOR(0x882c01);
    titleLabel.font = JA_REGULAR_FONT(16);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:titleLabel];
    
    UIButton *receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _receiveButton = receiveButton;
    [receiveButton setTitle:@"分享明信片,茉莉花翻倍" forState:UIControlStateNormal];
    [receiveButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    receiveButton.titleLabel.font = JA_REGULAR_FONT(20);
    receiveButton.backgroundColor = HEX_COLOR(0x23AD50);
    receiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self addSubview:receiveButton];
    
//    UILabel *timeLabel = [[UILabel alloc] init];
//    _timeLabel = timeLabel;
//    timeLabel.hidden = YES;
//    timeLabel.text = @"下一封邮件可在00:00:00后领取";
//    timeLabel.textAlignment = NSTextAlignmentCenter;
//    timeLabel.numberOfLines = 0;
//    timeLabel.textColor = HEX_COLOR(0x000000);
//    timeLabel.font = JA_REGULAR_FONT(14);
//    [backView addSubview:timeLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    [self caculatorMoliJunRewardViewFrame];
}

- (void)caculatorMoliJunRewardViewFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    self.backView.width = WIDTH_ADAPTER(320);
    self.backView.height = WIDTH_ADAPTER(400);
    self.backView.centerX = self.width * 0.5;
    self.backView.centerY = self.height * 0.5;
    
    self.closeButton.width = 40;
    self.closeButton.height = 40;
    self.closeButton.y = JA_StatusBarAndNavigationBarHeight + 12;
    self.closeButton.x = self.width - 12 - self.closeButton.width;
    
    self.imageView.width = WIDTH_ADAPTER(300);
    self.imageView.height = self.imageView.width;
    self.imageView.x = WIDTH_ADAPTER(10);
    self.imageView.y = WIDTH_ADAPTER(10);
    
    self.titleLabel.width = self.backView.width;
    self.titleLabel.height = WIDTH_ADAPTER(50);
    self.titleLabel.y = self.imageView.bottom + WIDTH_ADAPTER(19);
    
    self.receiveButton.width = WIDTH_ADAPTER(320);
    self.receiveButton.height = WIDTH_ADAPTER(50);
    self.receiveButton.centerX = self.width * 0.5;
    self.receiveButton.y = self.backView.bottom + WIDTH_ADAPTER(40);
    self.receiveButton.layer.cornerRadius = self.receiveButton.height * 0.5;
    self.receiveButton.layer.masksToBounds = YES;
    
//    self.timeLabel.width = self.backView.width;
//    self.timeLabel.height = WIDTH_ADAPTER(15);
//    self.timeLabel.y = self.receiveButton.bottom + WIDTH_ADAPTER(10);
}

- (void)closeRewardView
{
    [self removeFromSuperview];
}

- (void)setFlower:(NSString *)flower
{
    _flower = flower;
    NSString *string = [NSString stringWithFormat:@"茉莉君旅行回来啦\n为你带回了%@朵茉莉花",flower];
    self.titleLabel.text = string;
}

//- (void)setTime:(NSString *)time
//{
//    _time = time;
//    if (time.length) {
//        self.timeLabel.hidden = NO;
//        NSString *string = [NSString stringWithFormat:@"下一封邮件可在%@后领取",time];
//        self.timeLabel.text = string;
//    }else{
//        self.timeLabel.hidden = YES;
//    }
//}
@end
