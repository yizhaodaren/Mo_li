//
//  JAMarkLineView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMarkLineView.h"

@interface JAMarkLineView ()
@property (nonatomic, assign) CGFloat scall;
@end

@implementation JAMarkLineView

- (void)setScall:(CGFloat)scall
{
    _scall = scall;
    [self setNeedsDisplay];
}

- (void)setMarkModel:(JAMarkModel *)markModel
{
    _markModel = markModel;
    
    self.scall = [self getTaskScall:markModel];
}

- (CGFloat)getTaskScall:(JAMarkModel *)model
{
    NSInteger num = 0;
    for (NSInteger i = 0; i < model.tasks.count; i++) {
        JAMarkTaskModel *m = model.tasks[i];
        if (m.taskStatus.integerValue == 1) {
            num += 1;
        }
    }
    
    CGFloat scall = num / (model.tasks.count * 1.0);
    
    return scall;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat endP = rect.size.width * self.scall;
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    // 设置线宽
    CGContextSetLineWidth(ctx, 4);
    CGContextSetStrokeColorWithColor(ctx, HEX_COLOR(0x6BD379).CGColor);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, endP, 0);
    CGContextStrokePath(ctx);
}
@end
