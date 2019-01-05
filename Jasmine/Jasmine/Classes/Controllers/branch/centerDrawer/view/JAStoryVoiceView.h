//
//  JAStoryVoiceView.h
//  Jasmine
//
//  Created by xujin on 2018/5/30.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPlayLoadingView.h"
#import "JAWaveView.h"

@interface JAStoryVoiceView : UIView

@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIImageView *headImageView;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) JAPlayLoadingView *playLoadingView;
@property (nonatomic, strong) JAWaveView *waveView;
@property (nonatomic, strong) UILabel *durationLabel;

@end
