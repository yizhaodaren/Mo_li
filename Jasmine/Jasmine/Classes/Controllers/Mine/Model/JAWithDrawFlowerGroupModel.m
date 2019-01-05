//
//  JAWithDrawFlowerGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawFlowerGroupModel.h"
#import "JAWithDrawFlowerModel.h"
@implementation JAWithDrawFlowerGroupModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JAWithDrawFlowerModel class]};
}
@end
