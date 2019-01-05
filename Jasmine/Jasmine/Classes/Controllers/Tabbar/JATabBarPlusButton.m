//
//  JATabBarPlusButton.m
//  Jasmine
//
//  Created by xujin on 2018/5/3.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JATabBarPlusButton.h"
#import "CYLTabBarController.h"
#import "JAPreReleaseView.h"
#import "JAReleasePostManager.h"

@interface JATabBarPlusButton () {
    CGFloat _buttonImageHeight;
}
@end
@implementation JATabBarPlusButton

#pragma mark -
#pragma mark - Life Cycle

-(instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        //        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        //        self.adjustsImageWhenHighlighted = NO;
    }
    
    return self;
}



#pragma mark -
#pragma mark - Public Methods

/*
 *
 Create a custom UIButton without title and add it to the center of our tab bar
 *
 */
+ (instancetype)plusButton
{
    
    UIImage *buttonImage = [UIImage imageNamed:@"tabbar_post_nor"];
//    UIImage *highlightImage = [UIImage imageNamed:@"tabbar_post_nor"];
    UIImage *iconImage = [UIImage imageNamed:@"tabbar_post_nor"];
    UIImage *highlightIconImage = [UIImage imageNamed:@"tabbar_post_nor"];
    
    JATabBarPlusButton *button = [JATabBarPlusButton buttonWithType:UIButtonTypeCustom];
    
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, JA_SCREEN_WIDTH / 5, buttonImage.size.height);
    [button setImage:iconImage forState:UIControlStateNormal];
    [button setImage:highlightIconImage forState:UIControlStateHighlighted];
//    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
//    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [button addTarget:button action:@selector(clickPublish) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

#pragma mark -
#pragma mark - Event Response

- (void)clickPublish {
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_BindingType] = @"发帖";
        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
        return;
    }
    if ([JAReleasePostManager shareInstance].postDraftModel.uploadState == JAUploadUploadingState) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"你有帖子正在上传中，请上传完毕后再发帖"];
        return;
    }
    [JAPreReleaseView showPreReleaseView];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"buttonIndex = %ld", buttonIndex);
}

//+ (NSUInteger)indexOfPlusButtonInTabBar {
//    return 3;
//}

//+ (CGFloat)multiplerInCenterY {
//    return  0.5;
//}

+ (CGFloat)constantOfPlusButtonCenterYOffsetForTabBarHeight:(CGFloat)tabBarHeight {
    return -JA_TabbarSafeBottomMargin/2.0;
}

@end

