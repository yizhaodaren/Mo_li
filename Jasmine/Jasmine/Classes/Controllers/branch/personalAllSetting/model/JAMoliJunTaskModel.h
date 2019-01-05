//
//  JAMoliJunTaskModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/4/11.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JABaseModel.h"
#import "JAOnHookModel.h"

@interface JAMoliJunTaskModel : JABaseModel

@property (nonatomic, strong) NSString *activecount;
@property (nonatomic, strong) JAOnHookModel *onhook;
@property (nonatomic, strong) NSString *postcard;
@property (nonatomic, strong) NSString *receiveTime;
@property (nonatomic, strong) NSString *flower;

@end
