//
//  JAPostDetailNavBarView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/30.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JACircleModel;
@interface JAPostDetailNavBarView : UIView

- (void)circleDetailNavBarView_changePointButtonToEdge:(BOOL)isEdge;

@property (nonatomic, weak) UIButton *backButton;  // 返回按钮
@property (nonatomic, weak) UIButton *infoButton;     // 圈子资料按钮
@property (nonatomic, weak) UIView *circleView;  // 圈子view

@property (nonatomic, strong) JACircleModel *circleModel;  // 圈子信息

@end
