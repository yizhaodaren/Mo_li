//
//  JAStoryCircleViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAStoryCircleViewController.h"
#import "JAFocusCircleCollectionViewCell.h"
#import "JAAllCircleCollectionViewCell.h"
#import "JACircleHeadCollectionReusableView.h"

#import "JACircleNetRequest.h"

#import "JACircleDetailViewController.h"

#define kRequestCount 20
#define kPageCount 20

@interface JAStoryCircleViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) NSMutableArray *focusCircleArray;   // 全部的关注
@property (nonatomic, strong) NSMutableArray *allCircleArray;     // 全部（推荐）圈子

// 展开更多
@property (nonatomic, strong) JACircleModel *moreCircleModel;  // showAll 1 展开  2 收起

// 当前请求的数据页码
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSString *circleNewCountFile;  // 关注圈子的新帖数的文件路径
@property (nonatomic, strong) NSDictionary *circleNewCountDic;  // 关注圈子的新帖数的字典
@end

@implementation JAStoryCircleViewController

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    _focusCircleArray = [NSMutableArray array];
    _allCircleArray = [NSMutableArray array];

    self.moreCircleModel = [JACircleModel new];
    self.moreCircleModel.showAll = 1;
    
    [self setCenterTitle:@"圈子"];
    [self setupStoryCircleViewController];
    
    // 刷新（推荐）全部 圈子 、 关注圈子数据
    @WeakObj(self);
    self.collectionView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        if (IS_LOGIN) {
            // 请求圈子数据
            [self request_getFocusAndAllCircle];
        }else{
            [self request_getAllCircleWithMore:NO];
        }
    }];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getAllCircleWithMore:YES];
    }];
    self.collectionView.mj_footer.hidden = YES;
    
    [self.collectionView.mj_header beginRefreshing];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessRefreshData) name:LOGINSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutResetData) name:@"app_loginOut" object:nil];
}

#pragma mark - 通知的监听
- (void)loginSuccessRefreshData
{
    [self request_getFocusAndAllCircle];
}

- (void)loginOutResetData
{
    [self.dataSourceArray removeObject:self.focusCircleArray];
    [self.collectionView reloadData];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 网络请求
// 获取关注圈子和全部圈子数据
- (void)request_getFocusAndAllCircle
{
    self.currentPage = 1;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(100);  // 请求全部的关注圈子 - 用来做 展开 折叠
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_focusCircleListWithParameter:dic];
    
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
    dic1[@"pageNum"] = @(self.currentPage);
    dic1[@"pageSize"] = @(kRequestCount);
    JACircleNetRequest *r1 = [[JACircleNetRequest alloc] initRequest_allCircleListWithParameter:dic1];
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[r,r1]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest *batchRequest) {
        [self.collectionView.mj_footer endRefreshing];
        [self.collectionView.mj_header endRefreshing];
        NSArray *requests = batchRequest.requestArray;
        JACircleNetRequest *a = (JACircleNetRequest *)requests[0];
        JACircleNetRequest *b = (JACircleNetRequest *)requests[1];
        
        NSLog(@"%@ - %@",a,a.responseObject);
        NSLog(@"%@ - %@",b,b.responseObject);
        
        if ([a.responseObject[@"code"] integerValue] != 10000 && [b.responseObject[@"code"] integerValue] != 10000 ) {
            [self.view ja_makeToast:a.responseObject[@"message"]];
            [self.view ja_makeToast:b.responseObject[@"message"]];
             [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRequestCircle) buttonShow:YES];
            return;
        }
        
        // 解析数据
        [self removeBlankPage];
        
        [self.dataSourceArray removeAllObjects];
        
        // 解析关注圈子
        _focusCircleArray = [JACircleModel mj_objectArrayWithKeyValuesArray:a.responseObject[@"resBody"]];
        if (_focusCircleArray.count > 0) {
            if (self.focusCircleArray.count > kPageCount) {
                [self.focusCircleArray insertObject:self.moreCircleModel atIndex:kPageCount];
            }
            [self.dataSourceArray addObject:self.focusCircleArray];
        }
        
        _allCircleArray = [JACircleModel mj_objectArrayWithKeyValuesArray:b.responseObject[@"resBody"]];
        if (_allCircleArray.count > 0) {
            [self.dataSourceArray addObject:self.allCircleArray];
        }
        
        if (self.allCircleArray.count >= [b.responseObject[@"total"] integerValue] || self.allCircleArray.count < kRequestCount) {
            self.collectionView.mj_footer.hidden = YES;
        }else{
            self.collectionView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }

        [self.collectionView reloadData];
        
    } failure:^(YTKBatchRequest *batchRequest) {
        [self.collectionView.mj_footer endRefreshing];
        [self.collectionView.mj_header endRefreshing];
        [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRequestCircle) buttonShow:YES];
    }];
}

