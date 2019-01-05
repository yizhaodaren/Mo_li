//
//  JAMessageViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
@class JAMessageTopView;

@interface JAMessageViewController : JABaseViewController

@property (nonatomic, weak) JAMessageTopView *heardView;

@property (nonatomic, strong) void(^refreshRedPoint)(BOOL isHiddenRed);

@end
