//
//  JAVoiceFollowModel.h
//  Jasmine
//
//  Created by xujin on 15/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JANetBaseModel.h"

@interface JAVoiceFollowModel : JANetBaseModel

@property (nonatomic, copy) NSString *image;
@property (nonatomic, copy) NSString *introduce;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, strong) NSString *friendType;

@end
