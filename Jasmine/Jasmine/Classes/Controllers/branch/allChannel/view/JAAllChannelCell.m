//
//  JAAllChannelCell.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAllChannelCell.h"

@interface JAAllChannelCell ()

@property (nonatomic, weak) UILabel *nameLabel;

@end
@implementation JAAllChannelCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChannelCell];
        
        self.contentView.backgroundColor = HEX_COLOR(0xF4F4F4);
    }
    return self;
}

- (void)setupChannelCell
{
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.textColor = HEX_COLOR(JA_BlackTitle);
    nameLabel.font = JA_REGULAR_FONT(15);
    nameLabel.text = @" ";
    [self.contentView addSubview:nameLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.layer.cornerRadius = 5;
    self.contentView.clipsToBounds = YES;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.center = CGPointMake(self.contentView.width * 0.5, self.contentView.height * 0.5);
}

- (void)setNameString:(NSString *)nameString
{
    _nameString = nameString;
    
    self.nameLabel.text = nameString;
}
@end
