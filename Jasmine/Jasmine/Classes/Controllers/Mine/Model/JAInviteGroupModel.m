//
//  JAInviteGroupModel.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAInviteGroupModel.h"
#import "JAMyInviteModel.h"
@implementation JAInviteGroupModel
+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"result" : [JAMyInviteModel class]};
}
@end
