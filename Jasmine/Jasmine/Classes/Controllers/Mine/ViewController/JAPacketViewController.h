//
//  JAPacketViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/19.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JAPacketViewController : JABaseViewController
@property (nonatomic, assign) NSInteger type;  // 0 邀请好友  1  我的好友
@property (nonatomic, assign) NSInteger callFriend;  // 1 去召唤好友
@end
