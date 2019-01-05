//
//  JAHomeSignStepCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAHomeSignStepCell.h"

@interface JAHomeSignStepCell ()

@property (nonatomic, weak) UIButton *topLineButton;  // 上竖线
@property (nonatomic, weak) UIButton *circleButton;   // 圆点
@property (nonatomic, weak) UIButton *bottomButton;   // 下竖线

@property (nonatomic, weak) UIButton *todayNumButton;  // 天数
@property (nonatomic, weak) UIButton *awardButton;    // 奖励
@end

@implementation JAHomeSignStepCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupHomeSignStepCellUI];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


/*
 dic[@"signTime"]
 dic[@"signAward"]
 dic[@"signCount"]
 dic[@"signTag"]
 */

- (void)setDictionaryModel:(NSDictionary *)dictionaryModel
{
    _dictionaryModel = dictionaryModel;
    
    if ([dictionaryModel[@"signTag"] integerValue] == 1) {
        self.topLineButton.hidden = YES;
        self.bottomButton.hidden = NO;
    }else if ([dictionaryModel[@"signTag"] integerValue] == 7){
        self.topLineButton.hidden = NO;
        self.bottomButton.hidden = YES;
    }else{
        self.topLineButton.hidden = NO;
        self.bottomButton.hidden = NO;
    }
    
    if ([dictionaryModel[@"signTime"] integerValue] < [dictionaryModel[@"signCount"] integerValue]) {
        self.topLineButton.selected = YES;
        self.circleButton.selected = YES;
        self.bottomButton.selected = YES;
        self.todayNumButton.selected = YES;
        self.awardButton.selected = YES;
    }else if ([dictionaryModel[@"signTime"] integerValue] == [dictionaryModel[@"signCount"] integerValue]){
        self.topLineButton.selected = YES;
        self.circleButton.selected = YES;
        self.todayNumButton.selected = YES;
        self.awardButton.selected = YES;
    }else{
        self.topLineButton.selected = NO;
        self.circleButton.selected = NO;
        self.bottomButton.selected = NO;
        self.todayNumButton.selected = NO;
        self.awardButton.selected = NO;
    }
    
    [self.todayNumButton setTitle:[NSString stringWithFormat:@"第%@天",dictionaryModel[@"signTime"]] forState:UIControlStateNormal];
    if ([dictionaryModel[@"signAward"] isEqualToString:@"红包"]) {
        [self.awardButton setTitle:[NSString stringWithFormat:@"+拼手气%@",dictionaryModel[@"signAward"]] forState:UIControlStateNormal];
    }else{
        [self.awardButton setTitle:[NSString stringWithFormat:@"+%@朵茉莉花",dictionaryModel[@"signAward"]] forState:UIControlStateNormal];
    }
}

#pragma mark - UI
- (void)setupHomeSignStepCellUI
{
    UIButton *topLineButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _topLineButton = topLineButton;
    [topLineButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xEAEAEA)] forState:UIControlStateNormal];
    [topLineButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xAFF5A8)] forState:UIControlStateSelected];
    [self.contentView addSubview:topLineButton];
    
    UIButton *circleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _circleButton = circleButton;
    [circleButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xEAEAEA)] forState:UIControlStateNormal];
    [circleButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xAFF5A8)] forState:UIControlStateSelected];
    [self.contentView addSubview:circleButton];
    
    UIButton *bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _bottomButton = bottomButton;
    [bottomButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xEAEAEA)] forState:UIControlStateNormal];
    [bottomButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xAFF5A8)] forState:UIControlStateSelected];
    [self.contentView addSubview:bottomButton];
    
    UIButton *todayNumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _todayNumButton = todayNumButton;
    [todayNumButton setTitle:@"第一天" forState:UIControlStateNormal];
    [todayNumButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
    [todayNumButton setTitleColor:HEX_COLOR(0x009667) forState:UIControlStateSelected];
    todayNumButton.titleLabel.font = JA_REGULAR_FONT(14);
    todayNumButton.userInteractionEnabled = NO;
    [self.contentView addSubview:todayNumButton];
    
    UIButton *awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _awardButton = awardButton;
    [awardButton setTitle:@"+30朵茉莉花" forState:UIControlStateNormal];
    [awardButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
    [awardButton setTitleColor:HEX_COLOR(0x009667) forState:UIControlStateSelected];
    awardButton.titleLabel.font = JA_REGULAR_FONT(14);
    awardButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    awardButton.userInteractionEnabled = NO;
    [self.contentView addSubview:awardButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorHomeSignStepCellFrame];
}

- (void)calculatorHomeSignStepCellFrame
{
    self.topLineButton.width = 2;
    self.topLineButton.height = 11;
    self.topLineButton.centerX = 67;
    
    self.circleButton.width = 10;
    self.circleButton.height = 10;
    self.circleButton.y = self.topLineButton.bottom;
    self.circleButton.centerX = self.topLineButton.centerX;
    self.circleButton.layer.cornerRadius = self.circleButton.height * 0.5;
    self.circleButton.layer.masksToBounds = YES;
    
    self.bottomButton.width = 2;
    self.bottomButton.height = 11;
    self.bottomButton.y = self.circleButton.bottom;
    self.bottomButton.centerX = self.topLineButton.centerX;
    
    self.todayNumButton.width = 82;
    self.todayNumButton.height = 20;
    self.todayNumButton.x = self.circleButton.right + 3;
    self.todayNumButton.centerY = self.circleButton.centerY;
    
    self.awardButton.width = 85;
    self.awardButton.height = 20;
    self.awardButton.x = self.todayNumButton.right;
    self.awardButton.centerY = self.circleButton.centerY;
}
@end
