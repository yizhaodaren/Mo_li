//
//  JAReleaseStoryCountModel.h
//  Jasmine
//
//  Created by xujin on 17/10/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseModel.h"

@interface JAReleaseStoryCountModel : JABaseModel

@property (nonatomic, assign) NSInteger storyCount; // 已发帖数
@property (nonatomic, strong) NSDate *lastDate; // 上次调用获取发帖数的接口时间

@end
