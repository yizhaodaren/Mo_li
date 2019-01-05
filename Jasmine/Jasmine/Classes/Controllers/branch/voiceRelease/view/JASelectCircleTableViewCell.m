//
//  JASelectCircleTableViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/5/29.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JASelectCircleTableViewCell.h"

@interface JASelectCircleTableViewCell ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *lineView;


@end

@implementation JASelectCircleTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIImageView *iconImageView = [UIImageView new];
        iconImageView.layer.cornerRadius = 4.0;
        iconImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = JA_MEDIUM_FONT(14);
        titleLabel.textColor = HEX_COLOR(JA_Title);
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 59, JA_SCREEN_WIDTH-15, 1)];
        lineView.backgroundColor = HEX_COLOR(JA_Line);
        [self.contentView addSubview:lineView];
        self.lineView = lineView;
        
        UIButton *selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        selectBtn.backgroundColor = HEX_COLOR(0xF9F9F9);
        selectBtn.layer.cornerRadius = 10;
//        selectBtn.clipsToBounds = YES;
//        selectBtn.layer.borderWidth = 1;
//        selectBtn.layer.borderColor = HEX_COLOR(0xEDEDED).CGColor;
        [selectBtn setImage:[UIImage imageNamed:@"anonymous_nor"] forState:UIControlStateNormal];
        [selectBtn setImage:[UIImage imageNamed:@"anonymous_sel"] forState:UIControlStateSelected];
        [self.contentView addSubview:selectBtn];
        self.selectBtn = selectBtn;

    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImageView.width = self.iconImageView.height = 40;
    self.iconImageView.centerY = self.height/2.0;
    self.iconImageView.left = 15;
    
    self.titleLabel.width = self.width-self.iconImageView.right-10;
    self.titleLabel.height = self.height;
    self.titleLabel.left = self.iconImageView.right+10;
    
    self.selectBtn.width = 20;
    self.selectBtn.height = 20;
    self.selectBtn.centerY = self.height/2.0;
    self.selectBtn.x = JA_SCREEN_WIDTH - 20 - self.selectBtn.width;
}

- (void)setData:(JACircleModel *)data {
    _data = data;
    if (data) {
        int h = 40;
        int w = h;
        NSString *url = [data.circleThumb ja_getFitImageStringWidth:w height:h];
        [self.iconImageView ja_setImageWithURLStr:url];
        self.titleLabel.text = data.circleName;
    }
}

- (void)hiddenLineView:(BOOL)hidden {
    self.lineView.hidden = hidden;
}

@end
