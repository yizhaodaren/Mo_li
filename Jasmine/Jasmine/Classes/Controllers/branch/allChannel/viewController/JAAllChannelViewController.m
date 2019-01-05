//
//  JAAllChannelViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAAllChannelViewController.h"
#import "JAAllChannelCell.h"
#import "JAVoiceApi.h"
#import "JAChannelModel.h"

@interface JAAllChannelViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *datasourceArray;

@end

@implementation JAAllChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datasourceArray = [NSMutableArray array];
    NSArray *arr = [JAConfigManager shareInstance].channelArr;
    if (arr.count) {
        [self.datasourceArray addObjectsFromArray:arr];
    }
    [self setCenterTitle:@"全部频道"];
    [self setupChannelView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"全部频道";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)setupChannelView
{
    // 设置流水布局
    CGFloat padding = (JA_SCREEN_WIDTH-WIDTH_ADAPTER(105)*3)/4.0;
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    flow.itemSize = CGSizeMake(WIDTH_ADAPTER(105), HEIGHT_ADAPTER(45));
    flow.minimumLineSpacing = 20;
    flow.minimumInteritemSpacing = padding;
    
    CGRect rect = CGRectMake(padding, 20, JA_SCREEN_WIDTH - padding*2, JA_SCREEN_HEIGHT-64-20-20);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:flow];
    _collectionView = collectionView;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [collectionView registerClass:[JAAllChannelCell class] forCellWithReuseIdentifier:@"JAAllChannelCellID"];
    collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:collectionView];
}

#pragma mark - collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JAAllChannelCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JAAllChannelCellID" forIndexPath:indexPath];
    JAChannelModel *model = self.datasourceArray[indexPath.item];
    cell.nameString = model.title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    JAChannelModel *model = self.datasourceArray[indexPath.item];
    if (self.selectedChannel) {
        self.selectedChannel(model);
    }
    [self.navigationController popViewControllerAnimated:YES];
}



@end
