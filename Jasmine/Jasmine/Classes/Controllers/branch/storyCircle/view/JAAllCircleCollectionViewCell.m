//
//  JAAllCircleCollectionViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAAllCircleCollectionViewCell.h"

@interface JAAllCircleCollectionViewCell ()
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UIImageView *circleImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *circleDesLabel;
@property (nonatomic, weak) UILabel *focusCountLabel;
@end

@implementation JAAllCircleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAllCircleCollectionViewCellUI];
    }
    return self;
}

- (void)setCircleModel:(JACircleModel *)circleModel
{
    [self.circleImageView ja_setImageWithURLStr:circleModel.circleThumb];
    self.nameLabel.text = circleModel.circleName;
    self.circleDesLabel.text = circleModel.circleDesc;
    self.focusCountLabel.text = [NSString stringWithFormat:@"%@人关注",circleModel.followCount];
    [self.focusCountLabel sizeToFit];
}

- (void)setupAllCircleCollectionViewCellUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = HEX_COLOR(0xF7F7F8);
    backView.layer.cornerRadius = 5;
    backView.layer.masksToBounds = YES;
    [self.contentView addSubview:backView];
    
    UIImageView *circleImageView = [[UIImageView alloc] init];
    _circleImageView = circleImageView;
    [self.contentView addSubview:circleImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x363636);
    nameLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:nameLabel];
    
    UILabel *circleDesLabel = [[UILabel alloc] init];
    _circleDesLabel = circleDesLabel;
    circleDesLabel.text = @" ";
    circleDesLabel.textColor = HEX_COLOR(0x9B9B9B);
    circleDesLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:circleDesLabel];
    
    UILabel *focusCountLabel = [[UILabel alloc] init];
    _focusCountLabel = focusCountLabel;
    focusCountLabel.text = @"0人关注";
    focusCountLabel.textColor = HEX_COLOR(0x9B9B9B);
    focusCountLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:focusCountLabel];
    
}

- (void)calculatorAllCircleCollectionViewCellFrame
{
    self.backView.width = self.contentView.width;
    self.backView.height = self.contentView.height;
    
    self.circleImageView.width = 44;
    self.circleImageView.height = self.circleImageView.width;
    self.circleImageView.x = 10;
    self.circleImageView.centerY = self.contentView.height * 0.5;
    self.circleImageView.layer.cornerRadius = 3;
    self.circleImageView.layer.masksToBounds = YES;
    
    self.nameLabel.x = self.circleImageView.right + 10;
    self.nameLabel.width = self.contentView.width - self.nameLabel.x - 75;
    self.nameLabel.height = 22;
    self.nameLabel.y = self.circleImageView.y;
    
    self.circleDesLabel.x = self.circleImageView.right + 10;
    self.circleDesLabel.width = self.contentView.width - self.circleDesLabel.x - 10;
    self.circleDesLabel.height = 20;
    self.circleDesLabel.y = self.circleImageView.bottom - self.circleDesLabel.height;
    
    [self.focusCountLabel sizeToFit];
    self.focusCountLabel.height = 17;
    self.focusCountLabel.x = self.contentView.width - self.focusCountLabel.width - 10;
    self.focusCountLabel.centerY = self.nameLabel.centerY;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorAllCircleCollectionViewCellFrame];
}
@end
