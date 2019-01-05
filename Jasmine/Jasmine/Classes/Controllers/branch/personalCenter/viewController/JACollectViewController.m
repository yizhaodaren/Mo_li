//
//  JACollectViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACollectViewController.h"
#import "JANewPersonCollectVoiceViewController.h"
#import "JACollectAlbumViewController.h"

#import "JAHorizontalPageView.h"

@interface JACollectViewController () <SPPageMenuDelegate,JAHorizontalPageViewDelegate>
@property (nonatomic, weak) SPPageMenu *titleView;

@property (nonatomic, strong) JAHorizontalPageView *pageView;
@end

@implementation JACollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCenterTitle:@"我的收藏"];

    // 分页tab
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 44) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    });
    pageMenu.delegate = self;
    pageMenu.itemTitleFont = JA_REGULAR_FONT(17);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    self.titleView = pageMenu;
    self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    [self.titleView setItems:@[@"专辑",@"主帖"] selectedItemIndex:0];
    [self.view addSubview:self.titleView];
    
    [self.pageView reloadPage];
}

- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return 2;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if (index == 0) {
        JACollectAlbumViewController *vc1 = [JACollectAlbumViewController new];
        [self addChildViewController:vc1];
        return (UIScrollView *)vc1.view;
    }else{
        
        JANewPersonCollectVoiceViewController *vc2 = [[JANewPersonCollectVoiceViewController alloc]init];
        [self addChildViewController:vc2];
        return (UIScrollView *)vc2.view;
    }
    
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{return nil;}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{return 0;}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView   // 控制在什么地方悬停
{return 0;}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{}

#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self.pageView scrollToIndex:toIndex];
}

- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 22, size.width, size.height - JA_StatusBarAndNavigationBarHeight - JA_TabbarSafeBottomMargin - 44) delegate:self];
        [self.view addSubview:_pageView];
    }
    
    return _pageView;
}
@end
