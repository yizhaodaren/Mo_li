//
//  JAAdminViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/15.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAdminViewController.h"
#import "JACheckPostsViewController.h"
#import "JACheckCommentViewController.h"
#import "SPPageMenu.h"

@interface JAAdminViewController ()<SPPageMenuDelegate>

@property (nonatomic, strong) JACheckPostsViewController *postsVC;
@property (nonatomic, strong) JACheckCommentViewController *commentVC;

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, weak) SPPageMenu *titleView;


@end

@implementation JAAdminViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *string = self.checkTag == 1 ? @"待推荐区" : @"敏感词区";
    [self setCenterTitle:string];
    
    NSString *right = self.checkTag == 1 ? @"敏感词区" : @"待推荐区";
    [self setNavRightTitle:right color:HEX_COLOR(JA_Green)];
    
    [self setupUI];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.titleView.width = JA_SCREEN_WIDTH;
    self.titleView.height = (iPhone4 || iPhone5) ? 35 : 40;
    
    self.scrollView.width = JA_SCREEN_WIDTH;
    self.scrollView.height = self.view.height - self.titleView.bottom;
    self.scrollView.contentSize = CGSizeMake(2 * JA_SCREEN_WIDTH, 0);
    self.scrollView.y = self.titleView.bottom;
    
    self.postsVC.view.width = self.scrollView.width;
    self.postsVC.view.height = self.scrollView.height;
    
    self.commentVC.view.width = self.scrollView.width;
    self.commentVC.view.height = self.scrollView.height;
    self.commentVC.view.x = self.scrollView.width;
}

- (void)setupUI
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    scrollView.pagingEnabled = YES;
    [self.view addSubview:scrollView];
    
    NSArray *titles = @[@"主帖",@"回复"];
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    [pageMenu setItems:titles selectedItemIndex:0];
    pageMenu.delegate = self;
    pageMenu.itemTitleFont = JA_REGULAR_FONT(15);
    pageMenu.selectedItemTitleColor = HEX_COLOR(JA_Green);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(JA_BlackTitle);
    pageMenu.bridgeScrollView = scrollView;
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollEqualWidths;
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    [self.view addSubview:pageMenu];
    self.titleView = pageMenu;
    
    [self addChildViewController:self.postsVC];
    [self addChildViewController:self.commentVC];
    
    [self.scrollView addSubview:self.postsVC.view];
    [self.scrollView addSubview:self.commentVC.view];
}

- (JACheckPostsViewController *)postsVC
{
    if (_postsVC == nil) {
        
        JACheckPostsViewController *vc = [[JACheckPostsViewController alloc] init];
        _postsVC = vc;
        vc.checkTag = self.checkTag;
        vc.pageMenu = self.titleView;
    }
    return _postsVC;
}

- (JACheckCommentViewController *)commentVC
{
    if (_commentVC == nil) {
        JACheckCommentViewController *vc = [[JACheckCommentViewController alloc] init];
        _commentVC = vc;
        vc.checkTag = self.checkTag;
        vc.pageMenu = self.titleView;
    }
    
    return _commentVC;
}

- (void)actionRight
{
    if (self.checkTag == 1) {   // 在优质区
        
        JAAdminViewController *vc = [[JAAdminViewController alloc] init];
        vc.checkTag = 2;
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{    // 在清理区
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - SPPageMenu
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    [self.scrollView setContentOffset:CGPointMake((toIndex * 1.0 * JA_SCREEN_WIDTH), 0) animated:YES];
    
}
@end
