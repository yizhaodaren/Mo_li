//
//  JAUserApiRequest.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"

@interface JAUserApiRequest : JABaseApiRequest



+ (JAUserApiRequest *)shareInstance;

- (void)getLaunchConfig:(void (^)(NSDictionary *dictionary))success
                failure:(void(^)(NSError *error))failure;

- (void)getUniversalConfig:(void (^)(NSDictionary *dictionary))success
                failure:(void(^)(NSError *error))failure;

// 获取accesstoken
- (void)getAccessToken:(void (^)(NSDictionary *dictionary))success
failure:(void(^)(NSError *error))failure;

/// 注册账号接口
- (void)regisetUserAccount:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 完善个人信息接口 - 编辑用户资料
- (void)perfectUserInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 绑定手机
- (void)bindingPhone:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 获取验证
- (void)getVerifyCodeWithPhone:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 验证验证
- (void)checkVerifyCodeWithPhone:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 验证姓名 -- 暂时没用
- (void)checkUserNameWithName:(NSString *)name success:(void(^)())successBlock failure:(void(^)())failureBlock;

/// 手机号登录登录
- (void)loginUserWithPhone:(NSString *)phoneNum password:(NSString *)pwd success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 三方登录
- (void)loginUserWithPlatformType:(NSString *)type platformUid:(NSString *)platformUid accessToken:(NSString *)accessToken success:(void(^)(NSDictionary *result))successBlock;

/// 上传头像
- (void)upLoadUserIcon:(UIImage *)image finish:(void(^)(NSDictionary *result))finishedBlock;

/// 上传用户照片到阿里云
- (void)ali_upLoadUserIcon:(NSArray *)images isAsync:(BOOL)isAsync complete:(void(^)(NSArray<NSString *> *names, BOOL state))complete;

/// 上传文件
- (void)upLoadData:(NSData *)data finish:(void(^)(NSDictionary *result))finishedBlock;
- (void)upLoadData:(NSData *)data fileType:(NSString *)fileType finish:(void(^)(NSDictionary *result))finishedBlock;

/// 直接上传文件到阿里云
- (void)ali_upLoadData:(NSData *)data fileType:(NSString *)fileType finish:(void(^)(NSString *filePath))finishedBlock;
- (void)ali_upLoadData:(NSData *)data fileType:(NSString *)fileType progress:(void(^)(NSUInteger totalByteSent))progress finish:(void(^)(NSString *filePath))finishedBlock;

/// 重置密码
- (void)resetPasswordWithPara:(NSDictionary *)dic success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 签到接口
- (void)userSign:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 签到接口
- (void)userSignInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 红包列表 - 未拆红包
- (void)userAllPacketList:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 开启红包
- (void)userOpenPacket:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 邀请绑定
- (void)userInviteBinding:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 邀请记录
- (void)userInviteRecord:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 唤醒好友列表
- (void)userCallInviteFriend:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 唤醒好友操作
- (void)userCallInviteFriendAction:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 兑换前数据准备
- (void)userExchangeInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 兑换
- (void)userExchangeMoney:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 新的兑换
- (void)userNewExchangeMoney:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 提现
- (void)userWithDrawMoney:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 收支明细
- (void)userWithDrawInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;


/// 绑定三方
- (void)userWithDrawBindingPlatform:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 解除绑定三方
- (void)userWithDrawUnbindingPlatform:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 提现记录
- (void)userWithDrawRecord:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 分享注册信息
- (void)userShareInviteInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 分享小程序
- (void)userShareMiniInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 邀请规则
- (void)userInviteRuleInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 获取信用分
- (void)userCreditInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 获取信举报原因 (被合并为其他接口了)
- (void)userReportInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 查询经验操作记录、信用记录
- (void)userRecordList:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 获取等级列表
- (void)userLevelList:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 根据用户id查询当天的发的数
- (void)userReleaseCount:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 查询用户在帖子下是否匿名接口
- (void)userAnonymousStatus:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

// v2.6.2
/// 查询口令码
- (void)userSelectCommand:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

/// 领取口令码奖励
- (void)userUpdateComand:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock;

@end
