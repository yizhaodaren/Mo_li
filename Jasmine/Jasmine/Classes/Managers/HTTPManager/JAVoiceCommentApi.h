//
//  JAVoiceCommentApi.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JAVoiceCommentApi : JABaseApiRequest
+ (instancetype)shareInstance;

/// 音频评论分页列表
- (void)voice_commentListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 音频的单个评论
- (void)voice_singleCommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 添加评论信息
- (void)voice_releaseCommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 删除评论
- (void)voice_deleteVoiceCommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
@end
