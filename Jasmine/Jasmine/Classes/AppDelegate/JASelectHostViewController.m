//
//  JASelectHostViewController.m
//  Jasmine
//
//  Created by xujin on 13/11/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASelectHostViewController.h"
#import "AppDelegate+NIMSDK.h"

@interface JASelectHostViewController ()

@end

@implementation JASelectHostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self selectHost];
}

- (void)selectHost {
    NSArray *hosts = @[
                       @"http://dev.api.yourmoli.com",
                       @"https://data.urmoli.com",
                       @"http://192.168.1.54:8088",
                       @"http://192.168.1.20:201",
                       @"http://192.168.1.30:8061",
                       ];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSString *hostStr in hosts) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:hostStr style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setValue:hostStr forKey:@"select_host"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [[AppDelegateModel shareInstance] setup];
            [JAConfigManager shareInstance].host = hostStr;

            [(AppDelegate *)[UIApplication sharedApplication].delegate setupNIMSDK];
        }];
        [alert addAction:action];
    }
    [self presentViewController:alert animated:YES completion:nil];
}

@end
