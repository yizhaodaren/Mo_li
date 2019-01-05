//
//  NIMSessionViewController.m
//  NIMKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NIMSessionConfigurateProtocol.h"
#import "NIMKit.h"
#import "NIMMessageCellProtocol.h"
#import "NIMMessageModel.h"
#import "NIMKitUtil.h"
#import "NIMCustomLeftBarView.h"
#import "NIMBadgeView.h"
#import "UITableView+NIMScrollToBottom.h"
#import "NIMMessageMaker.h"
#import "NIMKitUIConfig.h"
#import "UIView+NIM.h"
#import "NIMSessionConfigurator.h"
#import "NIMKitInfoFetchOption.h"
#import "JAVoicePersonApi.h"
#import "JAVoicePlayerManager.h"
#import "JANewPlayTool.h"
#import "JANewPlaySingleTool.h"

@interface NIMSessionViewController ()<NIMMediaManagerDelegate,NIMInputDelegate>

@property (nonatomic,readwrite) NIMMessage *messageForMenu;

@property (nonatomic,strong)    UILabel *titleLabel;

@property (nonatomic,strong)    UILabel *subTitleLabel;

@property (nonatomic,strong)    NSIndexPath *lastVisibleIndexPathBeforeRotation;

@property (nonatomic,strong)  NIMSessionConfigurator *configurator;

@property (nonatomic,weak)    id<NIMSessionInteractor> interactor;

@end

@implementation NIMSessionViewController

- (instancetype)initWithSession:(NIMSession *)session{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _session = session;
    }
    return self;
}

- (void)dealloc
{
    [self removeListener];
    [[NIMKit sharedKit].robotTemplateParser clean];
    
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //导航栏
    [self setupNav];
    //消息 tableView
    [self setupTableView];
    //输入框 inputView
    [self setupInputView];
    //会话相关逻辑配置器安装
    [self setupConfigurator];
    //添加监听
    [self addListener];
    //进入会话时，标记所有消息已读，并发送已读回执
    [self markRead];
    //更新已读位置
    [self uiCheckReceipt];    
}

- (void)setupNav
{
    [self setUpTitleView];
    NIMCustomLeftBarView *leftBarView = [[NIMCustomLeftBarView alloc] init];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarView];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.leftItemsSupplementBackButton = YES;
}

- (void)setupTableView
{
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.backgroundColor = NIMKit_UIColorFromRGB(JA_BoardLineColor);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:self.tableView];
}


- (void)setupInputView
{
    if ([self shouldShowInputView]) {
        self.sessionInputView = [[NIMInputView alloc] initWithFrame:CGRectMake(0, 0, self.view.nim_width,0) config:self.sessionConfig];
        [self.sessionInputView refreshStatus:NIMInputStatusText];
        [self.sessionInputView setSession:self.session];
        [self.sessionInputView setInputDelegate:self];
        [self.sessionInputView setInputActionDelegate:self];
        [self.view addSubview:_sessionInputView];
        self.sessionInputView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        
        self.tableView.nim_height -= self.sessionInputView.toolBar.nim_height;
    }
}


- (void)setupConfigurator
{
    _configurator = [[NIMSessionConfigurator alloc] init];
    [_configurator setup:self];
    
    BOOL needProximityMonitor = [self needProximityMonitor];
    [[NIMSDK sharedSDK].mediaManager setNeedProximityMonitor:needProximityMonitor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.interactor onViewWillAppear];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.interactor onViewDidDisappear];
    
    [self.sessionInputView endEditing:YES];
}


- (void)viewDidLayoutSubviews{
    [self changeLeftBarBadge:self.conversationManager.allUnreadCount];
    [self.interactor resetLayout];
}



