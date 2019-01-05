//
//  JAIncomeDetailCell.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAWithDrawFlowerModel.h"
#import "JAWithDrawMoneyModel.h"
@interface JAIncomeDetailCell : UITableViewCell

@property (nonatomic, strong) JAWithDrawMoneyModel *moneyModel;
@property (nonatomic, strong) JAWithDrawFlowerModel *flowerModel;
@end
