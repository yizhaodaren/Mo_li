//
//  JAAlphaCircleView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAlphaCircleView.h"

@interface JAAlphaCircleView ()
@property (nonatomic, strong) void(^finish)();
@property (nonatomic, strong) void(^durationDraw)(CGFloat duration);
@property (nonatomic, assign) CGFloat progress;

@end

@implementation JAAlphaCircleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleViewUI];
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setupCircleViewUI
{
    self.width = 60;
    self.height = self.width;
    
    self.layer.cornerRadius = self.width * 0.5;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    [path addArcWithCenter:CGPointMake(CGRectGetWidth(self.bounds)/2, CGRectGetHeight(self.bounds)/2) radius:27 startAngle:0 endAngle:M_PI *2 clockwise:YES];
    path.usesEvenOddFillRule = YES;
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor= [UIColor whiteColor].CGColor;  //其他颜色都可以，只要不是透明的
    shapeLayer.fillRule=kCAFillRuleEvenOdd;
    
    self.layer.mask = shapeLayer;
    
}


// 开始绘制
- (void)beginDrawCircleWith:(CGFloat)second durationBlock:(void(^)(CGFloat duration))durationBlock finishBlcok:(void(^)())finishBlock
{
    _progress = second;
    [self setNeedsDisplay];

}
// 结束绘制
- (void)endDrawCircle
{
    _progress = 0;
    [self setNeedsDisplay];
}


- (void)drawRect:(CGRect)rect {
    
    CGPoint center = CGPointMake(self.width * 0.5, self.height * 0.5);  //设置圆心位置
    CGFloat radius = self.width * 0.5;  //设置半径
    CGFloat startA = - M_PI_2;  //圆起点位置
    CGFloat endA = -M_PI_2 + M_PI * 2 * _progress;  //圆终点位置
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取上下文
    CGContextSetLineWidth(ctx, 6);
    CGContextSetStrokeColorWithColor(ctx, HEX_COLOR(JA_Line).CGColor);
    
    //绘制环形进度条底框
    CGContextAddArc(ctx, center.x, center.y, radius, 0, 2*M_PI, 0);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:startA endAngle:endA clockwise:YES];
    
    CGContextSetLineWidth(ctx, 6); //设置线条宽度
    [HEX_COLOR(0x6BD379) setStroke]; //设置描边颜色
    
    CGContextAddPath(ctx, path.CGPath); //把路径添加到上下文
    
    CGContextStrokePath(ctx);  //渲染
}


- (void)dealloc
{
    NSLog(@"00");
}
@end
