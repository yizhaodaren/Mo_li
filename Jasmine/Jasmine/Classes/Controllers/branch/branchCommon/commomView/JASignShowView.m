//
//  JASignShowView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JASignShowView.h"

@interface JASignShowView ()
@property (nonatomic, weak) UIView *lineView1;
@property (nonatomic, weak) UIView *point1;
@property (nonatomic, weak) UIView *point2;
@property (nonatomic, weak) UIView *point3;
@property (nonatomic, weak) UIView *lineView2;
@end

@implementation JASignShowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSignShowViewUI];
    }
    return self;
}

#pragma mark - UI
- (void)setupSignShowViewUI
{
    UIView *lineView1 = [[UIView alloc] init];
    _lineView1 = lineView1;
    lineView1.backgroundColor = HEX_COLOR(0x009667);
    [self addSubview:lineView1];
    
    UIView *lineView2 = [[UIView alloc] init];
    _lineView2 = lineView2;
    lineView2.backgroundColor = HEX_COLOR(0xE2E2E2);
    [self addSubview:lineView2];
    
    UIView *point1 = [[UIView alloc] init];
    _point1 = point1;
    point1.backgroundColor = HEX_COLOR(0x009667);
    [self addSubview:point1];
    
    UIView *point2 = [[UIView alloc] init];
    _point2 = point2;
    point2.backgroundColor = HEX_COLOR(0xE2E2E2);
    [self addSubview:point2];
    
    UIView *point3 = [[UIView alloc] init];
    _point3 = point3;
    point3.backgroundColor = HEX_COLOR(0xE2E2E2);
    [self addSubview:point3];
    
    UILabel *dayLabel1 = [[UILabel alloc] init];
    _dayLabel1 = dayLabel1;
    dayLabel1.text = @" ";
    dayLabel1.textColor = HEX_COLOR(0x009667);
    dayLabel1.font = JA_REGULAR_FONT(14);
    [self addSubview:dayLabel1];
    
    UILabel *dayLabel2 = [[UILabel alloc] init];
    _dayLabel2 = dayLabel2;
    dayLabel2.text = @" ";
    dayLabel2.textColor = HEX_COLOR(0xB7B7B7);
    dayLabel2.font = JA_REGULAR_FONT(14);
    [self addSubview:dayLabel2];
    
    UILabel *dayLabel3 = [[UILabel alloc] init];
    _dayLabel3 = dayLabel3;
    dayLabel3.text = @" ";
    dayLabel3.textColor = HEX_COLOR(0xB7B7B7);
    dayLabel3.font = JA_REGULAR_FONT(14);
    [self addSubview:dayLabel3];
    
    UILabel *awardLabel1 = [[UILabel alloc] init];
    _awardLabel1 = awardLabel1;
    awardLabel1.text = @" ";
    awardLabel1.textColor = HEX_COLOR(0x009667);
    awardLabel1.font = JA_REGULAR_FONT(14);
    [self addSubview:awardLabel1];
    
    UILabel *awardLabel2 = [[UILabel alloc] init];
    _awardLabel2 = awardLabel2;
    awardLabel2.text = @" ";
    awardLabel2.textColor = HEX_COLOR(0xB7B7B7);
    awardLabel2.font = JA_REGULAR_FONT(14);
    [self addSubview:awardLabel2];
    
    UILabel *awardLabel3 = [[UILabel alloc] init];
    _awardLabel3 = awardLabel3;
    awardLabel3.text = @" ";
    awardLabel3.textColor = HEX_COLOR(0xB7B7B7);
    awardLabel3.font = JA_REGULAR_FONT(14);
    [self addSubview:awardLabel3];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorSignShowViewFrame];
}

- (void)calculatorSignShowViewFrame
{
    self.lineView1.width = 2;
    self.lineView1.height = 32;
    self.lineView1.x = 67;
    
    self.lineView2.width = 2;
    self.lineView2.height = self.height - self.lineView1.height;
    self.lineView2.x = 67;
    self.lineView2.y = self.lineView1.bottom;
    
    self.point1.width = 17;
    self.point1.height = 17;
    self.point1.layer.cornerRadius = self.point1.height * 0.5;
    self.point1.layer.masksToBounds = YES;
    self.point1.centerX = self.lineView1.centerX;
    self.point1.y = self.lineView1.bottom;
    
    self.point2.width = 10;
    self.point2.height = 10;
    self.point2.layer.cornerRadius = self.point2.height * 0.5;
    self.point2.layer.masksToBounds = YES;
    self.point2.centerX = self.lineView1.centerX;
    self.point2.y = self.point1.bottom + 18;
    
    self.point3.width = 10;
    self.point3.height = 10;
    self.point3.layer.cornerRadius = self.point2.height * 0.5;
    self.point3.layer.masksToBounds = YES;
    self.point3.centerX = self.lineView1.centerX;
    self.point3.y = self.point2.bottom + 21;
    
    [self.dayLabel1 sizeToFit];
    self.dayLabel1.x = self.lineView1.right + 20;
    self.dayLabel1.centerY = self.point1.centerY;
    
    [self.dayLabel2 sizeToFit];
    self.dayLabel2.x = self.lineView1.right + 20;
    self.dayLabel2.centerY = self.point2.centerY;
    
    [self.dayLabel3 sizeToFit];
    self.dayLabel3.x = self.lineView1.right + 20;
    self.dayLabel3.centerY = self.point3.centerY;
    
    [self.awardLabel1 sizeToFit];
    self.awardLabel1.x = self.width * 0.5;
    self.awardLabel1.centerY = self.point1.centerY;
    
    [self.awardLabel2 sizeToFit];
    self.awardLabel2.x = self.width * 0.5;
    self.awardLabel2.centerY = self.point2.centerY;
    
    [self.awardLabel3 sizeToFit];
    self.awardLabel3.x = self.width * 0.5;
    self.awardLabel3.centerY = self.point3.centerY;
}
@end