- (void)againRequestCircle
{
//    [self request_getFocusAndAllCircle];
    [self removeBlankPage];
    [self.collectionView.mj_header beginRefreshing];
}

// 获取全部(推荐)圈子数据
- (void)request_getAllCircleWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.collectionView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(kRequestCount);
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_allCircleListWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [self.collectionView.mj_footer endRefreshing];
        [self.collectionView.mj_header endRefreshing];
        
        // 解析数据
        JACircleGroupModel *groupM = (JACircleGroupModel *)responseModel;
        
        if (groupM.code != 10000) {
            
            return;
        }
        
        if (!isMore) {
            [self.allCircleArray removeAllObjects];
        }
        
        [self.allCircleArray addObjectsFromArray:groupM.resBody];
        
        if (![self.dataSourceArray containsObject:self.allCircleArray]) {
            [self.dataSourceArray addObject:self.allCircleArray];
        }
        
        if (self.allCircleArray.count >= groupM.total || groupM.resBody.count < kRequestCount) {
            self.collectionView.mj_footer.hidden = YES;
        }else{
            self.collectionView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.collectionView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [self.collectionView.mj_footer endRefreshing];
        [self.collectionView.mj_header endRefreshing];
        
    }];
}

#pragma mark - delegate
//分区，组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSourceArray.count;
}

//每一分区的单元个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{

    NSArray *arr = self.dataSourceArray[section];
    if (arr == self.focusCircleArray) {
        
        if ([self.focusCircleArray containsObject:self.moreCircleModel]) {
            if (self.moreCircleModel.showAll == 1) {
                if ([self.focusCircleArray containsObject:self.moreCircleModel]) {
                    [self.focusCircleArray removeObject:self.moreCircleModel];
                    [self.focusCircleArray insertObject:self.moreCircleModel atIndex:kPageCount];
                }
                return kPageCount + 1;
            }else{
                if ([self.focusCircleArray containsObject:self.moreCircleModel]) {
                    [self.focusCircleArray removeObject:self.moreCircleModel];
                    [self.focusCircleArray insertObject:self.moreCircleModel atIndex:self.focusCircleArray.count];
                }
                return arr.count;
            }
        }else{
            return arr.count;
        }
        
    }else{
        return arr.count;
    }
    
}

//集合视图单元格大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *modelArray = self.dataSourceArray[indexPath.section];
    if (modelArray == self.focusCircleArray) {
        
        // 计算大小
        CGFloat sizeW = (JA_SCREEN_WIDTH - 2 * 15 - 9) / 2;
        CGFloat sizeH = 60;
        return CGSizeMake(sizeW, sizeH);
    }else{
        
        // 计算大小
        CGFloat sizeW = JA_SCREEN_WIDTH - 2 * 15;
        CGFloat sizeH = 60;
        return CGSizeMake(sizeW, sizeH);
    }
    return CGSizeZero;
}

//头部大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    CGFloat sizeW = JA_SCREEN_WIDTH;
    CGFloat sizeH = 40;
    return CGSizeMake(sizeW, sizeH);
    
}

//单元格复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    NSArray *modelArray = self.dataSourceArray[indexPath.section];
    JACircleModel *model = modelArray[indexPath.row];
    if (modelArray == self.focusCircleArray) {
        [self circleCount_calculatorCountWithArray:self.focusCircleArray];
        JAFocusCircleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JAFocusCircleCollectionViewCell_id" forIndexPath:indexPath];
        cell.circleModel = model;
        return cell;
    }else{
        
        JAAllCircleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JAAllCircleCollectionViewCell_id" forIndexPath:indexPath];
        cell.circleModel = model;
        return cell;
    }
    
}


//集合视图头部或者尾部
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    NSArray *modelArray = self.dataSourceArray[indexPath.section];

    JACircleHeadCollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"JACircleHeadCollectionReusableView_id" forIndexPath:indexPath];
    view.name = modelArray == self.allCircleArray ? @"推荐圈子" : @"关注的圈子";
    return view;
}

