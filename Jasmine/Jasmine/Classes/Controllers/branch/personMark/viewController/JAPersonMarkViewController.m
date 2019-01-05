//
//  JAPersonMarkViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonMarkViewController.h"
#import "JAMarkNavigationView.h"
#import "JAScrollMarkView.h"
#import "JAMarkCollectionViewCell.h"
#import "JDFTooltips.h"

#import "JAPersonCenterNetRequest.h"

@interface JAPersonMarkViewController ()<JAScrollMarkViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, weak) JAMarkNavigationView *navigationView;  // 导航条

@property (nonatomic, weak) UIScrollView *backScrollView;  // 背景滚动

@property (nonatomic, weak) UIImageView *topImageView;
@property (nonatomic, weak) UIView *markImageBackView;  // 头衔图片
@property (nonatomic, weak) UIImageView *markImageView;  // 头衔图片
@property (nonatomic, weak) UILabel *markNameLabel;  // 头衔名字/ 未获得

@property (nonatomic, weak) UIImageView *greenImageView; // 绿色线
@property (nonatomic, weak) UILabel *markLabel;  // 社区头衔
@property (nonatomic, weak) UIButton *whatMarkButton;  // 头衔规则

@property (nonatomic, weak) JAScrollMarkView *scrollMarkView;  // 滚动头衔view

@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UICollectionView *collectionView;  // collectionView
@property (nonatomic, strong) NSMutableArray *markDatasourceArray;

@property (nonatomic, strong) NSString *questionRule; // 规则
@property(nonatomic,strong) JDFTooltipView *tipView;
@end

@implementation JAPersonMarkViewController

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _markDatasourceArray = [NSMutableArray array];
    [self setupPersonMarkViewControllerUI];
    [self request_getMark];
}

#pragma mark - 网络请求
- (void)request_getMark
{
    
    JAPersonCenterNetRequest *r = [[JAPersonCenterNetRequest alloc] initRequest_personMarkWithParameter:nil userId:self.userId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        JAMarkGroupModel *model = (JAMarkGroupModel *)responseModel;
        if (model.code != 10000) {
            [self.view ja_makeToast:model.message];
            return;
        }
        self.questionRule = model.rule;
        [self.markDatasourceArray addObjectsFromArray:model.crownList];
        [self.markDatasourceArray removeObjectAtIndex:0];
        self.scrollMarkView.markArray = self.markDatasourceArray;
        if (model.userCrown.crownStatus.integerValue == 1 && model.userCrown.markId.integerValue != 0) {
            self.markImageBackView.backgroundColor = HEX_COLOR(0xFFDF01);
        }else{
            self.markImageBackView.backgroundColor = HEX_COLOR(0xE2E2E2);
        }
        [self.markImageView ja_setImageWithURLStr:model.userCrown.lightImage];
        self.markNameLabel.text = model.userCrown.name;
        [self.collectionView reloadData];
        
        NSInteger index = -1;
        for (NSInteger i = 0; i < self.markDatasourceArray.count; i++) {
            JAMarkModel *m = self.markDatasourceArray[i];
            if (m.crownStatus.integerValue == 0) {
                index = i <= 0 ? 0 : (i);
                break;
            }
        }
        
        if (index == -1) {
            index = self.markDatasourceArray.count - 1;
        }
        
        // 滚动到该位置
        NSIndexPath *indexP = [NSIndexPath indexPathForItem:(index) inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
        [self.scrollMarkView scrollMarkWithIndex:index animate:NO];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

#pragma mark - 按钮点击
- (void)clickWhatMark:(UIButton *)button
{
    if (!self.tipView) {
        CGFloat tooltipWidth = 260.0f;//气泡宽度
        //创建气泡
        self.tipView = [[JDFTooltipView alloc] initWithTargetView:self.whatMarkButton hostView:self.view tooltipText:self.questionRule arrowDirection:JDFTooltipViewArrowDirectionUp width:tooltipWidth];
        //展示气泡
        [self.tipView show];
    }else{
        [self.tipView hideAnimated:YES];
        self.tipView = nil;
    }
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - scrollMarkView的代理
- (void)scrollMarkViewClickMarkWithIndex:(NSInteger)index scrollMarkView:(JAScrollMarkView *)markView
{
    NSIndexPath *indexP = [NSIndexPath indexPathForItem:(index - 1) inSection:0];
    [self.collectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

#pragma mark - collectionviewdelegate
//分区，组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每一分区的单元个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.markDatasourceArray.count;
}

//单元格复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JAMarkModel *model = self.markDatasourceArray[indexPath.row];
    
    JAMarkCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JAMarkCollectionViewCell_id" forIndexPath:indexPath];
    cell.model = model;
    return cell;
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    if (scrollView == self.backScrollView) {
        return;
    }
    NSInteger page = scrollView.contentOffset.x / (WIDTH_ADAPTER(334) - WIDTH_ADAPTER(23));
    [self.scrollMarkView scrollMarkWithIndex:page animate:YES];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.backScrollView) {
        return;
    }
    NSLog(@"%f",scrollView.contentOffset.x);
    NSInteger page = scrollView.contentOffset.x / (WIDTH_ADAPTER(334) - WIDTH_ADAPTER(23));
    [self.scrollMarkView scrollMarkWithIndex:page animate:YES];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == self.backScrollView) {
        return;
    }
    float pageWidth = WIDTH_ADAPTER(334) + 5; // width + space
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset)
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
    else
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
    
    if (newTargetOffset < 0)
        newTargetOffset = 0;
    else if (newTargetOffset > scrollView.contentSize.width)
        newTargetOffset = scrollView.contentSize.width;
    
    targetContentOffset->x = currentOffset;
    [scrollView setContentOffset:CGPointMake(newTargetOffset - WIDTH_ADAPTER(23), 0) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == self.backScrollView) {
        self.navigationView.offset = scrollView.contentOffset.y;
        if (scrollView.contentOffset.y <= 0) {
            self.topImageView.frame = CGRectMake(0, scrollView.contentOffset.y, JA_SCREEN_WIDTH, 200 - scrollView.contentOffset.y);
        }else{
            self.topImageView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, 200);
        }
        
        self.markNameLabel.y = self.topImageView.height - 20 - self.markNameLabel.height;
        self.markImageBackView.y = self.markNameLabel.y - 10 - self.markImageBackView.height;
        self.markImageView.y = self.markImageBackView.y + 2;
    }
    
    [self.tipView hideAnimated:NO];
    self.tipView = nil;
}

