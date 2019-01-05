
//
//  JAPacketManager.m
//  Jasmine
//
//  Created by xujin on 18/12/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAPacketManager.h"
#import "JARedPacketView.h"
#import "JAUserApiRequest.h"
#import "JAPacketNotiMsgAnimateView.h"
#import "JAsynthesizeMessageViewController.h"

#import "CYLTabBarController.h"

@interface JAPacketManager ()

@property (nonatomic, strong) NSMutableArray *animateArray;  // 存储动画的数组 对象是字典@{红包：List, 消息：obj,私信：obj}

@property (nonatomic, assign) BOOL packetNeedPacketList; // 是否需要拉取红包列表

@property (nonatomic, assign) BOOL noti_aniFinish;
@property (nonatomic, assign) BOOL msg_aniFinish;
@property (nonatomic, assign) BOOL packet_aniRemove;


@property (nonatomic, assign) packNotiMsgManagerType animateType;  // 正在动画的类型
@property (nonatomic, assign) NSInteger animateObjIndex;           // 正在动画的数据的索引

@property (nonatomic, assign) BOOL isRequest;  // 网络正在请求

@property (nonatomic, assign) CGFloat maginTime;
@end

@implementation JAPacketManager

///* ----------------------------------------- 新逻辑 ---------------------------------------- */
//+ (instancetype)packNotiMsgManager;
//{
//    static JAPacketManager *instance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        if (instance == nil)
//        {
//            instance = [[JAPacketManager alloc] init];
//
//        }
//    });
//    return instance;
//}
//
///*
//    还有未解决的问题：
//        1、同时又消息和私信，启动出现消息的时候，点击进入消息页面，但是这时候因为要清空红点要触发 redPointDismiss 事件。导致本类监听到该通知又去执行
// */
//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        self.animateArray = [NSMutableArray array];
//
//        // 监听消息、私信的通知、红包通知   @"packNotiMsg_noti",  @"packNotiMsg_msg" @"packNotiMsg_packet"
//        // 红包到达、消息到达、清除消息、私信到达、清除私信
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiArriveToGetPacketList) name:@"redPointArrive" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgArriveToGetPacketList) name:@"redPointArrive" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiDismissToGetPacketList) name:@"redPointDismiss" object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgDismissToGetPacketList) name:@"redPointDismiss" object:nil];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packetArriveToGetPacketList) name:@"packNotiMsg_packet" object:nil];
//
//        // 监听动画完成 @"packNotiMsg_aniFinish"
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(packetNotiMsganimateFinish) name:@"packNotiMsg_aniFinish" object:nil];
//    }
//    return self;
//}
//
//- (void)dealloc
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}
//
//#pragma mark - 退出登录情况数据
///// 退出登录情况数据
//- (void)resetData
//{
//    AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [myAppDelegate.packetArray removeAllObjects];
//    [self.animateArray removeAllObjects];
//    self.packetNeedPacketList = NO;
//    self.noti_aniFinish = NO;
//    self.msg_aniFinish = NO;
//    self.packet_aniRemove = NO;
//    self.animateType = packNotiMsgManagerType_none;
//
//    // 移除动画
//    [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_removeAnimateView];
//}
//
//#pragma mark - 新红包、通知、消息到达
///// 通知消息到达
//- (void)notiArriveToGetPacketList
//{
//    if (self.noti_aniFinish) {
//        return;
//    }
//    [self packNotiMsg_getNotiInfoWithAnimate:YES];
//}
//
///// 小秘书 茉莉君等消息到达
//- (void)msgArriveToGetPacketList
//{
//    if (self.msg_aniFinish) {
//        return;
//    }
//
//    [self packNotiMsg_getMsgInfoWithAnimate:YES];
//}
//
///// 红包通知到达
//- (void)packetArriveToGetPacketList
//{
//    self.packetNeedPacketList = YES;
//
//    if (self.isOpenPacket) {
//        return;
//    }
//    [self packNotiMsg_getPackListWithAnimate:YES finishBlock:nil];
//}
//
//// 消息红点消失
//- (void)notiDismissToGetPacketList
//{
//    if (self.noti_aniFinish) {
//        return;
//    }
//    [self packNotiMsg_getNotiInfoWithAnimate:NO];
//}
//// 私信红点消失
//- (void)msgDismissToGetPacketList
//{
//    if (self.msg_aniFinish) {
//        return;
//    }
//    [self packNotiMsg_getMsgInfoWithAnimate:NO];
//}
//
//#pragma mark - 新红包、通知、消息到达 插入动画数组
///// 检查动画列表中的顺序
//- (void)insertAnimateArray:(packNotiMsgManagerType)type obj:(NSMutableDictionary *)dicM
//{
//
//    if (type == packNotiMsgManagerType_packet) {
//        BOOL containPacket = NO;
//        NSInteger packetIndex = 0;
//        for (NSInteger i = 0; i < self.animateArray.count; i++) {
//            NSMutableDictionary *dic = self.animateArray[i];
//            if (dic[@"packet"]) {
//                containPacket = YES;
//                packetIndex = i;
//                break;
//            }
//        }
//
//        if (containPacket) {  // 包含先移除之前的
//            [self.animateArray removeObjectAtIndex:packetIndex];
//            [self.animateArray insertObject:dicM atIndex:0];
//        }else{
//            NSArray *arr = dicM[@"packet"];
//            if (arr.count) {
//                [self.animateArray insertObject:dicM atIndex:0];
//            }
//        }
//    }
//
//    if (type == packNotiMsgManagerType_noti) {
//
//        BOOL containNoti = NO;
//        for (NSInteger i = 0; i < self.animateArray.count; i++) {
//            NSMutableDictionary *dic = self.animateArray[i];
//            if (dic[@"noti"]) {
//                containNoti = YES;
//                break;
//            }
//        }
//
//        if (containNoti == NO) {
//
//            for (NSInteger i = 0; i < self.animateArray.count; i++) {
//                NSMutableDictionary *dic = self.animateArray[i];
//                if (dic[@"packet"]) {
//                    [self.animateArray insertObject:dicM atIndex:i+1];
//                    break;
//                }
//            }
//
//
//            if (![self.animateArray containsObject:dicM]) {
//                [self.animateArray insertObject:dicM atIndex:0];
//            }
//        }
//
//    }
//
//    if (type == packNotiMsgManagerType_msg) {
//
//        BOOL containMsg = NO;
//        for (NSInteger i = 0; i < self.animateArray.count; i++) {
//            NSMutableDictionary *dic = self.animateArray[i];
//            if (dic[@"msg"]) {
//                containMsg = YES;
//                break;
//            }
//        }
//
//        if (containMsg == NO) {
//
//            NSInteger count = self.animateArray.count;
//
//            [self.animateArray insertObject:dicM atIndex:count];
//        }
//
//    }
//}
//
//#pragma mark - 开红包完毕获取新的红包列表（开红包时，红包到达的情况）
///// 开完红包的时候要检查是否有需要拉取红包列表的请求
//- (void)setIsOpenPacket:(BOOL)isOpenPacket
//{
//    _isOpenPacket = isOpenPacket;
//
//    if ((isOpenPacket == NO) && (self.packetNeedPacketList)) {
//        [self packNotiMsg_getPackListWithAnimate:YES finishBlock:nil];
//    }
//}
//
//#pragma mark - 获取是否有新消息、新红包、新私信 并执行动画
///// 获取红包的列表
//- (void)packNotiMsg_getPackListWithAnimate:(BOOL)animate finishBlock:(void(^)(NSDictionary *result))finishBlock
//{
//    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
//        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//
//        self.packetNeedPacketList = NO;
//        return;
//    }
//
//    if (!IS_LOGIN) {
//        self.packetNeedPacketList = NO;
//
//        return;
//    }
//
//    if (self.isOpenPacket) {
//        return;
//    }
//
//    if (self.isRequest) {
//        return;
//    }
//
//    self.isRequest = YES;
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    [[JAUserApiRequest shareInstance] userAllPacketList:dic success:^(NSDictionary *result) {
//        self.isRequest = NO;
//        self.packetNeedPacketList = NO;
//        AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//        [myAppDelegate.packetArray removeAllObjects];
//        [myAppDelegate.packetArray addObjectsFromArray:result[@"arraylist"]];
//
//        // 添加需要动画的红包
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"packet"] = myAppDelegate.packetArray;
//        [self insertAnimateArray:packNotiMsgManagerType_packet obj:dic];
//
//        if (animate) {
//            // 开始动画
//            [self packNotiMsg_beginAnimate];
//        }
//
//        if (finishBlock) {
//            finishBlock(result);
//        }
//
//    } failure:^(NSError *error) {
//        self.isRequest = NO;
//        self.packetNeedPacketList = NO;
//        if (finishBlock) {
//            finishBlock(nil);
//        }
//    }];
//
//}
//
//// 获取 动画的消息数据
//- (void)packNotiMsg_getNotiInfoWithAnimate:(BOOL)animate
//{
//    // 添加需要动画的消息数组
//    // 检查是否有通知消息的未读数据
//    BOOL noti_unread = ([JARedPointManager checkRedPoint:120] || [JARedPointManager checkRedPoint:JARedPointTypeCallPerson]);
//    if (noti_unread) {
//        NSMutableDictionary *dic_noti = [NSMutableDictionary dictionary];
//        dic_noti[@"noti"] = @"1";
//        [self insertAnimateArray:packNotiMsgManagerType_noti obj:dic_noti];
//        if (animate) {
//
//            // 开始动画
//            [self packNotiMsg_beginAnimate];
//        }
//    }else{
//        for (NSInteger i = 0; i < self.animateArray.count; i++) {
//            NSDictionary *dic = self.animateArray[i];
//            if (dic[@"noti"]) {
//                [self.animateArray removeObject:dic];
//                break;
//            }
//        }
//    }
//}
//
//// 获取 动画的私信数据
//- (void)packNotiMsg_getMsgInfoWithAnimate:(BOOL)animate
//{
//    // 添加需要动画的私信数组
//    // 获取小秘书或者茉莉君是否有新消息
//    NSString *userId = JA_OFFIC_SERVERMOLI;
//    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
//    NIMRecentSession *serverRecent = [[NIMSDK sharedSDK].conversationManager recentSessionBySession:session];
//    if (serverRecent.unreadCount || [JARedPointManager checkRedPoint:JARedPointTypeAnnouncement]) {
//        NSMutableDictionary *dic_msg = [NSMutableDictionary dictionary];
//        dic_msg[@"msg"] = @"1";
//        [self insertAnimateArray:packNotiMsgManagerType_msg obj:dic_msg];
//
//        if (animate) {
//
//            // 开始动画
//            [self packNotiMsg_beginAnimate];
//        }
//    }else{
//        for (NSInteger i = 0; i < self.animateArray.count; i++) {
//            NSDictionary *dic = self.animateArray[i];
//            if (dic[@"msg"]) {
//                [self.animateArray removeObject:dic];
//                break;
//            }
//        }
//    }
//}
//
///// 获取需要动画的数据类型
//- (packNotiMsgManagerType)packNotiMsg_getAnimateType
//{
//    NSDictionary *dic = self.animateArray.firstObject;
//
//    // 赋值正在动画的数据obj
//    self.animateObjIndex = 0;
//
//    if (dic[@"packet"]) {  // 表示第一个数据是红包
//        self.animateType = packNotiMsgManagerType_packet;
//    }else if (dic[@"noti"]){
//        self.animateType = packNotiMsgManagerType_noti;
//    }else if (dic[@"msg"]){
//        self.animateType = packNotiMsgManagerType_msg;
//    }else{
//        self.animateType = packNotiMsgManagerType_none;
//    }
//    return self.animateType;
//}
//
//#pragma mark - 执行动画
///// 执行动画
//- (void)packNotiMsg_beginAnimate
//{
//    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
//        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//        return;
//    }
//    // 判断是否在首页 不是首页直接退出
//    JACenterDrawerViewController *centerVc = [AppDelegateModel getCenterMenuViewController];
//
//    if (![centerVc.view isDisplayedInScreen]) {
//        return;
//    }
//
//    if (self.animateType != packNotiMsgManagerType_none) {  // 正在动画
//
//        if (self.animateType == packNotiMsgManagerType_packet && self.packet_aniRemove) {  // 红包正在动画，并且不是第一次
//            [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_showSmallPersonAnimate];
//        }
//
//        return;
//    }
//
//    if (!self.animateArray.count) {   // 没有需要动画数据
//        return;
//    }
//
//    // 获取动画的类型
//    packNotiMsgManagerType type = [self packNotiMsg_getAnimateType];
//
//    if (self.animateType == packNotiMsgManagerType_none) {  // 安全监测正在动画
//        return;
//    }
//
//    if (self.animateType != packNotiMsgManagerType_packet) {
//        return;
//    }
//
//    // 取消执行
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetMaginTime) object:self];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.maginTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        self.maginTime = 1.0;
//        // 控件根据类型执行动画
//        [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_beginAnimateWithType:type];
//
//        [self performSelector:@selector(resetMaginTime) withObject:self afterDelay:1.0];
//    });
//}
//
//- (void)resetMaginTime
//{
//    self.maginTime = 0.0;
//}
//
//#pragma mark - 未登录展示
///// 未登录展示
//- (void)packNotiMsg_beginAnimate_notLogin
//{
//    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
//        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//        return;
//    }
//    // 直接展示红包 动画
//    [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_notLoginShowPacketAnimate];
//}
//
//#pragma mark - 移除动画
///// 移除动画
//- (void)packNotiMsg_removeAnimate
//{
//    // 移除动画
//    if (self.animateType == packNotiMsgManagerType_noti) {
//        [self.animateArray removeObjectAtIndex:self.animateObjIndex];
//        self.animateType = packNotiMsgManagerType_none;
//        self.noti_aniFinish = YES;
//        self.animateObjIndex = 0;
//    }
//
//    if (self.animateType == packNotiMsgManagerType_msg) {
//        [self.animateArray removeObjectAtIndex:self.animateObjIndex];
//        self.animateType = packNotiMsgManagerType_none;
//        self.msg_aniFinish = YES;
//        self.animateObjIndex = 0;
//    }
//
//    if (self.animateType == packNotiMsgManagerType_packet) {
//
//        self.packet_aniRemove = YES;
//        AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//        if (myAppDelegate.packetArray.count == 0) {
//
//            self.animateType = packNotiMsgManagerType_none;
//            self.animateObjIndex = 0;
//            self.packet_aniRemove = NO;
//            [self.animateArray removeObjectAtIndex:self.animateObjIndex];
//        }
//
//    }
//
//    // 移除动画
//    [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_removeAnimateView];
//
//}
//
//#pragma mark - 启动app时，获取需要动画的数据
///// 启动app时，获取需要动画的数据
//- (void)packNotiMsg_APPStartNeedAnimate:(BOOL)needAnimate
//{
////    @WeakObj(self);
////    [self packNotiMsg_getPackList:^(NSDictionary *result) {
////        @StrongObj(self);
////        [self packNotiMsg_getNotiInfo];
////        [self packNotiMsg_getMsgInfo];
////    }];
//    @WeakObj(self);
//    [self packNotiMsg_getPackListWithAnimate:needAnimate finishBlock:^(NSDictionary *result) {
//        @StrongObj(self);
//        [self packNotiMsg_getNotiInfoWithAnimate:needAnimate];
//        [self packNotiMsg_getMsgInfoWithAnimate:needAnimate];
//    }];
//}
//
//#pragma mark - 动画结束
///// 动画结束 （发动画完成的通知的时候，确保用户点击不到再发。红包类型的无所谓）
//- (void)packetNotiMsganimateFinish
//{
//    if (!self.animateArray.count) {
//        return;
//    }
//
//    if (self.animateType == packNotiMsgManagerType_noti) {
//        self.noti_aniFinish = YES;
//
//    }
//    if (self.animateType == packNotiMsgManagerType_msg) {
//        self.msg_aniFinish = YES;
//    }
//
//    if (self.animateType == packNotiMsgManagerType_packet) {   // 如果是红包类型需要看看红包数组还有没有数据
//
//        self.packet_aniRemove = YES;
//        AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//        if (myAppDelegate.packetArray.count) {
//
//            return;
//        }
//    }
//
//    self.animateType = packNotiMsgManagerType_none;
//    self.animateObjIndex = 0;
//    self.packet_aniRemove = NO;
//
//    [self.animateArray removeObjectAtIndex:self.animateObjIndex];
//
//    // 开始执行动画
//    [self packNotiMsg_beginAnimate];
//}
//
//#pragma mark - 点击动画的view 跳转
///// 点击动画的view
//- (void)packNotiMsg_clickAnimateView
//{
//
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalRegist];
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[JA_Property_BindingType] = @"点击红包";
//        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
//        return;
//    }
//
//    if (self.animateType == packNotiMsgManagerType_packet) {
//
//        [self packetNotiMsgopenPacket];
//    }
//
//    if (self.animateType == packNotiMsgManagerType_noti) {
//
//        // 跳转通知
////        JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
////        vc.selectIndex = 1;
////        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
//        [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
//        [self cyl_tabBarController].selectedIndex = 2;
//
//    }
//
//    if (self.animateType == packNotiMsgManagerType_msg) {
//
//        // 跳转私信
////        JAsynthesizeMessageViewController *vc = [[JAsynthesizeMessageViewController alloc] init];
////        vc.selectIndex = 2;
////        [[AppDelegateModel getBaseNavigationViewControll] pushViewController:vc animated:YES];
//        [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
//        [self cyl_tabBarController].selectedIndex = 2;
//
//        JAsynthesizeMessageViewController *vc = [self cyl_tabBarController].selectedViewController.childViewControllers[0];
//        vc.selectIndex = 1;
//    }
//
//    // 移除动画
//    [self packNotiMsg_removeAnimate];
//}
//
//#pragma mark - 开红包
//// 开红包
//- (void)packetNotiMsgopenPacket
//{
//    // 获取红包数据
//    AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    NSDictionary *dic = myAppDelegate.packetArray.firstObject;
//
//    JARedPacketView *packet = [[JARedPacketView alloc] init];
//    packet.packetDic = dic;
//    @WeakObj(self);
//    packet.unOpenClose = ^{
//
//        if (myAppDelegate.packetArray.count) {
//            // 展示 扒樯的动画
//            [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_showSmallPersonAnimate];
//        }
//    };
//
//    packet.openClose = ^(BOOL isClose) {
//        @StrongObj(self);
//        if (isClose) {   // 开完后 直接关闭弹窗
//            if (myAppDelegate.packetArray.count) {
//                [self packetNotiMsgopenPacket];
//            }else{
//                // 没有红包了 要移除
//                self.animateType = packNotiMsgManagerType_none;
//                self.animateObjIndex = 0;
//                self.packet_aniRemove = NO;
//                [self.animateArray removeObjectAtIndex:self.animateObjIndex];
//
//                // 检查动画列表
//                [self packNotiMsg_beginAnimate];
//            }
//        }else{  // 开完后 跳转其他节目
//            if (myAppDelegate.packetArray.count == 0) {
//                // 没有红包了 要移除
//                self.animateType = packNotiMsgManagerType_none;
//                self.animateObjIndex = 0;
//                self.packet_aniRemove = NO;
//                [self.animateArray removeObjectAtIndex:self.animateObjIndex];
//
//            }
//        }
//    };
//    [[[[UIApplication sharedApplication] delegate] window] addSubview:packet];
//}
//
///* ----------------------------------------- 新逻辑 ---------------------------------------- */
//
//
///* ----------------------------------------- 老逻辑 ---------------------------------------- */
//static UIView *win = nil;
///// 网络请求红包列表 展示红包浮层
//+ (void)packet_showPacket
//{
//    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
//        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//
//        // 测试服不展示  为 0 的时候才展示
//
//        win.hidden = YES;
//
//        return;
//    }
//
//    if (IS_LOGIN) {
//
//        [self getPacketList:^(NSDictionary *result) {
//
//            // 保存红包数据
//            AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [myAppDelegate.packetArray removeAllObjects];
//            [myAppDelegate.packetArray addObjectsFromArray:result[@"arraylist"]];
//
//            if (myAppDelegate.packetArray.count == 0) {
//
//                win = [self getWin];
//                win.hidden = YES;
//
//                return;
//            }else{
//                win = [self getWin];
//                win.hidden = NO;
//            }
//            // 展示红包悬浮窗
//            // 没登录的时候总是展示该小红包按钮
//            win = [self getWin];
//
//            win.hidden = NO;
//
//            [UIView animateWithDuration:0.3 delay:0.2 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
//
//                [UIView setAnimationRepeatCount:3];//动画的重复次数
//                win.x -= 3;
//                win.x += 3;
//            } completion:^(BOOL finished) {
//                win.x = JA_SCREEN_WIDTH - win.width;
//            }];
//        }];
//
//    }else{
//
//        win = [self getWin];
//
//        [UIView animateWithDuration:0.3 delay:0.2 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
//
//            [UIView setAnimationRepeatCount:3];//动画的重复次数
//            win.x -= 3;
//            win.x += 3;
//        } completion:^(BOOL finished) {
//            win.x = JA_SCREEN_WIDTH - win.width;
//        }];
//
//    }
//
//
//}
//
///// 隐藏开红包界面
//+ (void)packet_hiddenPacket
//{
//    win.hidden = YES;
//}
//
///// 展示开红包界面
//+ (void)packet_showPacketView
//{
//    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
//        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//        // 测试服不展示  为 0 的时候才展示
//
//        win.hidden = YES;
//
//        return;
//    }
//    // 没登录也展示
//    if (!IS_LOGIN) {
//        win = [self getWin];
//        win.hidden = NO;
//    }else{
//
//        // 获取数据库是否有红包 - 有则展示 无不处理
//        // 保存红包数据
//        AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//
//        if (myAppDelegate.packetArray.count != 0) {
//            win = [self getWin];
//            win.hidden = NO;
//
//        }
//    }
//
//    [UIView animateWithDuration:0.3 delay:0.2 usingSpringWithDamping:0.2 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
//
//        [UIView setAnimationRepeatCount:3];//动画的重复次数
//        win.x -= 3;
//        win.x += 3;
//    } completion:^(BOOL finished) {
//        win.x = JA_SCREEN_WIDTH - win.width;
//    }];
//}
//
///// 点击浮层弹出开红包界面
//+ (void)showPacket
//{
//    // 获取红包
//    AppDelegate *myAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    NSDictionary *dic = myAppDelegate.packetArray.firstObject;
//
//    [self packet_hiddenPacket];
//
//    // 有值的时候才展示红包
//    if (dic && IS_LOGIN) {
//        JARedPacketView *packet = [[JARedPacketView alloc] init];
//        packet.packetDic = dic;
//        [[[[UIApplication sharedApplication] delegate] window] addSubview:packet];
//        //        [[[[UIApplication sharedApplication] delegate] window] addSubview:packet];
//    }else{
//        JARedPacketView *packet = [[JARedPacketView alloc] init];
//        [[[[UIApplication sharedApplication] delegate] window] addSubview:packet];
//        //        [[[[UIApplication sharedApplication] delegate] window] addSubview:packet];
//    }
//
//
//}
//
//
//+ (void)getPacketList:(void(^)(NSDictionary *result))finishBlock
//{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    [[JAUserApiRequest shareInstance] userAllPacketList:dic success:^(NSDictionary *result) {
//
//        if (result) {
//            finishBlock(result);
//        }
//    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
//}
//
//+ (UIView *)getWin
//{
//    if (win == nil) {
//
//        win = [[UIView alloc] init];
//        win.backgroundColor = [UIColor clearColor];
//        win.width = 113;
//        win.height = 136;
//        win.x = JA_SCREEN_WIDTH - win.width;
//        win.y = JA_SCREEN_HEIGHT - win.height - (50+JA_TabbarSafeBottomMargin);
//
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPacket)];
//        [win addGestureRecognizer:tap];
//
//        [[[[UIApplication sharedApplication] delegate] window].rootViewController.view addSubview:win];
//    }
//    win.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"packet_home"].CGImage);
//
//    return win;
//}

@end
