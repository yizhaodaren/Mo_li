//
//  JAPacketNotiMsgAnimateView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/3/29.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPacketNotiMsgAnimateView : UIView

+ (instancetype)PacketNotiMsgAnimateView;

/// 获取红包数据并动画
- (void)homePage_getPacketCountAndAnimate;

/// 未登录调用，展示红包动画，点击弹出登录框
- (void)homePage_notLoginShowPacketAnimate;

/// 移除红包数据(退出登录的时候用)
- (void)homePage_resetData;

/// 移除未登录动画
- (void)homePage_removeNotLoginAnimateView;
//
///// 展示红包动画
//- (void)homePage_beginAnimatePacket;
//
//
///// 展示扒樯的小人动画
//- (void)homePage_showSmallPersonAnimate;
@end
