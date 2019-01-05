//
//  JAPacketManager.h
//  Jasmine
//
//  Created by xujin on 18/12/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, packNotiMsgManagerType) {
    packNotiMsgManagerType_none,
    packNotiMsgManagerType_packet,
    packNotiMsgManagerType_noti,
    packNotiMsgManagerType_msg,

};

@interface JAPacketManager : NSObject

//// 2.6.0前 老逻辑******************************* 红包动画、消息动画、私信动画********************************
///// 网络请求红包列表 展示红包浮层
//+ (void)packet_showPacket;
//
///// 隐藏开红包界面
//+ (void)packet_hiddenPacket;
//
///// 展示开红包界面
//+ (void)packet_showPacketView;
//
//
//
//
//
//
//
//// 2.6.0 新逻辑******************************* 红包动画、消息动画、私信动画********************************
///*
//    动画顺序： 红包 > 消息 > 私信
//
//    该类存储一个变量 --- 用来存储需要动画的数据  array
//
//    1、获取红包列表 保存到本地。并加入  array 中
//        1.1 启动获取红包列表
//        1.2 关闭签到红包 获取 红包列表
//        1.3 收到通知 获取 红包列表
//
//    2、收到消息通知 加入到 array中
//
//    3、收到小秘书 、茉莉君的通知  加入到 array 中
//
//
// */
//
//@property (nonatomic, assign) BOOL isOpenPacket;  // 是否正在开启红包
//
//
//+ (instancetype)packNotiMsgManager;
//
///// 启动app时，获取需要动画的数据
//- (void)packNotiMsg_APPStartNeedAnimate:(BOOL)needAnimate;
//
///// 首页出现时，执行动画
//- (void)packNotiMsg_beginAnimate;
//
///// 首页消失时，移除动画
//- (void)packNotiMsg_removeAnimate;
//
///// 未登录展示
//- (void)packNotiMsg_beginAnimate_notLogin;
//
///// 点击动画的view
//- (void)packNotiMsg_clickAnimateView;
//
///// 退出登录情况数据
//- (void)resetData;
@end
