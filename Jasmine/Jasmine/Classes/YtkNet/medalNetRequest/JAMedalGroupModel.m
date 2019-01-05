//
//  JAMedalGroupModel.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/14.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMedalGroupModel.h"

@implementation JAMedalGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"inviteList":[JAMedalModel class],
              @"dayList":[JAMedalModel class],
              @"storyList":[JAMedalModel class]
             };
}

@end
