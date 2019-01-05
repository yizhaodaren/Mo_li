//
//  JARedPacketView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/18.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JARedPacketView : UIView

//@property (nonatomic, assign) BOOL isHasInvitePacket; // 是否有邀请红包
//@property (nonatomic, assign) BOOL isHasSignPacket; // 是否有签到红包
//@property (nonatomic, strong) void (^jumpInvitationCode)();

@property (nonatomic, strong) NSDictionary *packetDic;  // 一个红包

// 2.6.0
// 未开启点击关闭按钮
@property (nonatomic, strong) void(^unOpenClose)();
// 已经开启点击确定、关闭、查看更多方式
@property (nonatomic, strong) void(^openClose)(BOOL isClose);  // 是关闭还是跳转

@end
