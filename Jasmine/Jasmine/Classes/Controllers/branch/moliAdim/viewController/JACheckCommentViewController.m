//
//  JACheckCommentViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACheckCommentViewController.h"
#import "JACheckCommentCell.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceCommentGroupModel.h"
#import "JAPersonalCenterViewController.h"
#import "JAVoicePersonApi.h"
#import "JAVoiceCommentDetailViewController.h"
#import "JADeleteReasonModel.h"
#import "SPPageMenu.h"
#import "JASampleHelper.h"
#import "JAVoicePlayerManager.h"

#define kNeedNew 0

@interface JACheckCommentViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) UICollectionView *collectionView;

@property (nonatomic, weak) UIButton *recommendButton;    // 推荐
@property (nonatomic, weak) UIButton *unRecommendButton;  // 不推荐(new沉帖)
@property (nonatomic, weak) UIButton *passsButton;        //      (new通过)
@property (nonatomic, weak) UIButton *sinkButton;         // 沉帖(new隐藏)
@property (nonatomic, weak) UIButton *deleteButton;       // 删除

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

@property (nonatomic, assign) NSInteger currentCount;
@property (nonatomic, assign) int allCount;

@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
@end

@implementation JACheckCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
    _dataSourceArray = [NSMutableArray array];
    [self setupViewUI];
    
    [self getCheckVoiceCommentDetai:NO];
    
}

- (void)setupViewUI
{
    CGFloat height = 260;
   
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    // 设置大小
    flow.itemSize = CGSizeMake(JA_SCREEN_WIDTH, height);
    // 滚动方向
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    // 间距
    flow.minimumLineSpacing = 0;
    flow.minimumInteritemSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, height) collectionViewLayout:flow];
    _collectionView = collectionView;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.pagingEnabled = YES;
    collectionView.bounces = NO;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.scrollEnabled = NO;
    [collectionView registerClass:[JACheckCommentCell class] forCellWithReuseIdentifier:@"checkComment"];
    [self.view addSubview:collectionView];
    
    // 推荐
    UIButton *recommendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recommendButton = recommendButton;
    [recommendButton addTarget:self action:@selector(clickRecommentButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recommendButton];
    
    // 沉帖
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
    
    // 隐藏
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.deleteButton.width = 90;
    self.deleteButton.height = self.deleteButton.width * 40 / 90;
    self.deleteButton.y = self.view.height - (iPhoneX ? (36 + 34) : 36) - self.deleteButton.height;
    self.deleteButton.x = JA_SCREEN_WIDTH * 0.5 - 35 - self.deleteButton.width;
    
    self.sinkButton.width = self.deleteButton.width;
    self.sinkButton.height = self.deleteButton.height;
    self.sinkButton.y = self.deleteButton.y;
    self.sinkButton.x = JA_SCREEN_WIDTH * 0.5 + 35;
    
//    self.passsButton.width = self.deleteButton.width;
//    self.passsButton.height = self.passsButton.width;
//    self.passsButton.y = self.deleteButton.y - 20 - self.passsButton.height;
//    self.passsButton.centerX = JA_SCREEN_WIDTH * 0.5;
//
//    self.recommendButton.width = self.passsButton.width;
//    self.recommendButton.height = self.passsButton.height;
//    self.recommendButton.x = self.passsButton.x - 20 - self.recommendButton.width;
//    self.recommendButton.y = self.passsButton.y;
//
//    self.unRecommendButton.width = self.passsButton.width;
//    self.unRecommendButton.height = self.passsButton.height;
//    self.unRecommendButton.x = self.passsButton.right + 20;
//    self.unRecommendButton.y = self.passsButton.y;
    
    self.unRecommendButton.width = self.deleteButton.width;
    self.unRecommendButton.height = self.unRecommendButton.width;
    self.unRecommendButton.y = self.deleteButton.y - 20 - self.unRecommendButton.height;
    self.unRecommendButton.centerX = JA_SCREEN_WIDTH * 0.5;

    self.recommendButton.width = self.unRecommendButton.width;
    self.recommendButton.height = self.unRecommendButton.height;
    self.recommendButton.x = self.unRecommendButton.x - 20 - self.recommendButton.width;
    self.recommendButton.y = self.unRecommendButton.y;

    self.passsButton.width = self.unRecommendButton.width;
    self.passsButton.height = self.unRecommendButton.height;
    self.passsButton.x = self.unRecommendButton.right + 20;
    self.passsButton.y = self.unRecommendButton.y;
}

