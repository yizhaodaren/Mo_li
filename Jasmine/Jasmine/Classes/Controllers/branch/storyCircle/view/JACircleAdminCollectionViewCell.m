//
//  JACircleAdminCollectionViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/27.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleAdminCollectionViewCell.h"

@interface JACircleAdminCollectionViewCell ()
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@end

@implementation JACircleAdminCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleAdminCollectionViewCellUI];
    }
    return self;
}

- (void)setUserModel:(JALightUserModel *)userModel
{
    _userModel = userModel;
    [self.iconImageView ja_setImageWithURLStr:userModel.avatar];
    self.nameLabel.text = userModel.userName;
}

- (void)setupCircleAdminCollectionViewCellUI
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.backgroundColor = HEX_COLOR(0xededed);
    [self.contentView addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x363636);
    nameLabel.font = JA_REGULAR_FONT(12);
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:nameLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self calculatorCircleAdminCollectionViewCellFrame];
}

- (void)calculatorCircleAdminCollectionViewCellFrame
{
    self.iconImageView.width = 40;
    self.iconImageView.height = 40;
    self.iconImageView.x = 15;
    self.iconImageView.y = 0;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    self.nameLabel.width = self.contentView.width;
    self.nameLabel.height = 17;
    self.nameLabel.centerX = self.iconImageView.centerX;
    self.nameLabel.y = self.iconImageView.bottom + 5;
}
@end
