//
//  JABaseViewController.h
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EDBaseViewController.h"

@interface JABaseViewController : EDBaseViewController

@property (nonatomic, strong) NSString *pageId;

@property (nonatomic, strong) UIView *blankView;

//webView 专用
@property (nonatomic, copy) NSString *webViewTitle;
@property (nonatomic, strong) UIColor *navigationBarColor;

@property (nonatomic, assign) BOOL showTopLine;
@property (nonatomic, weak) UIView *loadingView;

- (void)setNavigationBarNormalColor;


- (void)actionLeft;
- (void)actionRight;
//左右图片
- (void)setLeftNavigationItemImage:(UIImage *)image
                    highlightImage:(UIImage *)highlightImage;

- (void)setLeftNavigationItemImage:(UIImage *)image
                    highlightImage:(UIImage *)highlightImage
                            action:(SEL)action;


- (void)setRightNavigationItemImage:(UIImage *)image
                     highlightImage:(UIImage *)highlightImage;


- (void)setRightNavigationItemImage:(UIImage *)image
                     highlightImage:(UIImage *)highlightImage
                             action:(SEL)action;


//标题
- (void)setNavLeftTitle:(NSString *)navLeftTitle;
- (void)setNavRightTitle:(NSString *)navRightTitle;
- (void)setNavRightTitle:(NSString *)navRightTitle color:(UIColor *)color;
- (void)setCenterTitle:(NSString *)centerTitle;
- (void)setCenterTitle:(NSString *)centerTitle color:(UIColor *)color;
- (void)setCenterTitle:(NSString *)centerTitle withTextAttributes:(NSDictionary*)textAttributes;
/**
 * 是否是通过navigation push进来的
 */
- (BOOL)isPushed;

/**
 * 当vc的view添加到视图时，需要一个正确的高度
 */
- (void)updateViewHeight:(CGFloat)height;

/// 展示空白页
/// 传 y 带父视图
- (void)showBlankPageWithLocationY:(CGFloat)y
                             title:(NSString *)title
                          subTitle:(NSString *)subTitle
                             image:(NSString *)imageStr
                       buttonTitle:(NSString *)btnTitle
                          selector:(SEL)selector
                        buttonShow:(BOOL)show
                         superView:(UIView *)suV;

/// 传 高度
- (void)showBlankPageWithHeight:(CGFloat)height
                             title:(NSString *)title
                          subTitle:(NSString *)subTitle
                             image:(NSString *)imageStr
                       buttonTitle:(NSString *)btnTitle
                          selector:(SEL)selector
                        buttonShow:(BOOL)show
                         superView:(UIView *)suV;

/// 传Y
- (void)showBlankPageWithLocationY:(CGFloat)y
                             title:(NSString *)title
                          subTitle:(NSString *)subTitle
                             image:(NSString *)imageStr
                       buttonTitle:(NSString *)btnTitle
                          selector:(SEL)selector
                        buttonShow:(BOOL)show;

/// 移除空白页
- (void)removeBlankPage;

- (void)loadDate;

/// 显示loading
- (void)showLoading;

/// 移除loading
- (void)dismissLoading;

- (void)hideKeyboared;

@end
