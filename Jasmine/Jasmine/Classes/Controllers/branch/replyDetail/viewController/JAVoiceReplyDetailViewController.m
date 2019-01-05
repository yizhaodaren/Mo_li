//
//  JAVoiceReplyDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceReplyDetailViewController.h"
#import "JAPostDetailViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAPersonalCenterViewController.h"

#import "JACommonCommentCell.h"
#import "JAInputView.h"
#import "KILabel.h"
#import "JAReplyKeyBoardView.h"

#import "JAStoryDetailNetRequest.h"
#import "JAPublishNetRequest.h"

#import "JADataHelper.h"
#import "JASampleHelper.h"
#import "JANewPlaySingleTool.h"
#import "JAPlayLocalVoiceManager.h"

#define kReplyRecordIphoneX ((iPhoneX) ? 122 : 64)
@interface JAVoiceReplyDetailViewController ()<UITableViewDelegate, UITableViewDataSource,JAInputViewDelegate,UIGestureRecognizerDelegate>

// UI控件
@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) JACommonCommentCell *headerView;
@property (nonatomic, strong) JAInputView *inputView;
@property (nonatomic, weak) JAReplyKeyBoardView *bottomView;  // 底部键盘

// 请求的页面、数据源
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;

// 当前的评论
@property (nonatomic, strong) JANewCommentModel *commentModel;

// 发布回复
@property (nonatomic, strong) JANewReplyModel *needRefreshModel; // 需要回复的cell
@property (nonatomic, strong) NSIndexPath *frontIndex;  // 前一个点击的cell
@property (nonatomic, assign) BOOL replyComment;  // YES 回复的是头部的评论   NO 回复的回复

// 蒙版
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

// 发布成功后传递的模型数据
@property (nonatomic, strong) JANewReplyModel *release_replyModel;

// 需要滚动的位置（默认第一行）
@property (nonatomic, strong) NSIndexPath *scrollIndex;

@end

@implementation JAVoiceReplyDetailViewController

- (BOOL)fd_interactivePopDisabled
{
    if (self.inputView.isRespondStatus) {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    [self.inputView inputviewDealloc];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"回复详情";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    // UI
    [self setCenterTitle:@"回复详情"];
    [self setupVoiceReplyUI];
    if (self.hasRightButton) {
        [self setNavRightTitle:@"去主帖" color:HEX_COLOR(JA_Green)];
    }
    
    // 获取评论详情
    [self request_getCommentInfo];
    // 回复列表
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getReplyListWithMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getReplyListWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clickCover_registKeyBoard) name:@"clickCover_regist" object:self.inputView];
}
- (void)clickCover_registKeyBoard
{
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self registKeyBoard];
    }
}

