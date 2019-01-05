//
//  JAVoiceReplyGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceReplyGroupModel.h"
#import "JAVoiceReplyModel.h"
@implementation JAVoiceReplyGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JAVoiceReplyModel class]
             };
}
@end
