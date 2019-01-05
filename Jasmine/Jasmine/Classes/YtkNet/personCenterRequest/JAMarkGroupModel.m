//
//  JAMarkGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMarkGroupModel.h"

@implementation JAMarkGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"crownList":[JAMarkModel class]
             };
}
@end
