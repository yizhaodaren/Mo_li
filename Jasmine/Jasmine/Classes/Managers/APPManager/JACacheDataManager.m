//
//  JACacheDataManager.m
//  Jasmine
//
//  Created by xujin on 30/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JACacheDataManager.h"
#import "JAVoiceCommonApi.h"
#import "JAVoicePersonApi.h"
#import "JAUserApiRequest.h"
#import "JADeleteReasonModel.h"
#import "JACreditRuleModel.h"
#import "JAReportResonModel.h"
#import "JAShareRegistModel.h"
#import "JASharePictureModel.h"
#import "JAGuideHelpModel.h"
#import "JAChannelModel.h"

static NSString *const abc = @"";


@implementation JACacheDataManager

#pragma mark - Helper


#pragma mark - 缓存策略初始化数据
// 初始化频道信息
+ (NSMutableArray *)getLocalChannels {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/ChannelsDefault.plist"];
    NSMutableArray *channels = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    if (!channels.count) {
        // 沙盒没有数据，读取工程内的plist文件
        filePath = [[NSBundle mainBundle] pathForResource:@"ChannelsDefault.plist" ofType:nil];
        channels = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
    }
 
    NSMutableDictionary *channelDic = [NSMutableDictionary new];
    NSMutableArray *channelArr = [NSMutableArray new];
    for (int i=0; i<channels.count; i++) {
        NSDictionary *dic = channels[i];
        JAChannelModel *model = [JAChannelModel mj_objectWithKeyValues:dic];
        if (model) {
            [channelDic setValue:model.title forKey:model.channelId];
            [channelArr addObject:model];
        }
    }
    [JAConfigManager shareInstance].channelDic = channelDic;
    [JAConfigManager shareInstance].channelArr = channelArr;
    return channelArr;
}

// 初始化删除原因
+ (NSArray *)getLocalDeleteReason {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/DeleteReason.plist"];
    NSDictionary *reasonDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *reasons = reasonDic[@"ListContent"];
    if (!reasons.count) {
        // 沙盒没有数据，读取工程内的plist文件
        filePath = [[NSBundle mainBundle] pathForResource:@"DeleteReason.plist" ofType:nil];
        reasonDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        reasons = reasonDic[@"ListContent"];
    }
    
    NSArray *reasonModels = [JADeleteReasonModel mj_objectArrayWithKeyValuesArray:reasons];
    return reasonModels;
}

// 初始化信用规则
+ (NSArray *)getLocalCreditRule {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/CreditInfoDefault.plist"];
    NSDictionary *creditInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *creditRules = creditInfoDic[@"listIntegralInfoConfig"];
    if (!creditRules.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"CreditInfoDefault.plist" ofType:nil];
        creditInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        creditRules = creditInfoDic[@"listIntegralInfoConfig"];
    }
    
    NSArray *creditRuleModels = [JACreditRuleModel mj_objectArrayWithKeyValuesArray:creditRules];
    return creditRuleModels;
}

// 初始化等级信息
+ (NSArray *)getLocalLevelInfo {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/LevelInfoDefault.plist"];
    NSDictionary *levelInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *listGrade = levelInfoDic[@"listGrade"];
    if (!listGrade.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"LevelInfoDefault.plist" ofType:nil];
        levelInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        listGrade = levelInfoDic[@"listGrade"];
    }

    NSArray *listGradeModels = [JALevelModel mj_objectArrayWithKeyValuesArray:listGrade];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rightsType='story'"];
    NSArray *leftArray = [listGradeModels filteredArrayUsingPredicate:predicate];
    NSArray *sortArray = [leftArray sortedArrayUsingComparator:^NSComparisonResult(JALevelModel *obj1, JALevelModel *obj2) {
        if (obj1.gradeNum < obj2.gradeNum) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    return sortArray;
}

// 初始化举报原因
+ (NSArray *)getLocalReport {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/ReportInfoDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *reports = dic[@"arraylist"];
    if (!reports.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"ReportInfoDefault.plist" ofType:nil];
        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        reports = dic[@"arraylist"];
    }
    
    NSArray *modelArray = [JAReportResonModel mj_objectArrayWithKeyValuesArray:reports];
    return modelArray;
}

