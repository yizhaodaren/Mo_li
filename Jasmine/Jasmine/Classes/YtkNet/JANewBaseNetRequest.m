//
//  JANewBaseNetRequest.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewBaseNetRequest.h"

@implementation JANewBaseNetRequest

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"Content-Type"] = @"application/json; charset=UTF-8";
    dic[@"Content-Encoding"] = @"gzip";
    
    NSString *secretKey = @"PaQhbHy3XbH";
    NSString *version = [STSystemHelper getApp_version];
    NSString *distinctId = [[SensorsAnalyticsSDK sharedInstance] distinctId];
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970];
    NSString *timestamp = [NSString stringWithFormat:@"%lld",(long long)interval];
    NSString *userid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSString *str1 = [secretKey md5_origin];
    NSString *str2 = [[NSString stringWithFormat:@"%@%@",version,JA_PLATFORM] md5_origin];
    NSString *str3 = [[NSString stringWithFormat:@"%@%@",distinctId.length?distinctId:@"",userid.length?userid:@""] md5_origin];
    NSString *ticket = [[NSString stringWithFormat:@"%@%@%@%@",str1,str2,str3,timestamp] md5_origin];
    
    dic[@"x-version"] = version;
    dic[@"x-device-id"] = distinctId;
    dic[@"x-user-id"] = userid;
    dic[@"x-platform"] = JA_PLATFORM;
    dic[@"x-timestamp"] = timestamp;
    dic[@"x-ticket"] = ticket;
    
    return dic;
}

- (YTKRequestSerializerType)requestSerializerType
{
    return YTKRequestSerializerTypeJSON;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        YTKNetworkConfig *config = [YTKNetworkConfig sharedConfig];
        config.baseUrl = [JAConfigManager shareInstance].host;
    }
    return self;
}

- (Class)modelClass
{
    return [JANetBaseModel class];
}

- (BOOL)isToast
{
    return YES;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return 10;
}

- (BOOL)statusCodeValidator {
    return YES;
}

- (YTKRequestMethod)requestMethod
{
    return YTKRequestMethodPOST;
}
@end
