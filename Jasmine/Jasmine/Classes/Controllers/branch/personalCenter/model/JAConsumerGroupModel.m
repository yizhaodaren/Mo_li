//
//  JAConsumerGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/2.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAConsumerGroupModel.h"
#import "JAConsumer.h"
@implementation JAConsumerGroupModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JAConsumer class]
             };
}
@end
