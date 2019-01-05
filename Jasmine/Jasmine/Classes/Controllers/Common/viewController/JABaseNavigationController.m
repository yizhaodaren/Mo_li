//
//  JABaseNavigationController.m
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseNavigationController.h"

//#import "UIImage+ImageEffects.h"

#define IMG(name) [UIImage imageNamed:name]
#import "JAVoiceRecordViewController.h"
#import "JASessionViewController.h"
#import "JACreditViewController.h"
#import "JAWithDrawViewController.h"
#import "JAPersonalLevelViewController.h"


@interface JABaseNavigationController ()<UINavigationControllerDelegate>

@property(nonatomic,weak)   UIViewController * currentShowVC;

@end

@implementation JABaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
//    __weak JABaseNavigationController* wself = self;
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.interactivePopGestureRecognizer.delegate = wself;
//        self.delegate = wself;
//    }
    
    // 单纯填颜色
    self.navigationBar.barTintColor = [UIColor clearColor];//HEX_COLOR(0xF7F7F7);
    self.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationBar.translucent = NO;
    
    // 背景图片
    //    [self.navigationBar setBackgroundImage:IMG(@"nav-bg") forBarMetrics:UIBarMetricsDefault];
    //    self.navigationBar.clipsToBounds = YES;
    [self setNavigationBarLineHidden:NO];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        [super pushViewController:viewController animated:animated];
        return;
    }
    if ([viewController isKindOfClass:[JAVoiceRecordViewController class]]) {
        // 发帖优先级：禁言>信用>等级
        if ([JAAPPManager app_checkGag]) {
            return;
        }
//        NSInteger creditValue = [[JAUserInfo userInfo_getUserImfoWithKey:User_score] integerValue];
//        JARuleModel *ruleModel = [JAAPPManager currentAddStoryCommentScore];
//        if (creditValue < [ruleModel.num integerValue]) {
//            [self showAlertViewWithTitle:nil subTitle:[NSString stringWithFormat:@"您的信用分为%zd，无法发布主帖和回复，提升信用分至%@后，将恢复正常使用。" ,creditValue ,ruleModel.num] leftButtonTitle:@"查看信用分" rightButtonTitle:@"我知道了" completion:^(BOOL complete) {
//                if (complete) {
//
//                } else {
//                    JACreditViewController *creditVC = [JACreditViewController new];
//                    [super pushViewController:creditVC animated:animated];
//                }
//            }];
//            return;
//        }
//        JAVoiceRecordViewController *vc = (JAVoiceRecordViewController *)viewController;
//        if (vc.fromType == 0) {
//            if (![JAAPPManager app_checkCanReleaseStory]) {
//                // 如果发帖数达到最大值，判断是否为今天，重新拉取数据
//                [JAAPPManager app_getReleaseStoryCount];
//                NSInteger currentLevel = [[JAUserInfo userInfo_getUserImfoWithKey:User_LevelId] integerValue];
//                JALevelModel *currentModel = [JAAPPManager currentLevel];
//                if (currentModel) {
//                    [self showAlertViewWithTitle:nil subTitle:[NSString stringWithFormat:@"您的等级为Lv%zd，每天最多只能发布%@个主帖，提升等级可解锁更多特权。" ,currentLevel,currentModel.rightsNum] leftButtonTitle:@"查看等级特权" rightButtonTitle:@"我知道了" completion:^(BOOL complete) {
//                        if (complete) {
//
//                        } else {
//                            JAPersonalLevelViewController *creditVC = [JAPersonalLevelViewController new];
//                            [super pushViewController:creditVC animated:animated];
//                        }
//                    }];
//                    return;
//                }
//            }
//        }
    } else if ([viewController isKindOfClass:[JASessionViewController class]]) {
        JASessionViewController *vc = (JASessionViewController *)viewController;
        if (!vc.isSecretary) {
            // 非小秘书的处理
            if ([JAAPPManager app_checkGag]) {
                return;
            }
//            NSInteger creditValue = [[JAUserInfo userInfo_getUserImfoWithKey:User_score] integerValue];
//            JARuleModel *ruleModel = [JAAPPManager currentUserMsgScore];
//            if (creditValue < [ruleModel.num integerValue]) {
//                [self showAlertViewWithTitle:nil subTitle:[NSString stringWithFormat:@"您的信用分为%zd，无法发送私信，提升信用分至%@后，将恢复正常使用。" ,creditValue ,ruleModel.num] leftButtonTitle:@"查看信用分" rightButtonTitle:@"我知道了" completion:^(BOOL complete) {
//                    if (complete) {
//
//                    } else {
//                        JACreditViewController *creditVC = [JACreditViewController new];
//                        [super pushViewController:creditVC animated:animated];
//                    }
//                }];
//                return;
//            }
        }
    } else if ([viewController isKindOfClass:[JAWithDrawViewController class]]) {
//        NSInteger creditValue = [[JAUserInfo userInfo_getUserImfoWithKey:User_score] integerValue];
//        JARuleModel *ruleModel = [JAAPPManager currentNotDepositScore];
//        if (creditValue < [ruleModel.num integerValue]) {
//            [self showAlertViewWithTitle:nil subTitle:[NSString stringWithFormat:@"您的信用分为%zd，无法申请提现,提升信用分至%@后，将恢复正常使用。" ,creditValue ,ruleModel.num] leftButtonTitle:@"查看信用分" rightButtonTitle:@"我知道了" completion:^(BOOL complete) {
//                if (complete) {
//
//                } else {
//                    JACreditViewController *creditVC = [JACreditViewController new];
//                    [super pushViewController:creditVC animated:animated];
//                }
//            }];
//            return;
//        }
    }

    [super pushViewController:viewController animated:animated];
}


