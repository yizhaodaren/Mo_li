
//
//  JAChannelModel.m
//  Jasmine
//
//  Created by xujin on 31/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAChannelModel.h"

@implementation JAChannelModel

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"channelId":@"id",
             };
}

@end
