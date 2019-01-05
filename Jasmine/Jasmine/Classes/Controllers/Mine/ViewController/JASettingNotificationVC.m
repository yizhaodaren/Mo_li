//
//  JASettingNotificationVC.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/26.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASettingNotificationVC.h"

@interface JASettingNotificationVC ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation JASettingNotificationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCenterTitle:@"新消息通知"];
    [(JABaseNavigationController *)self.navigationController setNavigationBarLineHidden:NO];
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"circle_info_black"] highlightImage:[UIImage imageNamed:@"circle_back_black"]];
    [self setNavigationBarColor:[UIColor whiteColor]];
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellId = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    UISwitch *switchBtn;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        switchBtn = [[UISwitch alloc] initWithFrame:CGRectMake(JA_SCREEN_WIDTH-71, 14.5, 51, 31)];
        [cell.contentView addSubview:switchBtn];
        cell.textLabel.textColor = HEX_COLOR(0x444444);
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"@/评论我";
            switchBtn.on = YES;
            break;
        case 1:
            cell.textLabel.text = @"有人给我送花";
            switchBtn.on = NO;
            break;
        case 2:
            cell.textLabel.text = @"赞同我的回答";
            switchBtn.on = YES;
            break;
        case 3:
            cell.textLabel.text = @"有人关注了我";
            switchBtn.on = YES;
            break;
        case 4:
            cell.textLabel.text = @"邀请我回答问题";
            switchBtn.on = YES;
            break;
        case 5:
            cell.textLabel.text = @"关注的问题有了新回答";
            switchBtn.on = YES;
            break;

        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *bg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 5)];
    bg.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    return bg;
}@end
