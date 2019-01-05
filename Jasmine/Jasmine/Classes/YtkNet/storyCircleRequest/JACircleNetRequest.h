//
//  JACircleNetRequest.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANetRequest.h"
#import "JACircleGroupModel.h"
#import "JACircleModel.h"
#import "JANewVoiceModel.h"
#import "JANewVoiceGroupModel.h"
#import "JALightUserGroupModel.h"
#import "JACircleAdminGroupModel.h"

@interface JACircleNetRequest : JANetRequest

/// 关注圈子列表
- (instancetype)initRequest_focusCircleListWithParameter:(NSDictionary *)parameter;

/// 推荐（全部）圈子列表
- (instancetype)initRequest_allCircleListWithParameter:(NSDictionary *)parameter;

/// 圈子详情 - 基本信息
- (instancetype)initRequest_circleInfoWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;

/// 圈子详情 - 置顶帖
- (instancetype)initRequest_circleStickPostWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;

/// 圈子详情 - 帖子列表
- (instancetype)initRequest_circleVoiceListWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;

/// 关注圈子
- (instancetype)initRequest_focusCircleWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;

/// 圈子圈主
- (instancetype)initRequest_circleAdminWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;

/// 3.0.2版本圈子圈主
- (instancetype)initRequest_circleBigAndSmallAdminWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;

/// 圈子签到
- (instancetype)initRequest_circleSignWithParameter:(NSDictionary *)parameter circleId:(NSString *)circleId;
@end
