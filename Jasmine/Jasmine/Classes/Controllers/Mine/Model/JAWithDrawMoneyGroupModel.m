//
//  JAWithDrawMoneyGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawMoneyGroupModel.h"
#import "JAWithDrawMoneyModel.h"
@implementation JAWithDrawMoneyGroupModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JAWithDrawMoneyModel class]};
}

@end