#pragma mark - 消息收发接口
- (void)sendMessage:(NIMMessage *)message
{
    [self sensorsAnalyticsSendMessage];
    
    // 如果有官方信息就传扩展字段
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"myOffic"] = self.myOffic;
    dic[@"myUserId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"otherOffic"] = self.otherOffic;
    dic[@"otherUserId"] = [self.session.sessionId isEqualToString:JA_OFFIC_SERVERMOLI] ? JA_OFFIC_SERVERMOLI : [self.session.sessionId substringFromIndex:4];
    message.remoteExt = dic;
    
    [JAYXMessageManager app_sendMessageWithYXuserId:self.session.sessionId chatRecord:[self.interactor items] finish:^{
        [self.interactor sendMessage:message];
    }];
    
/*特殊逻辑*/
//    if ([JAConfigManager shareInstance].chatPersonArr.count) {
//        NIMMessage *lastMessage = [JAConfigManager shareInstance].chatPersonArr.firstObject;
//        int value = (int)(message.timestamp - lastMessage.timestamp);
//        if (value >= 60) {
//            [[JAConfigManager shareInstance].chatPersonArr removeAllObjects];
//        }
//    }
//    BOOL isNewPerson = YES;
//    for (NIMMessage *msg in [JAConfigManager shareInstance].chatPersonArr) {
//        if ([message.session.sessionId isEqualToString:msg.session.sessionId]) {
//            isNewPerson = NO;
//            break;
//        }
//    }
//    if (isNewPerson) {
//        [[JAConfigManager shareInstance].chatPersonArr addObject:message];
//    }
//    if ([JAConfigManager shareInstance].chatPersonArr.count >= 15) {
//        // 举报用户，后台审核
//        NSLog(@"举报了。。。。。。。。。。。。");
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//        dic[@"type"] = @"user";
//        dic[@"reportTypeId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//        dic[@"content"] = @"发送私信过于频繁";
//        [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
//
//            [self.view ja_makeToast:@"举报成功"];
//        } failure:^(NSError *error) {
//
//        }];
//
//        [[JAConfigManager shareInstance].chatPersonArr removeAllObjects];
//    }
}


#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [_sessionInputView endEditing:YES];
}


#pragma mark - NIMSessionConfiguratorDelegate

- (void)didFetchMessageData
{
    [self uiCheckReceipt];
    [self.tableView reloadData];
    [self.tableView nim_scrollToBottom:NO];
}

- (void)didRefreshMessageData
{
    [self refreshSessionTitle:self.sessionTitle];
    [self refreshSessionSubTitle:self.sessionSubTitle];
    [self.tableView reloadData];
}

#pragma mark - 会话title
- (NSString *)sessionTitle
{
    NSString *title = @"";
    NIMSessionType type = self.session.sessionType;
    switch (type) {
        case NIMSessionTypeTeam:{
            NIMTeam *team = [[[NIMSDK sharedSDK] teamManager] teamById:self.session.sessionId];
            title = [NSString stringWithFormat:@"%@(%zd)",[team teamName],[team memberNumber]];
        }
            break;
        case NIMSessionTypeP2P:{
            title = [NIMKitUtil showNick:self.session.sessionId inSession:self.session];
        }
            break;
        default:
            break;
    }
    return title;
}

- (NSString *)sessionSubTitle{return @"";};

#pragma mark - NIMChatManagerDelegate

- (void)willSendMessage:(NIMMessage *)message
{
    id<NIMSessionInteractor> interactor = self.interactor;
    
    if ([message.session isEqual:self.session]) {
        if ([interactor findMessageModel:message]) {
            [interactor updateMessage:message];
        }else{
            [interactor addMessages:@[message]];
        }
    }
}

