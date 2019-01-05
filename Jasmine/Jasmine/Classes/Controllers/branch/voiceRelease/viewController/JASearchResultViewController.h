//
//  JASearchResultViewController.h
//  Jasmine
//
//  Created by xujin on 27/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAConsumer.h"

@interface JASearchResultViewController : JABaseViewController<UISearchResultsUpdating>

@property (strong, nonatomic) UINavigationController *nav;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (nonatomic, copy) void (^selectBlock)(JAConsumer *consumer);
@property (nonatomic, copy) void (^hideSearchBar)(void);

@property (nonatomic, assign) NSInteger fromType; // 0私信页面1发布页
@end
