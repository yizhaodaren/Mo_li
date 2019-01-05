//
//  JAInviteRecommendViewController.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAInviteModel.h"

@interface JAInviteRecommendViewController : JABaseViewController

@property (nonatomic, strong) JAInviteModel *model;
@property (nonatomic, strong) JAVoiceModel *inviteModel; // 神策数据

- (void)requestFirstPageData;

@end
