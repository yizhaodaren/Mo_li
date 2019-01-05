//
//  JACircleInfoHeadView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleInfoHeadView.h"

@interface JACircleInfoHeadView ()

@property (nonatomic, weak) UIView *backView;  // 图片背景
@property (nonatomic, weak) UIImageView *circleImageView;  // 专辑图片
@property (nonatomic, weak) UILabel *circleNameLabel;      // 专辑名字
@property (nonatomic, weak) UILabel *countLabel;          // 关注数 帖子数
@property (nonatomic, weak) UIView *lineView;             // 线
@property (nonatomic, weak) UIView *circleDetailNameLabel;  // 圈子介绍
@property (nonatomic, weak) UILabel *circleDetailLabel;    // 简介
@property (nonatomic, weak) UIView *bottomLineView;             // 线
@end

@implementation JACircleInfoHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleInfoHeadViewUI];
    }
    return self;
}

- (void)setModel:(JACircleModel *)model
{
    _model = model;
    [self.circleImageView ja_setImageWithURLStr:model.circleThumb];
    self.circleNameLabel.text = model.circleName;
    self.countLabel.text = [NSString stringWithFormat:@"关注 %@   帖子%@",model.followCount,model.storyCount];
    self.circleDetailLabel.text = model.circleDesc;
    
}

- (void)setupCircleInfoHeadViewUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.layer.shadowColor = HEX_COLOR_ALPHA(0x000000, 0.3).CGColor;
    backView.layer.shadowRadius = 3.f;
    backView.layer.shadowOpacity = 1.0;
    backView.layer.shadowOffset = CGSizeMake(0,0);
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    
    UIImageView *circleImageView = [[UIImageView alloc] init];
    _circleImageView = circleImageView;
    circleImageView.backgroundColor = HEX_COLOR(0xededed);
    [backView addSubview:circleImageView];
    
    UILabel *circleNameLabel = [[UILabel alloc] init];
    _circleNameLabel = circleNameLabel;
    circleNameLabel.text = @" ";
    circleNameLabel.textColor = HEX_COLOR(0x363636);
    circleNameLabel.font = JA_MEDIUM_FONT(16);
    [self addSubview:circleNameLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    _countLabel = countLabel;
    countLabel.text = @" ";
    countLabel.textColor = HEX_COLOR(0x9b9b9b);
    countLabel.font = JA_MEDIUM_FONT(12);
    [self addSubview:countLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self addSubview:lineView];
    
    UILabel *circleDetailNameLabel = [[UILabel alloc] init];
    _circleDetailNameLabel = circleDetailNameLabel;
    circleDetailNameLabel.text = @"圈子介绍";
    circleDetailNameLabel.textColor = HEX_COLOR(0x363636);
    circleDetailNameLabel.font = JA_MEDIUM_FONT(15);
    circleDetailNameLabel.numberOfLines = 0;
    [self addSubview:circleDetailNameLabel];
    
    UILabel *circleDetailLabel = [[UILabel alloc] init];
    _circleDetailLabel = circleDetailLabel;
    circleDetailLabel.text = @" ";
    circleDetailLabel.textColor = HEX_COLOR(0x9b9b9b);
    circleDetailLabel.font = JA_REGULAR_FONT(14);
    circleDetailLabel.numberOfLines = 0;
    [self addSubview:circleDetailLabel];
    
    UIView *bottomLineView = [[UIView alloc] init];
    _bottomLineView = bottomLineView;
    bottomLineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self addSubview:bottomLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleInfoHeadViewFrame];
}
- (void)calculatorCircleInfoHeadViewFrame
{
    self.backView.width = 64;
    self.backView.height = 64;
    self.backView.x = 15;
    self.backView.y = 13;
    self.backView.layer.cornerRadius = 3;
    
    self.circleImageView.width = self.backView.width - 4;
    self.circleImageView.height = self.backView.height - 4;
    self.circleImageView.centerX = self.backView.width * 0.5;
    self.circleImageView.centerY = self.backView.height * 0.5;
    self.circleImageView.layer.cornerRadius = 3;
    self.circleImageView.layer.masksToBounds = YES;
    
    self.circleNameLabel.x = self.backView.right + 15;
    self.circleNameLabel.y = self.backView.y + 4;
    self.circleNameLabel.width = self.width - self.circleNameLabel.x - 10;
    self.circleNameLabel.height = 20;
    
    [self.countLabel sizeToFit];
    self.countLabel.x = self.circleNameLabel.x;
    self.countLabel.y = self.circleNameLabel.bottom + 20;
    
    self.lineView.x = self.backView.x;
    self.lineView.y = self.backView.bottom + 20;
    self.lineView.width = self.width - self.lineView.x;
    self.lineView.height = 1;
    
    self.circleDetailNameLabel.x = self.backView.x;
    self.circleDetailNameLabel.y = self.lineView.bottom + 9;
    self.circleDetailNameLabel.width = 65;
    self.circleDetailNameLabel.height = 21;
    
    self.circleDetailLabel.x = self.backView.x;
    self.circleDetailLabel.y = self.circleDetailNameLabel.bottom + 10;
    self.circleDetailLabel.width = self.width - 30;
    [self.circleDetailLabel sizeToFit];
    self.circleDetailLabel.width = self.width - 30;
    
    self.bottomLineView.width = self.width;
    self.bottomLineView.height = 10;
    self.bottomLineView.y = self.circleDetailLabel.bottom + 10;
}
@end
