//
//  JALoginManager.m
//  Jasmine
//
//  Created by xujin on 04/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JALoginManager.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "AppDelegate.h"
#import "WeiboSDK.h"
#import "WXApi.h"

@interface JALoginManager ()

@property (nonatomic, weak) UIViewController *controller;
@end

@implementation JALoginManager

static JALoginManager *instance = nil;
+ (JALoginManager *)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JALoginManager alloc] init];
            
        }
    });
    return instance;
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}
- (id)copyWithZone:(NSZone *)zone
{
    return instance;
}


#pragma mark - 三方登录
//qq登录
- (void)qqLogin
{
    
//    [self loginWithPlatformType:UMSocialPlatformType_QQ source:@"qq"];
    NSArray* permissions = [NSArray arrayWithObjects:
                            kOPEN_PERMISSION_GET_USER_INFO,
                            kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,
                            kOPEN_PERMISSION_ADD_SHARE,
                            nil];
    
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.tencentOAuth authorize:permissions inSafari:NO];
}


//微信登录
- (void)weChatLogin
{
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc ] init ];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
//    [WXApi sendReq:req];
    [WXApi sendAuthReq:req viewController:self.vc delegate:nil];
//    [self loginWithPlatformType:UMSocialPlatformType_WechatSession source:@"weixin"];
}
//sina登录
- (void)sinaLogin
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://sns.whalecloud.com";
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"ViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
//    [self loginWithPlatformType:UMSocialPlatformType_Sina source:@"sina"];
}

- (void)getWechatUnionID:(NSString *)accessToken openid:(NSString *)openid completeBlock:(void(^)(NSString *unionid))complete
{
    
    NSDictionary *dict = @{@"access_token":accessToken,
                           @"openid": openid};
    AFHTTPSessionManager * sessionManger = [AFHTTPSessionManager manager];
    sessionManger.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    
    [sessionManger GET:@"https://api.weixin.qq.com/sns/userinfo" parameters:dict progress:nil success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary*  _Nonnull responseObject) {
        if(complete)
        {
            complete(responseObject[@"unionid"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"123456%@",error);
    }];
}
//- (void)loginWithPlatformType:(UMSocialPlatformType)type source:(NSString *)source
//{
//    // 统计事件
////    [MobClick event:[NSString stringWithFormat:@"%@Login", source]]; //sina登录次数
//    @WeakObj(self)
//    [[UMSocialManager defaultManager] getUserInfoWithPlatform:type currentViewController:self.controller completion:^(id result, NSError *error) {
//        @StrongObj(self)
//        
//        if (result)
//        {
//            int sex = 0;
//            UMSocialUserInfoResponse *response = (UMSocialUserInfoResponse *)result;
//            if ([response.gender isEqualToString:@"m"] ||
//                [response.gender isEqualToString:@"男"])
//            {
//                sex = 1;
//            }
//            
//            if(type == UMSocialPlatformType_Sina)
//            {
//                response.openid = response.uid;
//            }
//            
//            if (type == UMSocialPlatformType_WechatSession)
//            {
//                // 获取unionid
//                [self getWechatUnionID:response.accessToken openid:response.openid completeBlock:^(NSString *unionid) {
//                    
//                    [self thirdLogin:response.openid token:response.accessToken channel:@"ios" source:source  headImage:response.iconurl sex:sex nickName:response.name unionId:unionid event:[NSString stringWithFormat:@"%@LoginSuccess", source]];
//                }];
//            }
//            else
//            {
//                [self thirdLogin:response.openid token:response.accessToken channel:@"ios" source:source  headImage:response.iconurl sex:sex nickName:response.name unionId:@"" event:[NSString stringWithFormat:@"%@LoginSuccess", source]];
//            }
//            
//        }
//        else if(error)
//        {
//    
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//                if (error.code == UMSocialPlatformErrorType_AuthorizeFailed)
//                {
//                    NSLog(@"登录失败");
//                }
//                else if (error.code == UMSocialPlatformErrorType_RequestForUserProfileFailed)
//                {
//                    NSLog(@"请求用户信息失败");
//                }
//                else if (error.code == UMSocialPlatformErrorType_Cancel)
//                {
//                    NSLog(@"取消登录");
//                }
//                else
//                {
//                    NSLog(@"网络异常");
//                }
//                
//            });
//            
//        }
//    }];
//}

- (void)thirdLogin:(NSString *)openID token:(NSString *)accessToken channel:(NSString *)channel source:(NSString *)source headImage:(NSString *)headImage sex:(int)sex nickName:(NSString *)nickName unionId:(NSString *)unionId event:(NSString *)event
{
    
    
}

- (void)loginWithType:(JALoginType)type
{
    switch (type)
    {
        case JALoginType_QQ:
            [self qqLogin];
            break;
            
        case JALoginType_Wechat:
            [self weChatLogin];
            break;
            
        case JALoginType_Weibo:
            [self sinaLogin];
            break;
            
        case JALoginType_Phone:
        {
            //  等待实现
            break;
        }
            break;
        default:
            break;
    }
    
}

// 手机登录
- (void)loginWithPhone:(NSString *)phone code:(NSString *)code completeBlock:(void(^)(void))completeBlock
{
//    [MobClick event:@"otherLogin"];
    NSLog(@"正在登录...");
    
}



// 获取验证码
- (void)getVerfiyCodeWithPhone:(NSString *)phone
{
}

@end
