//
//  JABaseApiRequest.m
//  Jasmine
//
//  Created by xujin on 02/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseApiRequest.h"
#import "NSString+URLEncode.h"
#import "Reachability.h"
#import "JAIMManager.h"
#import "JAAudioRecorder.h"
#import "JAUserApiRequest.h"
#import "AppDelegateModel.h"
#import "NSString+Extention.h"

@interface JABaseApiRequest ()

@end

@implementation JABaseApiRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        [JABaseApiRequest httpSessionManager];
    }
    return self;
}

static AFHTTPSessionManager *manager = nil;
+ (AFHTTPSessionManager *)httpSessionManager
{
    if (manager == nil)
    {
        manager = [AFHTTPSessionManager manager];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];

        manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
//        [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        [manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
        manager.requestSerializer.timeoutInterval = 30;
        
        // 新版AFNetworking bug
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",@"text/plain", nil];
    }
  
    return manager;
}

/// 上传
- (void)upLoadFile:(NSString *)uri parameter:(NSDictionary *)para constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void(^)(NSDictionary *result))success failure:(void(^)(NSError *error))failure
{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"text/json", @"image/jpg", nil];
     NSString *url = [self urlWithURI:uri];
    
    [[JABaseApiRequest httpSessionManager] POST:url parameters:para constructingBodyWithBlock:block progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self handleResponse:task responseObject:responseObject callbackOnMainThread:YES success:success failure:failure];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleFailure:task error:error callbackOnMainThread:YES failure:failure];
    }];
}

- (BOOL)get:(NSString *)uri
 parameters:(NSDictionary *)parameters
    success:(void(^)(NSDictionary *result))success
    failure:(void(^)(NSError *error))failure
{
    return [self get:uri parameters:parameters callbackOnMainThread:NO success:success failure:failure];
}

- (BOOL)post:(NSString *)uri
  parameters:(id)parameters
    success:(void(^)(NSDictionary *result))success
    failure:(void(^)(NSError *error))failure
{
    return [self post:uri parameters:parameters callbackOnMainThread:NO success:success failure:failure];
}

- (BOOL)getRequest:(NSString *)uri
        parameters:(NSDictionary *)parameters
           success:(void(^)(NSDictionary *result))success
           failure:(void(^)(NSError *error))failure
{
    return [self get:uri parameters:parameters callbackOnMainThread:YES success:success failure:failure];
}

- (BOOL)postRequest:(NSString *)uri
         parameters:(id)parameters
            success:(void(^)(NSDictionary *result))success
            failure:(void(^)(NSError *error))failure
{
    return [self post:uri parameters:parameters callbackOnMainThread:YES success:success failure:failure];
}


- (NSString *)urlWithURI:(NSString *)uri
{
    if ([uri containsString:@"http"])
    {
        return uri;
    }
    else
    {
        uri = [NSString stringWithFormat:@"%@%@",[JAConfigManager shareInstance].host ,uri];
        return uri;
    }
}

