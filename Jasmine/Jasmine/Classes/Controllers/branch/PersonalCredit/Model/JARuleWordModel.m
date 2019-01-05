//
//  JARuleWordModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JARuleWordModel.h"

@implementation JARuleWordModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"listIntegralInfoConfig":[JARuleModel class],
             @"listIntegralIncrease":[JARuleModel class],
             @"listIntegralInfoReduce":[JARuleModel class],
             };
}
@end
