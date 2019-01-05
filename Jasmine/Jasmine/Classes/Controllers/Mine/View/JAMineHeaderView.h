//
//  JAMineHeaderView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/4.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMineWordView.h"

@interface JAMineHeaderView : UIView
@property (nonatomic, assign) CGFloat topOffY;  // 顶部偏移

@property (nonatomic, strong) NSDictionary *infoDictionary;  // 用户信息

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIButton *levelButton;
@property (nonatomic, weak) UIButton *personCenterButton;

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) JAMineWordView *publishView;
@property (nonatomic, weak) JAMineWordView *collectView;
@property (nonatomic, weak) JAMineWordView *focusView;
@property (nonatomic, weak) JAMineWordView *fansView;

@end
