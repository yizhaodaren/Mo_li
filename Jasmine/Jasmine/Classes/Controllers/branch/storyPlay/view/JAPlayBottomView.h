//
//  JAPlayBottomView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/2.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JASlider;
@interface JAPlayBottomView : UIView
@property (nonatomic, weak) UILabel *beginTimeLabel;   // 开始时间
@property (nonatomic, weak) UILabel *totalTimeLabel;   // 总时间
@property (nonatomic, weak) JASlider *slider;          // 进度条
@property (nonatomic, weak) UIButton *orderButton;     // 顺序按钮
@property (nonatomic, weak) UIButton *frontButton;     // 前一首按钮
@property (nonatomic, weak) UIButton *playButton;      // 播放按钮
@property (nonatomic, weak) UIButton *nextButton;      // 下一首按钮
@property (nonatomic, weak) UIButton *infoButton;      // 帖子详情按钮

@end
