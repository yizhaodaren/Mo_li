//
//  JATaskGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JATaskGroupModel.h"

@implementation JATaskGroupModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
             @"taskList" : [JATaskRowModel class]
             };
}

@end
