//
//  JAActivityFloatModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/16.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAActivityFloatModel.h"

@implementation JAActivityFloatModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"floatId" : @"id"};
}

// 创建表名字
+(NSString *)getTableName
{
    NSString *name_uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    return [NSString stringWithFormat:@"personalFloatActivity_%@",name_uid];
}

+(NSString *)getPrimaryKey
{
    return @"floatId";
}
@end
