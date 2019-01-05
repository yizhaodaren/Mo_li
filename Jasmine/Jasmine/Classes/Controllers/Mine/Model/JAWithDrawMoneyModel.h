//
//  JAWithDrawMoneyModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAWithDrawMoneyModel : JABaseModel

@property (nonatomic, strong) NSString *afterMoney;
@property (nonatomic, strong) NSString *agoMoney;
//@property (nonatomic, strong) NSString *changeMoney;
@property (nonatomic, assign) double changeMoney;
@property (nonatomic, strong) NSString *dataType;
@property (nonatomic, strong) NSString *operationType;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *desc;
@end
