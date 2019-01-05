//
//  AppDelegate.h
//  Jasmine
//
//  Created by xujin on 4/14/17.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANewPlayerView.h"
#import "JAVoiceReleaseViewController.h"

@class TencentOAuth;

@protocol PlatformShareDelegate <NSObject>

- (void)qqShare:(NSString *)error;  // error 为空的时候 成功

- (void)wxShare:(int)code;          // code  0 为成功

- (void)wbShare:(int)code;

@end

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (AppDelegate *)sharedInstance;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) JANewPlayerView *playerView;
@property (nonatomic, strong) TencentOAuth *tencentOAuth;
@property (nonatomic, weak) JAVoiceReleaseViewController *releasevc;

/* 保存微博的access token - 分享的时候使用 */
@property (nonatomic, copy) NSString *weiboAccessToken;

// APP 在后台运行
//@property (nonatomic, strong) NSDictionary *notiDic;

// 红包数组
@property (nonatomic, strong) NSMutableArray *packetArray;

@property (nonatomic, weak) id <PlatformShareDelegate> shareDelegate;
@end

