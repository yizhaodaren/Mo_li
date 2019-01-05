//
//  JACommonApi.m
//  Jasmine
//
//  Created by xujin on 05/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JACommonApi.h"
#import "STSystemHelper.h"

@implementation JACommonApi

+ (instancetype)shareInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JACommonApi alloc] init];
        }
    });
    return instance;
}

- (NSMutableDictionary *)commonParams {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"platform_id"] = JA_CHANNEL;
    NSString *longitude = [NSString stringWithFormat:@"%.6f", [JAConfigManager shareInstance].location.coordinate.longitude];
    NSString *latitude = [NSString stringWithFormat:@"%.6f", [JAConfigManager shareInstance].location.coordinate.latitude];
    if (![JAConfigManager shareInstance].location) {
        longitude = @"0.0";
        latitude = @"0.0";
    }
    params[@"longitude"] = longitude;
    params[@"latitude"] = latitude;
    params[@"network_type"] = [STSystemHelper getNetworkType];
    params[@"phone_type"] = [STSystemHelper getCurrentDeviceModel];
    params[@"phone_id"] = [STSystemHelper getDeviceID];
    params[@"ip"] = [STSystemHelper deviceIPAdress]?:@"192.186.1";
    params[@"edition"] = [STSystemHelper getApp_version];
    params[@"system"] = JA_PLATFORM;
    params[@"client_package_name"] = [STSystemHelper getApp_bundleid];
    return  params;
}

/// 公共采集器---分享信息(类型:qq、wx、wb、moli)
- (void)addDataLogs_shareWithType:(NSString *)type {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1496814745348-1722617555-0002/front/interfaceDetail/ffff-1499772477367-1722617555-0014
    NSMutableDictionary *params = [self commonParams];
    params[@"data_type"] = @"share";
    if (IS_LOGIN) {
        params[@"user_id"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    } else {
        params[@"user_id"] = @"0";
    }
    params[@"type"] = type?:@"";
    NSString *uri = @"/moli_quartz/v1/acquisition/addDataLogs";
    [self post:uri parameters:params success:^(NSDictionary *result) {
        
    } failure:^(NSError *error) {
        
    }];
}

/// 公共采集器---注册信息(类型：phone、qq、wx、wb)
- (void)addDataLogs_registerWithType:(NSString *)type {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1496814745348-1722617555-0002/front/interfaceDetail/ffff-1496816840200-1722617555-0010
    NSMutableDictionary *params = [self commonParams];
    params[@"data_type"] = @"register";
    if (IS_LOGIN) {
        params[@"user_id"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    } else {
        params[@"user_id"] = @"0";
    }
    params[@"type"] = type?:@"";
    NSString *uri = @"/moli_quartz/v1/acquisition/addDataLogs";
    [self post:uri parameters:params success:^(NSDictionary *result) {
       NSLog(@"注册统计成功");
    } failure:^(NSError *error) {
       NSLog(@"注册统计失败");
    }];}

/// 公共采集器---激活信息
- (void)addDataLogs_activeSuccess:(void (^)(void))success {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1496814745348-1722617555-0002/front/interfaceDetail/ffff-1496816840200-1722617555-0010
    NSMutableDictionary *params = [self commonParams];
    params[@"data_type"] = @"activation";
    NSString *uri = @"/moli_quartz/v1/acquisition/addDataLogs";
    [self post:uri parameters:params success:^(NSDictionary *result) {
        NSLog(@"激活统计成功");
        if (success) {
            success();
        }
    } failure:^(NSError *error) {
        NSLog(@"激活统计失败");
    }];}

/// 公共采集器---登录信息(类型:phone、qq、wx、wb)
- (void)addDataLogs_loginWithType:(NSString *)type type_info:(NSString *)type_info {
    //http://doc.java.yourmoli.com/api/project.do#/ffff-1496814745348-1722617555-0002/front/interfaceDetail/ffff-1496816795264-1722617555-0007
    NSMutableDictionary *params = [self commonParams];
    params[@"data_type"] = @"login";
    if (IS_LOGIN) {
        params[@"user_id"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];

    } else {
        params[@"user_id"] = @"0";
    }
    params[@"type"] = type?:@"";
    NSString *uri = @"/moli_quartz/v1/acquisition/addDataLogs";
    [self post:uri parameters:params success:^(NSDictionary *result) {
        NSLog(@"登录统计成功");
    } failure:^(NSError *error) {
        NSLog(@"登录统计失败");
    }];}

@end
