//
//  JAIncomeDetailViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//


#import "JABaseViewController.h"
#import "SPPageMenu.h"

@interface JAIncomeDetailViewController : JABaseViewController

@property (nonatomic, strong) NSString *incomeType;
@property (nonatomic, weak) SPPageMenu *pageMenu;
@end
