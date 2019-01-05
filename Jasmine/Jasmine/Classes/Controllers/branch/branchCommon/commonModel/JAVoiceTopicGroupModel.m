//
//  JAVoiceTopicGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAVoiceTopicGroupModel.h"
#import "JAVoiceTopicModel.h"

@implementation JAVoiceTopicGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JAVoiceTopicModel class]
             };
}

MJCodingImplementation

@end
