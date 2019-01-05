//
//  JATaskRowModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JATaskRowModel.h"

@implementation JATaskRowModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"taskId" : @"id"};
}

- (CGFloat)cellHeight
{
    if (_cellHeight == 0) {
        
        _cellHeight = 50;
    }
    
    return _cellHeight;
}

+ (NSString *)getPrimaryKey
{
    return @"taskId";
}

// 创建表名字
+(NSString *)getTableName
{
    NSString *name_uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    return [NSString stringWithFormat:@"personalTasksTable_%@",name_uid];
}
@end
