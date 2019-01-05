//
//  JAPacketInviteFriendViewController.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "SPPageMenu.h"
@interface JAPacketInviteFriendViewController : JABaseViewController
@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) SPPageMenu *titleView;

@property (nonatomic, strong) void(^callFriendBlock)();
@end