#pragma mark - tableView
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath == self.scrollIndex) {
        self.scrollIndex = nil;
        cell.layer.backgroundColor = HEX_COLOR(0xF6FFF7).CGColor;
        CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        animation.toValue = (id)HEX_COLOR(0xffffff).CGColor;
        animation.duration = 2.0f;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        [cell.layer addAnimation:animation forKey:@"aAlpha"];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
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
    
    JANewReplyModel *model = self.dataSourceArray[indexPath.row];
    
    self.needRefreshModel = model;
    
    if (self.inputView.isHasDraft) {  // 有音频数据  直接唤起键盘
        
        if (self.frontIndex != indexPath || self.replyComment == YES) { // 如果点击的是不同的cell 或者之前是回复的头部评论
            NSString *name = [NSString stringWithFormat:@"回复@%@", model.user.userName];
            [self.inputView resetInputOfDraftWithPlacrHolder:name];
        }
        
        self.frontIndex = indexPath;
        [self.inputView callInputOrRecordKeyBoard];
        
    }else{   // 没有音频数据 添加占位文字 并唤起键盘
        
        NSString *name = [NSString stringWithFormat:@"回复@%@", model.user.userName];
        self.inputView.placeHolderText = name;
        self.frontIndex = indexPath;
        [self.inputView callInputOrRecordKeyBoard];
    }
    
    self.replyComment = NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JACommonCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JACommonCommentReplyCellID"];
    cell.cellType = VoiceCommentType_reply;
    
    cell.reply_Model = self.dataSourceArray[indexPath.row];
    @WeakObj(self);
    cell.jumpPersonalViewControlBlock = ^(JACommonCommentCell *cell) {    // 个人主页
        @StrongObj(self);
        if (cell.reply_Model.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return;
        }
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.reply_Model.user.userId;
        model.name = cell.reply_Model.user.userName;
        model.image = cell.reply_Model.user.avatar;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    cell.jumpBeReplyPersonalViewControlBlock = ^(JACommonCommentCell *cell) {  // 去往被回复者的主页
        @StrongObj(self);
        if (cell.reply_Model.replyUser.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
            [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return;
        }
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.reply_Model.replyUser.userId;
        model.name = cell.reply_Model.replyUser.userName;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    // 播放系列 
    cell.playCommentBlock = ^(JACommonCommentCell *cell) {
        [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_playSingleMusicWithFileUrlString:cell.reply_Model.audioUrl model:cell.reply_Model playType:JANewPlaySingleToolType_reply];
    };
    
    cell.pointClickBlock = ^(JACommonCommentCell *cell) {    // 点击三个点(操作是：长按)
        @StrongObj(self);
        [JADetailClickManager detail_modalChooseWindowWithReply:cell.reply_Model standbyParameter:nil needBlock:^(NSInteger actionType) {
            if (actionType == 2) {  // 删除
                [self.dataSourceArray removeObject:cell.reply_Model];
                [self.tableView reloadData];
            }
        }];
    };
    // v2.6.0
    cell.replyAtPersonBlock = ^(NSString *userName, NSArray *atList) {
        @StrongObj(self);
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v = [[UIView alloc] init];
    v.height = 50;
    v.clipsToBounds = YES;
    v.backgroundColor = [UIColor whiteColor];
    v.width = JA_SCREEN_WIDTH;
    
    UIView *yellowV = [[UIView alloc] init];
    yellowV.backgroundColor = HEX_COLOR(0xFFE456);
    yellowV.width = 95;
    yellowV.height = 30;
    yellowV.layer.cornerRadius = 15;
    yellowV.clipsToBounds = YES;
    yellowV.x = -15;
    yellowV.centerY = v.height * 0.5;
    [v addSubview:yellowV];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"全部回复";
    label.textColor = HEX_COLOR(JA_Title);
    label.font = JA_REGULAR_FONT(15);
    [label sizeToFit];
    label.x = 10;
    label.centerY = yellowV.centerY;
    [v addSubview:label];
    
    UIView *lineV = [[UIView alloc] init];
    lineV.backgroundColor = HEX_COLOR(JA_Line);
    lineV.width = JA_SCREEN_WIDTH;
    lineV.height = 1;
    lineV.y = 49;
    [v addSubview:lineV];
    
    return v;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JANewReplyModel *model = self.dataSourceArray[indexPath.row];
    model.storyUserId = self.storyUserId;      // 给model赋值，用来判断是否是楼主
    model.commentUserId = self.commentModel.user.userId;
    model.sourcePageName = self.sourcePageName;
    model.sourcePage = self.sourcePage;
    return model.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

#pragma mark - 网络请求
- (void)request_getCommentInfo
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    // 评论详情
    JAStoryDetailNetRequest *r = [[JAStoryDetailNetRequest alloc] initRequest_commentInfoWithParameter:nil commentId:self.voiceCommentId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        if (responseModel.code == 155555) {
            [self showBlankPageWithLocationY:0 title:@"该内容已经被删除啦！" subTitle:@"" image:@"blank_delete" buttonTitle:nil selector:nil buttonShow:NO];
            return;
        }else if (responseModel.code != 10000) {
            
            [self showBlankPageWithLocationY:0 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            return;
        }
        
        self.commentModel = (JANewCommentModel *)responseModel;
        self.commentModel.storyUserId = self.storyUserId;
        // 展示头部
        self.headerView.height = self.commentModel.cellHeight;
        self.headerView.comment_Model = self.commentModel;
        self.tableView.tableHeaderView = self.headerView;
        NSString *replyName = [NSString stringWithFormat:@"回复:%@",self.commentModel.user.userName];
        [self.bottomView.textButton setTitle:replyName forState:UIControlStateNormal];
        
        // 请求回复列表
        [self request_getReplyListWithMore:NO];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRequestCommentInfo) buttonShow:YES];
    }];
}

- (void)againRequestCommentInfo
{
    [self request_getCommentInfo];
}

- (void)request_getReplyListWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageSize"] = @(6);
    dic[@"pageNum"] = @(self.currentPage);
    
    JAStoryDetailNetRequest *r = [[JAStoryDetailNetRequest alloc] initRequest_replyListWithParameter:dic commentId:self.voiceCommentId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JANewReplyGroupModel *model = (JANewReplyGroupModel *)responseModel;
        if (model.code != 10000) {
            if (!self.dataSourceArray.count) {
                [self showBlankPageWithLocationY:self.headerView.height title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            }
            return;
        }
        
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
        }
        
        // 添加数据
        [self.dataSourceArray addObjectsFromArray:model.resBody];
        
        // 排查数据
        self.scrollIndex = nil;
        if (self.first_replyModel) {
            [self.dataSourceArray enumerateObjectsUsingBlock:^(JANewReplyModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([self.first_replyModel.replyId isEqualToString:model.replyId]) {
                    JANewReplyModel *newModel = model;
                    [self.dataSourceArray removeObject:model];
                    [self.dataSourceArray insertObject:newModel atIndex:0];
                    self.scrollIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                    *stop = YES;
                }
            }];

            if (!self.scrollIndex) {
                [self.dataSourceArray insertObject:self.first_replyModel atIndex:0];
                self.scrollIndex = [NSIndexPath indexPathForRow:0 inSection:0];
            }
            self.first_replyModel = nil;
        }

        
        if (self.dataSourceArray.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        if (!self.dataSourceArray.count) {
            [self showBlankPageWithLocationY:self.headerView.height title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
    }];
}

#pragma mark - 按钮的点击
- (void)actionRight  // 从通知界面进入 - 有去主帖的操作
{
    if (!self.hasRightButton) {
        return;
    }
    
    JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
    vc.voiceId = self.voiceId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)callRecordKeyBoard:(UIButton *)button  // 唤起录音键盘
{
    if ([JAAPPManager app_checkGag]) {
        return;
    }
    // 判断是否有要回复的人
    if (!self.inputView.isHasDraft) {  // 没有要回复的数据
        self.frontIndex = nil;
        self.replyComment = YES;
        NSString *name = [NSString stringWithFormat:@"回复@%@", self.commentModel.user.userName];
        self.inputView.placeHolderText = name;
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
        self.replyComment = YES;
        NSString *name = [NSString stringWithFormat:@"回复@%@", self.commentModel.user.userName];
        self.inputView.placeHolderText = name;
    }
    [self.inputView callInputKeyBoard];
}

- (void)registKeyBoard
{
    [self.inputView registAllInput];
    
    if (self.inputView.isHasVoice) {
        [self.bottomView.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordRed"] forState:UIControlStateNormal];
        
    }else{
        [self.bottomView.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateNormal];
        
    }
    if ([self.inputView.inputText isEqualToString:@"回复楼主"]) {
        NSString *replyName = [NSString stringWithFormat:@"回复:%@",self.commentModel.user.userName];
        [self.bottomView.textButton setTitle:replyName forState:UIControlStateNormal];
    }else{
        [self.bottomView.textButton setTitle:self.inputView.inputText forState:UIControlStateNormal];
    }
}

#pragma mark - 手势代理
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if([touch.view isKindOfClass:[KILabel class]])
    {
        NSDictionary *touchedLink;
        CGPoint touchLocation = [touch locationInView:touch.view];
        touchedLink = [self.headerView.title_label linkAtPoint:touchLocation];
        if (touchedLink) {
            return NO;
        }
    
    }
    return YES;    
}

#pragma mark - 头部的手势
- (void)sigleShowHeardShape:(UITapGestureRecognizer *)tap
{
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
    
    self.frontIndex = nil;
    
    if (self.inputView.isHasDraft) {  // 有音频数据或者文字  直接唤起键盘
        
        if (self.replyComment == NO) { // 如果之前的数据是回复不是帖子
            NSString *name = [NSString stringWithFormat:@"回复@%@", self.commentModel.user.userName];
            [self.inputView resetInputOfDraftWithPlacrHolder:name];
        }
        [self.inputView callInputOrRecordKeyBoard];
        
    }else{   // 没有音频数据或者文字 添加占位文字 并唤起键盘
        
        NSString *name = [NSString stringWithFormat:@"回复@%@", self.commentModel.user.userName];
        self.inputView.placeHolderText = name;
        [self.inputView callInputOrRecordKeyBoard];
    }
    self.replyComment = YES;
}

#pragma mark - inputView的代理方法
- (void)inputViewFrameChangeWithHeight:(CGFloat)height
{
    CGFloat bottominset = height > 50 ? height : 0;
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
    if (result) {
        [self releaseReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray replyComment:self.replyComment finish:^{
            @StrongObj(self);
            // 重置数据
            [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
            NSString *replyName = [NSString stringWithFormat:@"回复:%@",self.commentModel.user.userName];
            [self.bottomView.textButton setTitle:replyName forState:UIControlStateNormal];
        }];
    }else{
        [self.view ja_makeToast:@"文件上传失败"];
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


#pragma mark - 插入回复
- (void)setRelease_replyModel:(JANewReplyModel *)release_replyModel
{
    _release_replyModel = release_replyModel;

    release_replyModel.refreshModel = YES;
    release_replyModel.storyUserId = self.storyUserId;
    release_replyModel.commentUserId = self.commentModel.user.userId;

    [self.dataSourceArray insertObject:release_replyModel atIndex:0];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.tableView reloadData];

        NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:0];

        [self.tableView selectRowAtIndexPath:p animated:NO scrollPosition:UITableViewScrollPositionNone];
    });
}

#pragma mark - 发布回复
// 回复
- (void)releaseReplyWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList replyComment:(BOOL)replyComment finish:(void(^)())finish
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"commentId"] = self.commentModel.commentId;
    if (!replyComment) {
        dic[@"replyId"] = self.needRefreshModel.replyId;
    }
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
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [MBProgressHUD hideHUD];
    }];
}


