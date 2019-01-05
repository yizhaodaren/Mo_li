//
//  JANewReplyGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/31.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewReplyGroupModel.h"

@implementation JANewReplyGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[JANewReplyModel class]
             };
}
@end
