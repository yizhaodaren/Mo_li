//
//  JALeftDrawerCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JALeftDrawerCell.h"


@interface JALeftDrawerCell ()
@property (nonatomic, weak) UIImageView *icomImageView;
@property (nonatomic, weak) UIButton *signTagButton;
@property (nonatomic, weak) UILabel *subNameLabel;
@end

@implementation JALeftDrawerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLeftDrawerCell];
//        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupLeftDrawerCell
{
    UIImageView *iconV = [[UIImageView alloc] init];
    _icomImageView = iconV;
    iconV.contentMode = UIViewContentModeCenter;
    [self.contentView addSubview:iconV];
    
    UILabel *nameL = [[UILabel alloc] init];
    _nameLabel = nameL;
    nameL.textColor = HEX_COLOR(0x525252);
    nameL.font = JA_REGULAR_FONT(15);
    [self.contentView addSubview:nameL];
    
    UILabel *subNameLabel = [[UILabel alloc] init];
    _subNameLabel = subNameLabel;
    subNameLabel.textColor = HEX_COLOR(0xA7A7A7);
    subNameLabel.font = JA_MEDIUM_FONT(13);
    subNameLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:subNameLabel];
    
    UIButton *signTagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _signTagButton = signTagButton;
    [signTagButton setTitle:@"签到" forState:UIControlStateNormal];
    [signTagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    signTagButton.titleLabel.font = JA_REGULAR_FONT(8);
    signTagButton.backgroundColor = HEX_COLOR(0xF75549);
    [signTagButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateNormal];
    [signTagButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateHighlighted];
    [signTagButton setBackgroundImage:[UIImage imageWithColor:[UIColor redColor]] forState:UIControlStateSelected];
    signTagButton.hidden = YES;
    [self.contentView addSubview:signTagButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.icomImageView.width = 25;
    self.icomImageView.height = 25;
    self.icomImageView.x = 20;
    self.icomImageView.centerY = self.contentView.height * 0.5;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 21;
    self.nameLabel.centerY = self.icomImageView.centerY;
    self.nameLabel.x = self.icomImageView.right + 6;
    
    self.subNameLabel.width = 70;
    self.subNameLabel.height = 21;
    self.subNameLabel.centerY = self.icomImageView.centerY;
    self.subNameLabel.x = 185;
    
    self.signTagButton.width = 22;
    self.signTagButton.height = 10;
    self.signTagButton.x = self.nameLabel.right;
    self.signTagButton.centerY = self.nameLabel.y + 3;
    self.signTagButton.layer.cornerRadius = self.signTagButton.height * 0.5;
    self.signTagButton.layer.masksToBounds = YES;
    
}

- (void)setCellDic:(NSDictionary *)cellDic
{
    _cellDic = cellDic;
    
    self.icomImageView.image = [UIImage imageNamed:cellDic[@"image"]];
    self.nameLabel.text = cellDic[@"name"];
    if ([cellDic[@"type"] isEqualToString:@"JAPersonalTaskViewController"]) {
        
        if ([JAConfigManager shareInstance].signState == 0) {
            self.signTagButton.hidden = NO;
        }else{
            self.signTagButton.hidden = YES;
        }
    }else{
        self.signTagButton.hidden = YES;
    }
    self.subNameLabel.text = cellDic[@"subName"];
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    self.icomImageView.image = [UIImage imageNamed:imageName];
}

- (void)setNameString:(NSString *)nameString
{
    _nameString = nameString;
    
    self.nameLabel.text = nameString;
}

- (void)setTypeString:(NSString *)typeString
{
    _typeString = typeString;
    
    if ([typeString isEqualToString:@"JAPersonalTaskViewController"]) {
        
        if ([JAConfigManager shareInstance].signState == 0) {
                self.signTagButton.hidden = NO;
        }else{
                self.signTagButton.hidden = YES;
        }
    }else{
        
        self.signTagButton.hidden = YES;
    }
}

@end
