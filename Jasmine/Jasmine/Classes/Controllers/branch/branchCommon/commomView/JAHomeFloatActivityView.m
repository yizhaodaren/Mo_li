//
//  JAHomeFloatActivityView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/17.
//  Copyright © 2017年 xujin. All rights reserved.
/*
    活动弹窗
 */

#import "JAHomeFloatActivityView.h"
#import "JAActivityFloatModel.h"
#import "JAWebViewController.h"
#import "JAPostDetailViewController.h"
#import "AppDelegateModel.h"
#import "JAPersonalTaskViewController.h"
#import "JAPacketViewController.h"
#import "JAHelperViewController.h"
#import "CYLTabBarController.h"

@interface JAHomeFloatActivityView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, strong) JAActivityFloatModel *model;
//@property (nonatomic, strong) NSString *imageUrl;

@property (nonatomic, strong) void(^closeBlock)();

@property (nonatomic, assign) CGSize imageS;
@end

@implementation JAHomeFloatActivityView

+ (void)showFloatActivity:(JAActivityFloatModel *)model
{
    JAHomeFloatActivityView *v = [[JAHomeFloatActivityView alloc] init];
    v.model = model;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.8);
    }
    return self;
}

- (void)setupUI
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpActivity)];
    [imageView addGestureRecognizer:tap];
    [self addSubview:imageView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"activity_float_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeSelf:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorFrame];
}

- (void)caculatorFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;

    self.imageView.width = WIDTH_ADAPTER(375);
    self.imageView.height = WIDTH_ADAPTER(375);
    self.imageView.centerX = JA_SCREEN_WIDTH * 0.5;
    self.imageView.centerY = JA_SCREEN_HEIGHT * 0.5 + WIDTH_ADAPTER(20);
    
    self.closeButton.width = WIDTH_ADAPTER(40);
    self.closeButton.height = self.closeButton.width;
    self.closeButton.x = self.imageView.right - self.closeButton.width * 2;
    self.closeButton.y = self.imageView.y - self.closeButton.height - WIDTH_ADAPTER(10);

}

- (void)setModel:(JAActivityFloatModel *)model
{
    _model = model;
    [self.imageView ja_setImageWithURLStr:model.image placeholderImage:nil completed:^(UIImage *image, NSError *error) {
        
        if (image) {
            [[self cyl_tabBarController].view addSubview:self];
            MMDrawerController *mmD = [AppDelegateModel rootviewController];
            [mmD setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];   
        }
    }];

}

- (void)closeSelf:(UIButton *)btn
{
    MMDrawerController *mmD = [AppDelegateModel rootviewController];
    [mmD setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
    [self removeFromSuperview];
}

- (void)jumpActivity
{
    // 分类型跳转
    if (self.model.contentType == 0 || self.model.contentType == 300) {                                  // web页面
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        NSString *str = self.model.url;
        if ([str isEqualToString:@"http://www.urmoli.com/newmoli/views/app/activity/invitingFriends.html"] && IS_LOGIN) {
            vc.urlString = [NSString stringWithFormat:@"%@?id=%@",str,[JAUserInfo userInfo_getUserImfoWithKey:User_id]];
        }else{
            vc.urlString = str;
        }
        vc.enterType = @"首页弹窗";
        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        
    }else if (self.model.contentType == 1 || self.model.contentType == 127){                           // 帖子详情
        // banner 如果是帖子，分享的话，也算做任务
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        vc.voiceId = self.model.url;
        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        
    }else if (self.model.contentType == 2 || self.model.contentType == 114){                         // 任务页面
        
        if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
            [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
            return;
        }
        
        if (!IS_LOGIN) {
            [JAAPPManager app_modalLogin];
            return;
        }
        
        if ([[JAUserInfo userInfo_getUserImfoWithKey:User_Admin] integerValue] == JAVPOWER) {
            
            return;
        }
        
        JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        
    }else if (self.model.contentType == 3 || self.model.contentType == 110){                                     // 邀请红包页面
        if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
            [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
            return;
        }
        if (!IS_LOGIN) {
            [JAAPPManager app_modalLogin];
            return;
        }
        JAPacketViewController *vc = [[JAPacketViewController alloc] init];
        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        
    }else if (self.model.contentType == 4 || self.model.contentType == 118){                                     // 帮助中心 新手教程
//        JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//        vc.currentIndex = 0;
//        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        
        JAWebViewController *help = [[JAWebViewController alloc] init];
        help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
        help.titleString = @"帮助中心";
        help.fromType = 1;
        help.enterType = @"帮助中心";
        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:help animated:YES];
        
    }else if (self.model.contentType == 5 || self.model.contentType == 119){                                     // 帮助中心 视频教程
//        JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//        vc.currentIndex = 1;
//        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
        JAWebViewController *help = [[JAWebViewController alloc] init];
        help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
        help.titleString = @"帮助中心";
        help.fromType = 1;
        help.enterType = @"帮助中心";
        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:help animated:YES];
    }
    [self removeFromSuperview];
    
}
@end
