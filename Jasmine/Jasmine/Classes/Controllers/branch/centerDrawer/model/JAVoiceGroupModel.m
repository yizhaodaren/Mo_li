//
//  JAVoiceGroupModel.m
//  Jasmine
//
//  Created by xujin on 29/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceGroupModel.h"

@implementation JAVoiceGroupModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JAVoiceModel class]
             };
}

MJCodingImplementation

@end
