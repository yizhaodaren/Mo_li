//
//  JAReleaseStoryCountModel.m
//  Jasmine
//
//  Created by xujin on 17/10/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAReleaseStoryCountModel.h"

@implementation JAReleaseStoryCountModel

// 创建表名字
+(NSString *)getTableName
{
    NSString *name_uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    return [NSString stringWithFormat:@"ReleaseStoryCountTable_%@",name_uid];
}

@end
