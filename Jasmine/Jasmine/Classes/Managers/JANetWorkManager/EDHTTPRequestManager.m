//
//  EDHTTPRequestManager.m
//  HTTP
//
//  Created by moli-2017 on 2017/7/4.
//  Copyright © 2017年 moli-2017. All rights reserved.
//

#import "EDHTTPRequestManager.h"
#import <MJExtension/MJExtension.h>
#import "EDNetworkMonitor.h"

#define kServerField @"res"   // 服务器最外层字段

@interface EDHTTPRequestManager ()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) NSMutableDictionary *taskRequestDicM;

@property (nonatomic, strong) NSString *request_url;        // 请求url
@property (nonatomic, strong) NSDictionary *request_params; // 请求参数

@end

@implementation EDHTTPRequestManager

#pragma mark - 获取基本的URL
- (NSString *)getBaseUrl
{

    NSString *baseUrl = [JAConfigManager shareInstance].host;
    return baseUrl;
}

#pragma mark - POST
- (void)postRequest:(nonnull NSString *)requestKey
                url:(nonnull NSString *)requestUrl
             params:(nullable NSDictionary *)params
          jsonModel:(Class _Nullable )classType
           complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError * _Nullable error))complete
{
    
    [self requestConfig:requestKey url:requestUrl params:params method:@"POST" jsonModel:classType complete:complete];
}

#pragma mark - GET
- (void)getRequest:(nonnull NSString *)requestKey
               url:(nonnull NSString *)requestUrl
            params:(nullable NSDictionary *)params
         jsonModel:(Class _Nullable )classType
          complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError * _Nullable error))complete
{
    [self requestConfig:requestKey url:requestUrl params:params method:@"GET" jsonModel:classType complete:complete];
}

#pragma mark - UPLOAD
- (void)upLoadRequest:(nonnull NSString *)requestKey
                  url:(nonnull NSString *)requestUrl
               params:(nullable NSDictionary *)params
        filebodyBlock:(void (^_Nullable)(id <AFMultipartFormData> formData))block
            jsonModel:(Class _Nullable )classType
             complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError * _Nullable error))complete
{
    self.request_url = requestUrl;
    self.request_params = params;
    
    [self uploadRequest:requestKey filebodyBlock:block complete:complete];
}


#pragma mark - DOWNLOAD
- (void)downLoadRequest:(nonnull NSString *)requestKey
                    url:(nonnull NSString *)requestUrl
                 params:(nullable NSDictionary *)params
              jsonModel:(Class _Nullable )classType
               complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code,NSError * _Nullable error))complete
{
    
}

#pragma mark - 取消单个网络请求
- (void)cancleRequest:(nonnull NSString *)requestKey
{
    [self.taskRequestDicM[requestKey] cancel];
    [self.taskRequestDicM removeObjectForKey:requestKey];
}

#pragma mark - 取消所有的网络请求
- (void)cancleAllRequest
{
    for (NSURLSessionDataTask *task in self.taskRequestDicM) {
        [task cancel];
    }
    
    [self.taskRequestDicM removeAllObjects];
}

#pragma mark - 基础网络请求
- (NSURLSessionDataTask *)requestConfig:(nonnull NSString *)requestKey
                  url:(nonnull NSString *)requestUrl
               params:(nullable NSDictionary *)params
               method:(nonnull NSString *)method
            jsonModel:(Class _Nullable )classType
             complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError *error))complete
{
    // 判断网络情况
    if (![EDNetworkMonitor shareIntance].isReachable) {

        NSLog(@"网络连接异常 - 提示用户");
        self.requestState = EDHTTPRequestStateFailure;
        
//        return nil;
    }
    
    
    // 创建
//    EDHTTPRequestManager *requestManager = [EDHTTPRequestManager shareInstance];
    self.request_url = requestUrl;
    self.request_params = params;
    // 设置请求头
    [self configeHttpRequestHeader];
    
    // 首先取消请求
    [self cancleRequest:requestKey];
    
    self.requestState = EDHTTPRequestStateLoading;
    
    // 发送网络请求
    NSURLSessionDataTask *task = [self requestWithMethod:method Success:^(NSURLSessionDataTask *task, id responseObject) {
        
        self.requestState = EDHTTPRequestStateSuccess;
        // 移除task
        [self.taskRequestDicM removeObjectForKey:requestKey];
        
        NSDictionary *result = responseObject;

        if ([result[@"code"] integerValue] == 10000) {

            NSLog(@"\n 返回的数据【%@】",result[kServerField]);
            
            NSDictionary *dic = result[kServerField];
            
            // 获取key
            NSString *key = [dic allKeys].firstObject;
            
            // 解析数据
            if (classType) {
                
                id model = [classType mj_objectWithKeyValues:dic[key]];
                complete(model,[result[@"code"] integerValue],nil);
            }else{
               complete(result[kServerField],[result[@"code"] integerValue],nil);
            }
        }else{
            
            [self showFailureMessage:[result[@"code"] integerValue]]; // 提示错误信息
            
            complete(nil,[result[@"code"] integerValue],nil);
            
        }
        
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        // 移除task
        [self.taskRequestDicM removeObjectForKey:requestKey];
        
        // 失败
        complete(nil,-1,error);
        self.requestState = EDHTTPRequestStateFailure;
        
    }];
    
    if (task && requestKey) {
        
        [self.taskRequestDicM setObject:task forKey:requestKey];
    }
    
    return task;
    
}


