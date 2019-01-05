//
//  JACommonSectionView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACommonSectionView.h"

@interface JACommonSectionView ()

@property (nonatomic, weak) UIView *horizonLineView;

@property (nonatomic, assign) JACommonSectionViewType type;
@end

@implementation JACommonSectionView

- (instancetype)initWithType:(JACommonSectionViewType)type
{
    self = [super init];
    if (self) {
        self.type = type;
        [self setupCommonSectionViewUI];
    }
    return self;
}

#pragma mark - 重新布局
- (void)commonSection_layoutView
{
    [self calculatorCommonSectionViewFrame];
}

#pragma mark - UI
- (void)setupCommonSectionViewUI
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton = leftButton;
//    [leftButton setTitle:@"全部帖子" forState:UIControlStateNormal];
//    [leftButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
//    [leftButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateSelected];
//    leftButton.titleLabel.font = JA_REGULAR_FONT(14);
    [self addSubview:leftButton];
    
    UIView *leftView = [[UIView alloc] init];
    _leftView = leftView;
    leftView.backgroundColor = HEX_COLOR(0x6BD379);
    [self addSubview:leftView];
    
    UIView *verticalLineView = [[UIView alloc] init];
    _verticalLineView = verticalLineView;
    verticalLineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self addSubview:verticalLineView];
    
    UIButton *middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _middleButton = middleButton;
//    [middleButton setTitle:@"精华帖" forState:UIControlStateNormal];
//    [middleButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
//    [middleButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateSelected];
//    middleButton.titleLabel.font = JA_REGULAR_FONT(14);
    [self addSubview:middleButton];
    
    UIView *middleView = [[UIView alloc] init];
    _middleView = middleView;
    middleView.backgroundColor = HEX_COLOR(0x6BD379);
    [self addSubview:middleView];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
//    [rightButton setImage:[UIImage imageNamed:@"album_sort"] forState:UIControlStateNormal];
//    [rightButton setImage:[UIImage imageNamed:@"album_sort_sel"] forState:UIControlStateSelected];
//    [rightButton setTitle:@"排序" forState:UIControlStateNormal];
//    [rightButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
//    rightButton.titleLabel.font = JA_REGULAR_FONT(13);
    [self addSubview:rightButton];
    
    UIView *horizonLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 1)];
    _horizonLineView = horizonLineView;
    [UIView drawLineOfDashByCAShapeLayer:horizonLineView lineLength:3 lineSpacing:2 lineColor:HEX_COLOR(JA_Line) lineDirection:YES];
    [self addSubview:horizonLineView];
    
    if (self.type == JACommonSectionViewType_normal) {
        self.leftButton.hidden = NO;
        self.leftView.hidden = YES;
        self.verticalLineView.hidden = YES;
        self.middleButton.hidden = YES;
        self.middleView.hidden = YES;
        self.rightButton.hidden = NO;
        self.horizonLineView.hidden = NO;
    }else{
        self.leftButton.hidden = NO;
        self.leftView.hidden = NO;
        self.verticalLineView.hidden = NO;
        self.middleButton.hidden = NO;
        self.middleView.hidden = NO;
        self.rightButton.hidden = NO;
        self.horizonLineView.hidden = NO;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCommonSectionViewFrame];
}

- (void)calculatorCommonSectionViewFrame
{
    [self.leftButton sizeToFit];
    self.leftButton.x = 15;
    self.leftButton.centerY = self.height * 0.5;
    
    self.leftView.width = 12;
    self.leftView.height = 3;
    self.leftView.centerX = self.leftButton.centerX;
    self.leftView.y = self.height - 5 - self.leftView.height;
    
    self.verticalLineView.width = 1;
    self.verticalLineView.height = 15;
    self.verticalLineView.x = self.leftButton.right + 10;
    self.verticalLineView.centerY = self.leftButton.centerY;
    
    [self.middleButton sizeToFit];
    self.middleButton.x = self.verticalLineView.right + 10;
    self.middleButton.centerY = self.leftButton.centerY;
    
    self.middleView.width = 12;
    self.middleView.height = 3;
    self.middleView.centerX = self.middleButton.centerX;
    self.middleView.y = self.leftView.y;
    
    [self.rightButton sizeToFit];
    self.rightButton.width += 6;
    self.rightButton.centerY = self.leftButton.centerY;
    self.rightButton.x = self.width - 15 - self.rightButton.width;
    [self.rightButton setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
    
    self.horizonLineView.y = self.height - self.horizonLineView.height;
}
@end
