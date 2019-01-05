//
//  JASessionViewController.m
//  Jasmine
//
//  Created by xujin on 28/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASessionViewController.h"
@import MobileCoreServices;
@import AVFoundation;
#import "Reachability.h"
#import "UIActionSheet+NTESBlock.h"
//#import "NTESCustomSysNotificationSender.h"
#import "NTESSessionConfig.h"

#import "NIMMediaItem.h"
#import "NTESSessionMsgConverter.h"
#import "NTESFileLocationHelper.h"
#import "NTESSessionMsgConverter.h"
#import "UIView+Toast.h"
#import "NTESSnapchatAttachment.h"
#import "NTESJanKenPonAttachment.h"
//#import "NTESFileTransSelectViewController.h"
//#import "NTESAudioChatViewController.h"
//#import "NTESWhiteboardViewController.h"
//#import "NTESVideoChatViewController.h"
#import "NTESChartletAttachment.h"
#import "NTESGalleryViewController.h"
#import "NTESVideoViewController.h"
//#import "NTESFilePreViewController.h"
#import "NTESAudio2TextViewController.h"
#import "NSDictionary+NTESJson.h"
#import "NIMAdvancedTeamCardViewController.h"
//#import "NTESSessionRemoteHistoryViewController.h"
#import "NIMNormalTeamCardViewController.h"
#import "UIView+NTES.h"
//#import "NTESBundleSetting.h"
//#import "NTESPersonalCardViewController.h"
#import "NTESSessionSnapchatContentView.h"
//#import "NTESSessionLocalHistoryViewController.h"
#import "NIMContactSelectViewController.h"
//#import "NTESSessionCardViewController.h"
#import "NTESFPSLabel.h"
#import "UIAlertView+NTESBlock.h"
#import "NIMKit.h"
#import "NTESSessionUtil.h"
#import "NIMKitMediaFetcher.h"
#import "NIMKitLocationPoint.h"
#import "NIMLocationViewController.h"
#import "NIMKitInfoFetchOption.h"
//#import "NTESSubscribeManager.h"
//#import "NTESTeamMeetingViewController.h"
//#import "NTESTeamMeetingCallerInfo.h"
#import "NIMInputAtCache.h"
//#import "NTESRobotCardViewController.h"
//#import "JAPersonzoneVC.h"
//#import "JAStoryDetailViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JACreditViewController.h"
#import "JAPersonalLevelViewController.h"
#import "JAWebViewController.h"
#import "JAPostDetailViewController.h"
#import "JAPersonIncomeViewController.h"
#import "JAPersonTopicViewController.h"
#import "JACircleDetailViewController.h"
#import "JAAlbumDetailViewController.h"

#import "JAVoicePersonApi.h"
#import "JAPersonChatView.h"
#import "JAHelperViewController.h"
#import "JAReportResonModel.h"
#import "JAPacketViewController.h"
#import "JAVoicePlayerManager.h"
#import "LCActionSheet.h"
#import "JANewPlayTool.h"
#import "JANewPlaySingleTool.h"


@interface JASessionViewController ()
<UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
NIMSystemNotificationManagerDelegate,
NIMMediaManagerDelegate,
//NTESTimerHolderDelegate,
NIMContactSelectDelegate,
NIMEventSubscribeManagerDelegate
>

//@property (nonatomic,strong)    NTESCustomSysNotificationSender *notificaionSender;
@property (nonatomic,strong)    NTESSessionConfig       *sessionConfig;
@property (nonatomic,strong)    UIImagePickerController *imagePicker;
//@property (nonatomic,strong)    NTESTimerHolder         *titleTimer;
@property (nonatomic,strong)    UIView *currentSingleSnapView;
@property (nonatomic,strong)    NTESFPSLabel *fpsLabel;
@property (nonatomic,strong)    NIMKitMediaFetcher *mediaFetcher;

@property (nonatomic, assign) JAUserRelation userRelation;

@property (nonatomic, strong) NSString *name;
@end



@implementation JASessionViewController

- (BOOL)hidesBottomBarWhenPushed {
    return YES;
}

- (void)actionLeft
{
    [self.navigationController popViewControllerAnimated:YES];
}

// 举报和拉黑
- (void)actionRight
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    // 获取个人的uid
    NSString *userId = [self.session.sessionId substringFromIndex:4];
    if ([userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
        return;
    }
    [self popWindow_userAction];
    
}

- (void)popWindow_userAction
{
    NSMutableArray *titleButtons = [NSMutableArray array];
    [titleButtons addObject:@"举报"];
    [titleButtons addObject:self.userRelation == JAUserRelationBlack ? @"取消拉黑":@"拉黑"];
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:nil buttonTitles:titleButtons redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex >= titleButtons.count) {
            return;
        }
        NSString *title = titleButtons[buttonIndex];
        if ([title isEqualToString:@"举报"]) {
            // 举报个人
            [self gagActionWith:nil type:@"report"];
        }else if ([title isEqualToString:@"拉黑"]){
            [self middleTipView];
        }else if ([title isEqualToString:@"取消拉黑"]){
            [self deleteBlackAction];
        }
    }];
    [actionS show];
}

