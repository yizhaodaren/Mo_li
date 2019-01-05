//
//  JACameraUtil.h
//  Jasmine
//
//  Created by xujin on 17/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AVFoundation/AVFoundation.h"
#import <CoreLocation/CoreLocation.h>

@interface JACameraUtil : NSObject

{
    CLLocationManager *_locationManager;
}
@property (nonatomic,copy) void(^eventAuthorLocationCompleteBlock)(BOOL granted);

+ (instancetype)shareInstance;
/*
 相机权限
 */
+ (BOOL)checkAuthorCamera;
+ (void)requestAuthorCamera:(void (^)(BOOL granted))block;
/*
 麦克风权限
 */
+ (BOOL)checkAuthorMicphone;
+ (void)requestAuthorMicphone:(void (^)(BOOL granted))block;
/*
 地理位置权限
 */
+ (BOOL)checkAuthorLocation;
- (void)requestAuthorLocation;
+ (BOOL)checkAuthorLocationNotDetermined;

@end
