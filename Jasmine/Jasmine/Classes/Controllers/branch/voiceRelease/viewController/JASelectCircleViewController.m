//
//  JASelectCircleViewController.m
//  Jasmine
//
//  Created by xujin on 2018/5/29.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JASelectCircleViewController.h"
#import "JACircleNetRequest.h"
#import "JASelectCircleTableViewCell.h"

@interface JASelectCircleViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
@property(nonatomic,strong)NSIndexPath* selectedIndexPath;//选中的cell
@end

@implementation JASelectCircleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCenterTitle:@"选择发布到哪个圈子"];
    //设置初始选中的值
//    self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //发布item
//    [self setNavRightTitle:@"发布" color:HEX_COLOR(JA_Green)];
    [self setRightButtonEnable:NO];
    _dataSourceArray = [NSMutableArray array];
    [self setupUI];
}

- (void)setRightButtonEnable:(BOOL)enable {
    if (enable) {
        [self setNavRightTitle:@"发布" color:HEX_COLOR(JA_Green)];
    } else {
        [self setNavRightTitle:@"发布" color:HEX_COLOR(0xe2e2e2)];
    }
}

- (void)setupUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[JASelectCircleTableViewCell class] forCellReuseIdentifier:@"JASelectCircleTableViewCell"];
    [self.view addSubview:tableView];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, JA_TabbarSafeBottomMargin, 0);
    [self request_getFocusAndAllCircle];
}
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorStoryAlbumViewControllerFrame];
}

- (void)calculatorStoryAlbumViewControllerFrame
{
    self.tableView.frame = self.view.bounds;
}

#pragma mark - 网络请求
- (void)request_getFocusAndAllCircle
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(1);
    dic[@"pageSize"] = @(100);  // 请求全部的圈子 - 用来做 展开 折叠
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_focusCircleListWithParameter:dic];
    
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
    dic1[@"pageNum"] = @(1);
    dic1[@"pageSize"] = @(100);
    JACircleNetRequest *r1 = [[JACircleNetRequest alloc] initRequest_allCircleListWithParameter:dic1];
    
    JACircleNetRequest *r2 = [[JACircleNetRequest alloc] initRequest_circleInfoWithParameter:nil circleId:@"99"];

    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[r,r1,r2]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        [self.currentProgressHUD hideAnimated:NO];
        
        NSArray *requests = batchRequest.requestArray;
        JACircleNetRequest *a = (JACircleNetRequest *)requests[0];
        JACircleNetRequest *b = (JACircleNetRequest *)requests[1];
        JACircleNetRequest *c = (JACircleNetRequest *)requests[2];

        // 解析数据
        [self removeBlankPage];
        
        if ([c.responseObject[@"code"] integerValue] == 10000) {
            JACircleModel *model = [JACircleModel mj_objectWithKeyValues:c.responseObject[@"resBody"]];
            NSArray *defaultArray = [NSArray arrayWithObject:model];
            [self.dataSourceArray addObject:@{@"headerTitle":@"找不到合适的圈子？就发这里吧！",@"circles":defaultArray}];
        }
        
        if ([a.responseObject[@"code"] integerValue] == 10000) {
            NSArray *focusCircleArray = [JACircleModel mj_objectArrayWithKeyValuesArray:a.responseObject[@"resBody"]];
            if (focusCircleArray.count) {
                [self.dataSourceArray addObject:@{@"headerTitle":@"关注的圈子",@"circles":focusCircleArray}];
            }
        }
        if ([b.responseObject[@"code"] integerValue] == 10000) {
            NSArray *allCircleArray = [JACircleModel mj_objectArrayWithKeyValuesArray:b.responseObject[@"resBody"]];
            if (allCircleArray.count) {
                [self.dataSourceArray addObject:@{@"headerTitle":@"推荐的圈子",@"circles":allCircleArray}];
            }
        }
        [self.tableView reloadData];
    } failure:^(YTKBatchRequest *batchRequest) {
        [self.currentProgressHUD hideAnimated:NO];
        [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(request_getFocusAndAllCircle) buttonShow:YES];
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSourceArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = self.dataSourceArray[section];
    NSArray *rows = dic[@"circles"];
    return rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.dataSourceArray[indexPath.section];
    NSArray *rows = dic[@"circles"];
    JACircleModel *model = rows[indexPath.row];
    JASelectCircleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JASelectCircleTableViewCell"];
    cell.data = model;
    if (indexPath.row == rows.count-1) {
        [cell hiddenLineView:YES];
    } else {
        [cell hiddenLineView:NO];
    }
    
    if ([indexPath isEqual:self.selectedIndexPath]) {
        cell.selectBtn.selected = YES;
    }else{
        cell.selectBtn.selected = NO;
    }
    cell.selectBtn.userInteractionEnabled = NO;//不处理btn的事件 处理cell的事件
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40)];
    headerView.backgroundColor = HEX_COLOR(0xF9F9F9);

    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 1)];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [headerView addSubview:lineView];
    
    NSDictionary *dic = self.dataSourceArray[section];
    NSString *headerTitle = dic[@"headerTitle"];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, JA_SCREEN_WIDTH-30, 40)];
    titleLabel.font = JA_MEDIUM_FONT(16);
    titleLabel.textColor = HEX_COLOR(JA_Title);
    titleLabel.text = headerTitle;
    [headerView addSubview:titleLabel];
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 40, JA_SCREEN_WIDTH, 1)];
    lineView1.backgroundColor = HEX_COLOR(JA_Line);
    [headerView addSubview:lineView1];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setRightButtonEnable:YES];
    self.selectedIndexPath = indexPath;
    [self.tableView reloadData];
//    [self.navigationController popViewControllerAnimated:YES];
}
- (void)setNavRightTitle:(NSString *)navRightTitle color:(UIColor *)color
{
    if (navRightTitle.length == 0) {
        self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 60, 30);
        btn.tag = 4536;
        //        btn.backgroundColor = [UIColor redColor];
        [btn setTitle:navRightTitle forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateNormal];
        btn.titleLabel.font = JA_REGULAR_FONT(15);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -5);
        //    [btn setTitleEdgeInsets:UIEdgeInsetsMake(btn.titleEdgeInsets.top, btn.titleEdgeInsets.left, btn.titleEdgeInsets.bottom, -40)];
        CGSize textSize = [[btn titleForState:UIControlStateNormal] sizeWithAttributes:@{NSFontAttributeName : btn.titleLabel.font}];
        [btn setFrame:CGRectMake(0, 0, textSize.width, textSize.height)];
        [btn addTarget:self
                action:@selector(actionRight)
      forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithCustomView:btn];
    }
}
-(void)actionRight{
    
    if (self.selectedIndexPath == nil) {
        return;
    }
    //更新选择的圈子
    NSDictionary *dic = self.dataSourceArray[self.selectedIndexPath.section];
    NSArray *rows = dic[@"circles"];
    JACircleModel *model = rows[self.selectedIndexPath.row];
    if (self.selectedCircleBlock) {
        self.selectedCircleBlock(model);
    }
    //发布
    if (self.postBlock) {
        self.postBlock();
    }
    [self.navigationController popViewControllerAnimated:NO];
}

@end

