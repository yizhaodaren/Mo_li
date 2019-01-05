//
//  JAVoiceNotiCallMeViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/3/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAVoiceNotiCallMeViewController.h"

#import "JAVoiceInviteCell.h"
#import "JAVoiceReplyCell.h"
#import "JAPersonalCenterViewController.h"
#import "JAPostDetailViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JASampleHelper.h"
#import "JAVoiceReplyDetailViewController.h"

#import "JAVoiceCommonApi.h"
#import "JAUserApiRequest.h"
#import "JAVoiceCommentApi.h"
#import "JAVoiceReplyApi.h"

#import "JAPersonTopicViewController.h"
#import "JADataHelper.h"
#import "JAVoicePlayerManager.h"

#import "JAPlayLocalVoiceManager.h"

#import "JANewReplyModel.h"

#define Kcount 20
@interface JAVoiceNotiCallMeViewController ()<UITableViewDataSource, UITableViewDelegate>// JAInputViewDelegate
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;   // 数据源

@property (nonatomic, assign) NSInteger lastCount;   // 数据库分页标识
@property (nonatomic, assign) int allCount;

@property (nonatomic, strong) NSIndexPath *frontIndex;  // 前一个点击的cell

@property (nonatomic, strong) JANotiModel *needRefreshModel;  // 需要更新的model
// 发布用参数
@property (nonatomic, assign) BOOL anonymous;
@end

static NSString *callMe_VoiceCommentCellID = @"callMe_VoiceCommentCellID";
static NSString *callMe_VoiceVoiceCellID = @"callMe_VoiceVoiceCellID";

@implementation JAVoiceNotiCallMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self getNoti:NO type:@"atuser"];
    
    [self setCenterTitle:@"@我"];
    
    // 置为已读 2.6.0添加，现在一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeCallPerson];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointArrive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiCallPersonArrive) name:@"Noti_CallPerson_Arrive" object:nil];
}

- (void)notiCallPersonArrive
{
    // 刷新数据源
    NSDictionary *dic = @{@"operation" : @"atuser"};
    NSArray *lastDataSource = [JANotiModel searchWithWhere:dic orderBy:@"time desc" offset:0 count:1];
    JANotiModel *lastModel = lastDataSource.firstObject;
    JANotiModel *model = self.dataSourceArray.firstObject;
    if (lastModel.rowid != model.rowid) {
        [self.dataSourceArray insertObject:lastModel atIndex:0];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.tableView reloadData];
        [self showBlankPage];
    });
}

- (void)redPointArrive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 重置红点
        if ([self.view isDisplayedInScreen]) {
            [JARedPointManager resetNewRedPointArrive:JARedPointTypeCallPerson];
        }
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 置为已读 2.6.0添加，现在一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeCallPerson];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];

    [[JAVoicePlayerManager shareInstance] beforeLocalPlayResetAll];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI
{
    // tableView
    CGFloat safeHeight = 64;
    if (iPhoneX) {
        safeHeight = 64 + 24 + 34;
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - safeHeight)];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[JAVoiceInviteCell class] forCellReuseIdentifier:callMe_VoiceVoiceCellID];
    [tableView registerClass:[JAVoiceReplyCell class] forCellReuseIdentifier:callMe_VoiceCommentCellID];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getNoti:YES type:@"atuser"];
    }];
    
//    self.inputView = [[JAInputView alloc] init];
//    self.inputView.width = JA_SCREEN_WIDTH;
//    self.inputView.height = 50;
//    self.inputView.y = self.view.height - ((iPhoneX) ? 34 : 0);
//    self.inputView.inputInitial = JAInputInitialLocalTypeHiden;
//    self.inputView.delegate = self;
//    self.inputView.isAnonymous = NO;
//    [self.view addSubview:self.inputView];
}


