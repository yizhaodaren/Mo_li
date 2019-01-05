//
//  EDBaseViewController.h
//  HTTP
//
//  Created by moli-2017 on 2017/7/4.
//  Copyright © 2017年 moli-2017. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDHTTPRequestManager.h"
#import "EDRequestUrlManager.h"

@interface EDBaseViewController : UIViewController
@property (nonatomic, strong) EDHTTPRequestManager *httpManager; // 网络管理者

@property (nonatomic, assign) BOOL needLoading;  // 是否需要loading  （如果该控制器不需要loading，重写属性的get方法 return : NO）

@property (nonatomic, strong) void(^requestFailureBlock)(); // 请求失败 回调

@property (nonatomic, strong) void(^needLoginBlock)();  // 未登录空白页 - 点击登录/注册 回调

/// 加载loading页面
- (void)showLoadingAnimation;

/// loading提示 - 未实现
- (void)showLoading:(NSString *)title;

/// 展示loading失败页面
- (void)showLoadingFailureWithClick:(BOOL)needClick;

/// 展示空白页
//- (void)showTipImage:(NSString *)imageName tipTitle:(NSString *)title;
//
//- (void)showTipImage:(NSString *)imageName;
//
//- (void)showTipTitle:(NSString *)title;

/// 移除
- (void)dissmissTip;

/// 未登录空白页面
- (void)loginOutStateTipImage:(NSString *)imageName
                     tipTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                       button:(NSString *)btnTitle;

@end
