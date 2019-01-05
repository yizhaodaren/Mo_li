//
//  UIView+JACategory.m
//  Jasmine
//
//  Created by xujin on 25/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "UIView+JACategory.h"
#import <Toast/UIView+Toast.h>

@implementation UIView (JACategory)

- (void)ja_makeToast:(NSString *)message {
    [self ja_makeToast:message duration:2.0];
}

- (void)ja_makeToast:(NSString *)message duration:(NSTimeInterval)duration {
    [self ja_makeToast:message duration:duration position:CSToastPositionCenter];
}

- (void)ja_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position {
    if (!message.length) {
        return;
    }
    [CSToastManager setQueueEnabled:NO];
    [self makeToast:message duration:duration position:position];
}


- (void)ja_taskToastWithTitle:(NSString *)title keyWord:(NSString *)keyWord flower:(NSString *)flower deplay:(CGFloat)time
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.8);
        backView.width = 200;
        backView.height = 100;
        backView.layer.cornerRadius = 10;
        backView.layer.masksToBounds = YES;
        backView.centerX = self.width * 0.5;
        backView.centerY = self.height * 0.5;
        [self addSubview:backView];
        
        UILabel *titleL = [[UILabel alloc] init];
        titleL.textColor = HEX_COLOR(0xffffff);
        titleL.textAlignment = NSTextAlignmentCenter;
        titleL.font = JA_MEDIUM_FONT(16);
        titleL.attributedText = [self attributedString:title word:keyWord];
        titleL.width = backView.width;
        titleL.height = 22;
        titleL.y = 24;
        [backView addSubview:titleL];
        
        UIButton *flowerB = [UIButton buttonWithType:UIButtonTypeCustom];
        [flowerB setTitle:flower forState:UIControlStateNormal];
        [flowerB setTitleColor:HEX_COLOR(0xF8E81C) forState:UIControlStateNormal];
        flowerB.titleLabel.font = JA_MEDIUM_FONT(15);
        [flowerB setImage:[UIImage imageNamed:@"task_toast_flower"] forState:UIControlStateNormal];
        flowerB.width = backView.width;
        flowerB.height = 24;
        flowerB.y = titleL.bottom + 9;
        flowerB.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        [backView addSubview:flowerB];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [backView removeFromSuperview];
        });
    });
    
    
    
}

- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    
    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x44D2AA) range:rang];
    
    return attr;
}

// 是否在屏幕上
- (BOOL)isDisplayedInScreen
{
    if (self == nil) {
        return NO;
    }
    
    // 主窗口
    UIWindow *keyWindow = [[[UIApplication sharedApplication] delegate] window];
    
    // 主窗口左上角为坐标原点
    CGRect newFrame = [keyWindow convertRect:self.frame fromView:self.superview];
    CGRect winBounds = keyWindow.bounds;
    
    // 主窗口的bounds 和 self的矩形框 是否有重叠
    BOOL intersects = CGRectIntersectsRect(newFrame, winBounds);
    
    return !self.isHidden && self.alpha > 0.01 && self.window == keyWindow && intersects;
}

+ (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor lineDirection:(BOOL)isHorizonal {
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    [shapeLayer setBounds:lineView.bounds];
    
    if (isHorizonal) {
        
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
        
    } else{
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame)/2)];
    }
    
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    if (isHorizonal) {
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    } else {
        
        [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    }
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    
    if (isHorizonal) {
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    } else {
        CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    }
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

@end
