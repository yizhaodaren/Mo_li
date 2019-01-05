//
//  JAVoiceReplyApi.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceReplyApi.h"

@implementation JAVoiceReplyApi

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAVoiceReplyApi alloc] init];
        }
    });
    return instance;
}

/// 回复音频分页列表
- (void)voice_replyListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089891538-1722617555-0059
    
    NSString *uri = @"/moli_audio_consumer//v2/reply/selectPageReplyList";
    
    [self getRequest:uri parameters:paras success:^(NSDictionary *result) {
        
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/// 添加回复
- (void)voice_releaseReplyWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089089536-1722617555-0053
    
    NSString *uri = @"/moli_audio_consumer//v2/reply/insertReply";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/// 删除回复
- (void)voice_deleteVoiceReplyWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089631055-1722617555-0058
    
    NSString *uri = @"/moli_audio_consumer//v2/reply/deleteReply";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
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
