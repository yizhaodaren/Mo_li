//
//  XDNetworkMonitor.m
//  seeYouTime
//
//  Created by xingdian on 2016/11/6.
//  Copyright © 2016年 形点网络. All rights reserved.
//

#import "EDNetworkMonitor.h"


@implementation EDNetworkMonitor

+ (instancetype)shareIntance {
    static EDNetworkMonitor *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[EDNetworkMonitor alloc] init];
    });
    
    return _shareInstance;
}

- (void)startMonitoring {
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    __weak typeof(self) wself = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
     {
         [wself willChangeValueForKey:@"networkReachabilityStatus"];
         [wself willChangeValueForKey:@"reachable"];
         [wself willChangeValueForKey:@"reachableViaWWAN"];
         [wself willChangeValueForKey:@"reachableViaWiFi"];
         [wself didChangeValueForKey:@"networkReachabilityStatus"];
         [wself didChangeValueForKey:@"reachable"];
         [wself didChangeValueForKey:@"reachableViaWWAN"];
         [wself didChangeValueForKey:@"reachableViaWiFi"];
     }];
}

- (AFNetworkReachabilityStatus)networkReachabilityStatus {
    return [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus];
}

- (BOOL)isReachable {
//    return [[AFNetworkReachabilityManager sharedManager] isReachable];
    return [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus]!=AFNetworkReachabilityStatusNotReachable;
}

- (BOOL)isReachableViaWWAN {
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN];
}

- (BOOL)isReachableViaWiFi {
    return [[AFNetworkReachabilityManager sharedManager] isReachableViaWiFi];
}

@end
