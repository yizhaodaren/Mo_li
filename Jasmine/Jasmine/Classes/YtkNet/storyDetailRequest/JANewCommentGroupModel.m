//
//  JANewCommentGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewCommentGroupModel.h"

@implementation JANewCommentGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[JANewCommentModel class]
             };
}
@end
