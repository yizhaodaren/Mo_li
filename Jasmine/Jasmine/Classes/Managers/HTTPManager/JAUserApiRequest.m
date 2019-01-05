//
//  JAUserApiRequest.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAUserApiRequest.h"
#import <AliyunOSSiOS/OSSService.h>
#import "JACommonApi.h"
#import "JASwitchDefine.h"

#define Ali_EndPoint @"oss-cn-zhangjiakou.aliyuncs.com"

@interface JAUserApiRequest ()
@property (nonatomic, strong) OSSClient *client;
@end

@implementation JAUserApiRequest

+ (JAUserApiRequest *)shareInstance
{
    static JAUserApiRequest *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAUserApiRequest alloc] init];
        }
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 自实现签名，可以用本地签名也可以远程加签
        id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
            NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:@"R8Pf6CLZ4I2nZDbuENGfrhIWe3huA2"];
            if (error != NULL) {
                if (signature != nil) {
                    *error = nil;
                } else {
                    // construct error object
                    *error = [NSError errorWithDomain:@"com.moli.jasmine" code:OSSClientErrorCodeSignFailed userInfo:nil];
                    return nil;
                }                
            }
            return [NSString stringWithFormat:@"OSS %@:%@", @"LTAIB4bui61O93Aj", signature];
        }];
        
        
        OSSClientConfiguration * conf = [OSSClientConfiguration new];
        conf.maxRetryCount = 3; // 网络请求遇到异常失败后的重试次数
        conf.timeoutIntervalForRequest = 30; // 网络请求的超时时间
        conf.timeoutIntervalForResource = 24 * 60 * 60; // 允许资源传输的最长时间
        
        self.client = [[OSSClient alloc] initWithEndpoint:Ali_EndPoint credentialProvider:credential clientConfiguration:conf];
    }
    return self;
}


/*
     "id": 2,
     "clientName": "ios",
     "operateStat": 0,
     "serverwebUrl": "192.168.1.19",
     "imgUrl": "sdsdff",
     "clientVersion": "1.0",
     "clientType": "com.moli.jasmine",
     "updateUrl": "",
     "updateVersion": "",
     "updateContent": "",
     "isDebug": 0,
     "createTime": 1495200189000,
     "updateTime": 1495527342000
 */

//static int retryIndex = 0;
- (void)getLaunchConfig:(void (^)(NSDictionary *dictionary))success
                failure:(void(^)(NSError *error))failure
{
    NSString *host = @"http://api.imolihua.com";
#ifdef JA_TEST_HOST
    host = @"http://dev.api.yourmoli.com";
#endif
    
    NSString *uri = [NSString stringWithFormat:@"%@/moli_dataclient_consumer/v2/clienturl/selectDataClienturl", host];
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[@"clientVersion"] = [STSystemHelper getApp_version];
    parameters[@"clientName"] = @"ios";
    parameters[@"clientType"] = [STSystemHelper getApp_bundleid];
    NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if (!userId.length) {
        userId = @"0";
    }
    parameters[@"userId"] = userId;
//    NSDictionary *parameters = @{@"clientVersion":@"1.0",
//                                 @"clientName":@"ios",
//                                 @"clientType":@"com.moli.jasmine"
//                                 };
    
//    @WeakObj(self)
    // warning：dispatch_semaphore需使用异步线程
    [self get:uri parameters:parameters success:^(NSDictionary *result) {
        if (success)
        {
            success(result);
        }
        
    } failure:^(NSError *error) {
        
//        @StrongObj(self)
//        
//        if (retryIndex++ < 5)
//        {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [self getLaunchConfig:success failure:failure];
//            });
//        }
//        else
//        {
//            retryIndex = 0;
            if (failure)
            {
                failure(error);
            }
//        }
    }];
    
}