//发送结果
- (void)sendMessage:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
    
    // 此类消息本地存储，不需要发送出去
    if (error && error.code == 7101) {
        //构造消息
        NIMTipObject *tipObject = [[NIMTipObject alloc] init];
        NIMMessage *message     = [[NIMMessage alloc] init];
        message.text = @"由于对方的设置，你不能给该用户发送消息";
        message.messageObject   = tipObject;
        //构造会话
        NIMSession *session = [NIMSession session:self.session.sessionId type:NIMSessionTypeP2P];
        //发送消息
        //            [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
        [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:^(NSError * _Nullable error) {
            
        }];
    } else {
        BOOL isInBlackList = [[NIMSDK sharedSDK].userManager isUserInBlackList:self.session.sessionId];
        if (isInBlackList) {
            //构造消息
            NIMTipObject *tipObject = [[NIMTipObject alloc] init];
            NIMMessage *message     = [[NIMMessage alloc] init];
            message.text = @"你已拉黑对方，将不会收到对方的消息，取消拉黑后可恢复正常聊天";
            message.messageObject   = tipObject;
            //构造会话
            NIMSession *session = [NIMSession session:self.session.sessionId type:NIMSessionTypeP2P];
            //发送消息
            //                [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
            [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:^(NSError * _Nullable error) {
                
            }];
        }
        
        // 不需要遍历，sdk提供查询的接口
//        NSArray *myBlackList = [[NIMSDK sharedSDK].userManager myBlackList];
//        if (myBlackList.count) {
//            [myBlackList enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                NIMUser *user = (NIMUser *)obj;
//                if ([user.userId isEqualToString:self.session.sessionId]) {
//                    //构造消息
//                    NIMTipObject *tipObject = [[NIMTipObject alloc] init];
//                    NIMMessage *message     = [[NIMMessage alloc] init];
//                    message.text = @"你已拉黑对方，将不会收到对方的消息，取消拉黑后可恢复正常聊天";
//                    message.messageObject   = tipObject;
//                    //构造会话
//                    NIMSession *session = [NIMSession session:self.session.sessionId type:NIMSessionTypeP2P];
//                    //发送消息
//                    //                [[NIMSDK sharedSDK].chatManager sendMessage:message toSession:session error:nil];
//                    [[NIMSDK sharedSDK].conversationManager saveMessage:message forSession:session completion:^(NSError * _Nullable error) {
//                        
//                    }];
//                    *stop = YES;
//                }
//            }];
//        }
    }
}

//发送进度
-(void)sendMessage:(NIMMessage *)message progress:(float)progress
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
}

//接收消息
- (void)onRecvMessages:(NSArray *)messages
{
    NIMMessage *message = messages.firstObject;
    NIMSession *session = message.session;
    if (![session isEqual:self.session] || !messages.count){
        return;
    }
    
    [self uiAddMessages:messages];
    [self sendMessageReceipt:messages];
    
    [self.conversationManager markAllMessagesReadInSession:self.session];
}


- (void)fetchMessageAttachment:(NIMMessage *)message progress:(float)progress
{
    if ([message.session isEqual:_session]) {
        [self.interactor updateMessage:message];
    }
}

- (void)fetchMessageAttachment:(NIMMessage *)message didCompleteWithError:(NSError *)error
{
    if ([message.session isEqual:_session]) {
        NIMMessageModel *model = [self.interactor findMessageModel:message];
        //下完缩略图之后，因为比例有变化，重新刷下宽高。
        [model cleanCache];
        [self.interactor updateMessage:message];
    }
}

- (void)onRecvMessageReceipt:(NIMMessageReceipt *)receipt
{
    if ([receipt.session isEqual:self.session] && [self shouldHandleReceipt]) {
        [self uiCheckReceipt];
    }
}

#pragma mark - NIMConversationManagerDelegate
- (void)messagesDeletedInSession:(NIMSession *)session{
    [self.interactor resetMessages];
    [self.tableView reloadData];
}

- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}

- (void)didRemoveRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    [self changeUnreadCount:recentSession totalUnreadCount:totalUnreadCount];
}


- (void)changeUnreadCount:(NIMRecentSession *)recentSession
         totalUnreadCount:(NSInteger)totalUnreadCount{
    if ([recentSession.session isEqual:self.session]) {
        return;
    }
    [self changeLeftBarBadge:totalUnreadCount];
}

#pragma mark - NIMMediaManagerDelegate
- (void)recordAudio:(NSString *)filePath didBeganWithError:(NSError *)error {
    if (!filePath || error) {
        _sessionInputView.recording = NO;
        [self onRecordFailed:error];
    }
}

- (void)recordAudio:(NSString *)filePath didCompletedWithError:(NSError *)error {
    if(!error) {
        if ([self recordFileCanBeSend:filePath]) {
            [self sendMessage:[NIMMessageMaker msgWithAudio:filePath]];
        }else{
            [self showRecordFileNotSendReason];
        }
    } else {
        [self onRecordFailed:error];
    }
    _sessionInputView.recording = NO;
}

- (void)recordAudioDidCancelled {
    _sessionInputView.recording = NO;
}

