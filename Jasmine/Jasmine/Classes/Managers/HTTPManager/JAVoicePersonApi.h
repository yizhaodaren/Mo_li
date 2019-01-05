//
//  JAVoicePersonApi.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JAVoicePersonApi : JABaseApiRequest

+ (instancetype)shareInstance;

/// 个人主页信息
- (void)voice_personalInfoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 查看用户相册
- (void)voice_personalPhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 修改用户相册
- (void)voice_personalUpdatePhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 管理员修改用户相册
- (void)voice_adminUpdatePhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 管理员修改用户头像
- (void)voice_adminUpdateIconWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 管理员修改帖子图片
- (void)voice_adminUpdateVoicePicWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 用户首次上传相册
- (void)voice_personalUpLoadPhotoWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 关注用户
- (void)voice_personalFocusUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 取消关注用户
- (void)voice_personalCancleFocusUseroWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 查询两人的关注状态
- (void)voice_personalRelationParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 查询用户关注粉丝列表
- (void)voice_personalFocusAndFansParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 添加黑名单
- (void)voice_personalAddBlackUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 移除黑名单
- (void)voice_personalDeleteBlackUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 举报用户
- (void)voice_personalReportUserWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 帮助中心
- (void)voice_helperWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 任务接口
- (void)voice_taskWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 活动接口
- (void)voice_activityWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 评审故事列表
- (void)voice_checkPostsWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 评审评论列表
- (void)voice_checkCommentWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 审核区评审故事
- (void)voice_actionPostsWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 审核区评审评论
- (void)voice_actionCommentWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 列表评审故事列表
- (void)voice_listCheckPostsWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 列表评审评论列表
- (void)voice_listCheckCommentWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 冻结花朵详情
- (void)voice_checkFlowerWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 匿名开关
- (void)voice_anonymitySwitchWithPara:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 收藏帖子列表接口
- (void)voice_personCollectListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
/// 收藏取消收藏帖子接口
- (void)voice_insertCollectListWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
/// 查询是否收藏帖子接口
- (void)voice_collectStatusWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 添加不喜欢内容记录
- (void)voice_insertDislikeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取茉莉君信息
- (void)voice_getMoliJunTask:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取我的投稿列表
- (void)voice_getMyContribute:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 领取茉莉君奖励
- (void)voice_getMoliJunReward:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
@end
