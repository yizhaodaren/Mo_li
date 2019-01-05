//
//  JAPlayAnimateView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPlayAnimateView.h"
#import "JAVolumeAnimateView.h"
#import "JAPaddingLabel.h"
#import "JAPlayLoadingView.h"
#define kVolumeW 268 // 90个竖线（线宽1） 89个间隔（宽度2） 90 + 89 * 2 = 268
#define kMaskW 118 // 自身的宽度 210  两端按钮的宽度 35 57   210 - 35 - 57 = 108
#define kSelfW 210 // 自身的宽度 210

@interface JAPlayAnimateView ()

@property (nonatomic, strong) JAVolumeAnimateView *animateView_white;   // 动画view
@property (nonatomic, strong) JAVolumeAnimateView *animateView_black;   // 动画view
@property (nonatomic, strong) UIView *black_maskView;
@property (nonatomic, strong) JAPaddingLabel *timeLabel;    // 时间label

// v2.5.5
@property (nonatomic, strong) JAPlayLoadingView *playLoadingView;

@end

@implementation JAPlayAnimateView

- (instancetype)initWithColor:(UIColor *)color frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = color;
        self.width = kSelfW;
        self.height = 35;
        self.layer.cornerRadius = self.height * 0.5;
        self.layer.masksToBounds = YES;
        [self setupAnimateUI];
    }
    return self;
}


- (void)setupAnimateUI
{
    self.playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playButton setImage:[UIImage imageNamed:@"branch_record_replyPlay"] forState:UIControlStateNormal];
    [self.playButton setImage:[UIImage imageNamed:@"branch_record_replyPause"] forState:UIControlStateSelected];
    self.playButton.height = self.height;
    self.playButton.width = self.playButton.height;
    self.playButton.centerY = self.height * 0.5;
    self.playButton.backgroundColor = self.backgroundColor;
    self.playButton.userInteractionEnabled = NO;
    [self addSubview:self.playButton];
    
    self.playLoadingView = [JAPlayLoadingView playLoadingViewWithType:2];
    self.playLoadingView.centerX = self.playButton.width/2.0;
    self.playLoadingView.centerY = self.playButton.height/2.0;
    self.playLoadingView.backgroundColor = self.backgroundColor;
    [self.playButton addSubview:self.playLoadingView];
    
    self.animateView_white = [[JAVolumeAnimateView alloc] init];
    self.animateView_white.x = self.playButton.right;
    self.animateView_white.width = kVolumeW;
    self.animateView_white.height = self.height;
    self.animateView_white.drawColor = [UIColor whiteColor];
    [self insertSubview:self.animateView_white belowSubview:self.playButton];
    
    self.animateView_black = [[JAVolumeAnimateView alloc] init];
    self.animateView_black.x = self.animateView_white.x;
    self.animateView_black.width = self.animateView_white.width;
    self.animateView_black.height = self.height;
    self.animateView_black.drawColor = HEX_COLOR(0x4A4A4A);
    self.black_maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, self.height)];
    self.black_maskView.backgroundColor = [UIColor redColor];
    self.animateView_black.maskView = self.black_maskView;
    [self insertSubview:self.animateView_black belowSubview:self.playButton];
    
    self.timeLabel = [[JAPaddingLabel alloc] init];
    self.timeLabel.text = @"05:00";
    self.timeLabel.textColor = HEX_COLOR(0xffffff);
    self.timeLabel.font = JA_REGULAR_FONT(14);
    self.timeLabel.height = self.height;
    self.timeLabel.width = 57;
    self.timeLabel.x = self.width - self.timeLabel.width;
    self.timeLabel.centerY = self.playButton.centerY;
    self.timeLabel.backgroundColor = self.backgroundColor;
    self.timeLabel.edgeInsets = UIEdgeInsetsMake(0, 7, 0, 0);
    [self addSubview:self.timeLabel];
}

- (void)setTime:(NSString *)time
{
    _time = time;
    
    self.timeLabel.text = time;
}

- (void)beginVolumeAnimate:(CGFloat)process  // 开始音量的动画
{
    process = (isinf(process) || isnan(process)) ? 1.0 : process;
    
    // 最小的x
    CGFloat minX = kVolumeW + 57 - kSelfW;
    
    // 最多的x
    CGFloat maxX = self.playButton.right;
    
    self.animateView_white.x = maxX - (minX + maxX) * process;
    self.animateView_black.x = self.animateView_white.x;
    self.black_maskView.x = (minX + maxX) * process;
    self.black_maskView.width = kMaskW * process;
}
- (void)resetVolumeAnimate  // 重置音量的动画
{
    // 最多的x
    CGFloat maxX = self.playButton.right;
    
    self.animateView_white.x = maxX;
    self.animateView_black.x = self.animateView_white.x;
    self.black_maskView.x = 0;
    self.black_maskView.width = 0;
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    
    self.playButton.backgroundColor = backgroundColor;
    self.timeLabel.backgroundColor = backgroundColor;
    
    self.playLoadingView.backgroundColor = backgroundColor;
}

- (void)setPlayLoadingViewHidden:(BOOL)hidden {
    [self.playLoadingView setPlayLoadingViewHidden:hidden];
}

@end
