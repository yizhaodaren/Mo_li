//
//  JAActivityRedPacketView.h
//  Jasmine
//
//  Created by xujin on 2018/4/8.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACommandModel.h"

@interface JAActivityRedPacketView : UIView

@property (nonatomic, strong) void(^closeBlock)(void);

+ (void)showActivity:(JACommandModel *)data;

@end
