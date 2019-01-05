//
//  JAInviteData.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAInviteData.h"

@implementation JAInviteUser

+ (NSDictionary *)mj_replacedKeyFromPropertyName {
    return @{
             @"inviteUserId":@"userId",

             };
}

@end

@implementation JAInviteData

+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"result":[JAInviteUser class]
             };
}

@end
