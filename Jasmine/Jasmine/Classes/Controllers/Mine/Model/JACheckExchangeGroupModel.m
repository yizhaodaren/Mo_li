//
//  JACheckExchangeGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckExchangeGroupModel.h"
#import "JACheckExchangeModel.h"
@implementation JACheckExchangeGroupModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JACheckExchangeModel class]};
}
@end
