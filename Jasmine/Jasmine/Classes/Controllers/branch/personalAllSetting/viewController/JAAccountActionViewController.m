//
//  JAAccountActionViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAccountActionViewController.h"
#import "JAAccountActionCell.h"
#import "JABindPhoneViewController.h"

@interface JAAccountActionViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArray;

@end

@implementation JAAccountActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"账号管理"];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.frame = self.view.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[JAAccountActionCell class] forCellReuseIdentifier:@"JAAccountActionCellID"];
    [self.view addSubview:tableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingPlatformFinish) name:@"bindingPlatform" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindingPlatformFinish) name:@"unbindingPlatform" object:nil];
}

- (void)bindingPlatformFinish
{
    [self reloadTableData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadTableData];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"账号管理";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)reloadTableData
{
    // 获取是否绑定了手机 WX WB QQ
    BOOL phoneState = NO;
    BOOL wxState = NO;
    BOOL wbState = NO;
    BOOL qqState = NO;
    NSString *phoneString = [JAUserInfo userInfo_getUserImfoWithKey:User_Phone];
    NSString *wxString = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWXUid];
    NSString *wbString = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWBUid];
    NSString *qqString = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformQQUid];
    
    phoneState = phoneString.length ? YES : NO;
    wxState = wxString.length ? YES : NO;
    wbState = wbString.length ? YES : NO;
    qqState = qqString.length ? YES : NO;
    
    // 三方名称
    NSString *wxName = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWXName];
    NSString *wbName = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformWBName];
    NSString *qqName = [JAUserInfo userInfo_getUserImfoWithKey:User_PlatformQQName];
    if (!wxName.length) wxName = @"微信";
    if (!wbName.length) wbName = @"微博";
    if (!qqName.length) qqName = @"QQ";
    
    self.dataSourceArray = @[
                             @{@"image" : @"branch_account_phone",@"title" : @"手机",@"type" : @"phone", @"select" : @(phoneState),@"name" : @"手机"},
                             @{@"image" : @"branch_account_wx",@"title" : @"微信",@"type" : @"wx", @"select" : @(wxState),@"name" : wxName},
                             @{@"image" : @"branch_account_wb",@"title" : @"微博",@"type" : @"wb", @"select" : @(wbState),@"name" : wbName},
                             @{@"image" : @"branch_account_qq",@"title" : @"QQ",@"type" : @"qq", @"select" : @(qqState),@"name" : qqName},
                             ];
    
    [self.tableView reloadData];
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAAccountActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAAccountActionCellID"];
    cell.dictionary = self.dataSourceArray[indexPath.row];
    @WeakObj(self);
    cell.bindingPhoneBlock = ^{
        @StrongObj(self);
        JABindPhoneViewController *binePhoneV = [[JABindPhoneViewController alloc] init];
        [self.navigationController pushViewController:binePhoneV animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
