//
//  JAHomeLeftView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/27.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAHomeLeftView.h"

@interface JAHomeLeftView ()
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UIView *redView;
@end

@implementation JAHomeLeftView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViewUI];
    }
    return self;
}

- (void)setupViewUI
{
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    [self addSubview:iconImageView];
    iconImageView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
    iconImageView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
    
    UIView *redView = [[UIView alloc] init];
    _redView = redView;
    redView.backgroundColor = HEX_COLOR(0xFE3824);
    redView.userInteractionEnabled = NO;
    redView.hidden = YES;
    [self addSubview:redView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.iconImageView.width = self.height;
    self.iconImageView.height = self.height;
    self.iconImageView.y = self.height - self.iconImageView.height;
    self.iconImageView.layer.cornerRadius = self.iconImageView.width * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    
    
    self.redView.width = 6;
    self.redView.height = 6;
    self.redView.x = self.width - self.redView.width * 0.5 - 2;
    self.redView.layer.cornerRadius = self.redView.width * 0.5;
    self.redView.layer.masksToBounds = YES;
//    self.redView.layer.borderColor = HEX_COLOR(0xffffff).CGColor;
//    self.redView.layer.borderWidth = 1;
    
}

- (void)setImageUrl:(NSString *)imageUrl
{
    _imageUrl = imageUrl;
    
    [self.iconImageView ja_setImageWithURLStr:imageUrl];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.redView.hidden = !selected;
    
}
@end
