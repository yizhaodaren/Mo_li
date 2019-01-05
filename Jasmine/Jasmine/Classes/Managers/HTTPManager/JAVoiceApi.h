//
//  JAVoiceApi.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JAVoiceApi : JABaseApiRequest

+ (instancetype)shareInstance;

/// 首页音频分页列表(除关注、推荐列表外)
- (void)voice_contentListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 首页推荐
- (void)voice_recommendListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 首页发现
- (void)voice_discoverListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 首页关注人的音频列表
- (void)voice_followListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

///首页推荐关注达人接口
- (void)voice_followPeopleWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 关注多个人
- (void)voice_followSelectPeopleWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 单个音频接口（音频详情）
- (void)voice_singleVoiceWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 发布音频
- (void)voice_releaseWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 删除音频
- (void)voice_deleteVoiceWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

// v2.6.2
/// 投稿
- (void)voice_ContributeVoiceWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

@end
