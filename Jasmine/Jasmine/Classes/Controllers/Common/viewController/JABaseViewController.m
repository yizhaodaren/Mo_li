//
//  JABaseViewController.m
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"
//#import "UIImage+ImageEffects.h"


@interface JABaseViewController ()
{
    //没数据的情况下背景图
    UIImageView * noDataViewBg;
    
    //没数据的情况下文字描述
    UILabel     * noDataLab;
}
@property (nonatomic,strong)  UIButton * leftButton;
@property (nonatomic,strong)  UIButton * rightButton;
@property (nonatomic,strong)  UIButton * secondRightButton;
@property (nonatomic,strong) UILabel *topLineLabel;

@property(nonatomic, assign) BOOL navRightEnabled;


@end

@implementation JABaseViewController

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)dealloc
{
    
}

-(id) initWithNavigationBarHidden
{
    self = [super init];
    if(self)
    {
    }
    return self;
}

-(UIButton *) leftButton
{
    return _leftButton;
}

-(UIButton *) rightButton
{
    return _rightButton;
}

- (void)viewDidLoad

{
    
    [super viewDidLoad];
    
    //1.配置整个背景色
    self.view.backgroundColor = HEX_COLOR(JA_Background);
    
    //2.自定义导航
    //
    CGRect navigationFrame;
    navigationFrame = CGRectZero;
    UIView *navigationView = [[UIView alloc] initWithFrame:navigationFrame];
    
    navigationView.backgroundColor = HEX_COLOR(0xfcfcfc);
    [self.view addSubview:navigationView];
    
    
    float barHeight =0;
    
    BOOL isIPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
    
    if (!isIPad && ![[UIApplication sharedApplication] isStatusBarHidden]) {
        
        barHeight+=([[UIApplication sharedApplication]statusBarFrame]).size.height;
        
    }
    
    if(self.navigationController &&!self.navigationController.navigationBarHidden) {
        
        barHeight+=self.navigationController.navigationBar.frame.size.height;
        
    }
    
    for (UIView *view in self.view.subviews) {
        
        
        
        if ([view isKindOfClass:[UIScrollView class]]) {
            
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y +barHeight, view.frame.size.width, view.frame.size.height - barHeight);
            
        } else {
            
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y +barHeight, view.frame.size.width, view.frame.size.height);
            
        }
        
    }
    
    // navigation bar 底部分割线
//    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.height - 0.5, self.view.width, 0.5)];
//    line.backgroundColor = HEX_COLOR(0xd2d2d2);
//    [self.navigationController.navigationBar addSubview:line];
//    self.topLineLabel = line;
//    line.hidden = YES;
    
    // 增加默认的返回按钮
    if (self.navigationController.viewControllers.count>1) {
        [self setLeftNavigationItemImage:[UIImage imageNamed:@"circle_back_black"] highlightImage:[UIImage imageNamed:@"circle_back_black"]];
//        [self setLeftNavigationItemImage:[UIImage imageNamed:@"branch_back"] highlightImage:[UIImage imageNamed:@"branch_back"]];
    }
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];

}


- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[AppDelegate sharedInstance].playerView playerView_animateAndHiddenWithViewControl:self];
    
    
    // 需要增加代码，现在还没时间写
//    [[AppDelegateModel rootTabBarController] setTabbarHidden:NO];
    
}

- (void)actionLeft
{
    
    if (self.isPushed)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.loadingView removeFromSuperview];
    [MBProgressHUD hideHUD];
}

- (void)actionRight {
    
}

- (void)setLeftNavigationItemImage:(UIImage *)image
                    highlightImage:(UIImage *)highlightImage
{
    
    [self setLeftNavigationItemImage:image highlightImage:highlightImage action:@selector(actionLeft)];
}

- (void)setLeftNavigationItemImage:(UIImage *)image
                    highlightImage:(UIImage *)highlightImage
                            action:(SEL)action
{
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn.frame = CGRectMake(0, 0, 40, 44);
////    btn.backgroundColor = [UIColor redColor];
//    btn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
//    [btn setImage:image forState:UIControlStateNormal];
//    [btn setImage:highlightImage forState:UIControlStateHighlighted];
//    [btn addTarget:self
//            action:action
//  forControlEvents:UIControlEventTouchUpInside];
//    
//    
////    if (@available(iOS 11.0, *)) {
//        btn.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
//        [btn setImageEdgeInsets:UIEdgeInsetsMake(0, -5 * JA_SCREEN_WIDTH /375.0,0,0)];
////    }
//    
//    UIBarButtonItem *leftBarButtonItem =
//    [[UIBarButtonItem alloc] initWithCustomView:btn];
//    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
//                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
//                                       target:nil
//                                       action:nil];
//    negativeSpacer.width = -10;
//    self.navigationItem.leftBarButtonItems =
//    [NSArray arrayWithObjects: leftBarButtonItem, nil];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:action];
    item.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    
    self.navigationItem.leftBarButtonItem = item;
}


- (void)setRightNavigationItemImage:(UIImage *)image
                     highlightImage:(UIImage *)highlightImage{
    [self setRightNavigationItemImage:image highlightImage:highlightImage action:@selector(actionRight)];
}