// 取消拉黑
- (void)deleteBlackAction
{
    NSString *userId = [self.session.sessionId substringFromIndex:4];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"concernId"] = userId;
    
    [[JAVoicePersonApi shareInstance] voice_personalDeleteBlackUserWithParas:dic success:^(NSDictionary *result) {
        [self.view ja_makeToast:@"取消成功"];
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        [self refreshUserRelationWithNewType:type];
    } failure:^(NSError *error) {
        
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

- (void)refreshUserRelationWithNewType:(NSString *)type
{
    if ([type integerValue] == 0) {
        self.userRelation = JAUserRelationFocus;
    }else if([type integerValue] == 1){
        self.userRelation = JAUserRelationFriend;
    }else if(type.integerValue == 2){
        self.userRelation = JAUserRelationNone;
        
    }else if (type.integerValue == 3){
        self.userRelation = JAUserRelationBlack;
    }
    
}

// 选择举报原因
- (void)gagActionWith:(NSString *)time type:(NSString *)type {
    NSString *alertString = nil;
    if ([type isEqualToString:@"report"]) {
        alertString = @"选择举报原因";
    }
    NSMutableArray *titleArray = [NSMutableArray array];
    for (NSInteger i = 0; i < [JAConfigManager shareInstance].reportArray.count; i++) {
        JAReportResonModel *model = [JAConfigManager shareInstance].reportArray[i];
        [titleArray addObject:model.content];
    }
    @WeakObj(self);
    LCActionSheet *actionS = [[LCActionSheet alloc] initWithTitle:alertString buttonTitles:titleArray redButtonIndex:-1 completion:^(NSInteger buttonIndex, LCActionSheet *actionSheet) {
        @StrongObj(self);
        if (buttonIndex >= titleArray.count) {
            return;
        }
        NSString *reason = [JAConfigManager shareInstance].reportArray[buttonIndex];
        [self reportUserWithReason:reason];
    }];
    [actionS show];
}

// 拉黑提示用户
- (void)middleTipView
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确认将该用户加入黑名单？" message:@"拉黑后，对方将不能关注你、给你发消息、回复你实名发布的内容、邀请你评论等，并自动从你的粉丝和关注列表移除" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = [self.session.sessionId substringFromIndex:4];;
        
        [[JAVoicePersonApi shareInstance] voice_personalAddBlackUserWithParas:dic success:^(NSDictionary *result) {
            [MBProgressHUD showMessageAMoment:@"拉黑成功"];
            if (self.userRelation == JAUserRelationFocus || self.userRelation == JAUserRelationFriend) {
                // 数量要减1；
                NSInteger focus = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount].integerValue;
                [JAUserInfo userInfo_updataUserInfoWithKey:User_userConsernCount value:[NSString stringWithFormat:@"%ld",(focus - 1 > 0 ? (focus - 1) : 0)]];
            }
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            [self refreshUserRelationWithNewType:type];
            
        } failure:^(NSError *error) {
            
            [self.view ja_makeToast:error.localizedDescription];
        }];
        
    }];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:action1];
    [alert addAction:action2];
    
    [self presentViewController:alert animated:YES completion:nil];
}

// 举报用户
- (void)reportUserWithReason:(NSString *)reason
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"user";
    dic[@"reportTypeId"] = [self.session.sessionId substringFromIndex:4];
    dic[@"content"] = reason;
    [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
        
        // 神策数据
        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
        senDic[JA_Property_ReportType] = @"用户";
        senDic[JA_Property_ReportTeason] = reason;
        senDic[JA_Property_PostId] = [self.session.sessionId substringFromIndex:4];
        senDic[JA_Property_PostName] = self.name;
        [JASensorsAnalyticsManager sensorsAnalytics_reportPerson:senDic];
        
        [self.view ja_makeToast:@"举报成功"];
    } failure:^(NSError *error) {
        
    }];
}

// 获取用户间的关系
- (void)getUserRelation
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = [self.session.sessionId substringFromIndex:4];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAVoicePersonApi shareInstance] voice_personalRelationParas:dic success:^(NSDictionary *result) {
        if (result) {
            NSString *type = result[@"friend"][@"friendType"];
            [self refreshUserRelationWithNewType:type];
        }
    } failure:^(NSError *error) {}];
}

- (void)setLeftNavigationItemImage:(UIImage *)image
                    highlightImage:(UIImage *)highlightImage
{
    
    [self setLeftNavigationItemImage:image highlightImage:highlightImage action:@selector(actionLeft)];
}

- (void)setLeftNavigationItemImage:(UIImage *)image
                    highlightImage:(UIImage *)highlightImage
                            action:(SEL)action
{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStyleDone target:self action:action];
    item.imageInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    
    self.navigationItem.leftBarButtonItem = item;
}

- (void)setRightNavigationItemImage:(UIImage *)image
                     highlightImage:(UIImage *)highlightImage{
    [self setRightNavigationItemImage:image highlightImage:highlightImage action:@selector(actionRight)];
}

