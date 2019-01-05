//
//  JAOfficCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAOfficCell.h"
#import "JAOfficModel.h"
//#import "NSString+Extention.h"

#define kScale [self getScale]

@interface JAOfficCell ()
@property (nonatomic, weak) UILabel *timeLabel;

@property (nonatomic, weak) UIImageView *moliJunImageView;

@property (nonatomic, weak) UIImageView *image_view;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *contentLabel;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIButton *detailButton;
@property (nonatomic, weak) UIImageView *arrowImageView;

@end

@implementation JAOfficCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCell];
        self.contentView.backgroundColor = HEX_COLOR(0xF4F4F4);
        self.selectionStyle =  UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupCell
{
    UILabel *timeLabel = [[UILabel alloc] init];
    _timeLabel = timeLabel;
    timeLabel.backgroundColor = HEX_COLOR(0xF9F9F9);
    timeLabel.layer.cornerRadius = 4;
    timeLabel.clipsToBounds = YES;
    timeLabel.textAlignment = NSTextAlignmentCenter;
    timeLabel.text = @"6-17 6:30";
    timeLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    timeLabel.font = JA_REGULAR_FONT(11);
    [self.contentView addSubview:timeLabel];
    
    UIImageView *moliJunImageView = [[UIImageView alloc] init];
    _moliJunImageView = moliJunImageView;
    moliJunImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpMoliJunCenter)];
    [moliJunImageView addGestureRecognizer:tap1];
    moliJunImageView.image = [UIImage imageNamed:@"moli_jun"];
    [self.contentView addSubview:moliJunImageView];
    
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = HEX_COLOR(0xF4F4F4);
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 4;
    backView.clipsToBounds = YES;
    [self.contentView addSubview:backView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpUrl)];
    [backView addGestureRecognizer:tap];
    
    UIImageView *image_view = [[UIImageView alloc] init];
    _image_view = image_view;
    [backView addSubview:image_view];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel =titleLabel;
    titleLabel.text = @"官方消息";
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = HEX_COLOR(0x454C57);
    titleLabel.font = JA_MEDIUM_FONT(14);
    [backView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    _contentLabel =contentLabel;
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"消息的具体内容";
    contentLabel.textColor = HEX_COLOR(0x454C57);
    contentLabel.font = JA_REGULAR_FONT(14);
    [backView addSubview:contentLabel];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = HEX_COLOR(0xF4F4F4);
    bottomView.backgroundColor = [UIColor whiteColor];
    [backView addSubview:bottomView];
    
    UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _detailButton = detailButton;
    detailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [detailButton setTitle:@"查看详情" forState:UIControlStateNormal];
    [detailButton setTitleColor:HEX_COLOR(0x1CD39B) forState:UIControlStateNormal];
    detailButton.titleLabel.font = JA_MEDIUM_FONT(14);
    [detailButton addTarget:self action:@selector(jumpUrl) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:detailButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [bottomView addSubview:lineView];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowImage;
    [bottomView addSubview:arrowImage];
}

- (void)setModel:(JAOfficModel *)model
{

    _model = model;
    
    self.timeLabel.frame = CGRectIntegral(model.timeFrame);
    self.moliJunImageView.frame = model.moliJunFrame;
    self.backView.frame = model.backFrame;
    self.image_view.frame = model.imageFrame;
    self.titleLabel.frame = model.titleFrame;
    self.contentLabel.frame = model.contentFrame;
    self.bottomView.frame = model.urlFrame;
    self.lineView.frame = model.urlLineFrame;
    self.detailButton.frame = model.urlButtonFrame;
    self.arrowImageView.frame = model.urlArrowFrame;
    if (model.urlFrame.size.height > 0) {
        self.backView.userInteractionEnabled = YES;
    }else{
        self.backView.userInteractionEnabled = NO;
    }
    
    self.moliJunImageView.layer.cornerRadius = self.moliJunImageView.height * 0.5;
    self.moliJunImageView.layer.masksToBounds = YES;
    
    self.timeLabel.text = [NSString distanceTimeWithBeforeTime:[model.time doubleValue]];
    [self.image_view ja_setImageWithURLStr:model.image];
    self.titleLabel.text = model.title;
    self.contentLabel.text = model.content;
    
}

- (void)jumpUrl
{
    if (self.clickDetailBlock) {
        self.clickDetailBlock(self);
    }
    
}

- (void)jumpMoliJunCenter
{
    if (self.clickmoliJunBlock) {
        self.clickmoliJunBlock(self);
    }
}

- (CGFloat)getScale
{
    if ([UIScreen mainScreen].bounds.size.width == 375) {
        
        return 1;
    }else if ([UIScreen mainScreen].bounds.size.width == 414){
        return 414/375.0;
    }else{
        return 320 / 375.0;
    }
}
@end
