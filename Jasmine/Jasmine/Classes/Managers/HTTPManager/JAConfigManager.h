//
//  JAConfigManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/6/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class JAShareRegistModel;
@interface JAConfigManager : NSObject

@property (nonatomic, copy) NSString *host;
@property (nonatomic, copy) NSString *isDebug; // 0正式 1测试
@property (nonatomic, copy) NSString *isMaintain; // 0正常 1维护
@property (nonatomic, copy) NSString *maintainDate; // 维护开始时间
@property (nonatomic, copy) NSString *maintainEndDate; // 维护结束时间
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, copy) NSString *city;      // 城市
@property (nonatomic, copy) NSString *province;  // 省份
@property (nonatomic, copy) NSString *area;      // 区域
@property (nonatomic, assign) NSInteger signState; // 0未签到 1已签到
@property (nonatomic, copy) NSString *operateStat; // 0不需要跟新1更新2强制更新
@property (nonatomic, copy) NSString *updateUrl; // 版本更新地址
@property (nonatomic, copy) NSString *updateContent; // 版本更新内容
@property (nonatomic, copy) NSString *updateVersion; // 新更新的版本号
@property (nonatomic, strong) NSDictionary *channelDic;
@property (nonatomic, strong) NSMutableArray *channelArr;
@property (nonatomic, assign) NSInteger showShareStoryAward;
@property (nonatomic, assign) NSInteger showShareIncomeAward;
@property (nonatomic, assign) BOOL isCheckNewVersion; // 无网状态下进入app，回复网络后调用配置接口获取新版本信息

@property (nonatomic, strong) NSString *QQGroup; // 关于页面的QQ群号
@property (nonatomic, copy) NSString *saServerUrl; // 神策数据接收地址
@property (nonatomic, copy) NSString *saConfigUrl; // 神策配置分发地址

// 缓存策略
@property (nonatomic, strong) NSArray *deleteReasonArray;// 管理员删除原因
@property (nonatomic, strong) NSArray *creditRuleArray;// 信用规则
@property (nonatomic, strong) NSArray *levelArray;// 等级列表
@property (nonatomic, strong) NSArray *reportArray;// 等级列表
@property (nonatomic, strong) JAShareRegistModel *shareRegistModel;// 邀请红包页面 分享信息
@property (nonatomic, strong) NSArray *shareTemplateArray;// 分享模板
@property (nonatomic, strong) NSArray *guideBookArray;// 新手教程
@property (nonatomic, strong) NSArray *guideVideoArray;// 视频教程

// 2.6.0
@property (nonatomic, assign) NSInteger doubleFloatType; //完成任务弹双倍时的类型 0 不需要完成任务 1 微信完成任务 2 QQ完成任务

@property (nonatomic, assign) NSInteger shopSign;  // 0 不显示 1 显示
@property (nonatomic, strong) NSString *shopUrl;  // 商场链接

+ (JAConfigManager *)shareInstance;

@end
