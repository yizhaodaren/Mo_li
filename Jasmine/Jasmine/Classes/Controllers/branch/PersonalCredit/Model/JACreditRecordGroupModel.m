//
//  JACreditRecordGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACreditRecordGroupModel.h"
#import "JACreditRecordModel.h"
@implementation JACreditRecordGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JACreditRecordModel class]
             };
}
@end
