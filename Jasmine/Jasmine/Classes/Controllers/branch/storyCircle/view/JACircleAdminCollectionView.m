//
//  JACircleAdminCollectionView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/27.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleAdminCollectionView.h"
#import "JACircleAdminCollectionViewCell.h"
#import "JAPersonalCenterViewController.h"
#import "CYLTabBarController.h"

@interface JACircleAdminCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, weak) UILabel *circleNameLabel;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation JACircleAdminCollectionView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupCircleAdminCollectionViewUI];
    }
    return self;
}

- (void)setupCircleAdminCollectionViewUI
{
    UILabel *circleNameLabel = [[UILabel alloc] init];
    _circleNameLabel = circleNameLabel;
    circleNameLabel.text = @" ";
    circleNameLabel.textColor = HEX_COLOR(0x363636);
    circleNameLabel.font = JA_MEDIUM_FONT(15);
    [self addSubview:circleNameLabel];
    
    self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
    self.flowLayout.minimumLineSpacing = 0;  // 行距
    self.flowLayout.minimumInteritemSpacing = 0;
    self.flowLayout.itemSize = CGSizeMake(65, 77);
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
    _collectionView = collectionView;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView registerClass:[JACircleAdminCollectionViewCell class] forCellWithReuseIdentifier:@"JACircleAdminCollectionViewCell_id"];
    collectionView.backgroundColor = HEX_COLOR(0xffffff);
    [self addSubview:_collectionView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorCircleAdminCollectionViewFrame];
}

- (void)calculatorCircleAdminCollectionViewFrame
{
    [self.circleNameLabel sizeToFit];
    self.circleNameLabel.height = 50;
    self.circleNameLabel.x = 15;
    
    self.collectionView.width = JA_SCREEN_WIDTH;
    self.collectionView.height = 77;
    self.collectionView.y = self.circleNameLabel.bottom;
}

- (void)setDataSourceModel:(JACircleAdminModel *)dataSourceModel
{
    _dataSourceModel = dataSourceModel;
    self.circleNameLabel.text = dataSourceModel.adminName;
    [self.circleNameLabel sizeToFit];
    [self.collectionView reloadData];
}

#pragma mark - delegate
//分区，组
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//每一分区的单元个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceModel.baseUserVOList.count;
}
//单元格复用
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JACircleAdminCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"JACircleAdminCollectionViewCell_id" forIndexPath:indexPath];
    JALightUserModel *user = self.self.dataSourceModel.baseUserVOList[indexPath.row];
    cell.userModel = user;
    return cell;
}

//被选中的单元格
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JALightUserModel *user = self.self.dataSourceModel.baseUserVOList[indexPath.row];
    // 跳转
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    JAConsumer *model = [[JAConsumer alloc] init];
    model.userId = user.userId;
    model.name = user.userName;
    model.image = user.avatar;
    vc.personalModel = model;
    [[self currentViewController].navigationController pushViewController:vc animated:YES];
}

// 获取当前控制器
- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
    MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    return [self findBestViewController:tab];
}
@end
