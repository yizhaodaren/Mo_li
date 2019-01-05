//
//  JABaseModel.m
//  Jasmine
//
//  Created by xujin on 09/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseModel.h"

@implementation JAActionModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"actionId":@"id",
             };
}

@end

@implementation JAActionStateMsg

@end

@implementation JABaseModel
//
//+(LKDBHelper *)getUsingLKDBHelper
//{
//    static LKDBHelper* db;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        //        NSString* dbpath = [NSHomeDirectory() stringByAppendingPathComponent:@"asd/asd.db"];
//        //        db = [[LKDBHelper alloc]initWithDBPath:dbpath];
//        //or
//        db = [[LKDBHelper alloc]init];
//    });
//    return db;
//}

@end
