//
//  JANewCircleDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JACircleDetailViewController : JABaseViewController
@property (nonatomic, strong) NSString *circleId;
@property (nonatomic, strong) void(^focusAndCancleCircleBlock)(BOOL isFocus);
@end
