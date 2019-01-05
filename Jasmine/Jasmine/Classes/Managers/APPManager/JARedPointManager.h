//
//  JARedPointManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JARedPointType) {
    JARedPointTypeHomePageFocus = 1 << 0,   // 首页关注红点  1
    JARedPointTypeActivity = 1 << 1,         // 活动红点    2
    JARedPointTypeMessage = 1 << 2,          // 私信红点    4
    JARedPointTypeNoti_Reply = 1 << 3,       // 通知回复    8
    JARedPointTypeNoti_Agree = 1 << 4,       // 通知点赞    16
    JARedPointTypeNoti_Invite = 1 << 5,      // 通知邀请    32
    JARedPointTypeNoti_Focus = 1 << 6,       // 通知关注    64
    JARedPointTypeDraft = 1 << 7,            // 草稿箱    128
    JARedPointTypeCallPerson = 1 << 8,       // @某人    256
    JARedPointTypeAnnouncement = 1 << 9,       // 茉莉君公告    512
};

@interface JARedPointManager : NSObject

/// 获取红点数据 （消息的数目自己去云信读取）
+ (NSInteger)getRedPointNumber:(NSInteger)binary;

/// 检查红点
// 首页关注 1 首页左上角按钮 4+2+120+128+256+512=1022  私信 4 活动 2  通知 120   草稿箱 128  @某人 256 公告 512
+ (BOOL)checkRedPoint:(NSInteger)binary;

/// 红点到达
+ (void)hasNewRedPointArrive:(JARedPointType)type;

/// 重置红点
+ (void)resetNewRedPointArrive:(JARedPointType)type;

@end
