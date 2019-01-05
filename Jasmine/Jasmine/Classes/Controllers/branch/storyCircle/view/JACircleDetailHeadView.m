//
//  JACircleDetailHeadView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleDetailHeadView.h"

#import "JANewVoiceModel.h"

@interface JACircleDetailHeadView ()

@property (nonatomic, weak) UIImageView *backgroundImageView;    // 背景图片
@property (nonatomic, weak) UIView *coverView;                // 0.5黑色遮罩
@property (nonatomic, weak) UIView *imageBackView;           // 圈子图片容器
@property (nonatomic, weak) UIImageView *circleImageView;    // 圈子图片
@property (nonatomic, weak) UILabel *circleNameLabel;      // 专辑名字
@property (nonatomic, weak) UILabel *countLabel;          // 关注数 帖子数
@property (nonatomic, weak) UILabel *circleDetailLabel;    // 简介
@property (nonatomic, weak) UIView *bottomLineView;             // 线
@property (nonatomic, weak) UIButton *signCountButton;    // 签到天数

@end

@implementation JACircleDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleDetailHeadViewUI];
    }
    return self;
}

#pragma mark - 数据赋值
- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    if (offset < 0) {
        
        self.backgroundImageView.height = 200 - offset;
        self.backgroundImageView.y = offset;
    }else{
        self.backgroundImageView.height = 200;
        self.backgroundImageView.y = 0;
    }
}


- (void)setInfoModel:(JACircleModel *)infoModel
{
    _infoModel = infoModel;
    [self.backgroundImageView ja_setImageWithURLStr:infoModel.circleThumb];
    [self.circleImageView ja_setImageWithURLStr:infoModel.circleThumb];
    self.circleNameLabel.text = infoModel.circleName;
    
    if (infoModel.isConcern && infoModel.hasSign) {  // 关注已经签到
        self.signCountButton.hidden = NO;
        self.focusButton.hidden = YES;
        NSString *text = [NSString stringWithFormat:@"已签到%@天",infoModel.signNum];
        [self.signCountButton setTitle:text forState:UIControlStateNormal];
        self.focusButton.selected = YES;
    }else if (infoModel.isConcern && infoModel.hasSign == NO){  // 关注未签到
        self.focusButton.selected = YES;
        self.signCountButton.hidden = YES;
        self.focusButton.hidden = NO;
    }else{  // 未关注
        self.focusButton.selected = NO;
        self.focusButton.hidden = NO;
        self.signCountButton.hidden = YES;
    }
    
    self.countLabel.text = [NSString stringWithFormat:@"关注 %@   帖子 %@",infoModel.followCount,infoModel.storyCount];
    self.circleDetailLabel.text = infoModel.circleDesc;
    [self.circleDetailLabel sizeToFit];
    [self.countLabel sizeToFit];
}

