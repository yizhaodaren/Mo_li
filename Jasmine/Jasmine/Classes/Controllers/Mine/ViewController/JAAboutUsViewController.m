//
//  JAAboutUsViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/14.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAboutUsViewController.h"
#import "JAAboutUsCell.h"
#import "JAWebViewController.h"

@interface JAAboutUsViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *versionLabel;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSString *appversion;
@end

static NSString *aboutUsCellId = @"aboutUsCellId";
@implementation JAAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appversion = [STSystemHelper getApp_version];
    
    NSString *qqString = [JAConfigManager shareInstance].QQGroup.length ? [JAConfigManager shareInstance].QQGroup : @" ";
    
    self.dataSourceArray = @[
                             
//                             @{@"title" : @"关于我们", @"subTitle" : @"https://www.urmoli.com/webHtml/molicommunity/welcome.html"},
                             @{@"title" : @"用户协议", @"subTitle" : @"http://www.urmoli.com/newmoli/views/app/about/userAgreement.html"},
                             @{@"title" : @"茉莉官网", @"subTitle" : @"www.urmoli.com"},
                             @{@"title" : @"新浪微博", @"subTitle" : @"@茉莉"},
                             @{@"title" : @"微信公众号", @"subTitle" : @"茉莉(ID:urmoli)"},
                             @{@"title" : @"官方QQ福利群", @"subTitle" : qqString},
                             
                             ];
    
    [self setCenterTitle:@"关于茉莉"];
    
    [self setupAboutUsUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"关于茉莉";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)setupAboutUsUI
{
    UIView *headView = [[UIView alloc] init];
    _headerView = headView;
    headView.backgroundColor = HEX_COLOR(0xffffff);
    headView.width = JA_SCREEN_WIDTH;
    headView.height = 200;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"three_icon"]];
    iconImageView.width = 83;
    iconImageView.height = 83;
    iconImageView.layer.cornerRadius = 15;
    iconImageView.layer.borderWidth = 1;
    iconImageView.layer.borderColor = HEX_COLOR(JA_Line).CGColor;
    iconImageView.layer.masksToBounds = YES;
    _iconImageView = iconImageView;
    iconImageView.y = 40;
    iconImageView.centerX = headView.width * 0.5;
    [headView addSubview:iconImageView];
    
    UILabel *versionLabel = [[UILabel alloc] init];
    _versionLabel = versionLabel;
    versionLabel.text = [NSString stringWithFormat:@"v%@",self.appversion];
    versionLabel.textColor = HEX_COLOR(JA_ListTitle);
    versionLabel.font = JA_REGULAR_FONT(14);
    [versionLabel sizeToFit];
    versionLabel.centerX = iconImageView.centerX;
    versionLabel.y = iconImageView.bottom + 10;
    [headView addSubview:versionLabel];
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.frame = self.view.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:[JAAboutUsCell class] forCellReuseIdentifier:aboutUsCellId];
    tableView.tableHeaderView = headView;
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor whiteColor];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAAboutUsCell *cell = [tableView dequeueReusableCellWithIdentifier:aboutUsCellId];
    cell.aboutUsDic = self.dataSourceArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        vc.urlString = self.dataSourceArray[indexPath.row][@"subTitle"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *line = [UIView new];
    line.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    return line;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

@end