#pragma mark - afn 数据网络请求
- (NSURLSessionDataTask *)requestWithMethod:(NSString *)method Success:(void(^)(NSURLSessionDataTask *task, id responseObject))success failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure
{
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[self getBaseUrl],self.request_url];
    NSDictionary *params = self.request_params;

    NSLog(@"\n 请求的URL 【%@】 \n 参数【%@】",requestUrl,params);
    
    if ([method isEqualToString:@"POST"]) {
        
        return [self.manager POST:requestUrl parameters:params progress:nil success:success failure:failure];
    }else{
        return [self.manager GET:requestUrl parameters:params progress:nil success:success failure:failure];
    }
}

#pragma mark - afn 数据上传
- (NSURLSessionDataTask *)uploadRequest:(NSString *)requestKey
                          filebodyBlock:(void (^_Nullable)(id <AFMultipartFormData> formData))block
                               complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError *error))complete
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",[self getBaseUrl],self.request_url];
    NSDictionary *params = self.request_params;
    
    NSURLSessionDataTask *task = [self.manager POST:requestUrl parameters:params constructingBodyWithBlock:block progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [self.taskRequestDicM removeObjectForKey:requestKey];

        NSDictionary *result = responseObject;
        if ([result[@"code"] integerValue] == 10000) {
            
            complete(nil,[result[@"code"] integerValue],nil);
        }else{
            complete(nil,[result[@"code"] integerValue],nil);
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        // 移除task
        [self.taskRequestDicM removeObjectForKey:requestKey];
        // 失败
        complete(nil,NO,error);
        
    }];
    
    if (task && requestKey) {
        
        [self.taskRequestDicM setObject:task forKey:requestKey];
    }
    
    return task;
}

