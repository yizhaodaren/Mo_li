//
//  JABaseViewController+QiYuSDK.h
//  Jasmine
//
//  Created by xujin on 30/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"

@interface JABaseViewController (QiYuSDK)

- (void)setupQiYuViewController;
/// 获取客服聊天未读数量
- (void)getKeFuMessage:(void(^)(NSString *lastMsg,NSInteger count))finish;

@end
