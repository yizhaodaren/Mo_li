//
//  JADIYBottomView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/24.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JADIYBottomView.h"

@implementation JADIYBottomView

- (void)drawRect:(CGRect)rect
{
    // 获取图形环境
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect EllipseInRect = self.bounds;
    // 增加一个椭圆形
    CGContextAddEllipseInRect(context, EllipseInRect);
    // 设置椭圆形的边线宽度
    CGContextSetLineWidth(context, 0);
    // 设置椭圆形内部填充颜色
    CGContextSetRGBFillColor(context, 0.9, 0.9, 0.9, 1.0);
    
    // 渲染
    CGContextDrawPath(context, kCGPathFillStroke);
    
}

@end
