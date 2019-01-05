//
//  JALaunchADManager.h
//  Jasmine
//
//  Created by xujin on 16/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JALaunchADManager : NSObject

@property (nonatomic, assign) NSInteger adState; // 0展示中1展示完毕

+ (instancetype)shareInstance;
// 无网打开app，网络连通后再次版本检测
- (void)checkNewVersion;
- (void)showServermaintain;
@end
