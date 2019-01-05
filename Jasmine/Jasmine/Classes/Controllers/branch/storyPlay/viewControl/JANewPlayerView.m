
//
//  JANewPlayerView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/7.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPlayerView.h"
#import "JANewPlayTool.h"
#import "JAStoryPlayViewController.h"
#import <UIImage+GIF.h>

// 需要展示音量图的页面
#import "JAStoryViewController.h"
#import "JACenterDrawerViewController.h"  // 首页

#import "JAStoryCircleViewController.h"   // 圈子

#import "JAMessageViewController.h"
#import "JAVoiceNotiReplyViewController.h"
#import "JAsynthesizeMessageViewController.h"  // 消息私信

#import "JAMineViewController.h"            // 我的
#import "JAStoryAlbumViewController.h"   // 专辑列表
#import "JAAlbumDetailViewController.h"  // 专辑详情
#import "JAPostDetailViewController.h"   // 帖子详情
#import "JACircleDetailViewController.h" // 圈子详情
#import "JACircleAllStoryListViewController.h"
#import "JACircleEssenceStoryListViewController.h"
#import "JACircleInfoViewController.h"   // 圈子资料
#import "JAPersonalTaskViewController.h"   // 任务中心
#import "JAActivityCenterViewController.h"  // 活动中心
#import "JADraftViewController.h"         // 草稿
#import "JAPersonStoryAndReplyViewController.h" // 发表
#import "JANewPersonVoiceViewController.h"
#import "JANewPersonReplyViewController.h"
#import "JANewPersonCollectVoiceViewController.h"
#import "JACollectAlbumViewController.h"
#import "JACollectViewController.h"         // 收藏
#import "JASubRelationshipViewController.h" // 关注、粉丝
#import "JAPersonalCenterViewController.h" // 个人中心
#import "JASettingViewController.h"       // 设置
#import "JAVoiceNotiAgreeViewController.h" // 消息—喜欢
#import "JAVoiceNotiFocusViewController.h"  // 消息—粉丝
#import "JAVoiceNotiCallMeViewController.h" // 消息—@我
#import "CYLTabBarController.h"

#define kLineCount 4
#define kLineWidth 2
#define kLineMargin 3

@interface JANewPlayerView ()
@property (nonatomic, weak) UIImageView *waveImageView;
@property (nonatomic, strong) NSMutableArray *lineArray;
@property (nonatomic, strong) UIImage *aniImage;
@property (nonatomic, strong) UIImage *quietImage;

@end

@implementation JANewPlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.width = 44;
        self.height = 44;
        self.y = JA_StatusBarHeight;
        self.x = JA_SCREEN_WIDTH - self.width;
        self.userInteractionEnabled = YES;
        [self setupNewPlayerViewUI];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(modalStoryPlayViewControl)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - 弹出控制器
- (void)modalStoryPlayViewControl
{
    JAStoryPlayViewController *vc = [[JAStoryPlayViewController alloc] init];
    [[self currentViewController] presentViewController:vc animated:YES completion:nil];
}

#pragma mark - 控制显示和隐藏
- (void)playerView_animateAndHiddenWithViewControl:(UIViewController *)ViewControl
{
//    if (!IS_LOGIN) {
//        self.hidden = YES;
//        return;
//    }
    BOOL isShow = [self checkViewControlWithVC:ViewControl];
    if (isShow) {
        if ([JANewPlayTool shareNewPlayTool].musicList.count) {
            self.hidden = NO;
            self.alpha = 1;
            if ([JANewPlayTool shareNewPlayTool].playType == 1 || [JANewPlayTool shareNewPlayTool].playType == 3) {
                [self beginAnimate];
            }else{
                [self stopAnimate];
            }
        }else{
            self.hidden = YES;
        }
    }else{
        self.hidden = YES;
    }
}


