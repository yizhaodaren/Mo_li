//
//  JACameraUtil.m
//  Jasmine
//
//  Created by xujin on 17/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JACameraUtil.h"

@interface JACameraUtil () <CLLocationManagerDelegate>

@property (nonatomic ,strong) CLLocationManager *locationManager;
@end
@implementation JACameraUtil

+ (instancetype)shareInstance
{
    static JACameraUtil *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JACameraUtil alloc] init];
        }
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

+ (AVCaptureDevice *)captureDeviceForPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

//相机
+ (BOOL)checkAuthorCamera
{
#if defined(IOS7)
    if (IOS7)
    {
        AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        // NotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
        // Restricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
        // Denied,            // 用户已经明确否认了这一照片数据的应用程序访问
        // Authorized         // 用户已经授权应用访问照片数据
        if (author == AVAuthorizationStatusDenied)
        {  //被拒绝
            return NO;
        }
        else if (author == AVAuthorizationStatusNotDetermined)
        {
            //未选择
            return NO;
        }
        else if (author == AVAuthorizationStatusRestricted)
        {
            return NO;
        }
    }
#else
    // 添加是否已经限制了相机权限
    AVCaptureDeviceInput *captureDeviceInputFront = [AVCaptureDeviceInput
                                                     deviceInputWithDevice:[CameraUtilities captureDeviceForPosition:AVCaptureDevicePositionFront]
                                                     error:nil];
    AVCaptureDeviceInput *captureDeviceInputBack = [AVCaptureDeviceInput
                                                    deviceInputWithDevice:[CameraUtilities captureDeviceForPosition:AVCaptureDevicePositionBack]
                                                    error:nil];
    if (captureDeviceInputFront == nil && captureDeviceInputBack == nil)
    {
        return NO;
    }
    
#endif
    
    return YES;
}

//麦克风
+ (BOOL)checkAuthorMicphone
{
#if defined(IOS7)
    if (IOS7)
    {
        AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
        //  NotDetermined = 0, // 用户尚未做出选择这个应用程序的问候
        //  Restricted,        // 此应用程序没有被授权访问的照片数据。可能是家长控制权限
        //  Denied,            // 用户已经明确否认了这一照片数据的应用程序访问
        //  Authorized         // 用户已经授权应用访问照片数据
        if (author == AVAuthorizationStatusDenied)
        {  //被拒绝
            return NO;
        }
        else if (author == AVAuthorizationStatusNotDetermined)
        {
            //未选择
            return NO;
        }
        else if (author == AVAuthorizationStatusRestricted)
        {
            return NO;
        }
    }
#else
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    return [devices count] > 0 ? YES:NO;
#endif
    
    return YES;
}

/*
 地理位置权限
 */
+ (BOOL)checkAuthorLocation
{
    CLAuthorizationStatus state = [CLLocationManager authorizationStatus];
    if (state == kCLAuthorizationStatusNotDetermined)
    {
        return NO;
    }
    else if (![CLLocationManager locationServicesEnabled] ||
             state == kCLAuthorizationStatusDenied ||
             state == kCLAuthorizationStatusRestricted )
    {
        return NO;
    }
    return YES;
}

+ (void)requestAuthorCamera:(void (^)(BOOL granted))block
{
#if defined(IOS7)
    AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (author == AVAuthorizationStatusNotDetermined)
    {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted)
         {
             block(granted);
         }];
    }
    else block(NO);
    
#else
    block(NO);
#endif
}

+ (void)requestAuthorMicphone:(void (^)(BOOL granted))block
{
#if defined(IOS7)
    AVAuthorizationStatus author = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (author == AVAuthorizationStatusNotDetermined)
    {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted)
         {
             block(granted);
         }];
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:nil];
    }
    else block(NO);
    
#else
    block(NO);
#endif
}

- (void)requestAuthorLocation
{
#if defined(IOS8)
    [_locationManager requestWhenInUseAuthorization];
#endif
}

+ (BOOL)checkAuthorLocationNotDetermined
{
#if defined(IOS7)
    CLAuthorizationStatus state = [CLLocationManager authorizationStatus];
    if (state == kCLAuthorizationStatusNotDetermined)
    {
        return YES;
    }
    return NO;
#else
    return YES;
#endif
}

#pragma mark -
#pragma mark

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        if (self.eventAuthorLocationCompleteBlock) {
            self.eventAuthorLocationCompleteBlock(NO);
        }
        return;
    }
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            if (self.eventAuthorLocationCompleteBlock) {
                self.eventAuthorLocationCompleteBlock(NO);
            }
        }
            break;
        default:
            if (self.eventAuthorLocationCompleteBlock) {
                self.eventAuthorLocationCompleteBlock(YES);
            }
            break;
    }
    
}

@end
