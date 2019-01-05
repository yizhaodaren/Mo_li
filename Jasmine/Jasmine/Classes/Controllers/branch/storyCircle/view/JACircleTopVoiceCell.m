//
//  JACircleTopVoiceCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleTopVoiceCell.h"
#import "JANewVoiceModel.h"

@interface JACircleTopVoiceCell ()
@property (nonatomic, weak) UIImageView *jingHuaImageView;
@property (nonatomic, weak) UIImageView *dingImageView;
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation JACircleTopVoiceCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupCircleTopVoiceCellUI];
    }
    return self;
}

- (void)setVoiceModel:(JANewVoiceModel *)voiceModel
{
    _voiceModel = voiceModel;
    if (voiceModel.title.length) {
        self.nameLabel.text = [voiceModel.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }else{
        self.nameLabel.text = [voiceModel.content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    [self setNeedsLayout];
    [self layoutIfNeeded];
    // 判断是否是精华帖 调整x值
    if (voiceModel.essence) {
        self.jingHuaImageView.hidden = NO;
        self.nameLabel.x = self.jingHuaImageView.right + 5;
    }else{
        self.jingHuaImageView.hidden = YES;
        self.nameLabel.x = self.dingImageView.right + 5;
    }
    
}

- (void)setupCircleTopVoiceCellUI
{
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self.contentView addSubview:lineView];
    
    UIImageView *dingImageView = [[UIImageView alloc] init];
    _dingImageView = dingImageView;
    dingImageView.image = [UIImage imageNamed:@"circle_ding"];
    [self.contentView addSubview:dingImageView];
    
    UIImageView *jingHuaImageView = [[UIImageView alloc] init];
    _jingHuaImageView = jingHuaImageView;
    jingHuaImageView.image = [UIImage imageNamed:@"circle_jinghua"];
    jingHuaImageView.hidden = YES;
    [self.contentView addSubview:jingHuaImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x363636);
    nameLabel.font = JA_REGULAR_FONT(16);
    [self.contentView addSubview:nameLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleTopVoiceCellFrame];
}

- (void)calculatorCircleTopVoiceCellFrame
{
    self.lineView.x = 15;
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    
    self.dingImageView.width = 16;
    self.dingImageView.height = 16;
    self.dingImageView.centerY = self.contentView.height * 0.5;
    self.dingImageView.x = 15;
    
    self.jingHuaImageView.width = 16;
    self.jingHuaImageView.height = 16;
    self.jingHuaImageView.centerY = self.contentView.height * 0.5;
    self.jingHuaImageView.x = self.dingImageView.right + 5;
    
    self.nameLabel.width = self.contentView.width - 30 - self.jingHuaImageView.x;
    self.nameLabel.height = 22;
    self.nameLabel.centerY = self.contentView.height * 0.5;
}
@end
