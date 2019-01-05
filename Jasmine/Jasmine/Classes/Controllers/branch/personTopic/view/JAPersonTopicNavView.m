//
//  JAPersonTopicNavView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonTopicNavView.h"

@interface JAPersonTopicNavView ()

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *lineView;


@end

@implementation JAPersonTopicNavView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTopicNavView];
    }
    return self;
}

- (void)setupTopicNavView
{
    UIView *backV = [[UIView alloc] init];
    _backView = backV;
    //    backV.backgroundColor = [UIColor clearColor];
    self.backView.backgroundColor = HEX_COLOR_ALPHA(JA_Background, 0.0);
    [self addSubview:backV];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton = backButton;
    [backButton setImage:[UIImage imageNamed:@"circle_back_white"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateSelected];
    backButton.selected = YES;
    [self addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = HEX_COLOR_ALPHA(JA_BlackTitle, 0.0);
    titleLabel.alpha = 0.0;
    titleLabel.font = JA_REGULAR_FONT(17);
    [self addSubview:titleLabel];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
//    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [rightButton setImage:[UIImage imageNamed:@"branch_topic_white_share"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"branch_topic_share"] forState:UIControlStateSelected];
    [self addSubview:rightButton];
    
    UILabel *shareLabel = [[UILabel alloc] init];
    shareLabel.hidden = YES;
    self.shareLabel = shareLabel;
    self.shareLabel.text = @"0";
    self.shareLabel.textColor = HEX_COLOR(0xffffff);
    self.shareLabel.font = JA_REGULAR_FONT(10);
    self.shareLabel.backgroundColor = HEX_COLOR(0xFF7054);
    [rightButton addSubview:self.shareLabel];
    
    UIView *lineV = [[UIView alloc] init];
    _lineView = lineV;
    lineV.hidden = YES;
    lineV.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:lineV];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat safeHeight = 64;
    if (iPhoneX) {
        safeHeight = 64 + 24;
    }
    
    self.width = JA_SCREEN_WIDTH;
    self.height = safeHeight;
    
    self.backView.width = self.width;
    self.backView.height = self.height;
    
    self.backButton.width = 40;
    self.backButton.height = self.height - 20;
    self.backButton.y = 20;
    
    self.rightButton.width = 50;
    self.rightButton.height = self.height - 20;
    self.rightButton.x = JA_SCREEN_WIDTH - self.rightButton.width;
    self.rightButton.y = 20;
    
    self.shareLabel.x = 16;
    [self.shareLabel sizeToFit];
    self.shareLabel.height = 10;
    self.shareLabel.width = self.shareLabel.width + 6;
    self.shareLabel.textAlignment = NSTextAlignmentCenter;
    self.shareLabel.layer.cornerRadius = self.shareLabel.height * 0.5;
    self.shareLabel.layer.masksToBounds = YES;
    self.shareLabel.y = self.rightButton.height * 0.5;
    
    self.titleLabel.width = JA_SCREEN_WIDTH - 2 * self.rightButton.width;
    self.titleLabel.height = self.height - 20;
    self.titleLabel.x = self.backButton.width + 16;
    self.titleLabel.y = 20;
    
    self.lineView.height = 1;
    self.lineView.width = self.width;
    self.lineView.y = self.height - 1;
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.backButton.selected = NO;
    self.titleLabel.text = name;
}

- (void)setShareCount:(NSString *)shareCount
{
    _shareCount = shareCount;
   
    self.shareLabel.text = [NSString stringWithFormat:@"%ld",[shareCount integerValue]];
}

- (void)setAlphaValue:(CGFloat)alphaValue
{
    _alphaValue = alphaValue;
    
    if (alphaValue > 0.7) {
        
        CGFloat al1 = (alphaValue - 0.7) / 0.3;
        
        self.backButton.alpha = al1;
        self.rightButton.alpha = al1;
        
        self.lineView.hidden = alphaValue >= 1 ? NO : YES;
        self.backButton.selected = YES;
        self.rightButton.selected = YES;
//        self.titleLabel.textColor = HEX_COLOR_ALPHA(0x444444,al1);
    }else{
        
        CGFloat al = 1 - alphaValue * 1 / 0.7;
        
        self.backButton.alpha = al;
        self.rightButton.alpha = al;
        self.lineView.hidden = YES;
        self.backButton.selected = NO;
        self.rightButton.selected = NO;
//        self.titleLabel.textColor = HEX_COLOR_ALPHA(0xffffff,al);
        
    }
    self.titleLabel.textColor = HEX_COLOR_ALPHA(JA_BlackTitle,alphaValue);
    self.titleLabel.alpha = alphaValue;
    self.backView.backgroundColor = HEX_COLOR_ALPHA(JA_Background, alphaValue);
}
@end
