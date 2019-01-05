//
//  JAPersonalPagViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalPagViewController.h"
#import "JAEditInfoViewController.h"
#import "JAUserInfoModel.h"

#import "JAPersonalNavBarView.h"
#import "JAPersonalTopImageView.h"
#import "JAPersonalHeaderView.h"

#define kScale [self getScale]

@interface JAPersonalPagViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) JAPersonalNavBarView *navBarView; // 导航条
@property (nonatomic, weak) JAPersonalTopImageView *topImageView; // 顶部图片
@property (nonatomic, weak) UITableView *tableView; // tableView
@property (nonatomic, weak) JAPersonalHeaderView *headView; // 头部view

@property (nonatomic, strong) JAUserInfoModel *userInfoModel;
@end

@implementation JAPersonalPagViewController

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setup];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTableHeaderView:) name:@"refreshHead" object:nil];
}

- (void)refreshTableHeaderView:(NSNotification *)noti
{
    NSDictionary *dic = noti.userInfo;
    self.headView.height = [dic[@"height"] floatValue];
    self.tableView.tableHeaderView = self.headView;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)setup
{
    // 顶部图片
    JAPersonalTopImageView *topImageView = [[JAPersonalTopImageView alloc] init];
    _topImageView = topImageView;
    topImageView.width = JA_SCREEN_WIDTH;
    topImageView.height = 250 * kScale;
    [self.view addSubview:topImageView];
    
    // uitableview
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    _tableView.frame = self.view.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.contentInset = UIEdgeInsetsMake(topImageView.height - 37.5, 0, 0, 0);
    
    // 个人主页的导航条
    JAPersonalNavBarView *navBarView = [[JAPersonalNavBarView alloc] init];
    _navBarView = navBarView;
    navBarView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:navBarView];
    [navBarView.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [navBarView.rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 头部试图
    JAPersonalHeaderView *headView = [[JAPersonalHeaderView alloc] init];
    _headView = headView;
    headView.userId = @"7024";
    tableView.tableHeaderView = headView;
    
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
//    self.tableView.tableHeaderView = self.headView;
}

#pragma mark - tableDatasource delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"id"];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}


#pragma mark - 左右按钮
- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightClick
{
    if ([self discriminateIdnetity]) {
        
        // 点击的编辑
        JAEditInfoViewController *vc = [[JAEditInfoViewController alloc] init];
        vc.model = self.userInfoModel;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            // 举报个人
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = @"user";
            dic[@"reportTypeId"] = self.userUid;
            [[JAPersonalApi shareInstance] personal_reportUserWithPara:dic success:^(NSDictionary *result) {
                
                [MBProgressHUD showMessageAMoment:@"举报成功"];
                
            } failure:^{
                
            }];
        }];
        
        //        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"加入黑名单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //
        //            [MBProgressHUD showMessageAMoment:@"加入黑名单成功"];
        //        }];
        
        UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        
        [alert addAction:action1];
        //        [alert addAction:action2];
        [alert addAction:action3];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - 判断是否是自己
- (BOOL)discriminateIdnetity
{
    // 获取本地id
    NSString *localID = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 获取请求的id
    //    NSString *newID = self.userInfoModel.ID;
    
    if ([localID isEqualToString:self.userUid]) {
        
        return YES;
    }else{
        
        return NO;
    }
}

- (CGFloat)getScale
{
    if ([UIScreen mainScreen].bounds.size.width == 375) {
        
        return 1;
    }else if ([UIScreen mainScreen].bounds.size.width == 414){
        return 414/375.0;
    }else{
        return 320 / 375.0;
    }
}
@end
