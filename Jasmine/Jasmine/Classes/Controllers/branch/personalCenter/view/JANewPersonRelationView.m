//
//  JANewPersonRelationView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPersonRelationView.h"

@interface JANewPersonRelationView ()

@property (nonatomic, weak) UILabel *likeLabel;   // 被赞
@property (nonatomic, weak) UIView *horizonLineView;    // 线
@end

@implementation JANewPersonRelationView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupNewPersonRelationViewUI];
    }
    return self;
}

// 赋值
- (void)setModel:(JAConsumer *)model
{
    _model = model;
    
    NSString *focusCount = nil;
    NSString *fansCount = nil;
    NSString *agreeCount = nil;
    if (model.userConsernCount.integerValue > 10000) {
        focusCount = [NSString stringWithFormat:@"%.1fw",(model.userConsernCount.integerValue/10000.0)];
    }else{
        focusCount = model.userConsernCount.length ? model.userConsernCount : @"0";
    }
    if (model.concernUserCount.integerValue > 10000) {
        fansCount = [NSString stringWithFormat:@"%.1fw",(model.concernUserCount.integerValue/10000.0)];
    }else{
        fansCount = model.concernUserCount.length ? model.concernUserCount : @"0";
    }
    if (model.agreeCount.integerValue > 10000) {
        agreeCount = [NSString stringWithFormat:@"%.1fw",(model.agreeCount.integerValue/10000.0)];
    }else{
        agreeCount = model.agreeCount.integerValue ? model.agreeCount : @"0";
    }
    
    NSString *focus = [NSString stringWithFormat:@"%@ 关注",focusCount];
    
    self.followLabel.attributedText = [self attributedString:focus word:@"关注"];
    
    NSString *fans = [NSString stringWithFormat:@"%@ 粉丝",fansCount];
    self.fansLabel.attributedText = [self attributedString:fans word:@"粉丝"];
    
    NSString *agree = [NSString stringWithFormat:@"%@ 获赞",agreeCount];
    self.likeLabel.attributedText = [self attributedString:agree word:@"获赞"];
}

- (void)setupNewPersonRelationViewUI
{
    // 关注
    UILabel *followLabel = [[UILabel alloc] init];
    _followLabel = followLabel;
    followLabel.userInteractionEnabled = YES;
    followLabel.textColor = HEX_COLOR(0x363636);
    followLabel.font = JA_MEDIUM_FONT(20);
    followLabel.attributedText = [self attributedString:@"0 关注" word:@"关注"];
    [self addSubview:followLabel];
    
    // 粉丝
    UILabel *fansLabel = [[UILabel alloc] init];
    _fansLabel = fansLabel;
    fansLabel.userInteractionEnabled = YES;
    fansLabel.textColor = HEX_COLOR(0x363636);
    fansLabel.font = JA_MEDIUM_FONT(20);
    fansLabel.attributedText = [self attributedString:@"0 粉丝" word:@"粉丝"];
    [self addSubview:fansLabel];
    
    // 粉丝
    UILabel *likeLabel = [[UILabel alloc] init];
    _likeLabel = likeLabel;
    likeLabel.userInteractionEnabled = YES;
    likeLabel.textColor = HEX_COLOR(0x363636);
    likeLabel.font = JA_MEDIUM_FONT(20);
    likeLabel.attributedText = [self attributedString:@"0 被赞" word:@"被赞"];
    [self addSubview:likeLabel];
    
    UIView *horizonLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 1)];
    _horizonLineView = horizonLineView;
    [UIView drawLineOfDashByCAShapeLayer:horizonLineView lineLength:3 lineSpacing:2 lineColor:HEX_COLOR(JA_Line) lineDirection:YES];
    [self addSubview:horizonLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorNewPersonRelationViewFrame];
}

- (void)calculatorNewPersonRelationViewFrame
{
    self.followLabel.width = 65;
    [self.followLabel sizeToFit];
    self.followLabel.height = 50;
    self.followLabel.x = 18;
    
    self.fansLabel.width = 65;
    [self.fansLabel sizeToFit];
    self.fansLabel.height = 50;
    self.fansLabel.x = self.followLabel.right + 20;
    
    self.likeLabel.width = 65;
    [self.likeLabel sizeToFit];
    self.likeLabel.height = 50;
    self.likeLabel.x = self.fansLabel.right + 20;
    
    self.horizonLineView.y = self.height - 1;
}

- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    [attr addAttribute:NSFontAttributeName value:JA_REGULAR_FONT(13) range:rang];
    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x4a4a4a) range:rang];
    return attr;
}
@end
