//
//  JACollectAlbumCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACollectAlbumCell.h"
#import "JAAlbumModel.h"

@interface JACollectAlbumCell ()

@property (nonatomic, weak) UIImageView *albumImageView;  // 专辑图片
@property (nonatomic, weak) UIImageView *alphaImageView;  // 渐变图片
@property (nonatomic, weak) UIImageView *iconImageView;   // 标签图片
@property (nonatomic, weak) UILabel *playCountLabel;      // 播放次数
@property (nonatomic, weak) UILabel *albumNameLabel;      // 专辑名字
@property (nonatomic, weak) UILabel *collectTimeLabel;    // 收藏时间
@property (nonatomic, weak) UIButton *voiceCountButton; // 专辑故事数目
@property (nonatomic, weak) UILabel *xinTieLabel;      // 新帖
@property (nonatomic, weak) UIView *lineView;

@end

@implementation JACollectAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupCollectAlbumCellUI];
    }
    return self;
}

#pragma mark - 数据
- (void)setCollectModel:(JAAlbumModel *)collectModel
{
    _collectModel = collectModel;
    [self.albumImageView ja_setImageWithURLStr:collectModel.subjectThumb];
    self.playCountLabel.text = [NSString convertCountStr:collectModel.playCount];
    self.albumNameLabel.text = collectModel.subjectName;
    self.collectTimeLabel.text = [NSString timeToString:collectModel.createTime];
    if (collectModel.storyNewCount > 0) {
        self.voiceCountButton.hidden = NO;
        self.xinTieLabel.hidden = NO;
        [self.voiceCountButton setTitle:[NSString stringWithFormat:@"%ld",collectModel.storyNewCount] forState:UIControlStateNormal];
        [self.voiceCountButton sizeToFit];
    }else{
        self.voiceCountButton.hidden = YES;
        self.xinTieLabel.hidden = YES;
    }
    
}

#pragma mark - UI
- (void)setupCollectAlbumCellUI
{
    UIImageView *albumImageView = [[UIImageView alloc] init];
    _albumImageView = albumImageView;
    albumImageView.backgroundColor = HEX_COLOR(0xededed);
    albumImageView.contentMode = UIViewContentModeScaleAspectFill;
    albumImageView.clipsToBounds = YES;
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
    
    UILabel *collectTimeLabel = [[UILabel alloc] init];
    _collectTimeLabel = collectTimeLabel;
    collectTimeLabel.text = @"收藏时间 0000.00.00";
    collectTimeLabel.textColor = HEX_COLOR(0x666666);
    collectTimeLabel.font = JA_REGULAR_FONT(12);
    [self.contentView addSubview:collectTimeLabel];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self.contentView addSubview:lineView];
    
    UIButton *voiceCountButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceCountButton = voiceCountButton;
    [voiceCountButton setBackgroundImage:[UIImage imageNamed:@"circle_redQiPao"] forState:UIControlStateNormal];
    [voiceCountButton setTitle:@"0" forState:UIControlStateNormal];
    voiceCountButton.titleLabel.font = JA_REGULAR_FONT(10);
    [voiceCountButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    [self.contentView addSubview:voiceCountButton];
    
    UILabel *xinTieLabel = [[UILabel alloc] init];
    _xinTieLabel = xinTieLabel;
    xinTieLabel.text = @"新帖";
    xinTieLabel.textColor = HEX_COLOR(0xF75549);
    xinTieLabel.font = JA_MEDIUM_FONT(12);
    [self.contentView addSubview:xinTieLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCollectAlbumCellFrame];
}

- (void)calculatorCollectAlbumCellFrame
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
    self.albumNameLabel.y = self.albumImageView.y + 10;
    self.albumNameLabel.width = self.contentView.width - self.albumNameLabel.x - 10;
    self.albumNameLabel.height = 24;
    
    self.collectTimeLabel.x = self.albumNameLabel.x;
    self.collectTimeLabel.y = self.albumNameLabel.bottom + 5;
    self.collectTimeLabel.width = self.albumNameLabel.width;
    [self.collectTimeLabel sizeToFit];
    self.collectTimeLabel.width = self.albumNameLabel.width;
    
    [self.voiceCountButton sizeToFit];
    self.voiceCountButton.width += 2;
    self.voiceCountButton.height = 16;
    self.voiceCountButton.x = self.albumNameLabel.x;
    self.voiceCountButton.y = self.albumImageView.bottom - self.voiceCountButton.height;
    
    [self.xinTieLabel sizeToFit];
    self.xinTieLabel.height = 17;
    self.xinTieLabel.x = self.voiceCountButton.right + 5;
    self.xinTieLabel.y = self.albumImageView.bottom - self.xinTieLabel.height;
    
    self.lineView.x = self.albumImageView.x;
    self.lineView.width = self.contentView.width - self.lineView.x;
    self.lineView.height = 1;
    self.lineView.y = self.contentView.height - self.lineView.height;
}
@end