- (void)getUniversalConfig:(void (^)(NSDictionary *dictionary))success
                   failure:(void(^)(NSError *error))failure {
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1509941710974-1722617555-0003
    NSString *uri = @"/moli_audio_consumer/v2/clienturl/selectAllClientProperties";
    [self post:uri parameters:nil success:^(NSDictionary *result) {
        if (success)
        {
            success(result);
        }
        
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

// 获取accesstoken
- (void)getAccessToken:(void (^)(NSDictionary *))success failure:(void (^)(NSError *))failure {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1505284443884-1722617555-0115
    NSString *uri = @"/moli_audio_consumer/v2/login/refreshAccessToken";
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if (userId.length) {
        params[@"userId"] = userId;
    } else {
        params[@"userId"] = @"0";
    }
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        if (success)
        {
            success(result);
        }
    } failure:^(NSError *error) {
        if (failure)
        {
            failure(error);
        }
    }];
}

/// 注册账号接口
- (void)regisetUserAccount:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504092091820-1722617555-0078
    
    NSString *uri  = @"/moli_audio_consumer/v2/login/registerByPhoneSelective";
    
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
       
        successBlock(result);
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

/// 完善个人信息接口
- (void)perfectUserInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503134658635-1722617555-0024
    
    NSString *uri = @"/moli_audio_consumer/v2/login/perfectUserInfoSelective";
   
    [self postRequest:uri parameters:params success:^(NSDictionary *result) {
        
        if (successBlock) {
            
            successBlock(result);
        }

    } failure:^(NSError *error) {

        if (failureBlock) {
            failureBlock(error);
        }
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

/// 手机号登录登录
- (void)loginUserWithPhone:(NSString *)phoneNum password:(NSString *)pwd success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/login/loginSelective";
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"platformType"] = @"0";
    dic[@"password"] = pwd;
    dic[@"phone"] = phoneNum;
   dic[@"platformMark"] = JA_CHANNEL;
    [self postRequest:uri parameters:dic success:^(NSDictionary *result) {
        
            if (successBlock) {
                successBlock(result);
            }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSDictionary *dic = @{@"0":@"phone",@"1":@"qq",@"2":@"wx",@"3":@"wb"};
            [[JACommonApi shareInstance] addDataLogs_loginWithType:dic[@"0"] type_info:phoneNum];
        });
        
    } failure:^(NSError *error) {
        
        if (failureBlock) {
            failureBlock(error);
        }
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

/// 三方登录
- (void)loginUserWithPlatformType:(NSString *)type platformUid:(NSString *)platformUid accessToken:(NSString *)accessToken success:(void(^)(NSDictionary *result))successBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/login/loginSelective";
 
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"platformType"] = type;
    if (platformUid.length) {
        dic[@"platformUid"] = platformUid;
    }
    dic[@"accessToken"] = accessToken;
   dic[@"platformMark"] = JA_CHANNEL;
    [self postRequest:uri parameters:dic success:^(NSDictionary *result) {
            if (successBlock) {
                successBlock(result);
            }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            NSDictionary *dic = @{@"0":@"phone",@"1":@"qq",@"2":@"wx",@"3":@"wb"};
            [[JACommonApi shareInstance] addDataLogs_loginWithType:dic[type] type_info:accessToken];
        });
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        NSString *str = [NSString stringWithFormat:@"%@",error];
        if ([str containsString:@"Code=144444"]) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"您的账号违法了相关用户协议，已被禁用"];
        }else{
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }
        
    }];
}

/// 绑定手机
- (void)bindingPhone:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/index.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504513760082-1722617555-0102
    
    NSString *uri = @"/moli_audio_consumer/v2/login/bindingPhoneSelective";
    
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

/// 获取验证码
- (void)getVerifyCodeWithPhone:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503135303864-1722617555-0026
    
    NSString *uri = @"/moli_audio_consumer/v2/login/getPhoneAuth";
    
//        uri = @"http://192.168.1.28:8081/moli_mine_consumer/v1/login/getPhoneAuth";
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

/// 检查验证码
- (void)checkVerifyCodeWithPhone:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503135134841-1722617555-0025
    
    NSString *uri = @"/moli_audio_consumer/v2/login/checkPhoneAuthCommon";

//              uri = @"http://192.168.1.28:8081/moli_mine_consumer/v1/login/checkPhoneAuthCommon";
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

