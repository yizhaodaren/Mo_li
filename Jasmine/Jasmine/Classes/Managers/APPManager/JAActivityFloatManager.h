//
//  JAActivityFloatManager.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/16.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JAActivityFloatManager : NSObject

/// 开启活动/签到弹窗
- (void)FloatActivity:(void(^)())floatViewCloseBlock;

@end
