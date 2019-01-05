//
//  JACircleHeadCollectionReusableView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleHeadCollectionReusableView.h"

@interface JACircleHeadCollectionReusableView ()
@property (nonatomic, weak) UIImageView *greenImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@end

@implementation JACircleHeadCollectionReusableView

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
    [self.nameLabel sizeToFit];
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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleHeadCollectionReusableViewFrame];
}
@end