#pragma mark - 基本配置 - 设置请求头
- (void)configeHttpRequestHeader
{
    // 服务器需要的请求头
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    [self.manager.requestSerializer setValue:@"" forHTTPHeaderField:@""];
    
    [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [self.manager.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    self.manager.requestSerializer.timeoutInterval = 30;
}


// 根据code 展示相关内容
- (void)showFailureMessage:(NSInteger)code
{
    switch (code) {
        case HTTP_JA_EMPTY_OPTION:
            NSLog(@"失败");
            break;
        case HTTP_JA_SEX_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_EMPTY_LONG:
            NSLog(@"失败");
            break;
        case HTTP_JA_PHONE_FORMAT:
            NSLog(@"失败");
            break;
        case HTTP_JA_DATE_FORMAT:
            NSLog(@"失败");
            break;
        case HTTP_JA_SYSTEM_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_CONTENT_TYPE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_PLATFORM_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_CONTENT_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_ACTION_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_ACTIONTYPE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_COLLENT_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_LOGIN_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_LOGIN_TYPE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_NEED_PHONE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_REGIST_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_PLATFORM_VERIFICATION_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_CODE_PAST_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_HAVE_ACCOUNT_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_ACCOUNT_PWD_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_PLATFORM_REGIST_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_NO_REGIST_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_HAVE_NAME_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_NO_SENSITIVE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_HAVE_SENSITIVE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_PHONE_SYSTEMTYPE_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_REPETITION_ERROR:
            NSLog(@"失败");
            break;
        case HTTP_JA_RELEASE_ERROR:
            NSLog(@"失败");
            break;
        
        default:
            break;
    }
    
    
    /*
     
     HTTP_JA_SUCCESS = 10000,
     HTTP_JA_EMPTY_OPTION = 10001, empty option 字段数据为空
     HTTP_JA_SEX_ERROR = 100012,    值只能是1或者2 參考：1：男，2:女
     HTTP_JA_EMPTY_LONG = 10002,     too long 字段太长
     HTTP_JA_PHONE_FORMAT = 10011,   手机号格式不正确
     HTTP_JA_DATE_FORMAT = 10030,      type is yyyy-MM-dd HH:mm:ss 日期时间格式错误
     HTTP_JA_SYSTEM_ERROR = 11000,     system exception 系统异常
     HTTP_JA_CONTENT_TYPE_ERROR = 122100,   请确认Type的属性值，参考：problem|answer|topic|user|comment|publish|story
     HTTP_JA_PLATFORM_ERROR = 122200,     请确认SYSTEM的属性值，参考：qq|wx|weibo
     HTTP_JA_CONTENT_ERROR = 122300,       请确认CONCERN的属性值，参考：topic|problem|user|favorites
     HTTP_JA_ACTION_ERROR = 122400,	//请确认ACTION的属性值，参考：problem|answer|comment	茉莉“公共”项目
     HTTP_JA_ACTIONTYPE_ERROR = 122410,	//请确认ACTIONTYPE的属性值，参考：agree|oppose|nohelp	茉莉“公共”项目
     HTTP_JA_COLLENT_ERROR = 122500,	//请确认COLLENT的属性值，参考：topic|problem|answer	茉莉“公共”项目
     HTTP_JA_SYSTEMTYPE_ERROR = 122700, // 0,1,2
     HTTP_JA_CODE_ACTION_ERROR = 122800,//	验证码操作失败	茉莉“公共”项目
     HTTP_JA_LOGIN_ERROR = 122900,//	登录失败	茉莉“公共”项目
     HTTP_JA_LOGIN_TYPE_ERROR = 123000,//	登录类型错误，参考：0|1|2|3	茉莉“公共”项目
     HTTP_JA_NEED_PHONE_ERROR = 123100,//	需要绑定手机	茉莉“公共”项目
     HTTP_JA_REGIST_ERROR = 123200,//	注册失败	茉莉“公共”项目
     HTTP_JA_PLATFORM_VERIFICATION_ERROR = 123300,//	第三方验证失败	茉莉“公共”项目
     HTTP_JA_CODE_PAST_ERROR = 123400,//	验证码失效	茉莉“公共”项目
     HTTP_JA_HAVE_ACCOUNT_ERROR = 123500,//	注册失败，已经注册过	茉莉“公共”项目
     HTTP_JA_ACCOUNT_PWD_ERROR = 123600,//	账号密码错误	茉莉“公共”项目
     HTTP_JA_PLATFORM_REGIST_ERROR = 123700,//	第三方登录失败，需要注册	茉莉“公共”项目
     HTTP_JA_NO_REGIST_ERROR = 123800,//	失败，需要注册	茉莉“公共”项目
     HTTP_JA_HAVE_NAME_ERROR = 123900,//	昵称已被占用	茉莉“公共”项目
     HTTP_JA_NO_SENSITIVE_ERROR = 124000,//	没有检测到敏感字	茉莉“公共”项目
     HTTP_JA_HAVE_SENSITIVE_ERROR = 125000,//	检测到有敏感字存在	茉莉“公共”项目
     HTTP_JA_PHONE_SYSTEMTYPE_ERROR = 128000,//	请确认PLATFORM的属性值，参考：IOS||Android||WEB	茉莉“公共”项目
     HTTP_JA_REPETITION_ERROR = 129000,//	不能重复操作	茉莉“公共”项目
     HTTP_JA_RELEASE_ERROR = 130100//	内容发布失败
     
     */
}

#pragma mark - 懒加载
- (AFHTTPSessionManager *)manager
{
    if (_manager == nil) {
        _manager = [AFHTTPSessionManager manager];
//        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.requestSerializer = [[AFHTTPRequestSerializer alloc] init];
//        _manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes =
        [NSSet setWithObjects:@"text/html",@"application/json",@"text/plain", @"image/png", nil];
    }
    
    return _manager;
}


- (NSMutableDictionary *)taskRequestDicM
{
    if (_taskRequestDicM == nil) {
        _taskRequestDicM = [NSMutableDictionary dictionary];
    }
    return _taskRequestDicM;
}

- (void)dealloc
{
    [self cancleAllRequest];
}
@end