#pragma mark - UI
- (void)setupPersonMarkViewControllerUI
{
    UIScrollView *backScrollView = [[UIScrollView alloc] init];
    _backScrollView = backScrollView;
    backScrollView.contentSize = CGSizeMake(0, JA_SCREEN_HEIGHT + 10);
    backScrollView.showsHorizontalScrollIndicator = NO;
    backScrollView.showsVerticalScrollIndicator = NO;
    backScrollView.backgroundColor = HEX_COLOR(0xf4f4f4);
    backScrollView.delegate = self;
    if (@available(iOS 11.0, *)) {
        backScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self.view addSubview:backScrollView];
    
    JAMarkNavigationView *navigationView = [[JAMarkNavigationView alloc] init];
    _navigationView = navigationView;
    navigationView.titleName = @"我的社区头衔";
    [navigationView.leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:navigationView];
    
    UIImageView *topImageView = [[UIImageView alloc] init];
    _topImageView = topImageView;
    topImageView.image = [UIImage imageNamed:@"branch_mark_bg"];
    [backScrollView addSubview:topImageView];
    
    UIView *markImageBackView = [[UIView alloc] init];
    _markImageBackView = markImageBackView;
    markImageBackView.backgroundColor = HEX_COLOR(0xE2E2E2);
    [topImageView addSubview:markImageBackView];
    
    UIImageView *markImageView = [[UIImageView alloc] init];
    _markImageView = markImageView;
    markImageView.contentMode = UIViewContentModeScaleAspectFit;
    [topImageView addSubview:markImageView];
    
    UILabel *markNameLabel = [[UILabel alloc] init];
    _markNameLabel = markNameLabel;
    markNameLabel.text = @"未获得头衔";
    markNameLabel.textColor = HEX_COLOR(0xffffff);
    markNameLabel.font = JA_REGULAR_FONT(18);
    markNameLabel.textAlignment = NSTextAlignmentCenter;
    [topImageView addSubview:markNameLabel];
    
    UIImageView *greenImageView = [[UIImageView alloc] init];
    _greenImageView = greenImageView;
    greenImageView.backgroundColor = HEX_COLOR(0x6BD379);
    [backScrollView addSubview:greenImageView];
    
    UILabel *markLabel = [[UILabel alloc] init];
    _markLabel = markLabel;
    markLabel.text = @"社区头衔";
    markLabel.textColor = HEX_COLOR(0x363636);
    markLabel.font = JA_MEDIUM_FONT(14);
    [backScrollView addSubview:markLabel];
    
    UIButton *whatMarkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _whatMarkButton = whatMarkButton;
    [whatMarkButton setImage:[UIImage imageNamed:@"branch_medal_Question"] forState:UIControlStateNormal];
    [whatMarkButton addTarget:self action:@selector(clickWhatMark:) forControlEvents:UIControlEventTouchUpInside];
    [backScrollView addSubview:whatMarkButton];
    
    JAScrollMarkView *scrollMarkView = [[JAScrollMarkView alloc] init];
    _scrollMarkView = scrollMarkView;
    scrollMarkView.delegate = self;
    [backScrollView addSubview:scrollMarkView];
    
    // collectionView
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    _collectionView = collectionView;
    collectionView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[JAMarkCollectionViewCell class] forCellWithReuseIdentifier:@"JAMarkCollectionViewCell_id"];
    collectionView.contentInset = UIEdgeInsetsMake(0, WIDTH_ADAPTER(23), 0, WIDTH_ADAPTER(23));
    collectionView.showsHorizontalScrollIndicator = NO;
    [backScrollView addSubview:collectionView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorPersonMarkViewControllerFrame];
}

