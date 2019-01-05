//
//  JAInviteViewController.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAInviteViewController.h"
#import "JASegmentView.h"
#import "JAInviteFriendViewController.h"
#import "JAInviteRecommendViewController.h"
#import "JAInviteModel.h"

#import "FSSegmentTitleView.h"
#import "FSScrollContentView.h"

@interface JAInviteViewController ()<FSPageContentViewDelegate,FSSegmentTitleViewDelegate>

@property (nonatomic, strong) JASegmentView *segmentView;

@property (nonatomic) JAHorizonalTableView  *pageView;

@property (nonatomic, strong) JAInviteFriendViewController *friendVC;
@property (nonatomic, strong) JAInviteRecommendViewController *recommendVC;

@property (nonatomic, strong) JAInviteModel *model;


@property (nonatomic, strong) FSSegmentTitleView *titleView;
@property (nonatomic, strong) FSPageContentView *contentView;

@end

@implementation JAInviteViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    JAInviteModel *model = [[JAInviteModel alloc] init];
    model.typeId = self.typeId;
    self.model = model;

    
    NSMutableArray *titles = [NSMutableArray new];
    [titles addObject:@"推荐"];
    [titles addObject:@"关注"];
    self.titleView = [[FSSegmentTitleView alloc] initWithFrame:CGRectMake(0, 64, 150, 45)
                                                        titles:titles
                                                      delegate:self
                                                 indicatorType:FSIndicatorTypeCustom];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.titleFont = JA_REGULAR_FONT(15);
    self.titleView.titleSelectFont = JA_REGULAR_FONT(15);
    self.titleView.titleNormalColor = HEX_COLOR(JA_BlackTitle);
    self.titleView.titleSelectColor = HEX_COLOR(JA_Green);
    self.navigationItem.titleView = self.titleView;
    
    NSMutableArray *contentVCs = [NSMutableArray new];
    JAInviteRecommendViewController *recommendVC = [[JAInviteRecommendViewController alloc] init];
    _recommendVC = recommendVC;
    _recommendVC.inviteModel = self.inviteModel;
    _recommendVC.model = self.model;
    _recommendVC.view.hidden = NO;
    JAInviteFriendViewController *friendVC = [[JAInviteFriendViewController alloc] init];
    _friendVC = friendVC;
    _friendVC.inviteModel = self.inviteModel;
    _friendVC.model = self.model;
    _friendVC.view.hidden = NO;
    [contentVCs addObject:recommendVC];
    [contentVCs addObject:friendVC];
    self.contentView = [[FSPageContentView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT - 64)
                                                       childVCs:contentVCs
                                                       parentVC:self
                                                       delegate:self];
    
    [self.view addSubview:self.contentView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.titleView.selectIndex == 1) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请回复-关注";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }else{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请回复-推荐";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }
}

#pragma mark FSSegmentTitleViewDelegate
- (void)FSContenViewDidEndDecelerating:(FSPageContentView *)contentView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.titleView.selectIndex = endIndex;
    
    if (endIndex == 1) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请回复-关注";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }else{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请回复-推荐";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }
}

- (void)FSSegmentTitleView:(FSSegmentTitleView *)titleView startIndex:(NSInteger)startIndex endIndex:(NSInteger)endIndex
{
    self.contentView.contentViewCurrentIndex = endIndex;
    if (endIndex == 1) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请回复-关注";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }else{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"邀请回复-推荐";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }
}



@end