- (void)handleResponse:(NSURLSessionDataTask *)task
        responseObject:(id)responseObject
  callbackOnMainThread:(BOOL)onMainThread
               success:(void(^)(NSDictionary *result))success
               failure:(void(^)(NSError *error))failure
{
    
#if DEBUG
    // 打印URL
//    if ([task.currentRequest.URL.absoluteString rangeOfString:@"/skim"].location == NSNotFound &&
//        [task.currentRequest.URL.absoluteString rangeOfString:@"/moli_quartz"].location == NSNotFound ) {
//        
//        NSMutableDictionary *dic = nil;
//        if ([task.currentRequest.HTTPMethod isEqualToString:@"GET"]) {
//            dic = [task.currentRequest.URL.query getURLParameters];
//        } else  {
//            NSString *queryString = [[NSString alloc] initWithData:task.originalRequest.HTTPBody encoding:NSUTF8StringEncoding];
//            dic = [queryString getURLParameters];
//        }
//        NSLog(@"\n****************** Request URL ******************\n%@"
//              "\n****************** Request Params(%@) ******************\n%@"
//              "\n****************** Response ******************\n%@\n",
//              task.currentRequest.URL.absoluteString,
//              task.currentRequest.HTTPMethod,
//              dic,
//              responseObject);
//    }
#endif
    if (success)
    {
        NSDictionary *dictionary = responseObject;
        
        if ([dictionary[@"code"] integerValue] == 10000 ||
            [dictionary[@"code"] integerValue] == 123700 ||
            [dictionary[@"code"] integerValue] == 140006) {
            
            NSDictionary *res = dictionary[@"res"];
//            NSArray *array = dictionary[@"list"];
            
                if (onMainThread)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        success(res);
                    });
                }
                else
                {
                    success(res);
                }
            
        }
        else
        {
            NSString *messag = dictionary[@"message"];
            if (messag == nil || [messag isKindOfClass:[NSString class]] == NO)
            {
                messag = @"";
            }
            if ([dictionary[@"code"] integerValue] == 11000) {
                messag = @"服务器开小差了，请稍后再试";
            }
            NSInteger code = [[NSString stringWithFormat:@"%@", dictionary[@"code"]] integerValue];
            
            NSError *error = [NSError errorWithDomain:@"com.moli.jasmine"
                                                 code:code
                                             userInfo:@{NSLocalizedDescriptionKey:messag}];
            if (failure)
            {
                if (onMainThread)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        failure(error);
                    });
                }
                else
                {
                    failure(error);
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([dictionary[@"code"] integerValue] ==10013) {
                    //                            [self constraintLoginout];
                    [JAAPPManager app_loginOut];
                } else if ([dictionary[@"code"] integerValue] ==140011) {
                    [JAUserInfo userinfo_saveUserToken:nil];
                    [JAUserInfo userinfo_saveUserAccdessTime:nil];
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请重新操作"];
                } else if ([dictionary[@"code"] integerValue] == 200007) {
                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:messag];
                }
            });
        }
    }
}
- (void)handleFailure:(NSURLSessionDataTask *)task
                error:(NSError *)error
 callbackOnMainThread:(BOOL)onMainThread
              failure:(void(^)(NSError *error))failure
{
#if DEBUG

    // 打印出错URL
//    NSLog(@"++++Request URL++++\n%@\n",task.currentRequest.URL.absoluteString);
//    NSLog(@"getHTTPRequest error:%@", error);
#endif

//    [MobClick event:@"ios_http_error" attributes:error.userInfo];
    if (failure)
    {
        if (onMainThread)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(error);
            });
        }
        else
        {
            failure(error);
        }
    }
}

static int retryIndex = 0;

// 设置http header
- (void)setupHttpHeader:(id)parameters {
    @synchronized (self) {
        // 设置自定义请求头
        NSString *distinctId = [[SensorsAnalyticsSDK sharedInstance] distinctId];
        if (distinctId.length) {
            [manager.requestSerializer setValue:distinctId forHTTPHeaderField:@"distinctId"];//神策
        }
        [manager.requestSerializer setValue:[STSystemHelper getApp_version] forHTTPHeaderField:@"versionmoli"];//版本号 需要加密
        [manager.requestSerializer setValue:JA_PLATFORM forHTTPHeaderField:@"phonetype"];//手机类型 需要加密
        [manager.requestSerializer setValue:JA_CHANNEL forHTTPHeaderField:@"platformmoli"];//渠道标示 需要加密
        NSString *longitude = [NSString stringWithFormat:@"%.6f", [JAConfigManager shareInstance].location.coordinate.longitude];
        NSString *latitude = [NSString stringWithFormat:@"%.6f", [JAConfigManager shareInstance].location.coordinate.latitude];
        if (![JAConfigManager shareInstance].location) {
            longitude = @"0.0";
            latitude = @"0.0";
        }
        [manager.requestSerializer setValue:longitude forHTTPHeaderField:@"longitude"];//经度
        [manager.requestSerializer setValue:latitude forHTTPHeaderField:@"latitude"];//纬度
        [manager.requestSerializer setValue:[STSystemHelper getDeviceID] forHTTPHeaderField:@"phoneid"];//设备ID 需要加密
        NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        if (!userId.length) {
            userId = @"0";
        }
        [manager.requestSerializer setValue:userId forHTTPHeaderField:@"uid"];//自己的uid 没有登录情况下传0 不能为null 或空字符串

//        NSString *token = [JAUserInfo userInfo_getUserImfoWithKey:User_AccessToken];
//        NSString *allPara = [NSString sortKey:parameters];
//        if (!allPara.length) {
//            allPara = @"";
//        }
//        allPara = [allPara stringByAppendingString:[STSystemHelper getApp_version]];
//        allPara = [allPara stringByAppendingString:JA_PLATFORM];
//        allPara = [allPara stringByAppendingString:JA_CHANNEL];
//        allPara = [allPara stringByAppendingString:[STSystemHelper getDeviceID]];
//        NSData *nsdata = [allPara dataUsingEncoding:NSUTF8StringEncoding];
//        NSString *base64Encoded = [nsdata base64EncodedStringWithOptions:0];
//        NSString *sign = [NSString paraMd5:token.length?token:@"" para:base64Encoded];
//        [manager.requestSerializer setValue:sign forHTTPHeaderField:@"sign"];//加密字符串

        NSTimeInterval dealD = [[JAUserInfo userInfo_getUserImfoWithKey:User_DisTime] doubleValue];
        if (dealD != 0) {
            NSDate*date1 = [NSDate dateWithTimeIntervalSinceNow:-dealD];
            long long localTime = [date1 timeIntervalSince1970]*1000;
            [manager.requestSerializer setValue:[NSString stringWithFormat:@"%lld",localTime] forHTTPHeaderField:@"sendtime"];
        } else {
            [manager.requestSerializer setValue:@"" forHTTPHeaderField:@"sendtime"];
        }
   
        // 新版本header
        NSString *secretKey = @"PaQhbHy3XbH";
        NSString *version = [STSystemHelper getApp_version];
        NSString *userid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
        NSString *timestamp = [NSString stringWithFormat:@"%lld",(long long)interval];
        NSString *uuid = [[NSUUID UUID] UUIDString];
        uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSString *str1 = [secretKey md5_origin];
        NSString *str2 = [[NSString stringWithFormat:@"%@%@",version,JA_PLATFORM] md5_origin];
        NSString *str3 = [[NSString stringWithFormat:@"%@%@",distinctId.length?distinctId:@"",userid.length?userid:@""] md5_origin];
        NSString *ticket = [[NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,timestamp] md5_origin];

        [manager.requestSerializer setValue:version forHTTPHeaderField:@"x-version"];
        [manager.requestSerializer setValue:distinctId.length?distinctId:nil forHTTPHeaderField:@"x-device-id"];
        [manager.requestSerializer setValue:JA_PLATFORM forHTTPHeaderField:@"x-platform"];
        [manager.requestSerializer setValue:userid.length?userid:nil forHTTPHeaderField:@"x-user-id"];
        [manager.requestSerializer setValue:timestamp forHTTPHeaderField:@"x-timestamp"];
        //x-ticket-{uuid}=md5(md5(secretKey)+md5(version+platform)+md5(deviceId+userId)+timestamp)
        [manager.requestSerializer setValue:ticket forHTTPHeaderField:@"x-ticket"];
    }
}