#pragma mark - 获取所有邀请回复的数据
- (void)getNoti:(BOOL)isMore type:(NSString *)type
{
    if (!isMore) {   // 不是加载更多
        self.lastCount = 0;
        self.tableView.mj_footer.hidden = YES; // 先隐藏底部
    }
    [self.tableView.mj_footer endRefreshing];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSDictionary *dic = @{@"operation" : type};
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
            
            self.dataSourceArray = [JANotiModel searchWithWhere:dic orderBy:@"time desc" offset:0 count:Kcount];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dataSourceArray.count == Kcount) {
                    self.tableView.mj_footer.hidden = NO;
                    
                    self.lastCount += Kcount;
                }else{
                    self.tableView.mj_footer.hidden = YES;
                }
                
                [self showBlankPage];
            });
            
        }else{
            NSMutableArray *arr = [JANotiModel searchWithWhere:dic orderBy:@"time desc" offset:self.lastCount count:Kcount];
            [self.dataSourceArray addObjectsFromArray:arr];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.dataSourceArray.count == self.lastCount + Kcount) {
                    self.tableView.mj_footer.hidden = NO;
                    
                    self.lastCount += Kcount;
                }else{
                    [self.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark UITableView delegate and dataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JANotiModel *model = self.dataSourceArray[indexPath.row];
    
    return model.cellHeight;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self.inputView registAllInput];
        return;
    }
    
    JANotiModel *data = self.dataSourceArray[indexPath.row];
    // 更新数据库
    if (data.readState == NO) {
        data.readState = YES; // 已读
        [data updateToDB];
    }
    
    if ([data.content.type isEqualToString:@"story"]) {   // 帖子中@
        JAVoiceInviteCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.model = data;
        // 跳转帖子
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        vc.voiceId = data.content.storyId;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        
        JAVoiceReplyCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.model = data;
        
        // 获取数据类型 - 跳转对应的界面
        if ([data.content.type isEqualToString:@"reply"]) { // 回复中@
            // 跳转评论详情
            JAVoiceReplyDetailViewController *vc = [[JAVoiceReplyDetailViewController alloc] init];
            vc.voiceId = data.content.storyId;
            vc.voiceCommentId = data.content.subjoin.typeId;
            vc.hasRightButton = YES;
            vc.storyUserId = data.content.storyUserId;
            
            JANewReplyModel *replyM = [[JANewReplyModel alloc] init];
            replyM.audioUrl = data.content.audioUrl;
            replyM.content = data.content.content;
            replyM.createTime = data.content.createTime;
            replyM.replyId = data.content.typeId;
            replyM.time = data.content.time;
            
            JALightUserModel *userM = [[JALightUserModel alloc] init];
            userM.userId = data.content.userId;
            userM.isAnonymous = data.content.isAnonymous;
            userM.userName = data.content.userName;
            userM.avatar = data.user.img;
            replyM.user = userM;
            
            JALightUserModel *replyUserM = [[JALightUserModel alloc] init];
            replyUserM.userId = data.content.subjoin.userId;
            replyUserM.isAnonymous = data.content.subjoin.isAnonymous;
            replyUserM.userName = data.content.subjoin.userName;
            replyUserM.avatar = data.user.img;
            replyM.replyUser = replyUserM;
            
            vc.first_replyModel = replyM;
            
            [self.navigationController pushViewController:vc animated:YES];
        }else{
            
            // 跳转帖子详情
            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            vc.voiceId = data.content.storyId;
            vc.jump_commentId = data.content.typeId;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JANotiModel *model = self.dataSourceArray[indexPath.row];
    
    if ([model.content.type isEqualToString:@"story"]) {   // 在帖子中@我
        
        @WeakObj(self);
        JAVoiceInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:callMe_VoiceVoiceCellID];
        
        cell.model = model;
        cell.jumpPersonalCenterBlock = ^(JAVoiceInviteCell *cell) {
            
            @StrongObj(self);
            if (cell.model.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {   // 匿名则退出
                [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
                return ;
            }
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            model.userId = cell.model.user.userId;
            model.name = cell.model.user.nick;
            model.image = cell.model.user.img;
            vc.personalModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        cell.playCommentBlock = ^(JAVoiceInviteCell *cell) {   // 播放帖子
            JAVoiceModel *voiceM = [[JAVoiceModel alloc] init];
            voiceM.audioUrl = cell.model.content.audioUrl;
            voiceM.sample = cell.model.content.audioPlayImg;
            voiceM.voiceId = cell.model.content.typeId;
            voiceM.playState = cell.model.playState;
            voiceM.userId = cell.model.content.userId;
            voiceM.userName = cell.model.content.userName;
            voiceM.content = cell.model.content.content;
            voiceM.isAnonymous = cell.model.content.isAnonymous;
            voiceM.time = cell.model.content.time;
            
            [JAVoicePlayerManager shareInstance].replyVoices = nil;
            [JAVoicePlayerManager shareInstance].commentVoices = nil;
            [JAVoicePlayerManager shareInstance].voices = [@[voiceM] mutableCopy];
            
            if (cell.model.playState == 0) {
                cell.model.playState = 1;
                [JAVoicePlayerManager shareInstance].voiceModel.playState = 1;
                [JAVoicePlayerManager shareInstance].voiceModel = voiceM;
                [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
            } else if (cell.model.playState == 1) {
                cell.model.playState = 2;
                [JAVoicePlayerManager shareInstance].voiceModel.playState = 2;
                [[JAVoicePlayerManager shareInstance] pause];
            } else if (cell.model.playState == 2) {
                cell.model.playState = 1;
                [JAVoicePlayerManager shareInstance].voiceModel.playState = 1;
                [[JAVoicePlayerManager shareInstance] contiunePlay];
            }
        };
        
        // v2.6.0
        cell.topicDetailBlock = ^(NSString *topicName) {
            @StrongObj(self);
            JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
            vc.topicTitle = topicName;
            [self.navigationController pushViewController:vc animated:YES];
        };
        cell.atPersonBlock = ^(NSString *userName, NSArray *atList) {
            @StrongObj(self);
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
            [self.navigationController pushViewController:vc animated:YES];
        };
        return cell;
        
    }else{   // 在回复中@我
        
        @WeakObj(self);
        JAVoiceReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:callMe_VoiceCommentCellID];
        cell.model = model;
        cell.jumpPersonalCenterBlock = ^(JAVoiceReplyCell *cell) {  // 跳个人中心
            @StrongObj(self);
            if (cell.model.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {   // 匿名则退出
                [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
                return ;
            }
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            model.userId = cell.model.user.userId;
            model.name = cell.model.user.nick;
            model.image = cell.model.user.img;
            vc.personalModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        cell.playCommentOrReplyBlock = ^(JAVoiceReplyCell *cell) {
            if ([cell.model.content.type isEqualToString:@"reply"]) {    // 播回复
                // 创建回复模型
                JAVoiceReplyModel *replyM = [[JAVoiceReplyModel alloc] init];
                replyM.audioUrl = cell.model.content.audioUrl;
                replyM.sample = cell.model.content.audioPlayImg;
                replyM.voiceReplyId = cell.model.content.typeId;
                replyM.playState = cell.model.playReplyState;
                replyM.userId = cell.model.content.userId;
                replyM.userName = cell.model.content.userName;
                replyM.userImage = cell.model.user.img;
                replyM.isAnonymous = cell.model.content.isAnonymous;
                replyM.content = cell.model.content.content;
                replyM.time = cell.model.content.time;
                
                [JAVoicePlayerManager shareInstance].commentVoices = nil;
                [JAVoicePlayerManager shareInstance].voices = nil;
                [JAVoicePlayerManager shareInstance].replyVoices = [@[replyM] mutableCopy];
                
                if (cell.model.playReplyState == 0) {
                    
                    cell.model.playReplyState = 1;
                    [JAVoicePlayerManager shareInstance].replyModel.playState = 1;
                    [JAVoicePlayerManager shareInstance].replyModel = replyM;
                    [JAVoicePlayerManager shareInstance].currentPlayReplyIndex = 0;
                    
                } else if (cell.model.playReplyState == 1) {
                    cell.model.playReplyState = 2;
                    [JAVoicePlayerManager shareInstance].replyModel.playState = 2;
                    [[JAVoicePlayerManager shareInstance] pause];
                } else if (cell.model.playReplyState == 2) {
                    cell.model.playReplyState = 1;
                    [JAVoicePlayerManager shareInstance].replyModel.playState = 1;
                    [[JAVoicePlayerManager shareInstance] contiunePlay];
                }
            }else if ([cell.model.content.type isEqualToString:@"comment"]){   // 播评论
                // 创建评论模型
                JAVoiceCommentModel *commentM = [[JAVoiceCommentModel alloc] init];
                commentM.audioUrl = cell.model.content.audioUrl;
                commentM.sample = cell.model.content.audioPlayImg;
                commentM.voiceCommendId = cell.model.content.typeId;
                commentM.playState = cell.model.playCommentState;
                commentM.userId = cell.model.content.userId;
                commentM.userName = cell.model.content.userName;
                commentM.userImage = cell.model.user.img;
                commentM.content = cell.model.content.content;
                commentM.isAnonymous = cell.model.content.isAnonymous;
                commentM.time = cell.model.content.time;
                
                [JAVoicePlayerManager shareInstance].replyVoices = nil;
                [JAVoicePlayerManager shareInstance].voices = nil;
                [JAVoicePlayerManager shareInstance].commentVoices = [@[commentM] mutableCopy];
                
                
                if (cell.model.playCommentState == 0) {
                    cell.model.playCommentState = 1;
                    [JAVoicePlayerManager shareInstance].commentModel.playState = 1;
                    [JAVoicePlayerManager shareInstance].commentModel = commentM;
                    [JAVoicePlayerManager shareInstance].currentPlayCommentIndex = 0;
                    
                } else if (cell.model.playCommentState == 1) {
                    cell.model.playCommentState = 2;
                    [JAVoicePlayerManager shareInstance].commentModel.playState = 2;
                    [[JAVoicePlayerManager shareInstance] pause];
                } else if (cell.model.playCommentState == 2) {
                    cell.model.playCommentState = 1;
                    [JAVoicePlayerManager shareInstance].commentModel.playState = 1;
                    [[JAVoicePlayerManager shareInstance] contiunePlay];
                }
            }
        };
        // v2.6.0
        cell.atPersonBlock = ^(NSString *userName, NSArray *atList) {
            @StrongObj(self);
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
            [self.navigationController pushViewController:vc animated:YES];
        };
        return cell;
    }
}

// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有被@";
        NSString *st = @"";
        
        [self showBlankPageWithLocationY:53 title:t subTitle:st image:@"blank_notification" buttonTitle:nil selector:nil buttonShow:NO];
    }
}

#pragma mark - 2.6.0后这个作为主控制器后 添加这个类型(这个返回清空new标签数据)
- (void)actionLeft
{
    [super actionLeft];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"operation"] = @"atuser";
        NSArray *arr = [JANotiModel searchWithWhere:dic];
        for (JANotiModel *data in arr) {
            data.readState = YES;
            data.playState = 0;
            data.playReplyState = 0;
            data.playCommentState = 0;
            [data updateToDB];
        }
    });
}

//#pragma mark - inputView的代理方法
//- (void)inputViewFrameChangeWithHeight:(CGFloat)height
//{
//    CGFloat bottominset = height > 50  ? height : 0;
//    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, bottominset, self.tableView.contentInset.right);
//    if (self.frontIndex && self.frontIndex.row < self.dataSourceArray.count) {
//        [self.tableView scrollToRowAtIndexPath:self.frontIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
//    }
//}
//
//- (void)inputViewVoiceFileUploadFinishWithUrlString:(NSString *)fileUrlString
//                                           fileTime:(NSString *)timeString
//                                           fileText:(NSString *)text
//                                          soundWave:(NSMutableArray *)soundWaveArr
//                                            atArray:(NSArray *)atArray
//                                             result:(BOOL)result  // 音频文件上传完成
//                                         standbyObj:(id)standbyObj
//{
//
//    @WeakObj(self);
//
//    JANotiModel *model = self.needRefreshModel;//self.dataSourceArray[self.needRefreshIndex];
//
//    if ([model.content.type isEqualToString:@"story"]) {   // 评论
//
//        if (result) {
//            [self releaseCommentWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray finish:^{
//                @StrongObj(self);
//                // 重置数据
//                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
//            }];
//        }else{
//            [self.view ja_makeToast:@"文件上传失败"];
//        }
//
//    }else if ([model.content.type isEqualToString:@"reply"]) {     // (回复了评论 - 外层是回复 里层是评论)  回复回复
//
//        if (result) {
//            [self releaseReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray replyComment:NO finish:^{
//                @StrongObj(self);
//                // 重置数据
//                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
//            }];
//        }else{
//            [self.view ja_makeToast:@"文件上传失败"];
//        }
//    }else{                                          // （评论了故事 - 外层是评论 里层是故事） 回复评论
//        if (result) {
//            [self releaseReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray replyComment:YES finish:^{
//                @StrongObj(self);
//                // 重置数据
//
//                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
//            }];
//        }else{
//            [self.view ja_makeToast:@"文件上传失败"];
//        }
//
//    }
//}
//
////- (void)inputViewClickSelf:(JAInputView *)input   // 点击底部的输入框
////{
////}
//- (void)input_sensorsAnalyticsCancleRecordWithRecordDuration:(CGFloat)duration   // 重新录制
//{
//    //    NSMutableDictionary *params = [NSMutableDictionary new];
//    //    params[JA_Property_RecordDuration] = @((int)duration);
//    //    params[JA_Property_ContentType] = @"一级回复";
//    //    [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//
//    // 获取当前回复的model
//    if ([self.needRefreshModel.content.type isEqualToString:@"story"]) {
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_Rerecording] = @(YES);
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_AutoDialog] = @(NO);
//        params[JA_Property_ContentType] = @"一级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
//    }else{
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_Rerecording] = @(YES);
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_AutoDialog] = @(NO);
//        params[JA_Property_ContentType] = @"二级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
//    }
//
//
//}
//
//- (void)input_sensorsAnalyticsBeginRecord   // 开始录制
//{
//    if ([self.needRefreshModel.content.type isEqualToString:@"story"]) {
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_ContentType] = @"一级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
//    }else{
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_ContentType] = @"二级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
//    }
//
//}
//
//- (void)input_sensorsAnalyticsFinishRecordWithRecordDuration:(CGFloat)duration  // 完成录制
//{
//
//    if ([self.needRefreshModel.content.type isEqualToString:@"story"]) {
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_ContentType] = @"一级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//    }else{
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_ContentType] = @"二级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//    }
//
//}