- (void)setRightNavigationItemImage:(UIImage *)image
                     highlightImage:(UIImage *)highlightImage
                             action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 44);
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:highlightImage forState:UIControlStateHighlighted];
    [btn setImageEdgeInsets:UIEdgeInsetsMake(btn.imageEdgeInsets.top, btn.imageEdgeInsets.left, btn.imageEdgeInsets.bottom, -18)];
    [btn addTarget:self
            action:action
  forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isSecretary == NO) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"聊天";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }
    
    [AppDelegate sharedInstance].playerView.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeMessage];
    
    
    [self setLeftNavigationItemImage:[UIImage imageNamed:@"circle_back_black"] highlightImage:[UIImage imageNamed:@"circle_back_black"]];
    if ([[NIMSDK sharedSDK] loginManager].isLogined && self.isSecretary == NO) {
        
        [self setRightNavigationItemImage:[UIImage imageNamed:@"jubao_grzy"] highlightImage:[UIImage imageNamed:@"jubao_grzy"]];
    }
    
    self.navigationItem.leftItemsSupplementBackButton = NO;
    self.titleLabel.font = JA_MEDIUM_FONT(16);
    self.titleLabel.textColor = HEX_COLOR(JA_BlackTitle);
    self.view.backgroundColor = HEX_COLOR(JA_backGrayColor);

    self.tableView.backgroundColor = [UIColor clearColor];
    
    [JAChatMessageManager yx_getUserInfo:@[self.session.sessionId] complete:^(NSArray<NIMUser *> * _Nullable users) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NIMUserInfo *info = users.firstObject.userInfo;
            self.name = [info.nickName attributedStringFromHTML].string;
            [self refreshSessionTitle:self.name];
            
            [JAChatMessageManager yx_getUserInfo:@[self.session.sessionId] complete:^(NSArray<NIMUser *> * _Nullable users) {
                
                NIMUser *user = users.firstObject;
                
                NSLog(@"%@",user.userInfo.ext);
                NSString *officExt = user.userInfo.ext;
                
                if (officExt.length) {
                    NSDictionary *officDic = [officExt mj_JSONObject];
                    NSString *offic = officDic[@"extMap"][@"achievementId"];
                    
                    if (offic.integerValue == 1) {
                        [self refreshSessionOffic:YES];
                    }else{
                       [self refreshSessionOffic:NO];
                    }
                }else{
                    // 判断对方是不是官方
                    if (self.otherOffic.integerValue == 1) {
                        [self refreshSessionOffic:YES];
                    }else{
                        [self refreshSessionOffic:NO];
                    }
                }
                
            }];
            
        });
    }];
    // 获取用户关系
    if (self.isSecretary == NO) {
        [self getUserRelation];
    }
    
//    NSLog(@"enter session, id = %@",self.session.sessionId);
//    _notificaionSender  = [[NTESCustomSysNotificationSender alloc] init];
//    [self setUpNav];
//    BOOL disableCommandTyping = self.disableCommandTyping || (self.session.sessionType == NIMSessionTypeP2P &&[[NIMSDK sharedSDK].userManager isUserInBlackList:self.session.sessionId]);
//    if (!disableCommandTyping) {
//        _titleTimer = [[NTESTimerHolder alloc] init];
//        [[NIMSDK sharedSDK].systemNotificationManager addDelegate:self];
//    }
    
//    if ([[NTESBundleSetting sharedConfig] showFps])
//    {
//        self.fpsLabel = [[NTESFPSLabel alloc] initWithFrame:CGRectZero];
//        [self.view addSubview:self.fpsLabel];
//        self.fpsLabel.right = self.view.width;
//        self.fpsLabel.top   = self.tableView.top + self.tableView.contentInset.top;
//    }
    
//    if (self.session.sessionType == NIMSessionTypeP2P && !self.disableOnlineState)
//    {
//        //临时订阅这个人的在线状态
//        [[NTESSubscribeManager sharedManager] subscribeTempUserOnlineState:self.session.sessionId];
//        [[NIMSDK sharedSDK].subscribeManager addDelegate:self];
//    }
    
    //删除最近会话列表中有人@你的标记
    [NTESSessionUtil removeRecentSessionAtMark:self.session];
    
}

- (void)dealloc
{
    [[NIMSDK sharedSDK].systemNotificationManager removeDelegate:self];
//    if (self.session.sessionType == NIMSessionTypeP2P && !self.disableOnlineState)
//    {
//        [[NIMSDK sharedSDK].subscribeManager removeDelegate:self];
//        [[NTESSubscribeManager sharedManager] unsubscribeTempUserOnlineState:self.session.sessionId];
//    }
    [_fpsLabel invalidate];
}



- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.fpsLabel.right = self.view.width;
    self.fpsLabel.top   = self.tableView.top + self.tableView.contentInset.top;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NIMSDK sharedSDK].mediaManager stopRecord];
    [[NIMSDK sharedSDK].mediaManager stopPlay];
}

- (id<NIMSessionConfig>)sessionConfig
{
    if (_sessionConfig == nil) {
        _sessionConfig = [[NTESSessionConfig alloc] init];
        _sessionConfig.session = self.session;
    }
    return _sessionConfig;
}

