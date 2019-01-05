//
//  JAMarkModel.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetBaseModel.h"
#import "JAMarkTaskModel.h"
@interface JAMarkModel : JANetBaseModel
@property (nonatomic, strong) NSString *crownStatus;
@property (nonatomic, strong) NSString *darkImage;   // 未获得图片
@property (nonatomic, strong) NSString *markId;
@property (nonatomic, strong) NSString *lightImage;  // 已获得图片
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *smallImage;   // 个人中心小图标
@property (nonatomic, strong) NSArray *tasks;
@end
