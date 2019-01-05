//
//  JAActivityGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/26.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAActivityGroupModel.h"
#import "JAActivityModel.h"
@implementation JAActivityGroupModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JAActivityModel class]};
}

MJCodingImplementation

@end
