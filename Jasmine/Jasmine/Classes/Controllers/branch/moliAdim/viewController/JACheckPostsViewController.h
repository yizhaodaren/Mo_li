//
//  JACheckPostsViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@class SPPageMenu;
@interface JACheckPostsViewController : JABaseViewController
@property (nonatomic, assign) NSInteger checkTag;   // 1 为优质区  2 为清理区
@property (nonatomic, weak) SPPageMenu *pageMenu;
@end
