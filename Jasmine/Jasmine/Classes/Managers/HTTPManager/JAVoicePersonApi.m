//
//  JAVoicePersonApi.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoicePersonApi.h"

@implementation JAVoicePersonApi

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAVoicePersonApi alloc] init];
        }
    });
    return instance;
}

/// 个人主页信息
- (void)voice_personalInfoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504091389089-1722617555-0071
    
    NSString *uri = @"/moli_audio_consumer/v2/user/selectByPrimaryKey";
    
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

/// 查看用户相册
- (void)voice_personalPhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089616699-1722617555-0057
    
    NSString *uri = @"/moli_audio_consumer/v2/photo/selectAllPhotoByUserId";
    
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

/// 修改用户相册
- (void)voice_personalUpdatePhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089514126-1722617555-0056
    
    NSString *uri = @"/moli_audio_consumer/v2/photo/updateByPrimaryKeySelective";
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

/// 管理员修改用户相册
- (void)voice_adminUpdatePhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1520477868522-1722617555-0028
    
    NSString *uri = @"/moli_audio_consumer/v2/photo/updateUserPhotoByManager";
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

/// 管理员修改用户头像
- (void)voice_adminUpdateIconWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1520477732671-1722617555-0027
    
    NSString *uri = @"/moli_audio_consumer/v2/user/updateImageByManager";
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

/// 管理员修改帖子图片
- (void)voice_adminUpdateVoicePicWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1520481186828-1722617555-0030
    
    NSString *uri = @"/moli_audio_consumer/v2/story/updateStoryInfo";
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

/// 查看用户首次上传相册
- (void)voice_personalUpLoadPhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504089140977-1722617555-0054
    
    NSString *uri = @"/moli_audio_consumer/v2/photo/insertSelective";

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

/// 关注用户
- (void)voice_personalFocusUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504090417279-1722617555-0061
    
    NSString *uri = @"/moli_audio_consumer/v2/friend/insertSelective";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        // 获取用户的关注数
        NSInteger focus = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount].integerValue;
        [JAUserInfo userInfo_updataUserInfoWithKey:User_userConsernCount value:[NSString stringWithFormat:@"%ld",(focus + 1)]];
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 取消关注用户
- (void)voice_personalCancleFocusUseroWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504090490709-1722617555-0062
    
    NSString *uri = @"/moli_audio_consumer//v2/friend/updateByPrimaryKeySelective";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        // 获取用户的关注数
        NSInteger focus = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount].integerValue;
        [JAUserInfo userInfo_updataUserInfoWithKey:User_userConsernCount value:[NSString stringWithFormat:@"%ld",(focus - 1 > 0 ? (focus - 1) : 0)]];
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 查询两人的关注状态
- (void)voice_personalRelationParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504090621208-1722617555-0063
    
    NSString *uri = @"/moli_audio_consumer//v2/friend/selectFriendByUserIdAndConcernId";
    
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

/// 查询用户关注粉丝列表
- (void)voice_personalFocusAndFansParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504090277135-1722617555-0060
    
    NSString *uri = @"/moli_audio_consumer//v2/friend/selectFriendByUserId";
    
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

/// 添加黑名单
- (void)voice_personalAddBlackUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504090670506-1722617555-0064
    
    NSString *uri = @"/moli_audio_consumer//v2/friend/insertSelectiveBlack";
    
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

/// 移除黑名单
- (void)voice_personalDeleteBlackUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504090702711-1722617555-0065
    
    NSString *uri = @"/moli_audio_consumer//v2/friend/updateSelectiveBlack";
    
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


/// 举报用户
- (void)voice_personalReportUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504088432109-1722617555-0052
    
    NSString *uri = @"/moli_audio_consumer/v2/report/insertSelectiveReport";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (error.code == 129000) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }

        if (failure) {
            failure(error);
        }
    }];
}

/// 帮助中心
- (void)voice_helperWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    //    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504100655673-1722617555-0082
    
    NSString *uri = @"/moli_audio_consumer/v2/help/selectAllHelp";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 任务接口
- (void)voice_taskWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer//v2/task/selectTaskList";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 活动接口
- (void)voice_activityWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506162406225-1722617555-0119
    
    NSString *uri = @"/moli_audio_consumer/v2.1.0/advertisement/selectActivity";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    
}

/// 评审故事列表
- (void)voice_checkPostsWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506327524145-1722617555-0121
                                          
    NSString *uri = @"/moli_audio_consumer/v2/story/selectPageExamineStoryList";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 评审评论列表
- (void)voice_checkCommentWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506327629297-1722617555-0122
    
    NSString *uri = @"/moli_audio_consumer/v2/comment/selectPageCommentExamineList";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 列表评审故事
- (void)voice_listCheckPostsWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/story/updateStoryIndexListExamine";
    
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 列表评审评论
- (void)voice_listCheckCommentWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    
    NSString *uri = @"/moli_audio_consumer/v2/comment/updateCommentListExamine";
    
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 审核区评审故事
- (void)voice_actionPostsWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506327388846-1722617555-0120
    
    NSString *uri = @"/moli_audio_consumer/v2/story/updateStoryExamine";
    
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 审核区评审评论
- (void)voice_actionCommentWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506327663446-1722617555-0123
    NSString *uri = @"/moli_audio_consumer/v2/comment/updateCommentExamine";
    
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
    
}


/// 冻结花朵详情
- (void)voice_checkFlowerWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1507381322069-1722617555-0002
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/selectFrostRecordList";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}

/// 匿名开关
- (void)voice_anonymitySwitchWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1507901817784-1722617555-0011
    
    NSString *uri = @"/moli_audio_consumer/v2/story/userName";
    
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
    }];
}


/// 收藏帖子列表接口
- (void)voice_personCollectListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/collent/selectUserCollentList";
    
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

/// 收藏帖子接口
- (void)voice_insertCollectListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/collent/insertCollent";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        if ([result[@"isCollent"] integerValue] == 1) {
            
            if ([paras[@"type"] isEqualToString:JA_STORY_TYPE]) {
                
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"bool"] = @"1";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"personalCollectCountChange" object:dic];
                
                // 获取收藏数
                NSInteger collect = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount].integerValue;
                collect = collect + 1;
                [JAUserInfo userInfo_updataUserInfoWithKey:User_collentCount value:[NSString stringWithFormat:@"%ld",collect]];
            }
            
        }else if ([result[@"isCollent"] integerValue] == 2){
            if ([paras[@"type"] isEqualToString:JA_STORY_TYPE]) {
                NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                dic[@"bool"] = @"0";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"personalCollectCountChange" object:dic];
                
                // 获取收藏数
                NSInteger collect = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount].integerValue;
                collect = collect - 1 > 0 ? (collect - 1) : 0;
                [JAUserInfo userInfo_updataUserInfoWithKey:User_collentCount value:[NSString stringWithFormat:@"%ld",collect]];
            }
        }
        
        
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 查询是否收藏帖子接口
- (void)voice_collectStatusWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/collent/selectCollentInfo";
    
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

/// 添加不喜欢内容记录
- (void)voice_insertDislikeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1513675139932-1722617555-0010
    NSString *uri = @"/moli_audio_consumer/v2/dislike/insertDislike";
    
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

/// 获取茉莉君信息
- (void)voice_getMoliJunTask:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/onhook/selectOnHook";
    
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

/// 获取我的投稿列表
- (void)voice_getMyContribute:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/contribute/selectContributeList";
    
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

/// 领取茉莉君奖励
- (void)voice_getMoliJunReward:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/wallet/getOnhookRandomFlower";
    
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
