//
//  JAPullRefreshViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPullRefreshViewController.h"
#import <MJRefresh.h>

@interface JAPullRefreshViewController ()

- (void)cancelPullDownRefresh;
- (void)cancelPullUpRefresh;

@end

@implementation JAPullRefreshViewController

- (instancetype)init{
    if (self = [super init]) {
        self.pageIndex = 0;
        self.pageSize = 10;
    }
    return self;
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    IMP_BLOCK_SELF(JAPullRefreshViewController)
    if (!_refreshView) {
        return;
    }
    
    if (!self.refreshView.mj_header) {
        self.refreshView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
            [block_self PullDonwRefreshCompletion:^{
                [block_self.refreshView.mj_header endRefreshing];
                [block_self cancelPullDownRefresh];
            }];
        }];
    }
    if (!self.refreshView.mj_footer) {
        self.refreshView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            [block_self PullUpRefreshCompletion:^{
                [block_self.refreshView.mj_footer endRefreshing];
                [block_self cancelPullUpRefresh];
            }];
        }];
    }
    if (self.isAutoPullRefresh&&self.refreshView.contentOffset.y<=0) {
        [self.refreshView.mj_header beginRefreshing];
    }
}

- (void)PullDonwRefreshCompletion:(void (^)(void))completion{
    if (completion!=NULL) {
        completion();
    }
}

- (void)PullUpRefreshCompletion:(void (^)(void))completion{
    if (completion!=NULL) {
        completion();
    }
}

- (void)cancelPullDownRefresh{
    
}

- (void)cancelPullUpRefresh{
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
