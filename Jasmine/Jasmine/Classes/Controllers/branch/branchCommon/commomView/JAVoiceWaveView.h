//
//  JAVocieWaveView.h
//  Jasmine
//
//  Created by xujin on 29/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//


#import "WaveFormView.h"
#import "JASliderThumbView.h"

@interface JAVoiceWaveView : WaveFormView

@property (nonatomic, strong) JASliderThumbView *sliderIV;

- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue;
- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue cutIndex:(NSUInteger)cutIndex;
- (void)setSliderOffsetX:(CGFloat)percent;

@end