- (void)recordAudioProgress:(NSTimeInterval)currentTime {
    [_sessionInputView updateAudioRecordTime:currentTime];
}

- (void)recordAudioInterruptionBegin {
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

#pragma mark - 录音相关接口
- (void)onRecordFailed:(NSError *)error{}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    return YES;
}

- (void)showRecordFileNotSendReason{}

#pragma mark - NIMInputDelegate
- (void)showInputView
{
    [self.tableView setUserInteractionEnabled:NO];
}

- (void)hideInputView
{
    [self.tableView setUserInteractionEnabled:YES];
}

- (void)inputViewSizeToHeight:(CGFloat)height showInputView:(BOOL)show
{
    [self.tableView setUserInteractionEnabled:!show];
    CGFloat off = 0;
    if (iPhoneX) {
        if (!show) {
            off = 34;
            height += off;
        }
    }
    [self.interactor changeLayout:height];
}

#pragma mark - NIMInputActionDelegate
- (BOOL)onTapMediaItem:(NIMMediaItem *)item{
    SEL sel = item.selctor;
    BOOL handled = sel && [self respondsToSelector:sel];
    if (handled) {
        NIMKit_SuppressPerformSelectorLeakWarning([self performSelector:sel withObject:item]);
        handled = YES;
    }
    return handled;
}

- (void)onTextChanged:(id)sender{}

- (void)onSendText:(NSString *)text atUsers:(NSArray *)atUsers
{
    NSMutableSet *users = [NSMutableSet setWithArray:atUsers];
    if (self.session.sessionType == NIMSessionTypeP2P)
    {
        [users addObject:self.session.sessionId];
    }
    NSString *robotsToSend = [self robotsToSend:users];
    
    NIMMessage *message = nil;
    if (robotsToSend.length)
    {
        message = [NIMMessageMaker msgWithRobotQuery:text toRobot:robotsToSend];
    }
    else
    {
        message = [NIMMessageMaker msgWithText:text];
    }
    
    if (atUsers.count)
    {
        NIMMessageApnsMemberOption *apnsOption = [[NIMMessageApnsMemberOption alloc] init];
        apnsOption.userIds = atUsers;
        apnsOption.forcePush = YES;
        
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = self.session;
        
        NSString *me = [[NIMKit sharedKit].provider infoByUser:[NIMSDK sharedSDK].loginManager.currentAccount option:option].showName;
        apnsOption.apnsContent = [NSString stringWithFormat:@"%@在群里@了你",me];
        message.apnsMemberOption = apnsOption;
    }
    [self sendMessage:message];
}

- (NSString *)robotsToSend:(NSSet *)atUsers
{
    for (NSString *userId in atUsers)
    {
        if ([[NIMSDK sharedSDK].robotManager isValidRobot:userId])
        {
            return userId;
        }
    }
    return nil;
}


- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId{}

- (void)onCancelRecording
{
    [[NIMSDK sharedSDK].mediaManager cancelRecord];
}

- (void)onStopRecording
{
    [[NIMSDK sharedSDK].mediaManager stopRecord];
}

- (void)onStartRecording
{
#warning 暂停播放故事
    if ([JAVoicePlayerManager shareInstance].isPlaying) {
        [[JAVoicePlayerManager shareInstance] pause];
    }
    
    [[JANewPlayTool shareNewPlayTool] playTool_pause];
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];

    _sessionInputView.recording = YES;
    
    NIMAudioType type = NIMAudioTypeAAC;
    if ([self.sessionConfig respondsToSelector:@selector(recordType)])
    {
        type = [self.sessionConfig recordType];
    }
    
    NSTimeInterval duration = [NIMKitUIConfig sharedConfig].globalConfig.recordMaxDuration;
    
    [[NIMSDK sharedSDK].mediaManager addDelegate:self];
    
    [[NIMSDK sharedSDK].mediaManager record:type
                                     duration:duration];
}

