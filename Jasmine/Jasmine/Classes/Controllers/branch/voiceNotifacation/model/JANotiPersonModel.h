//
//  JANotiPersonModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/5.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JANotiPersonModel : JABaseModel

@property (nonatomic, strong) NSString *nick;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *img;
@property (nonatomic, strong) NSString *friendType;
@property (nonatomic, assign) BOOL isAnonymous;
@property (nonatomic, copy) NSString *anonymousName;
@end