#pragma mark - UI
- (void)setupCircleDetailHeadViewUI
{
    UIImageView *backgroundImageView = [[UIImageView alloc] init];
    _backgroundImageView = backgroundImageView;
    backgroundImageView.backgroundColor = HEX_COLOR(0xededed);
    backgroundImageView.width = JA_SCREEN_WIDTH;
    backgroundImageView.height = 180 + (iPhoneX ? 24.f : 0.f);
    backgroundImageView.userInteractionEnabled = YES;
    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImageView.clipsToBounds = YES;
    [self addSubview:backgroundImageView];
    
    UIView *coverView = [[UIView alloc] init];
    _coverView = coverView;
    coverView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    [backgroundImageView addSubview:coverView];
    
    UIView *imageBackView = [[UIView alloc] init];
    _imageBackView = imageBackView;
    imageBackView.backgroundColor = [UIColor whiteColor];
    [backgroundImageView addSubview:imageBackView];
    
    UIImageView *circleImageView = [[UIImageView alloc] init];
    _circleImageView = circleImageView;
    circleImageView.backgroundColor = HEX_COLOR(0xededed);
    [imageBackView addSubview:circleImageView];
    
    UILabel *circleNameLabel = [[UILabel alloc] init];
    _circleNameLabel = circleNameLabel;
    circleNameLabel.text = @" ";
    circleNameLabel.textColor = HEX_COLOR(0xffffff);
    circleNameLabel.font = JA_MEDIUM_FONT(18);
    [backgroundImageView addSubview:circleNameLabel];
    
    UILabel *countLabel = [[UILabel alloc] init];
    _countLabel = countLabel;
    countLabel.text = @" ";
    countLabel.textColor = HEX_COLOR(0xffffff);
    countLabel.font = JA_MEDIUM_FONT(12);
    [backgroundImageView addSubview:countLabel];
    
    UIButton *focusButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _focusButton = focusButton;
    [focusButton setImage:[UIImage imageNamed:@"circle_unFocus"] forState:UIControlStateNormal];
    [focusButton setImage:[UIImage imageNamed:@"circle_focus_sign"] forState:UIControlStateSelected];
    [backgroundImageView addSubview:focusButton];
    
    UIButton *signCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _signCountButton = signCountButton;
    [signCountButton setTitle:@"已签到1天" forState:UIControlStateNormal];
    [signCountButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    signCountButton.titleLabel.font = JA_REGULAR_FONT(12);
    signCountButton.hidden = YES;
    [backgroundImageView addSubview:signCountButton];
    
    UILabel *circleDetailLabel = [[UILabel alloc] init];
    _circleDetailLabel = circleDetailLabel;
    circleDetailLabel.text = @" ";
    circleDetailLabel.textColor = HEX_COLOR(0xffffff);
    circleDetailLabel.font = JA_REGULAR_FONT(12);
    circleDetailLabel.numberOfLines = 2;
    [backgroundImageView addSubview:circleDetailLabel];
    
    UIView *bottomLineView = [[UIView alloc] init];
    _bottomLineView = bottomLineView;
    bottomLineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self addSubview:bottomLineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleDetailHeadViewFrame];
}

- (void)calculatorCircleDetailHeadViewFrame
{
    self.coverView.width = self.backgroundImageView.width;
    self.coverView.height = self.backgroundImageView.height;
    
    self.imageBackView.width = 84;
    self.imageBackView.height = 84;
    self.imageBackView.x = 15;
    self.imageBackView.y = self.backgroundImageView.height - self.imageBackView.height - 20;
    self.imageBackView.layer.cornerRadius = 3;
    self.imageBackView.layer.masksToBounds = YES;
    
    self.circleImageView.width = self.imageBackView.width - 4;
    self.circleImageView.height = self.imageBackView.height - 4;
    self.circleImageView.centerX = self.imageBackView.width * 0.5;
    self.circleImageView.centerY = self.imageBackView.height * 0.5;
    self.circleImageView.layer.cornerRadius = 3;
    self.circleImageView.layer.masksToBounds = YES;
    
    self.circleNameLabel.x = self.imageBackView.right + 10;
    self.circleNameLabel.y = self.imageBackView.y + 2;
    self.circleNameLabel.width = self.width - self.circleNameLabel.x - 65;
    self.circleNameLabel.height = 20;
    
    self.focusButton.width = 50;
    self.focusButton.height = 30;
    self.focusButton.x = self.backgroundImageView.width - 15 - self.focusButton.width;
    self.focusButton.centerY = self.circleNameLabel.centerY;
    
    [self.signCountButton sizeToFit];
    self.signCountButton.height = 23;
    self.signCountButton.width += 20;
    self.signCountButton.x = self.backgroundImageView.width - 15 - self.signCountButton.width;
    self.signCountButton.centerY = self.circleNameLabel.centerY;
    self.signCountButton.layer.borderColor = HEX_COLOR(0xffffff).CGColor;
    self.signCountButton.layer.borderWidth = 1;
    self.signCountButton.layer.cornerRadius = self.signCountButton.height * 0.5;
    self.signCountButton.layer.masksToBounds = YES;
    
    [self.countLabel sizeToFit];
    self.countLabel.x = self.circleNameLabel.x;
    self.countLabel.y = self.circleNameLabel.bottom + 10;
    
    self.circleDetailLabel.x = self.circleNameLabel.x;
    self.circleDetailLabel.width = self.width - 15 - self.circleDetailLabel.x;
    [self.circleDetailLabel sizeToFit];
    self.circleDetailLabel.width = self.width - 15 - self.circleDetailLabel.x;
//    self.circleDetailLabel.y = self.countLabel.bottom + 10;
    self.circleDetailLabel.centerY = self.imageBackView.bottom - 20;
    
    self.bottomLineView.width = self.width;
    self.bottomLineView.height = 10;
    self.bottomLineView.y = self.backgroundImageView.bottom;
    
}
@end