#pragma mark - NIMMessageCellDelegate
- (BOOL)onTapCell:(NIMKitEvent *)event{
    BOOL handle = NO;
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapAudio])
    {
#warning 暂停播放故事
        if ([JAVoicePlayerManager shareInstance].isPlaying) {
            [[JAVoicePlayerManager shareInstance] pause];
        }
        [self.interactor mediaAudioPressed:event.messageModel];
        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapRobotBlock]) {
        NSDictionary *param = event.data;
        NIMMessage *message = [NIMMessageMaker msgWithRobotSelect:param[@"text"] target:param[@"target"] params:param[@"param"] toRobot:param[@"robotId"]];
        [self sendMessage:message];
        handle = YES;
    }
    if ([eventName isEqualToString:NIMKitEventNameTapRobotContinueSession]) {
        NIMRobotObject *robotObject = (NIMRobotObject *)event.messageModel.message.messageObject;
        NIMRobot *robot = [[NIMSDK sharedSDK].robotManager robotInfo:robotObject.robotId];
        NSString *text = [NSString stringWithFormat:@"%@%@%@",NIMInputAtStartChar,robot.nickname,NIMInputAtEndChar];
        
        NIMInputAtItem *item = [[NIMInputAtItem alloc] init];
        item.uid  = robot.userId;
        item.name = robot.nickname;
        [self.sessionInputView.atCache addAtItem:item];
        
        [self.sessionInputView.toolBar insertText:text];

        handle = YES;
    }
    
    return handle;
}

- (void)onRetryMessage:(NIMMessage *)message
{
    if (message.isReceivedMsg) {
        [[[NIMSDK sharedSDK] chatManager] fetchMessageAttachment:message
                                                           error:nil];
    }else{
        [[[NIMSDK sharedSDK] chatManager] resendMessage:message
                                                  error:nil];
    }
}

- (BOOL)onLongPressCell:(NIMMessage *)message
                 inView:(UIView *)view
{
    BOOL handle = NO;
    // tip 消息不处理长按
    if (message.messageType != NIMMessageTypeTip) {
        NSArray *items = [self menusItems:message];
        if ([items count] && [self becomeFirstResponder]) {
            UIMenuController *controller = [UIMenuController sharedMenuController];
            controller.menuItems = items;
            _messageForMenu = message;
            [controller setTargetRect:view.bounds inView:view];
            [controller setMenuVisible:YES animated:YES];
            handle = YES;
        }
    }
    return handle;
}

- (BOOL)disableAudioPlayedStatusIcon:(NIMMessage *)message
{
    BOOL disable = NO;
    if ([self.sessionConfig respondsToSelector:@selector(disableAudioPlayedStatusIcon)])
    {
        disable = [self.sessionConfig disableAudioPlayedStatusIcon];
    }
    return disable;
}

#pragma mark - 配置项
- (id<NIMSessionConfig>)sessionConfig
{
    return nil;
}

#pragma mark - 配置项列表
//是否需要监听新消息通知 : 某些场景不需要监听新消息，如浏览服务器消息历史界面
- (BOOL)shouldAddListenerForNewMsg
{
    BOOL should = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableReceiveNewMessages)]) {
        should = ![self.sessionConfig disableReceiveNewMessages];
    }
    return should;
}

//是否需要开启自动设置所有消息已读 ： 某些场景不需要自动设置消息已读，如使用 3D touch 的场景预览会话界面内容
- (BOOL)shouldAutoMarkRead
{
    BOOL should = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableAutoMarkMessageRead)]) {
        should = ![self.sessionConfig disableAutoMarkMessageRead];
    }
    return should;
}

//是否需要显示输入框 : 某些场景不需要显示输入框，如使用 3D touch 的场景预览会话界面内容
- (BOOL)shouldShowInputView
{
    BOOL should = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableInputView)]) {
        should = ![self.sessionConfig disableInputView];
    }
    return should;
}


//当前录音格式 : NIMSDK 支持 aac 和 amr 两种格式
- (NIMAudioType)recordAudioType
{
    NIMAudioType type = NIMAudioTypeAAC;
    if ([self.sessionConfig respondsToSelector:@selector(recordType)]) {
        type = [self.sessionConfig recordType];
    }
    return type;
}

