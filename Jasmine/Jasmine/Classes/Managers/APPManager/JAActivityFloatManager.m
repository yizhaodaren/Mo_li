//
//  JAActivityFloatManager.m
//  Jasmine
//
//  Created by moli-2017 on 2017/11/16.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAActivityFloatManager.h"
#import "JAActivityFloatModel.h"
#import "JAVoiceCommonApi.h"
#import "JAUserApiRequest.h"
#import "JAHomeSignView.h"
#import "JAHomeFloatActivityView.h"

#import "CYLTabBarController.h"

@interface JAActivityFloatManager ()

@property (nonatomic, assign) BOOL isToday;

@end

@implementation JAActivityFloatManager

/// 开启活动/签到弹窗
- (void)FloatActivity:(void(^)())floatViewCloseBlock
{
    if (!IS_LOGIN) {
        return;
    }
    
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
//        // 这个时候仅仅去获取一次签到状态
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//        [[JAUserApiRequest shareInstance] userSignInfo:dic success:^(NSDictionary *result) {
//            [JAConfigManager shareInstance].signState = [result[@"hashmap"][@"user"][@"isSign"] integerValue];
//        } failure:^(NSError *error) {
//            
//        }];
        return;
    }
    
    _isToday = [self checkIsToday];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"platform"] = @"IOS";
    // 获取活动弹窗数据
    [[JAVoiceCommonApi shareInstance] voice_activityFloat:dic success:^(NSDictionary *result) {
       
        // 1 解析数据
        NSArray *modelArray = [JAActivityFloatModel mj_objectArrayWithKeyValuesArray:result[@"alertList"]];
        
        // 2 如果没有数据 - 启动签到弹窗
        if (!modelArray.count) {
            [self getSignInfo:_isToday needSign:^(BOOL signState,NSDictionary *signInfo) {
                if (signState) {
                    JAHomeSignView *signView = [[JAHomeSignView alloc] init];
//                    signView.signInfoDic = signInfo;
//                    signView.signHomeClose = ^{
//                        if (floatViewCloseBlock) {
//                            floatViewCloseBlock();
//                        }
//                    };
                    
                    if ([self cyl_tabBarController].selectedIndex == 0) {
                        
                        [[UIApplication sharedApplication].delegate.window addSubview:signView];
                    }
//                    JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
//                    [vc.view addSubview:signView];
                    
                    MMDrawerController *mmD = [AppDelegateModel rootviewController];
                    [mmD setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
                }else{
                    // 弹出
                    JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
                    if (vc.adIsDismiss) {
                        
                        if (floatViewCloseBlock) {    // 直接执行block的内容，
                            floatViewCloseBlock();
                        }
                    }
                }

            }];
            return;
        }
        
        [self getSignInfo:_isToday needSign:nil];  // 只是获取签到状态（用于展示签到的标签）
        
        // 3 如果有数据 - 启动活动弹层
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (!_isToday) {   // 不是同一天 直接清除老的表
                // 先清除缓存 清除弹层时间
                NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
                NSString *key = [NSString stringWithFormat:@"%@_%@",uid,@"activityMaginTime"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                [LKDBHelper clearTableData:[JAActivityFloatModel class]];
                // 3.1.1  遍历模型数组 存入库
                for (NSInteger i = 0; i < modelArray.count; i++) {
                    
                    JAActivityFloatModel *model = modelArray[i];
                    [model saveToDB];
                }
                
            }else{  // 是同一天
                
                NSArray *storeActivity = [JAActivityFloatModel searchWithWhere:nil];
                // 先清除缓存
                [LKDBHelper clearTableData:[JAActivityFloatModel class]];
                
                // 3.1.2  遍历模型数组 从storeActivity中获取已经存在的模型更新状态
                for (NSInteger i = 0; i < modelArray.count; i++) {
                    
                    JAActivityFloatModel *model = modelArray[i];
                    JAActivityFloatModel *m = [self checkContainObj:model array:storeActivity];
                    if (m) {
                        model.floatState = m.floatState;
                    }
                    // 插入数据库
                    [model saveToDB];
                }
            }
            
            
            // 如果在间隔时间内不弹层
            JAActivityFloatModel *randomM = modelArray.firstObject;
            NSTimeInterval floatTime = [self storeTimeMargin:(randomM.time * 60.0)];
            if (!floatTime) {  // 在时间间隔内
                // 回到主线程弹出
                dispatch_async(dispatch_get_main_queue(), ^{
                    JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
                    if (vc.adIsDismiss) {
                        
                        if (floatViewCloseBlock) {    // 直接执行block的内容，
                            floatViewCloseBlock();
                        }
                    }
                    
                });
                return;
            }else{
                // 存储弹窗时间
                NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
                NSString *key = [NSString stringWithFormat:@"%@_%@",uid,@"activityMaginTime"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",floatTime] forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
           // 3.2 开始弹窗
            
            // 查询数据库（权重倒序）
            NSArray *activityArr = [JAActivityFloatModel searchWithWhere:nil orderBy:@"sort desc" offset:0 count:0];
            
            JAActivityFloatModel *model = activityArr.firstObject;  // 需要弹出的model
            
            for (NSInteger i = 0; i < activityArr.count; i++) {
                
                // 查出第一条未弹状态的的activity
                JAActivityFloatModel *activityModel = activityArr[i];
                if (activityModel.floatState == 0) {
                    
                    model = activityModel;
                    
                    // 修改这个model的弹出状态 - 并更新数据库
                    activityModel.floatState = 1;
                    [activityModel updateToDB];
                    
                    // 如果是最后一条 清空库里面的所有活动状态
                    if (i == activityArr.count - 1) {
                        
                        // 把库里面所有的弹出状态重置
                        [JAActivityFloatModel updateToDBWithSet:@"floatState='0'" where:@"floatState='1'"];
                    }
                    
                    break;
                }
            }
            
            // 回到主线程弹出
            dispatch_async(dispatch_get_main_queue(), ^{
                // 弹出model;
                if (model) {
//                    [JAHomeFloatActivityView showFloatActivity:model isClose:floatViewCloseBlock];
                }
            });
        });
    } failure:^(NSError *error) {
        
        // 启动签到弹窗
        [self getSignInfo:_isToday needSign:^(BOOL signState,NSDictionary *signInfo) {
            if (signState) {
                JAHomeSignView *signView = [[JAHomeSignView alloc] init];
//                signView.signInfoDic = signInfo;
//                signView.signHomeClose = ^{
//                    if (floatViewCloseBlock) {
//                        floatViewCloseBlock();
//                    }
//                };
                
                if ([self cyl_tabBarController].selectedIndex == 0) {
                    
                    [[UIApplication sharedApplication].delegate.window addSubview:signView];
                }
//                JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
//                [vc.view addSubview:signView];
                
                MMDrawerController *mmD = [AppDelegateModel rootviewController];
                [mmD setOpenDrawerGestureModeMask:MMOpenDrawerGestureModeNone];
            }
        }];
    }];
    
}


// 获取用户的签到状态
- (void)getSignInfo:(BOOL)isToday needSign:(void(^)(BOOL signState,NSDictionary *signInfo))needSignBlock
{
    
    // 是同一天&&已经签到
    if (_isToday && [JAConfigManager shareInstance].signState == 1) {
        if (needSignBlock) {
            needSignBlock(NO,nil);
        }
        return;
    }
    
    // 请求接口获取签到信息
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAUserApiRequest shareInstance] userSignInfo:dic success:^(NSDictionary *result) {
        
        [JAConfigManager shareInstance].signState = [result[@"hashmap"][@"user"][@"isSign"] integerValue];
        [[NSNotificationCenter defaultCenter] postNotificationName:NEED_SIGN object:nil];  // 这个通知是为了在左边栏的时候点击了签到
        if (isToday) {  // 是同一天
            if (needSignBlock) {
                needSignBlock(NO,result);
            }
            return;
        }
        
        if ([result[@"hashmap"][@"user"][@"isSign"] integerValue] == 0) {
            
            if (needSignBlock) {
                needSignBlock(YES,result);
            }
            
        }else{
            
            if (needSignBlock) {
                needSignBlock(NO,result);
            }
        }
        
        
    } failure:^(NSError *error) {
        
    }];
}