#pragma mark - UI
- (void)setupVoiceReplyUI
{
    CGFloat safeHeight = JA_TabbarSafeBottomMargin + JA_StatusBarAndNavigationBarHeight;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, self.view.height - safeHeight - 50) style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JACommonCommentCell class] forCellReuseIdentifier:@"JACommonCommentReplyCellID"];
    // iOS11以后默认开启self-sizing，导致加载更多后跳动问题
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:tableView];
    
    JACommonCommentCell *headerView = [[JACommonCommentCell alloc] init];
    _headerView = headerView;
    headerView.width = JA_SCREEN_WIDTH;
    headerView.height = 120;
    headerView.refreshCommentOrReplyAgreeStatus = self.refreshCommentAgreeStatus;
    
    // 添加手势
    UITapGestureRecognizer *waveSignTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sigleShowHeardShape:)];
    //    waveSignTap.cancelsTouchesInView = NO;
    waveSignTap.delegate = self;
    [headerView addGestureRecognizer:waveSignTap];
    
    headerView.backgroundColor = [UIColor whiteColor];
    @WeakObj(self);
    headerView.jumpPersonalViewControlBlock = ^(JACommonCommentCell *cell) {    // 个人主页
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
    
    headerView.pointClickBlock = ^(JACommonCommentCell *cell) {
        @StrongObj(self);
        [JADetailClickManager detail_modalChooseWindowWithComment:cell.comment_Model standbyParameter:nil needBlock:^(NSInteger actionType) {
            if (actionType == 1) {   // 加神
                cell.comment_Model.sort = @"1";
            }else if (actionType == 2){   // 取消神回
                cell.comment_Model.sort = @"0";
            }else if (actionType == 3){  // 隐藏
                
            }else if (actionType == 5){  // 删除
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    };
    
    headerView.playCommentBlock = ^(JACommonCommentCell *cell) {
        [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_playSingleMusicWithFileUrlString:cell.comment_Model.audioUrl model:cell.comment_Model playType:JANewPlaySingleToolType_comment];
    };
    
    // v2.6.0
    headerView.commentAtPersonBlock = ^(NSString *userName, NSArray *atList) {
        @StrongObj(self);
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
        [self.navigationController pushViewController:vc animated:YES];
    };
    
    tableView.tableHeaderView = headerView;
    
    // 底部键盘
    JAReplyKeyBoardView *bottomView = [[JAReplyKeyBoardView alloc] init];
    _bottomView = bottomView;
    bottomView.type = 1;
    [bottomView.recordButton addTarget:self action:@selector(callRecordKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView.textButton addTarget:self action:@selector(calltextKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:bottomView];
    
    self.inputView = [[JAInputView alloc] init];
    self.inputView.width = JA_SCREEN_WIDTH;
    self.inputView.height = 50;
    self.inputView.y = self.view.height;
    self.inputView.delegate = self;
    self.inputView.isAnonymous = NO;
    self.inputView.inputInitial = JAInputInitialLocalTypeHiden;
    [self.view addSubview:self.inputView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    // 底部键盘布局
    self.bottomView.y = self.view.height - self.bottomView.height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
        [self registKeyBoard];
        return;
    }
}
@end
