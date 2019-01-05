//
//  JAVoiceCommentGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceCommentGroupModel.h"
#import "JAVoiceCommentModel.h"
@implementation JAVoiceCommentGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JAVoiceCommentModel class]
             };
}
@end
