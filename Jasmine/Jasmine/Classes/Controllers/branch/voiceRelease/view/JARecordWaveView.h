//
//  JARecordWaveView.h
//  Jasmine
//
//  Created by xujin on 04/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "WaveFormView.h"
#import "JASliderThumbView.h"

@interface JARecordWaveView : WaveFormView

@property (nonatomic, strong) JASliderThumbView *sliderIV;

- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue;
- (void)setSliderOffsetX:(CGFloat)percent;

@end
