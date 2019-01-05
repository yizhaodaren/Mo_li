//
//  JAVoiceTopicModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAVoiceTopicModel.h"

@implementation JAVoiceTopicModel
+ (NSDictionary *)mj_replacedKeyFromPropertyName
{
    return @{@"topicId" : @"id"};
}

MJCodingImplementation

@end
