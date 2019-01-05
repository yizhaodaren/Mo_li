//
//  JASignAwardView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASignAwardView.h"

#define kAnimCount 5

@interface JASignAwardView ()

@property (nonatomic, weak) UIImageView *awardImageView;      // 奖励imageView
@property (nonatomic, weak) UILabel *awardLabel;      // 奖励label

@property (nonatomic, weak) UIView *selectView;          // 选中展示的view
@property (nonatomic, weak) UIImageView *yuZhiBoImageView;
@property (nonatomic, weak) UIImageView *personalImageView;
@property (nonatomic, weak) UIButton *button;

@end

@implementation JASignAwardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
        
    }
    return self;
}


- (void)setupUI
{
    UIImageView *awardImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_mine_flower"]];
    _awardImageView = awardImageView;
    awardImageView.backgroundColor = [UIColor whiteColor];
    awardImageView.contentMode = UIViewContentModeCenter;
    [self addSubview:awardImageView];
    
    UILabel *awardLabel = [[UILabel alloc] init];
    _awardLabel = awardLabel;
    awardLabel.text = @"x10";
    awardLabel.textColor = HEX_COLOR(0x8B572A);
    awardLabel.font = JA_REGULAR_FONT(10);
    awardLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:awardLabel];
    
    UIView *selectView = [[UIView alloc] init];
    _selectView = selectView;
//    [self addSubview:selectView];
    
    UIImageView *yuZhiBoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_mine_zuoZhu"]];
    _yuZhiBoImageView = yuZhiBoImageView;
    [selectView addSubview:yuZhiBoImageView];
    
    UIImageView *personalImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_mine_person"]];
    _personalImageView = personalImageView;
    [selectView addSubview:personalImageView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _button = button;
    button.backgroundColor = HEX_COLOR(0xF8E81C);
    [button setImage:[UIImage imageNamed:@"branch_mine_flower_small"] forState:UIControlStateNormal];
    [button setTitle:@"x10" forState:UIControlStateNormal];
    [button setTitleColor:HEX_COLOR(0x8B572A) forState:UIControlStateNormal];
    button.titleLabel.font = JA_REGULAR_FONT(10);
    [selectView addSubview:button];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorFrame];
}

- (void)caculatorFrame
{
    self.width = 40;
    self.height = 42;
    
    self.awardImageView.width = 24;
    self.awardImageView.height = self.awardImageView.width;
    self.awardImageView.layer.cornerRadius = self.awardImageView.width * 0.5;
    self.awardImageView.layer.masksToBounds = YES;
    self.awardImageView.centerX = self.width * 0.5;
    self.awardImageView.y = 3;
    
    self.awardLabel.width = self.width;
    self.awardLabel.height = 10;
    self.awardLabel.y = self.awardImageView.bottom + 2;
    
    self.selectView.frame = self.bounds;
    
    self.yuZhiBoImageView.centerX = self.selectView.width * 0.5;
    self.yuZhiBoImageView.y = self.selectView.height - self.yuZhiBoImageView.height;
    
    self.personalImageView.centerX = self.yuZhiBoImageView.centerX;
    self.personalImageView.y = self.selectView.height - 8 - self.personalImageView.height;
    self.personalImageView.layer.anchorPoint = CGPointMake(0.5, 1);
    self.personalImageView.layer.position = CGPointMake(self.personalImageView.center.x, self.selectView.height - 8);
    
    self.button.width = 40;
    self.button.height = 20;
    self.button.centerX = self.selectView.width * 0.5;
    self.button.y = self.personalImageView.y - 20 - 7;
    self.button.layer.cornerRadius = 10;
    
}

- (void)setSelect:(BOOL)select
{
    _select = select;
    
//    self.selectView.hidden = !select;
    
//    if (self.selectView.hidden == NO) {
//
//        CAKeyframeAnimation *anim = [CAKeyframeAnimation animation];
//        anim.keyPath = @"transform.rotation";
//        anim.values = @[@((-5) / 180.0 * M_PI),@((5) / 180.0 * M_PI),@((-5) / 180.0 * M_PI)];
//        anim.repeatCount = kAnimCount;
//        [self.personalImageView.layer addAnimation:anim forKey:nil];
//    }
    
//    self.awardImageView.hidden = select;
//    self.awardLabel.hidden = select;
    
    self.awardImageView.backgroundColor = select ? HEX_COLOR(0xF8E81C) : HEX_COLOR(0xffffff);
}

- (void)setIsPacket:(BOOL)isPacket
{
    _isPacket = isPacket;
    
    if (isPacket) {
        
        self.awardImageView.image = [UIImage imageNamed:@"branch_mine_packet_big"];
        self.awardLabel.text = [NSString stringWithFormat:@"%@",self.flowerCountString];
        [self.button setImage:[UIImage imageNamed:@"branch_mine_packet_small"] forState:UIControlStateNormal];
        [self.button setTitle:nil forState:UIControlStateNormal];
    }else{
        self.awardImageView.image = [UIImage imageNamed:@"branch_mine_flower"];
        self.awardLabel.text = [NSString stringWithFormat:@"x%@",self.flowerCountString];
        [self.button setImage:[UIImage imageNamed:@"branch_mine_flower_small"] forState:UIControlStateNormal];
        [self.button setTitle:[NSString stringWithFormat:@"x%@",self.flowerCountString] forState:UIControlStateNormal];
    }
}
@end
