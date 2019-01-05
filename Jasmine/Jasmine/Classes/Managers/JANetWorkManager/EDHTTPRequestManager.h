//
//  EDHTTPRequestManager.h
//  HTTP
//
//  Created by moli-2017 on 2017/7/4.
//  Copyright © 2017年 moli-2017. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef NS_ENUM(NSUInteger, EDHTTPRequestState) {
    EDHTTPRequestStateSuccess,
    EDHTTPRequestStateLoading,
    EDHTTPRequestStateFailure,
};

typedef NS_ENUM(NSInteger, XDHttpStatusCode) {
    
    HTTP_JA_SUCCESS = 10000,
    HTTP_JA_EMPTY_OPTION = 10001,
    HTTP_JA_SEX_ERROR = 100012,
    HTTP_JA_EMPTY_LONG = 10002,
    HTTP_JA_PHONE_FORMAT = 10011,
    HTTP_JA_DATE_FORMAT = 10030,
    HTTP_JA_SYSTEM_ERROR = 11000,
    HTTP_JA_CONTENT_TYPE_ERROR = 122100,
    HTTP_JA_PLATFORM_ERROR = 122200,
    HTTP_JA_CONTENT_ERROR = 122300,
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
};

@interface EDHTTPRequestManager : NSObject

@property (nonatomic, assign) EDHTTPRequestState requestState;  // 网络请求状态

// POST
- (void)postRequest:(nonnull NSString *)requestKey
                url:(nonnull NSString *)requestUrl
             params:(nullable NSDictionary *)params
          jsonModel:(Class _Nullable )classType
           complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError * _Nullable error))complete;

// GET
- (void)getRequest:(nonnull NSString *)requestKey
                url:(nonnull NSString *)requestUrl
             params:(nullable NSDictionary *)params
          jsonModel:(Class _Nullable )classType
           complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError * _Nullable error))complete;

// UPLOAD
- (void)upLoadRequest:(nonnull NSString *)requestKey
                  url:(nonnull NSString *)requestUrl
            params:(nullable NSDictionary *)params
     filebodyBlock:(void (^_Nullable)(id <AFMultipartFormData> _Nullable formData))block
         jsonModel:(Class _Nullable )classType
          complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code, NSError * _Nullable error))complete;


// DOWNLOAD
- (void)downLoadRequest:(nonnull NSString *)requestKey
               url:(nonnull NSString *)requestUrl
            params:(nullable NSDictionary *)params
         jsonModel:(Class _Nullable )classType
          complete:(void(^_Nullable)(id _Nullable class_Model, NSInteger code,NSError * _Nullable error))complete;

// CANCLE
- (void)cancleRequest:(nonnull NSString *)requestKey;


// CANCLE_ALL
- (void)cancleAllRequest;
@end
