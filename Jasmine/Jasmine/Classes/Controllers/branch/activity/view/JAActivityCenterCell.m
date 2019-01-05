//
//  JAActivityCenterCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAActivityCenterCell.h"
#import "JAActivityModel.h"

@interface JAActivityCenterCell ()

@property (nonatomic, strong) UIView *activityView;
@property (nonatomic, strong) UIImageView *activityImageView;
@property (nonatomic, strong) UILabel *activityNameLabel;
@property (nonatomic, strong) UILabel *activityTimeLabel;
@property (nonatomic, strong) UILabel *validLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation JAActivityCenterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupActivityCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = HEX_COLOR(JA_Line);
    }
    return self;
}

- (void)setModel:(JAActivityModel *)model
{
    _model = model;
    
    [self.activityImageView ja_setImageWithURLStr:model.activityImage];
    
    if (model.isExpire.integerValue == 0) {
        self.validLabel.hidden = YES;
        self.arrowImageView.hidden = NO;
    }else{
        self.validLabel.hidden = NO;
        self.arrowImageView.hidden = YES;
    }
    
    self.activityNameLabel.text = model.title;
    self.activityTimeLabel.text = [NSString timeToString:model.startTime];
}


- (void)setupActivityCell
{
    self.activityView = [[UIView alloc] init];
    self.activityView.backgroundColor = [UIColor whiteColor];
    self.activityView.layer.cornerRadius = 4;
    self.activityView.layer.masksToBounds = YES;
    [self.contentView addSubview:self.activityView];
    
    self.activityImageView = [[UIImageView alloc] init];
    [self.activityView addSubview:self.activityImageView];
    
    self.activityNameLabel = [[UILabel alloc] init];
    self.activityNameLabel.text = @" ";
    self.activityNameLabel.textColor = HEX_COLOR(0x373C43);
    self.activityNameLabel.font = JA_REGULAR_FONT(13);
    [self.activityView addSubview:self.activityNameLabel];
    
    self.activityTimeLabel = [[UILabel alloc] init];
    self.activityTimeLabel.text = @" ";
    self.activityTimeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.activityTimeLabel.font = JA_REGULAR_FONT(11);
    [self.activityView addSubview:self.activityTimeLabel];
    
    self.validLabel = [[UILabel alloc] init];
    self.validLabel.text = @"活动结束";
    self.validLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.validLabel.font = JA_REGULAR_FONT(11);
    self.validLabel.textAlignment = NSTextAlignmentCenter;
    self.validLabel.hidden = YES;
    [self.activityView addSubview:self.validLabel];
    
    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    self.arrowImageView.hidden = YES;
    [self.activityView addSubview:self.arrowImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.activityView.width = WIDTH_ADAPTER(345);
    self.activityView.height = WIDTH_ADAPTER(160);
    self.activityView.x = WIDTH_ADAPTER(15);
    self.activityView.y = WIDTH_ADAPTER(15);
    
    self.activityImageView.width = self.activityView.width;
    self.activityImageView.height = WIDTH_ADAPTER(120);
    
    [self.activityNameLabel sizeToFit];
    self.activityNameLabel.x = 15;
    self.activityNameLabel.y = self.activityImageView.bottom + WIDTH_ADAPTER(3);
    self.activityNameLabel.height = WIDTH_ADAPTER(18);
    
    [self.activityTimeLabel sizeToFit];
    self.activityTimeLabel.height = WIDTH_ADAPTER(16);
    self.activityTimeLabel.x = self.activityNameLabel.x;
    self.activityTimeLabel.y = self.activityNameLabel.bottom;
    
    self.validLabel.width = 60;
    self.validLabel.height = WIDTH_ADAPTER(18);
    self.validLabel.x = self.activityView.width - 15 - self.validLabel.width;
    self.validLabel.y = self.activityImageView.bottom + WIDTH_ADAPTER(11);
    self.validLabel.layer.cornerRadius = self.validLabel.height * 0.5;
    self.validLabel.layer.borderWidth = 1;
    self.validLabel.layer.borderColor = HEX_COLOR(JA_Line).CGColor;
    self.validLabel.layer.masksToBounds = YES;
    
    self.arrowImageView.x = self.activityView.width - 15 - self.arrowImageView.width;
    self.arrowImageView.y = self.activityImageView.bottom + WIDTH_ADAPTER(14);
}
@end