// 检查是否是今天
- (BOOL)checkIsToday
{
    NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    NSString *todaysignDateKey = [NSString stringWithFormat:@"%@%@",uid,@"todaysignDate"];
    NSString *storeStr = [[NSUserDefaults standardUserDefaults] objectForKey:todaysignDateKey]; // 获取存储的本地时间
    
    NSDate *senddate=[NSDate date];  // 获取今天时间
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *timeStr = [dateformatter stringFromDate:senddate];
    
    NSString *locationTodayString=[NSString stringWithFormat:@"%@-%@",uid,timeStr]; // 今天的标记
    
    if (![locationTodayString isEqualToString:storeStr]) {  // 不是同一天
     
        [[NSUserDefaults standardUserDefaults] setObject:locationTodayString forKey:todaysignDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
    
    return YES;
}

// 存储弹层的时间
- (NSTimeInterval)storeTimeMargin:(double)marginTime
{
    // 当前时间
    NSDate *senddate=[NSDate date];
    // 当前时间戳
    NSTimeInterval timeSecond = [senddate timeIntervalSince1970];
    
    // 获取存储的本地时间戳
    NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSString *key = [NSString stringWithFormat:@"%@_%@",uid,@"activityMaginTime"];
    NSString *dateString = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    double dateSecond = [dateString doubleValue];
    double frontSecond = dateSecond + marginTime;
    
    // 判断时间是不是超过时间间隔
    if (timeSecond >= frontSecond) {  // 超过了时间间隔
        return timeSecond;
    }
    
    return 0;
}

// 检查模型是否在数组中
- (JAActivityFloatModel *)checkContainObj:(JAActivityFloatModel *)model array:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++) {
        
        JAActivityFloatModel *m = array[i];
        if ([m.floatId isEqualToString:model.floatId]) {
            return m;
        }
    }
    return nil;
}
@end