// 初始化获取分享模板信息
+ (NSArray *)getLocalShareTemplate
{
    NSString *filePath = [NSString ja_getPlistFilePath:@"/ShareTemplateDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *shareArr = dic[@"allShareFriendList"];
    if (!shareArr.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"ShareTemplateDefault.plist" ofType:nil];
        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        shareArr = dic[@"allShareFriendList"];
    }
    
    NSArray *modelArray = [JASharePictureModel mj_objectArrayWithKeyValuesArray:shareArr];
    return modelArray;
}

// 初始化获取新手教程
+ (NSArray *)getLocalGuideBookHelp
{
    NSString *filePath = [NSString ja_getPlistFilePath:@"/GuideBookHelpDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *array = dic[@"arraylist"];
    if (!array.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"GuideBookHelpDefault.plist" ofType:nil];
        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        array = dic[@"arraylist"];
    }
    
    NSArray *modelArray = [JAGuideHelpModel mj_objectArrayWithKeyValuesArray:array];
    return modelArray;
}

// 初始化获取视频教程
+ (NSArray *)getLocalGuideVideoHelp
{
    NSString *filePath = [NSString ja_getPlistFilePath:@"/GuideVideoHelpDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *array = dic[@"arraylist"];
    if (!array.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"GuideVideoHelpDefault.plist" ofType:nil];
        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        array = dic[@"arraylist"];
    }
    
    NSArray *modelArray = [JAGuideHelpModel mj_objectArrayWithKeyValuesArray:array];
    return modelArray;
}

// 初始化沉帖、隐藏原因
+ (NSArray *)getLocalHideAndSink
{
//    NSString *filePath = [NSString ja_getPlistFilePath:@"/HideAndSinkDefault.plist"];
//    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//    NSArray *array = dic[@"arraylist"];
//    if (!array.count) {
//        filePath = [[NSBundle mainBundle] pathForResource:@"GuideVideoHelpDefault.plist" ofType:nil];
//        dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        array = dic[@"arraylist"];
//    }
//
//    NSArray *modelArray = [JAGuideHelpModel mj_objectArrayWithKeyValuesArray:array];
//    return modelArray;
    return nil;
}

#pragma mark - 缓存策略更新数据
// 获取频道信息
+ (void)updateChannels:(NSArray *)channels {
    if (channels.count) {
        NSMutableDictionary *channelDic = [NSMutableDictionary new];
        NSMutableArray *channelArr = [NSMutableArray new];
        for (int i=0; i<channels.count; i++) {
            NSDictionary *dic = channels[i];
            JAChannelModel *model = [JAChannelModel mj_objectWithKeyValues:dic];
            if (model) {
                [channelDic setValue:model.title forKey:model.channelId];
                [channelArr addObject:model];
            }
        }
        // v2.5.0的发现的bug，当频道数减少时会导致首页数组越界
        // 获取网络数据晚于页面展示，会出现这种情况
        // v2.5.2以后修复这个问题
        if (![JAConfigManager shareInstance].channelArr.count) {
            // 已赋值就不更新值，下次启动才更新
            [JAConfigManager shareInstance].channelDic = channelDic;
            [JAConfigManager shareInstance].channelArr = channelArr;
        }
        NSString *filePath = [NSString ja_getPlistFilePath:@"/ChannelsDefault.plist"];
        [channels writeToFile:filePath atomically:YES];
    }
}

