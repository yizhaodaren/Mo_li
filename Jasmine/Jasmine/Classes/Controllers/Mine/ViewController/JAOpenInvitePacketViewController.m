//
//  JAOpenInvitePacketViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAOpenInvitePacketViewController.h"
#import "JAInvitePacketView.h"
#import "JABindPhoneViewController.h"

@interface JAOpenInvitePacketViewController ()

@end

@implementation JAOpenInvitePacketViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"输入邀请码"];
    self.view.backgroundColor = HEX_COLOR(0xF9F9F9);
    
    JAInvitePacketView *packetView = [[JAInvitePacketView alloc] init];
    
    @WeakObj(self);
    packetView.popFrontVc = ^{
      
        @StrongObj(self);
        [self.navigationController popViewControllerAnimated:YES];
    };
    packetView.clickOpenPack = ^{
        @StrongObj(self);
        JABindPhoneViewController *binding = [[JABindPhoneViewController alloc] init];
        binding.isInviteBinding = YES;
        [self.navigationController pushViewController:binding animated:YES];
        
    };
    [self.view addSubview:packetView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"输入邀请码";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

@end
