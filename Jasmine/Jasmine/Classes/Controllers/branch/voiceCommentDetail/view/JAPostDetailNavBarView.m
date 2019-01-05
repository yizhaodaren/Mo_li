//
//  JAPostDetailNavBarView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPostDetailNavBarView.h"
#import "JACircleModel.h"

@interface JAPostDetailNavBarView ()
@property (nonatomic, assign) BOOL isEdge;  // 是否需要在边缘


@property (nonatomic, weak) UIImageView *circleImageView;  // 圈子图片view
@property (nonatomic, weak) UILabel *circleNameLabel;   // 圈子名称
@property (nonatomic, weak) UILabel *focusLabel;     // 关注数
@property (nonatomic, weak) UIButton *arrowButton;   // 箭头
@property (nonatomic, weak) UIView *lineView;
@end

@implementation JAPostDetailNavBarView

#pragma mark - 改变导航条上的资料按钮的位置
- (void)circleDetailNavBarView_changePointButtonToEdge:(BOOL)isEdge
{
    self.isEdge = isEdge;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isEdge = YES;
        [self setupPostDetailNavBarViewUI];
    }
    return self;
}

- (void)setCircleModel:(JACircleModel *)circleModel
{
    _circleModel = circleModel;
    
    if (circleModel.circleId.length) {
        
        self.circleView.hidden = NO;
        [self.circleImageView ja_setImageWithURLStr:circleModel.circleThumb];
        self.circleNameLabel.text = circleModel.circleName;
        [self.circleNameLabel sizeToFit];
        self.focusLabel.text = [NSString stringWithFormat:@"已有%@人关注",circleModel.followCount];
        [self.focusLabel sizeToFit];
        self.arrowButton.x = MAX(self.circleNameLabel.right, self.focusLabel.right) + 10;
    }else{
        self.circleView.hidden = YES;
    }
}

#pragma mark - UI
- (void)setupPostDetailNavBarViewUI
{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton = backButton;
    [backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateNormal];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:backButton];
    
    UIView *circleView = [[UIView alloc] init];
    _circleView = circleView;
    circleView.hidden = YES;
    [self addSubview:circleView];
    
    UIImageView *circleImageView = [[UIImageView alloc] init];
    _circleImageView = circleImageView;
    circleImageView.backgroundColor = HEX_COLOR(0xededed);
    [circleView addSubview:circleImageView];
    
    UILabel *circleNameLabel = [[UILabel alloc] init];
    _circleNameLabel = circleNameLabel;
    circleNameLabel.text = @" ";
    circleNameLabel.textColor = HEX_COLOR(0x525252);
    circleNameLabel.font = JA_MEDIUM_FONT(13);
    [circleView addSubview:circleNameLabel];
    
    UILabel *focusLabel = [[UILabel alloc] init];
    _focusLabel = focusLabel;
    focusLabel.text = @" ";
    focusLabel.textColor = HEX_COLOR(0xC6C6C6);
    focusLabel.font = JA_REGULAR_FONT(11);
    [circleView addSubview:focusLabel];
    
    UIButton *arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _arrowButton = arrowButton;
    [arrowButton setImage:[UIImage imageNamed:@"跳转按钮"] forState:UIControlStateNormal];
    [circleView addSubview:arrowButton];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _infoButton = infoButton;
    [infoButton setImage:[UIImage imageNamed:@"post_detai_point"] forState:UIControlStateNormal];
    [self addSubview:infoButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xededed);
    [self addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorPostDetailNavBarViewFrame];
}

- (void)calculatorPostDetailNavBarViewFrame
{
    self.backButton.width = 60;
    self.backButton.height = self.height - JA_StatusBarHeight;
    self.backButton.x = 10;
    self.backButton.y = JA_StatusBarHeight;
    
    self.circleView.x = 50;
    self.circleView.width = self.width - self.circleView.x - 90;
    self.circleView.height = 44;
    self.circleView.y = self.backButton.y;
    
    self.circleImageView.width = 30;
    self.circleImageView.height = 30;
    self.circleImageView.centerY = self.circleView.height * 0.5;
    self.circleImageView.x = 2;
    
    [self.circleNameLabel sizeToFit];
    
    self.circleNameLabel.x = self.circleImageView.right + 10;
    self.circleNameLabel.y = self.circleImageView.y;
    self.circleNameLabel.height = 13;
    
    [self.focusLabel sizeToFit];
    self.focusLabel.height = 12;
    self.focusLabel.x = self.circleNameLabel.x;
    self.focusLabel.y = self.circleImageView.bottom - self.focusLabel.height;
    
    self.arrowButton.width = 6;
    self.arrowButton.height = 10;
    self.arrowButton.x = self.circleNameLabel.right + 10;
    self.arrowButton.centerY = self.circleImageView.centerY;
    self.arrowButton.x = MAX(self.circleNameLabel.right, self.focusLabel.right) + 10;
    
    self.infoButton.width = 60;
    self.infoButton.height = self.backButton.height;
    self.infoButton.x = self.isEdge ? self.width - 5 - self.infoButton.width : self.width - 35 - self.infoButton.width;
    self.infoButton.centerY = self.backButton.centerY;
    
    self.lineView.width = self.width;
    self.lineView.height = 1;
    self.lineView.y = self.height - 1;
}
@end
