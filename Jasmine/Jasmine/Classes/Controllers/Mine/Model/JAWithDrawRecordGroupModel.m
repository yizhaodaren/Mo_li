//
//  JAWithDrawRecordGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/24.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWithDrawRecordGroupModel.h"
#import "JAWithDrawRecordModel.h"
@implementation JAWithDrawRecordGroupModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JAWithDrawRecordModel class]};
}
@end
