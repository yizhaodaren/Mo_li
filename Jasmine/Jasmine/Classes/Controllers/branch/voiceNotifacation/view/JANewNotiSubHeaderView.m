//
//  JANewNotiSubHeaderView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/24.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewNotiSubHeaderView.h"

@interface JANewNotiSubHeaderView ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *numberLabel;
@property (nonatomic, weak) UIImageView *arrowImageView;

@end

@implementation JANewNotiSubHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupNewNotiSubHeaderView];
    }
    return self;
}

- (void)setupNewNotiSubHeaderView
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
//    iconImageView.image = [UIImage imageNamed:@"moren_nan"];
    [self addSubview:iconImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x4a4a4a);
    nameLabel.font = JA_MEDIUM_FONT(15);
    nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:nameLabel];
    
    UILabel *numberLabel = [[UILabel alloc] init];
    _numberLabel = numberLabel;
    numberLabel.backgroundColor = HEX_COLOR(0xFF3B30);
    numberLabel.text = @" ";
    numberLabel.textColor = HEX_COLOR(0xffffff);
    numberLabel.font = JA_MEDIUM_FONT(10);
    numberLabel.hidden = YES;
    numberLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:numberLabel];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowImageView;
    arrowImageView.hidden = YES;
    [self addSubview:arrowImageView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView];
}

- (void)caculatorNewNotiSubHeaderView
{
    self.iconImageView.width = 35;
    self.iconImageView.height = self.iconImageView.width;
    self.iconImageView.x = 15;
    self.iconImageView.centerY = self.height * 0.5;
    self.iconImageView.layer.cornerRadius = self.iconImageView.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.x = self.iconImageView.right + 15;
    self.nameLabel.centerY = self.height * 0.5;
    
    self.arrowImageView.x = self.width - self.arrowImageView.width - 14;
    self.arrowImageView.centerY = self.height * 0.5;
    
    [self.numberLabel sizeToFit];
    self.numberLabel.width = self.numberLabel.width + 4;
    if (self.numberLabel.width < 16) {
        self.numberLabel.width = 16;
    }
    self.numberLabel.height = 16;
    self.numberLabel.x = JA_SCREEN_WIDTH - 15 - self.numberLabel.width;
    self.numberLabel.centerY = self.height * 0.5;
    self.numberLabel.layer.cornerRadius = self.numberLabel.height * 0.5;
    self.numberLabel.layer.masksToBounds = YES;
    
    self.arrowImageView.x = JA_SCREEN_WIDTH - 15 - self.arrowImageView.width;
    self.arrowImageView.centerY = self.height * 0.5;
    
    self.lineView.width = JA_SCREEN_WIDTH - 15;
    self.lineView.height = 1;
    self.lineView.x = 15;
    self.lineView.y = self.height - 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorNewNotiSubHeaderView];
}

- (void)setDicModel:(NSDictionary *)dicModel
{
    _dicModel = dicModel;
    
    NSString *imageStr = dicModel[@"image"];
    NSString *nameStr = dicModel[@"name"];
    
    self.iconImageView.image = [UIImage imageNamed:imageStr];
    self.nameLabel.text = nameStr;
    [self.nameLabel sizeToFit];
}

- (void)setUnReadCount:(NSInteger)unReadCount
{
    _unReadCount = unReadCount;
    
    if (unReadCount == 0) {
        self.numberLabel.hidden = YES;
        self.arrowImageView.hidden = NO;
    }else{
        self.arrowImageView.hidden = YES;
        self.numberLabel.hidden = NO;
        
        NSString *numStr = [NSString stringWithFormat:@"%ld",unReadCount];
        
        self.numberLabel.text = numStr;
        
    }
    
}
@end
