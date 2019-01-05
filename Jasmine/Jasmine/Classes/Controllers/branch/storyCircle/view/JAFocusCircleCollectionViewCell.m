//
//  JAFocusCircleCollectionViewCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAFocusCircleCollectionViewCell.h"

@interface JAFocusCircleCollectionViewCell ()
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UIImageView *circleImageView;
@property (nonatomic, weak) UIButton *circleCountButton;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *showAllButton;
@end

@implementation JAFocusCircleCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFocusCircleCollectionViewCellUI];
    }
    return self;
}

- (void)setCircleModel:(JACircleModel *)circleModel
{
    if (circleModel.showAll) {
        self.showAllButton.hidden = NO;
        self.showAllButton.selected = circleModel.showAll == 1 ? NO : YES;
        self.circleImageView.hidden = YES;
        self.circleCountButton.hidden = YES;
        self.nameLabel.hidden = YES;
    }else{
        self.showAllButton.hidden = YES;
        self.circleImageView.hidden = NO;
        
        self.nameLabel.hidden = NO;
        [self.circleImageView ja_setImageWithURLStr:circleModel.circleThumb];
        if (circleModel.storyNewCount > 0) {
            self.circleCountButton.hidden = NO;
            [self.circleCountButton setTitle:[NSString stringWithFormat:@"%@",circleModel.storyNewCount > 99 ? @"99+" : [NSString stringWithFormat:@"%ld",circleModel.storyNewCount]] forState:UIControlStateNormal];
        }else{
            self.circleCountButton.hidden = YES;
        }
        [self.circleCountButton sizeToFit];
        self.circleCountButton.width += 2;
        self.circleCountButton.height = 16;
        self.circleCountButton.centerX = self.circleImageView.right;
        self.circleCountButton.centerY = self.circleImageView.y + 2;
        
        self.nameLabel.text = circleModel.circleName;
        [self.nameLabel sizeToFit];
    }
}

- (void)setupFocusCircleCollectionViewCellUI
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
    
    UIButton *circleCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _circleCountButton = circleCountButton;
    [circleCountButton setBackgroundImage:[UIImage imageNamed:@"circle_redQiPao"] forState:UIControlStateNormal];
    [circleCountButton setTitle:@"0" forState:UIControlStateNormal];
    circleCountButton.titleLabel.font = JA_REGULAR_FONT(10);
    [circleCountButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    [self.contentView addSubview:circleCountButton];
    
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @" ";
    nameLabel.textColor = HEX_COLOR(0x363636);
    nameLabel.font = JA_REGULAR_FONT(14);
    [self.contentView addSubview:nameLabel];
    
    UIButton *showAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _showAllButton = showAllButton;
    showAllButton.userInteractionEnabled = NO;
    [showAllButton setTitle:@"展示更多" forState:UIControlStateNormal];
    [showAllButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
    showAllButton.titleLabel.font = JA_REGULAR_FONT(14);
    [showAllButton setImage:[UIImage imageNamed:@"circle_showAll_no"] forState:UIControlStateNormal];
    [showAllButton setImage:[UIImage imageNamed:@"circle_showAll"] forState:UIControlStateSelected];
    showAllButton.hidden = YES;
    [self.contentView addSubview:showAllButton];
}

- (void)calculatorFocusCircleCollectionViewCellFrame
{
    self.backView.width = self.contentView.width;
    self.backView.height = self.contentView.height;
    
    self.circleImageView.width = 44;
    self.circleImageView.height = self.circleImageView.width;
    self.circleImageView.x = 10;
    self.circleImageView.centerY = self.contentView.height * 0.5;
    self.circleImageView.layer.cornerRadius = 3;
    self.circleImageView.layer.masksToBounds = YES;
    
    [self.circleCountButton sizeToFit];
    self.circleCountButton.width += 2;
    self.circleCountButton.height = 16;
    self.circleCountButton.centerX = self.circleImageView.right;
    self.circleCountButton.centerY = self.circleImageView.y + 2;
    
    self.nameLabel.x = self.circleImageView.right + 5;
    self.nameLabel.width = self.contentView.width - self.nameLabel.x;
    self.nameLabel.height = 20;
    self.nameLabel.centerY = self.circleImageView.centerY;
    
    self.showAllButton.width = self.contentView.width;
    self.showAllButton.height = self.contentView.height;
    [self.showAllButton setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorFocusCircleCollectionViewCellFrame];
}
@end
