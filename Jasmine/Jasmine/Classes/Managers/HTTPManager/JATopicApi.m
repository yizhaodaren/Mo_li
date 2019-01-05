//
//  JATopicApi.m
//  Jasmine
//
//  Created by xujin on 26/02/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JATopicApi.h"

@implementation JATopicApi

+ (JATopicApi *)shareInstance
{
    static JATopicApi *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JATopicApi alloc] init];
        }
    });
    return instance;
}

/// 发现页热门话题
- (void)topic_hotTopic:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)())failure {
    // http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1519461612496-1722617555-0023
    NSString *uri = @"/moli_audio_consumer/v2/topic/selectRecommendTopicList";
    [self getRequest:uri parameters:dic success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 发帖时推荐话题
- (void)topic_recommendTopic:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)())failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1518943598797-1722617555-0019
    NSString *uri = @"/moli_audio_consumer/v2/topic/selectTopicList";
    [self getRequest:uri parameters:dic success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 根据话题查询帖子列表(热门、最新)
- (void)topic_voiceList:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)())failure {
    
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1518943947868-1722617555-0021
    
    NSString *uri = @"/moli_audio_consumer/v2/topic/selectTopicStoryList";
    [self getRequest:uri parameters:dic success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 根据id或者话题标题查找详情
- (void)topic_Detail:(NSDictionary *)dic success:(void(^)(NSDictionary *result))success failure:(void(^)(NSError *error))failure {
    
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1518943779157-1722617555-0020
    
    NSString *uri = @"/moli_audio_consumer/v2/topic/selectTopicInfo";
    [self getRequest:uri parameters:dic success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}


@end
