//
//  JACallinviteFriendGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/9.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACallinviteFriendGroupModel.h"
#import "JACallInviteFriendModel.h"
@implementation JACallinviteFriendGroupModel

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JACallInviteFriendModel class]};
}

@end
