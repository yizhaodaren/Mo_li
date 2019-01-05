//
//  UIView+JACategory.h
//  Jasmine
//
//  Created by xujin on 25/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (JACategory)

- (void)ja_makeToast:(NSString *)message;
- (void)ja_makeToast:(NSString *)message duration:(NSTimeInterval)duration;
- (void)ja_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position;
- (void)ja_taskToastWithTitle:(NSString *)title keyWord:(NSString *)keyWord flower:(NSString *)flower deplay:(CGFloat)time;
- (BOOL)isDisplayedInScreen;


/**
 *  通过 CAShapeLayer 方式绘制虚线
 *
 *  param lineView:       需要绘制成虚线的view
 *  param lineLength:     虚线的宽度
 *  param lineSpacing:    虚线的间距
 *  param lineColor:      虚线的颜色
 *  param lineDirection   虚线的方向  YES 为水平方向， NO 为垂直方向
 **/
+ (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor lineDirection:(BOOL)isHorizonal;

@end
