//
//  JALabelCollectionViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JALabelCollectionViewCell.h"

@interface JALabelCollectionViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView *maskImageView;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation JALabelCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.contentView.backgroundColor = [UIColor redColor];
        
        UIImageView *iconImageView = [UIImageView new];
        [self.contentView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
        UIImageView *maskImageView = [UIImageView new];
        [self.contentView addSubview:maskImageView];
        self.maskImageView = maskImageView;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = JA_REGULAR_FONT(12);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.layer.cornerRadius = 10;
        titleLabel.layer.masksToBounds = YES;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImageView.width = self.width;
    self.iconImageView.height = self.width;
    self.iconImageView.layer.cornerRadius =  self.width/2.0;
    self.iconImageView.layer.masksToBounds = YES;
    
    self.maskImageView.width = self.iconImageView.width;
    self.maskImageView.height = self.iconImageView.height;
    
    self.titleLabel.width = self.iconImageView.width;
    self.titleLabel.height = 20;
    self.titleLabel.y = self.maskImageView.bottom+WIDTH_ADAPTER(10);
}

- (void)selectItem:(BOOL)isSelected {
    if (isSelected) {
        self.maskImageView.image = [UIImage imageNamed:@"recommend_label_sel"];
        self.titleLabel.backgroundColor = HEX_COLOR(JA_Green);
        self.titleLabel.textColor = HEX_COLOR(0xffffff);
    } else {
            self.titleLabel.backgroundColor = HEX_COLOR(0xEDECEC);
        self.maskImageView.image = [UIImage imageNamed:@"recommend_label_nor"];
        self.titleLabel.textColor = HEX_COLOR(JA_BlackTitle);
    }
}

- (void)setData:(JALabelSelectModel *)data {
    _data = data;
    if (data) {
        if (data.labelThumb.length) {
            int h = self.width;
            int w = h;
            NSString *url = [data.labelThumb ja_getFitImageStringWidth:w height:h];
            [self.iconImageView ja_setImageWithURLStr:url];
        } else {
            self.iconImageView.image = nil;
        }
        
        self.titleLabel.text = data.labelName;
        
        [self selectItem:data.isSelected];
    }
}

@end
