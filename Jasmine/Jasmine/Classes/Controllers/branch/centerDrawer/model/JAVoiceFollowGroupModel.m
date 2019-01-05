//
//  JAVoiceFollowGroupModel.m
//  Jasmine
//
//  Created by xujin on 15/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceFollowGroupModel.h"

@implementation JAVoiceFollowGroupModel

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[JAVoiceFollowModel class]
             };
}

@end
