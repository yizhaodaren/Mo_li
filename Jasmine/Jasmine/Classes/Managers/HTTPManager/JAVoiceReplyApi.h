//
//  JAVoiceReplyApi.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JAVoiceReplyApi : JABaseApiRequest
+ (instancetype)shareInstance;

/// 回复音频分页列表
- (void)voice_replyListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 添加回复
- (void)voice_releaseReplyWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 删除回复
- (void)voice_deleteVoiceReplyWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
@end