//是否需要监听感应器事件
- (BOOL)needProximityMonitor
{
    BOOL needProximityMonitor = YES;
    if ([self.sessionConfig respondsToSelector:@selector(disableProximityMonitor)]) {
        needProximityMonitor = !self.sessionConfig.disableProximityMonitor;
    }
    return needProximityMonitor;
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    
    BOOL copyText = NO;
    if (message.messageType == NIMMessageTypeText)
    {
        copyText = YES;
    }
    if (message.messageType == NIMMessageTypeRobot)
    {
        NIMRobotObject *robotObject = (NIMRobotObject *)message.messageObject;
        copyText = !robotObject.isFromRobot;
    }
    if (copyText) {
        [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制"
                                                    action:@selector(copyText:)]];
    }
    [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除"
                                                action:@selector(deleteMsg:)]];
    return items;
    
}

- (NIMMessage *)messageForMenu
{
    return _messageForMenu;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    NSArray *items = [[UIMenuController sharedMenuController] menuItems];
    for (UIMenuItem *item in items) {
        if (action == [item action]){
            return YES;
        }
    }
    return NO;
}


- (void)copyText:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    if (message.text.length) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:message.text];
    }
}

- (void)deleteMsg:(id)sender
{
    NIMMessage *message    = [self messageForMenu];
    [self uiDeleteMessage:message];
    [self.conversationManager deleteMessage:message];
}

- (void)menuDidHide:(NSNotification *)notification
{
    [UIMenuController sharedMenuController].menuItems = nil;
}


#pragma mark - 操作接口
- (void)uiAddMessages:(NSArray *)messages
{
    [self.interactor addMessages:messages];
}

- (void)uiInsertMessages:(NSArray *)messages
{
    [self.interactor insertMessages:messages];
}

- (NIMMessageModel *)uiDeleteMessage:(NIMMessage *)message{
    NIMMessageModel *model = [self.interactor deleteMessage:message];
    if (model.shouldShowReadLabel)
    {
        [self uiCheckReceipt];
    }
    return model;
}

- (void)uiUpdateMessage:(NIMMessage *)message{
    [self.interactor updateMessage:message];
}

- (void)uiCheckReceipt
{
    if ([self shouldHandleReceipt]) {
        [self.interactor checkReceipt];
    }
}

#pragma mark - NIMMeidaButton
- (void)onTapMediaItemPicture:(NIMMediaItem *)item
{
    [self.interactor mediaPicturePressed];
}

- (void)onTapMediaItemShoot:(NIMMediaItem *)item
{
    [self.interactor mediaShootPressed];
}

- (void)onTapMediaItemLocation:(NIMMediaItem *)item
{
    [self.interactor mediaLocationPressed];
}

#pragma mark - 旋转处理 (iOS8 or above)
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.lastVisibleIndexPathBeforeRotation = [self.tableView indexPathsForVisibleRows].lastObject;
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    if (self.view.window) {
        __weak typeof(self) wself = self;
        [coordinator animateAlongsideTransition:^(id <UIViewControllerTransitionCoordinatorContext> context)
         {
             [[NIMSDK sharedSDK].mediaManager cancelRecord];
             [wself.interactor cleanCache];
             [wself.sessionInputView reset];
             [wself.tableView reloadData];
             [wself.tableView scrollToRowAtIndexPath:wself.lastVisibleIndexPathBeforeRotation atScrollPosition:UITableViewScrollPositionBottom animated:NO];
         } completion:nil];
    }
}


#pragma mark - 标记已读
- (void)markRead
{
    if (![self disableAutoMarkRead]) {
        [[NIMSDK sharedSDK].conversationManager markAllMessagesReadInSession:self.session];
        [self sendMessageReceipt:self.interactor.items];
    }
}

#pragma mark - 已读回执
- (void)sendMessageReceipt:(NSArray *)messages
{
    if ([self shouldHandleReceipt]) {
        [self.interactor sendMessageReceipt:messages];
    }
}


#pragma mark - Private

- (void)addListener
{
    
    if (![self.sessionConfig respondsToSelector:@selector(disableReceiveNewMessages)]
        || ![self.sessionConfig disableReceiveNewMessages]) {
        [[NIMSDK sharedSDK].chatManager addDelegate:self];
    }
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
}

- (void)removeListener
{
    [[NIMSDK sharedSDK].chatManager removeDelegate:self];
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
}

