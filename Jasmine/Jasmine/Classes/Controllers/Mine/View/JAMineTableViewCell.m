//
//  JAMineTableViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAMineTableViewCell.h"

@interface JAMineTableViewCell ()
@property (nonatomic, weak) UIImageView *icomImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *subNameLabel;
@property (nonatomic, weak) UIImageView *subImageView;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIView *lineview;

@property (nonatomic, weak) UIButton *signTagButton;    // 签 到
@property (nonatomic, weak) UIView *activityRedView;  // 活动红点
@property (nonatomic, weak) UILabel *draftLabel;  // 草稿
@end



@implementation JAMineTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setup];
    }
    return self;
}


- (void)setup
{
    UIImageView *iconV = [[UIImageView alloc] init];
    _icomImageView = iconV;
    iconV.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:iconV];
    
    UILabel *nameL = [[UILabel alloc] init];
    _nameLabel = nameL;
    nameL.textColor = HEX_COLOR(0x454C57);
    nameL.font = JA_REGULAR_FONT(16);
    [self.contentView addSubview:nameL];
    
    UILabel *subNameL = [[UILabel alloc] init];
    _subNameLabel = subNameL;
    subNameL.textColor = HEX_COLOR(JA_BlackSubTitle);
    subNameL.font = JA_LIGHT_FONT(13);
    [self.contentView addSubview:subNameL];
    
    UIImageView *subImageView = [[UIImageView alloc] init];
    _subImageView = subImageView;
    [self.contentView addSubview:subImageView];
    
    UIImageView *arrowV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowV;
    [self.contentView addSubview:arrowV];
    
    UIView *lineV = [[UIView alloc] init];
    _lineview = lineV;
    lineV.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineV];
    
    UIButton *signTagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _signTagButton = signTagButton;
    [signTagButton setTitle:@"签到" forState:UIControlStateNormal];
    [signTagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signTagButton.titleLabel.font = JA_REGULAR_FONT(8);
    signTagButton.backgroundColor = HEX_COLOR(0xF75549);
//    [signTagButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
//    [signTagButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
//    [signTagButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateSelected];
    signTagButton.hidden = YES;
    [self.contentView addSubview:signTagButton];
    
    UIView *activityRedView = [[UIView alloc] init];
    _activityRedView = activityRedView;
    activityRedView.backgroundColor = HEX_COLOR(0xFE3824);
    activityRedView.hidden = YES;
    [self.contentView addSubview:activityRedView];
    
    UILabel *draftLabel = [[UILabel alloc] init];
    _draftLabel = draftLabel;
    draftLabel.backgroundColor = HEX_COLOR(0xFF3B30);
    draftLabel.text = @" ";
    draftLabel.textColor = HEX_COLOR(0xffffff);
    draftLabel.font = JA_MEDIUM_FONT(10);
    draftLabel.hidden = YES;
    draftLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:draftLabel];
    
    self.contentView.backgroundColor = HEX_COLOR(JA_Background);
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.icomImageView.width = 20;
    self.icomImageView.height = 20;
    self.icomImageView.x = 21;
    self.icomImageView.centerY = self.contentView.height * 0.5;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 22;
    self.nameLabel.centerY = self.icomImageView.centerY;
    self.nameLabel.x = self.icomImageView.right + 20;
    
    self.arrowImageView.width = 6;
    self.arrowImageView.height = 10;
    self.arrowImageView.centerY = self.icomImageView.centerY;
    self.arrowImageView.x = self.contentView.width - 20 - self.arrowImageView.width;
    
    [self.subNameLabel sizeToFit];
    self.subNameLabel.height = 17;
    self.subNameLabel.centerY = self.nameLabel.centerY;
    self.subNameLabel.x = self.arrowImageView.x - 15 - self.subNameLabel.width;
    
    self.subImageView.width = 40;
    self.subImageView.height = 30;
    self.subImageView.centerY = self.nameLabel.centerY;
    self.subImageView.x = self.arrowImageView.x - 15 - self.subImageView.width;
    
    self.lineview.x = self.nameLabel.x;
    self.lineview.y = self.contentView.height - 1;
    self.lineview.width = self.contentView.width - self.lineview.x;
    self.lineview.height = 1;
    
    self.signTagButton.width = 22;
    self.signTagButton.height = 10;
    self.signTagButton.x = self.nameLabel.right;
    self.signTagButton.centerY = self.nameLabel.y + 3;
    self.signTagButton.layer.cornerRadius = self.signTagButton.height * 0.5;
    self.signTagButton.layer.masksToBounds = YES;
    
    self.activityRedView.width = 6;
    self.activityRedView.height = 6;
    self.activityRedView.layer.cornerRadius = self.activityRedView.height * 0.5;
    self.activityRedView.layer.masksToBounds = YES;
    self.activityRedView.x = self.nameLabel.right + 5;
    self.activityRedView.centerY = self.contentView.height * 0.5;
    
    [self.draftLabel sizeToFit];
    self.draftLabel.width = self.draftLabel.width + 4;
    if (self.draftLabel.width < 16) {
        self.draftLabel.width = 16;
    }
    self.draftLabel.height = 16;
    self.draftLabel.x = self.arrowImageView.x - 15 - self.draftLabel.width;
    self.draftLabel.centerY = self.contentView.height * 0.5;
    self.draftLabel.layer.cornerRadius = self.draftLabel.height * 0.5;
    self.draftLabel.layer.masksToBounds = YES;
}

