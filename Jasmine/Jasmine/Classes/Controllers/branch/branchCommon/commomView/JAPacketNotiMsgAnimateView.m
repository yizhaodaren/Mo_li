//
//  JAPacketNotiMsgAnimateView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/29.
//  Copyright © 2018年 xujin. All rights reserved.
/*
    红包动画
 */

#import "JAPacketNotiMsgAnimateView.h"
#import "CYLTabBarController.h"
#import "JARedPacketView.h"
#import "FLAnimatedImage.h"

#import "JAUserApiRequest.h"

@interface JAPacketNotiMsgAnimateView ()
@property (nonatomic, strong) FLAnimatedImageView *aPlayer_long;
@property (nonatomic, strong) FLAnimatedImageView *aPlayer_side;

@property (nonatomic, strong) FLAnimatedImage *aniImage_regist;
@property (nonatomic, strong) FLAnimatedImage *aniImage_packet;
@end

@implementation JAPacketNotiMsgAnimateView

+ (instancetype)PacketNotiMsgAnimateView
{
    static JAPacketNotiMsgAnimateView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAPacketNotiMsgAnimateView alloc] init];
        }
    });
    return instance;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickAnimateView)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

#pragma mark - 获取红包数据并动画
- (void)homePage_getPacketCountAndAnimate
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAUserApiRequest shareInstance] userAllPacketList:dic success:^(NSDictionary *result) {
        AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [myAppDelegate.packetArray removeAllObjects];
        [myAppDelegate.packetArray addObjectsFromArray:result[@"arraylist"]];
        if (myAppDelegate.packetArray.count) {
            // 开始动画
            [self homePage_beginAnimatePacket];
        }
    } failure:^(NSError *error) {}];
}

#pragma mark - 未登录动画
/// 未登录调用，展示红包动画，点击弹出登录框
- (void)homePage_notLoginShowPacketAnimate
{
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        // 测试服不展示  为 0 的时候才展示
        return;
    }

    self.hidden = NO;
    self.aPlayer_long.alpha = 1;
    self.aPlayer_side.hidden = YES;
    [self.aPlayer_side removeFromSuperview];
    self.aPlayer_side = nil;
    
    self.aPlayer_long.animatedImage = self.aniImage_regist;
}

#pragma mark - 红包动画
/// 展示红包动画
- (void)homePage_beginAnimatePacket
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        // 测试服不展示  为 0 的时候才展示
        return;
    }

    AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    if (myAppDelegate.packetArray.count == 0) {
        return;
    }
    
    self.hidden = NO;
    self.aPlayer_long.alpha = 1;
    self.aPlayer_side.hidden = YES;
    [self.aPlayer_side removeFromSuperview];
    self.aPlayer_side = nil;
    self.aPlayer_long.animatedImage = self.aniImage_packet;
}

/// 展示扒樯的小人动画
- (void)homePage_showSmallPersonAnimate
{
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        // 测试服不展示  为 0 的时候才展示
        return;
    }
    self.hidden = NO;
    [self.aPlayer_long removeFromSuperview];
    self.aPlayer_long = nil;
    NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"side_new" withExtension:@"gif"]; //
    NSData *data1 = [NSData dataWithContentsOfURL:url1];
    FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data1];
    self.aPlayer_side.animatedImage = animatedImage1;
}

#pragma mark - 移除动画
/// 移除动画
- (void)homePage_removeAnimateView
{
    self.hidden = YES;
    [self.aPlayer_long stopAnimating];
    [self.aPlayer_long removeFromSuperview];
    self.aPlayer_long = nil;
    [self.aPlayer_side stopAnimating];
    [self.aPlayer_side removeFromSuperview];
    self.aPlayer_side = nil;
}

/// 移除未登录动画
- (void)homePage_removeNotLoginAnimateView
{
    if (_aPlayer_long.animatedImage == self.aniImage_regist) {
        self.hidden = YES;
        [self.aPlayer_long stopAnimating];
        [self.aPlayer_long removeFromSuperview];
        self.aPlayer_long = nil;
    }
}

/// 移除红包数据
- (void)homePage_resetData
{
    AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [myAppDelegate.packetArray removeAllObjects];
    
    [self homePage_removeAnimateView];
}

