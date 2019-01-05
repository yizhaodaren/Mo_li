//
//  JAVoiceNotiReplyViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/12.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceNotiReplyViewController.h"

#import "JAVoiceReplyCell.h"
#import "JAPersonalCenterViewController.h"
#import "JAPostDetailViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceReplyDetailViewController.h"
#import "JANewNotiSubHeaderView.h"

#import "JAVoiceNotiAgreeViewController.h"
#import "JAVoiceNotiFocusViewController.h"
#import "JAVoiceNotiCallMeViewController.h"

#import "JAUserApiRequest.h"
#import "JAVoiceReplyApi.h"
#import "JASampleHelper.h"
#import "JADataHelper.h"
#import "JAVoicePlayerManager.h"
#import "JAPlayLocalVoiceManager.h"

#import "JANewReplyModel.h"
#import "JANewCommentModel.h"

#import "JAPublishNetRequest.h"

#define Kcount 20

@interface JAVoiceNotiReplyViewController ()<UITableViewDelegate, UITableViewDataSource,JAInputViewDelegate>

// 2.6.0 需求 添加头部↓↓↓↓↓↓↓↓↓↓↓↓↓
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) JANewNotiSubHeaderView *subHeaderView_callMe;  // @我
@property (nonatomic, weak) JANewNotiSubHeaderView *subHeaderView_likeMe;  // 喜欢我
@property (nonatomic, weak) JANewNotiSubHeaderView *subHeaderView_focusMe; // 关注我

@property (nonatomic, weak) UIView *lineView;
// 2.6.0 需求 添加头部↑↑↑↑↑↑↑↑↑↑↑↑↑↑

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;   // 数据源

@property (nonatomic, assign) NSInteger lastCount;   // 数据库分页标识

@property (nonatomic, strong) NSIndexPath *frontIndex;  // 前一个点击的cell

@property (nonatomic, strong) JANotiModel *needRefreshModel;  // 需要更新的model
// 发布用参数
@property (nonatomic, assign) BOOL anonymous;
@end

static NSString *VoiceReplyCellID = @"JAVoiceReplyCellID";


@implementation JAVoiceNotiReplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self setupHeaderView];
    [self getNoti:NO type:@"reply"];
    
    
    // 回复置为已读 2.6.0添加，现在一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeNoti_Reply];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiReplyArrive) name:@"Noti_Reply_Arrive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointArrive" object:nil];
    //2.6.0 添加红点消息的监听 -- 用来清空数字提醒  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointDismiss) name:@"redPointDismiss" object:nil];

    // 监听退出登录 清空数据源
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutResetData) name:@"app_loginOut" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessRefreshData) name:LOGINSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickCover_registKeyBoard) name:@"clickCover_regist" object:self.inputView];
}

- (void)clickCover_registKeyBoard
{
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self.inputView registAllInput];
    }
}

// 监听退出登录
- (void)loginOutResetData
{
    [self.dataSourceArray removeAllObjects];
    [self.tableView reloadData];
}

- (void)loginSuccessRefreshData
{
    [self getNoti:NO type:@"reply"];
}

- (void)notiReplyArrive
{
    // 刷新数据源
    NSDictionary *dic = @{@"operation" : @"reply"};
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

- (void)setupHeaderView
{
    NSArray *headArray = @[
                           @{@"image":@"branch_noti_at",@"name":@"@我"},
                           @{@"image":@"branch_noti_like",@"name":@"喜欢"},
                           @{@"image":@"branch_noti_focus",@"name":@"粉丝"},
                           ];
    
    NSInteger arrcount = headArray.count;
    CGFloat subViewHeight = 60;
    CGFloat lineHeight = 15; //line的高度
    
    UIView *headerView = [[UIView alloc] init];
    _headerView = headerView;
    headerView.width = JA_SCREEN_WIDTH;
    headerView.height = arrcount * subViewHeight + lineHeight;
    headerView.backgroundColor = [UIColor whiteColor];
    
    for (NSInteger i = 0; i < arrcount; i++) {
        
        NSDictionary *dic = headArray[i];
        
        JANewNotiSubHeaderView *subHead = [[JANewNotiSubHeaderView alloc] init];
        subHead.width = JA_SCREEN_WIDTH;
        subHead.height = subViewHeight;
        subHead.y = i * subHead.height;
        subHead.dicModel = dic;
        [headerView addSubview:subHead];
        
        if (i == 0) {
            self.subHeaderView_callMe = subHead;
            subHead.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeCallPerson];
        }else if (i == 1){
            self.subHeaderView_likeMe = subHead;
            subHead.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Agree];
        }else if (i == 2){
            self.subHeaderView_focusMe = subHead;
            self.subHeaderView_focusMe.lineView.hidden = YES;
            subHead.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Focus];
        }
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpNoti_page:)];
        [subHead addGestureRecognizer:tap];
    }
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xF4F4F4);
    lineView.width = JA_SCREEN_WIDTH;
    lineView.height = lineHeight;
    lineView.y = headerView.height - lineView.height;
    [headerView addSubview:lineView];
    
    self.tableView.tableHeaderView = headerView;
}

