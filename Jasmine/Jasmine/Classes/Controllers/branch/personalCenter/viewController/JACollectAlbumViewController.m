//
//  JACollectAlbumViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACollectAlbumViewController.h"
#import "JAAlbumDetailViewController.h"

#import "JACollectAlbumCell.h"

#import "JAAlbumNetRequest.h"

@interface JACollectAlbumViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@property (nonatomic, strong) NSString *albumNewCountFile;  // 关注专辑的新帖数的文件路径
@property (nonatomic, strong) NSDictionary *albumNewCountDic;  // 关注专辑的新帖数的字典
@end

@implementation JACollectAlbumViewController

- (void)loadView{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    
    [self.tableView registerClass:[JACollectAlbumCell class] forCellReuseIdentifier:@"collectAlbumCell_id"];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getCollectAlbumListWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getCollectAlbumListWithMore:NO];
}

#pragma mark - 网络请求
- (void)request_getCollectAlbumListWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
        self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    JAAlbumNetRequest *r = [[JAAlbumNetRequest alloc] initRequest_collectAlbumListWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JAAlbumGroupModel *model = (JAAlbumGroupModel *)responseModel;
        if (model.code != 10000) {   // 请求失败
            if (!self.dataSourceArray.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithLocationY:0 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            }
            return;
        }
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        [self.dataSourceArray addObjectsFromArray:model.resBody];
        
        if (!isMore) {
            [self showBlankPage];  // 空数据
        }
        
        if (self.dataSourceArray.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (!self.dataSourceArray.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    JAAlbumModel *model = self.dataSourceArray[indexPath.row];
    
    model.storyNewCount = 0;
    [self.tableView reloadData];
    [self albumCount_saveNewCountWithModelArray:self.dataSourceArray];
    
    JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
    vc.subjectId = model.subjectId;
    @WeakObj(self);
    vc.cancleCollectBlock = ^{
        @StrongObj(self);
        [self.dataSourceArray removeObject:model];
        [self.tableView reloadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAAlbumModel *model = self.dataSourceArray[indexPath.row];
    [self albumCount_calculatorCountWithArray:self.dataSourceArray];
    JACollectAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"collectAlbumCell_id"];
    cell.collectModel = model;
    return cell;
}

// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"还没有收藏任何专辑";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_searchnoresult" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

#pragma mark - 懒加载
- (NSString *)albumNewCountFile
{
    NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSString *fileName = [NSString stringWithFormat:@"albumNewCount_%@.data",userId];
    _albumNewCountFile = [NSString ja_getLibraryCachPath:fileName];
    return _albumNewCountFile;
}

- (NSDictionary *)albumNewCountDic
{
    _albumNewCountDic = [NSDictionary dictionaryWithContentsOfFile:self.albumNewCountFile];
    
    return _albumNewCountDic;
}

#pragma mark - 文件存储
- (void)albumCount_saveNewCountWithModelArray:(NSArray *)modelArray
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [modelArray enumerateObjectsUsingBlock:^(JAAlbumModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *keyId_old = [NSString stringWithFormat:@"%@_old",obj.subjectId];
        NSString *keyId_new = [NSString stringWithFormat:@"%@_new",obj.subjectId];
        dic[keyId_old] = obj.storyCount;
        dic[keyId_new] = @(obj.storyNewCount == 0 ? 0 : obj.storyNewCount);
        
    }];
    
    [dic writeToFile:self.albumNewCountFile atomically:YES];
}

// 计算新帖数目
- (void)albumCount_calculatorCountWithArray:(NSArray *)modelArray
{
    [modelArray enumerateObjectsUsingBlock:^(JAAlbumModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *keyId_old = [NSString stringWithFormat:@"%@_old",obj.subjectId];
        NSString *keyId_new = [NSString stringWithFormat:@"%@_new",obj.subjectId];
        
        // 获取该贴存储的帖子数
        NSInteger storyCacheCount = [self.albumNewCountDic[keyId_old] integerValue];
        
        // 获取该贴存储的新帖子数
        NSInteger storyCacheNewCount = [self.albumNewCountDic[keyId_new] integerValue];
        
        // 现在的帖子总数
        NSInteger storyCount = obj.storyCount.integerValue;
        
        // 计算新增的帖子数
        NSInteger newCount = storyCount - storyCacheCount > 0 ? storyCount - storyCacheCount : 0;
        
        // 新帖总数
        obj.storyNewCount = newCount + storyCacheNewCount;
    }];
    
}
@end
