//
//  JAPlayBottomView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/2.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPlayBottomView.h"
#import "JASlider.h"

@interface JAPlayBottomView ()

@end

@implementation JAPlayBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPlayBottomViewUI];
    }
    return self;
}


#pragma mark - UI
- (void)setupPlayBottomViewUI
{
    UILabel *beginTimeLabel = [[UILabel alloc] init];
    _beginTimeLabel = beginTimeLabel;
    beginTimeLabel.text = @"00:00";
    beginTimeLabel.textColor = HEX_COLOR(0x4A4A4A);
    beginTimeLabel.font = JA_REGULAR_FONT(11);
    [self addSubview:beginTimeLabel];
    
    JASlider *slider = [[JASlider alloc] init];
    _slider = slider;
    slider.continuous = NO;
    slider.minimumTrackTintColor = HEX_COLOR(0x6BD379);
    slider.maximumTrackTintColor = HEX_COLOR(0xEDEDED);
    [slider setThumbImage:[UIImage imageNamed:@"playList_slide"] forState:UIControlStateNormal];
    [self addSubview:slider];
    
    UILabel *totalTimeLabel = [[UILabel alloc] init];
    _totalTimeLabel = totalTimeLabel;
    totalTimeLabel.text = @"00:00";
    totalTimeLabel.textColor = HEX_COLOR(0x4A4A4A);
    totalTimeLabel.font = JA_REGULAR_FONT(11);
    [self addSubview:totalTimeLabel];
    
    UIButton *playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _playButton = playButton;
    [playButton setImage:[UIImage imageNamed:@"playList_play"] forState:UIControlStateNormal];
    [playButton setImage:[UIImage imageNamed:@"playList_pause"] forState:UIControlStateSelected];
    [self addSubview:playButton];
    
    UIButton *frontButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _frontButton = frontButton;
//    frontButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [frontButton setImage:[UIImage imageNamed:@"playList_front"] forState:UIControlStateNormal];
    [self addSubview:frontButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _nextButton = nextButton;
//    nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [nextButton setImage:[UIImage imageNamed:@"playList_next"] forState:UIControlStateNormal];
    [self addSubview:nextButton];
    
    UIButton *orderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _orderButton = orderButton;
    [orderButton setImage:[UIImage imageNamed:@"playList_order_zheng"] forState:UIControlStateNormal];
    [orderButton setImage:[UIImage imageNamed:@"playList_order_dao"] forState:UIControlStateSelected];
    [self addSubview:orderButton];
    
    UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _infoButton = infoButton;
    [infoButton setImage:[UIImage imageNamed:@"circle_info_black"] forState:UIControlStateNormal];
    [self addSubview:infoButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorPlayBottomViewFrame];
}

- (void)calculatorPlayBottomViewFrame
{
    self.beginTimeLabel.width = 33;
    self.beginTimeLabel.height = 16;
    self.beginTimeLabel.x = 14;
    self.beginTimeLabel.y = 20;
    
    self.totalTimeLabel.width = 33;
    self.totalTimeLabel.height = 16;
    self.totalTimeLabel.x = self.width - 14 - self.totalTimeLabel.width;
    self.totalTimeLabel.y = self.beginTimeLabel.y;
    
    self.slider.x = self.beginTimeLabel.right + 10;
    self.slider.height = 16;
    self.slider.width = self.totalTimeLabel.x - self.slider.x - 10;
    self.slider.centerY = self.beginTimeLabel.centerY;
    
    self.playButton.width = 60;
    self.playButton.height = self.playButton.width;
    self.playButton.centerX = self.width * 0.5;
    self.playButton.y = self.slider.bottom + 24;
    
    self.frontButton.width = WIDTH_ADAPTER(50);
    self.frontButton.height = self.playButton.height;
    self.frontButton.centerY = self.playButton.centerY;
    self.frontButton.x = self.playButton.x - WIDTH_ADAPTER(15) - self.frontButton.width;
    
    self.nextButton.width = WIDTH_ADAPTER(50);
    self.nextButton.height = self.playButton.height;
    self.nextButton.centerY = self.playButton.centerY;
    self.nextButton.x = self.playButton.right + WIDTH_ADAPTER(15);
    
    self.orderButton.width = 30;
    self.orderButton.height = 30;
    self.orderButton.centerY = self.playButton.centerY;
    self.orderButton.x = WIDTH_ADAPTER(20);
    
    self.infoButton.width = 30;
    self.infoButton.height = 30;
    self.infoButton.centerY = self.playButton.centerY;
    self.infoButton.x = self.width - WIDTH_ADAPTER(20) - self.infoButton.width;
}

@end
