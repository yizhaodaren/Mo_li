//
//  XDLocationTool.m
//  testCity
//
//  Created by 形点网络 on 16/6/24.
//  Copyright © 2016年 形点网络. All rights reserved.
//

#import "XDLocationTool.h"

#define isIOS(version) ([[UIDevice currentDevice].systemVersion floatValue] >= version)

@interface XDLocationTool () <CLLocationManagerDelegate>
/** 保存block */
@property (nonatomic, copy) ResultBlock block;
///** 位置管理者 */
//@property (nonatomic, strong) CLLocationManager *locationM;
/** 地理编码对象 */
@property (nonatomic, strong) CLGeocoder *geoc;
@end

@implementation XDLocationTool

- (instancetype)init
{
    self = [super init];
    if (self) {
   
    }
    return self;
}

single_implementation(XDLocationTool)

#pragma mark - 懒加载
- (CLGeocoder *)geoc {
    if (_geoc == nil) {
        _geoc = [[CLGeocoder alloc] init];
    }
    return _geoc;
}

#pragma mark - 懒加载
- (CLLocationManager *)locationM {
    if (_locationM == nil) {
        
        // 1.创建位置管理者
        _locationM = [[CLLocationManager alloc] init];
        
        // 2.设置代理
        _locationM.delegate = self;
        
        // 3.ios8.0+必须主动请求用户授权
        
        // 31.获取info.plist中的key
        NSDictionary *infoDict = [NSBundle mainBundle].infoDictionary;
        if (isIOS(8.0)) {
            
            // 1.获取前后台定位以及前台定位授权描述
            NSString *alwaysStr = infoDict[@"NSLocationAlwaysUsageDescription"];
            NSString *whenInUseStr = infoDict[@"NSLocationWhenInUseUsageDescription"];
            
            // 2.如果前后台定位授权描述有值,则执行前后台请求授权
            if (alwaysStr > 0) {
                [_locationM requestAlwaysAuthorization];
            } else if (whenInUseStr) { // 来到这里则请求前台定位授权
                
                // 如果请求前台定位授权,想要在后台进行定位,需要开启后台定位模式
                // 取出对应的key
                NSArray *backgroundArray = infoDict[@"UIBackgroundModes"];
                // 判断是否包含后台模式
                if ([backgroundArray containsObject:@"location"]) { // 表示用户开启了后台模式
                    // 在ios9之后在当前授权模式,不但开启后台模式,还要允许后台获取用户位置信息
                    if (isIOS(9.0)) {
                        [_locationM allowsBackgroundLocationUpdates];
                    }
                    
                } else {
                    NSLog(@"当前授权模式,如果想要在后台获取用户位置,需要勾选后台模式,location updates");
                }
                
                // 请求前台定位授权
                [_locationM requestWhenInUseAuthorization];
            } else { // 给用户提示
                NSLog(@"如果使用iOS8进行定位,需要请求定位授权,在info.plist中配置对应的key,NSLocationAlwaysUsageDescription或者NSLocationWhenInUseUsageDescription");
            }
            
        } else { // ios8.0之前想要在后台获取用户信息,需要勾选后台模式
            NSArray *backgroundArray = infoDict[@"UIBackgroundModes"];
            if (![backgroundArray containsObject:@"location"]) { // 表示用户开启了后台模式
                NSLog(@"当前授权模式,如果想要在后台获取用户位置,需要勾选后台模式,location updates");
            }
        }
    }
    return _locationM;
}

- (void)getCurrentLocation:(ResultBlock)resultBlock {
    if ([CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
         [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined ||
         [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways))
    {
        //定位功能可用
        // 1.记录block
        self.block = resultBlock;
            
        // 2.获取用户信息
        [self.locationM startUpdatingLocation];
     
    } else {
        //定位不能用
        resultBlock(nil,nil,@"当前位置不可用");
    }
}

#pragma mark - CLLocationManagerDelegate
/**
 *  定位到之后调用该方法
 *
 *  @param manager   位置管理者
 *  @param locations 位置数组
 */
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    // 1.获取用户位置
    CLLocation *location = [locations lastObject];
    
    // 2.判断位置是否可用
    if (location.horizontalAccuracy > 0) {
        /*
        if (_block) {
            self.block(location, nil, nil);
        }
        */
        if (!self.geoc.isGeocoding) {
            // 反地理编码
            [self.geoc reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                NSLog(@"reverseGeocodeLocation:");
                // 1.判断是否有错误
                if (error == nil) {
                    // 1.取出地标
                    CLPlacemark *pl = [placemarks firstObject];
                    
                    // 2.调用block
                    if (_block) {
                        self.block(location, pl,nil);
                    }
                } else {
                    // 调用block
                    if (_block) {
                        self.block(location,nil,@"反地理编码失败");
                    }
                }
                
            }];
        }
        
    } else {
        if (_block) {
            self.block(nil,nil,@"当前位置不可用");
        }
    }
    
    // 如果只获取一次用户信息,那么在此处停止获取用户信息
    [manager stopUpdatingLocation];
}

@end
