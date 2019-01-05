//
//  JAPostDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPostDetailViewController.h"
#import "JACommonCommentCell.h"
#import "JAReplyKeyBoardView.h"
#import "JAInputView.h"
#import "JACommonSectionView.h"
#import "JAStoryTableViewCell.h"
#import "JAPersonBlankCell.h"
#import "JAPostDetailNavBarView.h"
#import "JABottomShareView.h"

#import "JAStoryDetailNetRequest.h"
#import "JAPublishNetRequest.h"
#import "JAVoiceCommonApi.h"

#import "JANewVoiceModel.h"
#import "JANewCommentModel.h"

#import "JAVoiceReplyDetailViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JACircleDetailViewController.h"
#import "JAStoryPlayViewController.h"
#import "JAWebViewController.h"

#import "JADataHelper.h"
#import "JAStoryTableViewCell+BlockHelper.h"
#import "JAPlatformShareManager.h"
#import "JANewPlaySingleTool.h"
#import "JAPlayLocalVoiceManager.h"
#import "JANewPlayTool.h"
#import "JARichContentTableView.h"
#import "JAVoicePersonApi.h"
#import "JAPersonTopicViewController.h"

@interface JAPostDetailViewController ()<UITableViewDelegate, UITableViewDataSource, JAInputViewDelegate, PlatformShareDelegate, JAEmitterViewDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) JACommonSectionView *sectionView_one;
@property (nonatomic, strong) JACommonSectionView *sectionView_two;

// 评论列表参数
@property (nonatomic, strong) NSString *louzhuId;
@property (nonatomic, assign) NSInteger sort;
@property (nonatomic, assign) NSInteger orderType;

@property (nonatomic, strong) NSString *storyUserId;  // 评论界面 - 回复详情界面都需要的

// 控件
@property (nonatomic, weak) JAPostDetailNavBarView *navBarView;
@property (nonatomic, weak) JAReplyKeyBoardView *bottomView;  // 底部键盘
@property (nonatomic, weak) JAStoryTableViewCell *headView;    // 头部视图
@property (nonatomic, weak) JARichContentTableView *pictureHeadView;    // 头部视图
@property (nonatomic, strong) JAInputView *inputView;  // 键盘

// 数据源
@property (nonatomic, strong) NSMutableArray *dataSourceArray_total;
@property (nonatomic, strong) NSMutableArray *dataSourceArray_shen;
@property (nonatomic, strong) NSMutableArray *dataSourceArray_all;

// 网络请求页码
@property (nonatomic, assign) NSInteger currentPage;

// 发布回复
@property (nonatomic, strong) JANewCommentModel *needRefreshModel;  // 需要更新的model
@property (nonatomic, strong) NSIndexPath *frontIndex;  // 前一个点击的cell
@property (nonatomic, assign) BOOL replyPosts;  // YES 回复的是帖子   NO 回复的评论或者回复

// 蒙版
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

// 当前帖子
@property (nonatomic, strong) JANewVoiceModel *voiceModel;
// 分享 - 需要回调
@property (nonatomic, assign) BOOL needShareRequest;

// 点赞 -
@property (nonatomic, assign) BOOL lastAgreeState;// 0未点赞1已赞
@property (nonatomic, strong) NSString *agreeMethod;   // 神策数据（点赞方式）
@property (nonatomic, assign) NSTimeInterval frontTime;

// 发布完成后拿到的评论、回复数据（3.0版本以后开发）
@property (nonatomic, strong) NSIndexPath *scrollIndex; // 3.0版本后做带数据跳进该页面的时候有用
@property (nonatomic, strong) JANewCommentModel *release_commentModel;  // 发布成功后的数据模型
@property (nonatomic, strong) JANewReplyModel *release_replyModel;

// 3.1
@property (nonatomic, assign) CGPoint publishOffset;  // 发布时候的偏移量
@property (nonatomic, assign) BOOL scrollFinish;
@end

@implementation JAPostDetailViewController
- (BOOL)fd_interactivePopDisabled
{
    if (self.inputView.isRespondStatus) {
        return YES;
    }
    return NO;
}

- (BOOL)fd_prefersNavigationBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray_all = [NSMutableArray array];
    _dataSourceArray_total = [NSMutableArray array];
    _dataSourceArray_shen = [NSMutableArray array];
    
    [self setupPostDetailViewControllerUI];
    
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
//        [self request_getAllCommentList];
        self.jump_commentId = nil;
        [self requeset_getCommentListWithMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        if (self.scrollFinish) {
            self.scrollFinish = NO;
            [self.tableView.mj_footer endRefreshing];
            return;
        }
        [self requeset_getCommentListWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    // 请求帖子数据
    [self request_getStoryInfo];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adminDelVoice) name:@"AdminDelVoice" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshNav) name:@"STKAudioPlayer_status" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickCover_registKeyBoard) name:@"clickCover_regist" object:self.inputView];
}

- (void)clickCover_registKeyBoard
{
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self registKeyBoard];
    }
}

