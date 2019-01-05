//
//  JAPermissionHelper.m
//  Jasmine
//
//  Created by xujin on 20/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAPermissionHelper.h"

@implementation JAPermissionHelper

+ (BOOL)hasRecordPermission {
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    if (AVstatus == AVAuthorizationStatusNotDetermined) {
#ifdef DEBUG
        __block BOOL bCanRecord = YES;
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"茉莉需要访问您的麦克风" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            [JAPermissionHelper openJurisdiction];
                        }];
                        [alertController addAction:cancel];
                        [alertController addAction:ok];
                        [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:alertController animated:YES completion:nil];
                    });
                }
            }];
        }
        return bCanRecord;
#else
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){//麦克风权限
            
        }];
        return NO;
#endif
    } else if (AVstatus == AVAuthorizationStatusAuthorized) {
        return YES;
    } else if (AVstatus == AVAuthorizationStatusDenied) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"茉莉需要访问您的麦克风" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [JAPermissionHelper openJurisdiction];
        }];
        [alertController addAction:cancel];
        [alertController addAction:ok];
        [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:alertController animated:YES completion:nil];
        return NO;
    } else {
        [[[UIAlertView alloc] initWithTitle:nil
                                    message:@"麦克风权限受限"
                                   delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil] show];
        return NO;
    }
}

+ (void)openJurisdiction{
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

/**
 *  获取麦克风权限状态
 */
+ (BBEPermissionsStatus)systemPermissionsWithVoice
{
    AVAuthorizationStatus AVstatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    switch (AVstatus) {
        case AVAuthorizationStatusAuthorized: return BBEPermissionsStatusAuthorize;     //允许
        case AVAuthorizationStatusDenied: return BBEPermissionsStatusRefuse;            // 拒绝
        case AVAuthorizationStatusNotDetermined: return BBEPermissionsStatusNoAsk;      // 未询问
        case AVAuthorizationStatusRestricted: return BBEPermissionsStatusParentsLimit;  // 家长控制
        default: break;
    }
    return BBEPermissionsStatusNoAsk;
}

/**
 *  获取麦克风权限
 */
+ (void)systemPermissionsWithVoice_getSuccess:(void(^)())success getFailure:(void(^)())failure
{
    if ([self systemPermissionsWithVoice] != BBEPermissionsStatusNoAsk) {
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"茉莉需要访问您的麦克风" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [JAPermissionHelper openJurisdiction];
            }];
            [alertController addAction:cancel];
            [alertController addAction:ok];
            [[[[UIApplication sharedApplication] delegate] window].rootViewController presentViewController:alertController animated:YES completion:nil];
        });
    }else{
       
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted){//麦克风权限
            if (granted) {
                
                if (success) {
                    success();
                }
            }
            else{
                if (failure) {
                    failure();
                }
            }
        }];
    }
    
}

@end
