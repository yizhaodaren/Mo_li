//
//  XDLocationTool.h
//  testCity
//
//  Created by 形点网络 on 16/6/24.
//  Copyright © 2016年 形点网络. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "Singleton.h"

typedef void(^ResultBlock)(CLLocation *location, CLPlacemark *pl, NSString *error);

@interface XDLocationTool : NSObject
single_interface(XDLocationTool)

/**
 *  获取用户位置以及地标
 */
- (void)getCurrentLocation:(ResultBlock)resultBlock;

/** 位置管理者 */
@property (nonatomic, strong) CLLocationManager *locationM;

/**
 *  用户是否允许定位
 */
@property (nonatomic, assign, getter=isAllow) BOOL allow;

@end
