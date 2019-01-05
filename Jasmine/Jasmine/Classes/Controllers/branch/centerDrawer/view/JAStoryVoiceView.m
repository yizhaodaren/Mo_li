//
//  JAStoryVoiceView.m
//  Jasmine
//
//  Created by xujin on 2018/5/30.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryVoiceView.h"

@implementation JAStoryVoiceView

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIView *bgView = [UIView new];
//        bgView.backgroundColor = HEX_COLOR(0xF1F2F4);
        bgView.backgroundColor = HEX_COLOR(0xF5f5f5);
        bgView.layer.cornerRadius = 3.0;
        bgView.layer.masksToBounds = YES;
        bgView.clipsToBounds = YES;
        [self addSubview:bgView];
        self.bgView = bgView;
        
        UIImageView *headImageView = [UIImageView new];
        headImageView.userInteractionEnabled = YES;
        [bgView addSubview:headImageView];
        self.headImageView = headImageView;
        
        UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
        playButton.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
        [playButton setImage:[UIImage imageNamed:@"recommend_play"] forState:UIControlStateNormal];
        [playButton setImage:[UIImage imageNamed:@"recommend_play"] forState:UIControlStateHighlighted];
        [playButton setImage:[UIImage imageNamed:@"recommend_pause"] forState:UIControlStateSelected];
        [playButton setImage:[UIImage imageNamed:@"recommend_pause"] forState:UIControlStateSelected|UIControlStateHighlighted];
        [headImageView addSubview:playButton];
        playButton.userInteractionEnabled = NO;
        self.playButton = playButton;
        
        self.playLoadingView = [JAPlayLoadingView playLoadingViewWithType:0];
        [headImageView addSubview:self.playLoadingView];
        self.playLoadingView.stateChangeBlock = ^(BOOL hidden) {
            if (hidden) {
                [playButton setImage:[UIImage imageNamed:@"recommend_play"] forState:UIControlStateNormal];
                [playButton setImage:[UIImage imageNamed:@"recommend_play"] forState:UIControlStateHighlighted];
                [playButton setImage:[UIImage imageNamed:@"recommend_pause"] forState:UIControlStateSelected];
                [playButton setImage:[UIImage imageNamed:@"recommend_pause"] forState:UIControlStateSelected|UIControlStateHighlighted];
            } else {
                [playButton setImage:nil forState:UIControlStateNormal];
                [playButton setImage:nil forState:UIControlStateHighlighted];
                [playButton setImage:nil forState:UIControlStateSelected];
                [playButton setImage:nil forState:UIControlStateSelected|UIControlStateHighlighted];
            }
        };
        self.waveView = [[JAWaveView alloc] init];
        self.waveView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.waveView]; // 防止圆角被切，父视图放在self上而不是bgView
        
        UILabel *durationLabel = [UILabel new];
        durationLabel.textColor = HEX_COLOR(0x4A4A4A);
        durationLabel.font = JA_REGULAR_FONT(14);
        durationLabel.backgroundColor = [UIColor clearColor];
        [bgView addSubview:durationLabel];
        self.durationLabel = durationLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bgView.width = self.width;
    self.bgView.height = self.height;
    
    self.headImageView.width = self.headImageView.height = self.height;
    
    self.playButton.width = self.headImageView.width;
    self.playButton.height = self.headImageView.width;
    self.playButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.playButton.centerX = self.headImageView.width/2.0;
    self.playButton.centerY = self.headImageView.height/2.0;
    
    self.playLoadingView.centerX = self.playButton.centerX;
    self.playLoadingView.centerY = self.playButton.centerY;
    
    self.durationLabel.width = 58;
    self.durationLabel.height = 20;
    self.durationLabel.centerY = self.height/2.0;
    self.durationLabel.right = self.width;
    
    self.waveView.x = self.headImageView.right + 15;
    self.waveView.width = self.durationLabel.x - self.waveView.x - 15;
    self.waveView.height = self.bgView.height;
}

@end
