//
//  JAHelperViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAHelperViewController.h"
#import "JAGuidebookViewController.h"
#import "JAGuidevideoViewController.h"
#import "JABaseViewController+QiYuSDK.h"

@interface JAHelperViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIButton *questionButton;
@property (nonatomic, weak) UIButton *videoButton;
@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIView *greenLine;
@end


@implementation JAHelperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavRightTitle:@"去反馈" color:HEX_COLOR(JA_Green)];
    [self setCenterTitle:@"帮助中心"];
    
    [self setupHelperUI];
    
}


- (void)setupHelperUI
{
    // 创建顶部试图
//    UIView *topView = [[UIView alloc] init];
//    _topView = topView;
//    topView.width = JA_SCREEN_WIDTH;
//    topView.height = 50;
//    topView.backgroundColor = [UIColor whiteColor];
//    [self.view addSubview:topView];
//
//    UIButton *questionButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _questionButton = questionButton;
//    [questionButton setImage:[UIImage imageNamed:@"guideBook_selecte"] forState:UIControlStateNormal];
//    [questionButton setImage:[UIImage imageNamed:@"guideBook_selected"] forState:UIControlStateSelected];
//    [questionButton setTitle:@"常见问题" forState:UIControlStateNormal];
//    [questionButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
//    [questionButton setTitleColor:HEX_COLOR(0x31C27C) forState:UIControlStateSelected];
//    questionButton.titleLabel.font = JA_REGULAR_FONT(17);
//    questionButton.width = topView.width * 0.5;
//    questionButton.height = topView.height;
//    questionButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//    [questionButton addTarget:self action:@selector(clickQuestionButton:) forControlEvents:UIControlEventTouchUpInside];
//    questionButton.selected = YES;
//    [topView addSubview:questionButton];
//
//    UIButton *videoButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _videoButton = videoButton;
//    [videoButton setImage:[UIImage imageNamed:@"guidevideo_selecte"] forState:UIControlStateNormal];
//    [videoButton setImage:[UIImage imageNamed:@"guidevideo_selected"] forState:UIControlStateSelected];
//    [videoButton setTitle:@"视频教程" forState:UIControlStateNormal];
//    [videoButton setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
//    [videoButton setTitleColor:HEX_COLOR(0x31C27C) forState:UIControlStateSelected];
//    videoButton.titleLabel.font = JA_REGULAR_FONT(17);
//    videoButton.width = topView.width * 0.5;
//    videoButton.height = topView.height;
//    videoButton.x = videoButton.width;
//    videoButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
//    [videoButton addTarget:self action:@selector(clickVideoButton:) forControlEvents:UIControlEventTouchUpInside];
//    [topView addSubview:videoButton];
//
//    UIView *lineView = [[UIView alloc] init];
//    _lineView = lineView;
//    lineView.backgroundColor = HEX_COLOR(JA_Line);
//    lineView.width = JA_SCREEN_WIDTH;
//    lineView.height = 1;
//    lineView.y = topView.height - 1;
//    [topView addSubview:lineView];
//
//    UIView *greenLine = [[UIView alloc] init];
//    _greenLine = greenLine;
//    greenLine.backgroundColor = HEX_COLOR(JA_Green);
//    greenLine.width = topView.width * 0.5;
//    greenLine.height = 3;
//    greenLine.x = 0;
//    greenLine.y = topView.height - 3;
//    [topView addSubview:greenLine];
//
//    UIScrollView *scrollView = [[UIScrollView alloc] init];
//    _scrollView = scrollView;
//    scrollView.width = JA_SCREEN_WIDTH;
//    scrollView.height = self.view.height - 50 - 64;
//    scrollView.y = 50;
//    scrollView.backgroundColor = [UIColor greenColor];
//    scrollView.pagingEnabled = YES;
//    scrollView.bounces = NO;
//    scrollView.contentSize = CGSizeMake(JA_SCREEN_WIDTH, 0);
//    scrollView.showsHorizontalScrollIndicator = NO;
//    scrollView.delegate = self;
//    [self.view addSubview:scrollView];
    
    JAGuidebookViewController *bookVc = [[JAGuidebookViewController alloc] init];
    bookVc.view.frame = self.view.bounds;
    [self.view addSubview:bookVc.view];
    [self addChildViewController:bookVc];
    
//    JAGuidevideoViewController *videoVc = [[JAGuidevideoViewController alloc] init];
//    videoVc.view.frame = scrollView.bounds;
//    videoVc.view.x = JA_SCREEN_WIDTH;
//    [scrollView addSubview:videoVc.view];
//    [self addChildViewController:videoVc];
    
//    if (self.currentIndex == 0) {
//
//        [self clickQuestionButton:self.questionButton];
//    }else{
//
//        [self clickVideoButton:self.videoButton];
//    }
}

// 点击新手教程
//- (void)clickQuestionButton:(UIButton *)btn
//{
//    self.videoButton.selected = NO;
//    self.questionButton.selected = YES;
//    self.greenLine.centerX = btn.centerX;
//    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[JA_Property_ScreenName] = @"常见问题";
//    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
//}

// 点击视频教程
//- (void)clickVideoButton:(UIButton *)btn
//{
//    self.videoButton.selected = YES;
//    self.questionButton.selected = NO;
//    self.greenLine.centerX = btn.centerX;
//    [self.scrollView setContentOffset:CGPointMake(JA_SCREEN_WIDTH, 0) animated:NO];
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[JA_Property_ScreenName] = @"视频教程";
//    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
//}

//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    [UIView animateWithDuration:0.2 animations:^{
//
//        self.greenLine.centerX = scrollView.contentOffset.x == JA_SCREEN_WIDTH ? self.videoButton.centerX : self.questionButton.centerX;
//    }];
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    if (scrollView.contentOffset.x == JA_SCREEN_WIDTH) {
//        params[JA_Property_ScreenName] = @"视频教程";
//    } else {
//        params[JA_Property_ScreenName] = @"常见问题";
//    }
//    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
//}

- (void)actionRight
{
    [self setupQiYuViewController];
}

@end