/// 验证姓名
- (void)checkUserNameWithName:(NSString *)name success:(void(^)())successBlock failure:(void(^)())failureBlock
{
   NSString *uri = @"/moli_audio_consumer/v2/login/findUserNameInfoExists";
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"name"] = name;
    
    [self postRequest:uri parameters:dic success:^(NSDictionary *result) {
        if (successBlock) {
            successBlock();
        }
    } failure:^(NSError *error) {
       
        [ [[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"昵称重复"];
    }];
}

/// 重置密码
- (void)resetPasswordWithPara:(NSDictionary *)dic success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/login/resetPasswordSelective";
    
    [self postRequest:uri parameters:dic success:^(NSDictionary *result) {
        
        if (successBlock) {
            successBlock(result);
        }
    } failure:^(NSError *error) {
        if (failureBlock) {
            failureBlock(error);
        }
        
    }];
}
/// 上传头像
- (void)upLoadUserIcon:(UIImage *)image finish:(void(^)(NSDictionary *result))finishedBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/fileCommonUpload/uploadFile";
    
//              uri = @"http://192.168.1.20:8082/moli_discover_consumer/v1/fileCommonUpload/uploadFile";
    
    
    NSData *data = UIImageJPEGRepresentation(image, 1.0);
    
    [self upLoadFile:uri parameter:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        if (data) {
            
            [formData appendPartWithFileData:data name:@"Filedata" fileName:[@"moli_user_icon" stringByAppendingString:@".jpg"] mimeType:@"image/jpg"];
        }
        
    } success:^(NSDictionary *result) {
       
        NSLog(@"上传头像成功");
        if (finishedBlock) {
            
            finishedBlock(result);
        }
    } failure:^(NSError *error) {
        NSLog(@"上传头像失败 %@",error);
        if (finishedBlock) {
            finishedBlock(nil);
        }
    }];
    
}

- (void)upLoadData:(NSData *)data finish:(void(^)(NSDictionary *result))finishedBlock {
    [self upLoadData:data fileType:@"mp3" finish:finishedBlock];
}

- (void)upLoadData:(NSData *)data fileType:(NSString *)fileType finish:(void(^)(NSDictionary *result))finishedBlock {
    NSString *uri = @"/moli_audio_consumer/v2/fileCommonUpload/uploadFile";
    [self upLoadFile:uri parameter:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        if (data) {
            [formData appendPartWithFileData:data name:@"Filedata" fileName:[NSString stringWithFormat:@"moli_user_music.%@",fileType] mimeType:fileType];
        }
    } success:^(NSDictionary *result) {
        NSLog(@"上传文件成功");
        if (finishedBlock) {
            finishedBlock(result);
        }
    } failure:^(NSError *error) {
        NSLog(@"上传文件失败 %@",error);
        if (finishedBlock) {
            finishedBlock(nil);
        }
    }];
}

/// 签到接口
- (void)userSign:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503135407713-1722617555-0027
    
    NSString *uri = @"/moli_audio_consumer/v2/signlogin/insertSignLogin";
    
    
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

/// 签到信息接口
- (void)userSignInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503123765596-1722617555-0022
    
    NSString *uri = @"/moli_audio_consumer/v2/user/selectSignInfo";
    
    
    
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

/// 红包列表 - 未拆红包
- (void)userAllPacketList:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503404167171-1722617555-0032
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/redPackageList";
    
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

/// 开启红包
- (void)userOpenPacket:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503404258938-1722617555-0033
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/openRedPackage";
    
    
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

/// 邀请绑定
- (void)userInviteBinding:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503395406871-1722617555-0029
    
    NSString *uri = @"/moli_audio_consumer//v2/invite/inviteRegisterBinding";
    
    
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

/// 邀请记录
- (void)userInviteRecord:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503394101107-1722617555-0028
    
    NSString *uri = @"/moli_audio_consumer//v2/invite/selectInviteRegisterPage";
    
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

/// 唤醒好友列表
- (void)userCallInviteFriend:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1515466163415-1722617555-0014
    
    NSString *uri = @"/moli_audio_consumer/v2/invite/selectInviteRegisterAwakenList";
    
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

/// 唤醒好友操作
- (void)userCallInviteFriendAction:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1515466305506-1722617555-0015
    
    NSString *uri = @"/moli_audio_consumer/v3/awaken/insertAwaken";
    
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

