//
//  JAAboutUsCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAboutUsCell.h"

@interface JAAboutUsCell ()

@property (nonatomic, weak) UILabel *leftLabel;
@property (nonatomic, weak) UILabel *rightLabel;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIView *lineView;

@end
@implementation JAAboutUsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupAboutUs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}


- (void)setupAboutUs
{
    UILabel *leftLabel = [[UILabel alloc] init];
    _leftLabel = leftLabel;
    leftLabel.text = @" ";
    leftLabel.textColor = HEX_COLOR(JA_ListTitle);
    leftLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] init];
    _rightLabel = rightLabel;
    rightLabel.contentMode = UIViewContentModeRight;
    rightLabel.text = @" ";
    rightLabel.textColor = HEX_COLOR(JA_ListTitle);
    rightLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:rightLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowImageView;
    [self.contentView addSubview:arrowImageView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self culatorAboutUs];
}

- (void)culatorAboutUs
{
    self.leftLabel.x = 14;
    [self.leftLabel sizeToFit];
    self.leftLabel.centerY = self.contentView.height * 0.5;
    
    [self.rightLabel sizeToFit];
    self.rightLabel.x = self.contentView.width - 14 - self.rightLabel.width;
    self.rightLabel.centerY = self.leftLabel.centerY;
    
    self.arrowImageView.x = self.contentView.width - self.arrowImageView.width - 14;
    self.arrowImageView.centerY = self.leftLabel.centerY;
    
    self.lineView.x = 14;
    self.lineView.y = self.contentView.height - 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.height = 1;
}


- (void)setAboutUsDic:(NSDictionary *)aboutUsDic
{
    _aboutUsDic = aboutUsDic;
    
    self.leftLabel.text = aboutUsDic[@"title"];
    NSString *str = aboutUsDic[@"subTitle"];
    if ([str hasPrefix:@"http://"] || [str hasPrefix:@"https://"]) {
        
        self.arrowImageView.hidden = NO;
        self.rightLabel.hidden = YES;
        
    }else{
        self.arrowImageView.hidden = YES;
        self.rightLabel.hidden = NO;
    }
    
    self.rightLabel.text = aboutUsDic[@"subTitle"];
}

@end
