//
//  JATaskModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JATaskModel.h"
#import "JATaskGroupModel.h"
#import "JATaskRowModel.h"

@implementation JATaskModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
              @"msgTaskList" : [JATaskGroupModel class]
             };
}


@end
