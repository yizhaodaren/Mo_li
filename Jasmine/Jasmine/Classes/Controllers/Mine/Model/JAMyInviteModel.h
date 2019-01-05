//
//  JAMyInviteModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAMyInviteModel : JABaseModel

@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *inviteUserFlower;
@property (nonatomic, strong) NSString *inviteUserId;
@property (nonatomic, strong) NSString *inviteUserImage;
@property (nonatomic, strong) NSString *inviteUserMoney;
@property (nonatomic, strong) NSString *inviteUserName;
@property (nonatomic, strong) NSString *updateTime;
@property (nonatomic, strong) NSString *userFlower;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userImage;
@property (nonatomic, strong) NSString *userMoney;
@property (nonatomic, strong) NSString *userName;

@property (nonatomic, assign) NSInteger ranking;
@end