- (void)setRightNavigationItemImage:(UIImage *)image
                     highlightImage:(UIImage *)highlightImage
                             action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 44);
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:highlightImage forState:UIControlStateHighlighted];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(btn.imageEdgeInsets.top, btn.imageEdgeInsets.left, btn.imageEdgeInsets.bottom, -18)];
    [btn addTarget:self
            action:action
  forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setNavLeftTitle:(NSString *)navLeftTitle {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 60, 30);
    [btn setTitle:navLeftTitle forState:UIControlStateNormal];
    btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
    [btn setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateNormal];
    btn.titleLabel.font = JA_MEDIUM_FONT(15);
    [btn addTarget:self
            action:@selector(actionLeft)
  forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithCustomView:btn];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil
                                       action:nil];
    negativeSpacer.width = -10;
    self.navigationItem.leftBarButtonItems =
    [NSArray arrayWithObjects:negativeSpacer, leftBarButtonItem, nil];
}
- (void)setNavRightTitle:(NSString *)navRightTitle
{
    if (navRightTitle.length == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        [self setNavRightTitle:navRightTitle color:HEX_COLOR(JA_BlackTitle)];
    }
}
- (void)setNavRightTitle:(NSString *)navRightTitle color:(UIColor *)color
{
    if (navRightTitle.length == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 30);
        btn.tag = 4536;
//        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:navRightTitle forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateNormal];
        btn.titleLabel.font = JA_REGULAR_FONT(15);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
        //    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.titleEdgeInsets.top, btn.titleEdgeInsets.left, btn.titleEdgeInsets.bottom, -40)];
        CGSize textSize = [[btn titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
        [btn setFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
        [btn addTarget:self
                action:@selector(actionRight)
      forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
    
}

- (void)setCenterTitle:(NSString *)centerTitle
{
    [self setCenterTitle:centerTitle color:HEX_COLOR(JA_BlackTitle)];
}

- (void)setCenterTitle:(NSString *)centerTitle color:(UIColor *)color
{
    [self setCenterTitle:centerTitle withTextAttributes:@{NSForegroundColorAttributeName:color,NSFontAttributeName:JA_REGULAR_FONT(18)}];
}

- (void)setCenterTitle:(NSString *)centerTitle withTextAttributes:(NSDictionary*)textAttributes
{
    if (centerTitle.length > 0 ) {
        [[UINavigationBar appearance] setTitleTextAttributes:textAttributes];
        self.navigationItem.title = centerTitle;
    } else {
        [[UINavigationBar appearance] setTitleTextAttributes:nil];
        self.navigationItem.title = nil;
    }
}


- (void) setNavRightEnabled:(BOOL)navRightEnabled{
    _navRightEnabled = navRightEnabled;
    self.navigationItem.rightBarButtonItem.enabled = navRightEnabled;
    UIView * button = self.navigationItem.rightBarButtonItem.customView;
    if ([button isKindOfClass:[UIButton class]]) {
        ((UIButton*)button).enabled = navRightEnabled;
    }
}
- (BOOL)isPushed {
    
    NSArray *viewcontrollers=self.navigationController.viewControllers;
    
    if (viewcontrollers.count>1) {
        if ([viewcontrollers objectAtIndex:viewcontrollers.count-1]==self) {
            //push方式
            return YES;
        }
    } else {
        // 在tabbar中显示
        UIViewController *vc = viewcontrollers[0];
        if ([vc isKindOfClass:[UITabBarController class]]) {
            return YES;
        }
    }
    //present方式
    return NO;
}


- (void)setNavigationBarColor:(UIColor *)navigationBarColor
{
    if (navigationBarColor == [UIColor whiteColor]) {
        
        navigationBarColor = HEX_COLOR(JA_Background);
    }
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:navigationBarColor]
                            forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
}

- (void)setNavigationBarNormalColor
{
    [self setNavigationBarColor:HEX_COLOR(JA_Background)];
}
- (void)setShowTopLine:(BOOL)showTopLine
{
    if (showTopLine)
    {
        self.topLineLabel.hidden = NO;
    }
    else
    {
        self.topLineLabel.hidden = YES;
    }
        
}

- (void)updateViewHeight:(CGFloat)height {}


/// 展示空白页
- (void)showBlankPageWithLocationY:(CGFloat)y
                            height:(CGFloat)height
                             title:(NSString *)title
                          subTitle:(NSString *)subTitle
                             image:(NSString *)imageStr
                       buttonTitle:(NSString *)btnTitle
                          selector:(SEL)selector
                        buttonShow:(BOOL)show
                         superView:(UIView *)suV
{
    [_blankView removeFromSuperview];
    _blankView = [[UIView alloc] init];
    _blankView.backgroundColor = HEX_COLOR(JA_Background);
    
    if (suV) {
        _blankView.width = suV.width;
        if (y > 0) {
            _blankView.y = y;
        }else{
            _blankView.y = 0;
        }
        if (height > 0) {
            _blankView.height = height;
        }else{
            _blankView.height = suV.height - y > 300 ? suV.height - y : 300;
        }
        
        _blankView.x = 0;
        [suV addSubview:_blankView];
    }else{
        _blankView.width = self.view.width;
        if (y > 0) {
            _blankView.y = y;
        }else{
            _blankView.y = 0;
        }
        if (height > 0) {
            _blankView.height = height;
        }else{
            _blankView.height = self.view.height - y > 300 ? self.view.height - y : 300;
        }
        _blankView.x = 0;
        [self.view addSubview:_blankView];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:selector];
    [_blankView addGestureRecognizer:tap];
    
    UILabel *subTLabel = [[UILabel alloc] init];
    subTLabel.text = subTitle;
    subTLabel.textColor = HEX_COLOR(0xe6e6e6);
    subTLabel.font = [UIFont systemFontOfSize:14];
    [subTLabel sizeToFit];
    subTLabel.center = CGPointMake(_blankView.width * 0.5, _blankView.height * 0.5 + 20);
    [_blankView addSubview:subTLabel];
    
    UILabel *titleL = [[UILabel alloc] init];
    titleL.textColor = HEX_COLOR(0x7e8392);
    titleL.text = title;
    titleL.font = [UIFont systemFontOfSize:18];
    [titleL sizeToFit];
    titleL.y = subTLabel.y - 5 - titleL.height;
    titleL.centerX = subTLabel.centerX;
    [_blankView addSubview:titleL];
    
    UIImageView *firstImageV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageStr]];
    firstImageV.centerX = subTLabel.centerX;
    firstImageV.y = titleL.y - 30 - firstImageV.height;
    [_blankView addSubview:firstImageV];
    
    if (btnTitle.length && show) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
        btn.backgroundColor = HEX_COLOR(0xDDF9EA);
        [btn setTitle:btnTitle forState:UIControlStateNormal];
        [btn setTitleColor:HEX_COLOR(0x31C27C) forState:UIControlStateNormal];
        btn.titleLabel.font = JA_REGULAR_FONT(14);
        btn.clipsToBounds = YES;
        btn.width = 100;
        btn.height = 24;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = HEX_COLOR(0x31C27C).CGColor;
        btn.layer.cornerRadius = btn.height * 0.5;
        btn.centerX = subTLabel.centerX;
        btn.y = CGRectGetMaxY(subTLabel.frame) + 20;
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [_blankView addSubview:btn];
    }
    
}
- (void)showBlankPageWithLocationY:(CGFloat)y
                             title:(NSString *)title
                          subTitle:(NSString *)subTitle
                             image:(NSString *)imageStr
                       buttonTitle:(NSString *)btnTitle
                          selector:(SEL)selector
                        buttonShow:(BOOL)show
                         superView:(UIView *)suV
{
    [self showBlankPageWithLocationY:y height:0 title:title subTitle:subTitle image:imageStr buttonTitle:btnTitle selector:selector buttonShow:show superView:suV];
}


