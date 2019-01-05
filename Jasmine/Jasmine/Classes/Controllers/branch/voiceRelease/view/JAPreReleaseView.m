//
//  JAPreReleaseView.m
//  Jasmine
//
//  Created by xujin on 2018/5/28.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAPreReleaseView.h"
#import "JAVoiceRecordViewController.h"
#import "JAVoiceReleaseViewController.h"
#import "CYLTabBarController.h"

@interface JAPreReleaseView ()

@property (nonatomic, strong) UIButton *picButton;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation JAPreReleaseView

+ (void)showPreReleaseView {
    [self showPreReleaseViewWithTopic:nil circle:nil];
}

+ (void)showPreReleaseViewWithTopic:(JAVoiceTopicModel *)topicModel {
    [self showPreReleaseViewWithTopic:topicModel circle:nil];
}

+ (void)showPreReleaseViewWithCircle:(JACircleModel *)circleModel {
    [self showPreReleaseViewWithTopic:nil circle:circleModel];
}

+ (void)showPreReleaseViewWithTopic:(JAVoiceTopicModel *)topicModel circle:(JACircleModel *)circleModel {
    JAPreReleaseView *view = [[JAPreReleaseView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    view.topicModel = topicModel;
    view.circleModel = circleModel;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:view];
    [UIView animateWithDuration:0.3 animations:^{
        view.maskView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
        view.contentView.y = view.height-view.contentView.height;
    }];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *maskView = [UIView new];
        [self addSubview:maskView];
        self.maskView = maskView;
        self.maskView.frame = self.bounds;
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonAction)]];
        
        UIView *contentView = [UIView new];
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        self.contentView = contentView;
        self.contentView.width = self.width;
        self.contentView.height = 220+JA_TabbarSafeBottomMargin;
        self.contentView.y = self.height;
        
        UIButton *picButton = [UIButton buttonWithType:UIButtonTypeCustom];
        picButton.titleLabel.font = JA_MEDIUM_FONT(15);
        [picButton setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateNormal];
        [picButton setTitle:@"发文字帖" forState:UIControlStateNormal];
        [picButton setImage:[UIImage imageNamed:@"release_pre_pic"] forState:UIControlStateNormal];
        [picButton setImage:[UIImage imageNamed:@"release_pre_pic"] forState:UIControlStateHighlighted];
        [picButton addTarget:self action:@selector(picButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:picButton];
        self.picButton = picButton;
        self.picButton.width = 80;
        self.picButton.height = 100;
        self.picButton.y = 50;
        self.picButton.centerX = self.width/2.0-75;
        [picButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:8];

        UIButton *voiceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        voiceButton.titleLabel.font = JA_MEDIUM_FONT(15);
        [voiceButton setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateNormal];
        [voiceButton setTitle:@"发语音帖" forState:UIControlStateNormal];
        [voiceButton setImage:[UIImage imageNamed:@"release_pre_voice"] forState:UIControlStateNormal];
        [voiceButton setImage:[UIImage imageNamed:@"release_pre_voice"] forState:UIControlStateHighlighted];
        [voiceButton addTarget:self action:@selector(voiceButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:voiceButton];
        self.voiceButton = voiceButton;
        self.voiceButton.width = 80;
        self.voiceButton.height = 100;
        self.voiceButton.y = self.picButton.y;
        self.voiceButton.centerX = self.width/2.0+75;
        [voiceButton setButtonImageTitleStyle:ButtonImageTitleStyleTop padding:8];

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"release_pre_close"] forState:UIControlStateNormal];
        [closeButton setImage:[UIImage imageNamed:@"release_pre_close"] forState:UIControlStateHighlighted];
        [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:closeButton];
        closeButton.width = closeButton.height = 44;
        closeButton.bottom = self.contentView.height-JA_TabbarSafeBottomMargin;
        closeButton.centerX = self.width/2.0;
    }
    return self;
}

- (void)picButtonAction {
    [self closeButtonAction];
    if ([JAAPPManager app_checkGag]) {
        return;
    }
    
    JAVoiceReleaseViewController *vc = [JAVoiceReleaseViewController new];
    vc.storyType = 1;
    vc.circleModel = self.circleModel;
    vc.topicModel = self.topicModel;
    [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
}

- (void)voiceButtonAction {
    [self closeButtonAction];
    
    JAVoiceRecordViewController *vc = [JAVoiceRecordViewController new];
    vc.storyType = 0;
    vc.circleModel = self.circleModel;
    vc.topicModel = self.topicModel;
    [[self cyl_tabBarController].selectedViewController pushViewController:vc animated:YES];
}

- (void)closeButtonAction {
    [UIView animateWithDuration:0.3 animations:^{
        self.contentView.y = self.height;
        self.maskView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

@end