#pragma mark - NIMEventSubscribeManagerDelegate
- (void)onRecvSubscribeEvents:(NSArray *)events
{
    for (NIMSubscribeEvent *event in events) {
        if ([event.from isEqualToString:self.session.sessionId]) {
            [self refreshSessionSubTitle:[NTESSessionUtil onlineState:self.session.sessionId detail:YES]];
        }
    }
}
#pragma mark - NIMSystemNotificationManagerDelegate
//- (void)onReceiveCustomSystemNotification:(NIMCustomSystemNotification *)notification
//{
//    if (!notification.sendToOnlineUsersOnly) {
//        return;
//    }
//    NSData *data = [[notification content] dataUsingEncoding:NSUTF8StringEncoding];
//    if (data) {
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
//                                                             options:0
//                                                               error:nil];
//        if ([dict jsonInteger:NTESNotifyID] == NTESCommandTyping && self.session.sessionType == NIMSessionTypeP2P && [notification.sender isEqualToString:self.session.sessionId])
//        {
//            [self refreshSessionTitle:@"正在输入..."];
//            [_titleTimer startTimer:5
//                           delegate:self
//                            repeats:NO];
//        }
//    }
//    
//    
//}
//
//- (void)onNTESTimerFired:(NTESTimerHolder *)holder
//{
//    [self refreshSessionTitle:self.sessionTitle];
//}


- (NSString *)sessionTitle
{
    if ([self.session.sessionId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        return  @"我的电脑";
    }
    return [super sessionTitle];
}

- (NSString *)sessionSubTitle
{
    if (self.session.sessionType == NIMSessionTypeP2P && ![self.session.sessionId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount]) {
        return [NTESSessionUtil onlineState:self.session.sessionId detail:YES];
    }
    return @"";
}

// 对方正在偷人
//- (void)onTextChanged:(id)sender
//{
//    [_notificaionSender sendTypingState:self.session];
//}

// 发送表情
- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId
{
    NTESChartletAttachment *attachment = [[NTESChartletAttachment alloc] init];
    attachment.chartletId = chartletId;
    attachment.chartletCatalog = catalogId;
    [self sendMessage:[NTESSessionMsgConverter msgWithChartletAttachment:attachment]];
}


#pragma mark - 石头剪子布
- (void)onTapMediaItemJanKenPon:(NIMMediaItem *)item
{
    NTESJanKenPonAttachment *attachment = [[NTESJanKenPonAttachment alloc] init];
    attachment.value = arc4random() % 3 + 1;
    [self sendMessage:[NTESSessionMsgConverter msgWithJenKenPon:attachment]];
}

#pragma mark - 阅后即焚
- (void)onTapMediaItemSnapChat:(NIMMediaItem *)item
{
    UIActionSheet *sheet;
    BOOL isCamraAvailable = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (isCamraAvailable) {
        sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选取",@"拍照",nil];
    }else{
        sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从相册中选取",nil];
    }
    __weak typeof(self) wself = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                //相册
                [wself.mediaFetcher fetchPhotoFromLibrary:^(NSArray *images, NSString *path, PHAssetMediaType type){
                    if (images.count) {
                        [wself sendSnapchatMessage:images.firstObject];
                    }
                    if (path) {
                        [wself sendSnapchatMessagePath:path];
                    }
                }];
                
            }
                break;
            case 1:{
                //相机
                [wself.mediaFetcher fetchMediaFromCamera:^(NSString *path, UIImage *image) {
                    if (image) {
                        [wself sendSnapchatMessage:image];
                    }
                }];
            }
                break;
            default:
                return;
        }
    }];
}
// 发送阅后即焚
- (void)sendSnapchatMessagePath:(NSString *)path
{
    NTESSnapchatAttachment *attachment = [[NTESSnapchatAttachment alloc] init];
    [attachment setImageFilePath:path];
    [self sendMessage:[NTESSessionMsgConverter msgWithSnapchatAttachment:attachment]];
}

- (void)sendSnapchatMessage:(UIImage *)image
{
    NTESSnapchatAttachment *attachment = [[NTESSnapchatAttachment alloc] init];
    [attachment setImage:image];
    [self sendMessage:[NTESSessionMsgConverter msgWithSnapchatAttachment:attachment]];
}

#pragma mark - 录音事件
- (void)onRecordFailed:(NSError *)error
{
    [self.view makeToast:@"录音失败" duration:2 position:CSToastPositionCenter];
}

- (BOOL)recordFileCanBeSend:(NSString *)filepath
{
    NSURL    *URL = [NSURL fileURLWithPath:filepath];
    AVURLAsset *urlAsset = [[AVURLAsset alloc]initWithURL:URL options:nil];
    CMTime time = urlAsset.duration;
    CGFloat mediaLength = CMTimeGetSeconds(time);
    return mediaLength > 2;
}

- (void)showRecordFileNotSendReason
{
    [self.view makeToast:@"录音时间太短" duration:0.2f position:CSToastPositionCenter];
}