#pragma mark - 点击事件
- (void)clickAnimateView
{
    [self homePage_removeAnimateView];
    
    if (!IS_LOGIN) {
        [JAAPPManager app_modalRegist];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_BindingType] = @"点击红包";
        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
        return;
    }
    
    // 开启红包
    [self packetNotiMsgopenPacket];
}

// 开红包
- (void)packetNotiMsgopenPacket
{
    // 获取红包数据
    AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSDictionary *dic = myAppDelegate.packetArray.firstObject;
    
    JARedPacketView *packet = [[JARedPacketView alloc] init];
    packet.packetDic = dic;
    @WeakObj(self);
    packet.unOpenClose = ^{
        if (myAppDelegate.packetArray.count) {
            // 展示 扒樯的动画
            [self homePage_showSmallPersonAnimate];
        }
    };
    
    packet.openClose = ^(BOOL isClose) {
        @StrongObj(self);
        if (isClose) {   // 开完后 直接关闭弹窗
            if (myAppDelegate.packetArray.count) {
                [self packetNotiMsgopenPacket];
            }else{
                // 没有红包了 要移除
                [self homePage_removeAnimateView];
            }
        }else{  // 开完后 跳转其他节目
            if (myAppDelegate.packetArray.count) {
                [self homePage_showSmallPersonAnimate];
            }else{
                // 没有红包了 要移除
                [self homePage_removeAnimateView];
            }
        }
    };
    [[self cyl_tabBarController].view addSubview:packet];
}

#pragma mark - UI
- (void)setupUI
{
    self.frame = CGRectMake(JA_SCREEN_WIDTH - 110, JA_SCREEN_HEIGHT - 180, 110, 110);
    self.hidden = YES;
    [[AppDelegateModel getCenterMenuViewController].view addSubview:self];
}

- (FLAnimatedImageView *)aPlayer_long
{
    if (_aPlayer_long == nil) {
        _aPlayer_long = [[FLAnimatedImageView alloc] init];
        _aPlayer_long.contentMode = UIViewContentModeScaleToFill;
        @WeakObj(self);
        _aPlayer_long.loopCompletionBlock = ^(NSUInteger loopCountRemaining) {
            @StrongObj(self);
            if (IS_LOGIN && _aPlayer_long.animatedImage == self.aniImage_packet) {
                self.hidden = NO;
                self.aPlayer_long.alpha = 0;
                [self.aPlayer_long removeFromSuperview];
                self.aPlayer_long = nil;
                self.aPlayer_side.hidden = NO;
                NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"side_new" withExtension:@"gif"]; //
                NSData *data1 = [NSData dataWithContentsOfURL:url1];
                FLAnimatedImage *animatedImage1 = [FLAnimatedImage animatedImageWithGIFData:data1 ];
                self.aPlayer_side.animatedImage = animatedImage1;
            }
        };
        _aPlayer_long.frame = self.bounds;
        _aPlayer_long.clipsToBounds = YES;
        [self addSubview:_aPlayer_long];
    }
    
    return _aPlayer_long;
}

- (FLAnimatedImageView *)aPlayer_side
{
    if (_aPlayer_side == nil) {
        _aPlayer_side = [[FLAnimatedImageView alloc] init];
        _aPlayer_side.contentMode = UIViewContentModeScaleToFill;
        
        _aPlayer_side.frame = self.bounds;
        _aPlayer_side.clipsToBounds = YES;
        [self addSubview:_aPlayer_side];
    }
    
    return _aPlayer_side;
}

- (FLAnimatedImage *)aniImage_packet
{
    if (_aniImage_packet == nil) {
        
        NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"packet_new" withExtension:@"gif"];
        NSData *data1 = [NSData dataWithContentsOfURL:url1];
        _aniImage_packet = [FLAnimatedImage animatedImageWithGIFData:data1];
    }
    
    return _aniImage_packet;
}

- (FLAnimatedImage *)aniImage_regist
{
    if (_aniImage_regist == nil) {
     
        NSURL *url1 = [[NSBundle mainBundle] URLForResource:@"registAnimate" withExtension:@"gif"];
        NSData *data1 = [NSData dataWithContentsOfURL:url1];
        _aniImage_regist = [FLAnimatedImage animatedImageWithGIFData:data1];
    }
    return _aniImage_regist;
}
@end
