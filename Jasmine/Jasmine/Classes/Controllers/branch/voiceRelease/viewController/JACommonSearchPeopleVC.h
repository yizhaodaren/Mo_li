//
//  JACommonSearchPeopleVC.h
//  Jasmine
//
//  Created by xujin on 26/03/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAConsumer.h"

@interface JACommonSearchPeopleVC : JABaseViewController

@property (nonatomic, assign) NSInteger fromType; // 0私信页面1发布页
@property (nonatomic, copy) void (^selectBlock)(JAConsumer *consumer);
@end