//#pragma mark - 发布评论和回复
//// 评论
//- (void)releaseCommentWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList finish:(void(^)())finish
//{
//    JANotiModel *model = self.needRefreshModel;//self.dataSourceArray[self.needRefreshIndex];
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    params[@"categoryId"] = model.content.categoryId;
//    params[@"typeId"] = model.content.typeId;
//    params[@"type"] = JA_STORY_TYPE;
//    params[@"isAnonymous"] = self.inputView.anonymousStatus?@"1":nil;
//    params[@"content"] = text;// 声音描述
//    params[@"screenName"] = @"无法获取该属性";
//    params[@"recommendType"] = @"无法获取该属性";
//
//    if (audioUrl.length) {
//        params[@"audioUrl"] = audioUrl;
//        params[@"time"] = time;
//        params[@"sample"] = [JASampleHelper getSampleStringWithAllPeakLevelQueue:sample];
//        params[@"sampleZip"] = [JASampleHelper getSampleZipStringWithAllPeakLevelQueue:sample];
//    }
//
//    if (atList.count) {
//        params[@"atList"] = [@{@"atList":atList} mj_JSONString];
//    }
//
//    [MBProgressHUD showMessage:@"正在发布..."];
//    [[JAVoiceCommentApi shareInstance] voice_releaseCommentWithParas:params success:^(NSDictionary *result) {
//        [MBProgressHUD hideHUD];
//        [self.view ja_makeToast:@"回复成功" duration:1.0];
//        if (finish) {
//            finish();
//        }
//    } failure:^(NSError *error) {
//        [MBProgressHUD hideHUD];
//        [self.view ja_makeToast:error.localizedDescription];
//    }];
//}
//
//// 回复
//- (void)releaseReplyWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList replyComment:(BOOL)replyComment finish:(void(^)())finish
//{
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//
//    JANotiModel *model = self.needRefreshModel;//self.dataSourceArray[self.needRefreshIndex];
//
//    if (replyComment) {
//
//        params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
//        params[@"categoryId"] = model.content.categoryId;
//        params[@"storyId"] = model.content.storyId;
//        params[@"commentId"] = model.content.typeId;
//        params[@"replyUserid"] = model.content.userId;
//        params[@"type"] = JA_STORY_TYPE;
//        params[@"isAnonymous"] = self.inputView.anonymousStatus?@"1":nil;
//        params[@"content"] = text;// 声音描述
//    }else{
//
//        params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
//        params[@"categoryId"] = model.content.categoryId;
//        params[@"storyId"] = model.content.storyId;
//        params[@"commentId"] = model.content.subjoin.typeId;
//        params[@"replyUserid"] = model.content.userId;
//        params[@"type"] = JA_STORY_TYPE;
//        params[@"isAnonymous"] = self.inputView.anonymousStatus?@"1":nil;
//        params[@"replyId"] = model.content.typeId;
//        params[@"content"] = text;// 声音描述
//    }
//
//    if (audioUrl.length) {
//        params[@"audioUrl"] = audioUrl;
//        params[@"time"] = time;
//        params[@"sample"] = [JASampleHelper getSampleStringWithAllPeakLevelQueue:sample];
//        params[@"sampleZip"] = [JASampleHelper getSampleZipStringWithAllPeakLevelQueue:sample];
//    }
//
//    if (atList.count) {
//        params[@"atList"] = [@{@"atList":atList} mj_JSONString];
//    }
//    [MBProgressHUD showMessage:@"正在发布..."];
//    [[JAVoiceReplyApi shareInstance] voice_releaseReplyWithParas:params success:^(NSDictionary *result) {
//        [MBProgressHUD hideHUD];
//        [self.view ja_makeToast:@"回复成功" duration:1.0];
//        if (finish) {
//            finish();
//        }
//    } failure:^(NSError *error) {
//
//        [MBProgressHUD hideHUD];
//        [self.view ja_makeToast:error.localizedDescription];
//    }];
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//        [self.inputView registAllInput];
//        return;
//    }
//}

@end
