//
//  JACallInviteFriendModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/1/9.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JACallInviteFriendModel : JABaseModel

@property (nonatomic, strong) NSString *callId;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userImage;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *logo;
@property (nonatomic, strong) NSString *shareUrl;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@end
