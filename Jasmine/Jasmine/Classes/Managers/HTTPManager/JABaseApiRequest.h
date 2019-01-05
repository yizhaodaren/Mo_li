//
//  JABaseApiRequest.h
//  Jasmine
//
//  Created by xujin on 02/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface JABaseApiRequest : NSObject

+ (AFHTTPSessionManager *)httpSessionManager;

// 以下两个方法回调在子线程
- (BOOL)get:(NSString *)uri
 parameters:(NSDictionary *)parameters
    success:(void(^)(NSDictionary *result))success
    failure:(void(^)(NSError *error))failure;

- (BOOL)post:(NSString *)uri
  parameters:(id)parameters
     success:(void(^)(NSDictionary *result))success
     failure:(void(^)(NSError *error))failure;



// 以下两个方法回调会切换到主线程
- (BOOL)getRequest:(NSString *)uri
        parameters:(NSDictionary *)parameters
           success:(void(^)(NSDictionary *result))success
           failure:(void(^)(NSError *error))failure;

- (BOOL)postRequest:(NSString *)uri
      parameters:(id)parameters
         success:(void(^)(NSDictionary *result))success
         failure:(void(^)(NSError *error))failure;

/// 上传
- (void)upLoadFile:(NSString *)uri parameter:(NSDictionary *)para constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block success:(void(^)(NSDictionary *result))success failure:(void(^)(NSError *error))failure;

// 强制退出
//- (void)constraintLoginout;
@end