- (void)playStatus_refreshNav
{
    [self.navBarView circleDetailNavBarView_changePointButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   [self.navBarView circleDetailNavBarView_changePointButtonToEdge:[AppDelegate sharedInstance].playerView.hidden];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
}


#pragma mark - 通知的监听
- (void)adminDelVoice
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - 界面刷新
- (void)postDetail_refreshViewWithId:(NSString *)storyId
{
    if ([self.voiceId isEqualToString:storyId]) {
        return;
    }
    self.voiceId = storyId;
    // 请求帖子数据
    [self request_getStoryInfo];
}

#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *arr = self.dataSourceArray_total[indexPath.section];
    if (arr.count == 0) {
        return;
    }
    
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_BindingType] = @"回复";
        [JASensorsAnalyticsManager sensorsAnalytics_jumpRegistOrLoginPage:dic];
        return;
    }
    
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self registKeyBoard];
        return;
    }
    // 获取数据
    JANewCommentModel *model = arr[indexPath.row];
    self.needRefreshModel = model;  // 需要回复的model
    
    if (self.inputView.isHasDraft) {  // 有音频数据或者文字  直接唤起键盘

        if (self.frontIndex != indexPath || self.replyPosts == YES) { // 如果点击的是不同的cell 或者之前是回复的帖子
            NSString *name = [NSString stringWithFormat:@"回复@%@", model.user.userName];
            [self.inputView resetInputOfDraftWithPlacrHolder:name];
        }

        self.frontIndex = indexPath;
        [self.inputView callInputOrRecordKeyBoard];

    }else{   // 没有音频数据或者文字 添加占位文字 并唤起键盘

        NSString *name = [NSString stringWithFormat:@"回复@%@", model.user.userName];
        self.inputView.placeHolderText = name;
        self.frontIndex = indexPath;
        [self.inputView callInputOrRecordKeyBoard];
    }

    self.replyPosts = NO;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return self.dataSourceArray_total.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataSourceArray_total[section];
    
    if (arr == self.dataSourceArray_all && self.dataSourceArray_all.count == 0) {
        return 1;
    }else{
        return arr.count;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = self.dataSourceArray_total[indexPath.section];
    if (arr == self.dataSourceArray_all && self.dataSourceArray_all.count == 0) {
        return 300;
    }else{
        JANewCommentModel *model = arr[indexPath.row];
        model.storyUserId = self.storyUserId;
        model.sourcePageName = self.sourcePageName;
        model.sourcePage = self.sourcePage;
        return model.cellHeight;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableArray *arr = self.dataSourceArray_total[indexPath.section];
    if (!self.dataSourceArray_all.count && arr == self.dataSourceArray_all) {
        
        JAPersonBlankCell *cell = [[JAPersonBlankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.requestStatus = 1;
        return cell;
    }
    JACommonCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JACommonCommentCell_commentId"];
    cell.comment_Model = arr[indexPath.row];
    
    // 跳转回复详情
    @WeakObj(self);
    cell.jumpPersonalViewControlBlock = ^(JACommonCommentCell *cell) {    // 个人主页
        @StrongObj(self);
        if (cell.comment_Model.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return;
        }
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.comment_Model.user.userId;
        model.name = cell.comment_Model.user.userName;
        model.image = cell.comment_Model.user.avatar;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.jumpReplyViewControlBlock = ^(JACommonCommentCell *cell) {    // 回复详情
        @StrongObj(self);
        
        // 有音频或者文字就先移除
        if (self.inputView.isHasDraft) {
            [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
        }
        
        [self registKeyBoard];
        
        JAVoiceReplyDetailViewController *vc = [[JAVoiceReplyDetailViewController alloc] init];
        vc.sourcePageName = self.sourcePageName;
        vc.sourcePage = self.sourcePage;
        vc.voiceId = self.voiceId;
        vc.voiceCommentId = cell.comment_Model.commentId;
        vc.storyUserId = self.storyUserId;
        vc.refreshCommentAgreeStatus = ^(BOOL agreeStatus) {
            cell.likeButton.selected = agreeStatus;
            if (agreeStatus) {
                cell.lastAgreeState = agreeStatus;
                cell.comment_Model.agreeCount = [NSString stringWithFormat:@"%ld",cell.comment_Model.agreeCount.integerValue + 1];
                [cell.likeButton setTitle:cell.comment_Model.agreeCount forState:UIControlStateNormal];
            }else{
                cell.lastAgreeState = agreeStatus;
                cell.comment_Model.agreeCount = [NSString stringWithFormat:@"%ld",cell.comment_Model.agreeCount.integerValue - 1];
                [cell.likeButton setTitle:cell.comment_Model.agreeCount forState:UIControlStateNormal];
            }
        };
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.pointClickBlock = ^(JACommonCommentCell *cell) {    // 点击三个点
        @StrongObj(self);

        if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
            [self registKeyBoard];
        }
        [JADetailClickManager detail_modalChooseWindowWithComment:cell.comment_Model standbyParameter:nil needBlock:^(NSInteger actionType) {
            if (actionType == 1) {   // 加神
                cell.comment_Model.sort = @"1";
            }else if (actionType == 2){   // 取消神回
                cell.comment_Model.sort = @"0";
            }else if (actionType == 3){  // 隐藏
                
            }else if (actionType == 5){  // 删除
                if ([self.dataSourceArray_shen containsObject:cell.comment_Model]) {
                    [self.dataSourceArray_shen removeObject:cell.comment_Model];
                }
                
                if ([self.dataSourceArray_all containsObject:cell.comment_Model]) {
                    [self.dataSourceArray_all removeObject:cell.comment_Model];
                }
                [self.tableView reloadData];
                
                if (self.refreshCommentCount) {
                    self.refreshCommentCount(YES);
                }
            }
        }];
        
    };
    
    // v2.6.0
    cell.commentAtPersonBlock = ^(NSString *userName, NSArray *atList) {
        @StrongObj(self);
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    // 播放评论
    cell.playCommentBlock = ^(JACommonCommentCell *cell) {
        [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_playSingleMusicWithFileUrlString:cell.comment_Model.audioUrl model:cell.comment_Model playType:JANewPlaySingleToolType_comment];
    };
    
    // v3.1
    cell.goBackBrowseLocation = ^{
        @StrongObj(self);
        // 滚回位置 移除带按钮的cell
        self.scrollFinish = NO;
        NSMutableArray *arr = [NSMutableArray array];
        [self.dataSourceArray_all enumerateObjectsUsingBlock:^(JANewCommentModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.needActionButton == 1) {
                [arr addObject:obj];
            }
        }];
        [self.dataSourceArray_all removeObjectsInArray:arr];
        [self.tableView reloadData];
        self.tableView.contentOffset = self.publishOffset;
    };
    
    cell.goBackBeginLocation = ^{
        @StrongObj(self);
        self.jump_commentId = nil;
        [self requeset_getCommentListWithMore:NO];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *arr = self.dataSourceArray_total[section];
    if (arr == self.dataSourceArray_shen) {
        
        return self.sectionView_one;
    }else{
        return self.sectionView_two;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSArray *arr = self.dataSourceArray_total[section];
    if (arr == self.dataSourceArray_shen) {
        UIView *v = [UIView new];
        v.backgroundColor = HEX_COLOR(0xf4f4f4);
        v.height = 10;
        v.width = JA_SCREEN_WIDTH;
        return v;
    }else{
        
        return [UIView new];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSArray *arr = self.dataSourceArray_total[section];
    if (arr == self.dataSourceArray_shen) {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, -20, 0);
        return 10;
    }else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        return 0.01;
    }
}

#pragma mark - scrollDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.scrollFinish = NO;
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self registKeyBoard];
        return;
    }
}

- (void)registKeyBoard
{
    [self.inputView registAllInput];
    
    if (self.inputView.isHasVoice) {
        [self.bottomView.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordRed"] forState:UIControlStateNormal];

    }else{
        [self.bottomView.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateNormal];

    }
    [self.bottomView.textButton setTitle:self.inputView.inputText forState:UIControlStateNormal];
}

#pragma mark - 网络请求
- (void)request_getStoryInfo
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    // 帖子信息
    JAStoryDetailNetRequest *r = [[JAStoryDetailNetRequest alloc] initRequest_storyInfoWithParameter:nil storyId:self.voiceId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        if (responseModel.code == 140021) {
            [self showBlankPageWithLocationY:64 title:@"该内容已经被删除啦！" subTitle:@"" image:@"blank_delete" buttonTitle:nil selector:nil buttonShow:NO];
            return;
        }else if (responseModel.code != 10000) {
            
            [self showBlankPageWithLocationY:64 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            return;
        }
        
        self.voiceModel = (JANewVoiceModel *)responseModel;
        self.voiceModel.sourcePage = self.sourcePage;
        self.voiceModel.sourcePageName = self.sourcePageName;
        
        self.storyUserId = self.voiceModel.user.userId;
        
        // 展示导航
        if (self.enterType != 1) {        
            self.navBarView.circleModel = self.voiceModel.circle;
        }

        // 展示头部
        // tableViewHead
        self.tableView.tableHeaderView = [self getHeaderView];
        // 底部点赞按钮
        self.bottomView.likeButton.selected = self.voiceModel.isAgree;
        self.lastAgreeState = self.voiceModel.isAgree;
        // 请求评论列表
        [self request_getAllCommentList];
        
        // 神策统计
        NSArray *timeArr = [self.voiceModel.time componentsSeparatedByString:@":"];
        NSString *min = timeArr.firstObject;
        NSString *sec = timeArr.lastObject;
        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_ContentId] = self.voiceModel.storyId;
        senDic[JA_Property_ContentTitle] = self.voiceModel.content;
        senDic[JA_Property_Anonymous] = @(self.voiceModel.user.isAnonymous);
        senDic[JA_Property_RecordDuration] = @(sen_time);
        senDic[JA_Property_PostId] = self.voiceModel.user.userId;
        senDic[JA_Property_PostName] = self.voiceModel.user.userName;
        senDic[JA_Property_storyType] = self.voiceModel.concernType.integerValue == 0 ? @"语音":@"图文";
        if (self.sourcePage.length) {
            senDic[JA_Property_SourcePage] = self.sourcePage;
        }
        if (self.sourcePageName.length) {
            senDic[JA_Property_SourcePageName] = self.sourcePageName;
        }
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewControllerDetail:senDic];

        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        [self showBlankPageWithLocationY:64 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRequestStoryInfo) buttonShow:YES];
    }];
}

