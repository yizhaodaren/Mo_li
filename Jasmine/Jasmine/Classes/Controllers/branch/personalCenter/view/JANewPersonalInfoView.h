//
//  JANewPersonalInfoView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANewPersonalInfoView : UIView
@property (nonatomic, strong) JAConsumer *model;  // 个人信息
@property (nonatomic, assign) CGFloat topOffY;  // 顶部偏移

@property (nonatomic, weak) UIImageView *iconImageView;  // 头像
@property (nonatomic, weak) UIButton *editButton;  // 编辑按钮
@property (nonatomic, weak) UIButton *focusButton;  // 关注按钮
@property (nonatomic, weak) UIButton *messageButton;  // 私信按钮
@property (nonatomic, weak) UIButton *contributeButton;  // 投稿须知按钮
@end
