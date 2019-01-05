//
//  JAMarkNavigationView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMarkNavigationView.h"

@interface JAMarkNavigationView ()
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIView *backView;      // 背景view
@property (nonatomic, weak) UIView *lineView;  // 线
@property (nonatomic, assign) BOOL isEdge;  // 是否需要在边缘
@end
@implementation JAMarkNavigationView

- (void)markNavBarView_changeInfoButtonToEdge:(BOOL)isEdge
{
    self.isEdge = isEdge;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMarkNavigationViewUI];
    }
    return self;
}

- (void)setupMarkNavigationViewUI
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_StatusBarAndNavigationBarHeight;
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = [UIColor whiteColor];
    backView.alpha = 0;
    [self addSubview:backView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton = leftButton;
    [leftButton setImage:[UIImage imageNamed:@"circle_back_white"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateSelected];
    [leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self addSubview:leftButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @" ";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = JA_REGULAR_FONT(18);
//    titleLabel.alpha = 0;
    [self addSubview:titleLabel];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
//    [rightButton setImage:[UIImage imageNamed:@"circle_info_white"] forState:UIControlStateNormal];
//    [rightButton setImage:[UIImage imageNamed:@"circle_info_black"] forState:UIControlStateSelected];
    [self addSubview:rightButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.alpha = 0;
    lineView.backgroundColor = HEX_COLOR(0xededed);
    [self addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMarkNavigationViewFrame];
}

- (void)calculatorMarkNavigationViewFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_StatusBarAndNavigationBarHeight;
    
    self.backView.width = self.width;
    self.backView.height = self.height;
    
    self.leftButton.width = 60;
    self.leftButton.height = self.height - JA_StatusBarHeight;
    self.leftButton.x = 10;
    self.leftButton.y = JA_StatusBarHeight;
    
    [self.titleLabel sizeToFit];
    self.titleLabel.centerY = self.leftButton.centerY;
    self.titleLabel.centerX = self.width * 0.5;
    
    self.rightButton.width = 60;
    self.rightButton.height = self.leftButton.height;
    self.rightButton.x = self.isEdge ? self.width - 5 - self.rightButton.width : self.width - 35 - self.rightButton.width;
    self.rightButton.y = self.leftButton.y;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    self.lineView.y = self.height - 1;
}

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
    self.lineView.alpha = scale;
    
    if (scale >= 0.5) {
        self.leftButton.selected = YES;
        self.rightButton.selected = YES;
        self.leftButton.alpha = (scale - 0.5) * 2;
        self.rightButton.alpha = (scale - 0.5) * 2;
        self.titleLabel.textColor = HEX_COLOR_ALPHA(0x444444,(scale - 0.5) * 2);
    }else{
        self.leftButton.selected = NO;
        self.rightButton.selected = NO;
        self.leftButton.alpha = 1 - scale * 2;
        self.rightButton.alpha = 1 - scale * 2;
        self.titleLabel.textColor = HEX_COLOR_ALPHA(0xffffff,1 - scale * 2);
    }
    
}

- (void)setTitleName:(NSString *)titleName
{
    _titleName = titleName;
    self.titleLabel.text = titleName;
    [self.titleLabel sizeToFit];
}
@end
