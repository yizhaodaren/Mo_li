//
//  XDNetworkMonitor.h
//  seeYouTime
//
//  Created by xingdian on 2016/11/6.
//  Copyright © 2016年 形点网络. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
@interface EDNetworkMonitor : NSObject

/**
The current network reachability status.
*/
@property (readonly, nonatomic, assign) AFNetworkReachabilityStatus networkReachabilityStatus;

/**
 Whether or not the network is currently reachable.
 */
@property (readonly, nonatomic, assign, getter = isReachable) BOOL reachable;

/**
 Whether or not the network is currently reachable via WWAN.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWWAN) BOOL reachableViaWWAN;

/**
 Whether or not the network is currently reachable via WiFi.
 */
@property (readonly, nonatomic, assign, getter = isReachableViaWiFi) BOOL reachableViaWiFi;

+ (instancetype)shareIntance;

/**
 Starts monitoring for changes in network reachability status.
 */
- (void)startMonitoring;

@end
