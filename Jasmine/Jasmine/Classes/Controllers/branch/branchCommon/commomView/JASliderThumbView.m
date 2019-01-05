//
//  JASliderThumbView.m
//  Jasmine
//
//  Created by xujin on 04/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASliderThumbView.h"

@implementation JASliderThumbView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
//        _drawColor = HEX_COLOR(0x31C27C);
        self.diameter = 6;
        self.stickWidth = 2;
    }
    return self;
}

- (void)setDrawColor:(UIColor *)drawColor {
    _drawColor = drawColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    // 上圆
    CGContextAddEllipseInRect(context, CGRectMake(0, 0, self.diameter, self.diameter));
    // 矩形
    CGContextAddRect(context,CGRectMake((self.diameter-self.stickWidth)/2.0, self.diameter/2.0, self.stickWidth, self.height-self.diameter));
    // 下圆
    CGContextAddEllipseInRect(context, CGRectMake(0, self.height-self.diameter, self.diameter, self.diameter));
    
    //    [self.drawColor set];
    CGContextSetFillColorWithColor(context, self.drawColor.CGColor);//填充颜色
//    CGContextSetShadowWithColor(context, CGSizeMake(0, 0.5), 5, HEX_COLOR_ALPHA(0x000000, 0.5).CGColor);

    CGContextFillPath(context);
    
}

@end
