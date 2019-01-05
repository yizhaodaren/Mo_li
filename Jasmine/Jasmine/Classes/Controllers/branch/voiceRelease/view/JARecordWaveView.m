//
//  JARecordWaveView.m
//  Jasmine
//
//  Created by xujin on 04/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JARecordWaveView.h"

@interface JARecordWaveView ()

@property (nonatomic, weak) NSMutableArray *peakLevelQueue;

@end

@implementation JARecordWaveView

- (instancetype)init
{
    self = [super init];
    if (self) {
       
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.sliderIV = [JASliderThumbView new];
        self.sliderIV.frame = CGRectMake(0, 0, 6, frame.size.height);
        [self addSubview:self.sliderIV];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    if ([_peakLevelQueue count] > 0) {
        //没有剪辑
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        NSUInteger count = _peakLevelQueue.count;
        
        // 绘制 音量柱状图
        CGFloat maxHeight = self.height;
        CGFloat volumeBarWidth = 3;
        CGFloat volumeBarXOffset = 1;
        CGFloat volumeBarX = 3;
        
        //设置线的宽度
        CGContextSetLineWidth(context, volumeBarWidth);
        
        // 设置线的颜色
        [mMaskColor set];
        for (int i = 0; i < count; i++)
        {
            CGFloat volume = [_peakLevelQueue[i] floatValue];
            volume = floor(volume*100) / 100;
            if (volume < 0.1) {
                volume = 0.1;
            }
            CGFloat height = maxHeight * volume;
            CGFloat bottom = self.frame.size.height;
            CGContextMoveToPoint(context, volumeBarX, bottom - height);
            CGContextAddLineToPoint(context, volumeBarX, bottom);
            volumeBarX += volumeBarWidth + volumeBarXOffset;
        }
        CGContextDrawPath(context, kCGPathStroke);
    }
}

- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue
{
    _peakLevelQueue = peakLevelQueue;
    [self setNeedsDisplay];
}

- (void)setSliderOffsetX:(CGFloat)percent {
    if (percent<0.0) {
        percent = 0.0;
    }
    if (percent>=1.0) {
        percent = 1.0;
    }
    if (self.sliderIV.x <= self.width) {
        self.sliderIV.x = percent * self.width-4;
    } else {
        self.sliderIV.x = self.width-4;
    }
}

@end

