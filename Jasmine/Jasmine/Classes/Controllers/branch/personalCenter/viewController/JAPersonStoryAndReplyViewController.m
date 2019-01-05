//
//  JAPersonStoryAndReplyViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/5.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonStoryAndReplyViewController.h"

#import "SPPageMenu.h"
#import "JAHorizontalPageView.h"

#import "JANewPersonVoiceViewController.h"
#import "JANewPersonReplyViewController.h"

@interface JAPersonStoryAndReplyViewController ()<SPPageMenuDelegate,JAHorizontalPageViewDelegate>
@property (nonatomic, strong) JAHorizontalPageView *pageView;
@property (nonatomic, weak) SPPageMenu *titleView;

@property (nonatomic, strong) NSString *storyCountStr;
@property (nonatomic, strong) NSString *replyCountStr;
@end

@implementation JAPersonStoryAndReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"发表"];
    
    self.storyCountStr = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_storyCount]];
    self.replyCountStr = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_commentCount]];
    
    [self setupUI];
    [self.pageView reloadPage];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.storyCountStr = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_storyCount]];
    self.replyCountStr = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_commentCount]];
    NSString *title = [NSString stringWithFormat:@"主帖(%ld)",self.storyCountStr.integerValue];
    [self.titleView setTitle:title forItemAtIndex:0];
    NSString *title1 = [NSString stringWithFormat:@"回复(%ld)",self.replyCountStr.integerValue];
    [self.titleView setTitle:title1 forItemAtIndex:1];
}

#pragma mark - JAHorizontalPageView懒加载
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 20, size.width, size.height - JA_StatusBarAndNavigationBarHeight - JA_TabbarSafeBottomMargin - 40) delegate:self];
        _pageView.needHeadGestures = NO;
        [self.view addSubview:_pageView];
    }
    
    return _pageView;
}

#pragma mark - JAHorizontalPageView代理
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return 2;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if (index == 0) {
        JANewPersonVoiceViewController *vc = [[JANewPersonVoiceViewController alloc] init];
        vc.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        vc.sex = [[JAUserInfo userInfo_getUserImfoWithKey:User_Sex] integerValue];
        vc.enterType = 1;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }else{
        
        JANewPersonReplyViewController *vc = [[JANewPersonReplyViewController alloc] init];
        vc.userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        vc.sex = [[JAUserInfo userInfo_getUserImfoWithKey:User_Sex] integerValue];
        vc.enterType = 1;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }
    
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    return nil;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return 0;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView   // 控制在什么地方悬停
{
    return 0;
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{}

- (void)setupUI
{
    // 分页tab
    NSString *title1 = [NSString stringWithFormat:@"主帖(%@)",self.storyCountStr];
    NSString *title2 = [NSString stringWithFormat:@"回复(%@)",self.replyCountStr];
    
    NSArray *titles = @[title1,title2];
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    [pageMenu setItems:titles selectedItemIndex:0];
    pageMenu.delegate = self;
    pageMenu.itemTitleFont = JA_REGULAR_FONT(15);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    [self.view addSubview:pageMenu];
    self.titleView = pageMenu;
    [self.view addSubview:self.titleView];
}

#pragma mark - SPPageMenu
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.pageView scrollToIndex:toIndex];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