- (BOOL)get:(NSString *)uri
 parameters:(NSDictionary *)parameters
callbackOnMainThread:(BOOL)onMainThread
    success:(void(^)(NSDictionary *result))success
    failure:(void(^)(NSError *error))failure
{
    return [self checkTokenOfGet:uri parameters:parameters callbackOnMainThread:onMainThread success:success failure:failure token:nil];
}

- (BOOL)checkTokenOfGet:(NSString *)uri
              parameters:(id)parameters
    callbackOnMainThread:(BOOL)onMainThread
                 success:(void(^)(NSDictionary *result))success
                 failure:(void(^)(NSError *error))failure
                   token:(NSString *)token {
    [self setupHttpHeader:parameters];
    
    //判断时候有网
    BOOL network = YES;
    if ([self checkNetwork:failure])
    {
        NSString *url = [self urlWithURI:uri];
        
        if ([url hasPrefix:@"http"])
        {
            @WeakObj(self)
            [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                @StrongObj(self)
                [self handleResponse:task responseObject:responseObject callbackOnMainThread:onMainThread success:success failure:failure];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
                @StrongObj(self)
                [self handleFailure:task error:error callbackOnMainThread:onMainThread failure:failure];
                
            }];
            
            manager.completionQueue = dispatch_queue_create("com.moli.gethttprequestqueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
        }
        else
        {
            if (failure)
            {
                failure(nil);
            }
            NSLog(@"正在获取软件配置信息，请稍后");
        }
    }
    else network = NO;
    return network;
}

- (BOOL)post:(NSString *)uri
  parameters:(id)parameters
