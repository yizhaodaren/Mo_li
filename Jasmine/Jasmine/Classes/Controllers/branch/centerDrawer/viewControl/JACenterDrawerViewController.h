//
//  JACenterDrawerViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/28.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "FSScrollContentView.h"
#import "JAHomeLeftView.h"
#import "SPPageMenu.h"

@interface JACenterDrawerViewController : JABaseViewController

// 为了计算该控件在新手引导界面的位置
@property (nonatomic, weak) JAHomeLeftView *leftButton;
@property (nonatomic, weak) UIButton *rightButton;// 发布按钮
@property (nonatomic, weak) UIView *topNavView;
@property (nonatomic, strong) FSPageContentView *contentView;
@property (nonatomic, strong) SPPageMenu *titleView;

// 广告是否消失
@property (nonatomic, assign) BOOL adIsDismiss;
@end
