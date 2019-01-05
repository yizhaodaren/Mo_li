//
//  JAChooseChannelCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAChooseChannelCell.h"

@interface JAChooseChannelCell ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *title_label;
@property (nonatomic, weak) UILabel *subtitle_label;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation JAChooseChannelCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChooseChannelCell];
    }
    return self;
}

- (void)setupChooseChannelCell
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    iconImageView.layer.cornerRadius = 22.5;
    iconImageView.layer.masksToBounds = YES;
    _iconImageView = iconImageView;
//    _iconImageView.image = [UIImage imageNamed:@"branch_choose_bb"];
    [self.contentView addSubview:iconImageView];
    
    UILabel *title_label = [[UILabel alloc] init];
    _title_label = title_label;
//    title_label.text = @"哔哔";
    title_label.textColor = HEX_COLOR(JA_BlackTitle);
    title_label.font = JA_REGULAR_FONT(16);
    [self.contentView addSubview:title_label];
    
    UILabel *subtitle_label = [[UILabel alloc] init];
    _subtitle_label = subtitle_label;
//    subtitle_label.text = @"一起吹牛B！都是老司机～";
    subtitle_label.textColor = HEX_COLOR(JA_BlackSubTitle);
    subtitle_label.font = JA_REGULAR_FONT(13);
    [self.contentView addSubview:subtitle_label];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorChooseChannelCell];
}

- (void)caculatorChooseChannelCell
{
    self.iconImageView.width = 45;
    self.iconImageView.height = 45;
    self.iconImageView.x = 14;
    self.iconImageView.centerY = self.contentView.height * 0.5;
    
    self.title_label.x = self.iconImageView.right + 14;
    self.title_label.width = self.contentView.width - self.title_label.x - 14;
    self.title_label.height = 22;
    self.title_label.y = self.iconImageView.y;
    
    self.subtitle_label.x = self.title_label.x;
    self.subtitle_label.width = self.contentView.width - self.subtitle_label.x - 14;
    self.subtitle_label.height = 18;
    self.subtitle_label.y = self.title_label.bottom + 5;
    
    self.lineView.x = self.title_label.x;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - self.lineView.height;
}

- (void)setData:(JAChannelModel *)data {
    _data = data;
    
    int h = 45;
    int w = h;
    NSString *url = [data.image ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:url];
    
    self.title_label.text = data.title;
    self.subtitle_label.text = data.content;
}

@end
