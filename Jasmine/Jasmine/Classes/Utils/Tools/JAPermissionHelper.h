//
//  JAPermissionHelper.h
//  Jasmine
//
//  Created by xujin on 20/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    /** 已授权*/
    BBEPermissionsStatusAuthorize,  // 0
    /** 已拒绝*/
    BBEPermissionsStatusRefuse,     // 1
    /** 未询问*/
    BBEPermissionsStatusNoAsk,      // 2
    /** 家长控制*/
    BBEPermissionsStatusParentsLimit, // 3
    
}BBEPermissionsStatus;

@interface JAPermissionHelper : NSObject

+ (BOOL)hasRecordPermission;

+ (BBEPermissionsStatus)systemPermissionsWithVoice;
+ (void)systemPermissionsWithVoice_getSuccess:(void(^)())success getFailure:(void(^)())failure;
@end
