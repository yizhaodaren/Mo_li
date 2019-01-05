//
//  JAInviteData.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JABaseModel.h"

@interface JAInviteUser : JABaseModel

@property (nonatomic, copy) NSString *inviteUserId;
@property (nonatomic, copy) NSString *inviteStatus;
                                      
@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *introduce;
@property (nonatomic, copy) NSString *agreeCount;
@property (nonatomic, copy) NSString *storyCount;
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *levelId;

@end

@interface JAInviteData : NSObject

@property (nonatomic, strong) NSArray *result;
@property (nonatomic, assign) NSInteger totalCount;

@end
