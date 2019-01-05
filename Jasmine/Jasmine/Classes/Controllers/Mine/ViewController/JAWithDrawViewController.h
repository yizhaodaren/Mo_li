//
//  JAWithDrawViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/22.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAWithDrawViewController : JABaseViewController

@property (nonatomic, strong) NSString *moneyCountString;

//@property (nonatomic, strong) NSString *maxWithDrawMoney; // 暂时没用

@property (nonatomic, strong) NSMutableArray *moneyArray;

@property (nonatomic, assign) BOOL isFirstWithDraw;  // 是否是首次提现

@property (nonatomic, strong) void(^withDrawSuccess)(NSString *totalM); // 提现成功
@end
