//
//  JAInviteHeaderView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAInviteHeaderView : UIView
@property (nonatomic, strong) void(^randomInviteMan)();
@property (nonatomic, strong) void(^randomInviteWoman)();
@property (nonatomic, strong) void(^randomInvite)();
@end
