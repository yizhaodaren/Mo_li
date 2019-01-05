//
//  JAPersonalNavBarView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalNavBarView.h"

@interface JAPersonalNavBarView ()

@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) UILabel *officLabel;

@property (nonatomic, assign) BOOL isEdge;
@end

@implementation JAPersonalNavBarView

- (void)PersonalNavBarView_changeInfoButtonToEdge:(BOOL)isEdge
{
    self.isEdge = isEdge;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.isEdge = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
// more_grzy  jubao_grzy  reture_grzy
- (void)setup
{
    UIView *backV = [[UIView alloc] init];
    _backView = backV;
    self.backView.backgroundColor = HEX_COLOR_ALPHA(JA_Background, 0.0);
    [self addSubview:backV];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton = backButton;
    [backButton setImage:[UIImage imageNamed:@"circle_back_white"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateSelected];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:17];
    [self addSubview:titleLabel];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
    [self addSubview:rightButton];
    
    UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _followButton = followButton;
    [followButton setImage:[UIImage imageNamed:@"branch_person_nav_follow"] forState:UIControlStateNormal];
    [followButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    followButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, 0);
    followButton.alpha = 0;
    [self addSubview:followButton];
    
    UIView *lineV = [[UIView alloc] init];
    _lineView = lineV;
    lineV.hidden = YES;
    lineV.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self addSubview:lineV];
    
    self.officLabel = [[UILabel alloc] init];
    self.officLabel.backgroundColor = HEX_COLOR(0x1CD39B);
    self.officLabel.width = 30;
    self.officLabel.height = 16;
    self.officLabel.text = @"官方";
    self.officLabel.hidden = YES;
    self.officLabel.textColor = [UIColor whiteColor];
    self.officLabel.font = JA_REGULAR_FONT(10);
    self.officLabel.layer.cornerRadius = 8;
    self.officLabel.layer.masksToBounds = YES;
    self.officLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.officLabel];
    
    self.titleLabel.alpha = 0;
    self.officLabel.alpha = 0;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_StatusBarAndNavigationBarHeight;
    
    self.backView.width = self.width;
    self.backView.height = self.height;
    
    self.backButton.width = 60;
    self.backButton.height = self.height - JA_StatusBarHeight;
    self.backButton.y = JA_StatusBarHeight;
    self.backButton.x = 10;
    
    self.rightButton.width = 60;
    self.rightButton.height = self.height - JA_StatusBarHeight;
    self.rightButton.x = self.isEdge ? JA_SCREEN_WIDTH - self.rightButton.width : JA_SCREEN_WIDTH - self.rightButton.width - 35;
    self.rightButton.y = self.backButton.y ;
    
    self.followButton.width = 17;
    self.followButton.height = 15;
    self.followButton.centerY = self.rightButton.centerY;
    self.followButton.x = self.rightButton.x - self.followButton.width;
    
    [self.titleLabel sizeToFit];
    if (self.titleLabel.width > 120) {
        self.titleLabel.width = 120;
    }
    self.titleLabel.height = self.height - JA_StatusBarHeight;
    self.titleLabel.centerX = self.width * 0.5;
    self.titleLabel.y = self.backButton.y ;
    
    self.officLabel.x = self.titleLabel.right + 10;
    self.officLabel.centerY = self.titleLabel.centerY;
    
    self.lineView.height = 1;
    self.lineView.width = self.width;
    self.lineView.y = self.height - 1;
}

- (void)setName:(NSString *)name
{
    _name = name;
    
    self.titleLabel.text = name;
    [self.titleLabel sizeToFit];
    if (self.titleLabel.width > 150) {
        self.titleLabel.width = 150;
    }
    self.officLabel.x = self.titleLabel.right + 10;
    
}

- (void)setHiddenOffic:(BOOL)hiddenOffic
{
    _hiddenOffic = hiddenOffic;
    self.officLabel.hidden = hiddenOffic;
}

- (void)setIsMe:(BOOL)isMe
{
    _isMe = isMe;
    
    if (isMe) {
        [self.rightButton setImage:[UIImage imageNamed:@"person_edit"] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"person_blackEdit"] forState:UIControlStateSelected];
    }else{
        
        [self.rightButton setImage:[UIImage imageNamed:@"person_point_white"] forState:UIControlStateNormal];
        [self.rightButton setImage:[UIImage imageNamed:@"detail_right_report"] forState:UIControlStateSelected];
        [self.rightButton setTitle:nil forState:UIControlStateNormal];
    }
}

- (void)setAlphaValue:(CGFloat)alphaValue
{
    _alphaValue = alphaValue;
    
    if (alphaValue > 0.7) {
        
        CGFloat al1 = (alphaValue - 0.7) / 0.3;
        
        self.backButton.alpha = al1;
        self.rightButton.alpha = al1;
        self.followButton.alpha = al1;
        self.lineView.hidden = alphaValue >= 1 ? NO : YES;
        self.backButton.selected = YES;
        self.rightButton.selected = YES;
        
        self.titleLabel.alpha = al1;
        self.titleLabel.textColor = HEX_COLOR_ALPHA(0x444444,al1);
        self.officLabel.alpha = al1;
    }else{
        
        CGFloat al = 1 - alphaValue * 1 / 0.7;
        
        self.backButton.alpha = al;
        self.rightButton.alpha = al;
        self.lineView.hidden = YES;
        self.backButton.selected = NO;
        self.rightButton.selected = NO;
        self.followButton.alpha = 0;
        self.titleLabel.alpha = 0;
        
        self.titleLabel.textColor = HEX_COLOR_ALPHA(0xffffff,0);
        self.officLabel.alpha = 0;
    }
    self.backView.backgroundColor = HEX_COLOR_ALPHA(JA_Background, alphaValue);
}


- (void)setHiddenRight:(BOOL)hiddenRight
{
    _hiddenRight = hiddenRight;
    
    self.rightButton.hidden = hiddenRight;
}

- (void)setHiddenFollow:(BOOL)hiddenFollow
{
    _hiddenFollow = hiddenFollow;
    self.followButton.hidden = hiddenFollow;
}

@end
