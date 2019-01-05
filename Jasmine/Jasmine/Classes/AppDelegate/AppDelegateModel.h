//
//  AppDelegateModel.h
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JABaseNavigationController.h"
#import "Reachability.h"
#import "JANewLeftDrawerViewController.h"
#import "JACenterDrawerViewController.h"

@class MMDrawerController;
@interface AppDelegateModel : NSObject

@property (nonatomic,strong) MMDrawerController * drawerController;
@property (nonatomic, strong) Reachability *reach;
+ (instancetype)shareInstance;

/// 获取跟控制器 (MMDrawerController *)
+ (MMDrawerController *)rootviewController;

/// 获取最基本的控制器 （JABaseNavigationController *）
+ (JABaseNavigationController *)getBaseNavigationViewControll;


/// 获取左边控制器
+ (JANewLeftDrawerViewController *)getLeftMenuViewController;

/// 获取中心控制器
+ (JACenterDrawerViewController *)getCenterMenuViewController;

- (void)setup;

@end
