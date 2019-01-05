//
//  JAMessageViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAMessageViewController.h"
#import "JAMessageTableViewCell.h"
#import "JAMessageTopView.h"
#import "JASessionViewController.h"
#import "JAPersonalCenterViewController.h"
#import "JAWebViewController.h"
#import "JABaseViewController+QiYuSDK.h"
#import "JAOfficViewController.h"

#import "JAVoiceCommonApi.h"

@interface JAMessageViewController () <
UITableViewDelegate,
UITableViewDataSource,
JAMessageTableViewCellDelegate,
NIMConversationManagerDelegate>

@property (nonatomic, strong) UILabel *messageInfomationLabel;
@property (nonatomic, strong) UITableView *tableView;
/// 好友聊天消息列表
@property (nonatomic, strong) NSMutableArray *conversationArrM;

@end

@implementation JAMessageViewController

- (void)dealloc
{
    [[NIMSDK sharedSDK].conversationManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)hidesBottomBarWhenPushed {
    return NO;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // 一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeMessage];  // 这里重置是因为 总的控制器要接受通知。（这个重置只是发了一个通知）
    
    // tableView
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64)];
    tableView.backgroundColor = [UIColor clearColor];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    JAMessageTopView *topView = [[[NSBundle mainBundle] loadNibNamed:@"JAMessageTopView" owner:nil options:nil] lastObject];
    _heardView = topView;
    topView.height = 213;
    self.tableView.tableHeaderView = topView;
    
    // 设置按钮的点击
    [self.heardView.officButton addTarget:self action:@selector(clickOffic:) forControlEvents:UIControlEventTouchUpInside];
    [self.heardView.customerButton addTarget:self action:@selector(clickCustomer:) forControlEvents:UIControlEventTouchUpInside];
    [self.heardView.noticeButton addTarget:self action:@selector(clickNoticeButton:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *moliJunTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpMoliJunCenter)];
    UITapGestureRecognizer *moliJunTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpMoliJunCenter)];
    [self.heardView.moliJunImageView addGestureRecognizer:moliJunTap];
    [self.heardView.moliJunName addGestureRecognizer:moliJunTap1];
    
    [[NIMSDK sharedSDK].conversationManager addDelegate:self];
    
    
    // 监听红点到达 --- 主要是茉莉君/客服
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointArrive" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointDismiss" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccessRefreshData) name:LOGINSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginOutResetData) name:@"app_loginOut" object:nil];
    
    [self getMessageData];
}

- (void)loginSuccessRefreshData
{
    [self getMessageData];
}

- (void)loginOutResetData
{
    [self.conversationArrM removeAllObjects];
    [self.tableView reloadData];
}

- (void)getMessageData
{
    // 获取普通消息
    _conversationArrM = [[JAChatMessageManager yx_getAllChatSession] mutableCopy];
    if (!self.conversationArrM.count) {
        _conversationArrM = [NSMutableArray array];
    }else{
        [self.tableView reloadData];
    }
    // 获取客服消息
    [self getKeFuMessage:^(NSString *lastMsg, NSInteger count) {
        self.heardView.keFucount = count;
        self.heardView.keFuMessage = lastMsg;
    }];
    
    // 获取茉莉君的数据
    [self getMoliJunInfo:^(NSString *lastMsg, NSInteger count) {
        self.heardView.moliJunCount = count;
        self.heardView.moliJunMessage = lastMsg;
    }];
    
    // 获取小秘书消息
    [self getServerRecentInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"私信列表";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)redPointArrive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 获取茉莉君的数量
        [self getMoliJunInfo:^(NSString *lastMsg, NSInteger count) {
            self.heardView.moliJunCount = count;
            self.heardView.moliJunMessage = lastMsg;
        }];
        
        // 获取客服消息
        [self getKeFuMessage:^(NSString *lastMsg, NSInteger count) {
            self.heardView.keFucount = count;
            self.heardView.keFuMessage = lastMsg;
        }];
    });
}

#pragma mark - 获取茉莉君的信息
// 获取茉莉君的信息
- (void)getMoliJunInfo:(void(^)(NSString *lastMsg, NSInteger count))finishBlock
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAVoiceCommonApi shareInstance] voice_getOfficDetailInfo:dic success:^(NSDictionary *result) {
        
        NSInteger unReadCount = [result[@"notReadCount"] integerValue];
        NSString *content = result[@"lastMsgTitle"];
        
        if (finishBlock) {
            finishBlock(content,unReadCount);
        }
        
    } failure:^{
        
    }];
}

#pragma mark - Private Action
// 获取茉莉小秘书列表
- (void)getServerRecentInfo
{
    NIMRecentSession *session = [JAChatMessageManager yx_getServermoliMessage];
    self.heardView.recentSession = session;
}

- (void)jumpMoliJunCenter
{
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    JAConsumer *model = [[JAConsumer alloc] init];
    model.userId = @"1000449";
    model.name = @"茉莉君";
    model.image = @"http://file.xsawe.top//file/1515057390234cadbc939-94f5-4e51-87ae-ffb49eb116ac.png";
    vc.personalModel = model;
    [self.navigationController pushViewController:vc animated:YES];
   
}

// 跳转小秘书
- (void)clickOffic:(UIButton *)btn
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"茉莉小秘书";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    
    NSString *userId = JA_OFFIC_SERVERMOLI;
    NIMSession *session = [NIMSession session:userId type:NIMSessionTypeP2P];
    JASessionViewController *vc = [[JASessionViewController alloc] initWithSession:session];
    vc.isSecretary = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

// 跳转客服
- (void)clickCustomer:(UIButton *)btn
{   
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"茉莉客服";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    [AppDelegate sharedInstance].playerView.hidden = YES;
    [self setupQiYuViewController];
}

