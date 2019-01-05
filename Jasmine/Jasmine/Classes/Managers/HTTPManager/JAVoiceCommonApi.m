//
//  JAVoiceCommonApi.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/2.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceCommonApi.h"

@implementation JAVoiceCommonApi

+ (JAVoiceCommonApi *)shareInstance
{
    static JAVoiceCommonApi *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAVoiceCommonApi alloc] init];
        }
    });
    return instance;
}

/// 获取茉莉君官方信息
- (void)voice_getOffic:(NSDictionary *)dic success:(void(^)(NSDictionary *result))successBlock failure:(void(^)())failureBlock
{
    //    http://doc.java.yourmoli.com/api/project.do#/ffff-1494212363495-1722617555-0003/front/interfaceDetail/ffff-1522074129826-1722617555-0058
    
    NSString *uri = @"/moli_audio_consumer/v2/molimsg/selectMoliMsgList";
//    NSString *uri = @"/moli_audio_consumer//v2/officialpush/selectAllPushInfoByPage";
    
    [self getRequest:uri parameters:dic success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}

/// 获取茉莉君官方未读信息
- (void)voice_getOfficDetailInfo:(NSDictionary *)dic success:(void(^)(NSDictionary *result))successBlock failure:(void(^)())failureBlock
{
    //    http://doc.java.yourmoli.com/api/project.do#/ffff-1494212363495-1722617555-0003/front/interfaceDetail/ffff-1522073066195-1722617555-0057
    
    NSString *uri = @"/moli_audio_consumer/v2/molimsg/countNotReadMsgNum";
    
    [self getRequest:uri parameters:dic success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock();
        }
    }];
}

/// 邀请 关注列表
- (void)voice_inviteFocusWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504239810912-1722617555-0099
    NSString *uri = @"/moli_audio_consumer/v2/friend/selectInviteStatusFriendByUserId";
    
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

/// 邀请 推荐列表
- (void)voice_inviteRecommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interface/debug/ffff-1504517746673-1722617555-0104
    
    NSString *uri = @"/moli_audio_consumer/v2/friend/selectUserRecommend";
    
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

/// 随机邀请
- (void)voice_inviteRandomWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504179436212-1722617555-0097
    
    NSString *uri = @"/moli_audio_consumer/v2/invite/randInvite";
    
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

/// 邀请接口
- (void)voice_inviteAddWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504086114775-1722617555-0047
    
    NSString *uri = @"/moli_audio_consumer/v2/invite/insertSelective";
    
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

/// 点赞接口
- (void)voice_agreeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504091937795-1722617555-0076
    NSString *uri = @"/moli_audio_consumer/v2/action/insertAction";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
        if (success) {
            success(result);
        }
        
//        NSString *str = [NSString stringWithFormat:@"%@",result[@"finishTaskId"]];
//        
//        if (str.integerValue) {
//            
//            [JAAPPManager app_awardMaskToast:@"task_agree"];
//        }
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 个人赞过的内容
- (void)voice_contentOfAgreeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504513560382-1722617555-0101
    
    NSString *uri = @"/moli_audio_consumer/v2/user/getLikeContentList";
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


/// 搜索
- (void)voice_searchWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504186230364-1722617555-0098
    
    NSString *uri = @"/moli_audio_consumer/v2/search/appSearch";
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

/// 主帖加精
- (void)voice_voiceCreamWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504671185304-1722617555-0108
    
    NSString *uri = @"/moli_audio_consumer/v2/story/updateStorySort";
    
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

/// 评论加神
- (void)voice_commentCreamWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504671089771-1722617555-0107
    
    NSString *uri = @"/moli_audio_consumer/v2/comment/updateCommentSort";
    
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

/// 封停用户
- (void)voice_userBanWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504671725398-1722617555-0109
    NSString *uri = @"/moli_audio_consumer/v2/user/kickUserPower";
    
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

/// 客户端、播放、跳过、分享，调用此接口
- (void)voice_appCommonWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504669911246-1722617555-0106
    
    NSString *uri = @"/moli_audio_consumer/v2/action/updateActionData";
    
    [self postRequest:uri parameters:paras success:^(NSDictionary *result) {
        
        if (success) {
            success(result);
        }
//        [JAAPPManager app_awardMaskToast:@"task_share_story"];
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

/// 分享收入
- (void)voice_appShareIncomeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1505098050398-1722617555-0112
    
    NSString *uri = @"/moli_audio_consumer/v2/action/recordIncome";
    
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


/// 分享注册链接 - 完成任务接口 2.5.0
- (void)voice_appShareRegistTaskWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1516442581624-1722617555-0002
    NSString *uri = @"/moli_audio_consumer/v2/task/updateShareTask";
    
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

// 获取banner
- (void)voice_getBanner:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504100864153-1722617555-0083
    NSString *uri = @"/moli_audio_consumer/v2/advertisement/selectAllAdvertisement";
    
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}


/// 获取启动页banner
- (void)voice_getLaunchBanner:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506416344958-1722617555-0125
    NSString *uri = @"/moli_audio_consumer/v2.1.0/advertisement/selectInitAdvertisement";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 获取首页banner
- (void)voice_getHomeBanner:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1506400786528-1722617555-0124
    NSString *uri = @"/moli_audio_consumer/v2.1.0/advertisement/selectBanner";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 解禁言用户
- (void)voice_UnGagUser {
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1507460447095-1722617555-0003
    NSString *uri = @"/moli_audio_consumer/v2/user/kickUserNoGag";
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"kickUserId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"dataType"] = @"nogag";
    
    [self postRequest:uri parameters:dic success:^(NSDictionary *result) {
        
    } failure:^(NSError *error) {
        
    }];
}

/// 删除内容原因
- (void)voice_getDeleteReason:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1508135375580-1722617555-0013
    
    NSString *uri = @"/moli_audio_consumer/v2/content/selectContentList";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 分享的模板
- (void)voice_getShareTemplate:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1509438534824-1722617555-0014
    
    NSString *uri = @"/moli_audio_consumer/v2/sharefriend/selectAllShareFriendList";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 好友私信限制接口
- (void)voice_friendLimit:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1509522706634-1722617555-0002
    
    NSString *uri = @"/moli_audio_consumer/v2/friend/selectUserIm";
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 获取活动弹层接口
- (void)voice_activityFloat:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interface/debug/ffff-1510827056300-1722617555-0004
    
    NSString *uri = @"/moli_audio_consumer/v2/alert/selectAllAlert";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}


/// 获取分享动态接口
- (void)voice_shareRandom:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/domain/getRandomDomain";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 获取检查声音内容
- (void)voice_getCheckVoiceContent:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1523257941752-1722617555-0062
    
    NSString *uri = @"/moli_audio_consumer/v2/uservoicecheck/selectVoiceCheckContent";
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 获取检查声音提交服务器
- (void)voice_checkVoiceContentToServer:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1523258076462-1722617555-0063
    NSString *uri = @"/moli_audio_consumer/v2/uservoicecheck/updateVoiceCheckContent";
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 获取投稿规则
- (void)voice_getContrbuteRule:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure
{
    NSString *uri = @"/moli_audio_consumer/v2/contribute/selectContributeContent";
    [self getRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success) {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}
@end
