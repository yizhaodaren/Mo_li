//
//  JAPullRefreshViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAPullRefreshViewController : JABaseViewController
// 默认 10和1
@property (nonatomic, assign) int pageSize;
@property (nonatomic, assign) int pageIndex;
// 设置刷新View,必须！！
@property (nonatomic, strong) UIScrollView *refreshView;
// 进入页面是否自动触发
@property (nonatomic, assign) BOOL isAutoPullRefresh;

/**
 需要执行时在子类重写

 @param completion 完成回调时调用completion()结束动画
 */
- (void)PullDonwRefreshCompletion:(void (^)(void))completion;
- (void)PullUpRefreshCompletion:(void (^)(void))completion;
@end