// 跳转茉莉君
- (void)clickNoticeButton:(UIButton *)btn
{
    JAOfficViewController *vc = [[JAOfficViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark UITableView delegate and dataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.conversationArrM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idstring = @"JAMessageTableViewCellID";
    JAMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idstring];
    if (cell == nil)
    {
        cell = [[JAMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idstring];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    // 传递消息数据
    cell.conversation = self.conversationArrM[indexPath.row];
    return cell;
}

// 编辑删除
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    NIMRecentSession *con = self.conversationArrM[indexPath.row];
    
    [JAChatMessageManager yx_deleteSession:con];
    [self.conversationArrM removeObject:con];
    [self.tableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([JAAPPManager app_checkGag]) {
//        return;
//    }
    NIMRecentSession *conversation = self.conversationArrM[indexPath.row];
    
    // 获取消息中的双方的官方状态
    __block NSString *otherOffic = nil;
    __block NSString *myOffic = nil;
    NIMMessage *lastM = conversation.lastMessage;
    // 获取最后一个对方的消息 - 判断是不是自己的消息
    NSString *fromId = [lastM.from substringFromIndex:4];
    // 获取自己的id
    NSString *myId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    if ([myId isEqualToString:fromId]) {   // 该条消息是自己的
        // 获取对方的官方状态
        if (lastM.remoteExt) {
            NSDictionary *dic = lastM.remoteExt;
            otherOffic = dic[@"otherOffic"];
            myOffic = dic[@"myOffic"];
        }
    }else{
        if (lastM.remoteExt) {
            
            NSDictionary *dic = lastM.remoteExt;
            otherOffic = dic[@"myOffic"];
            myOffic = dic[@"otherOffic"];
        }
       
    }
    
    JAMessageTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_MessageId] = cell.chatUid;
    senDic[JA_Property_MessageName] = cell.chatName;
    [JASensorsAnalyticsManager sensorsAnalytics_enterMessage:senDic];
    
    [JAYXMessageManager app_getChatLimitsWithYXuserId:conversation.session.sessionId finish:^(JAChatLimitsType code) {
        
        [JAChatMessageManager yx_getUserInfo:@[conversation.session.sessionId] complete:^(NSArray<NIMUser *> * _Nullable users) {
           
            NIMUser *user = users.firstObject;
            
            NSLog(@"%@",user.userInfo.ext);
            NSString *officExt = user.userInfo.ext;
            
            if (officExt.length) {
                NSDictionary *officDic = [officExt mj_JSONObject];
                NSString *offic = officDic[@"extMap"][@"achievementId"];
                
                if (offic.integerValue == 1) {
                    otherOffic = @"1";
                }else{
                    otherOffic = @"0";
                }
            }
            
            JASessionViewController *vc = [[JASessionViewController alloc] initWithSession:conversation.session];
            vc.myOffic = myOffic;
            vc.otherOffic = otherOffic;
            [self.navigationController pushViewController:vc animated:YES];
        }];
        
    }];
}

#pragma mark - JAMessageTableViewCellDelegate
// 跳转个人中心代理
- (void)message_jumpPersonalCenterWithUserId:(NSString *)uid
{
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    JAConsumer *model = [[JAConsumer alloc] init];
    model.userId = uid;
    vc.personalModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NIMConversationManagerDelegate

- (NSInteger)findInsertPlace:(NIMRecentSession *)recentSession{
    __block NSUInteger matchIdx = 0;
    __block BOOL find = NO;
    [self.conversationArrM enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NIMRecentSession *item = obj;
        if (item.lastMessage.timestamp <= recentSession.lastMessage.timestamp) {
            *stop = YES;
            find  = YES;
            matchIdx = idx;
        }
    }];
    if (find) {
        return matchIdx;
    }else{
        return self.conversationArrM.count;
    }
}

- (void)sort{
    [self.conversationArrM sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NIMRecentSession *item1 = obj1;
        NIMRecentSession *item2 = obj2;
        if (item1.lastMessage.timestamp < item2.lastMessage.timestamp) {
            return NSOrderedDescending;
        }
        if (item1.lastMessage.timestamp > item2.lastMessage.timestamp) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
}

- (void)didAddRecentSession:(NIMRecentSession *)recentSession
           totalUnreadCount:(NSInteger)totalUnreadCount{
    if ([recentSession.session.sessionId isEqualToString:JA_OFFIC_SERVERMOLI]) {
        [self getServerRecentInfo];
    } else {
        [self.conversationArrM addObject:recentSession];
        [self sort];
        [self.tableView reloadData];
    }
}

- (void)didUpdateRecentSession:(NIMRecentSession *)recentSession
              totalUnreadCount:(NSInteger)totalUnreadCount{
    if ([recentSession.session.sessionId isEqualToString:JA_OFFIC_SERVERMOLI]) {
        [self getServerRecentInfo];
    }else{
        for (NIMRecentSession *recent in self.conversationArrM) {
            if ([recentSession.session.sessionId isEqualToString:recent.session.sessionId]) {
                [self.conversationArrM removeObject:recent];
                break;
            }
        }
        NSInteger insert = [self findInsertPlace:recentSession];
        [self.conversationArrM insertObject:recentSession atIndex:insert];
        [self.tableView reloadData];
    }
}

- (void)messagesDeletedInSession:(NIMSession *)session{
    _conversationArrM = [[JAChatMessageManager yx_getAllChatSession] mutableCopy];
    [self.tableView reloadData];
}

- (void)allMessagesDeleted{
    _conversationArrM = [[JAChatMessageManager yx_getAllChatSession] mutableCopy];
    [self.tableView reloadData];
}

@end
