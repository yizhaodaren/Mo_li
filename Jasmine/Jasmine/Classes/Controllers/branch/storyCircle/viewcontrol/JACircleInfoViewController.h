//
//  JACircleInfoViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
@class JACircleModel;
@interface JACircleInfoViewController : JABaseViewController
@property (nonatomic, strong) JACircleModel *circleModel;

@property (nonatomic, strong) void (^followAndCancleCircle)(BOOL isFollow);
@end
