//
//  JAPersonIncomeHeaderView.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPersonIncomeHeaderView : UIView
@property (nonatomic, strong) NSString *totalFlower;  // 可用花朵
@property (nonatomic, strong) NSString *totalMoney;  // 可用金额
@property (nonatomic, strong) NSString *rate;        // 汇率

//@property (nonatomic, strong) NSString *checkFlower;  // 审核花朵

@property (nonatomic, strong) NSString *enableMoney;  // 可兑换的钱

// 多少花兑换多少钱
@property (nonatomic, strong) NSString *rateFlower;
@property (nonatomic, strong) NSString *rateMoney;
@end
