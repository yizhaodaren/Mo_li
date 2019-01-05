//
//  JAPlayAnimateView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/1/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPlayAnimateView : UIView
@property (nonatomic, strong) UIButton *playButton;  // 播放按钮

- (instancetype)initWithColor:(UIColor *)color frame:(CGRect)frame;

@property (nonatomic, strong) NSString *time;

- (void)beginVolumeAnimate:(CGFloat)process;  // 开始音量的动画
- (void)resetVolumeAnimate;  // 重置音量的动画
- (void)setPlayLoadingViewHidden:(BOOL)hidden;

@end