- (void)againRequestStoryInfo
{
    [self request_getStoryInfo];
}

/// 请求评论列表 - 神回复列表
- (void)request_getAllCommentList
{
    
    self.currentPage = 1;
    // 神回复
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(1);
    dic[@"pageSize"] = @(10);
    dic[@"sort"] = @(1);
    dic[@"orderType"] = @(0);
    JAStoryDetailNetRequest *r = [[JAStoryDetailNetRequest alloc] initRequest_commentListWithParameter:dic storyId:self.voiceId];
    
    // 评论列表
    NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
    dic1[@"pageNum"] = @(1);
    dic1[@"pageSize"] = @(6);
    dic1[@"sort"] = @(0);
    dic1[@"orderType"] = @(0);
    if (self.jump_commentId.length) {
        dic1[@"commentId"] = self.jump_commentId;
    }
    JAStoryDetailNetRequest *r1 = [[JAStoryDetailNetRequest alloc] initRequest_commentListWithParameter:dic1 storyId:self.voiceId];
    
    YTKBatchRequest *batchRequest = [[YTKBatchRequest alloc] initWithRequestArray:@[r,r1]];
    [batchRequest startWithCompletionBlockWithSuccess:^(YTKBatchRequest * _Nonnull batchRequest) {
        NSArray *requests = batchRequest.requestArray;
        JAStoryDetailNetRequest *a = (JAStoryDetailNetRequest *)requests[0];
        JAStoryDetailNetRequest *b = (JAStoryDetailNetRequest *)requests[1];

        [self.currentProgressHUD hideAnimated:NO];
        

        if ([a.responseObject[@"code"] integerValue] != 10000 || [b.responseObject[@"code"] integerValue] != 10000 ) {
            // 计算高度
            [self showBlankPageWithLocationY:64 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            return;
        }
        
        NSLog(@"%@ - %@",a,a.responseObject);
        NSLog(@"%@ - %@",b,b.responseObject);

        [self removeBlankPage];
        [self.dataSourceArray_total removeAllObjects];
        
        // 解析数据
        self.dataSourceArray_shen = [JANewCommentModel mj_objectArrayWithKeyValuesArray:a.responseObject[@"resBody"]];
        self.dataSourceArray_all = [JANewCommentModel mj_objectArrayWithKeyValuesArray:b.responseObject[@"resBody"]];
        
        if (self.dataSourceArray_shen.count) {
            [self.dataSourceArray_total addObject:self.dataSourceArray_shen];
        }
        
        [self.dataSourceArray_total addObject:self.dataSourceArray_all];
        [self getJumpComment:self.dataSourceArray_all];
        
        if (self.dataSourceArray_all.count >= [b.responseObject[@"total"] integerValue]) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
        if (self.jump_commentId.length) {
            NSInteger section = 0;
            if (self.dataSourceArray_total.count > 1) {
                section = 1;
            }
            NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:section];
            [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionNone animated:NO];
        }

    } failure:^(YTKBatchRequest * _Nonnull batchRequest) {
        [self.currentProgressHUD hideAnimated:NO];
        [self showBlankPageWithLocationY:64 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRequestStoryDetai) buttonShow:YES];
    }];
}

- (void)againRequestStoryDetai
{
    [self request_getAllCommentList];
}

// 获取评论列表
- (void)requeset_getCommentListWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"orderType"] = @(self.orderType);  // 排序  0升序  1降序
    if (self.louzhuId.length) {
        dic[@"toUserId"] = self.louzhuId;
    }
    dic[@"pageSize"] = @"6";
    
    dic[@"sort"] = @(0);
    dic[@"pageNum"] = @(self.currentPage);
    if (self.jump_commentId.length) {
        dic[@"commentId"] = self.jump_commentId;
    }
    
    JAStoryDetailNetRequest *r = [[JAStoryDetailNetRequest alloc] initRequest_commentListWithParameter:dic storyId:self.voiceId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JANewCommentGroupModel *model = (JANewCommentGroupModel *)responseModel;
        
        if (model.code != 10000) {
            if (!self.dataSourceArray_all.count) {
                [self showBlankPageWithLocationY:64 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            }
            return;
        }
        
        [self removeBlankPage];
        if (!isMore) {
            [self.dataSourceArray_all removeAllObjects];
        }
        
        NSMutableArray *arr = [NSMutableArray array];
        [self.dataSourceArray_all enumerateObjectsUsingBlock:^(JANewCommentModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.needActionButton == 1) {
                [arr addObject:obj];
            }
        }];
        [self.dataSourceArray_all removeObjectsInArray:arr];
        
        // 添加数据
        [self.dataSourceArray_all addObjectsFromArray:model.resBody];
        [self getJumpComment:self.dataSourceArray_all];
        
        if (self.dataSourceArray_all.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
    }];
    
}

