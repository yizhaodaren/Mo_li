//
//  JAVocieWaveView.m
//  Jasmine
//
//  Created by xujin on 29/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceWaveView.h"
#import "JASliderThumbView.h"

@interface JAVoiceWaveView ()
{
    NSUInteger _cutIndex;
}
@property (nonatomic, weak) NSMutableArray *peakLevelQueue;

@end

@implementation JAVoiceWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.sliderIV = [JASliderThumbView new];
        self.sliderIV.drawColor = HEX_COLOR(0x00A7F3);
        self.sliderIV.frame = CGRectMake(0, 0, 6, frame.size.height);
        [self addSubview:self.sliderIV];
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    if ([_peakLevelQueue count] > 0) {
        
        if (_cutIndex > 0) {
            NSRange redRange = NSMakeRange(0, _cutIndex);
            
            NSRange grayRange = NSMakeRange(_cutIndex,[_peakLevelQueue count]- _cutIndex);
            
            NSIndexSet *redPointsIndex = [NSIndexSet indexSetWithIndexesInRange:redRange];
            
            NSIndexSet *grayPointsIndex = [NSIndexSet indexSetWithIndexesInRange:grayRange];
            
            NSArray *redPoints = [_peakLevelQueue objectsAtIndexes:redPointsIndex];
            
            NSArray *grayPoints = [_peakLevelQueue objectsAtIndexes:grayPointsIndex];
            
            //绿色部分
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            // 绘制 音量柱状图
            CGFloat maxHeight = self.height;
            CGFloat volumeBarWidth = 3;
            CGFloat volumeBarXOffset = 1;
            CGFloat volumeBarX = 3;
            
            //设置线的宽度
            CGContextSetLineWidth(context, volumeBarWidth);
            // 设置线的颜色
            [mMaskColor set];
            
            for (int i = 0; i < redPoints.count; i++)
            {
                CGFloat volume = [redPoints[i] floatValue];
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
            
            // 灰色
            // 设置线的颜色
            [mDarkgrayColor set];
            
            for (int i = 0; i < grayPoints.count; i++)
            {
                CGFloat volume = [grayPoints[i] floatValue];
                volume = floor(volume*100) / 100;
                if (volume < 0.1) {
                    if (volume<0) {
                        volume = 0.0;
                    } else {
                        volume = 0.1;
                    }
                }
                if (volume > 0.0) {
                    CGFloat height = maxHeight * volume;
                    CGFloat bottom = self.frame.size.height;
                    CGContextMoveToPoint(context, volumeBarX, bottom - height);
                    CGContextAddLineToPoint(context, volumeBarX, bottom);
                    volumeBarX += volumeBarWidth + volumeBarXOffset;
                } else {
                }
            }
            
            CGContextDrawPath(context, kCGPathStroke);
        }
        else
        {
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
            [mDarkgrayColor set];
            for (int i = 0; i < count; i++)
            {
                CGFloat volume = [_peakLevelQueue[i] floatValue];
                volume = floor(volume*100) / 100;
                if (volume < 0.1) {
                    if (volume<0) {
                        volume = 0.0;
                    } else {
                        volume = 0.1;
                    }
                }
                if (volume > 0.0) {
                    CGFloat height = maxHeight * volume;
                    CGFloat bottom = self.frame.size.height;
                    CGContextMoveToPoint(context, volumeBarX, bottom - height);
                    CGContextAddLineToPoint(context, volumeBarX, bottom);
                    volumeBarX += volumeBarWidth + volumeBarXOffset;
                }
            }
            CGContextDrawPath(context, kCGPathStroke);
        }
    }
}

- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue
{
    [self setPeakLevelQueue:peakLevelQueue cutIndex:0];
}

- (void)setPeakLevelQueue:(NSMutableArray *)peakLevelQueue cutIndex:(NSUInteger)cutIndex
{
    _cutIndex = cutIndex;
    _peakLevelQueue = peakLevelQueue;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)setSliderOffsetX:(CGFloat)percent {
//    if (percent<0.0) {
//        percent = 0.0;
//    }
//    if (percent>=1.0) {
//        percent = 1.0;
//    }
    if (self.sliderIV.x <= self.width/2.0) {
        self.sliderIV.x = percent * self.width-4;
    } else {
        self.sliderIV.x = self.width/2.0-4;
    }
}
@end


