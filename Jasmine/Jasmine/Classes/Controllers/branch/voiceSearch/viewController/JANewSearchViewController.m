//
//  JANewSearchViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JANewSearchViewController.h"
#import "JASearchTopView.h"
#import "JASearchHistoryCell.h"
#import "JANewSearchResultViewController.h"

@interface JANewSearchViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) JASearchTopView *topView;
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *historyArr;
@property (nonatomic, strong) NSMutableArray *historyRecord;

@property (nonatomic, assign) BOOL isHistory;  // 是否点击了历史记录（神策数据）

@end

@implementation JANewSearchViewController

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _historyRecord = [NSMutableArray array];
    
    self.topView = [JASearchTopView searchTopView];
    if (iPhoneX) {
        self.topView.y = 24;
    }
    self.topView.backgroundColor = HEX_COLOR(JA_Background);
    [self.view addSubview:self.topView];
    self.topView.searchTextField.delegate = self;
    [self.topView.searchCancleButton addTarget:self action:@selector(cancleButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.topView.searchTextField addTarget:self action:@selector(inputBeginEdit:) forControlEvents:UIControlEventEditingDidBegin];
    
    CGFloat safeHeight = 64;
    if (iPhoneX) {
        safeHeight = 64 + 24;
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, safeHeight, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT - safeHeight) style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor whiteColor];
    
    [tableView registerNib:[UINib nibWithNibName:@"JASearchHistoryCell" bundle:nil] forCellReuseIdentifier:@"search"];
    
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;// ios8BUG:必须在addsubview之前，或者在registerNib之后
    
    [self.view addSubview:tableView];
    
    // 获取搜索数据
    [self getSearchHistoryData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.historyRecord.count) {
        [self.tableView reloadData];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.topView.searchTextField becomeFirstResponder];
}

#pragma mark - textView
- (void)inputBeginEdit:(UITextField *)textF
{
    // 神策数据
    [JASensorsAnalyticsManager sensorsAnalytics_clickSearch:nil];
}

// 取消按钮
- (void)cancleButtonClick
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 文本输入的代理 return键
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    textField.text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (!textField.text.length) {
        
        return NO;
    }
    
    // 保存10条搜索历史
    if (textField.text.length) {
        
        if ([self.historyRecord containsObject:textField.text]) {
            [self.historyRecord removeObject:textField.text];
        }
        
        [self.historyRecord insertObject:textField.text atIndex:0];
        if (self.historyRecord.count > 10) {
            [self.historyRecord removeLastObject];
        }
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        [userDefaults setObject:self.historyRecord forKey:@"searchHistory"];
    }

    if (self.isHistory != YES) {
        
        self.isHistory = NO;
    }
    [self.view endEditing:YES];
    
    JANewSearchResultViewController *vc = [[JANewSearchResultViewController alloc] init];
    vc.keyWord = textField.text;
    vc.clickHistory = self.isHistory;
    vc.selectIndex = self.pushIndex;
    [self.navigationController pushViewController:vc animated:NO];
    
    return YES;
}


- (void)deleteButtonClick:(UIButton *)btn
{
    [self.historyRecord removeObjectAtIndex:(btn.tag)];
    [self.tableView reloadData];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:self.historyRecord forKey:@"searchHistory"];
    
}


#pragma mark - tabelview
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.historyRecord.count == 0 ? 1 : self.historyRecord.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JASearchHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"search"];
    
    if (self.historyRecord.count) {
        
        cell.hidden = NO;
        cell.model = self.historyRecord[indexPath.row];
        
        [cell.deleteLabel addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        cell.deleteLabel.tag = indexPath.row;
        
    }else{
        
        cell.hidden = YES;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] init];
    v.height = 40;
    v.width = JA_SCREEN_WIDTH;
    v.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"历史记录";
    label.textColor = HEX_COLOR(JA_BlackSubTitle);
    label.font = JA_MEDIUM_FONT(13);
    [label sizeToFit];
    label.x = 23;
    label.centerY = v.height * 0.5;
    [v addSubview:label];
    
    UIView *line = [[UIView alloc] init];
    line.backgroundColor = HEX_COLOR(JA_Line);
    line.width = JA_SCREEN_WIDTH;
    line.height = 1;
    line.y = 39;
    [v addSubview:line];
    return v;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.topView.searchTextField.text = self.historyRecord[indexPath.row];
    self.isHistory = YES;
    [self textFieldShouldReturn:self.topView.searchTextField];
}


#pragma mark - s搜索结果
- (void)getSearchHistoryData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSUserDefaults *userDefaultes = [NSUserDefaults standardUserDefaults];
        
        self.historyArr = [userDefaultes arrayForKey:@"searchHistory"];
        [self.historyRecord removeAllObjects];
        [self.historyRecord addObjectsFromArray:self.historyArr];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });

    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}
@end
