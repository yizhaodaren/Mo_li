//
//  JAGuidebookViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAGuidebookViewController.h"
#import "JAWebViewController.h"
#import "JAHelperCell.h"
#import "JAVoicePersonApi.h"
#import "JAGuideHelpModel.h"
@interface JAGuidebookViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataSourceArray;
@end

static NSString *helperCellId = @"helperCellId";

@implementation JAGuidebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _dataSourceArray = [NSMutableArray array];
    [self getGuidebookData];
    [self setupGuidebookUI];
    
}

- (void)setupGuidebookUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JAHelperCell class] forCellReuseIdentifier:helperCellId];
    tableView.backgroundColor = HEX_COLOR(0xffffff);
    [self.view addSubview:tableView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

- (void)getGuidebookData
{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"type"] = @"0";
//    dic[@"platform"] = @"IOS";
//
//    [[JAVoicePersonApi shareInstance] voice_helperWithPara:dic success:^(NSDictionary *result) {
//
//        NSString *filePath = [NSString ja_getPlistFilePath:@"/GuideBookHelpDefault.plist"];
//        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
//        dictionary[@"version"] = @(0);
//        [dictionary writeToFile:filePath atomically:YES];
//
//
//        self.dataSourceArray = result[@"arraylist"];
//        [self.tableView reloadData];
//    } failure:^(NSError *error) {
//
//    }];
    
    self.dataSourceArray = [JAConfigManager shareInstance].guideBookArray;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAHelperCell *cell = [tableView dequeueReusableCellWithIdentifier:helperCellId];
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
    senDic[JA_Property_QuestionTitle] = model.problem;
    [JASensorsAnalyticsManager sensorsAnalytics_seeQuestionHelp:senDic];
    
    if ([url hasPrefix:@"http://"] || [url hasPrefix:@"https://"]) {
        JAWebViewController *vc = [[JAWebViewController alloc] init];
        vc.urlString = url;
        vc.titleString = @"常见问题";
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
    label.text = @"新手问题";
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

@end
