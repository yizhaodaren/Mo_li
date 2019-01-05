//
//  JAActivityModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/26.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAActivityModel.h"

@implementation JAActivityModel


+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{
             @"activityId" : @"id",
             @"activityImage" : @"newImage"
             };
}

MJCodingImplementation

@end
