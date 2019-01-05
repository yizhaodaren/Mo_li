//
//  JAVolumeAnimateView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/15.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAVolumeAnimateView.h"

@interface JAVolumeAnimateView ()

@property (nonatomic, strong) NSArray *volumeArray;
@end

@implementation JAVolumeAnimateView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.volumeArray = @[@"3",@"5",@"9",@"3",@"3",@"7",@"3",@"7",@"3",@"3",@"3",@"4",@"4",@"4",@"14",@"3",@"5",@"3",@"5",@"3",@"4",@"3",@"9",@"3",@"3",@"9",@"3",@"3",@"6",@"11",@"19",@"12",@"3",@"3",@"3",@"3",@"11",@"3",@"5",@"3",@"11",@"3",@"3",@"3",@"15",@"3",@"5",@"9",@"3",@"3",@"7",@"3",@"7",@"3",@"3",@"3",@"4",@"4",@"4",@"14",@"3",@"5",@"3",@"5",@"3",@"4",@"3",@"9",@"3",@"3",@"9",@"3",@"3",@"6",@"11",@"19",@"12",@"3",@"3",@"3",@"3",@"11",@"3",@"5",@"3",@"11",@"3",@"3",@"3",@"15"];
    }
    return self;
}

- (void)setDrawColor:(UIColor *)drawColor
{
    _drawColor = drawColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 绘制 音量柱状图
    CGFloat volumeBarWidth = 1;
    CGFloat volumeBarXOffset = 2;
    CGFloat volumeBarX = 0;
    
    //设置线的宽度
    CGContextSetLineWidth(context, volumeBarWidth);
    
    // 设置线的颜色
    if (self.drawColor) {
        [self.drawColor set];
    }else{
        [[UIColor greenColor] set];
    }
    
    for (int i = 0; i < self.volumeArray.count; i++)
    {
        CGFloat volumeH = [self.volumeArray[i] floatValue];
        
        CGFloat beginP = (self.frame.size.height - volumeH) * 0.5;
        CGFloat endP = (self.frame.size.height + volumeH) * 0.5;
        
        CGContextMoveToPoint(context, volumeBarX, beginP);
        CGContextAddLineToPoint(context, volumeBarX, endP);
        volumeBarX += volumeBarWidth + volumeBarXOffset;
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}
@end
