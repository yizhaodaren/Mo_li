//
//  EDSegmentViewController.h
//  segmentView
//
//  Created by 刘宏亮 on 17/6/18.
//  Copyright © 2017年 刘宏亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EDSegmentViewController : JABaseViewController

// 布局位置
@property (nonatomic, assign) CGFloat layoutY; // 默认64

// 标题左右间距
@property (nonatomic, assign) CGFloat title_margin; // 不设置默认等分

// 子控制器数组
@property (nonatomic, strong) NSArray *childViewControlArray;

// 控制器是否需要滑动
@property (nonatomic, assign) BOOL content_scroll;

// 标题是否需要滚动
@property (nonatomic, assign) BOOL title_scroll; // 默认为NO

// 标题的宽度
@property (nonatomic, assign) CGFloat *title_width; // 如果设置标题滚动必须设置宽度

// 标题是否需要跟随滚动放大缩小
@property (nonatomic, assign) BOOL title_scale;  // 默认为NO

// 标题是否需要渐变色
@property (nonatomic, assign) BOOL *title_color; // 默认为NO

// 开始滚动需要做的事情
//@property (nonatomic, strong) void(^beginScrollBlock)(UIViewController *vc);  // 暂时不加

// 点击按钮需要做的事情
@property (nonatomic, strong) void(^clickButtonBlock)(UIViewController *vc,UIButton *button);

// 结束滚动需要做的事情
@property (nonatomic, strong) void(^endScrollBlock)(UIViewController *vc);

// 当前正在显示的控制器
@property (nonatomic, weak) UIViewController *currentViewControl;
@end
