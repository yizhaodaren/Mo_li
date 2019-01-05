//
//  JASectionView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JASectionView.h"

@interface JASectionView ()
@property (nonatomic, weak) UIImageView *greenImageView;

@end
@implementation JASectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleHeadCollectionReusableViewUI];
    }
    return self;
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameLabel.text = name;
}

- (void)setupCircleHeadCollectionReusableViewUI
{
    UIImageView *greenImageView = [[UIImageView alloc] init];
    _greenImageView = greenImageView;
    greenImageView.backgroundColor = HEX_COLOR(0x6BD379);
    [self addSubview:greenImageView];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x000000);
    nameLabel.font = JA_REGULAR_FONT(15);
    [self addSubview:nameLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.hidden = YES;
    lineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self addSubview:lineView];
}

- (void)calculatorCircleHeadCollectionReusableViewFrame
{
    self.greenImageView.width = 3;
    self.greenImageView.height = 15;
    self.greenImageView.x = 15;
    self.greenImageView.centerY = self.height * 0.5;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.x = self.greenImageView.right + 10;
    self.nameLabel.centerY = self.greenImageView.centerY;
    
    self.lineView.width = self.width;
    self.lineView.height = 1;
    self.lineView.y = self.height - 1;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleHeadCollectionReusableViewFrame];
}

@end
