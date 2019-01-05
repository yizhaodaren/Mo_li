//
//  JACircleDetailNavBarView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleDetailNavBarView.h"

@interface JACircleDetailNavBarView ()
@property (nonatomic, weak) UIView *backView;      // 背景view
@property (nonatomic, weak) UILabel *titleNameLabel;  // 圈子名称
@property (nonatomic, weak) UIView *lineView;  // 线
@property (nonatomic, assign) BOOL isEdge;  // 是否需要在边缘
@end

@implementation JACircleDetailNavBarView

#pragma mark - 改变导航条上的资料按钮的位置
- (void)circleDetailNavBarView_changeInfoButtonToEdge:(BOOL)isEdge
{
    self.isEdge = isEdge;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - 改变导航条的透明度
- (void)setOffset:(CGFloat)offset
{
    _offset = offset;
    
    // 计算alpha值
    CGFloat scale = 0;
    if (offset < 0) {
        scale = 0;
    }else{
        scale = offset / JA_StatusBarAndNavigationBarHeight >= 1.0 ? 1.0 : offset / JA_StatusBarAndNavigationBarHeight;
    }
   
    self.backView.alpha = scale;
    self.titleNameLabel.alpha = scale;
    self.lineView.alpha = scale;
    
    if (scale >= 0.5) {
        self.backButton.selected = YES;
        self.infoButton.selected = YES;
        self.backButton.alpha = (scale - 0.5) * 2;
        self.infoButton.alpha = (scale - 0.5) * 2;
    }else{
        self.backButton.selected = NO;
        self.infoButton.selected = NO;
        self.backButton.alpha = 1 - scale * 2;
        self.infoButton.alpha = 1 - scale * 2;
    }
    
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.titleNameLabel.text = titleName;
    [self.titleNameLabel sizeToFit];
}

#pragma mark - UI
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isEdge = YES;
        [self setupCircleDetailNavBarViewUI];
    }
    return self;
}

- (void)setupCircleDetailNavBarViewUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    backView.alpha = 0;
    [self addSubview:backView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton = backButton;
    [backButton setImage:[UIImage imageNamed:@"circle_back_white"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateSelected];
    [backButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:backButton];
    
    UILabel *titleNameLabel = [[UILabel alloc] init];
    _titleNameLabel = titleNameLabel;
    titleNameLabel.text = @" ";
    titleNameLabel.textColor = HEX_COLOR(0x363636);
    titleNameLabel.font = JA_REGULAR_FONT(18);
    titleNameLabel.alpha = 0;
    [self addSubview:titleNameLabel];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _infoButton = infoButton;
    [infoButton setImage:[UIImage imageNamed:@"circle_info_white"] forState:UIControlStateNormal];
    [infoButton setImage:[UIImage imageNamed:@"circle_info_black"] forState:UIControlStateSelected];
    [self addSubview:infoButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.alpha = 0;
    lineView.backgroundColor = HEX_COLOR(0xededed);
    [self addSubview:lineView];
}

- (void)calculatorCircleDetailNavBarViewFrame
{
    self.backView.width = self.width;
    self.backView.height = self.height;
    
    self.backButton.width = 60;
    self.backButton.height = self.height - JA_StatusBarHeight;
    self.backButton.x = 10;
    self.backButton.y = JA_StatusBarHeight;
    
    [self.titleNameLabel sizeToFit];
    self.titleNameLabel.centerY = self.backButton.centerY;
    self.titleNameLabel.centerX = self.width * 0.5;
    
    self.infoButton.width = 60;
    self.infoButton.height = self.backButton.height;
    self.infoButton.x = self.isEdge ? self.width - 5 - self.infoButton.width : self.width - 35 - self.infoButton.width;
    self.infoButton.y = self.backButton.y;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    self.lineView.y = self.height - 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleDetailNavBarViewFrame];
}

@end