// 管理员的时候获取删除内容原因的接口（普通用户的举报也是用这个）
+ (void)getDeleteReason:(NSInteger)version {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/DeleteReason.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"dataType"] = @"1";
        [[JAVoiceCommonApi shareInstance] voice_getDeleteReason:params success:^(NSDictionary *result) {
            NSArray *reasons = [JADeleteReasonModel mj_objectArrayWithKeyValuesArray:result[@"ListContent"]];
            if (reasons.count) {
                [JAConfigManager shareInstance].deleteReasonArray = reasons;
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                dictionary[@"version"] = @(version);
                [dictionary writeToFile:filePath atomically:YES];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

// 获取信用页面信息
+ (void)getCreditInfo:(NSInteger)version {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/CreditInfoDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"type"] = @"credit";
        [[JAUserApiRequest shareInstance] userCreditInfo:dic success:^(NSDictionary *result) {
            if (result) {
                NSArray *ruleModels = [JACreditRuleModel mj_objectArrayWithKeyValuesArray:result[@"listIntegralInfoConfig"]];
                if (ruleModels.count) {
                    [JAConfigManager shareInstance].creditRuleArray = ruleModels  ;
                }
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                dictionary[@"version"] = @(version);
                [dictionary writeToFile:filePath atomically:YES];
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

// 获取等级信息
+ (void)getLevelInfo:(NSInteger)version {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/LevelInfoDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"type"] = @"1";
        if (IS_LOGIN) {
            dic[@"levelId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelId];
        }else{
            dic[@"levelId"] = @"1";
        }
        [[JAUserApiRequest shareInstance] userLevelList:dic success:^(NSDictionary *result) {
            NSArray *listGrade = [JALevelModel mj_objectArrayWithKeyValuesArray:result[@"listGrade"]];
            if (listGrade.count) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rightsType='story'"];
                NSArray *leftArray = [listGrade filteredArrayUsingPredicate:predicate];
                NSArray *sortArray = [leftArray sortedArrayUsingComparator:^NSComparisonResult(JALevelModel *obj1, JALevelModel *obj2) {
                    if (obj1.gradeNum < obj2.gradeNum) {
                        return NSOrderedAscending;
                    }
                    return NSOrderedDescending;
                }];
                [JAConfigManager shareInstance].levelArray = sortArray;
                
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                dictionary[@"version"] = @(version);
                [dictionary writeToFile:filePath atomically:YES];
            }
        } failure:^(NSError *error) {
        }];
    }
}

// 获取举报、禁言用户原因
+ (void)getReportAndBannedInfo:(NSInteger)version {
    NSString *filePath = [NSString ja_getPlistFilePath:@"/ReportInfoDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[@"dataType"] = @"2";
        [[JAVoiceCommonApi shareInstance] voice_getDeleteReason:params success:^(NSDictionary *result) {
            if (result) {
                NSArray *reportModels = [JAReportResonModel mj_objectArrayWithKeyValuesArray:result[@"ListContent"]];
                if (reportModels.count) {
                    [JAConfigManager shareInstance].reportArray = reportModels;
                    
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                    dictionary[@"version"] = @(version);
                    [dictionary writeToFile:filePath atomically:YES];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

// 获取分享注册信息
+ (void)getShareRegistInfo {
    if (IS_LOGIN) {
        NSString *uuid = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
        NSString *filePath = [NSString ja_getPlistFilePath:[NSString stringWithFormat:@"/ShareRegistInfoDefault_%@.plist",uuid]];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        if (!dic) {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"uuid"] = uuid;
            [[JAUserApiRequest shareInstance] userShareInviteInfo:param success:^(NSDictionary *result) {
                NSDictionary *resultDic = result[@"resMap"];
                if (resultDic) {
                    
//                    JAShareRegistModel *model = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
//                    [JAConfigManager shareInstance].shareRegistModel = model;
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                    dictionary[@"version"] = @(0);
                    [dictionary writeToFile:filePath atomically:YES];
                }
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

+ (void)updateShareRegistInfo:(NSInteger)version {
    if (IS_LOGIN) {
        NSString *uuid = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
        NSString *filePath = [NSString ja_getPlistFilePath:[NSString stringWithFormat:@"/ShareRegistInfoDefault_%@.plist",uuid]];
        NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        NSInteger currentVersion = [dic[@"version"] integerValue];
        if (dic && currentVersion < version) {
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            param[@"uuid"] = uuid;
            [[JAUserApiRequest shareInstance] userShareInviteInfo:param success:^(NSDictionary *result) {
                NSDictionary *resultDic = result[@"resMap"];
                if (resultDic) {
                    
//                    JAShareRegistModel *model = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
//                    [JAConfigManager shareInstance].shareRegistModel = model;
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                    dictionary[@"version"] = @(version);
                    [dictionary writeToFile:filePath atomically:YES];
                }
                
            } failure:^(NSError *error) {
                
            }];
        }
    }
}

// 获取分享模板信息
+ (void)getShareTemplate:(NSInteger)version {
    
    NSString *filePath = [NSString ja_getPlistFilePath:@"/ShareTemplateDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {

        [[JAVoiceCommonApi shareInstance] voice_getShareTemplate:nil success:^(NSDictionary *result) {
            if (result) {
                NSArray *shareArr = [JASharePictureModel mj_objectArrayWithKeyValuesArray:result[@"allShareFriendList"]];
                
                if (shareArr.count) {
                    [JAConfigManager shareInstance].shareTemplateArray = shareArr;
                    
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                    dictionary[@"version"] = @(version);
                    [dictionary writeToFile:filePath atomically:YES];
                }
            }
        } failure:^(NSError *error) {
        }];
    }
}

// 获取新手教程
+ (void)getGuideBookHelp:(NSInteger)version {
    
    NSString *filePath = [NSString ja_getPlistFilePath:@"/GuideBookHelpDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"type"] = @"0";
        dic[@"platform"] = @"IOS";
        
        [[JAVoicePersonApi shareInstance] voice_helperWithPara:dic success:^(NSDictionary *result) {
            
            if (result) {
                NSArray *array = [JAGuideHelpModel mj_objectArrayWithKeyValuesArray:result[@"arraylist"]];
                
                if (array.count) {
                    [JAConfigManager shareInstance].guideBookArray = array;
                    
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                    dictionary[@"version"] = @(version);
                    [dictionary writeToFile:filePath atomically:YES];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

// 获取视频教程
+ (void)getGuideVideoHelp:(NSInteger)version {
    
    NSString *filePath = [NSString ja_getPlistFilePath:@"/GuideVideoHelpDefault.plist"];
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSInteger currentVersion = [dic[@"version"] integerValue];
    if (currentVersion < version) {

        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"type"] = @"1";
        dic[@"platform"] = @"IOS";
        
        [[JAVoicePersonApi shareInstance] voice_helperWithPara:dic success:^(NSDictionary *result) {
            if (result) {
                NSArray *array = [JAGuideHelpModel mj_objectArrayWithKeyValuesArray:result[@"arraylist"]];
                
                if (array.count) {
                    [JAConfigManager shareInstance].guideVideoArray = array;
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
                    dictionary[@"version"] = @(version);
                    [dictionary writeToFile:filePath atomically:YES];
                }
            }
        } failure:^(NSError *error) {
            
        }];
    }
}

// 获取沉帖、隐藏原因
+ (void)getHideAndSink:(NSInteger)version {
    
//    NSString *filePath = [NSString ja_getPlistFilePath:@"/HideAndSinkDefault.plist"];
//    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:filePath];
//    NSInteger currentVersion = [dic[@"version"] integerValue];
//    if (currentVersion < version) {
//
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"type"] = @"1";
//        dic[@"platform"] = @"IOS";
//
//        [[JAVoicePersonApi shareInstance] voice_helperWithPara:dic success:^(NSDictionary *result) {
//            if (result) {
//                NSArray *array = [JAGuideHelpModel mj_objectArrayWithKeyValuesArray:result[@"arraylist"]];
//
//                if (array.count) {
//                    [JAConfigManager shareInstance].guideVideoArray = array;
//                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
//                    dictionary[@"version"] = @(version);
//                    [dictionary writeToFile:filePath atomically:YES];
//                }
//            }
//        } failure:^(NSError *error) {
//
//        }];
//    }
}

@end