// 寻找跳转的评论model
- (void)getJumpComment:(NSArray *)modelArray
{
    for (NSInteger i = 0; i < modelArray.count; i++) {
        JANewCommentModel *model = modelArray[i];
        if ([model.commentId isEqualToString:self.jump_commentId]) {
            model.needActionButton = 2;
            break;
        }
    }
}

// 点赞
- (void)request_likeStory
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"actionType"] = @"agree";
    dic[@"typeId"] = self.voiceModel.storyId;
    dic[@"type"] = @"story";
    
    [[JAVoiceCommonApi shareInstance] voice_agreeWithParas:dic success:^(NSDictionary *result) {
        NSLog(@"%@",result);
    } failure:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

#pragma mark - 发布评论
- (void)request_postCommentWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList finish:(void(^)())finish
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"typeId"] = self.voiceModel.storyId;
    params[@"type"] = JA_STORY_TYPE;
    params[@"content"] = text;// 声音描述
    if (audioUrl.length) {
        params[@"audioUrl"] = audioUrl;
        params[@"time"] = time;
    }
    if (atList.count) {
        params[@"atList"] = [@{@"atList":atList} mj_JSONString];
    }
    
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
        self.release_commentModel = model;
        if (finish) {
            finish();
        }
        NSInteger comment = [JAUserInfo userInfo_getUserImfoWithKey:User_commentCount].integerValue;
        comment = comment + 1;
        [JAUserInfo userInfo_updataUserInfoWithKey:User_commentCount value:[NSString stringWithFormat:@"%ld",comment]];
        
        if (self.refreshCommentCount) {
            self.refreshCommentCount(NO);
        }

    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [MBProgressHUD hideHUD];
    }];
}

#pragma mark - 发布回复
- (void)request_postReplyWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList finish:(void(^)())finish
{
    JANewCommentModel *model = self.needRefreshModel;
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"commentId"] = model.commentId;
    dic[@"content"] = text;
    if (audioUrl.length) {
        dic[@"audioUrl"] = audioUrl;
        dic[@"time"] = time;
    }
    if (atList.count) {
        dic[@"atList"] = [@{@"atList":atList} mj_JSONString];
    }
    
    if (self.sourcePage.length) {
        dic[@"sourcePage"] = self.sourcePage;
    }
    if (self.sourcePageName.length) {    
        dic[@"sourcePageName"] = self.sourcePageName;
    }
    
    [MBProgressHUD showMessage:@"正在发布..."];
    JAPublishNetRequest *r = [[JAPublishNetRequest alloc] initRequest_publishReplyWithParameter:dic];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [MBProgressHUD hideHUD];
        JANewReplyModel *model = (JANewReplyModel *)responseModel;
        if (model.code != 10000) {
            [self.view ja_makeToast:model.message duration:1.0];
            return;
        }
        [self.view ja_makeToast:@"回复成功" duration:1.0];
        self.release_replyModel = model;
        if (finish) {
            finish();
        }
        
        if (self.refreshCommentCount) {
            self.refreshCommentCount(NO);
        }
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [MBProgressHUD hideHUD];
    }];
}

