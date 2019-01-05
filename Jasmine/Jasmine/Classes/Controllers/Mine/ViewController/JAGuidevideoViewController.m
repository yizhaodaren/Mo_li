//
//  JAGuidevideoViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAGuidevideoViewController.h"
#import "JAWebViewController.h"
#import "JAHelperCell.h"
#import "JAVoicePersonApi.h"
#import "JAGuideHelpModel.h"
@interface JAGuidevideoViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArray;
@end

static NSString *helperVideoCellId = @"helperVideoCellId";
@implementation JAGuidevideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = [NSMutableArray array];
    [self getGuidevideoData];
    [self setupGuidevideoUI];
    
}

- (void)setupGuidevideoUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JAHelperCell class] forCellReuseIdentifier:helperVideoCellId];
    tableView.backgroundColor = HEX_COLOR(0xffffff);
    [self.view addSubview:tableView];
}

- (void)getGuidevideoData
{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"type"] = @"1";
//    dic[@"platform"] = @"IOS";
//
//    [[JAVoicePersonApi shareInstance] voice_helperWithPara:dic success:^(NSDictionary *result) {
//
//        self.dataSourceArray = result[@"arraylist"];
//
//        // 展示空界面
//        [self showBlankPage];
//
//        [self.tableView reloadData];
//    } failure:^(NSError *error) {
//
//    }];
    self.dataSourceArray = [JAConfigManager shareInstance].guideVideoArray;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAHelperCell *cell = [tableView dequeueReusableCellWithIdentifier:helperVideoCellId];
    JAGuideHelpModel *model = self.dataSourceArray[indexPath.row];
    cell.helpModel = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAGuideHelpModel *model = self.dataSourceArray[indexPath.row];
    NSString *url = model.url;
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_VideoTitle] = model.problem;
    [JASensorsAnalyticsManager sensorsAnalytics_seevideoHelp:senDic];
    
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        vc.urlString = url;
        vc.titleString = @"视频教程";
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        
        //        JACompositionParticularsViewController *vc = [[JACompositionParticularsViewController alloc] init];
        //        vc.compositionId = dic[@"url"];
        //        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [UIView new];
    sectionView.backgroundColor = HEX_COLOR(0xffffff);
    UILabel *label = [[UILabel alloc] init];
    label.text = @"视频解说";
    label.textColor = HEX_COLOR(0xF5A623);
    label.font = JA_MEDIUM_FONT(15);
    [label sizeToFit];
    label.x = 14;
    label.centerY = 25;
    [sectionView addSubview:label];
    
    UIView *lineView = [[UIView alloc] init];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    lineView.width = JA_SCREEN_WIDTH;
    lineView.height = 1;
    lineView.y = 50 - 1;
    [sectionView addSubview:lineView];
    
    return sectionView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"敬请期待";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
}
@end
