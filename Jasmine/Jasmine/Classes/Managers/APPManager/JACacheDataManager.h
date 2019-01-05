//
//  JACacheDataManager.h
//  Jasmine
//
//  Created by xujin on 30/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JACacheDataManager : NSObject

/**************************** 缓存策略初始化数据 ****************************/

// 初始化频道信息
+ (NSMutableArray *)getLocalChannels;
// 初始化删除原因
+ (NSArray *)getLocalDeleteReason;
// 初始化信用规则
+ (NSArray *)getLocalCreditRule;
// 初始化等级信息
+ (NSArray *)getLocalLevelInfo;
// 初始化举报原因
+ (NSArray *)getLocalReport;
// 获取分享模板信息
+ (NSArray *)getLocalShareTemplate;
// 初始化获取新手教程
+ (NSArray *)getLocalGuideBookHelp;
// 初始化获取视频教程
+ (NSArray *)getLocalGuideVideoHelp;
// 初始化沉帖、隐藏原因
+ (NSArray *)getLocalHideAndSink;

/**************************** 缓存策略更新数据 ****************************/

// 获取频道信息
+ (void)updateChannels:(NSArray *)channels;
// 管理员的时候获取删除内容原因的接口（普通用户的举报也是用这个）
+ (void)getDeleteReason:(NSInteger)version;
// 获取信用页面信息
+ (void)getCreditInfo:(NSInteger)version;
// 获取等级信息
+ (void)getLevelInfo:(NSInteger)version;
// 获取举报、禁言用户原因
+ (void)getReportAndBannedInfo:(NSInteger)version;
// 获取分享注册信息
+ (void)getShareRegistInfo;
+ (void)updateShareRegistInfo:(NSInteger)version;
// 获取分享模板信息
+ (void)getShareTemplate:(NSInteger)version;
// 获取新手教程
+ (void)getGuideBookHelp:(NSInteger)version;
// 获取视频教程
+ (void)getGuideVideoHelp:(NSInteger)version;
// 获取沉帖、隐藏原因
+ (void)getHideAndSink:(NSInteger)version;

@end
