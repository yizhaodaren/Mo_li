//
//  JAAlphaCircleView.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAAlphaCircleView : UIView

// 开始绘制
- (void)beginDrawCircleWith:(CGFloat)second durationBlock:(void(^)(CGFloat duration))durationBlock finishBlcok:(void(^)())finishBlock;
// 结束绘制
- (void)endDrawCircle;
@end
