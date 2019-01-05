//
//  JACircleDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAoldCircleDetailViewController : JABaseViewController
@property (nonatomic, strong) NSString *circleId;
@property (nonatomic, strong) void(^focusAndCancleCircleBlock)(BOOL isFocus);
@end
