//
//  JAVoiceCommentApi.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/31.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceCommentApi.h"

@implementation JAVoiceCommentApi

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAVoiceCommentApi alloc] init];
        }
    });
    return instance;
}

/// 音频评论分页列表
- (void)voice_commentListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089344177-1722617555-0055
    
    NSString *uri = @"/moli_audio_consumer//v2/comment/selectPageCommentList";
    
    NSMutableDictionary *addParas = [NSMutableDictionary dictionaryWithDictionary:paras];
    // userType标示自己还是他人，1：自己，2：别人
    NSString *userId = addParas[@"userId"];
    NSString *uid = addParas[@"uid"];
    if (uid.length) {
        // 已登录
        if (userId.length && ![uid isEqualToString:userId]) {
            // 查看他人的列表
            addParas[@"userType"] = @"2";
        } else {
            addParas[@"userType"] = @"1";
        }
    }
    
    [self getRequest:uri parameters:addParas success:^(NSDictionary *result) {
       
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/// 音频的单个评论
- (void)voice_singleCommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504171714354-1722617555-0095
    
    NSString *uri = @"/moli_audio_consumer//v2/comment/selectComment";
    
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

/// 添加评论
- (void)voice_releaseCommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504087593700-1722617555-0050
    
    NSString *uri = @"/moli_audio_consumer//v2/comment/insertComment";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"bool"] = @"1";
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"personalCommentCountChange" object:dic];
        
        if (success) {
            success(result);
        }
        
        // 获取回复数
        NSInteger comment = [JAUserInfo userInfo_getUserImfoWithKey:User_commentCount].integerValue;
        comment = comment + 1;
        [JAUserInfo userInfo_updataUserInfoWithKey:User_commentCount value:[NSString stringWithFormat:@"%ld",comment]];
       
//        [JAAPPManager app_awardMaskToast:@"task_comment"];
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/// 删除评论
- (void)voice_deleteVoiceCommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504087841607-1722617555-0051
    
    NSString *uri = @"/moli_audio_consumer//v2/comment/deletedComment";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
        
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"bool"] = @"0";
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"personalCommentCountChange" object:dic];
        
        if (success) {
            success(result);
        }
        
        if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            
            // 获取回复数
            NSInteger comment = [JAUserInfo userInfo_getUserImfoWithKey:User_commentCount].integerValue;
            comment = comment - 1 > 0 ? (comment - 1) : 0;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_commentCount value:[NSString stringWithFormat:@"%ld",comment]];
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}
@end
