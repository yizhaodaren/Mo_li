//
//  JACheckPostsViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckPostsViewController.h"
#import "JACheckPostsCell.h"
#import "JAVoiceApi.h"
#import "JAVoiceGroupModel.h"
#import "JAVoiceModel.h"
#import "JAVoicePersonApi.h"
#import "JACheckCommentViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JAVoiceCommentDetailViewController.h"
#import "JADeleteReasonModel.h"
#import "SPPageMenu.h"
#import "JASampleHelper.h"
#import "JAVoicePlayerManager.h"

#define kNeedNew 0

@interface JACheckPostsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flow;

//@property (nonatomic, weak) UIView *bottomView;

@property (nonatomic, weak) UIButton *recommendButton;    // 推荐
@property (nonatomic, weak) UIButton *unRecommendButton;  // 不推荐(new沉帖)
@property (nonatomic, weak) UIButton *passsButton;        //      (new通过)
@property (nonatomic, weak) UIButton *sinkButton;         // 沉帖(new隐藏)
@property (nonatomic, weak) UIButton *deleteButton;       // 删除

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *datasourceArray;

@property (nonatomic, assign) NSInteger currentCount;
// 当前审核的帖子
//@property (nonatomic, strong) JAVoiceModel *currentModel;

@property (nonatomic, assign) int allCount;

@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@end

@implementation JACheckPostsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _datasourceArray = [NSMutableArray array];
    [self setupViewUI];
    
    [self getCheckVoiceListWithLoadMore:NO];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // 设置大小
    self.flow.itemSize = CGSizeMake(JA_SCREEN_WIDTH, self.view.height - (iPhoneX ? 225 : ((iPhone4 || iPhone5) ? 95 : 190)));
    self.collectionView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, self.view.height - (iPhoneX ? 225 : ((iPhone4 || iPhone5) ? 95 : 190)));
    
    self.deleteButton.width = (iPhone5 || iPhone4) ? 45 : 90;
    self.deleteButton.height = self.deleteButton.width * 40 / 90;
    self.deleteButton.y = self.view.height - (iPhoneX ? (36 + 34) : ((iPhone5 || iPhone4) ? 20 : 36)) - self.deleteButton.height;
    self.deleteButton.x = JA_SCREEN_WIDTH * 0.5 - 35 - self.deleteButton.width;
    
    self.sinkButton.width = self.deleteButton.width;
    self.sinkButton.height = self.deleteButton.height;
    self.sinkButton.y = self.deleteButton.y;
    self.sinkButton.x = JA_SCREEN_WIDTH * 0.5 + 35;
    
    
//    self.passsButton.width = self.deleteButton.width;
//    self.passsButton.height = self.passsButton.width;
//    self.passsButton.centerX = JA_SCREEN_WIDTH * 0.5;
//    self.passsButton.y = self.deleteButton.y - ((iPhone5 || iPhone4) ? 10 : 20) - self.passsButton.height;
//
//    self.recommendButton.width = self.passsButton.width;
//    self.recommendButton.height = self.passsButton.height;
//    self.recommendButton.y = self.passsButton.y;
//    self.recommendButton.x = self.passsButton.x - 20 - self.recommendButton.width;
//
//    self.unRecommendButton.width = self.passsButton.width;
//    self.unRecommendButton.height = self.passsButton.height;
//    self.unRecommendButton.x = self.passsButton.right + 20;
//    self.unRecommendButton.y = self.passsButton.y;
    
    self.unRecommendButton.width = self.deleteButton.width;
    self.unRecommendButton.height = self.unRecommendButton.width;
    self.unRecommendButton.centerX = JA_SCREEN_WIDTH * 0.5;
    self.unRecommendButton.y = self.deleteButton.y - ((iPhone5 || iPhone4) ? 10 : 20) - self.unRecommendButton.height;

    self.recommendButton.width = self.unRecommendButton.width;
    self.recommendButton.height = self.unRecommendButton.height;
    self.recommendButton.y = self.unRecommendButton.y;
    self.recommendButton.x = self.unRecommendButton.x - 20 - self.recommendButton.width;

    self.passsButton.width = self.unRecommendButton.width;
    self.passsButton.height = self.unRecommendButton.height;
    self.passsButton.x = self.unRecommendButton.right + 20;
    self.passsButton.y = self.unRecommendButton.y;
}

- (void)setupViewUI
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    _flow = flow;
    // 滚动方向
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 间距
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, self.view.height - (iPhoneX ? 225 : ((iPhone4 || iPhone5) ? 95 : 190))) collectionViewLayout:flow];
    _collectionView = collectionView;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.bounces = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.scrollEnabled = NO;
    [collectionView registerClass:[JACheckPostsCell class] forCellWithReuseIdentifier:@"checkPosts"];
    [self.view addSubview:collectionView];