- (UIViewController *) popViewControllerAnimated:(BOOL)animated
{
    return [super popViewControllerAnimated:animated];
}

// 记录当前的偏移量
static CGPoint contentOffsetPrevious = {0, 0};

-(void)scrollViewDidScroll:(UIScrollView*)scrollView {
    
    if (!scrollView.isDragging) {
        return;
    }
    
    CGPoint currentOffset = scrollView.contentOffset;
    CGSize contentSize = scrollView.contentSize;
    
    // 如果到达顶部，显示TabBar
    if (currentOffset.y <= 0) {
        contentOffsetPrevious.y = 0;
        [self setTabbarHidden:NO];
        return;
    }
    // 列表滚动到底部，向上拖拽
    else if (contentSize.height - currentOffset.y <= scrollView.height) {
        contentOffsetPrevious.y = contentSize.height - currentOffset.y;
        [self setTabbarHidden:YES];
        return;
    }
    
    CGFloat offset = currentOffset.y - contentOffsetPrevious.y;
    contentOffsetPrevious = currentOffset;
    
    // 根据列表滚动方向设置tabbar显示或者隐藏
    // 向上滑动
    if (offset > 0) {
        [self setTabbarHidden:YES];
    } else {
        [self setTabbarHidden:NO];
    }
}

- (void)setTabbarHidden:(BOOL)hidden {
    
    // 隐藏
    if (hidden && // 要隐藏
        self.navigationBar.hidden == NO // 已经显示了
        )
    {
        [self setNavigationBarHidden:YES animated:YES];
        
    }
    
    // 显示
    else if (!hidden && // 要显示
             self.navigationBar.hidden == YES // 已经隐藏了
             ) {
        
        [self setNavigationBarHidden:NO animated:YES];
    }
    
    else {
        
        return;
    }
    
}

/**
 * 配置navigation bar 背景图片 设置线是否隐藏
 */
- (void)setNavigationBarLineHidden:(BOOL)hidden
{
    CGSize size = self.navigationBar.bounds.size;
    const CGFloat locations[2] = {0,1};
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(JA_Background)]
                            forBarPosition:UIBarPositionAny
                                barMetrics:UIBarMetricsDefault];
    if (hidden) {
        [self.navigationBar setShadowImage:[UIImage new]];
    }
    else
    {
        const CGFloat R = 1.0*0xe0/0xff, G = 1.0*0xe0/0xff, B = 1.0*0xe0/0xff;
        const CGFloat components[4] = {
            R,G,B,1,
        };
        size.height = 0.5;
        UIImage *lineImage = [UIImage gradientImageWithSize:size
                                                  locations:locations
                                                 components:components
                                                      count:1];
        [self.navigationBar setShadowImage:lineImage];
    }
}
#pragma mark UINavigationControllerDelegate

//- (void)navigationController:(UINavigationController *)navigationController
//       didShowViewController:(UIViewController *)viewController
//                    animated:(BOOL)animated
//{
//    // Enable the gesture again once the new controller is shown
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        self.interactivePopGestureRecognizer.enabled = YES;
//    }
//    
//    if (navigationController.viewControllers.count == 1)
//    {
//        self.currentShowVC = nil;
//    }
//    else
//    {
//        self.currentShowVC = viewController;
//    }
//}
//
//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
//{
//    if (self.currentShowVC.ja_interactivePopDisabled) {
//        return NO;
//    }
//    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
//    {
//        if (gestureRecognizer == self.interactivePopGestureRecognizer)
//        {
//            return (self.currentShowVC == self.topViewController); //the most important
//        }
//    }
//    return YES;
//}

//- (UIScreenEdgePanGestureRecognizer *)screenEdgePanGestureRecognizer
//{
//    UIScreenEdgePanGestureRecognizer *screenEdgePanGestureRecognizer = nil;
//    if (self.view.gestureRecognizers.count > 0)
//    {
//        for (UIGestureRecognizer *recognizer in self.view.gestureRecognizers)
//        {
//            if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
//            {
//                screenEdgePanGestureRecognizer = (UIScreenEdgePanGestureRecognizer *)recognizer;
//                break;
//            }
//        }
//    }
//    return screenEdgePanGestureRecognizer;
//}

//- (NSArray<UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
//{
//    NSLog(@"=====");
//    return nil;
//}
@end
