
//
//  JACommonSearchPeopleCell.m
//  Jasmine
//
//  Created by xujin on 27/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JACommonSearchPeopleCell.h"

@interface JACommonSearchPeopleCell ()

@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UILabel *userNameLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation JACommonSearchPeopleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCommonTopicCell];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupCommonTopicCell
{
    self.headImageView = [[UIImageView alloc] init];
    self.headImageView.layer.cornerRadius = 17.5;
    self.headImageView.layer.masksToBounds = YES;
//    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.headImageView];
    
    self.userNameLabel = [[UILabel alloc] init];
    self.userNameLabel.text = @" ";
    self.userNameLabel.textColor = HEX_COLOR(0x4A4A4A);
    self.userNameLabel.font = JA_REGULAR_FONT(15);
    [self.contentView addSubview:self.userNameLabel];
  
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.contentView addSubview:self.lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorCommonTopicCellFrame];
}

- (void)caculatorCommonTopicCellFrame
{
    self.headImageView.width = 35;
    self.headImageView.height = 35;
    self.headImageView.x = 15;
    self.headImageView.centerY = self.contentView.height * 0.5;
    
    self.userNameLabel.height = 17;
    self.userNameLabel.x = self.headImageView.right + 10;
    self.userNameLabel.centerY = self.headImageView.centerY;
    self.userNameLabel.width = JA_SCREEN_WIDTH - self.userNameLabel.x - 15;
    
    self.lineView.x = 15;
    self.lineView.height = 1;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.y = self.contentView.height - 1;
}

- (void)setData:(JAConsumer *)data {
    _data = data;
    int h = 35;
    int w = 35;
    NSString *imageurl = [data.image ja_getFillImageStringWidth:w height:h];
    [self.headImageView ja_setImageWithURLStr:imageurl];

    self.userNameLabel.text = data.name;
    [self.userNameLabel sizeToFit];
}

@end
