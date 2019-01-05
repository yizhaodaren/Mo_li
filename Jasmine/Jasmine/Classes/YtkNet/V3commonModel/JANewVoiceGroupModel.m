//
//  JANewVoiceGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewVoiceGroupModel.h"

@implementation JANewVoiceGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"resBody":[JANewVoiceModel class]
             };
}
MJCodingImplementation
@end