/*
 @"name" : @"福利活动",
 @"subName" : @" ",
 @"image" : @"branch_mine_activity",
 @"class" : @"JAActivityCenterViewController",
 @"leftTag" : leftT,  // 0 不展示  1 签到  2 活动红点
 @"rightTag" : @"0-0"
 */

- (void)setCellDic:(NSDictionary *)cellDic
{
    _cellDic = cellDic;
    
    self.icomImageView.image = [UIImage imageNamed:cellDic[@"image"]];
    self.nameLabel.text = cellDic[@"name"];
    if ([self.nameLabel.text isEqualToString:@"我的勋章"] && (![cellDic[@"subName"] isEqualToString:@"未获得"] && ![cellDic[@"subName"] isEqualToString:@"未佩戴"])) {
        self.subNameLabel.text = @" ";
        [self.subImageView ja_setImageWithURLStr:cellDic[@"subName"]];
        self.subImageView.hidden = NO;
    }else{
        self.subNameLabel.text = cellDic[@"subName"];
        self.subImageView.hidden = YES;
    }
    
    
    NSInteger leftT = [cellDic[@"leftTag"] integerValue];
    
    if (leftT == 0) {
        self.signTagButton.hidden = YES;
        self.activityRedView.hidden = YES;
    }else if (leftT == 1){
        self.signTagButton.hidden = NO;
        self.activityRedView.hidden = YES;
    }else if (leftT == 2){
        self.signTagButton.hidden = YES;
        self.activityRedView.hidden = NO;
    }else{
        self.signTagButton.hidden = YES;
        self.activityRedView.hidden = YES;
    }
    
    NSString *rightT = cellDic[@"rightTag"] ;
    NSArray *arr = [rightT componentsSeparatedByString:@"-"];
    NSInteger first = [arr.firstObject integerValue];
    NSInteger last = [arr.lastObject integerValue];
    
    if (first > 0 || last > 0) {
        self.draftLabel.hidden = NO;
        if (first > 0) {
            self.draftLabel.backgroundColor = HEX_COLOR(0xFF3B30);
            self.draftLabel.text = [NSString stringWithFormat:@"%ld",last];
        }else{
            self.draftLabel.backgroundColor = HEX_COLOR(0xC6C6C6);
            self.draftLabel.text = [NSString stringWithFormat:@"%ld",last];
        }
    }else{
        self.draftLabel.hidden = YES;
    }
    
}

- (void)setBottomLineHidden:(BOOL)hidden {
    self.lineview.hidden = hidden;
}
@end
