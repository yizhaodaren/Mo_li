//
//  JABottomDoubleButtonView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABottomDoubleButtonView.h"

@interface JABottomDoubleButtonView ()
@property (nonatomic, weak) UIView *lineView;
@end

@implementation JABottomDoubleButtonView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupBottomDoubleButtonViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupBottomDoubleButtonViewUI
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton = leftButton;
    [self addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
    [self addSubview:rightButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xededed);
    [self addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorBottomDoubleButtonViewFrame];
}

- (void)calculatorBottomDoubleButtonViewFrame
{
    self.leftButton.width = self.width * 0.5;
    self.leftButton.height = self.height - JA_TabbarSafeBottomMargin;
    
    self.rightButton.width = self.width * 0.5;
    self.rightButton.height = self.height - JA_TabbarSafeBottomMargin;
    self.rightButton.x = self.leftButton.right;
    
    self.lineView.width = self.width;
    self.lineView.height = 1;
}
@end
