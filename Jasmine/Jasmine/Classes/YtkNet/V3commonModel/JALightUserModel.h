//
//  JALightUserModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"

@interface JALightUserModel : JANetBaseModel

@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, assign) BOOL isAnonymous;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) BOOL isCircleAdmin;
@property (nonatomic, strong) NSString *friendType; //关注关系 0关注 1 好友,2:无关系 3：黑名单
@property (nonatomic, strong) NSString *circleLevel; //关注关系 0关注 1 好友,2:无关系 3：黑名单

// 3.1
@property (nonatomic, strong) NSString *medalUrl;
@property (nonatomic, strong) NSString *medalId;
@property (nonatomic, strong) NSString *crownImage;
@end
