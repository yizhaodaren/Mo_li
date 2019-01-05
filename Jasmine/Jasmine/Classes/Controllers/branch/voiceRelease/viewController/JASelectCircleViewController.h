//
//  JASelectCircleViewController.h
//  Jasmine
//
//  Created by xujin on 2018/5/29.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JACircleModel.h"

@interface JASelectCircleViewController : JABaseViewController

@property (nonatomic, copy) void (^selectedCircleBlock)(JACircleModel *model);
@property (nonatomic, copy) void (^postBlock)(void);
@end