#pragma mark - 发布成功后拿到的数据
- (void)setRelease_commentModel:(JANewCommentModel *)release_commentModel
{
    self.publishOffset = self.tableView.contentOffset;
    _release_commentModel = release_commentModel;
    if (self.louzhuId) {
        NSString *userId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        if ([userId isEqualToString:self.louzhuId]) {
            if (self.orderType) {  // 1 倒序
                // 插入到第一行
                [self.dataSourceArray_all insertObject:release_commentModel atIndex:0];
                [self.tableView reloadData];
                NSInteger section = 0;
                if (self.dataSourceArray_total.count > 1) {
                    section = 1;
                }
                NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:section];
                [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionNone animated:YES];
            }else{                 // 0 正序
                // 在最后一页的时候插入
                if (self.tableView.mj_footer.hidden) {
                    [self.dataSourceArray_all addObject:release_commentModel];
                    [self.tableView reloadData];
                }else{
                    release_commentModel.needActionButton = 1;
                    [self.dataSourceArray_all addObject:release_commentModel];
                    [self.tableView reloadData];
                }
                NSInteger section = 0;
                if (self.dataSourceArray_total.count > 1) {
                    section = 1;
                }
                self.scrollFinish = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    NSIndexPath *indexP = [NSIndexPath indexPathForRow:(self.dataSourceArray_all.count - 1) inSection:section];
                    [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                });
            }
        }
        return;
    }
    
    if (self.orderType) {  // 1 倒序
        // 插入到第一行
        [self.dataSourceArray_all insertObject:release_commentModel atIndex:0];
        [self.tableView reloadData];
        NSInteger section = 0;
        if (self.dataSourceArray_total.count > 1) {
            section = 1;
        }
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:0 inSection:section];
        [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }else{                 // 0 正序
        // 在最后一页的时候插入
        if (self.tableView.mj_footer.hidden) {
            [self.dataSourceArray_all addObject:release_commentModel];
            [self.tableView reloadData];
        }else{
            release_commentModel.needActionButton = 1;
            [self.dataSourceArray_all addObject:release_commentModel];
            [self.tableView reloadData];
        }
        NSInteger section = 0;
        if (self.dataSourceArray_total.count > 1) {
            section = 1;
        }
        self.scrollFinish = YES;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSIndexPath *indexP = [NSIndexPath indexPathForRow:(self.dataSourceArray_all.count - 1) inSection:section];
            [self.tableView scrollToRowAtIndexPath:indexP atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)setRelease_replyModel:(JANewReplyModel *)release_replyModel
{
    _release_replyModel = release_replyModel;
    
    // 获取当前需要刷新的模型
    JANewCommentModel *model = self.needRefreshModel;
    
    if (model.replyList.count == 0) {
        
        // 2.3.0 重写评论cell 添加的属性
        model.refreshModelHeight = YES;  // 刷新高度
        model.replyList = @[release_replyModel];
        
        model.replyCount = [NSString stringWithFormat:@"%ld",model.replyCount.integerValue + 1];
        
        [self.tableView reloadData];
    }
}

#pragma mark - 完成分享任务
- (void)shareRequestWithNeedTask:(BOOL)isNeedTask methodType:(NSInteger)type //type 完成任务弹双倍时的类型 0 不需要完成任务 1 微信完成任务 2 QQ完成任务 // 分享接口
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"dataType"] = @"story";
    dic[@"type"] = @"share";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"typeId"] = self.voiceModel.storyId;
    if (self.channelId.length && isNeedTask) {
        dic[@"categoryTypeId"] = self.channelId;
        [JAConfigManager shareInstance].doubleFloatType = type;
    }
    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:^(NSDictionary *result) {
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 分享回调
- (void)wxShare:(int)code
{
    if (self.needShareRequest == NO) {
        return;
    }
    self.needShareRequest = NO;
    if (code == 0) {
        [self shareRequestWithNeedTask:YES methodType:1];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else if (code == -1) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信未识别的错误类型，请重试"];
    }else if (code == -2) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -3) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -4) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -5) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信不支持"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)qqShare:(NSString *)error
{
    if (self.needShareRequest == NO) {
        return;
    }
    self.needShareRequest = NO;
    if (error == nil) {
        [self shareRequestWithNeedTask:YES methodType:2];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wbShare:(int)code
{
    if (self.needShareRequest == NO) {
        return;
    }
    self.needShareRequest = NO;
    if (code == 0) {
        [self shareRequestWithNeedTask:NO methodType:0];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else if (code == -1){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -2){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -3){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -8){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }else if (code == -99){
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请求无效"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

#pragma mark - 按钮的点击
// 关注取消人
- (void)focusCustomer:(UIButton *)focusButton userModel:(JALightUserModel *)userModel
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    focusButton.userInteractionEnabled = NO;
    if (focusButton.selected) {
        
        // 取消关注
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = userModel.userId;
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_BindingType] = @"取消关注";
        senDic[JA_Property_PostId] = userModel.userId;
        senDic[JA_Property_PostName] = userModel.userName;
        senDic[JA_Property_FollowMethod] = @"帖子详情页";
        [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
        
        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
            
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            userModel.friendType = type;
            focusButton.userInteractionEnabled = YES;
            focusButton.selected = NO;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = userModel.userId;
            dic[@"status"] = type;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
            
        } failure:^(NSError *error) {
            focusButton.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = userModel.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = userModel.userId;
    senDic[JA_Property_PostName] = userModel.userName;
    senDic[JA_Property_FollowMethod] = @"帖子详情页";
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        userModel.friendType = type;
        focusButton.userInteractionEnabled = YES;
        focusButton.selected = YES;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = userModel.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        focusButton.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

- (void)clickSortButton:(UIButton *)button   // 排序
{
    self.jump_commentId = nil;
    button.selected = !button.selected;
    if (button.selected) {
        [button setTitle:@"时间倒序" forState:UIControlStateNormal];
    }else{
        [button setTitle:@"时间正序" forState:UIControlStateNormal];
    }
    
    self.orderType = button.selected ? 1 : 0;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestWithSort) object:self];
    
    [self performSelector:@selector(requestWithSort) withObject:self afterDelay:0.3];
}

- (void)requestWithSort
{
    [self requeset_getCommentListWithMore:NO];
}

- (void)clickMyPostCommentButton:(UIButton *)button  // 查看楼主
{
    self.jump_commentId = nil;
    self.sectionView_two.leftButton.selected = NO;
    self.sectionView_two.leftView.hidden = YES;
    button.selected = YES;
    if (button.selected) {
        self.louzhuId = self.storyUserId;
    }
    self.sectionView_two.middleView.hidden = NO;
    
    [self requeset_getCommentListWithMore:NO];
}

- (void)clickAllCommentButton:(UIButton *)button  // 全部回复
{
    self.jump_commentId = nil;
    self.sectionView_two.middleButton.selected = NO;
    self.sectionView_two.middleView.hidden = YES;
    button.selected = YES;
    if (button.selected) {
        self.louzhuId = nil;
    }
    self.sectionView_two.leftView.hidden = NO;
    
    [self requeset_getCommentListWithMore:NO];
}

- (void)clickWhyButton:(UIButton *)button   // 点击什么是神回复
{
    JAWebViewController *webvc = [[JAWebViewController alloc] init];
    webvc.urlString = @"http://activity.urmoli.com/views/app/about/hotReplyRule.html";
    [self.navigationController pushViewController:webvc animated:YES];
}

- (void)callRecordKeyBoard:(UIButton *)button  // 唤起录音键盘
{
    if ([JAAPPManager app_checkGag]) {
        return;
    }
    // 判断是否有要回复的人
    if (!self.inputView.isHasDraft) {  // 没有要回复的数据
        self.frontIndex = nil;
        self.replyPosts = YES;
        self.inputView.placeHolderText = @"请输入回复内容";
    }
    [self.inputView callRecordKeyBoard];
}

- (void)calltextKeyBoard:(UIButton *)button  // 唤起文字键盘
{
    if ([JAAPPManager app_checkGag]) {
        return;
    }
    // 判断是否有要回复的人
    if (!self.inputView.isHasDraft) {  // 没有要回复的数据
        self.frontIndex = nil;
        self.replyPosts = YES;
        self.inputView.placeHolderText = @"请输入回复内容";
    }
    [self.inputView callInputKeyBoard];
}

- (void)clickShareVoiceButton:(UIButton *)button  // 点击分享帖子
{
    if (!self.voiceModel.storyId.length) {
        [self.view ja_makeToast:@"帖子信息获取失败"];
        return;
    }
    
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self registKeyBoard];
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    appDelegate.shareDelegate = self;
    
    JABottomShareView *shareView = [[JABottomShareView alloc] initWithShareType:JABottomShareViewTypeOneLine contentType:JABottomShareOneContentTypeNormal twoContentType:JABottomShareTwoContentTypeNormal];
    @WeakObj(self);
    shareView.bottomShareClickButton = ^(JABottomShareClickType clickType, BOOL select, UIButton *button) {
        @StrongObj(self);
        if (clickType == JABottomShareClickTypeWX) {
            self.needShareRequest = NO;
            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"微信聊天"];
            [self shareRequestWithNeedTask:NO methodType:0];
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.voiceModel.shareMsg.shareWxContent;
            model.descripe = self.voiceModel.shareMsg.shareTitle;
            model.shareUrl = self.voiceModel.shareMsg.shareUrl;
            model.image = self.voiceModel.shareMsg.shareImg;
            model.music = self.voiceModel.audioUrl;
            [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:0];
        }else if (clickType == JABottomShareClickTypeWXSession){
            self.needShareRequest = YES;
            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"朋友圈"];
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.voiceModel.shareMsg.shareWxContent;
            model.shareUrl = self.voiceModel.shareMsg.shareUrl;
            model.image = self.voiceModel.shareMsg.shareImg;
            model.music = self.voiceModel.audioUrl;
            [JAPlatformShareManager wxShareMusic:WeiXinShareTypeSession shareContent:model];
        }else if (clickType == JABottomShareClickTypeQQ){
            self.needShareRequest = NO;
            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"qq"];
            [self shareRequestWithNeedTask:NO methodType:0];
            JAShareModel *model = [JAShareModel new];
            model.title = self.voiceModel.shareMsg.shareWxContent;
            model.descripe = self.voiceModel.shareMsg.shareTitle;
            model.shareUrl = self.voiceModel.shareMsg.shareUrl;
            model.image = self.voiceModel.shareMsg.shareImg;
            model.music = self.voiceModel.audioUrl;
            [JAPlatformShareManager qqShareMusic:QQShareTypeFriend shareContent:model domainType:0];
            
        }else if (clickType == JABottomShareClickTypeQQZone){
            self.needShareRequest = YES;
            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"qq空间"];
            JAShareModel *model = [JAShareModel new];
            model.title = self.voiceModel.shareMsg.shareWxContent;
            model.descripe = self.voiceModel.shareMsg.shareTitle;
            model.shareUrl = self.voiceModel.shareMsg.shareUrl;
            model.image = self.voiceModel.shareMsg.shareImg;
            model.music = self.voiceModel.audioUrl;
            [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:0];
            
        }else if (clickType == JABottomShareClickTypeWB){
            self.needShareRequest = YES;
            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"微博"];
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.voiceModel.shareMsg.shareWBContent;
            model.shareUrl = self.voiceModel.shareMsg.shareUrl;
            model.image = self.voiceModel.shareMsg.shareImg;
            [JAPlatformShareManager wbShareWithshareContent:model domainType:0];
        }
        
    };
    [shareView showBottomShareView];
}