callbackOnMainThread:(BOOL)onMainThread
     success:(void(^)(NSDictionary *result))success
     failure:(void(^)(NSError *error))failure
{
    NSString *token = [JAUserInfo userInfo_getUserImfoWithKey:User_AccessToken];
    NSString *tokenTime = [JAUserInfo userInfo_getUserImfoWithKey:User_AccessTokenServerTime];
    if (![uri containsString:@"/moli_audio_consumer/v2/login/refreshAccessToken"]) {
        if (!token.length || (tokenTime.length && [NSString isExpried:tokenTime])) {
            // accesstoken 过期重新获取
            [[JAUserApiRequest shareInstance] getAccessToken:^(NSDictionary *dictionary) {
                [JAAPPManager saveAccessTokenAndTime:dictionary];
                [self checkTokenOfPost:uri parameters:parameters callbackOnMainThread:onMainThread success:success failure:failure token:token];
            } failure:^(NSError *error) {
                if (retryIndex < 1) {
                    retryIndex++;
                    [[JAUserApiRequest shareInstance] getAccessToken:^(NSDictionary *dictionary) {
                        retryIndex = 0;

                        [JAAPPManager saveAccessTokenAndTime:dictionary];
                        [self checkTokenOfPost:uri parameters:parameters callbackOnMainThread:onMainThread success:success failure:failure token:token];
                        
                    } failure:^(NSError *error) {
                        retryIndex = 0;
                        // accesstoken获取失败
                        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"accesstoken获取失败",NSLocalizedFailureReasonErrorKey:@"accesstoken获取失败"};
                        NSError *localError = [[NSError alloc] initWithDomain:@"com.moli.jasmine" code:900 userInfo:userInfo];
                        if (failure)
                        {
                            failure(localError);
                        }
                        // 第二次尝试获取失败后，退出登录
                        if (error.code == 140011) {
//                            [self constraintLoginout];
                            [JAAPPManager app_loginOut];
                        }
                    }];
                } else {
                    retryIndex = 0;
                    // accesstoken获取失败
                    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"accesstoken获取失败",NSLocalizedFailureReasonErrorKey:@"accesstoken获取失败"};
                    NSError *localError = [[NSError alloc] initWithDomain:@"com.moli.jasmine" code:900 userInfo:userInfo];
                    if (failure)
                    {
                        failure(localError);
                    }
                }
            }];
            return NO;
        }
    }
    return [self checkTokenOfPost:uri parameters:parameters callbackOnMainThread:onMainThread success:success failure:failure token:token];
}

- (BOOL)checkTokenOfPost:(NSString *)uri
  parameters:(id)parameters
callbackOnMainThread:(BOOL)onMainThread
     success:(void(^)(NSDictionary *result))success
     failure:(void(^)(NSError *error))failure
       token:(NSString *)token {
    
    [self setupHttpHeader:parameters];

    BOOL network = YES;
    //判断时候有网
    if ([self checkNetwork:failure])
    {
        
        NSString *url = [self urlWithURI:uri];
        
        if (url && [url isKindOfClass:[NSString class]] && url.length)
        {
            if ([url hasPrefix:@"http"])
            {
                @WeakObj(self)
                [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                    
                    @StrongObj(self)
                    [self handleResponse:task responseObject:responseObject callbackOnMainThread:onMainThread success:success failure:failure];
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                    @StrongObj(self)
                    [self handleFailure:task error:error callbackOnMainThread:onMainThread failure:failure];
                    
                }];
                
                manager.completionQueue = dispatch_queue_create("com.moli.posthttprequestqueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
            }
            else
            {
                @WeakObj(self)
                [manager POST:url parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                    
                    @StrongObj(self)
                    [self handleResponse:task responseObject:responseObject callbackOnMainThread:onMainThread success:success failure:failure];
                    
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                    @StrongObj(self)
                    [self handleFailure:task error:error callbackOnMainThread:onMainThread failure:failure];
                    
                }];
                
                manager.completionQueue = dispatch_queue_create("com.moli.posthttprequestqueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
            }
        }
        else
        {
            NSLog(@"url is nil");
            if (failure)
            {
                failure(nil);
            }
        }
    }
    else network = NO;
    
    return network;
}

- (BOOL)checkNetwork:(void(^)(NSError *error))failure
{
    //判断时候有网
    if (![self isReachable])
    {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"当前网络不可用", @""),NSLocalizedFailureReasonErrorKey:NSLocalizedString(@"当前网络不可用", @"")};
        NSError *error = [[NSError alloc] initWithDomain:@"com.moli.jasmine" code:800 userInfo:userInfo];
        if (failure) {
            failure(error);
        }
        return NO;
    }
    return YES;
}

/**
 * 检测当前网络是不是可以连接 返回YES无网络
 */
- (BOOL)isReachable
{
    Reachability *r = [Reachability reachabilityForInternetConnection];
    
    if (NotReachable != [r currentReachabilityStatus]) {
        return YES;
    }
    return NO;
}

//// 强制退出
//- (void)constraintLoginout
//{
//    [JAUserInfo userinfo_saveUserLoginState:NO];
//    [JAUserInfo userInfo_deleteUserInfo];
//    // 退出云信
//    [JAChatMessageManager yx_loginOutYX];
//    [[QYSDK sharedSDK] logout:^(){}];
//
//    // 删除别名
//    [JPUSHService setAlias:nil completion:nil seq:0];
//
//    // 回到首页
//    [[AppDelegateModel rootviewController] closeDrawerAnimated:NO completion:^(BOOL finished) {
//        // 设置打开抽屉模式为MMOpenDrawerGestureModeNone，也就是没有任何效果。
//        [[AppDelegateModel rootviewController] setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
//    }];
//    JABaseNavigationController *nav = [AppDelegateModel getBaseNavigationViewControll];
//    [nav popToRootViewControllerAnimated:YES];
//
//    [JAAPPManager app_modalLogin];
//}
@end
