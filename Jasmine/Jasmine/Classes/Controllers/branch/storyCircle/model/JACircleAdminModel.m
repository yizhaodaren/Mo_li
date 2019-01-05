//
//  JACircleAdminModel.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/27.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleAdminModel.h"

@implementation JACircleAdminModel
+ (NSDictionary *)mj_objectClassInArray {
    return @{
             @"baseUserVOList":[JALightUserModel class]
             };
}
@end
