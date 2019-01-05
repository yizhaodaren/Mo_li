//
//  JANewSearchResultViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANewSearchResultViewController.h"
#import "SPPageMenu.h"
#import "JAHorizontalPageView.h"
#import "JASearchTopView.h"

#import "JANewSearchAllViewController.h"
#import "JANewSearchPostsViewController.h"
#import "JANewSearchPersonViewController.h"
#import "JANewSearchTopicViewController.h"
#import "JANewSearchViewController.h"

@interface JANewSearchResultViewController ()<SPPageMenuDelegate,JAHorizontalPageViewDelegate,UITextFieldDelegate>
@property (nonatomic, strong) JASearchTopView *topView;
@property (nonatomic, weak) SPPageMenu *titleView;
@property (nonatomic, strong) JAHorizontalPageView *pageView;

@end

@implementation JANewSearchResultViewController

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNewSearchResultUI];
    
    [self.pageView reloadPage];
    self.pageView.y = self.titleView.bottom;
    [self.pageView scrollToIndex:self.selectIndex animation:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollPersonPage) name:@"scrollPerson" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollTopicPage) name:@"scrollTopic" object:nil];
}

- (void)scrollPersonPage  // 用户
{
    [self.pageView scrollToIndex:1];
    self.titleView.selectedItemIndex = 1;
}

- (void)scrollTopicPage  // 话题
{
    [self.pageView scrollToIndex:2];
    self.titleView.selectedItemIndex = 2;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 设置UI
- (void)setupNewSearchResultUI
{
    self.topView = [JASearchTopView searchTopView];
    if (iPhoneX) {
        self.topView.y = 24;
    }
    self.topView.backgroundColor = HEX_COLOR(JA_Background);
    [self.view addSubview:self.topView];
    
    self.topView.searchTextField.delegate = self;
    [self.topView.searchCancleButton addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.searchTextField addTarget:self action:@selector(inputBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
    self.topView.searchTextField.text = self.keyWord;
    
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, self.topView.bottom, JA_SCREEN_WIDTH, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pageMenu.delegate = self;
    });
    pageMenu.itemTitleFont = JA_REGULAR_FONT(17);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    self.titleView = pageMenu;
    [self.view addSubview:pageMenu];
    self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
//    NSArray *titleArr = @[@"综合",@"帖子",@"话题",@"用户"];
    NSArray *titleArr = @[@"综合",@"用户",@"话题",@"帖子"];
    [self.titleView setItems:titleArr selectedItemIndex:self.selectIndex];
    
}

#pragma mark - textView
- (void)inputBeginEdit:(UITextField *)textF
{
    // 神策数据
    [JASensorsAnalyticsManager sensorsAnalytics_clickSearch:nil];
    NSInteger ind = [self.navigationController.childViewControllers indexOfObject:self];
    UIViewController *vc = self.navigationController.childViewControllers[ind - 1];
    if ([vc isKindOfClass:[JANewSearchViewController class]]) {
        JANewSearchViewController *popVc = (JANewSearchViewController *)vc;
        popVc.pushIndex = self.titleView.selectedItemIndex;
    }
    [self.navigationController popViewControllerAnimated:NO];
}

// 取消按钮
- (void)cancleButtonClick
{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

#pragma mark - JAHorizontalPageView代理
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
//    return 2;
    return 4;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
//    if (index == 0){
//
//        JANewSearchPostsViewController *vc = [[JANewSearchPostsViewController alloc]init];
//        vc.keyWord = self.keyWord;
//        vc.clickHistory = self.clickHistory;
//        [self addChildViewController:vc];
//        return (UIScrollView *)vc.view;
//    }else{
//
//        JANewSearchPersonViewController *vc = [[JANewSearchPersonViewController alloc]init];
//        vc.keyWord = self.keyWord;
//        vc.clickHistory = self.clickHistory;
//        [self addChildViewController:vc];
//        return (UIScrollView *)vc.view;
//    }
    if (index == 0) {
        JANewSearchAllViewController *vc = [JANewSearchAllViewController new];
        vc.keyWord = self.keyWord;
        vc.clickHistory = self.clickHistory;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }else if (index == 3){

        JANewSearchPostsViewController *vc = [[JANewSearchPostsViewController alloc]init];
        vc.keyWord = self.keyWord;
        vc.clickHistory = self.clickHistory;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }else if (index == 2){
     
        JANewSearchTopicViewController *vc = [[JANewSearchTopicViewController alloc]init];
        vc.keyWord = self.keyWord;
        vc.clickHistory = self.clickHistory;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }else{

        JANewSearchPersonViewController *vc = [[JANewSearchPersonViewController alloc]init];
        vc.keyWord = self.keyWord;
        vc.clickHistory = self.clickHistory;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    return [UIView new];
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return 0;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView
{
    return 0;
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{
}

#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self.pageView scrollToIndex:toIndex];
}

#pragma mark - JAHorizontalPageView懒加载
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - self.titleView.bottom) delegate:self];
        _pageView.needHeadGestures = YES;
        [self.view addSubview:_pageView];
    }
    
    return _pageView;
}

@end
