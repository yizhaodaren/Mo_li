//
//  JANewVoiceWaveView.h
//  Jasmine
//
//  Created by xujin on 13/12/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "WaveFormView.h"
#import "JASliderThumbView.h"

@interface JANewVoiceWaveView : WaveFormView

@property (nonatomic, strong) UIImageView *sliderIV;
//@property (nonatomic, strong) JASliderThumbView *sliderIV;
@property (nonatomic, strong) UIImageView *bgImageView;

- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue;
- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue cutIndex:(NSUInteger)cutIndex;
- (void)setSliderOffsetX:(CGFloat)percent;
- (void)changeBGImage:(NSString *)imageName;

@end
