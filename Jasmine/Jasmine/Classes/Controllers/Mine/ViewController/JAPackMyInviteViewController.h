//
//  JAPackMyInviteViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "SPPageMenu.h"
@interface JAPackMyInviteViewController : JABaseViewController
//@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) SPPageMenu *titleView;

@property (nonatomic, assign) NSInteger currentViewPage; // 当前的页面  // 0 排行榜 1 召唤好友

@property (nonatomic, assign) NSInteger callFriendType;  //  1 邀请好友 -> 我的邀请的召唤好友
@end