#pragma mark - 网络请求
- (void)getCheckVoiceCommentDetai:(BOOL)isMore
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (self.checkTag == 1) {
        
        dic[@"isSensitive"] = @(0);
    }else{
        dic[@"isSensitive"] = @(1);
    }
    [[JAVoicePersonApi shareInstance] voice_checkCommentWithPara:dic success:^(NSDictionary *result) {
        JAVoiceCommentGroupModel *groupModel = [JAVoiceCommentGroupModel mj_objectWithKeyValues:result[@"commentPageList"]];
        [self.dataSourceArray addObjectsFromArray:groupModel.result];
        self.currentCount = groupModel.totalCount;
        [self.pageMenu setTitle:[NSString stringWithFormat:@"回复(%ld)",self.currentCount] forItemAtIndex:1];
        for (JAVoiceCommentModel *model in self.dataSourceArray) {
            model.displayPeakLevelQueue = [JASampleHelper getDisplayPeakLevelQueue:model.sampleZip sample:model.sample type:JADisplayTypeCheckComment];
            model.currentPeakLevelQueue = [JASampleHelper getCurrentPeakLevelQueue:model.displayPeakLevelQueue type:JADisplayTypeCheckComment];
        }
        [self.collectionView reloadData];
        [self showBlankPage];
    } failure:^(NSError *error) {
        
        if (!self.dataSourceArray.count) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

#pragma mark - 数据源
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JAVoiceCommentModel *model = self.dataSourceArray[indexPath.section];
    JAVoiceCommentDetailViewController *vc = [[JAVoiceCommentDetailViewController alloc] init];
    vc.voiceId = model.s2cStoryMsg.voiceId.length ? model.s2cStoryMsg.voiceId : model.typeId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JACheckCommentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"checkComment" forIndexPath:indexPath];
    
    @WeakObj(self);
    cell.admin_jumpPersonalCenterBlock = ^(JACheckCommentCell *cell) {
        @StrongObj(self);
        if (cell.commentModel.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return;
        }
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.commentModel.userId;
        model.name = cell.commentModel.userName;
        model.image = cell.commentModel.userImage;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.admin_playCommentOrReplyBlock = ^(JACheckCommentCell *cell) {  // 播评论
        
        [JAVoicePlayerManager shareInstance].playEnterType = 1;
        
        [JAVoicePlayerManager shareInstance].replyVoices = nil;
        [JAVoicePlayerManager shareInstance].voices = nil;
        [JAVoicePlayerManager shareInstance].commentVoices = [@[cell.commentModel] mutableCopy];
        
        if (cell.commentModel.playState == 0) {
//            [[JAVoicePlayerManager shareInstance] stop];
            cell.commentModel.playState = 1;
            [JAVoicePlayerManager shareInstance].commentModel = cell.commentModel;
            [JAVoicePlayerManager shareInstance].currentPlayCommentIndex = indexPath.row;
        } else if (cell.commentModel.playState == 1) {
            cell.commentModel.playState = 2;
            [[JAVoicePlayerManager shareInstance] pause];
        } else if (cell.commentModel.playState == 2) {
            cell.commentModel.playState = 1;
            [[JAVoicePlayerManager shareInstance] contiunePlay];
        }
        
    };
    
    JAVoiceCommentModel *model = self.dataSourceArray[indexPath.item];
    cell.commentModel = model;
    return cell;
}

#warning 不要删
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    if (scrollView.contentOffset.x != JA_SCREEN_WIDTH) {
//        [MBProgressHUD hideHUD];
//        return;
//    }
//
//    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = model.voiceCommendId;
//    dic[@"dataType"] = @"norecommend";
//
//    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
//
//        [MBProgressHUD hideHUD];
//        [self setCenterTitle:[NSString stringWithFormat:@"未审核回帖(%ld)",self.currentCount - 1]]
//        ;
//        self.currentCount -= 1;
//
//        // 移除该条数据
//        [self.dataSourceArray removeObject:model];
//
//        // 获取第一条
//        NSIndexPath *indexP = [NSIndexPath indexPathForItem:0 inSection:0];
//
//        // 刷新数据
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//
//        // 如果当前的数据源少于3条的时候去请求网络数据
//        if (self.dataSourceArray.count == kNeedNew) {
//
//            [self getCheckVoiceCommentDetai:YES];
//        }
//
//    } failure:^(NSError *error) {
//        [MBProgressHUD hideHUD];
//        [self.view ja_makeToast:error.localizedDescription];
////        [self setCenterTitle:[NSString stringWithFormat:@"未审核回帖(%ld)",self.currentCount - 1]]
////        ;
////        self.currentCount -= 1;
//
//        // 移除该条数据
//        [self.dataSourceArray removeObject:model];
//
//        // 获取第一条
//        NSIndexPath *indexP = [NSIndexPath indexPathForItem:0 inSection:0];
//
//        // 刷新数据
//        [self.collectionView reloadData];
//        [self.collectionView scrollToItemAtIndexPath:indexP atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
//
//        // 如果当前的数据源少于3条的时候去请求网络数据
//        if (self.dataSourceArray.count == kNeedNew) {
//
//            [self getCheckVoiceCommentDetai:YES];
//        }
//    }];
//
//
//}
//
//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
//{
//    if (scrollView.contentOffset.x != 0) {
//
//        [MBProgressHUD showMessage:@""];
//    }
//}

#pragma mark - 按钮的点击事件
// 推荐
- (void)clickRecommentButton:(UIButton *)btn
{
    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"推荐" commentModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceCommendId;
    dic[@"dataType"] = @"recommend";
    dic[@"debugFlag"] = @"9999";
    
//    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    
    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
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
    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
    // 神策数据
    [self sensorsAnalytics:@"沉帖" commentModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceCommendId;
    dic[@"dataType"] = @"sedimentation";
    dic[@"debugFlag"] = @"9999";
    
    //    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];

//    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
//
//    // 神策数据
//    [self sensorsAnalytics:@"不推荐" commentModel:model];
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = model.voiceCommendId;
//    dic[@"dataType"] = @"norecommend";
//    dic[@"debugFlag"] = @"9999";
//
////    [MBProgressHUD showMessage:nil];
//    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
//    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
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
    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"通过" commentModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceCommendId;
    dic[@"dataType"] = @"norecommend";
    dic[@"debugFlag"] = @"9999";
    
    //    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];

}

// 沉帖(new隐藏)
- (void)clickSinkButton:(UIButton *)btn
{
    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"隐藏" commentModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"id"] = model.voiceCommendId;
    dic[@"dataType"] = @"hide";
    dic[@"debugFlag"] = @"9999";
    
    //    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
        // 推荐审核
        [self scrollToNext:YES];
    } failure:^(NSError *error) {
        [self scrollToNext:NO];
        [self.view ja_makeToast:error.localizedDescription];
    }];
//    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
//    // 神策数据
//    [self sensorsAnalytics:@"沉帖" commentModel:model];
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = model.voiceCommendId;
//    dic[@"dataType"] = @"sedimentation";
//    dic[@"debugFlag"] = @"9999";
//
////    [MBProgressHUD showMessage:nil];
//    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
//    [[JAVoicePersonApi shareInstance] voice_actionCommentWithPara:dic success:^(NSDictionary *result) {
//        // 推荐审核
//        [self scrollToNext:YES];
//    } failure:^(NSError *error) {
//        [self scrollToNext:NO];
//        [self.view ja_makeToast:error.localizedDescription];
//    }];
}

