//
//  JAPostDraftModel.m
//  Jasmine
//
//  Created by xujin on 19/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAPostDraftModel.h"

@implementation JAPostDraftModel

- (instancetype)init
{
    self = [super init];
    if (self) {
//        self.circleId = @"99";
        self.progress = 0.0;
    }
    return self;
}

//+ (NSString *)getPrimaryKey
//{
//    return @"createTime";
//}


// 创建表名字
+(NSString *)getTableName
{
    NSString *name_uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    return [NSString stringWithFormat:@"postDraftModelTable_%@",name_uid];
}

@end
