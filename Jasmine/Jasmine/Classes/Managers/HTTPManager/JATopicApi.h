//
//  JATopicApi.h
//  Jasmine
//
//  Created by xujin on 26/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JATopicApi : JABaseApiRequest

+ (JATopicApi *)shareInstance;

/// 发现页热门话题
- (void)topic_hotTopic:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)())failure;

/// 发帖时推荐话题
- (void)topic_recommendTopic:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)())failure;

/// 根据话题查询帖子列表(热门、最新)
- (void)topic_voiceList:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)())failure;

/// 根据id或者话题标题查找详情
- (void)topic_Detail:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)(NSError *error))failure;

@end