#pragma mark - Cell事件
- (BOOL)onTapCell:(NIMKitEvent *)event
{
    BOOL handled = [super onTapCell:event];
    NSString *eventName = event.eventName;
    if ([eventName isEqualToString:NIMKitEventNameTapContent])
    {
        NIMMessage *message = event.messageModel.message;
        NSDictionary *actions = [self cellActions];
        NSString *value = actions[@(message.messageType)];
        if (value) {
            SEL selector = NSSelectorFromString(value);
            if (selector && [self respondsToSelector:selector]) {
                SuppressPerformSelectorLeakWarning([self performSelector:selector withObject:message]);
                handled = YES;
            }
        }
    }
    else if([eventName isEqualToString:NIMKitEventNameTapLabelLink])
    {
//        NSString *link = event.data;
//        [self openSafari:link];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMDemoEventNameOpenSnapPicture])
    {
        NIMCustomObject *object = event.messageModel.message.messageObject;
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
        if(attachment.isFired){
            return handled;
        }
        UIView *sender = event.data;
        self.currentSingleSnapView = [NTESGalleryViewController alertSingleSnapViewWithMessage:object.message baseView:sender];
        handled = YES;
    }
    else if([eventName isEqualToString:NIMDemoEventNameCloseSnapPicture])
    {
        //点击很快的时候可能会触发两次查看，所以这里不管有没有查看过 先强直销毁掉
        NIMCustomObject *object = event.messageModel.message.messageObject;
        UIView *senderView = event.data;
        [senderView dismissPresentedView:YES complete:nil];
        
        NTESSnapchatAttachment *attachment = (NTESSnapchatAttachment *)object.attachment;
        if(attachment.isFired){
            return handled;
        }
        attachment.isFired  = YES;
        NIMMessage *message = object.message;
//        if ([NTESBundleSetting sharedConfig].autoRemoveSnapMessage) {
            [[NIMSDK sharedSDK].conversationManager deleteMessage:message];
            [self uiDeleteMessage:message];
//        }else{
//            [[NIMSDK sharedSDK].conversationManager updateMessage:message forSession:message.session completion:nil];
//            [self uiUpdateMessage:message];
//        }
        [[NSFileManager defaultManager] removeItemAtPath:attachment.filepath error:nil];
        handled = YES;
        self.currentSingleSnapView = nil;
    }
    else if([eventName isEqualToString:NIMKitEventNameTapRobotLink])
    {
        NSString *link = event.data;
        [self openSafari:link];
        handled = YES;
    }
//    else if([eventName isEqualToString:NIMKitEventNameTapAudio])
//    {
//        handled = YES;
//    }
    if (!handled) {
        NSAssert(0, @"invalid event");
    }
    return handled;
}

- (BOOL)onTapAvatar:(NSString *)userId{
    if (![userId isEqualToString:JA_OFFIC_SERVERMOLI]) {
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = [userId substringFromIndex:4];
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    }
    return YES;
}


- (BOOL)onLongPressAvatar:(NSString *)userId
{
//    if (self.session.sessionType == NIMSessionTypeTeam && ![userId isEqualToString:[NIMSDK sharedSDK].loginManager.currentAccount])
//    {
//        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
//        option.session = self.session;
//        option.forbidaAlias = YES;
//        
//        NSString *nick = [[NIMKit sharedKit].provider infoByUser:userId option:option].showName;
//        NSString *text = [NSString stringWithFormat:@"%@%@%@",NIMInputAtStartChar,nick,NIMInputAtEndChar];
//        
//        NIMInputAtItem *item = [[NIMInputAtItem alloc] init];
//        item.uid  = userId;
//        item.name = nick;
//        [self.sessionInputView.atCache addAtItem:item];
//        
//        [self.sessionInputView.toolBar insertText:text];
//    }
    return YES;
}



#pragma mark - Cell Actions
- (void)showText:(NIMMessage *)message
{
}
- (void)showImage:(NIMMessage *)message
{
    NIMImageObject *object = message.messageObject;
    NTESGalleryItem *item = [[NTESGalleryItem alloc] init];
    item.thumbPath      = [object thumbPath];
    item.imageURL       = [object url];
    item.name           = [object displayName];
    NTESGalleryViewController *vc = [[NTESGalleryViewController alloc] initWithItem:item];
    [self.navigationController pushViewController:vc animated:YES];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.thumbPath]){
        //如果缩略图下跪了，点进看大图的时候再去下一把缩略图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.thumbUrl filepath:object.thumbPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}

- (void)showLocation:(NIMMessage *)message
{
    NIMLocationObject *object = message.messageObject;
    NIMKitLocationPoint *locationPoint = [[NIMKitLocationPoint alloc] initWithLocationObject:object];
    NIMLocationViewController *vc = [[NIMLocationViewController alloc] initWithLocationPoint:locationPoint];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)showVideo:(NIMMessage *)message
{
    if ([JAVoicePlayerManager shareInstance].isPlaying) {
        [[JAVoicePlayerManager shareInstance] pause];
    }
    
    [[JANewPlayTool shareNewPlayTool] playTool_pause];
    [[JANewPlaySingleTool shareNewPlaySingleTool] playSingleTool_pause];
    
    NIMVideoObject *object = message.messageObject;
    NTESVideoViewController *playerViewController = [[NTESVideoViewController alloc] initWithVideoObject:object];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController pushViewController:playerViewController animated:NO];
    if(![[NSFileManager defaultManager] fileExistsAtPath:object.coverPath]){
        //如果封面图下跪了，点进视频的时候再去下一把封面图
        __weak typeof(self) wself = self;
        [[NIMSDK sharedSDK].resourceManager download:object.coverUrl filepath:object.coverPath progress:nil completion:^(NSError *error) {
            if (!error) {
                [wself uiUpdateMessage:message];
            }
        }];
    }
}
/*
 0,  // 编辑个人资料
 1,  // 邀请红包
 2,  // 分享收入
 3,  // 发布故事
 4,  // 首页
 5,  // 邀请码
 6,  // 信用积分
 7,  // 等级
 8,  // 帮助中心 新手教程
 9   // 帮助中心 视频教程
 10  // 邀请红包的我的邀请
 11  // 我的收入
 128  // 话题详情
 130  圈子详情页
 131  专辑详情页
 */