// 头部的点击事件  -- 跳转 @me 喜欢 粉丝 邀请
- (void)jumpNoti_page:(UITapGestureRecognizer *)tapG
{
    UIView *tapView = tapG.view;
    if (tapView == self.subHeaderView_callMe) {
        
        JAVoiceNotiCallMeViewController *vc = [[JAVoiceNotiCallMeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (tapView == self.subHeaderView_likeMe){
        
        JAVoiceNotiAgreeViewController *vc = [[JAVoiceNotiAgreeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if (tapView == self.subHeaderView_focusMe){
        
        JAVoiceNotiFocusViewController *vc = [[JAVoiceNotiFocusViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // 回复置为已读 2.6.0添加，现在一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeNoti_Reply];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];

     [[JAVoicePlayerManager shareInstance] beforeLocalPlayResetAll];
}

- (void)redPointArrive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 重置红点
        if ([self.view isDisplayedInScreen]) {   // 该回复在当前屏幕上 清除回复的通知红点
            [JARedPointManager resetNewRedPointArrive:JARedPointTypeNoti_Reply];
        }
        // 设置tableview的其他的红点
        self.subHeaderView_callMe.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeCallPerson];
        self.subHeaderView_likeMe.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Agree];
        self.subHeaderView_focusMe.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Focus];
    });
}

- (void)redPointDismiss
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 设置tableview的其他的红点
        self.subHeaderView_callMe.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeCallPerson];
        self.subHeaderView_likeMe.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Agree];
        self.subHeaderView_focusMe.unReadCount = [JARedPointManager getRedPointNumber:JARedPointTypeNoti_Focus];
    });
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI
{
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT - JA_StatusBarAndNavigationBarHeight - JA_TabbarHeight)];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[JAVoiceReplyCell class] forCellReuseIdentifier:VoiceReplyCellID];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getNoti:YES type:@"reply"];
    }];
    
    self.inputView = [[JAInputView alloc] init];
    self.inputView.width = JA_SCREEN_WIDTH;
    self.inputView.height = 50;
    self.inputView.y = self.view.height - ((iPhoneX) ? 34 : 0);
    self.inputView.inputInitial = JAInputInitialLocalTypeHiden;
    self.inputView.delegate = self;
    self.inputView.isAnonymous = NO;
    [self.view addSubview:self.inputView];
}