// 点击导航条的返回
- (void)clickBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 点击导航条的三个点
- (void)clickInfoButton
{
    if (!self.voiceModel.storyId.length) {
        return;
    }
    [JADetailClickManager detail_modalChooseWindowWithStory:self.voiceModel standbyParameter:nil needBlock:^(NSInteger actionType) {
        
        if (actionType == 1) {  // 置顶
            self.voiceModel.circleTop = YES;
        }else if (actionType == 2) {  // 取消置顶
            self.voiceModel.circleTop = NO;
        }else if (actionType == 3){ // 加精华
            self.voiceModel.essence = YES;
        }else if (actionType == 4){ // 取消加精华
            self.voiceModel.essence = NO;
        }else if (actionType == 5){ // 收藏
            self.voiceModel.userCollect = YES;
        }else if (actionType == 6){ // 取消收藏
            self.voiceModel.userCollect = NO;
        }else if (actionType == 7){ // 不感兴趣
            
        }else if (actionType == 9){ // 删除
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

// 点击导航条的去圈子
- (void)gotoCircle
{
    JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
    vc.circleId = self.voiceModel.circle.circleId;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 点赞的代理方法
- (void)emitterViewClickSingle:(JAEmitterView *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    if (button.selected) {
        if ([self checkTimeMargin]) {
            [self clickAgree:button];
        }
    }else{
        [self clickAgree:button];
    }
}

// 判断时间间隔是否大于0.3
- (BOOL)checkTimeMargin
{
    NSTimeInterval interval = [[NSDate date] timeIntervalSince1970] * 1000;
    if (interval - self.frontTime > 1300) {
        self.frontTime = interval;
        return YES;
    }
    self.frontTime = interval;
    return NO;
}

- (void)emitterViewClickLongSingle:(JAEmitterView *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    if (!button.selected) {
        [self clickAgree:button];
    }
}

// 点赞
- (void)clickAgree:(JAEmitterView *)sender
{
    sender.selected = !sender.selected;
    
    if (self.refreshAgreeStatus) {
        self.refreshAgreeStatus(sender.selected);
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(myDelayedMethod) object:self];
    [self performSelector:@selector(myDelayedMethod) withObject:self afterDelay:0.3];
}

- (void)myDelayedMethod
{
    
    if (self.bottomView.likeButton.selected != self.lastAgreeState) {
        self.lastAgreeState = self.bottomView.likeButton.selected;
        self.voiceModel.isAgree = self.lastAgreeState;
        if (self.voiceModel.isAgree) {
            self.voiceModel.agreeCount = [NSString stringWithFormat:@"%ld",self.voiceModel.agreeCount.integerValue + 1];
        }else{
            NSInteger count = self.voiceModel.agreeCount.integerValue - 1 > 0 ? (self.voiceModel.agreeCount.integerValue - 1) : 0;
            self.voiceModel.agreeCount = [NSString stringWithFormat:@"%ld",count];
        }
        if (self.headView) {
            self.headView.data = self.voiceModel;
        }else if(self.pictureHeadView){
            self.pictureHeadView.refreshModel = self.voiceModel;
        }
        [self request_likeStory];
        // 神策数据
        if (self.bottomView.likeButton.selected) {
            self.agreeMethod = @"点击按钮喜欢";
            [self sensorsAnalyticsWithLikeType:JA_STORY_TYPE model:self.voiceModel method:self.agreeMethod];
        }
    }
}

#pragma mark - inputDelegate
- (void)inputViewFrameChangeWithHeight:(CGFloat)height   // 获取键盘的高高度
{
    if (self.frontIndex) {
        NSArray *arr = self.dataSourceArray_total[self.frontIndex.section];
        if (self.frontIndex.row < arr.count) {
            [self.tableView scrollToRowAtIndexPath:self.frontIndex atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
   
}

- (void)inputViewVoiceFileUploadFinishWithUrlString:(NSString *)fileUrlString  // 音频文件上传完成
                                           fileTime:(NSString *)timeString
                                           fileText:(NSString *)text
                                          soundWave:(NSMutableArray *)soundWaveArr
                                            atArray:(NSArray *)atArray
                                             result:(BOOL)result
                                         standbyObj:(id)standbyObj
{
    @WeakObj(self);
    if (self.replyPosts) {
        if (result) {
            [self request_postCommentWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray finish:^{
                @StrongObj(self);
                // 重置数据
                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
                [self.bottomView.textButton setTitle:@"回复楼主" forState:UIControlStateNormal];
            }];
        }else{
            [self.view ja_makeToast:@"文件上传失败"];
        }
    }else{
        if (result) {
            [self request_postReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray finish:^{
                @StrongObj(self);
                // 重置数据
                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
                [self.bottomView.textButton setTitle:@"回复楼主" forState:UIControlStateNormal];
            }];
        }else{
            [self.view ja_makeToast:@"文件上传失败"];
        }
    }
}

/*神策需要的点击*/
- (void)input_sensorsAnalyticsBeginRecord   // 开始录制
{
    if (self.replyPosts) {
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_ContentType] = @"一级回复";
        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
    }else{
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_ContentType] = @"二级回复";
        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
    }
}
- (void)input_sensorsAnalyticsFinishRecordWithRecordDuration:(CGFloat)duration   // 完成录制
{
    if (self.replyPosts) {
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_RecordDuration] = @((int)duration);
        params[JA_Property_ContentType] = @"一级回复";
        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
    }else{
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_RecordDuration] = @((int)duration);
        params[JA_Property_ContentType] = @"二级回复";
        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
    }
}
- (void)input_sensorsAnalyticsCancleRecordWithRecordDuration:(CGFloat)duration   // 重新录制
{
    if (self.replyPosts) {
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_Rerecording] = @(YES);
        params[JA_Property_RecordDuration] = @((int)duration);
        params[JA_Property_AutoDialog] = @(NO);
        params[JA_Property_ContentType] = @"一级回复";
        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
    }else{
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        params[JA_Property_Rerecording] = @(YES);
        params[JA_Property_RecordDuration] = @((int)duration);
        params[JA_Property_AutoDialog] = @(NO);
        params[JA_Property_ContentType] = @"二级回复";
        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
    }
}

#pragma mark - UI
- (void)setupPostDetailViewControllerUI
{
    // tableview
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, JA_StatusBarAndNavigationBarHeight, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT - 44 - JA_StatusBarAndNavigationBarHeight) style:UITableViewStylePlain];
    _tableView = tableView;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedRowHeight = 0; //(ios11 预估为0 ，让系统先调用cellHeight自己计算)
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.tableView registerClass:[JACommonCommentCell class] forCellReuseIdentifier:@"JACommonCommentCell_commentId"];
    [self.view addSubview:tableView];
    
    // 底部
    JAReplyKeyBoardView *bottomView = [[JAReplyKeyBoardView alloc] init];
    _bottomView = bottomView;
    bottomView.type = 0;
    [bottomView.recordButton addTarget:self action:@selector(callRecordKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView.textButton addTarget:self action:@selector(calltextKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView.textButton setTitle:@"回复楼主" forState:UIControlStateNormal];
    bottomView.likeButton.delegate = self;
    [bottomView.shareButton addTarget:self action:@selector(clickShareVoiceButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomView];
    
    // 键盘
    self.inputView = [[JAInputView alloc] init];
    self.inputView.delegate = self;
    self.inputView.inputInitial = JAInputInitialLocalTypeHiden;
    self.inputView.width = JA_SCREEN_WIDTH;
    self.inputView.height = 50;
    self.inputView.y = self.view.height;
    [self.view addSubview:self.inputView];
    
    // 导航条
    JAPostDetailNavBarView *navBarView = [[JAPostDetailNavBarView alloc] init];
    _navBarView = navBarView;
    navBarView.backgroundColor = HEX_COLOR(0xffffff);
    [navBarView.backButton addTarget:self action:@selector(clickBackButton) forControlEvents:UIControlEventTouchUpInside];
    [navBarView.infoButton addTarget:self action:@selector(clickInfoButton) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *circleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoCircle)];
    [navBarView.circleView addGestureRecognizer:circleTap];
    [self.view addSubview:navBarView];
    
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self calculatorPostDetailViewControllerFrame];
}

- (void)calculatorPostDetailViewControllerFrame
{
    self.bottomView.y = self.view.height - self.bottomView.height;
    self.navBarView.width = JA_SCREEN_WIDTH;
    self.navBarView.height = JA_StatusBarAndNavigationBarHeight;
}

- (UIView *)getHeaderView {
    if (self.voiceModel.storyType == 0) {
        JAStoryTableViewCellType cellType = DefaultCellType;
        NSString *reuseIdentifierString = @"DefaultCellType";
        if (self.voiceModel.storyType == 0) {
            // 音频帖
            if (self.voiceModel.photos.count) {
                if (self.voiceModel.photos.count == 1) {
                    cellType = VoiceAndSingleImageCellType;
                    reuseIdentifierString = @"VoiceAndSingleImageCellType";
                } else {
                    cellType = VoiceAndMuliImageCellType;
                    reuseIdentifierString = @"VoiceAndMuliImageCellType";
                }
            } else {
                cellType = VoiceNoImageCellType;
                reuseIdentifierString = @"VoiceNoImageCellType";
            }
        } else {
            // 图文帖
            if (self.voiceModel.photos.count) {
                if (self.voiceModel.photos.count == 1) {
                    cellType = SingleImageCellType;
                    reuseIdentifierString = @"SingleImageCellType";
                } else {
                    cellType = MultiImageCellType;
                    reuseIdentifierString = @"MultiImageCellType";
                }
            }
        }
        JAStoryTableViewCell *headView = [[JAStoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil cellType:cellType imageCount:self.voiceModel.photos.count isDetail:YES];
        _headView = headView;
        headView.width = JA_SCREEN_WIDTH;
        headView.data = self.voiceModel;
        headView.height = headView.data.detailCellHeight + 10;
        [headView hideTimeLabel:NO];
        [headView hideEssenceView:NO isDetail:YES];
        [headView hideCircleTagView:NO];
        [headView setupCommonBlockWithModel:self.voiceModel superVC:self];
        
        // 因精华帖导致追加空格，需要重新计算高度
        headView.height = headView.data.detailCellHeight + 10;
                
        @WeakObj(self);
        headView.playBlock = ^(JAStoryTableViewCell *cell) {
            @StrongObj(self);
            NSInteger type = 2;
            if (!self.musicList.count) {
                self.musicList = @[self.voiceModel];
            }
            [[JANewPlayTool shareNewPlayTool] playTool_playWithModel:self.voiceModel storyList:self.musicList enterType:type albumParameter:nil];
        };
        return headView;
    } else if (self.voiceModel.storyType == 1) {
        JARichContentTableView *view = [[JARichContentTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 1)];
        _pictureHeadView = view;
        view.width = JA_SCREEN_WIDTH;
        [view setupData:self.voiceModel];
        @WeakObj(self);
        view.showBigPicture = ^{
            @StrongObj(self);
            [self registKeyBoard];
        };
        view.headActionBlock = ^{
            @StrongObj(self);
            if (self.voiceModel.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
                [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
                return;
            }
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            model.userId = self.voiceModel.user.userId;
            model.name = self.voiceModel.user.userName;
            model.image = self.voiceModel.user.avatar;
            vc.personalModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        };
        view.followBlock = ^(UIButton *sener) {
            @StrongObj(self);
            [self focusCustomer:sener userModel:self.voiceModel.user];
        };
        view.topicDetailBlock = ^(NSString *topicName) {
            @StrongObj(self);
            JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
            vc.topicTitle = topicName;
            [self.navigationController pushViewController:vc animated:YES];
        };
        view.atPersonBlock = ^(NSString *userName) {
            @StrongObj(self);
            if (userName.length && self.voiceModel.atList.count) {
                JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
                vc.personalModel = [JADataHelper getConsumer:userName atList:self.voiceModel.atList];
                [self.navigationController pushViewController:vc animated:YES];
            }
        };
        return view;
    }
    return nil;
}

#pragma mark - 懒加载
- (JACommonSectionView *)sectionView_one
{
    if (_sectionView_one == nil) {
        
        _sectionView_one = [[JACommonSectionView alloc] initWithType:JACommonSectionViewType_normal];
        _sectionView_one.width = JA_SCREEN_WIDTH;
        _sectionView_one.height = 40;
        _sectionView_one.backgroundColor = [UIColor whiteColor];
        
        [_sectionView_one.leftButton setTitle:@"神回复" forState:UIControlStateNormal];
        [_sectionView_one.leftButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
        _sectionView_one.leftButton.titleLabel.font = JA_MEDIUM_FONT(14);
        
        [_sectionView_one.rightButton setTitle:@"什么是神回复?" forState:UIControlStateNormal];
        [_sectionView_one.rightButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
        _sectionView_one.rightButton.titleLabel.font = JA_REGULAR_FONT(12);
        _sectionView_one.rightButton.backgroundColor = HEX_COLOR(0xC6C6C6);
        [_sectionView_one.rightButton addTarget:self action:@selector(clickWhyButton:) forControlEvents:UIControlEventTouchUpInside];
        [_sectionView_one.rightButton sizeToFit];
        _sectionView_one.rightButton.layer.cornerRadius = _sectionView_one.rightButton.height * 0.5;
        _sectionView_one.rightButton.layer.masksToBounds = YES;
        
        [_sectionView_one commonSection_layoutView];
        
    }
    return _sectionView_one;
}

- (JACommonSectionView *)sectionView_two
{
    if (_sectionView_two == nil) {
        _sectionView_two = [[JACommonSectionView alloc] initWithType:JACommonSectionViewType_moreButton];
        _sectionView_two.width = JA_SCREEN_WIDTH;
        _sectionView_two.height = 40;
        _sectionView_two.backgroundColor = [UIColor whiteColor];
        
        [_sectionView_two.leftButton setTitle:@"全部回复" forState:UIControlStateNormal];
        [_sectionView_two.leftButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        [_sectionView_two.leftButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateSelected];
        _sectionView_two.leftButton.titleLabel.font = JA_REGULAR_FONT(14);
        [_sectionView_two.leftButton addTarget:self action:@selector(clickAllCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        _sectionView_two.leftButton.selected = YES;
        
        [_sectionView_two.middleButton setTitle:@"只看楼主" forState:UIControlStateNormal];
        [_sectionView_two.middleButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        [_sectionView_two.middleButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateSelected];
        _sectionView_two.middleButton.titleLabel.font = JA_REGULAR_FONT(14);
        [_sectionView_two.middleButton addTarget:self action:@selector(clickMyPostCommentButton:) forControlEvents:UIControlEventTouchUpInside];
        _sectionView_two.middleView.hidden = YES;
        
        [_sectionView_two.rightButton setImage:[UIImage imageNamed:@"album_sort"] forState:UIControlStateNormal];
        [_sectionView_two.rightButton setImage:[UIImage imageNamed:@"album_sort_sel"] forState:UIControlStateSelected];
        [_sectionView_two.rightButton setTitle:@"时间正序" forState:UIControlStateNormal];
        [_sectionView_two.rightButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        _sectionView_two.rightButton.titleLabel.font = JA_REGULAR_FONT(13);
        [_sectionView_two.rightButton addTarget:self action:@selector(clickSortButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_sectionView_two commonSection_layoutView];
                
    }
    
    return _sectionView_two;
}

- (void)sensorsAnalyticsWithModel:(JANewVoiceModel *)model mothod:(NSString *)mothod
{
    // 神策数据
    // 计算时间
    NSArray *timeArr = [model.time componentsSeparatedByString:@":"];
    NSString *min = timeArr.firstObject;
    NSString *sec = timeArr.lastObject;
    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;

    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_ContentId] = model.storyId;
    senDic[JA_Property_ContentTitle] = model.content;
    senDic[JA_Property_ContentType] = @"主帖";
    senDic[JA_Property_Anonymous] = @(model.user.isAnonymous);
    senDic[JA_Property_RecordDuration] = @(sen_time);
    senDic[JA_Property_PostId] = model.user.userId;
    senDic[JA_Property_PostName] = model.user.userName;
    senDic[JA_Property_ShareMethod] = mothod;
    if (self.sourcePage.length) {
        senDic[JA_Property_SourcePage] = self.sourcePage;
    }
    if (self.sourcePageName.length) {
        senDic[JA_Property_SourcePageName] = self.sourcePageName;        
    }
    [JASensorsAnalyticsManager sensorsAnalytics_clickShare:senDic];
}
- (void)sensorsAnalyticsWithLikeType:(NSString *)type model:(id)model method:(NSString *)method
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    
    JANewVoiceModel *voiceM = (JANewVoiceModel *)model;
    // 计算时间
    NSArray *timeArr = [voiceM.time componentsSeparatedByString:@":"];
    NSString *min = timeArr.firstObject;
    NSString *sec = timeArr.lastObject;
    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
    
    senDic[JA_Property_ContentId] = voiceM.storyId;
    senDic[JA_Property_ContentTitle] = voiceM.content;
    senDic[JA_Property_ContentType] = @"主帖";
    senDic[JA_Property_Anonymous] = @(voiceM.user.isAnonymous);
    senDic[JA_Property_RecordDuration] = @(sen_time);
    senDic[JA_Property_PostId] = voiceM.user.userId;
    senDic[JA_Property_PostName] = voiceM.user.userName;
    senDic[JA_Property_LikeMethod] = method;
    [JASensorsAnalyticsManager sensorsAnalytics_clickAgree:senDic];
}

- (void)dealloc {
    [self.inputView inputviewDealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.currentProgressHUD hideAnimated:NO];
}
@end
