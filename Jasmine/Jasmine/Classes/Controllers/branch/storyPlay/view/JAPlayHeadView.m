//
//  JAPlayHeadView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/2.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPlayHeadView.h"

@interface JAPlayHeadView ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *subTitleLabel;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation JAPlayHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPlayHeadViewUI];
    }
    return self;
}

- (void)setStoryModel:(JANewVoiceModel *)storyModel
{
    _storyModel = storyModel;
//    [self.iconImageView ja_setImageWithURLStr:storyModel.user.avatar placeholder:[UIImage imageNamed:@"playList_playIcon"]];
    self.titleLabel.text = storyModel.content;
    self.subTitleLabel.text = storyModel.user.userName;
    
    if (storyModel.user.isAnonymous) {
        self.iconImageView.image = [UIImage imageNamed:@"anonymous_head"];
    } else {
        [self.iconImageView ja_setImageWithURLStr:storyModel.user.avatar placeholder:[UIImage imageNamed:@"playList_playIcon"]];
    }
}

- (void)setupPlayHeadViewUI
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"playList_playIcon"];
    iconImageView.backgroundColor = HEX_COLOR(0xededed);
    iconImageView.layer.cornerRadius = 2;
    iconImageView.layer.masksToBounds = YES;
    [self addSubview:iconImageView];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @" ";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = JA_REGULAR_FONT(16);
    [self addSubview:titleLabel];
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    _subTitleLabel = subTitleLabel;
    subTitleLabel.text = @" ";
    subTitleLabel.textColor = HEX_COLOR(0xc6c6c6);
    subTitleLabel.font = JA_REGULAR_FONT(13);
    [self addSubview:subTitleLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] init];
    _arrowImageView = arrowImageView;
    arrowImageView.image = [UIImage imageNamed:@"playList_jumpInfo"];
    [self addSubview:arrowImageView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR_ALPHA(0xFFFFFF, 0.2);
    [self addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorPlayHeadViewFrame];
}
- (void)calculatorPlayHeadViewFrame
{
    self.iconImageView.width = 60;
    self.iconImageView.height = 60;
    self.iconImageView.centerY = self.height * 0.5;
    self.iconImageView.x = 12;
    
    self.titleLabel.x = self.iconImageView.right + 10;
    self.titleLabel.y = self.iconImageView.y + 5;
    self.titleLabel.width = JA_SCREEN_WIDTH - self.titleLabel.x - 35;
    self.titleLabel.height = 22;
    
    self.subTitleLabel.x = self.titleLabel.x;
    self.subTitleLabel.y = self.titleLabel.bottom + 5;
    self.subTitleLabel.width = self.titleLabel.width;
    self.subTitleLabel.height = 18;
    
    self.arrowImageView.width = 24;
    self.arrowImageView.height = 24;
    self.arrowImageView.centerY = self.iconImageView.centerY;
    self.arrowImageView.x = JA_SCREEN_WIDTH - 15 - self.arrowImageView.width;
    
    self.lineView.width = self.width;
    self.lineView.height = 1;
    self.lineView.y = self.height - self.lineView.height;
}
@end
