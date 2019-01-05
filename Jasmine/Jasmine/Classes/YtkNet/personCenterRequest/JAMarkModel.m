//
//  JAMarkModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMarkModel.h"

@implementation JAMarkModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"tasks":[JAMarkTaskModel class]
             };
}
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"markId":@"id",
             };
}
MJCodingImplementation
@end