/// 展示空白页
- (void)showBlankPageWithLocationY:(CGFloat)y
                             title:(NSString *)title
                          subTitle:(NSString *)subTitle
                             image:(NSString *)imageStr
                       buttonTitle:(NSString *)btnTitle
                          selector:(SEL)selector
                        buttonShow:(BOOL)show
{
    
    [self showBlankPageWithLocationY:y height:0 title:title subTitle:subTitle image:imageStr buttonTitle:btnTitle selector:selector buttonShow:show superView:nil];
}

/// 传 高度
- (void)showBlankPageWithHeight:(CGFloat)height
                          title:(NSString *)title
                       subTitle:(NSString *)subTitle
                          image:(NSString *)imageStr
                    buttonTitle:(NSString *)btnTitle
                       selector:(SEL)selector
                     buttonShow:(BOOL)show
                      superView:(UIView *)suV
{
    [self showBlankPageWithLocationY:0 height:height title:title subTitle:subTitle image:imageStr buttonTitle:btnTitle selector:selector buttonShow:show superView:suV];
}

/// 移除空白页
- (void)removeBlankPage
{
    [_blankView removeFromSuperview];
}

/// 显示loading
- (void)showLoading
{
//    UIView *loading = [[UIView alloc] init];
//    self.loadingView = loading;
//    self.loadingView.backgroundColor = HEX_COLOR(JA_Background);
//    self.loadingView.width = JA_SCREEN_WIDTH;
//    self.loadingView.height = JA_SCREEN_HEIGHT;
//    self.loadingView.y = 65;
//   [[[[UIApplication sharedApplication] delegate] window] addSubview:self.loadingView];
//
//    [SVProgressHUD show];
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
//    [SVProgressHUD setBackgroundColor:HEX_COLOR(JA_Background)];
    
}

/// 移除loading
- (void)dismissLoading
{
    [self.view ja_makeToast:@""];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self.loadingView removeFromSuperview];
//        [SVProgressHUD dismiss];
//    });
}

- (void)loadDate
{
    
}

- (void)hideKeyboared {
    [self.view endEditing:YES];
}

@end