/// 兑换前数据准备
- (void)userExchangeInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503404002866-1722617555-0030
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/selectConvertInfo";
    
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

/// 新的兑换
- (void)userNewExchangeMoney:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/wallet/insertConvertNew";
    
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

/// 兑换
- (void)userExchangeMoney:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503404097169-1722617555-0031
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/insertConvert";
    
    
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

/// 提现
- (void)userWithDrawMoney:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503404343945-1722617555-0034
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/depositMoney";
    
    
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

/// 收支明细
- (void)userWithDrawInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//   http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503404487120-1722617555-0035
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/moneyDetailed";
    
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

/// 绑定三方
- (void)userWithDrawBindingPlatform:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503475293548-1722617555-0036
    
    NSString *uri = @"/moli_audio_consumer/v2/login/bindingWxSelective";
                      
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

/// 解除绑定三方
- (void)userWithDrawUnbindingPlatform:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interface/debug/ffff-1507880303059-1722617555-0008
    NSString *uri = @"/moli_audio_consumer/v2/user/userRelieveBinding";
    
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

/// 提现记录
- (void)userWithDrawRecord:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
//    http://doc.java.yourmoli.com/api/project.do#/ffff-1500554649851-1722617555-0002/front/interfaceDetail/ffff-1503481022708-1722617555-0037
    
    NSString *uri = @"/moli_audio_consumer/v2/wallet/depositRecord";
    
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


/// 分享注册信息
- (void)userShareInviteInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{

//    http://doc.java.yourmoli.com/api/project.do#/ffff-1504077160787-1722617555-0003/front/interfaceDetail/ffff-1504091032836-1722617555-0067
    
    NSString *uri = @"/moli_audio_consumer//v2/invite/selectInviteRegisterUrl";
    
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

/// 分享小程序
- (void)userShareMiniInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/clienturl/selectClientPropertiesByType";
    
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

/// 邀请规则
- (void)userInviteRuleInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock
{
    NSString *uri = @"/moli_audio_consumer/v2/content/selectActivityAndTaskContentList";
    
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

/// 获取信用分
- (void)userCreditInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1507799901528-1722617555-0005
    NSString *uri = @"/moli_audio_consumer/v2/integral/selectIntegralList";
    
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

/// 获取信举报原因
- (void)userReportInfo:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interface/debug/ffff-1507884183805-1722617555-0009
    NSString *uri = @"/moli_audio_consumer/v2/reportinfo/selectReportInfo";
    
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

/// 查詢经验操作记录、信用记录
- (void)userRecordList:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1507803581935-1722617555-0007
    NSString *uri = @"/moli_audio_consumer/v2/integralrecord/selectIntegralRecordList";
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

/// 获取等级列表
- (void)userLevelList:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/index.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1507797540476-1722617555-0004
    NSString *uri = @"/moli_audio_consumer/v2/grade/selectGradeList";
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

/// 根据用户id查询当天的发的数
- (void)userReleaseCount:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1507800515229-1722617555-0006
    NSString *uri = @"/moli_audio_consumer/v2/story/selectStoryCount";
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

/// 查询用户在帖子下是否匿名接口
- (void)userAnonymousStatus:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1508126897508-1722617555-0012
    NSString *uri = @"/moli_audio_consumer/v2/story/selectUserIsAnonymousStatus";
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

// 上传用户图片到阿里云
- (void)ali_upLoadUserIcon:(NSArray *)images isAsync:(BOOL)isAsync complete:(void(^)(NSArray<NSString *> *names, BOOL state))complete
{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = images.count;
    
    NSMutableArray *callBackNames = [NSMutableArray array];
    NSMutableArray *resultNames = [NSMutableArray array];
    
    int i = 0;
    for (UIImage *image in images) {
        if (image) {
            NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
                //任务执行
                OSSPutObjectRequest * put = [OSSPutObjectRequest new];
                put.bucketName = @"moli2017";
                NSString *deviceId = [[NSUUID UUID] UUIDString];
                NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
                // 毫秒值+随机字符串+文件类型
                NSString *imageName = [NSString stringWithFormat:@"file/iOS_%lld%@.%@",(long long)interval,deviceId,@"jpg"];
                put.objectKey = imageName;
                [callBackNames addObject:imageName];
                NSData *data = [NSData reSizeImageData:image maxImageSize:JA_SCREEN_HEIGHT maxSizeWithKB:300];
                
                put.uploadingData = data;
                
                OSSTask * putTask = [self.client putObject:put];
                [putTask waitUntilFinished]; // 阻塞直到上传完成
                if (!putTask.error) {
//                    NSLog(@"upload object success!");
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *imageUrl = [NSString stringWithFormat:@"http://file.xsawe.top/%@",put.objectKey];
                        [resultNames addObject:imageUrl];
                       
                    });
                } else {
                    
                }
                
                if (isAsync) {
                    if (image == images.lastObject) {
//                        NSLog(@"upload object finished!");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (complete) {
                                complete(resultNames ,YES);
                            }
                        });
                    }
                }
            }];
            if (queue.operations.count != 0) {
                [operation addDependency:queue.operations.lastObject];
            }
            [queue addOperation:operation];
        }
        i++;
    }
    if (!isAsync) {
        [queue waitUntilAllOperationsAreFinished];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (complete) {
                complete(resultNames ,YES);
            }
        });
    }
}