// 删除
- (void)clickDeleteButton:(UIButton *)btn
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
        
        JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:deletemodel.content style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self deleteCommentDateWithPara:deletemodel.content deleteType:deletemodel.type];
            
        }];
        
        [alert addAction:action];
    }
    UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action6];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deleteCommentDateWithPara:(NSString *)type deleteType:(NSString *)deleteType
{
//    [MBProgressHUD showMessage:nil];
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    JAVoiceCommentModel *model = self.dataSourceArray.firstObject;
    
    // 神策数据
    [self sensorsAnalytics:@"删除" commentModel:model];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"digest"] = type;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"id"] = model.voiceCommendId;
    dic[@"typeId"] = model.typeId;
    dic[@"type"] = model.type;
    dic[@"power"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
    dic[@"delReasonType"] = deleteType;
    [[JAVoiceCommentApi shareInstance] voice_deleteVoiceCommentWithParas:dic success:^(NSDictionary *result) {
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

    if (self.dataSourceArray.count > 0) {
        if (success) {
            [self.pageMenu setTitle:[NSString stringWithFormat:@"回复(%ld)",self.currentCount - 1] forItemAtIndex:1];
            self.currentCount -= 1;
        }
        [self.dataSourceArray removeObjectAtIndex:0];
        [self.collectionView reloadData];
//        [MBProgressHUD hideHUD];
        [self.currentProgressHUD hideAnimated:NO];
    }
    
    if (self.dataSourceArray.count == kNeedNew) {
        [self getCheckVoiceCommentDetai:YES];
    }

}

- (void)actionRight
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"暂无未审核数据";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
}

- (void)sensorsAnalytics:(NSString *)mothod commentModel:(JAVoiceCommentModel *)model
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
    senDic[JA_Property_ContentType] = @"回复";
    senDic[JA_Property_ContentId] = model.voiceCommendId;
    senDic[JA_Property_ContentTitle] = model.content;
    senDic[JA_Property_RecordDuration] = @(sen_time);
    [JASensorsAnalyticsManager sensorsAnalytics_checkContent:senDic];
    
}
@end
