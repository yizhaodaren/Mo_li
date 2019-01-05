//
//  EDBaseViewController.m
//  HTTP
//
//  Created by moli-2017 on 2017/7/4.
//  Copyright © 2017年 moli-2017. All rights reserved.
//

#import "EDBaseViewController.h"


#define HEX_COLOR_ALPHA(_HEX_,a) [UIColor colorWithRed:((float)((_HEX_ & 0xFF0000) >> 16))/255.0 green:((float)((_HEX_ & 0xFF00) >> 8))/255.0 blue:((float)(_HEX_ & 0xFF))/255.0 alpha:a]


#define HEX_COLOR(_HEX_) HEX_COLOR_ALPHA(_HEX_, 1.0)
@interface EDBaseViewController ()

@property (nonatomic, weak) UIView *content_view; // 大view
@property (nonatomic, weak) UIImageView *bgImageView;    // 图片
@property (nonatomic, weak) UILabel *bgTitleLabel;   // 标题
@property (nonatomic, weak) UILabel *bgSubTitleLabel; // 子标题
@property (nonatomic, weak) UIButton *bgLoginRegistButton; // 按钮

@end

@implementation EDBaseViewController

- (BOOL)needLoading   // 默认是YES  --  临时 NO
{
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.needLoading) {
        [self showLoadingAnimation];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    if (self.needLoading) {
//        [self showLoadingAnimation];
//    }
}

/*
    控件的调整：
        1、布局尺寸、位置
        2、设置展示内容
 */

// 加载loading页面
- (void)showLoadingAnimation
{
    [_bgTitleLabel removeFromSuperview];
    _bgTitleLabel = nil;
    [_bgSubTitleLabel removeFromSuperview];
    _bgSubTitleLabel = nil;
    [_bgLoginRegistButton removeFromSuperview];
    _bgLoginRegistButton = nil;
    
    UIImage *image = [UIImage imageNamed:@"duihao_huifu"];
    self.bgImageView.image = image;
    self.bgImageView.width = image.size.width;
    self.bgImageView.height = image.size.height;
    self.bgImageView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
}


// loading提示
- (void)showLoading:(NSString *)title
{
    
}

// 展示loading失败页面
- (void)showLoadingFailureWithClick:(BOOL)needClick
{
    
    self.bgImageView.userInteractionEnabled = needClick;
    
    [self showTipImage:@"blank_fail"];
}

// 展示空白页
- (void)showTipImage:(NSString *)imageName tipTitle:(NSString *)title
{

    [_bgSubTitleLabel removeFromSuperview];
    _bgSubTitleLabel = nil;
    [_bgLoginRegistButton removeFromSuperview];
    _bgLoginRegistButton = nil;
    
    UIImage *image = [UIImage imageNamed:imageName];
    self.bgImageView.image = image;
    
    self.bgImageView.width = image.size.width;
    self.bgImageView.height = image.size.height;
    
    self.bgTitleLabel.text = title;
    [self.bgTitleLabel sizeToFit];
    self.bgTitleLabel.centerX = self.view.width * 0.5;
    self.bgTitleLabel.centerY = self.view.height * 0.5;
    
    self.bgImageView.centerX = self.view.width * 0.5;
    self.bgImageView.y = self.bgTitleLabel.y - self.bgImageView.height - 38;
}

- (void)showTipImage:(NSString *)imageName
{

    [_bgTitleLabel removeFromSuperview];
    _bgTitleLabel = nil;
    [_bgSubTitleLabel removeFromSuperview];
    _bgSubTitleLabel = nil;
    [_bgLoginRegistButton removeFromSuperview];
    _bgLoginRegistButton = nil;
    
    UIImage *image = [UIImage imageNamed:imageName];
    self.bgImageView.image = image;
    self.bgImageView.width = image.size.width;
    self.bgImageView.height = image.size.height;
    self.bgImageView.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    
}

- (void)showTipTitle:(NSString *)title
{

    [_bgImageView removeFromSuperview];
    _bgImageView = nil;
    [_bgSubTitleLabel removeFromSuperview];
    _bgSubTitleLabel = nil;
    [_bgLoginRegistButton removeFromSuperview];
    _bgLoginRegistButton = nil;
    
    self.bgTitleLabel.text = title;
    [self.bgTitleLabel sizeToFit];
    self.bgTitleLabel.centerX = self.view.width * 0.5;
    self.bgTitleLabel.centerY = self.view.height * 0.5;
}

// 移除
- (void)dissmissTip
{
    
    [_content_view removeFromSuperview];
    _content_view = nil;
    
}

// 未登录空白页面
- (void)loginOutStateTipImage:(NSString *)imageName
                     tipTitle:(NSString *)title
                     subTitle:(NSString *)subTitle
                       button:(NSString *)btnTitle
{
    
    UIImage *image = [UIImage imageNamed:imageName];
    self.bgImageView.image = image;
    
    
}


// 点击未登录时的按钮
- (void)needLogin
{
    NSLog(@"跳往登录页面");
    // 取消加载失败页面
    [_content_view removeFromSuperview];
    
    if (self.needLoginBlock) {
        self.needLoginBlock();
    }
}

- (void)loadingAgain
{
    NSLog(@"点击重新加载");
    [self showLoadingAnimation];
    
    if (self.requestFailureBlock) {
        self.requestFailureBlock();
    }
}

// 每个控制器的网络请求
- (EDHTTPRequestManager *)httpManager
{
    if (_httpManager == nil) {
        _httpManager = [[EDHTTPRequestManager alloc] init];
    }
    return _httpManager;
}

// 控件的懒加载
- (UIImageView *)bgImageView
{
    if (_bgImageView == nil) {
        UIImageView *imageV = [[UIImageView alloc] init];
//        imageV.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadingAgain)];
        [imageV addGestureRecognizer:tap];
        _bgImageView = imageV;
        [self.content_view addSubview:imageV];
    }
    return _bgImageView;
}

- (UILabel *)bgTitleLabel
{
    if (_bgTitleLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        _bgTitleLabel = label;
        label.textColor = HEX_COLOR(0x7e8392);
        label.font = [UIFont systemFontOfSize:18];
        [label sizeToFit];
        [self.content_view addSubview:label];
    }
    return _bgTitleLabel;
}

- (UILabel *)bgSubTitleLabel
{
    if (_bgSubTitleLabel == nil) {
        UILabel *label = [[UILabel alloc] init];
        _bgSubTitleLabel = label;
        label.textColor = HEX_COLOR(0xe6e6e6);
        label.font = [UIFont systemFontOfSize:14];
        [label sizeToFit];
        [self.content_view addSubview:label];
    }
    return _bgSubTitleLabel;
}

- (UIButton *)bgLoginRegistButton
{
    if (_bgLoginRegistButton == nil) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn addTarget:self action:@selector(needLoading) forControlEvents:UIControlEventTouchUpInside];
        _bgLoginRegistButton = btn;
        [self.content_view addSubview:btn];
    }
    return _bgLoginRegistButton;
}

- (UIView *)content_view
{
    if (_content_view == nil) {
        UIView *v = [[UIView alloc] initWithFrame:self.view.bounds];
        _content_view = v;
        v.backgroundColor = HEX_COLOR(JA_Background);
        [self.view addSubview:v];
    }
    return _content_view;
}
@end