#pragma mark - inputView的代理方法
- (void)inputViewFrameChangeWithHeight:(CGFloat)height
{
    CGFloat bottominset = height > 50  ? height : 0;
    self.tableView.contentInset = UIEdgeInsetsMake(self.tableView.contentInset.top, self.tableView.contentInset.left, bottominset, self.tableView.contentInset.right);
    if (self.frontIndex && self.frontIndex.row < self.dataSourceArray.count) {
        [self.tableView scrollToRowAtIndexPath:self.frontIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)inputViewVoiceFileUploadFinishWithUrlString:(NSString *)fileUrlString
                                           fileTime:(NSString *)timeString
                                           fileText:(NSString *)text
                                          soundWave:(NSMutableArray *)soundWaveArr
                                            atArray:(NSArray *)atArray
                                             result:(BOOL)result  // 音频文件上传完成
                                         standbyObj:(id)standbyObj
{
    @WeakObj(self);
    JANotiModel *model = self.needRefreshModel;//self.dataSourceArray[self.needRefreshIndex];
    if ([model.content.type isEqualToString:@"reply"]) {     // (回复了评论 - 外层是回复 里层是评论)  回复回复
        if (result) {
            [self releaseReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray replyComment:NO finish:^{
                @StrongObj(self);
                // 重置数据
                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
            }];
        }else{
            [self.view ja_makeToast:@"文件上传失败"];
        }
    }else{                                          // （评论了故事 - 外层是评论 里层是故事） 回复评论
        if (result) {
            [self releaseReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray replyComment:YES finish:^{
                @StrongObj(self);
                // 重置数据
                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
            }];
        }else{
            [self.view ja_makeToast:@"文件上传失败"];
        }
    }
}

- (void)input_sensorsAnalyticsCancleRecordWithRecordDuration:(CGFloat)duration   // 重新录制
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[JA_Property_Rerecording] = @(YES);
    params[JA_Property_RecordDuration] = @((int)duration);
    params[JA_Property_AutoDialog] = @(NO);
    params[JA_Property_ContentType] = @"二级回复";
    [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
}

- (void)input_sensorsAnalyticsBeginRecord   // 开始录制
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[JA_Property_ContentType] = @"二级回复";
    [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
}

- (void)input_sensorsAnalyticsFinishRecordWithRecordDuration:(CGFloat)duration  // 完成录制
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[JA_Property_RecordDuration] = @((int)duration);
    params[JA_Property_ContentType] = @"二级回复";
    [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
}

// 获取评论的通知
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
    
    JAVoiceReplyCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.model = data;
    
    // 获取数据类型 - 跳转对应的界面
    if ([data.content.type isEqualToString:@"reply"]) { // 回复
        
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JANotiModel *model = self.dataSourceArray[indexPath.row];
    @WeakObj(self);
    JAVoiceReplyCell *cell = [tableView dequeueReusableCellWithIdentifier:VoiceReplyCellID];
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
    
    cell.jumpRecordBlock = ^(JAVoiceReplyCell *cell) {   // 回复

        @StrongObj(self);
        if (!IS_LOGIN) {
            [JAAPPManager app_modalLogin];
            return;
        }
        
        if ([JAAPPManager app_checkGag]) {
            return;
        }
        
        self.needRefreshModel = cell.model;
        
        if (self.inputView.isHasDraft) {  // 有音频数据  直接唤起键盘
            
            if (self.frontIndex != indexPath) { // 如果点击的是不同的cell
                NSString *name = [NSString stringWithFormat:@"回复@%@", cell.model.content.userName];
                [self.inputView resetInputOfDraftWithPlacrHolder:name];
            }
            
            self.frontIndex = indexPath;
            [self.inputView callInputOrRecordKeyBoard];
            
        }else{   // 没有音频数据 添加占位文字 并唤起键盘
            
            NSString *name = [NSString stringWithFormat:@"回复@%@", cell.model.content.userName];
            self.inputView.placeHolderText = name;
            self.frontIndex = indexPath;
            [self.inputView callInputOrRecordKeyBoard];
        }
        
        
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

#pragma mark - 发布回复
// 回复
- (void)releaseReplyWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList replyComment:(BOOL)replyComment finish:(void(^)())finish
{
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    JANotiModel *model = self.needRefreshModel;
    params[@"content"] = text;
    
    if (audioUrl.length) {
        params[@"audioUrl"] = audioUrl;
        params[@"time"] = time;
    }
    if (atList.count) {
        params[@"atList"] = [@{@"atList":atList} mj_JSONString];
    }
    if (replyComment) {
        params[@"typeId"] = model.content.storyId;
        params[@"type"] = JA_STORY_TYPE;
        [MBProgressHUD showMessage:@"正在发布..."];
        JAPublishNetRequest *r = [[JAPublishNetRequest alloc] initRequest_publishCommentWithParameter:params];
        [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
            [MBProgressHUD hideHUD];
            JANewCommentModel *model = (JANewCommentModel *)responseModel;
            if (model.code != 10000) {
                [self.view ja_makeToast:model.message duration:1.0];
                return;
            }
            [self.view ja_makeToast:@"回复成功" duration:1.0];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"personalCommentCountChange" object:nil];
            if (finish) {
                finish();
            }
            NSInteger comment = [JAUserInfo userInfo_getUserImfoWithKey:User_commentCount].integerValue;
            comment = comment + 1;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_commentCount value:[NSString stringWithFormat:@"%ld",comment]];
            
        } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
            [MBProgressHUD hideHUD];
        }];
    }else{
        params[@"commentId"] = model.content.subjoin.typeId;
        [MBProgressHUD showMessage:@"正在发布..."];
        JAPublishNetRequest *r = [[JAPublishNetRequest alloc] initRequest_publishReplyWithParameter:params];
        [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
            [MBProgressHUD hideHUD];
            JANewReplyModel *model = (JANewReplyModel *)responseModel;
            if (model.code != 10000) {
                [self.view ja_makeToast:model.message duration:1.0];
                return;
            }
            [self.view ja_makeToast:@"回复成功" duration:1.0];
            
            if (finish) {
                finish();
            }
            
        } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
            [MBProgressHUD hideHUD];
        }];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self.inputView registAllInput];
        return;
    }
}
// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有收到新回复";
        NSString *st = @"";
        [self showBlankPageWithLocationY:260 title:t subTitle:st image:@"blank_notification" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
    }
}

@end
