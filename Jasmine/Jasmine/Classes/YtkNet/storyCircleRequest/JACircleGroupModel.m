//
//  JACircleGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleGroupModel.h"

@implementation JACircleGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[JACircleModel class]
             };
}
@end
