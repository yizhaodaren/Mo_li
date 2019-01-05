//
//  JACommonApi.h
//  Jasmine
//
//  Created by xujin on 05/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

/// 包含评论添加删除、收藏、点赞
@interface JACommonApi : JABaseApiRequest

+ (instancetype)shareInstance;

/// 公共采集器---分享信息(类型:qq、wx、wb、moli)
- (void)addDataLogs_shareWithType:(NSString *)type;

/// 公共采集器---注册信息(类型：phone、qq、wx、wb)
- (void)addDataLogs_registerWithType:(NSString *)type;

/// 公共采集器---激活信息
- (void)addDataLogs_activeSuccess:(void (^)(void))success;

/// 公共采集器---登录信息(类型:phone、qq、wx、wb)
- (void)addDataLogs_loginWithType:(NSString *)type type_info:(NSString *)type_info;

@end