//被选中的单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *modelArray = self.dataSourceArray[indexPath.section];
    
    JACircleModel *model = modelArray[indexPath.row];
    
    if (model == self.moreCircleModel) {

        [self.focusCircleArray removeObject:self.moreCircleModel];
        self.moreCircleModel.showAll = model.showAll == 1 ? 2 : 1;
        if (self.moreCircleModel.showAll == 1) {
            [self.focusCircleArray insertObject:self.moreCircleModel atIndex:kPageCount];
        }else{
            [self.focusCircleArray insertObject:self.moreCircleModel atIndex:self.focusCircleArray.count];
        }
        
        [self.collectionView reloadData];
    }else{
        
        if (modelArray == self.focusCircleArray) {
            model.storyNewCount = 0;
            // 刷新该行
            [self.collectionView reloadData];
            [self circleCount_saveNewCountWithModelArray:self.focusCircleArray];
        }
        
        JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
        vc.circleId = model.circleId;
        @WeakObj(self);
        vc.focusAndCancleCircleBlock = ^(BOOL isFocus) {
            @StrongObj(self);
            [self request_getFocusAndAllCircle];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - UI
- (void)setupStoryCircleViewController
{
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 10;
    self.flowLayout.minimumInteritemSpacing = 9;
    self.flowLayout.sectionInset = UIEdgeInsetsMake(15, 15, 15, 15);
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT - JA_StatusBarAndNavigationBarHeight - JA_TabbarHeight) collectionViewLayout:self.flowLayout];
    _collectionView = collectionView;
    collectionView.backgroundColor = [UIColor whiteColor];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[JAFocusCircleCollectionViewCell class] forCellWithReuseIdentifier:@"JAFocusCircleCollectionViewCell_id"];
    [collectionView registerClass:[JAAllCircleCollectionViewCell class] forCellWithReuseIdentifier:@"JAAllCircleCollectionViewCell_id"];
    [collectionView registerClass:[JACircleHeadCollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"JACircleHeadCollectionReusableView_id"];
    [self.view addSubview:collectionView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorStoryCircleViewControllerFrame];
}

- (void)calculatorStoryCircleViewControllerFrame
{
    
}

#pragma mark - 懒加载
- (NSString *)circleNewCountFile
{
    NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSString *fileName = [NSString stringWithFormat:@"circleNewCount_%@.data",userId];
    _circleNewCountFile = [NSString ja_getLibraryCachPath:fileName];
    return _circleNewCountFile;
}

- (NSDictionary *)circleNewCountDic
{
    _circleNewCountDic = [NSDictionary dictionaryWithContentsOfFile:self.circleNewCountFile];
    
    return _circleNewCountDic;
}

#pragma mark - 文件存储
- (void)circleCount_saveNewCountWithModelArray:(NSArray *)modelArray
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [modelArray enumerateObjectsUsingBlock:^(JACircleModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *keyId_old = [NSString stringWithFormat:@"%@_old",obj.circleId];
        NSString *keyId_new = [NSString stringWithFormat:@"%@_new",obj.circleId];
        dic[keyId_old] = obj.storyCount;
        dic[keyId_new] = @(obj.storyNewCount == 0 ? 0 : obj.storyNewCount);
        
    }];
    
    [dic writeToFile:self.circleNewCountFile atomically:YES];
}

// 计算新帖数目
- (void)circleCount_calculatorCountWithArray:(NSArray *)modelArray
{
    [modelArray enumerateObjectsUsingBlock:^(JACircleModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *keyId_old = [NSString stringWithFormat:@"%@_old",obj.circleId];
        NSString *keyId_new = [NSString stringWithFormat:@"%@_new",obj.circleId];
        
        // 获取该贴存储的帖子数
        NSInteger storyCacheCount = [self.circleNewCountDic[keyId_old] integerValue];
        
        // 获取该贴存储的新帖子数
        NSInteger storyCacheNewCount = [self.circleNewCountDic[keyId_new] integerValue];
        
        // 现在的帖子总数
        NSInteger storyCount = obj.storyCount.integerValue;
        
        // 计算新增的帖子数
        NSInteger newCount = storyCount - storyCacheCount > 0 ? storyCount - storyCacheCount : 0;
        
        // 新帖总数
        obj.storyNewCount = newCount + storyCacheNewCount;
    }];
    
}
@end
