//
//  JAPlayListCell.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/2.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPlayListCell.h"
#import "JANewPlayTool.h"
#import <UIImage+GIF.h>

@interface JAPlayListCell ()
@property (nonatomic, weak) UIButton *storyNameButton;
@property (nonatomic, weak) UILabel *storyDesLabel;
@property (nonatomic, weak) UILabel *storyTimeLabel;
@property (nonatomic, weak) UIImageView *animateImageView;
@property (nonatomic, weak) UIView *lineView;
@end

@implementation JAPlayListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupPlayListCellUI];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.storyNameButton.selected = YES;
        self.storyNameButton.titleLabel.font = JA_MEDIUM_FONT(16);
        self.animateImageView.hidden = NO;
        if ([JANewPlayTool shareNewPlayTool].playType == 0 || [JANewPlayTool shareNewPlayTool].playType == 2) {
            self.animateImageView.image = [UIImage imageNamed:@"music_list_wave_quiet"];
        }else{
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"music_list_wave" ofType:@"gif"];
            NSData *imageData = [NSData dataWithContentsOfFile:filePath];
            self.animateImageView.image = [UIImage sd_animatedGIFWithData:imageData];
        }
        
        self.storyTimeLabel.hidden = YES;
    }else{
        self.storyNameButton.selected = NO;
        self.storyNameButton.titleLabel.font = JA_REGULAR_FONT(16);
        self.animateImageView.hidden = YES;
        self.storyTimeLabel.hidden = NO;
    }
}

- (void)setStoryModel:(JANewVoiceModel *)storyModel
{
    _storyModel = storyModel;
    [self.storyNameButton setTitle:storyModel.content forState:UIControlStateNormal];
    self.storyDesLabel.text = storyModel.user.userName;
    self.storyTimeLabel.text = [NSString getStoryVoiceShowTime:storyModel.time];
}


#pragma mark - UI
- (void)setupPlayListCellUI
{
    UIButton *storyNameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _storyNameButton = storyNameButton;
    storyNameButton.userInteractionEnabled = NO;
    storyNameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [storyNameButton setTitleColor:HEX_COLOR(0xFFFFFF) forState:UIControlStateNormal];
    [storyNameButton setTitleColor:HEX_COLOR(0x6BD379) forState:UIControlStateSelected];
    storyNameButton.titleLabel.font = JA_REGULAR_FONT(16);
    [self.contentView addSubview:storyNameButton];
    
    UILabel *storyDesLabel = [[UILabel alloc] init];
    _storyDesLabel = storyDesLabel;
    storyDesLabel.text = @" ";
    storyDesLabel.textColor = HEX_COLOR(0xC6C6C6);
    storyDesLabel.font = JA_REGULAR_FONT(13);
    [self.contentView addSubview:storyDesLabel];
    
    UILabel *storyTimeLabel = [[UILabel alloc] init];
    _storyTimeLabel = storyTimeLabel;
    storyTimeLabel.text = @"00:00";
    storyTimeLabel.textColor = HEX_COLOR(0xC6C6C6);
    storyTimeLabel.font = JA_REGULAR_FONT(12);
    storyTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:storyTimeLabel];
    
    UIImageView *animateImageView = [[UIImageView alloc] init];
    _animateImageView = animateImageView;
    animateImageView.hidden = YES;
    animateImageView.backgroundColor = [UIColor clearColor];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"music_list_wave" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    animateImageView.image = [UIImage sd_animatedGIFWithData:imageData];
    [self.contentView addSubview:animateImageView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR_ALPHA(0xffffff, 0.2);
    [self.contentView addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorPlayListCellFrame];
}

- (void)calculatorPlayListCellFrame
{
    self.storyNameButton.x = 15;
    self.storyNameButton.y = 6;
    self.storyNameButton.width = self.contentView.width - 70;
    self.storyNameButton.height = 22;
    
    self.storyDesLabel.x = self.storyNameButton.x;
    self.storyDesLabel.y = self.storyNameButton.bottom + 4;
    self.storyDesLabel.width = self.storyNameButton.width;
    self.storyDesLabel.height = 18;
    
    self.storyTimeLabel.width = 35;
    self.storyTimeLabel.height = 18;
    self.storyTimeLabel.centerY = self.contentView.height * 0.5;
    self.storyTimeLabel.x = self.contentView.width - 15 - self.storyTimeLabel.width;
    
    self.animateImageView.width = 14;
    self.animateImageView.height = 16;
    self.animateImageView.centerX = self.storyTimeLabel.centerX;
    self.animateImageView.centerY = self.storyTimeLabel.centerY;
    
    self.lineView.width = self.contentView.width - 15;
    self.lineView.height = 1;
    self.lineView.x = 15;
    self.lineView.y = self.contentView.height - self.lineView.height;
}

@end