- (void)playerView_animateAndHidden
{
//    if (!IS_LOGIN) {
//        self.hidden = YES;
//        return;
//    }
    BOOL isShow = [self checkViewControlWithVC:[self currentViewController]];
    if (isShow) {
        if ([JANewPlayTool shareNewPlayTool].musicList.count) {
            self.hidden = NO;
            self.alpha = 1;
            if ([JANewPlayTool shareNewPlayTool].playType == 1 || [JANewPlayTool shareNewPlayTool].playType == 3) {
                [self beginAnimate];
            }else{
                [self stopAnimate];
            }
        }else{
            self.hidden = YES;
        }
    }else{
        self.hidden = YES;
    }
}
- (BOOL)checkViewControlWithVC:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[JACenterDrawerViewController class]] ||
        [viewController isKindOfClass:[JAStoryViewController class]] ||
        [viewController isKindOfClass:[JAStoryCircleViewController class]] ||
        [viewController isKindOfClass:[JAMessageViewController class]] ||
        [viewController isKindOfClass:[JAVoiceNotiReplyViewController class]] ||
        [viewController isKindOfClass:[JAsynthesizeMessageViewController class]] ||
        [viewController isKindOfClass:[JAMineViewController class]] ||
        [viewController isKindOfClass:[JAStoryAlbumViewController class]] ||
        [viewController isKindOfClass:[JAAlbumDetailViewController class]] ||
        [viewController isKindOfClass:[JAPostDetailViewController class]] ||
        [viewController isKindOfClass:[JACircleDetailViewController class]] ||
        [viewController isKindOfClass:[JACircleAllStoryListViewController class]] ||
        [viewController isKindOfClass:[JACircleEssenceStoryListViewController class]] ||
        [viewController isKindOfClass:[JACircleInfoViewController class]] ||
        [viewController isKindOfClass:[JAPersonalTaskViewController class]] ||
        [viewController isKindOfClass:[JAActivityCenterViewController class]] ||
        [viewController isKindOfClass:[JADraftViewController class]] ||
        [viewController isKindOfClass:[JANewPersonVoiceViewController class]] ||
        [viewController isKindOfClass:[JANewPersonReplyViewController class]] ||
        [viewController isKindOfClass:[JAPersonStoryAndReplyViewController class]] ||
        [viewController isKindOfClass:[JANewPersonCollectVoiceViewController class]] ||
        [viewController isKindOfClass:[JACollectAlbumViewController class]] ||
        [viewController isKindOfClass:[JACollectViewController class]] ||
        [viewController isKindOfClass:[JASubRelationshipViewController class]] ||
        [viewController isKindOfClass:[JAPersonalCenterViewController class]] ||
        [viewController isKindOfClass:[JASettingViewController class]] ||
        [viewController isKindOfClass:[JAVoiceNotiAgreeViewController class]] ||
        [viewController isKindOfClass:[JAVoiceNotiFocusViewController class]] ||
        [viewController isKindOfClass:[JAVoiceNotiCallMeViewController class]] ||
        [viewController isKindOfClass:[CYLTabBarController class]]) {
        
        // 如果播放列表有值那么展示 音量条
        return YES;
        
    }else{
        return NO;
    }
}

#pragma mark - UI
- (void)setupNewPlayerViewUI
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"music_list_wave" ofType:@"gif"];
    NSData *imageData = [NSData dataWithContentsOfFile:filePath];
    self.aniImage = [UIImage sd_animatedGIFWithData:imageData];
    
    self.quietImage = [UIImage imageNamed:@"music_list_wave_quiet"];
    
    UIImageView *waveImageView = [[UIImageView alloc] init];
    _waveImageView = waveImageView;
    waveImageView.width = 14;
    waveImageView.height = 16;
    waveImageView.centerX = self.width * 0.5;
    waveImageView.centerY = self.height * 0.5;
    waveImageView.image = self.quietImage;
    [self addSubview:waveImageView];
}

- (UIImage *)getRightImage
{
    if ([JANewPlayTool shareNewPlayTool].playType == 1 || [JANewPlayTool shareNewPlayTool].playType == 3) {
        
        return self.aniImage;
        
    }else{
        
        return self.quietImage;
    }
}

-(void)beginAnimate
{
    self.waveImageView.image = [self getRightImage];
}

- (void)stopAnimate
{
    self.waveImageView.image = [self getRightImage];
}

- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    return [self findBestViewController:tab];
}
@end