//
    // 推荐
    UIButton *recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recommendButton = recommendButton;
    [recommendButton addTarget:self action:@selector(clickRecommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recommendButton];
    
    // 不推荐(new沉帖)
    UIButton *unRecommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _unRecommendButton = unRecommendButton;
    [unRecommendButton addTarget:self action:@selector(clickUnrecommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:unRecommendButton];
    
    // 通过
    UIButton *passsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _passsButton = passsButton;
//    passsButton.hidden = YES;
    [passsButton addTarget:self action:@selector(clickPasssButtonButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:passsButton];
    
    // 沉帖(new隐藏)
    UIButton *sinkButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sinkButton = sinkButton;
    [sinkButton addTarget:self action:@selector(clickSinkButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sinkButton];
  
    // 删除
    UIButton *deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton = deleteButton;
    [deleteButton addTarget:self action:@selector(clickDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:deleteButton];
    
    [passsButton setImage:[UIImage imageNamed:@"admin_Pass_UnSel"] forState:UIControlStateNormal];
    [passsButton setImage:[UIImage imageNamed:@"admin_Pass_Sel"] forState:UIControlStateHighlighted];
    
    [recommendButton setImage:[UIImage imageNamed:@"admin_Recommend_unSel"] forState:UIControlStateNormal];
    [recommendButton setImage:[UIImage imageNamed:@"admin_Recommend_Sel"] forState:UIControlStateHighlighted];
    
//    [unRecommendButton setImage:[UIImage imageNamed:@"admin_old_unRecommend_unSel"] forState:UIControlStateNormal];
//    [unRecommendButton setImage:[UIImage imageNamed:@"admin_old_unRecommend_Sel"] forState:UIControlStateHighlighted];
//
//    [sinkButton setImage:[UIImage imageNamed:@"admin_old_sink_small_unSel"] forState:UIControlStateNormal];
//    [sinkButton setImage:[UIImage imageNamed:@"admin_old_sink_small_unSel"] forState:UIControlStateHighlighted];
    
    [unRecommendButton setImage:[UIImage imageNamed:@"admin_unRecommend_unSel"] forState:UIControlStateNormal];
    [unRecommendButton setImage:[UIImage imageNamed:@"admin_unRecommend_Sel"] forState:UIControlStateHighlighted];
    
    [sinkButton setImage:[UIImage imageNamed:@"admin_hidden_UnSel"] forState:UIControlStateNormal];
    [sinkButton setImage:[UIImage imageNamed:@"admin_hidden_UnSel"] forState:UIControlStateHighlighted];
    
    [deleteButton setImage:[UIImage imageNamed:@"admin_delete_small_unSel"] forState:UIControlStateNormal];
    [deleteButton setImage:[UIImage imageNamed:@"admin_delete_small_unSel"] forState:UIControlStateHighlighted];
  
}

#pragma mark - 数据源方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    JAVoiceModel *voice = self.datasourceArray[indexPath.section];
    
    JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
    vc.voiceId = voice.voiceId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datasourceArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JACheckPostsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"checkPosts" forIndexPath:indexPath];
    
    @WeakObj(self);
    cell.headActionBlock = ^(JACheckPostsCell *cell) {  // 跳转个人中心
        
        @StrongObj(self);
        if (cell.data.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
                        [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return;
        }
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.data.userId;
        model.name = cell.data.userName;
        model.image = cell.data.userImage;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.playBlock = ^(JACheckPostsCell *cell) {    // 播放
        
        [JAVoicePlayerManager shareInstance].playEnterType = 1;
        
        [JAVoicePlayerManager shareInstance].replyVoices = nil;
        [JAVoicePlayerManager shareInstance].voices = [@[cell.data] mutableCopy];
        [JAVoicePlayerManager shareInstance].commentVoices = nil;
        [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
        
        if (cell.data.playState == 0) {
            
//            [[JAVoicePlayerManager shareInstance] stop];
            [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
            
            cell.data.playState = 1;
            [JAVoicePlayerManager shareInstance].voiceModel = cell.data;
  
        } else if (cell.data.playState == 1) {
            cell.data.playState = 2;
            [[JAVoicePlayerManager shareInstance] pause];
        } else if (cell.data.playState == 2) {
            cell.data.playState = 1;
            [[JAVoicePlayerManager shareInstance] contiunePlay];
        }
    };
 
    JAVoiceModel *model = self.datasourceArray[indexPath.item];
    cell.data = model;
    return cell;
}

#warning 不要删
// 动画结束的时候 1 如果偏移量 = 0 隐藏遮罩  2 偏移量 = 屏幕宽度，发送请求 请求成功后 隐藏遮罩
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//
//    if (scrollView.contentOffset.x != JA_SCREEN_WIDTH) {
//        [MBProgressHUD hideHUD];
//        return;
//    }
//
//    JAVoiceModel *model = self.datasourceArray.firstObject;
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = model.voiceId;
//    dic[@"dataType"] = @"norecommend";
//
//
//    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
//        [MBProgressHUD hideHUD];
//        [self setCenterTitle:[NSString stringWithFormat:@"未审核主帖(%ld)",self.currentCount - 1]]
//        ;
//        self.currentCount -= 1;
//
//        // 移除该条数据
//        [self.datasourceArray removeObject:model];
//
//        // 获取第一条
//        NSIndexPath *indexP = [NSIndexPath indexPathForItem:0 inSection:0];
//
//        // 刷新数据
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//
//        // 如果当前的数据源少于3条的时候去请求网络数据
//        if (self.datasourceArray.count == kNeedNew) {
//
//            [self getCheckVoiceListWithLoadMore:YES];
//        }
//
//    } failure:^(NSError *error) {
//        [MBProgressHUD hideHUD];
//        [self.view ja_makeToast:error.localizedDescription];
//
////        [self setCenterTitle:[NSString stringWithFormat:@"未审核主帖(%ld)",self.currentCount - 1]]
//        ;
////        self.currentCount -= 1;
//
//        // 移除该条数据
//        [self.datasourceArray removeObject:model];
//
//        // 获取第一条
//        NSIndexPath *indexP = [NSIndexPath indexPathForItem:0 inSection:0];
//
//        // 刷新数据
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//
//        // 如果当前的数据源少于3条的时候去请求网络数据
//        if (self.datasourceArray.count == kNeedNew) {
//
//            [self getCheckVoiceListWithLoadMore:YES];
//        }
//    }];
//}

// 结束拖拽的时候 添加遮罩来阻止用户继续滑动
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (scrollView.contentOffset.x != 0) {
//
//        [MBProgressHUD showMessage:@""];
//    }
//}

#pragma mark - Network
- (void)getCheckVoiceListWithLoadMore:(BOOL)isLoadMore
{
//    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.checkTag == 1) {
        
        dic[@"isSensitive"] = @(0);
    }else{
        dic[@"isSensitive"] = @(1);
    }
    [[JAVoicePersonApi shareInstance] voice_checkPostsWithPara:dic success:^(NSDictionary *result) {
//        [MBProgressHUD hideHUD];
        [self.currentProgressHUD hideAnimated:NO];
        
        JAVoiceGroupModel *groupModel = [JAVoiceGroupModel mj_objectWithKeyValues:result[@"storyPageList"]];
        self.currentCount = groupModel.totalCount;
        [self.pageMenu setTitle:[NSString stringWithFormat:@"主帖(%ld)",self.currentCount] forItemAtIndex:0];
        if (groupModel.result.count) {
            
            for (JAVoiceModel *model in groupModel.result) {
                model.displayPeakLevelQueue = [JASampleHelper getDisplayPeakLevelQueue:model.sampleZip sample:model.sample type:JADisplayTypeCheckVoice];
                model.currentPeakLevelQueue = [JASampleHelper getCurrentPeakLevelQueue:model.displayPeakLevelQueue type:JADisplayTypeCheckVoice];
            }
//            [self.datasourceArray removeAllObjects];
            [self.datasourceArray addObjectsFromArray:groupModel.result];
        }
        [self.collectionView reloadData];
        
        [self showBlankPage];
        
    } failure:^(NSError *error) {
//        [MBProgressHUD hideHUD];
        [self.currentProgressHUD hideAnimated:NO];
        if (!self.datasourceArray.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

#pragma mark - 按钮点击
/// 推荐
- (void)clickRecommentButton:(UIButton *)btn
{
    JAVoiceModel *model = self.datasourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"推荐" storyModel:model];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceId;
    dic[@"dataType"] = @"recommend";
    dic[@"debugFlag"] = @"9999";
    
//    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
       
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

// 不推荐(new沉帖)
- (void)clickUnrecommentButton:(UIButton *)btn
{
    JAVoiceModel *model = self.datasourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"沉帖" storyModel:model];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceId;
    dic[@"dataType"] = @"sedimentation";
    dic[@"debugFlag"] = @"9999";
    
    //    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];

    
//    JAVoiceModel *model = self.datasourceArray.firstObject;
//    // 神策数据
//    [self sensorsAnalytics:@"不推荐" storyModel:model];
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = model.voiceId;
//    dic[@"dataType"] = @"norecommend";
//    dic[@"debugFlag"] = @"9999";
//
////    [MBProgressHUD showMessage:nil];
//    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
//    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
//        // 推荐审核
//        [self scrollToNext:YES];
//    } failure:^(NSError *error) {
//        [self scrollToNext:NO];
//        [self.view ja_makeToast:error.localizedDescription];
//    }];
}

// 通过
- (void)clickPasssButtonButton:(UIButton *)btn
{
    JAVoiceModel *model = self.datasourceArray.firstObject;
    // 神策数据
    [self sensorsAnalytics:@"通过" storyModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceId;
    dic[@"dataType"] = @"norecommend";
    dic[@"debugFlag"] = @"9999";
    
    //    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];

}

/// 沉帖(new隐藏)
- (void)clickSinkButton:(UIButton *)btn
{
    JAVoiceModel *model = self.datasourceArray.firstObject;
    // 神策数据
    [self sensorsAnalytics:@"隐藏" storyModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceId;
    dic[@"dataType"] = @"hide";
    dic[@"debugFlag"] = @"9999";
    
    //    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];
    
//    JAVoiceModel *model = self.datasourceArray.firstObject;
//
//    // 神策数据
//    [self sensorsAnalytics:@"沉帖" storyModel:model];
//
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = model.voiceId;
//    dic[@"dataType"] = @"sedimentation";
//    dic[@"debugFlag"] = @"9999";
//
////    [MBProgressHUD showMessage:nil];
//    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
//    [[JAVoicePersonApi shareInstance] voice_actionPostsWithPara:dic success:^(NSDictionary *result) {
//        // 推荐审核
//        [self scrollToNext:YES];
//    } failure:^(NSError *error) {
//        [self scrollToNext:NO];
//        [self.view ja_makeToast:error.localizedDescription];
//    }];
}

/// 删除
- (void)clickDeleteButton:(UIButton *)btn
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:deletemodel.content style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self deleteVoiceDateWithPara:deletemodel.content deleteType:deletemodel.type];
            
        }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:action6];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteVoiceDateWithPara:(NSString *)type deleteType:(NSString *)deleteType
{
//    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    JAVoiceModel *model = self.datasourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"删除" storyModel:model];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = model.voiceId;
    dic[@"power"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    dic[@"digest"] = type;
    dic[@"delReasonType"] = deleteType;
    [[JAVoiceApi shareInstance] voice_deleteVoiceWithParas:dic success:^(NSDictionary *result) {
        
        [self scrollToNext:YES];
        
    } failure:^(NSError *error) {
//        [MBProgressHUD hideHUD];
        [self.currentProgressHUD hideAnimated:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

// 自动滚动到下一条
- (void)scrollToNext:(BOOL)success
{
    
    if (self.datasourceArray.count > 0) {
        if (success) {
            [self.pageMenu setTitle:[NSString stringWithFormat:@"主帖(%ld)",self.currentCount - 1] forItemAtIndex:0];
            self.currentCount -= 1;
        }
        
        [self.datasourceArray removeObjectAtIndex:0];
        [self.collectionView reloadData];
     
//        [MBProgressHUD hideHUD];
        [self.currentProgressHUD hideAnimated:NO];

    }
    
    if (self.datasourceArray.count == kNeedNew) {
        
        [self getCheckVoiceListWithLoadMore:YES];
    }
}

- (void)actionRight
{
    JACheckCommentViewController *vc = [[JACheckCommentViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showBlankPage
{
    if (self.datasourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"暂无未审核数据";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

- (void)sensorsAnalytics:(NSString *)mothod storyModel:(JAVoiceModel *)model
{
    // 神策数据
    // 计算时间
    NSArray *timeArr = [model.time componentsSeparatedByString:@":"];
    NSString *min = timeArr.firstObject;
    NSString *sec = timeArr.lastObject;
    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_ReviewMethod] = @"人工";
    senDic[JA_Property_ReviewResult] = mothod;
    senDic[JA_Property_PostId] = model.userId;
    senDic[JA_Property_PostName] = model.userName;
    senDic[JA_Property_ContentType] = @"主帖";
    senDic[JA_Property_ContentId] = model.voiceId;
    senDic[JA_Property_ContentTitle] = model.content;
    senDic[JA_Property_RecordDuration] = @(sen_time);
    [JASensorsAnalyticsManager sensorsAnalytics_checkContent:senDic];

}
@end
