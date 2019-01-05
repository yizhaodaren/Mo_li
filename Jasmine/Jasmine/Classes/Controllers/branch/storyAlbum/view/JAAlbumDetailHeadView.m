//
//  JAAlbumDetailHeadView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAAlbumDetailHeadView.h"
#import "JAAlbumModel.h"

@interface JAAlbumDetailHeadView ()

@property (nonatomic, weak) UIView *backView;  // 图片背景
@property (nonatomic, weak) UIImageView *albumImageView;  // 专辑图片
@property (nonatomic, weak) UIImageView *alphaImageView;  // 渐变图片
@property (nonatomic, weak) UIImageView *iconImageView;   // 标签图片
@property (nonatomic, weak) UILabel *playCountLabel;      // 播放次数
@property (nonatomic, weak) UILabel *albumNameLabel;      // 专辑名字
@property (nonatomic, weak) UILabel *albumDetailLabel;    // 详情
@property (nonatomic, weak) UIView *lineView1;  // 细线
@property (nonatomic, weak) UIView *lineView;  // 线
@end

@implementation JAAlbumDetailHeadView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupAlbumDetailHeadViewUI];
    }
    return self;
}

- (void)setupAlbumDetailHeadViewUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.layer.shadowColor = HEX_COLOR_ALPHA(0x000000, 0.3).CGColor;
    backView.layer.shadowRadius = 3.f;
    backView.layer.shadowOpacity = 1.f;
    backView.layer.shadowOffset = CGSizeMake(0,0);
    backView.backgroundColor = [UIColor whiteColor];
    [self addSubview:backView];
    
    UIImageView *albumImageView = [[UIImageView alloc] init];
    _albumImageView = albumImageView;
    albumImageView.backgroundColor = HEX_COLOR(0xededed);
    [backView addSubview:albumImageView];
    
    UIImageView *alphaImageView = [[UIImageView alloc] init];
    _alphaImageView = alphaImageView;
    alphaImageView.image = [UIImage imageNamed:@"album_alphaCover"];
    [albumImageView addSubview:alphaImageView];
    
    UIImageView *iconImageView = [[UIImageView alloc] init];
    _iconImageView = iconImageView;
    iconImageView.image = [UIImage imageNamed:@"album_ear"];
    [albumImageView addSubview:iconImageView];
    
    UILabel *playCountLabel = [[UILabel alloc] init];
    _playCountLabel = playCountLabel;
    playCountLabel.text = @"0";
    playCountLabel.textColor = HEX_COLOR(0xffffff);
    playCountLabel.font = JA_REGULAR_FONT(12);
    [albumImageView addSubview:playCountLabel];
    
    UILabel *albumNameLabel = [[UILabel alloc] init];
    _albumNameLabel = albumNameLabel;
    albumNameLabel.text = @" ";
    albumNameLabel.textColor = HEX_COLOR(0x363636);
    albumNameLabel.font = JA_MEDIUM_FONT(18);
    [self addSubview:albumNameLabel];
    
    UILabel *albumDetailLabel = [[UILabel alloc] init];
    _albumDetailLabel = albumDetailLabel;
    albumDetailLabel.text = @" ";
    albumDetailLabel.textColor = HEX_COLOR(0x666666);
    albumDetailLabel.font = JA_REGULAR_FONT(14);
    albumDetailLabel.numberOfLines = 0;
    [self addSubview:albumDetailLabel];
    
    UIView *lineView1 = [[UIView alloc] init];
    _lineView1 = lineView1;
    lineView1.backgroundColor = HEX_COLOR(0xEDEDED);
    [self addSubview:lineView1];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = playButton;
    [playButton setTitle:@"播放全部" forState:UIControlStateNormal];
    [playButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    playButton.titleLabel.font = JA_MEDIUM_FONT(14);
    [playButton setImage:[UIImage imageNamed:@"album_play"] forState:UIControlStateNormal];
    playButton.backgroundColor = HEX_COLOR(0x6BD379);
    playButton.titleEdgeInsets = UIEdgeInsetsMake(0, 3, 0, -3);
    playButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
    [self addSubview:playButton];
    
    UIButton *collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _collectButton = collectButton;
    [collectButton setTitle:@"收藏" forState:UIControlStateNormal];
    [collectButton setTitle:@"已收藏" forState:UIControlStateSelected];
    [collectButton setTitle:@"已收藏" forState:UIControlStateSelected | UIControlStateHighlighted];
    [collectButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
    collectButton.titleLabel.font = JA_REGULAR_FONT(16);
    [collectButton setImage:[UIImage imageNamed:@"album_collect_un"] forState:UIControlStateNormal];
    [collectButton setImage:[UIImage imageNamed:@"album_collected"] forState:UIControlStateSelected];
    [collectButton setImage:[UIImage imageNamed:@"album_collected"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [collectButton setButtonImageTitleStyle:ButtonImageTitleStyleDefault padding:5];
    [self addSubview:collectButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton = shareButton;
    [shareButton setTitle:@"分享" forState:UIControlStateNormal];
    [shareButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
    shareButton.titleLabel.font = JA_REGULAR_FONT(16);
    [shareButton setImage:[UIImage imageNamed:@"recommend_share"] forState:UIControlStateNormal];
    [shareButton setButtonImageTitleStyle:ButtonImageTitleStyleDefault padding:5];
    [self addSubview:shareButton];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    [self addSubview:lineView];
}

- (void)setModel:(JAAlbumModel *)model
{
    _model = model;
    [self.albumImageView ja_setImageWithURLStr:model.subjectThumb];
    NSInteger playC = model.playCount.integerValue;
    if (playC >= 10000) {
        self.playCountLabel.text = [NSString stringWithFormat:@"%.1fw",playC / 10000.0];
    }else{
        self.playCountLabel.text = [NSString stringWithFormat:@"%@",model.playCount];
    }
    
    self.albumNameLabel.text = model.subjectName;
    self.albumDetailLabel.text = model.subjectDesc;
    [self.albumDetailLabel sizeToFit];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorAlbumDetailHeadViewFrame];
}

- (void)calculatorAlbumDetailHeadViewFrame
{
    self.backView.width = 113;
    self.backView.height = 90;
    self.backView.x = 15;
    self.backView.y = 20;
    
    self.albumImageView.width = self.backView.width - 4;
    self.albumImageView.height = self.backView.height - 4;
    self.albumImageView.centerX = self.backView.width * 0.5;
    self.albumImageView.centerY = self.backView.height * 0.5;
    
    self.alphaImageView.width = 109;
    self.alphaImageView.height = 40;
    self.alphaImageView.y = self.albumImageView.height - self.alphaImageView.height;
    
    self.iconImageView.width = 20;
    self.iconImageView.height = 20;
    self.iconImageView.x = 9;
    self.iconImageView.y = self.albumImageView.height - 4 - self.iconImageView.height;
    
    self.playCountLabel.width = 70;
    self.playCountLabel.height = 17;
    self.playCountLabel.centerY = self.iconImageView.centerY;
    self.playCountLabel.x = self.iconImageView.right + 5;
    
    self.albumNameLabel.x = self.backView.right + 15;
    self.albumNameLabel.y = self.backView.y + 5;
    self.albumNameLabel.width = self.width - self.albumNameLabel.x - 10;
    self.albumNameLabel.height = 25;
    
    self.albumDetailLabel.x = self.albumNameLabel.x;
    self.albumDetailLabel.y = self.albumNameLabel.bottom + 10;
    self.albumDetailLabel.width = self.width - 20 - self.albumDetailLabel.x;
    [self.albumDetailLabel sizeToFit];
    self.albumDetailLabel.width = self.width - 20 - self.albumDetailLabel.x;
    
    self.lineView1.height = 1;
    self.lineView1.width = self.width;
    self.lineView1.y = MAX(self.backView.bottom, self.albumDetailLabel.bottom) + 15;
    
    self.playButton.width = 100;
    self.playButton.height = 30;
    self.playButton.x = self.width - 20 - self.playButton.width;
    self.playButton.y = self.lineView1.bottom + 12;
    self.playButton.layer.cornerRadius = self.playButton.height * 0.5;
    self.playButton.layer.masksToBounds = YES;
    
    [self.collectButton sizeToFit];
    self.collectButton.x = 15;
    self.collectButton.centerY = self.playButton.centerY;
    
    [self.shareButton sizeToFit];
    self.shareButton.x = self.collectButton.right + 30;
    self.shareButton.centerY = self.playButton.centerY;
    
    self.lineView.x = 0;
    self.lineView.width = self.width - self.lineView.x;
    self.lineView.height = 10;
    self.lineView.y = self.height - self.lineView.height;
}
@end
