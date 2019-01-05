//
//  JADBTaskModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JADBTaskModel.h"

@implementation JADBTaskModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"taskId" : @"id"};
}

// 创建表名字
+(NSString *)getTableName
{
    NSString *name_uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    return [NSString stringWithFormat:@"personalTasksTable_%@",name_uid];
}
@end
