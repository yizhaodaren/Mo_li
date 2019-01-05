//
//  JAMyInviteCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAMyInviteCell.h"

@interface JAMyInviteCell ()

//@property (nonatomic, strong) UIImageView *sortImageView;
@property (nonatomic, strong) UILabel *sortLabel;

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
//@property (nonatomic, weak) UILabel *uidLabel;
@property (nonatomic, weak) UILabel *moliFLabel;

@property (nonatomic, strong) UIButton *callButton;

@property (nonatomic, weak) UIView *lineView;
@end

@implementation JAMyInviteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setup];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setup
{
    self.sortLabel = [[UILabel alloc] init];
    self.sortLabel.text = @" ";
    self.sortLabel.textColor = HEX_COLOR(0x4a4a4a);
    self.sortLabel.font = JA_MEDIUM_FONT(12);
    [self.contentView addSubview:self.sortLabel];
    
    UIImageView *iconIamgeView = [[UIImageView alloc] init];
    _iconImageView = iconIamgeView;
    iconIamgeView.image = [UIImage imageNamed:@"moren_nan"];
    iconIamgeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPerson)];
    [iconIamgeView addGestureRecognizer:tap1];
    [self.contentView addSubview:iconIamgeView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"茉莉";
    nameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    nameLabel.font = JA_REGULAR_FONT(16);
    nameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpPerson)];
    [nameLabel addGestureRecognizer:tap2];
    [self.contentView addSubview:nameLabel];
    
//    UILabel *uidLabel = [[UILabel alloc] init];
//    _uidLabel = uidLabel;
//    uidLabel.text = @"ID:0";
//    uidLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
//    uidLabel.font = JA_REGULAR_FONT(13);
//    [self.contentView addSubview:uidLabel];
    
    UILabel *moliFLabel = [[UILabel alloc] init];
    _moliFLabel = moliFLabel;
    moliFLabel.text = @"+1000朵";
    moliFLabel.textColor = HEX_COLOR(JA_BlackTitle);
    moliFLabel.font = JA_REGULAR_FONT(16);
    [self.contentView addSubview:moliFLabel];
    
    self.callButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.callButton setTitle:@"唤醒ta" forState:UIControlStateNormal];
    [self.callButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
    self.callButton.titleLabel.font = JA_REGULAR_FONT(14);
    [self.callButton addTarget:self action:@selector(clickCallButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.callButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorFrame];
}

- (void)caculatorFrame
{
    
    if (self.cellType == 0) {
        
        [self.sortLabel sizeToFit];
        self.sortLabel.centerY = self.contentView.height * 0.5;
        self.sortLabel.centerX = 20;
        
        
        self.iconImageView.height = 45;
        self.iconImageView.width = 45;
        self.iconImageView.centerY = self.height * 0.5;
        self.iconImageView.x = 44;
        self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
        self.iconImageView.clipsToBounds = YES;
        
        [self.nameLabel sizeToFit];
        self.nameLabel.height = 20;
        self.nameLabel.x = self.iconImageView.right + 14;
        self.nameLabel.centerY = self.iconImageView.centerY;
        
//        [self.uidLabel sizeToFit];
//        self.uidLabel.height = 18;
//        self.uidLabel.x = self.iconImageView.right + 14;
//        self.uidLabel.y = self.nameLabel.bottom + 5;
        
        [self.moliFLabel sizeToFit];
        self.moliFLabel.height = 20;
        self.moliFLabel.x = self.contentView.width - self.moliFLabel.width - 23;
        self.moliFLabel.centerY = self.contentView.height * 0.5;
        
        self.nameLabel.width = self.moliFLabel.x - self.nameLabel.x;
//        self.uidLabel.width = self.moliFLabel.x - self.uidLabel.x;
        
    }else{
        
        self.iconImageView.height = 45;
        self.iconImageView.width = 45;
        self.iconImageView.centerY = self.height * 0.5;
        self.iconImageView.x = 17;
        self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
        self.iconImageView.clipsToBounds = YES;
        
        [self.nameLabel sizeToFit];
        self.nameLabel.height = 20;
        self.nameLabel.x = self.iconImageView.right + 14;
        self.nameLabel.centerY = self.iconImageView.centerY;
        
//        [self.uidLabel sizeToFit];
//        self.uidLabel.height = 18;
//        self.uidLabel.x = self.iconImageView.right + 14;
//        self.uidLabel.y = self.nameLabel.bottom + 5;
        
        self.callButton.width = 70;
        self.callButton.height = 29;
        self.callButton.centerY = self.contentView.height * 0.5;
        self.callButton.x = self.contentView.width - self.callButton.width - 20;
        self.callButton.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
        self.callButton.layer.borderWidth = 1;
        self.callButton.layer.cornerRadius = self.callButton.height * 0.5;
        self.callButton.layer.masksToBounds = YES;
        
        self.nameLabel.width = self.callButton.x - self.nameLabel.x;
//        self.uidLabel.width = self.callButton.x - self.uidLabel.x;
    }
    
    
    
    self.lineView.x = self.nameLabel.x;
    self.lineView.y = self.contentView.height - 1;
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    
}

- (void)setCellType:(NSInteger)cellType
{
    _cellType = cellType;
    if (cellType == 0) {
        self.sortLabel.hidden = NO;
        self.moliFLabel.hidden = NO;
        self.callButton.hidden = YES;
    }else{
        self.sortLabel.hidden = YES;
        self.moliFLabel.hidden = YES;
        self.callButton.hidden = NO;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)setModel:(JAMyInviteModel *)model
{
    _model = model;
    
    int h = 45;
    int w = h;
    NSString *url = [model.userImage ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:url];
    
    self.nameLabel.text = model.userName;
    
    self.moliFLabel.text = [NSString stringWithFormat:@"+%ld朵",[model.inviteUserFlower integerValue]];
    if (model.ranking > 10000) {
        NSString *str = [NSString stringWithFormat:@"%.1fw",(model.ranking + 1) / 10000.0];
        self.sortLabel.text = str;
    }else{
        NSString *str = [NSString stringWithFormat:@"%ld",model.ranking + 1];
        self.sortLabel.text = str;
    }
}

- (void)setCallFriendModel:(JACallInviteFriendModel *)callFriendModel
{
    _callFriendModel = callFriendModel;
    
    int h = 45;
    int w = h;
    NSString *url = [callFriendModel.userImage ja_getFitImageStringWidth:w height:h];
    [self.iconImageView ja_setImageWithURLStr:url];
    self.nameLabel.text = callFriendModel.userName;
}

#pragma mark - 点击唤醒
- (void)clickCallButton:(UIButton *)btn
{
    if (self.callPersonBlock) {
        self.callPersonBlock(self);
    }
}

// 跳转个人中心
- (void)jumpPerson
{
    if (self.jumpPersonBlock) {
        self.jumpPersonBlock(self);
    }
}


/** 直接传入精度丢失有问题的Double类型*/
- (NSString *)decimalNumberWithDouble:(double)conversionValue{
    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
    return [decNumber stringValue];
}
@end
