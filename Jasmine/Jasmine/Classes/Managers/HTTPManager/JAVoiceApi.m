
//
//  JAVoiceApi.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceApi.h"

@implementation JAVoiceApi

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAVoiceApi alloc] init];
        }
    });
    return instance;
}

/// 首页音频分页列表
- (void)voice_contentListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504083372845-1722617555-0046
    
    NSString *uri = @"/moli_audio_consumer//v2/story/selectPageStoryList";
    
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

/// 首页推荐
- (void)voice_recommendListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504766374441-1722617555-0110
    NSString *uri = @"/moli_audio_consumer//v2/story/selectIndexRecommend";
    
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

/// 首页关注
- (void)voice_followListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504502189629-1722617555-0100
    NSString *uri = @"/moli_audio_consumer/v2/user/selectFriendContentList";
    
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

/// 首页发现
- (void)voice_discoverListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    NSString *uri = @"/moli_audio_consumer/v2/story/selectDiscoverRecommend";
    
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

///首页推荐关注达人接口
- (void)voice_followPeopleWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504513813581-1722617555-0103
    NSString *uri = @"/moli_audio_consumer/v2/user/selectUserByWeight";
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

/// 关注多个人
- (void)voice_followSelectPeopleWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1505279973013-1722617555-0114
    NSString *uri = @"/moli_audio_consumer//v2/friend/concernUsers";
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

/// 单个音频接口（音频详情）
- (void)voice_singleVoiceWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504082256643-1722617555-0044
    
    NSString *uri = @"/moli_audio_consumer//v2/story/selectStoryInfo";
    
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

/// 发布音频
- (void)voice_releaseWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
//http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504081952919-1722617555-0042
    
    NSString *uri = @"/moli_audio_consumer//v2/story/insertStory";
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
        
        // 获取帖子数
        NSInteger story = [JAUserInfo userInfo_getUserImfoWithKey:User_storyCount].integerValue;
        story = story + 1;
        [JAUserInfo userInfo_updataUserInfoWithKey:User_storyCount value:[NSString stringWithFormat:@"%ld",story]];
       
//        [JAAPPManager app_awardMaskToast:@"task_story"];
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

/// 删除音频
- (void)voice_deleteVoiceWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504083115842-1722617555-0045
    
    NSString *uri = @"/moli_audio_consumer//v2/story/deleteStory";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
        if (success) {
            success(result);
        }
        if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            // 获取帖子数
            NSInteger story = [JAUserInfo userInfo_getUserImfoWithKey:User_storyCount].integerValue;
            story = story - 1 > 0 ? (story - 1) : 0;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_storyCount value:[NSString stringWithFormat:@"%ld",story]];
        }
        
    } failure:^(NSError *error) {
        
        if (failure) {
            failure(error);
        }
    }];
}

// v2.6.2
/// 投稿
- (void)voice_ContributeVoiceWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1523265393720-1722617555-0067
    NSString *uri = @"/moli_audio_consumer/v2/contribute/insertContribute";
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