- (void)ali_upLoadData:(NSData *)data fileType:(NSString *)fileType finish:(void(^)(NSString *filePath))finishedBlock {
    [self ali_upLoadData:data fileType:fileType progress:nil finish:finishedBlock];
}

- (void)ali_upLoadData:(NSData *)data fileType:(NSString *)fileType progress:(void(^)(NSUInteger totalByteSent))progress finish:(void(^)(NSString *filePath))finishedBlock {
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    // 必填字段
    put.bucketName = @"moli2017";
    NSString *deviceId = [[NSUUID UUID] UUIDString];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    // 毫秒值+随机字符串+文件类型
    NSString *filePath = [NSString stringWithFormat:@"file/iOS_%lld%@.%@",(long long)interval,deviceId,fileType];
    put.objectKey = filePath;
    put.uploadingData = data; // 直接上传NSData
    // 可选字段，可不设置
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        // 当前上传段长度、当前已经上传总长度、一共需要上传的总长度
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        if (progress) {
            progress(totalByteSent);
        }
    };
    if (fileType.length) {
        NSDictionary *fileTypesByMimeType =
        @{
          @"mp3": @"audio/mpeg",
          @"wav": @"audio/wav",
          @"aifc": @"audio/aifc",
          @"aiff": @"audio/aiff",
          @"m4a": @"audio/x-m4a",
          @"mp4": @"audio/x-mp4",
          @"caf": @"audio/caf",
          @"aac": @"audio/aac",
          @"ac3": @"audio/ac3",
          @"3gp": @"audio/3gp"
          };
        NSString *contentType = fileTypesByMimeType[fileType];
        if (contentType.length) {
            put.contentType = contentType;
        }
    }
    OSSTask * putTask = [self.client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!task.error) {
                //                NSLog(@"upload object success!");
                NSString *imageUrl = [NSString stringWithFormat:@"http://file.xsawe.top/%@",put.objectKey];
                if (finishedBlock) {
                    finishedBlock(imageUrl);
                }
            } else {
                //                NSLog(@"upload object failed, error: %@" , task.error);
                if (finishedBlock) {
                    finishedBlock(nil);
                }
            }
        });
        return nil;
    }];
}

// v2.6.2
/// 查询口令码
- (void)userSelectCommand:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1523258640361-1722617555-0065
    NSString *uri = @"/moli_audio_consumer/v2/command/selectCommand";
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

/// 领取口令码奖励
- (void)userUpdateComand:(NSDictionary *)params success:(void(^)(NSDictionary *result))successBlock failure:(void(^)(NSError *error))failureBlock {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1506161487637-1722617555-0004/front/interfaceDetail/ffff-1523258977073-1722617555-0066
    NSString *uri = @"/moli_audio_consumer/v2/command/updateCommand";
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

@end
