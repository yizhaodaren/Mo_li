//
//  JAStoryAlbumCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAStoryAlbumCell.h"

@interface JAStoryAlbumCell ()
@property (nonatomic, weak) UIImageView *albumImageView;  // 专辑图片
@property (nonatomic, weak) UIImageView *alphaImageView;  // 渐变图片
@property (nonatomic, weak) UIImageView *iconImageView;   // 标签图片
@property (nonatomic, weak) UILabel *playCountLabel;      // 播放次数
@property (nonatomic, weak) UILabel *albumNameLabel;      // 专辑名字
@property (nonatomic, weak) UILabel *albumDetailLabel;    // 详情
@property (nonatomic, weak) UILabel *albumStoryCountLabel;    // 专辑故事数目

@property (nonatomic, weak) UIView *lineView;  // 线
@end

@implementation JAStoryAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupStoryAlbumCellUI];
    }
    return self;
}

- (void)setAlbumModel:(JAAlbumModel *)albumModel
{
    _albumModel = albumModel;
    [self.albumImageView ja_setImageWithURLStr:albumModel.subjectThumb];
    self.playCountLabel.text = [NSString convertCountStr:albumModel.playCount];
    self.albumNameLabel.text = albumModel.subjectName;
    self.albumDetailLabel.text = albumModel.subjectDesc;
    self.albumStoryCountLabel.text = [NSString stringWithFormat:@"已收录%@位茉友故事",albumModel.storyCount];
}

- (void)setupStoryAlbumCellUI
{
    UIImageView *albumImageView = [[UIImageView alloc] init];
    _albumImageView = albumImageView;
    albumImageView.backgroundColor = HEX_COLOR(0xededed);
    albumImageView.contentMode = UIViewContentModeScaleAspectFill;
    albumImageView.clipsToBounds = YES;
    albumImageView.layer.borderColor = HEX_COLOR(JA_Line).CGColor;
    albumImageView.layer.borderWidth = JA_SCREEN_ONE_PIEXL;
    [self.contentView addSubview:albumImageView];
    
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
    albumNameLabel.text = @"专辑名称";
    albumNameLabel.textColor = HEX_COLOR(0x363636);
    albumNameLabel.font = JA_REGULAR_FONT(17);
    [self.contentView addSubview:albumNameLabel];
    
    UILabel *albumDetailLabel = [[UILabel alloc] init];
    _albumDetailLabel = albumDetailLabel;
    albumDetailLabel.text = @"结婚俩年就分手，我们踩了婚姻中小乔是个大混蛋";
    albumDetailLabel.textColor = HEX_COLOR(0x666666);
    albumDetailLabel.font = JA_REGULAR_FONT(13);
    albumDetailLabel.numberOfLines = 2;
    [self.contentView addSubview:albumDetailLabel];
    
    UILabel *albumStoryCountLabel = [[UILabel alloc] init];
    _albumStoryCountLabel = albumStoryCountLabel;
    albumStoryCountLabel.text = @"已收录0位茉友故事";
    albumStoryCountLabel.textColor = HEX_COLOR(0x363636);
    albumStoryCountLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:albumStoryCountLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorStoryAlbumCellFrame];
}

- (void)calculatorStoryAlbumCellFrame
{
    self.albumImageView.width = 113;
    self.albumImageView.height = 90;
    self.albumImageView.x = 14;
    self.albumImageView.centerY = self.contentView.height * 0.5;
    
    self.alphaImageView.width = 111;
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
    
    self.albumNameLabel.x = self.albumImageView.right + 12;
    self.albumNameLabel.y = self.albumImageView.y;
    self.albumNameLabel.width = self.contentView.width - self.albumNameLabel.x - 10;
    self.albumNameLabel.height = 24;
    
    self.albumDetailLabel.x = self.albumNameLabel.x;
    self.albumDetailLabel.y = self.albumNameLabel.bottom + 5;
    self.albumDetailLabel.width = self.albumNameLabel.width;
    [self.albumDetailLabel sizeToFit];
    self.albumDetailLabel.width = self.albumNameLabel.width;
    
    self.albumStoryCountLabel.x = self.albumNameLabel.x;
    self.albumStoryCountLabel.width = self.albumNameLabel.width;
    self.albumStoryCountLabel.height = 17;
    self.albumStoryCountLabel.y = self.albumImageView.bottom - self.albumStoryCountLabel.height;
    
    self.lineView.x = self.albumImageView.x;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - self.lineView.height;
}
@end
