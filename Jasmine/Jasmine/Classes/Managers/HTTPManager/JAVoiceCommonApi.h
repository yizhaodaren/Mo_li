//
//  JAVoiceCommonApi.h
//  Jasmine
//
//  Created by moli-2017 on 2017/9/2.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JAVoiceCommonApi : JABaseApiRequest

+ (JAVoiceCommonApi *)shareInstance;

/// 获取茉莉君官方信息
- (void)voice_getOffic:(NSDictionary *)dic success:(void(^)(NSDictionary *result))successBlock failure:(void(^)())failureBlock;

/// 获取茉莉君官方未读信息
- (void)voice_getOfficDetailInfo:(NSDictionary *)dic success:(void(^)(NSDictionary *result))successBlock failure:(void(^)())failureBlock;


/// 邀请 关注列表
- (void)voice_inviteFocusWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 邀请 推荐列表
- (void)voice_inviteRecommentWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 随机邀请
- (void)voice_inviteRandomWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 邀请接口
- (void)voice_inviteAddWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 点赞接口
- (void)voice_agreeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 个人赞过的内容
- (void)voice_contentOfAgreeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 搜索
- (void)voice_searchWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 主帖加精
- (void)voice_voiceCreamWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 评论加神
- (void)voice_commentCreamWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 封停用户
- (void)voice_userBanWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 客户端、播放、跳过、分享，调用此接口
- (void)voice_appCommonWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 分享收入 - 完成任务接口
- (void)voice_appShareIncomeWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 分享注册链接 - 完成任务接口
- (void)voice_appShareRegistTaskWithParas:(NSDictionary *)paras success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取邀请页banner
- (void)voice_getBanner:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取启动页banner
- (void)voice_getLaunchBanner:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取首页banner
- (void)voice_getHomeBanner:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 解禁言用户
- (void)voice_UnGagUser;

/// 删除内容原因
- (void)voice_getDeleteReason:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 分享的模板
- (void)voice_getShareTemplate:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 好友私信限制接口
- (void)voice_friendLimit:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取活动弹层接口
- (void)voice_activityFloat:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取分享动态接口
- (void)voice_shareRandom:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取检查声音内容
- (void)voice_getCheckVoiceContent:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取检查声音提交服务器
- (void)voice_checkVoiceContentToServer:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;

/// 获取投稿规则
- (void)voice_getContrbuteRule:(NSDictionary *)params success:(void (^)(NSDictionary *result))success failure:(void (^)(NSError *error))failure;
@end