- (void)changeLeftBarBadge:(NSInteger)unreadCount
{
    NIMCustomLeftBarView *leftBarView = (NIMCustomLeftBarView *)self.navigationItem.leftBarButtonItem.customView;
    leftBarView.badgeView.badgeValue = @(unreadCount).stringValue;
    leftBarView.badgeView.hidden = !unreadCount;
}


- (BOOL)shouldHandleReceipt
{
    return [self.interactor shouldHandleReceipt];
}


- (BOOL)disableAutoMarkRead
{
    return [self.sessionConfig respondsToSelector:@selector(disableAutoMarkMessageRead)] &&
    [self.sessionConfig disableAutoMarkMessageRead];
}

- (id<NIMConversationManager>)conversationManager{
    switch (self.session.sessionType) {
        case NIMSessionTypeChatroom:
            return nil;
            break;
        case NIMSessionTypeP2P:
        case NIMSessionTypeTeam:
        default:
            return [NIMSDK sharedSDK].conversationManager;
    }
}


- (void)setUpTitleView
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:15.f];
//    self.titleLabel.text = self.sessionTitle;
    self.titleLabel.clipsToBounds = NO;
 
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.subTitleLabel  = [[UILabel alloc] initWithFrame:CGRectZero];
    self.subTitleLabel.textColor = [UIColor grayColor];
    self.subTitleLabel.font = [UIFont systemFontOfSize:12.f];
//    self.subTitleLabel.text = self.sessionSubTitle;
    self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
    
    UIView *titleView = [[UIView alloc] init];
    [titleView addSubview:self.titleLabel];
    [titleView addSubview:self.subTitleLabel];
    
    self.officLabel = [[UILabel alloc] init];
    self.officLabel.width = 30;
    self.officLabel.height = 16;
    self.officLabel.text = @"官方";
    self.officLabel.hidden = YES;
    self.officLabel.textColor = HEX_COLOR(0x1CD39B);
    self.officLabel.font = JA_REGULAR_FONT(10);
    self.officLabel.layer.cornerRadius = 8;
    self.officLabel.clipsToBounds = YES;
    self.officLabel.layer.borderWidth = 1;
    self.officLabel.layer.borderColor = HEX_COLOR(0x1CD39B).CGColor;
    self.officLabel.textAlignment = NSTextAlignmentCenter;
    [self.titleLabel addSubview:self.officLabel];
    
    self.navigationItem.titleView = titleView;
    
    [self layoutTitleView];
    
}

- (void)layoutTitleView
{
    CGFloat maxLabelWidth = 150.f;
    [self.titleLabel sizeToFit];
    self.titleLabel.nim_width = maxLabelWidth;
    
    [self.subTitleLabel sizeToFit];
    self.subTitleLabel.nim_width = maxLabelWidth;
    
    self.officLabel.centerY = self.titleLabel.height * 0.5;
    CGFloat w = [self.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:15.f]].width;
    self.officLabel.x = (150 - w) * 0.5 + w + 10;

    
    UIView *titleView = self.navigationItem.titleView;
    
    titleView.nim_width  = MAX(self.titleLabel.nim_width, self.subTitleLabel.nim_width);
    titleView.nim_height = self.titleLabel.nim_height + self.subTitleLabel.nim_height;
    
    self.subTitleLabel.nim_bottom  = titleView.nim_height;
}



- (void)refreshSessionTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self layoutTitleView];
}

- (void)refreshSessionOffic:(BOOL)offic
{
    self.officLabel.hidden = !offic;
}


- (void)refreshSessionSubTitle:(NSString *)title
{
    self.subTitleLabel.text = title;
    [self layoutTitleView];
}

// 神策数据
- (void)sensorsAnalyticsSendMessage
{
    [JAChatMessageManager yx_getUserInfo:@[self.session.sessionId] complete:^(NSArray<NIMUser *> * _Nullable users) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NIMUserInfo *info = users.firstObject.userInfo;
            NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
            senDic[JA_Property_MessageId] = [self.session.sessionId substringFromIndex:4];
            senDic[JA_Property_MessageName] = info.nickName;
            [JASensorsAnalyticsManager sensorsAnalytics_sendMessage:senDic];
        });
    }];
}
@end