- (void)calculatorPersonMarkViewControllerFrame
{
    self.backScrollView.width = JA_SCREEN_WIDTH;
    self.backScrollView.height = JA_SCREEN_HEIGHT;
    
    self.topImageView.width = self.backScrollView.width;
    self.topImageView.height = 200;
    
    [self.markNameLabel sizeToFit];
    self.markNameLabel.centerX = self.topImageView.width * 0.5;
    self.markNameLabel.y = self.topImageView.height - 20 - self.markNameLabel.height;
    
    self.markImageBackView.width = 64;
    self.markImageBackView.height = 64;
    self.markImageBackView.centerX = self.markNameLabel.centerX;
    self.markImageBackView.y = self.markNameLabel.y - 10 - self.markImageBackView.height;
    self.markImageBackView.layer.cornerRadius = self.markImageBackView.height * 0.5;
    self.markImageBackView.layer.masksToBounds = YES;
    
    self.markImageView.width = 60;
    self.markImageView.height = 60;
    self.markImageView.centerX = self.markNameLabel.centerX;
    self.markImageView.y = self.markImageBackView.y + 2;
    self.markImageView.layer.cornerRadius = self.markImageView.height * 0.5;
    self.markImageView.layer.masksToBounds = YES;
    
    
    self.greenImageView.width = 3;
    self.greenImageView.height = 15;
    self.greenImageView.x = 15;
    self.greenImageView.y = self.topImageView.bottom + 18;
    
    [self.markLabel sizeToFit];
    self.markLabel.x = self.greenImageView.right + 5;
    self.markLabel.centerY = self.greenImageView.centerY;
    
    self.whatMarkButton.width = 30;
    self.whatMarkButton.height = 30;
    self.whatMarkButton.x = self.markLabel.right;
    self.whatMarkButton.centerY = self.greenImageView.centerY;
    
    self.scrollMarkView.width = self.backScrollView.width;
    self.scrollMarkView.height = 138;
    self.scrollMarkView.y = self.markLabel.bottom;
    
    self.collectionView.width = self.backScrollView.width;
    self.collectionView.height = WIDTH_ADAPTER(274);
    self.collectionView.y = self.scrollMarkView.bottom;
    
    self.flowLayout.itemSize = CGSizeMake(WIDTH_ADAPTER(334), self.collectionView.height);
//    self.backScrollView.contentSize = CGSizeMake(0, self.collectionView.y + self.collectionView.height);
}

@end
