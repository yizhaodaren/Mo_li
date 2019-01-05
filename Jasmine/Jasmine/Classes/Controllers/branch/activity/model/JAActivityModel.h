//
//  JAActivityModel.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/26.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAActivityModel : JABaseModel
@property (nonatomic, strong) NSString *categoryId;
@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) NSString *createTime;
@property (nonatomic, strong) NSString *endTime;
@property (nonatomic, strong) NSString *activityId;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *inside;
@property (nonatomic, strong) NSString *isExpire;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *startTime;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *updateTime;
@property (nonatomic, strong) NSString *url;

// v3.0.0
@property (nonatomic, copy) NSString *activityImage;

@end