- (void)showCustom:(NIMMessage *)message
{
    //普通的自定义消息点击事件可以在这里做哦~
    if (message.remoteExt) {

        NSArray *arr = message.remoteExt[@"connect"];
        NSDictionary *dic = arr.firstObject;

        if ([dic[@"operation"] isEqualToString:@"getPage"]) {
            if ([dic[@"type"] integerValue] == 6 || [dic[@"type"] integerValue] == 102) {  // 信用积分

                JACreditViewController *vc = [[JACreditViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];

            }else if ([dic[@"type"] integerValue] == 7 || [dic[@"type"] integerValue] == 103){   // 等级

                JAPersonalLevelViewController *vc = [[JAPersonalLevelViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];

            }else if ([dic[@"type"] integerValue] == 8 || [dic[@"type"] integerValue] == 118){   // 帮助中心 新手教程
                
//                JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//                vc.currentIndex = 0;
//                [self.navigationController pushViewController:vc animated:YES];
                JAWebViewController *help = [[JAWebViewController alloc] init];
                help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
                help.titleString = @"帮助中心";
                help.fromType = 1;
                help.enterType = @"帮助中心";
                [self.navigationController pushViewController:help animated:YES];
                
            }else if ([dic[@"type"] integerValue] == 9 || [dic[@"type"] integerValue] == 119){   // 帮助中心 视频教程
                
//                JAHelperViewController *vc = [[JAHelperViewController alloc] init];
//                vc.currentIndex = 1;
//                [self.navigationController pushViewController:vc animated:YES];
                JAWebViewController *help = [[JAWebViewController alloc] init];
                help.urlString = @"http://www.urmoli.com/views/app/about/helpCenter.html";
                help.titleString = @"帮助中心";
                help.fromType = 1;
                help.enterType = @"帮助中心";
                [self.navigationController pushViewController:help animated:YES];
                
            }else if ([dic[@"type"] integerValue] == 10 || [dic[@"type"] integerValue] == 111){   // 邀请红包 我的邀请
                
                JAPacketViewController *vc = [[JAPacketViewController alloc] init];
                vc.type = 1;
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([dic[@"type"] integerValue] == 1 || [dic[@"type"] integerValue] == 110){   // 邀请红包
                
                JAPacketViewController *vc = [[JAPacketViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([dic[@"type"] integerValue] == 11 || [dic[@"type"] integerValue] == 115){   // 我的收入
                
                JAPersonIncomeViewController *vc = [[JAPersonIncomeViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
                
            }
        }else if ([dic[@"operation"] isEqualToString:@"getContentPage"]){

            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            vc.voiceId = dic[@"typeId"];
            [self.navigationController pushViewController:vc animated:YES];

        }else if ([dic[@"operation"] isEqualToString:@"getH5Page"]){

            JAWebViewController *vc = [[JAWebViewController alloc] init];
            vc.urlString = dic[@"url"];
            vc.enterType = @"官方私信";
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([dic[@"operation"] isEqualToString:@"getCommonContentPage"]){
            
            if ([dic[@"type"] integerValue] == 128){   // 话题详情
                
                JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
                vc.topicTitle = dic[@"url"];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([dic[@"type"] integerValue] == 130){
                JACircleDetailViewController *vc = [[JACircleDetailViewController alloc] init];
                vc.circleId = dic[@"url"];
                [self.navigationController pushViewController:vc animated:YES];
            }else if ([dic[@"type"] integerValue] == 131){
                JAAlbumDetailViewController *vc = [[JAAlbumDetailViewController alloc] init];
                vc.subjectId = dic[@"url"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
    }
}

- (void)openSafari:(NSString *)link
{
    NSURLComponents *components = [[NSURLComponents alloc] initWithString:link];
    if (components)
    {
        if (!components.scheme)
        {
            //默认添加 http
            components.scheme = @"http";
        }
        [[UIApplication sharedApplication] openURL:[components URL]];
    }
}

#pragma mark - 菜单
- (NSArray *)menusItems:(NIMMessage *)message
{
    NSMutableArray *items = [NSMutableArray array];
    NSArray *defaultItems = [super menusItems:message];
    if (defaultItems) {
        [items addObjectsFromArray:defaultItems];
    }
    
//    if ([NTESSessionUtil canMessageBeForwarded:message]) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(forwardMessage:)]];
//    }
//    
//    if ([NTESSessionUtil canMessageBeRevoked:message]) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"撤回" action:@selector(revokeMessage:)]];
//    }
//    
//    if (message.messageType == NIMMessageTypeAudio) {
//        [items addObject:[[UIMenuItem alloc] initWithTitle:@"转文字" action:@selector(audio2Text:)]];
//    }
    
    return items;
    
}

- (void)audio2Text:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) wself = self;
    NTESAudio2TextViewController *vc = [[NTESAudio2TextViewController alloc] initWithMessage:message];
    vc.completeHandler = ^(void){
        [wself uiUpdateMessage:message];
    };
    [self presentViewController:vc
                       animated:YES
                     completion:nil];
}


- (void)forwardMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择会话类型" delegate:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"个人",@"群组", nil];
    __weak typeof(self) weakSelf = self;
    [sheet showInView:self.view completionHandler:^(NSInteger index) {
        switch (index) {
            case 0:{
                NIMContactFriendSelectConfig *config = [[NIMContactFriendSelectConfig alloc] init];
                config.needMutiSelected = NO;
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *userId = array.firstObject;
                    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 1:{
                NIMContactTeamSelectConfig *config = [[NIMContactTeamSelectConfig alloc] init];
                NIMContactSelectViewController *vc = [[NIMContactSelectViewController alloc] initWithConfig:config];
                vc.finshBlock = ^(NSArray *array){
                    NSString *teamId = array.firstObject;
                    NIMSession *session = [NIMSession session:teamId type:NIMSessionTypeTeam];
                    [weakSelf forwardMessage:message toSession:session];
                };
                [vc show];
            }
                break;
            case 2:
                break;
            default:
                break;
        }
    }];
}


- (void)revokeMessage:(id)sender
{
    NIMMessage *message = [self messageForMenu];
    __weak typeof(self) weakSelf = self;
    [[NIMSDK sharedSDK].chatManager revokeMessage:message completion:^(NSError * _Nullable error) {
        if (error) {
            if (error.code == NIMRemoteErrorCodeDomainExpireOld) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送时间超过2分钟的消息，不能被撤回" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                [alert show];
            }else{
                NSLog(@"revoke message eror code %zd",error.code);
                [weakSelf.view makeToast:@"消息撤回失败，请重试" duration:2.0 position:CSToastPositionCenter];
            }
        }
        else
        {
            NIMMessageModel *model = [self uiDeleteMessage:message];
            NIMMessage *tip = [NTESSessionMsgConverter msgWithTip:[NTESSessionUtil tipOnMessageRevoked:message]];
            tip.timestamp = model.messageTime;
            [self uiInsertMessages:@[tip]];
            
            tip.timestamp = message.timestamp;
            // saveMessage 方法执行成功后会触发 onRecvMessages: 回调，但是这个回调上来的 NIMMessage 时间为服务器时间，和界面上的时间有一定出入，所以要提前先在界面上插入一个和被删消息的界面时间相符的 Tip, 当触发 onRecvMessages: 回调时，组件判断这条消息已经被插入过了，就会忽略掉。
            [[NIMSDK sharedSDK].conversationManager saveMessage:tip forSession:message.session completion:nil];
        }
    }];
}

- (void)forwardMessage:(NIMMessage *)message toSession:(NIMSession *)session
{
    NSString *name;
    if (session.sessionType == NIMSessionTypeP2P)
    {
        NIMKitInfoFetchOption *option = [[NIMKitInfoFetchOption alloc] init];
        option.session = session;
        name = [[NIMKit sharedKit] infoByUser:session.sessionId option:option].showName;
    }
    else
    {
        name = [[NIMKit sharedKit] infoByTeam:session.sessionId option:nil].showName;
    }
    NSString *tip = [NSString stringWithFormat:@"确认转发给 %@ ?",name];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确认转发" message:tip delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
    
    __weak typeof(self) weakSelf = self;
    [alert showAlertWithCompletionHandler:^(NSInteger index) {
        if(index == 1)
        {
            if (message.messageType == NIMMessageTypeRobot)
            {
                NIMMessage *forwardMessage = [NTESSessionMsgConverter msgWithText:message.text];
                [[NIMSDK sharedSDK].chatManager sendMessage:forwardMessage toSession:session error:nil];
            }
            else
            {
                [[NIMSDK sharedSDK].chatManager forwardMessage:message toSession:session error:nil];
            }
            [weakSelf.view makeToast:@"已发送" duration:2.0 position:CSToastPositionCenter];
        }
    }];
}

#pragma mark - 辅助方法
- (void)sendImageMessagePath:(NSString *)path
{
    
    [self sendSnapchatMessagePath:path];
}


- (BOOL)checkRTSCondition
{
    BOOL result = YES;
    
//    if (![[Reachability reachabilityForInternetConnection] isReachable])
//    {
//        [self.view makeToast:@"请检查网络" duration:2.0 position:CSToastPositionCenter];
//        result = NO;
//    }
    NSString *currentAccount = [[NIMSDK sharedSDK].loginManager currentAccount];
    if (self.session.sessionType == NIMSessionTypeP2P && [currentAccount isEqualToString:self.session.sessionId])
    {
        [self.view makeToast:@"不能和自己通话哦" duration:2.0 position:CSToastPositionCenter];
        result = NO;
    }
    if (self.session.sessionType == NIMSessionTypeTeam)
    {
        NIMTeam *team = [[NIMSDK sharedSDK].teamManager teamById:self.session.sessionId];
        NSInteger memberNumber = team.memberNumber;
        if (memberNumber < 2)
        {
            [self.view makeToast:@"无法发起，群人数少于2人" duration:2.0 position:CSToastPositionCenter];
            result = NO;
        }
    }
    return result;
}

- (NSDictionary *)cellActions
{
    static NSDictionary *actions = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = @{@(NIMMessageTypeImage) :    @"showImage:",
                    @(NIMMessageTypeVideo) :    @"showVideo:",
                    @(NIMMessageTypeLocation) : @"showLocation:",
                    @(NIMMessageTypeFile)  :    @"showFile:",
                    @(NIMMessageTypeText)  :    @"showText:",
                    @(NIMMessageTypeCustom):    @"showCustom:"};
    });
    return actions;
}

- (NIMKitMediaFetcher *)mediaFetcher
{
    if (!_mediaFetcher) {
        _mediaFetcher = [[NIMKitMediaFetcher alloc] init];
        _mediaFetcher.limit = 1;
        _mediaFetcher.mediaTypes = @[(NSString *)kUTTypeImage];;;
    }
    return _mediaFetcher;
}

//- (void)setUpNav{
//    UIButton *enterTeamCard = [UIButton buttonWithType:UIButtonTypeCustom];
//    [enterTeamCard addTarget:self action:@selector(enterTeamCard:) forControlEvents:UIControlEventTouchUpInside];
//    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
//    [enterTeamCard setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
//    [enterTeamCard sizeToFit];
//    UIBarButtonItem *enterTeamCardItem = [[UIBarButtonItem alloc] initWithCustomView:enterTeamCard];
//    
//    UIButton *infoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [infoBtn addTarget:self action:@selector(enterPersonInfoCard:) forControlEvents:UIControlEventTouchUpInside];
//    [infoBtn setImage:[UIImage imageNamed:@"icon_session_info_normal"] forState:UIControlStateNormal];
//    [infoBtn setImage:[UIImage imageNamed:@"icon_session_info_pressed"] forState:UIControlStateHighlighted];
//    [infoBtn sizeToFit];
//    UIBarButtonItem *enterUInfoItem = [[UIBarButtonItem alloc] initWithCustomView:infoBtn];
//    
//    UIButton *historyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [historyBtn addTarget:self action:@selector(enterHistory:) forControlEvents:UIControlEventTouchUpInside];
//    [historyBtn setImage:[UIImage imageNamed:@"icon_history_normal"] forState:UIControlStateNormal];
//    [historyBtn setImage:[UIImage imageNamed:@"icon_history_pressed"] forState:UIControlStateHighlighted];
//    [historyBtn sizeToFit];
//    UIBarButtonItem *historyButtonItem = [[UIBarButtonItem alloc] initWithCustomView:historyBtn];
//    
//    
//    UIButton *robotInfoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [robotInfoBtn addTarget:self action:@selector(enterRobotInfoCard:) forControlEvents:UIControlEventTouchUpInside];
//    [robotInfoBtn setImage:[UIImage imageNamed:@"icon_robot_card_normal"] forState:UIControlStateNormal];
//    [robotInfoBtn setImage:[UIImage imageNamed:@"icon_robot_card_pressed"] forState:UIControlStateHighlighted];
//    [robotInfoBtn sizeToFit];
//    UIBarButtonItem *robotInfoButtonItem = [[UIBarButtonItem alloc] initWithCustomView:robotInfoBtn];
//    
//    
//    if (self.session.sessionType == NIMSessionTypeTeam)
//    {
//        self.navigationItem.rightBarButtonItems  = @[enterTeamCardItem,historyButtonItem];
//    }
//    else if(self.session.sessionType == NIMSessionTypeP2P)
//    {
//        if ([self.session.sessionId isEqualToString:[[NIMSDK sharedSDK].loginManager currentAccount]])
//        {
//            self.navigationItem.rightBarButtonItems = @[historyButtonItem];
//        }
//        else if([[NIMSDK sharedSDK].robotManager isValidRobot:self.session.sessionId])
//        {
//            self.navigationItem.rightBarButtonItems = @[historyButtonItem,robotInfoButtonItem];
//        }
//        else
//        {
//            self.navigationItem.rightBarButtonItems = @[enterUInfoItem,historyButtonItem];
//        }
//    }
//}

- (BOOL)shouldAutorotate{
    return !self.currentSingleSnapView;
}

@end

