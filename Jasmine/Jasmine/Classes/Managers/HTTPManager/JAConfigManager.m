//
//  JAConfigManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAConfigManager.h"
#import "JACacheDataManager.h"
#import "JAShareRegistModel.h"
#import "JASwitchDefine.h"

@implementation JAConfigManager

+ (JAConfigManager *)shareInstance
{
    static JAConfigManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAConfigManager alloc] init];
            
            instance.isDebug = @"1"; // 正式环境默认为苹果审核
            NSString *host = @"https://data.urmoli.com";
#ifdef JA_TEST_HOST
            host =@"http://dev.api.yourmoli.com";
            instance.isDebug = @"0";
#endif
            instance.host = host;
 
            instance.deleteReasonArray = [JACacheDataManager getLocalDeleteReason];
            instance.creditRuleArray = [JACacheDataManager getLocalCreditRule];
            instance.levelArray = [JACacheDataManager getLocalLevelInfo];
            instance.reportArray = [JACacheDataManager getLocalReport];
            instance.shareTemplateArray = [JACacheDataManager getLocalShareTemplate];
            instance.guideBookArray = [JACacheDataManager getLocalGuideBookHelp];
            instance.guideVideoArray = [JACacheDataManager getLocalGuideVideoHelp];
//            instance.hideAndSinkArray = [JACacheDataManager getLocalHideAndSink];
        }
    });
    return instance;
}

//// 测试本地服务器
//- (NSString *)host
//{
////    return @"http://192.168.1.17:8084";  // 文章、故事、回答、提问
//    return @"http://192.168.1.17:8081";  // 收藏、分享
//
//    
////    return @"http://api.java.duailin.top"; // 外网
//    return @"http://192.168.1.20:8030";  // 个人 mine
////    return @"http://192.168.1.20:8082";  // 发现 discover
////    return @"http://192.168.1.20:8010";  // 故事 explore
//}


@end
