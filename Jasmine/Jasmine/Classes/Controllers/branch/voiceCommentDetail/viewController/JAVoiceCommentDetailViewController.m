////
////  JAVoiceReplyDetailViewController.m
////  Jasmine
////
////  Created by moli-2017 on 2017/8/29.
////  Copyright © 2017年 xujin. All rights reserved.
////
//
#import "JAVoiceCommentDetailViewController.h"
//#import "JACommonCommentCell.h"
//#import "JAVoiceCommentHeaderView.h"
//#import "JAVoiceApi.h"
//#import "JAVoiceCommentApi.h"
//#import "JAVoiceCommentGroupModel.h"
//#import "JAVoiceCommentModel.h"
//#import "JAPaddingLabel.h"
//
//#import "JAVoiceReplyDetailViewController.h"
//#import "JAInviteViewController.h"
//#import "JAWebViewController.h"
//
//#import "JAVoiceRecordViewController.h"
//#import "JAPersonalCenterViewController.h"
//#import "JAVoicePersonApi.h"
//#import "JAVoiceCommonApi.h"
//
//#import "JAFunctionToolV.h"
//#import "JAPlatformShareManager.h"
//#import "JAPersonBlankCell.h"
//#import "JADeleteReasonModel.h"
//
//#import "JAInputView.h"
//#import "JASampleHelper.h"
//#import "JAVoiceReplyApi.h"
//#import "JAVoiceCommentApi.h"
//#import "JAUserApiRequest.h"
//#import "JAPersonTopicViewController.h"
//#import "JADataHelper.h"
//#import "JAVoicePlayerManagerdian.h"
//
//#import "JAPlayLocalVoiceManager.h"
//#import "JAReplyKeyBoardView.h"
//
//#define kHeaderBase 228
//#define kHeaderBasePic (228 - 50 + WIDTH_ADAPTER(85))
//#define kVoiceRecordIphoneX ((iPhoneX) ? 122 : 64)
//
//@interface JAVoiceCommentDetailViewController ()<UITableViewDelegate, UITableViewDataSource, JAPlayerDelegate, PlatformShareDelegate,JAInputViewDelegate>
//
//@property (nonatomic, strong) NSString *storyUserId;  // 评论界面 - 回复详情界面都需要的
//
//@property (nonatomic, weak) UITableView *tableView;
//@property (nonatomic, weak) JAVoiceCommentHeaderView *headerView;
//@property (nonatomic, strong) JAInputView *inputView;
//@property (nonatomic, strong) UILabel *shareLabel;
//
//// 组头
//@property (nonatomic, strong) UIView *sectionView;
//@property (nonatomic, weak) UILabel *sectionLabel;
//@property (nonatomic, weak) UIView *lineView;
//@property (nonatomic, weak) UIButton *inviteButton;
//@property (nonatomic, weak) JAPaddingLabel *inviteLabel;
//@property (nonatomic, weak) UIButton *sortButton;
//@property (nonatomic, weak) UIButton *hotButton;
//@property (nonatomic, weak) UIButton *moreNewButton;
//
//@property (nonatomic, assign) NSInteger currentPage;
//@property (nonatomic, strong) NSMutableArray *dataSourceArray;
//
//@property (nonatomic, strong) JAVoiceModel *voiceModel;   // 主帖
//@property (nonatomic, strong) JAVoiceCommentModel *selectaaaa;   // 主帖
//@property (nonatomic, strong) JAVoiceCommentGroupModel *groupModel;
//
//@property (nonatomic, assign) BOOL isNewList;  // 最新的评论列表
//@property (nonatomic, assign) int allCount;// 主帖
//@property (nonatomic, assign) int allSubCount;// 评论
//
//// 回复评论的那行cell的索引
////@property (nonatomic, assign) NSInteger needRefreshIndex;
//@property (nonatomic, strong) JAVoiceCommentModel *needRefreshModel;  // 需要更新的model
//
//@property (nonatomic, assign) BOOL requestFaile;  // 判断是否可以右上角分享
//@property (nonatomic, assign) BOOL needShare; // 判断是否需要调用分享
//
//@property (nonatomic, assign) NSInteger requestStatus;   // 用来设置cell没有数据的样式
//
////@property (nonatomic, assign) NSInteger tapCount;    // cell的单双击
////@property (nonatomic, strong) NSIndexPath *tapIndex;
//
//@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
//
//@property (nonatomic, strong) NSIndexPath *frontIndex;  // 前一个点击的cell
//@property (nonatomic, assign) BOOL replyPosts;  // YES 回复的是帖子   NO 回复的评论或者回复
//
//// 需要滚动的位置
//@property (nonatomic, strong) NSIndexPath *scrollIndex;
//
//// 发布用参数
//@property (nonatomic, assign) BOOL anonymous;
//
//@property (nonatomic, weak) JAReplyKeyBoardView *bottomView;  // 底部键盘
//@end
//
@implementation JAVoiceCommentDetailViewController
//
//
//- (BOOL)fd_interactivePopDisabled
//{
//    if (self.inputView.isRespondStatus) {
//        return YES;
//    }
//    return NO;
//}
//
//- (void)dealloc {
//    [self.inputView inputviewDealloc];
//    [[JAVoicePlayerManager shareInstance] removeDelegate:self];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//    [self.currentProgressHUD hideAnimated:NO];
//}
//
//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[JA_Property_ScreenName] = @"主帖详情";
//    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
//}
//
//- (void)viewWillDisappear:(BOOL)animated
//{
//    [super viewWillDisappear:animated];
//    
//    [[JAPlayLocalVoiceManager sharePlayVoiceManager] stopLocalVoice];
//}
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    _dataSourceArray = [NSMutableArray array];
//    
//    // 设置导航条
//    [self setupNavRightButton];
//    
//    // 设置组头
//    [self setupSectionView];
//    
//    // 设置UI
//    [self setupVoiceReplyUI];
//    
//    // 获取单条帖子详情数据
//    [self getVoiceDetail];
//   
//    @WeakObj(self);
//    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
//        @StrongObj(self);
//        [self getVoiceCommentList:NO];
//    }];
//    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        @StrongObj(self);
//        [self getVoiceCommentList:YES];
//    }];
//    
////    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshUserName:) name:@"actionAnonymity" object:nil];
//}
//
//// 设置右边导航按钮
//- (void)setupNavRightButton
//{
//    UIView *shareView = [[UIView alloc] init];
//    shareView.width = 50;
//    shareView.height = shareView.width;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRight_share)];
//    [shareView addGestureRecognizer:tap];
//    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [shareButton setImage:[UIImage imageNamed:@"voice_share"] forState:UIControlStateNormal];
//    shareButton.userInteractionEnabled = NO;
//    shareButton.width = 20;
//    shareButton.height = shareButton.width;
//    shareButton.centerX = shareView.width * 0.5 + 5;
//    shareButton.centerY = shareView.height * 0.5;
//    [shareView addSubview:shareButton];
//    
//    
//    self.shareLabel = [[UILabel alloc] init];
//    self.shareLabel.text = @"0";
//    self.shareLabel.textColor = HEX_COLOR(0xffffff);
//    self.shareLabel.font = JA_REGULAR_FONT(10);
//    self.shareLabel.backgroundColor = HEX_COLOR(0xFF7054);
//    self.shareLabel.x = shareButton.x + 10;
//    [self.shareLabel sizeToFit];
//    self.shareLabel.height = 10;
//    self.shareLabel.width = self.shareLabel.width + 6;
//    self.shareLabel.textAlignment = NSTextAlignmentCenter;
//    self.shareLabel.layer.cornerRadius = self.shareLabel.height * 0.5;
//    self.shareLabel.layer.masksToBounds = YES;
//    self.shareLabel.y = shareView.width- 7 - self.shareLabel.height - 8;
//    self.shareLabel.hidden = YES;
//    [shareView addSubview:self.shareLabel];
//    
//    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareView];
//    
//    UIButton *pointButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [pointButton setImage:[UIImage imageNamed:@"detail_right_report"] forState:UIControlStateNormal];
//    pointButton.width = 30;
//    pointButton.height = pointButton.width;
//    [pointButton addTarget:self action:@selector(clickRight_point) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *pointItem = [[UIBarButtonItem alloc] initWithCustomView:pointButton];
//    
//    UIButton *checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [checkButton setTitle:@"审核" forState:UIControlStateNormal];
//    [checkButton setTitleColor:HEX_COLOR(0x0080FF) forState:UIControlStateNormal];
//    checkButton.titleLabel.font = JA_REGULAR_FONT(18);
//    checkButton.width = 50;
//    checkButton.height = 30;
//    [checkButton addTarget:self action:@selector(clickRight_check) forControlEvents:UIControlEventTouchUpInside];
//    UIBarButtonItem *checkItem = [[UIBarButtonItem alloc] initWithCustomView:checkButton];
//    
//    if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
//        self.navigationItem.rightBarButtonItems = @[pointItem,shareItem,checkItem];
//    }else{
//        self.navigationItem.rightBarButtonItems = @[pointItem,shareItem];
//    }
//    
//}
//
//#pragma mark - 右上角三个点
//- (void)clickRight_check   // 审核
//{
//    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//        [self registKeyBoard];
//        
//    }
//    NSString *power = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
//    if (power.integerValue == JAPOWER) {
//        @WeakObj(self);
//        [JADetailClickManager detail_clickCellPopWindowsWithType:JA_STORY_TYPE typeModel:self.voiceModel DeleteAction:^{
//            @StrongObj(self);
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            dic[@"voiceId"] = self.voiceId;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"AdminDelVoice" object:dic];
//            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"删除成功"];
//            [self.navigationController popViewControllerAnimated:YES];
//        } storyUserId:self.storyUserId floatType:JADetailClickTypeNoRecord recordAction:nil];
//    }
//}
//
//- (void)clickRight_point
//{
//    if (self.requestFaile) {
//        return;
//    }
//    
//    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//        [self registKeyBoard];
//        return;
//    }
//    
//    AppDelegate *appDelegate = [AppDelegate sharedInstance];
//    appDelegate.shareDelegate = self;
//    
//    JAParticularsReportType type = JAParticularsReportCollect;
//    // 判断是不是自己
//    if ([self.voiceModel.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
//        type = JAParticularsCollectDelete;
//    }
//    
//    @WeakObj(self);
//    JAFunctionToolV *shareView = [[JAFunctionToolV alloc] functionToolV:type];
//    
////    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
////    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
////    dic[@"typeId"] = self.voiceModel.voiceId;
////    dic[@"type"] = JA_STORY_TYPE;
////
////    [[JAVoicePersonApi shareInstance] voice_collectStatusWithParas:dic success:^(NSDictionary *result) {
////        if ([result[@"isCollent"] integerValue] == 1) {
////            shareView.collectButton.selected = YES;
////        }else if ([result[@"isCollent"] integerValue] == 2){
////            shareView.collectButton.selected = NO;
////        }
////
////    } failure:^(NSError *error) {
////
////    }];
//    
//    shareView.shareWitnIndex = ^(NSInteger index) {
//        @StrongObj(self);
//        if (index == 0) {       // 朋友圈
//            
//            self.needShare = YES;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"朋友圈"];
//            JAShareModel *model = [[JAShareModel alloc] init];
//            model.title = self.voiceModel.shareWxContent;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
//            [JAPlatformShareManager wxShareMusic:WeiXinShareTypeSession shareContent:model];
////            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:0];
//        }else if (index == 1){      // 好友
//            self.needShare = NO;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"微信聊天"];
//            [self shareRequestServer:NO methodType:0];
//            JAShareModel *model = [[JAShareModel alloc] init];
//            model.title = self.voiceModel.shareWxContent;
//            model.descripe = self.voiceModel.shareTitle;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
////            [JAPlatformShareManager wxShareMusic:WeiXinShareTypeTimeline shareContent:model];
//            [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:0];
//            
//        }else if (index == 2){     // qq好友
//            self.needShare = NO;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"qq"];
//            [self shareRequestServer:NO methodType:0];
//            JAShareModel *model = [JAShareModel new];
//            model.title = self.voiceModel.shareWxContent;
//            model.descripe = self.voiceModel.shareTitle;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
//            [JAPlatformShareManager qqShareMusic:QQShareTypeFriend shareContent:model];
////            [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:0];
//        }else if (index == 3){         // qq空间
//            
//            self.needShare = YES;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"qq空间"];
//            JAShareModel *model = [JAShareModel new];
//            model.title = self.voiceModel.shareWxContent;
//            model.descripe = self.voiceModel.shareTitle;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
////            [JAPlatformShareManager qqShareMusic:QQShareTypeZone shareContent:model];
//            [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:0];
//        }else if (index == 4){        // 微博
//            
//            self.needShare = YES;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"微博"];
//            JAShareModel *model = [[JAShareModel alloc] init];
//            model.title = self.voiceModel.shareWBContent;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            [JAPlatformShareManager wbShareWithshareContent:model domainType:0];
//            
//        }
//    };
//    
//    shareView.funcWitnIndex = ^(NSInteger index, BOOL selected) {
//        if (index == 0) {
//            @StrongObj(self);
//
//            if (!IS_LOGIN) {
//                [JAAPPManager app_modalLogin];
//                return;
//            }
//            
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//            dic[@"typeId"] = self.voiceModel.voiceId;
//            dic[@"type"] = JA_STORY_TYPE;
//            
//            [[JAVoicePersonApi shareInstance] voice_insertCollectListWithParas:dic success:^(NSDictionary *result) {
//                if ([result[@"isCollent"] integerValue] == 1) {
//                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"收藏成功"];
//                }else if ([result[@"isCollent"] integerValue] == 2){
//                    [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"取消成功"];
//                }
//                
//                
//                // 神策数据
//                JAVoiceModel *voiceModel = self.voiceModel;
//                NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//                senDic[JA_Property_ContentId] = voiceModel.voiceId;
//                senDic[JA_Property_ContentTitle] = voiceModel.content;
////                senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[voiceModel.categoryId];
//                senDic[JA_Property_Anonymous] = @(voiceModel.isAnonymous);
//                senDic[JA_Property_RecordDuration] = @([NSString getSeconds:voiceModel.time]);
//                senDic[JA_Property_PostId] = voiceModel.userId;
//                senDic[JA_Property_PostName] = voiceModel.userName;
//                if ([result[@"isCollent"] integerValue] == 1) {
//                    senDic[JA_Property_BindingType] = @"收藏";
//                } else {
//                    senDic[JA_Property_BindingType] = @"取消收藏";
//                }
//                [JASensorsAnalyticsManager sensorsAnalytics_collect:senDic];
//                
//            } failure:^(NSError *error) {
//                [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
//            }];
//            
//            
//        }else if (index == 1){
//            @StrongObj(self);
//            if (!IS_LOGIN) {
//                [JAAPPManager app_modalLogin];
//                return;
//            }
//            
//            if (type == JAParticularsReportCollect) {  // 举报
//                
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//                
//                for (NSInteger i = 0; i < [JAConfigManager shareInstance].deleteReasonArray.count; i++) {
//                    
//                    JADeleteReasonModel *deletemodel = [JAConfigManager shareInstance].deleteReasonArray[i];
//                    
//                    UIAlertAction *action = [UIAlertAction actionWithTitle:deletemodel.content style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                        [self reportContentWithType:JA_STORY_TYPE contentId:self.voiceModel.voiceId reason:deletemodel.content];
//                    }];
//                    
//                    [alert addAction:action];
//                }
//                
//                UIAlertAction *cancleaction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                    
//                }];
//                [alert addAction:cancleaction];
//                [self presentViewController:alert animated:YES completion:nil];
//                
//            }else if(type == JAParticularsCollectDelete){   // 删除
//                
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:@"" preferredStyle:UIAlertControllerStyleAlert];
//                
//                UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                }];
//                UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                    
//                    [self deleteVoiceDateWithTypeModel:self.voiceModel];
//                    
//                }];
//                
//                [alert addAction:action1];
//                [alert addAction:action2];
//                
//                [[AppDelegateModel rootviewController] presentViewController:alert animated:YES completion:nil];
//            }
//            
//        }
//    };
//    
//    [shareView show];
//}
//
//#pragma mark - 删除帖子  举报帖子
//// 删除帖子
//- (void)deleteVoiceDateWithTypeModel:(JAVoiceModel *)model
//{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    dic[@"id"] = model.voiceId;
//    dic[@"power"] = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
//    [[JAVoiceApi shareInstance] voice_deleteVoiceWithParas:dic success:^(NSDictionary *result) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        dic[@"voiceId"] = self.voiceId;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"AdminDelVoice" object:dic];
//        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"删除成功"];
//        [self.navigationController popViewControllerAnimated:YES];
//    } failure:^(NSError *error) {
//        [[UIApplication sharedApplication].keyWindow ja_makeToast:error.localizedDescription];
//    }];
//}
//
//// 举报
//- (void)reportContentWithType:(NSString *)type contentId:(NSString *)typeId reason:(NSString *)reason
//{
//    // 举报
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    dic[@"type"] = type;
//    dic[@"reportTypeId"] = typeId;
//    dic[@"content"] = reason;
//    
//    [[JAVoicePersonApi shareInstance] voice_personalReportUserWithParas:dic success:^(NSDictionary *result) {
//        
//        
//        // 神策数据
//        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//        senDic[JA_Property_ReportTeason] = reason;
//        JAVoiceModel *voiceM = self.voiceModel;
//        senDic[JA_Property_ReportType] = @"主帖";
//        senDic[JA_Property_PostId] = voiceM.userId;
//        senDic[JA_Property_PostName] = voiceM.userName;
//        senDic[JA_Property_ContentId] = voiceM.voiceId;
//        senDic[JA_Property_ContentTitle] = voiceM.content;
//        
//        [JASensorsAnalyticsManager sensorsAnalytics_reportPerson:senDic];
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"举报成功"];
//    } failure:^(NSError *error) {
//    }];
//}
//
//#pragma mark - 右上角分享
//- (void)clickRight_share
//{
//    if (self.requestFaile) {
//        return;
//    }
//    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//        [self registKeyBoard];
//        return;
//    }
//    
//    AppDelegate *appDelegate = [AppDelegate sharedInstance];
//    appDelegate.shareDelegate = self;
//    @WeakObj(self);
//    JAFunctionToolV *shareView = [JAFunctionToolV shareToolV];
//    shareView.shareWitnIndex = ^(NSInteger index) {
//        @StrongObj(self);
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            // 不论分享成功与否，分享数均增加1
//            NSInteger shareCount = [self.voiceModel.shareCount integerValue];
//            self.voiceModel.shareCount = [NSString stringWithFormat:@"%zd",shareCount+1];
//            if (self.voiceModel.shareCount.integerValue > 0) {
//                self.shareLabel.hidden = NO;
//            }
//            self.shareLabel.text = self.voiceModel.shareCount;
//            [self.shareLabel sizeToFit];
//            self.shareLabel.height = 10;
//            self.shareLabel.width = self.shareLabel.width + 6;
//        });
//        
//        if (index == 0) {       // 朋友圈
//            
//            self.needShare = YES;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"朋友圈"];
//            JAShareModel *model = [[JAShareModel alloc] init];
//            model.title = self.voiceModel.shareWxContent;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
//            [JAPlatformShareManager wxShareMusic:WeiXinShareTypeSession shareContent:model];
////            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:0];
//        }else if (index == 1){      // 好友
//            self.needShare = NO;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"微信聊天"];
//            [self shareRequestServer:NO methodType:0];
//            JAShareModel *model = [[JAShareModel alloc] init];
//            model.title = self.voiceModel.shareWxContent;
//            model.descripe = self.voiceModel.shareTitle;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
////            [JAPlatformShareManager wxShareMusic:WeiXinShareTypeTimeline shareContent:model];
//            [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:0];
//            
//        }else if (index == 2){     // qq好友
//            self.needShare = NO;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"qq"];
//            [self shareRequestServer:NO methodType:0];
//            JAShareModel *model = [JAShareModel new];
//            model.title = self.voiceModel.shareWxContent;
//            model.descripe = self.voiceModel.shareTitle;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
//            [JAPlatformShareManager qqShareMusic:QQShareTypeFriend shareContent:model];
////            [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:0];
//        }else if (index == 3){         // qq空间
//            
//            self.needShare = YES;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"qq空间"];
//            JAShareModel *model = [JAShareModel new];
//            model.title = self.voiceModel.shareWxContent;
//            model.descripe = self.voiceModel.shareTitle;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            model.music = self.voiceModel.audioUrl;
////            [JAPlatformShareManager qqShareMusic:QQShareTypeZone shareContent:model];
//            [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:0];
//        }else if (index == 4){        // 微博
//            
//            self.needShare = YES;
//            [self sensorsAnalyticsWithModel:self.voiceModel mothod:@"微博"];
//            JAShareModel *model = [[JAShareModel alloc] init];
//            model.title = self.voiceModel.shareWBContent;
//            model.shareUrl = self.voiceModel.shareUrl;
//            model.image = self.voiceModel.shareImg;
//            [JAPlatformShareManager wbShareWithshareContent:model domainType:0];
//            
//        }
//    };
//    [shareView show];
//}
//
//#pragma mark - 匿名切换刷新
////// 刷新按钮
////- (void)refreshUserName:(NSNotification *)noti
////{
////    NSDictionary *dic = noti.userInfo;
////    
////    NSString *name = dic[@"userName"];  // 切换后的名字
////    NSInteger isAnonymous = [dic[@"isAnonymous"] integerValue]; // 新的状态
////    NSString *myId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];  // 我自己的id
////    
////    // 遍历数据源修改名称字段
////    for (NSInteger i = 0; i < self.dataSourceArray.count; i++) {
////        
////        JAVoiceCommentModel *model = self.dataSourceArray[i];
////        if ([myId isEqualToString:model.userId]) {
////            
////            model.isAnonymous = isAnonymous == 1 ? YES : NO;
////            if (isAnonymous) {
////                model.refreshModel = YES;
////                model.anonymousName = name;
////            }
////        }
////        
////        if ([myId isEqualToString:model.s2cReplyMsg.userId]) {
////            model.refreshModel = YES;
////            model.s2cReplyMsg.isAnonymous = isAnonymous == 1 ? YES : NO;
////            if (isAnonymous) {
////                model.s2cReplyMsg.userAnonymousName = name;
////            }
////        }
////        
////    }
////    
////    [self.tableView reloadData];
////}
//
//#pragma mark - 设置UI
//- (void)setupVoiceReplyUI
//{
//    CGFloat safeHeight = 64;
//    if (iPhoneX) {
//        safeHeight = 64 + 24 + 34;
//    }
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, self.view.height - safeHeight - 50) style:UITableViewStylePlain];
//    _tableView = tableView;
//    tableView.backgroundColor = [UIColor clearColor];
////    tableView.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, self.view.height - safeHeight - 50);
//    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    [tableView registerClass:[JACommonCommentCell class] forCellReuseIdentifier:@"JACommonCommentCellID"];
//    // iOS11以后默认开启self-sizing，导致加载更多后跳动问题
//    self.tableView.estimatedRowHeight = 0;
//    self.tableView.estimatedSectionHeaderHeight = 0;
//    self.tableView.estimatedSectionFooterHeight = 0;
//    [self.view addSubview:tableView];
//    
//    
//    JAVoiceCommentHeaderView *headerView = [[JAVoiceCommentHeaderView alloc] init];
//    _headerView = headerView;
//    headerView.width = JA_SCREEN_WIDTH;
//    headerView.height = kHeaderBase;
//    headerView.refreshAgreeStatus = self.refreshAgreeStatus;
//    @WeakObj(self);
//    headerView.headActionBlock = ^(JAVoiceCommentHeaderView *headV) {  // 跳转个人中心
//     
//        @StrongObj(self);
//        if (headV.data.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
//            [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
//            return;
//        }
//        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
//        JAConsumer *model = [[JAConsumer alloc] init];
//        model.userId = self.voiceModel.userId;
//        model.name = self.voiceModel.userName;
//        model.image = self.voiceModel.userImage;
//        vc.personalModel = model;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//
//    headerView.playBlock = ^(JAVoiceCommentHeaderView *headV) {    // 播放
//       @StrongObj(self);
//   
//        [JAVoicePlayerManager shareInstance].replyVoices = nil;
//        [JAVoicePlayerManager shareInstance].voices = [@[self.voiceModel] mutableCopy];
////        [JAVoicePlayerManager shareInstance].commentVoices = nil;
//        [JAVoicePlayerManager shareInstance].commentVoices = self.dataSourceArray;
//        [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
//        
//        if (self.voiceModel.playState == 0) {
//            
////            [[JAVoicePlayerManager shareInstance] stop];
//            [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
//            
//            [JAVoicePlayerManager shareInstance].isHomeData = NO;
//            self.voiceModel.playState = 1;
//            [JAVoicePlayerManager shareInstance].voiceModel = self.voiceModel;
//            
//            
//        } else if (self.voiceModel.playState == 1) {
//            self.voiceModel.playState = 2;
//            [[JAVoicePlayerManager shareInstance] pause];
//        } else if (self.voiceModel.playState == 2) {
//            self.voiceModel.playState = 1;
//            [[JAVoicePlayerManager shareInstance] contiunePlay];
//        }
//    };
//    
//    headerView.deleteVoiceBlock = ^(JAVoiceCommentHeaderView *headV) {   // 删除操作
//       @StrongObj(self);
//        
//        [self.navigationController popViewControllerAnimated:YES];
//    };
//
//    headerView.commentBlock = ^(JAVoiceCommentHeaderView *headV) {      // 点击回复
//        @StrongObj(self);
//        if (!IS_LOGIN) {
//            [JAAPPManager app_modalLogin];
//            return;
//        }
//        
//        if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//            [self registKeyBoard];
//            return;
//        }
//        
//        self.frontIndex = nil;
//        
//        if (self.inputView.isHasDraft) {  // 有音频数据或者文字  直接唤起键盘
//            
//            if (self.replyPosts == NO) { // 如果之前的数据是回复不是帖子
////                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入文字标题(必填)"];  // 重置数据
//                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];  // 重置数据
//            }
//            [self.inputView callInputOrRecordKeyBoard];
//            
//        }else{   // 没有音频数据或者文字 添加占位文字 并唤起键盘
//            
////            self.inputView.placeHolderText = @"请输入文字标题(必填)";
//            self.inputView.placeHolderText = @"请输入回复内容";
//            [self.inputView callInputOrRecordKeyBoard];
//        }
//        self.replyPosts = YES;
//
//    };
//    
//    headerView.adminActionVoicePicture = ^(JAVoiceCommentHeaderView *headV) {
//        @StrongObj(self);
//        // 删除后刷新帖子详情
//        // 计算头部的高度
//        CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 2 * 12 - 30, MAXFLOAT);
//        CGFloat height = [headV.data.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_voiceFont)} context:nil].size.height + 24;
//        
//        NSMutableArray *images = [[headV.data.image componentsSeparatedByString:@","] mutableCopy];
//        [images removeObject:@""];
//        headV.height = (images.count > 0 ? kHeaderBasePic : kHeaderBase) + height + 10;
//        self.tableView.tableHeaderView = headV;
//        
////        [self.tableView reloadData];
//    };
//    
//    headerView.showPicture_registInut = ^(JAVoiceCommentHeaderView *headV) {
//        @StrongObj(self);
//        if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//            [self registKeyBoard];
//        }
//    };
//    
////    headerView.adminActionVoicePosts = ^(JAVoiceCommentHeaderView *headV) {
////        @StrongObj(self);
////        if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
////            [self.inputView registAllInput];
////            
////        }
////        NSString *power = [JAUserInfo userInfo_getUserImfoWithKey:User_Admin];
////        if (power.integerValue == JAPOWER) {
////            [JADetailClickManager detail_clickCellPopWindowsWithType:JA_STORY_TYPE typeModel:self.voiceModel DeleteAction:^{
////                [self.navigationController popViewControllerAnimated:YES];
////            } storyUserId:self.storyUserId floatType:JADetailClickTypeNoRecord recordAction:nil];
////        }
////    };
//    
//    headerView.topicDetailBlock = ^(NSString *topicName) {
//        @StrongObj(self);
//        JAPersonTopicViewController *vc = [[JAPersonTopicViewController alloc] init];
//        vc.topicTitle = topicName;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//    // v2.6.0
//    headerView.atPersonBlock = ^(NSString *userName, NSArray *atList) {
//        @StrongObj(self);
//        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
//        vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//    tableView.tableHeaderView = headerView;
//    
//    
//    // 底部键盘
//    JAReplyKeyBoardView *bottomView = [[JAReplyKeyBoardView alloc] init];
//    _bottomView = bottomView;
//    bottomView.type = 0;
//    [bottomView.recordButton addTarget:self action:@selector(callRecordKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
//    [bottomView.textButton addTarget:self action:@selector(calltextKeyBoard:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:bottomView];
//    
//    self.inputView = [[JAInputView alloc] init];
//    self.inputView.delegate = self;
//    self.inputView.inputInitial = JAInputInitialLocalTypeHiden;
//    self.inputView.width = JA_SCREEN_WIDTH;
//    self.inputView.height = 50;
//    self.inputView.y = self.view.height;
//    [self.view addSubview:self.inputView];
//}
//
//#pragma mark - 底部按钮
//- (void)callRecordKeyBoard:(UIButton *)button  // 唤起录音键盘
//{
//    // 判断是否有要回复的人
//    if (!self.inputView.isHasDraft) {  // 没有要回复的数据
//        self.frontIndex = nil;
//        self.replyPosts = YES;
//        self.inputView.placeHolderText = @"请输入回复内容";
//    }
//    [self.inputView callRecordKeyBoard];
//}
//
//- (void)calltextKeyBoard:(UIButton *)button  // 唤起文字键盘
//{
//    // 判断是否有要回复的人
//    if (!self.inputView.isHasDraft) {  // 没有要回复的数据
//        self.frontIndex = nil;
//        self.replyPosts = YES;
//        self.inputView.placeHolderText = @"请输入回复内容";
//    }
//    [self.inputView callInputKeyBoard];
//}
//
//- (void)registKeyBoard
//{
//    [self.inputView registAllInput];
//    
//    if (self.inputView.isHasVoice) {
//        [self.bottomView.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordRed"] forState:UIControlStateNormal];
//        
//    }else{
//        [self.bottomView.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateNormal];
//        
//    }
//    [self.bottomView.textButton setTitle:self.inputView.inputText forState:UIControlStateNormal];
//}
//
//#pragma mark - inputView的代理方法
//- (void)inputViewFrameChangeWithHeight:(CGFloat)height
//{
//    CGFloat bottominset = height > 50 ? height : 0;
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
//    if (self.replyPosts) {
//        if (result) {
//            [self releaseCommentWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray finish:^{
//                @StrongObj(self);
//                // 重置数据
//                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
//            }];
//        }else{
//            [self.view ja_makeToast:@"文件上传失败"];
//        }
//    }else{
//        if (result) {
//            [self releaseReplyWithUrl:fileUrlString time:timeString word:text sample:soundWaveArr atList:atArray finish:^{
//                @StrongObj(self);
//                // 重置数据
//                [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
//            }];
//        }else{
//            [self.view ja_makeToast:@"文件上传失败"];
//        }
//    }
//}
//
////- (void)inputViewClickSelf:(JAInputView *)input   // 点击底部的输入框
////{
////    if (!input.isHasDraft) {   // 没有数据 - 按回复帖子（即是评论）处理
////        self.frontIndex = nil;
////        self.replyPosts = YES;
////        self.inputView.placeHolderText = @"请输入回复内容";
////    }
////}
//
//- (void)input_sensorsAnalyticsCancleRecordWithRecordDuration:(CGFloat)duration   // 重新录制
//{
//    if (self.replyPosts) {
//        
////        NSMutableDictionary *params = [NSMutableDictionary new];
////        params[JA_Property_RecordDuration] = @((int)duration);
////        params[JA_Property_ContentType] = @"一级回复";
////        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_Rerecording] = @(YES);
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_AutoDialog] = @(NO);
//        params[JA_Property_ContentType] = @"一级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
//    }else{
//        
////        NSMutableDictionary *params = [NSMutableDictionary new];
////        params[JA_Property_RecordDuration] = @((int)duration);
////        params[JA_Property_ContentType] = @"二级回复";
////        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_Rerecording] = @(YES);
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_AutoDialog] = @(NO);
//        params[JA_Property_ContentType] = @"二级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_rerecording:params];
//    }
//}
//
//- (void)input_sensorsAnalyticsBeginRecord   // 开始录制
//{
//    
//    if (self.replyPosts) {
//        
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_ContentType] = @"一级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
//    }else{
//        
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_ContentType] = @"二级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_startRecord:params];
//    }
//}
//
//- (void)input_sensorsAnalyticsFinishRecordWithRecordDuration:(CGFloat)duration  // 完成录制
//{
//    if (self.replyPosts) {
//        
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_ContentType] = @"一级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//    }else{
//        
//        NSMutableDictionary *params = [NSMutableDictionary new];
//        params[JA_Property_RecordDuration] = @((int)duration);
//        params[JA_Property_ContentType] = @"二级回复";
//        [JASensorsAnalyticsManager sensorsAnalytics_endRecord:params];
//    }
//}
//
//#pragma mark - 布置子控件
//- (void)viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    self.sectionView.height = 50;
//    self.sectionView.width = JA_SCREEN_WIDTH;
//    [_sectionLabel sizeToFit];
//    _sectionLabel.x = 15;
//    _sectionLabel.centerY = self.sectionView.height * 0.5;
//    
//    _lineView.width = 1;
//    _lineView.height = 16;
//    _lineView.x = _sectionLabel.right + 10;
//    _lineView.centerY = _sectionView.height * 0.5;
//    
//    _inviteButton.width = 85;
//    _inviteButton.height = 20;
//    _inviteButton.x = _lineView.right;
//    _inviteButton.centerY = _sectionView.height * 0.5;
//    
//    // 底部键盘布局
//    self.bottomView.y = self.view.height - self.bottomView.height;
//}
//
//#pragma mark - 设置组头
//- (void)setupSectionView
//{
//    UIView *v = [[UIView alloc] init];
//    _sectionView = v;
//    v.height = 50;
//    v.backgroundColor = [UIColor whiteColor];
//    v.width = JA_SCREEN_WIDTH;
//    
//    UILabel *label = [[UILabel alloc] init];
//    _sectionLabel = label;
//    
//    label.text = [NSString stringWithFormat:@"%ld次播放",self.voiceModel.playCount.integerValue * 3];
//    label.textColor = HEX_COLOR(0x4A90E2);
//    label.font = JA_MEDIUM_FONT(13);
//    [label sizeToFit];
//    label.x = 15;
//    label.centerY = v.height * 0.5;
//    [v addSubview:label];
//    
//    UIView *lineview = [[UIView alloc] init];
//    _lineView = lineview;
//    lineview.backgroundColor = HEX_COLOR(JA_Line);
//    lineview.width = 1;
//    lineview.height = 16;
//    lineview.x = label.right + 10;
//    lineview.centerY = v.height * 0.5;
//    [v addSubview:lineview];
//    
//    UIButton *inviteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    _inviteButton = inviteBtn;
//    [inviteBtn setImage:[UIImage imageNamed:@"branch_voice_invite"] forState:UIControlStateNormal];
//    [inviteBtn addTarget:self action:@selector(invitePersonReply) forControlEvents:UIControlEventTouchUpInside];
//    inviteBtn.width = 85;
//    inviteBtn.height = 20;
//    inviteBtn.x = lineview.right;
//    inviteBtn.centerY = v.height * 0.5;
//    inviteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    inviteBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
//    [v addSubview:inviteBtn];
//    
//    JAPaddingLabel *inviteLabel = [[JAPaddingLabel alloc] init];
//    _inviteLabel = inviteLabel;
//    inviteLabel.text = @"邀请回复";
//    inviteLabel.textColor = HEX_COLOR(0x31C27C);
//    inviteLabel.font = JA_MEDIUM_FONT(13);
//    inviteLabel.edgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
//    [inviteLabel sizeToFit];
//    inviteLabel.x = 26;
//    inviteLabel.centerY = inviteBtn.height * 0.5;
//    [inviteBtn addSubview:inviteLabel];
//    
//    UIButton *sortButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _sortButton = sortButton;
//    [sortButton setTitle:@"热门排序" forState:UIControlStateNormal];
//    [sortButton setTitle:@"最新排序" forState:UIControlStateSelected];
//    [sortButton setImage:[UIImage imageNamed:@"branch_comment_sort"] forState:UIControlStateNormal];
//    [sortButton setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateNormal];
//    [sortButton setTitleColor:HEX_COLOR(JA_BlackTitle) forState:UIControlStateSelected];
//    sortButton.titleLabel.font = JA_REGULAR_FONT(13);
//    sortButton.width = 70;
//    sortButton.height = 17;
//    sortButton.centerY = v.height * 0.5;
//    sortButton.x = v.width - 15 - sortButton.width;
//    [sortButton setButtonImageTitleStyle:ButtonImageTitleStyleRight padding:5];
//    [sortButton addTarget:self action:@selector(sortCommentList:) forControlEvents:UIControlEventTouchUpInside];
//    [v addSubview:sortButton];
//    
////    UIButton *hotButton = [UIButton buttonWithType:UIButtonTypeCustom];
////    _hotButton = hotButton;
////    [hotButton setBackgroundImage:[UIImage imageNamed:@"branch_voice_newReply"] forState:UIControlStateNormal];
////    [hotButton setBackgroundImage:[UIImage imageNamed:@"branch_voice_hotReply"] forState:UIControlStateSelected];
////    [hotButton setTitle:@"热门回复" forState:UIControlStateNormal];
////    [hotButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
////    [hotButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
////    [hotButton addTarget:self action:@selector(hotCommentList) forControlEvents:UIControlEventTouchUpInside];
////    hotButton.titleLabel.font = JA_REGULAR_FONT(11);
////    hotButton.width = 60;
////    hotButton.height = 26;
////    hotButton.x = JA_SCREEN_WIDTH - 25 - 2 * hotButton.width;
////    hotButton.centerY = v.height * 0.5;
////    hotButton.selected = YES;
////    [v addSubview:hotButton];
//    
//    UIButton *newButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _moreNewButton = newButton;
//    [newButton setBackgroundImage:[UIImage imageNamed:@"branch_voice_newReply"] forState:UIControlStateNormal];
//    [newButton setBackgroundImage:[UIImage imageNamed:@"branch_voice_hotReply"] forState:UIControlStateSelected];
//    [newButton setTitle:@"最新回复" forState:UIControlStateNormal];
//    [newButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
//    [newButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
//    [newButton addTarget:self action:@selector(newCommentList) forControlEvents:UIControlEventTouchUpInside];
//    newButton.titleLabel.font = JA_REGULAR_FONT(11);
//    newButton.width = 60;
//    newButton.height = 26;
//    newButton.x = JA_SCREEN_WIDTH - 15 - newButton.width;
//    newButton.centerY = v.height * 0.5;
////    [v addSubview:newButton];
//    
//    UIView *lineV = [[UIView alloc] init];
//    lineV.backgroundColor = HEX_COLOR(JA_Line);
//    lineV.width = JA_SCREEN_WIDTH;
//    lineV.height = 1;
//    lineV.y = 49;
//    [v addSubview:lineV];
//    
//}
//
//#pragma mark - 分享的点击事件
//- (void)wxShare:(int)code
//{
//    if (self.needShare == NO) {
//        return;
//    }
//    self.needShare = NO;
//    if (code == 0) {
//        [self shareRequestServer:YES methodType:1];
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
//    }else if (code == -1) {
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信未识别的错误类型，请重试"];
//    }else if (code == -2) {
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
//    }else if (code == -3) {
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
//    }else if (code == -4) {
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
//    }else if (code == -5) {
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信不支持"];
//    }else{
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
//    }
//}
//
//- (void)qqShare:(NSString *)error
//{
//    if (self.needShare == NO) {
//        return;
//    }
//    self.needShare = NO;
//    if (error == nil) {
//        [self shareRequestServer:YES methodType:2];
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
//    }else{
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
//    }
//}
//
//- (void)wbShare:(int)code
//{
//    if (self.needShare == NO) {
//        return;
//    }
//    self.needShare = NO;
//    if (code == 0) {
//        [self shareRequestServer:NO methodType:0];
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
//    }else if (code == -1){
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
//    }else if (code == -2){
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
//    }else if (code == -3){
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
//    }else if (code == -8){
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
//    }else if (code == -99){
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"请求无效"];
//    }else{
//        
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
//    }
//}
//
//- (void)shareRequestServer:(BOOL)isWxSession methodType:(NSInteger)type //type 完成任务弹双倍时的类型 0 不需要完成任务 1 微信完成任务 2 QQ完成任务 // 分享接口
//{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    
//    dic[@"dataType"] = @"story";
//    dic[@"type"] = @"share";
//    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    dic[@"categoryId"] = self.voiceModel.categoryId;
//    dic[@"typeId"] = self.voiceModel.voiceId;
//    if (self.channelId.length && isWxSession) {
//        dic[@"categoryTypeId"] = self.channelId;
//        [JAConfigManager shareInstance].doubleFloatType = type;
//    }
//    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:^(NSDictionary *result) {
//        
//    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
//}
//
//#pragma mark - 邀请好友
///// 邀请好友
//- (void)invitePersonReply
//{
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//    
//    // 神策数据
//    // 计算时间
//    NSArray *timeArr = [self.voiceModel.time componentsSeparatedByString:@":"];
//    NSString *min = timeArr.firstObject;
//    NSString *sec = timeArr.lastObject;
//    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
//    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
////    senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[self.voiceModel.categoryId];
//    senDic[JA_Property_ContentId] = self.voiceModel.voiceId;
//    senDic[JA_Property_ContentTitle] = self.voiceModel.content;
//    senDic[JA_Property_Anonymous] = @(self.voiceModel.isAnonymous);
//    senDic[JA_Property_RecordDuration] = @(sen_time);
//    senDic[JA_Property_PostId] = self.voiceModel.userId;
//    senDic[JA_Property_PostName] = self.voiceModel.userName;
//    [JASensorsAnalyticsManager sensorsAnalytics_clickInvite:senDic];
//    
//
//    JAInviteViewController *vc = [[JAInviteViewController alloc] init];
//    vc.typeId = self.voiceId;
//    vc.inviteModel = self.voiceModel;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//#pragma mark - 排序
//- (void)sortCommentList:(UIButton *)btn
//{
//    btn.selected = !btn.selected;
//    
//    if (btn.selected) {
//        
//        [self newCommentList];
//    }else{
//        
//        [self hotCommentList];
//    }
//}
//
///// 热门回复
//- (void)hotCommentList
//{
////    self.hotButton.selected = YES;
//    self.moreNewButton.selected = NO;
//    self.isNewList = NO;
//    [self getVoiceCommentList:NO];
//}
//
///// 最新回复
//- (void)newCommentList
//{
////    self.hotButton.selected = NO;
//    self.moreNewButton.selected = YES;
//    self.isNewList = YES;
//    [self getVoiceCommentList:NO];
//}
//
//// ---------------------------
//#pragma mark - 网络请求 获取帖子详情数据
//- (void)getVoiceDetail
//{
////    MBProgressHUD showin
//    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"id"] = self.voiceId;
//    if(IS_LOGIN) dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    
//    [[JAVoiceApi shareInstance] voice_singleVoiceWithParas:dic success:^(NSDictionary *result) {
//        [self.currentProgressHUD hideAnimated:NO];
//        
//        self.requestFaile = NO;   // 判断请求是否失败 - 是否可以分享
//        JAVoiceModel *model = [JAVoiceModel mj_objectWithKeyValues:result[@"story"]];
//        
//        // v2.4.0新增
//        model.sourceName = self.backSourceName;
//        model.recommendType = self.backRecommendType;
//        
//        self.voiceModel = model;
//        self.storyUserId = self.voiceModel.userId;
//        NSString *shareString = model.shareCount;
//        if (shareString.integerValue > 0) {
//            self.shareLabel.hidden = NO;
//        }
//        if (model.shareCount.integerValue > 10000) {
//            shareString = [NSString stringWithFormat:@"%.1fw",model.shareCount.integerValue / 10000.0];
//        }
//        self.shareLabel.text = shareString;
//        [self.shareLabel sizeToFit];
//        self.shareLabel.height = 10;
//        self.shareLabel.width = self.shareLabel.width + 6;
//        
//        // 开始刷新评论列表数据
//        [self getVoiceCommentList:NO];
//        
//        // 获取匿名状态
//        [self getMyAnonymousStatus:model.userId anonymous:model.isAnonymous];
//        
//        // 神策数据
//        // 计算时间
//        NSArray *timeArr = [model.time componentsSeparatedByString:@":"];
//        NSString *min = timeArr.firstObject;
//        NSString *sec = timeArr.lastObject;
//        NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
//        NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
////        senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
//        senDic[JA_Property_ContentId] = model.voiceId;
//        senDic[JA_Property_ContentTitle] = model.content;
//        senDic[JA_Property_Anonymous] = @(model.isAnonymous);
//        senDic[JA_Property_RecordDuration] = @(sen_time);
//        senDic[JA_Property_PostId] = model.userId;
//        senDic[JA_Property_PostName] = model.userName;
//        [JASensorsAnalyticsManager sensorsAnalytics_browseViewControllerDetail:senDic];
//        
//        
//        // 计算头部的高度
//        CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 2 * 12 - 30, MAXFLOAT);
//        CGFloat height = [model.content boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(JA_CommentDetail_voiceFont)} context:nil].size.height + 24;
//        
//        NSMutableArray *images = [[model.image componentsSeparatedByString:@","] mutableCopy];
//        [images removeObject:@""];
//        self.headerView.height = (images.count > 0 ? kHeaderBasePic : kHeaderBase) + height + 10;
//        
//        model.displayPeakLevelQueue = [JASampleHelper getDisplayPeakLevelQueue:model.sampleZip sample:model.sample type:JADisplayTypeStory];
//        model.currentPeakLevelQueue = [JASampleHelper getCurrentPeakLevelQueue:model.displayPeakLevelQueue type:JADisplayTypeStory];
//
//        self.headerView.data = model;
//        self.tableView.tableHeaderView = self.headerView;
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
//            
//            // 点击评论按钮进入
//            if (self.isCommentClick && IS_LOGIN) {
//                self.frontIndex = nil;
//                
//                if (self.inputView.isHasDraft) {  // 有音频数据或者文字  直接唤起键盘
//                    
//                    if (self.replyPosts == NO) { // 如果之前的数据是回复不是帖子
////                        [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入文字标题(必填)"];  // 重置数据
//                        [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];  // 重置数据
//                    }
//                    [self.inputView callInputOrRecordKeyBoard];
//                    
//                }else{   // 没有音频数据或者文字 添加占位文字 并唤起键盘
//                    
////                    self.inputView.placeHolderText = @"请输入文字标题(必填)";
//                    self.inputView.placeHolderText = @"请输入回复内容";
//                    [self.inputView callInputOrRecordKeyBoard];
//                }
//                self.replyPosts = YES;
//            }
//        });
//        
//        // v2.6.4 点击播放球进入播放主帖，如果在播放评论或回复不做处理
//        if (self.lastVoiceModel) {
//            JAVoiceCommentModel *commentModel = [JAVoicePlayerManager shareInstance].commentModel;
//            JAVoiceReplyModel *replyModel = [JAVoicePlayerManager shareInstance].replyModel;
//            if (commentModel || replyModel) {
//                if (commentModel.playState == 2 || replyModel.playState == 2) {
//                    [[JAVoicePlayerManager shareInstance] contiunePlay];
//                }
//                return;
//            }
//            [JAVoicePlayerManager shareInstance].replyVoices = nil;
//            [JAVoicePlayerManager shareInstance].voices = [@[self.voiceModel] mutableCopy];
//            [JAVoicePlayerManager shareInstance].commentVoices = self.dataSourceArray;
//            
//            if (self.voiceModel.playState == 0) {
//                [JAVoicePlayerManager shareInstance].currentPlayIndex = 0;
//                
//                [JAVoicePlayerManager shareInstance].isHomeData = NO;
//                self.voiceModel.playState = 1;
//                [JAVoicePlayerManager shareInstance].voiceModel = self.voiceModel;
//                
//            } else if (self.voiceModel.playState == 2) {
//                self.voiceModel.playState = 1;
//                [[JAVoicePlayerManager shareInstance] contiunePlay];
//            }
//        }
//    } failure:^(NSError *error) {
//        
//        [self.currentProgressHUD hideAnimated:NO];
//        self.requestFaile = YES;
//        if (error.code == 155555) {
//            [self showBlankPageWithLocationY:0 title:@"该内容已经被删除啦！" subTitle:@"" image:@"blank_delete" buttonTitle:nil selector:nil buttonShow:NO];
//        }else{
//            
////            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
//            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryActionPost) buttonShow:NO];
//        }
//        
//    }];
//}
//
//- (void)retryActionPost {
//    [self removeBlankPage];
//    [self getVoiceDetail];
//}
//
//// ---------------------------
//#pragma mark - 获取评论列表
//- (void)getVoiceCommentList:(BOOL)isMore
//{
//   
//    if (!isMore) {
//        self.currentPage = 1;
//        self.tableView.mj_footer.hidden = YES;
//    }
//    
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//    dic[@"pageNum"] = @(self.currentPage);
//    dic[@"pageSize"] = @"6";
//    dic[@"type"] = @"story";
//    dic[@"typeId"] = self.voiceId;
//    if (self.isNewList) {
//        
//    }else{
//        
//        dic[@"orderType"] = @"1";
//    }
//    dic[@"isFold"] = @"0";
//    if (IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    
//    [[JAVoiceCommentApi shareInstance] voice_commentListWithParas:dic success:^(NSDictionary *result) {
//
//        [self.tableView.mj_footer endRefreshing];
//        [self.tableView.mj_header endRefreshing];
//        self.requestStatus = 1;
//        // 之前的数据处理
//        if (!isMore) {
//            [self.dataSourceArray removeAllObjects];
//        }
//        
//        // 解析数据
//        JAVoiceCommentGroupModel *groupModel = [JAVoiceCommentGroupModel mj_objectWithKeyValues:result[@"commentPageList"]];
//        self.groupModel = groupModel;
//        
//        
//        // 初始化波形图
//        for (JAVoiceCommentModel *model in groupModel.result) {
//            
//#warning 2.3.0 重写评论cell 添加的属性
//            model.voiceStoryUserId = self.storyUserId;
//            
//            model.displayPeakLevelQueue = [JASampleHelper getDisplayPeakLevelQueue:model.sampleZip sample:model.sample type:JADisplayTypeComment];
//            model.currentPeakLevelQueue = [JASampleHelper getCurrentPeakLevelQueue:model.displayPeakLevelQueue type:JADisplayTypeComment];
//
//            // 热度排序，导致数据重复问题
//            __block BOOL isRepeatData = NO;
//            [self.dataSourceArray enumerateObjectsUsingBlock:^(JAVoiceCommentModel *obj, NSUInteger idx, BOOL *stop) {
//                if ([obj.voiceCommendId isEqualToString:model.voiceCommendId]) {
//                    isRepeatData = YES;
//                    *stop = YES;
//                }
//            }];
//            if (!isRepeatData) {
//                [self.dataSourceArray addObject:model];
//            }
//        }
//        
//        // 需要滚动的位置
//        self.scrollIndex = nil;
//        if (self.first_commentModel) {
//            [self.dataSourceArray enumerateObjectsUsingBlock:^(JAVoiceCommentModel *model, NSUInteger idx, BOOL * _Nonnull stop) {
//                if ([self.first_commentModel.voiceCommendId isEqualToString:model.voiceCommendId]) {
//                    JAVoiceCommentModel *newModel = model;
//                    [self.dataSourceArray removeObject:model];
//                    [self.dataSourceArray insertObject:newModel atIndex:0];
//                    self.scrollIndex = [NSIndexPath indexPathForRow:0 inSection:0];
//                    *stop = YES;
//                }
//            }];
//            
//            if (!self.scrollIndex) {
//                [self.dataSourceArray insertObject:self.first_commentModel atIndex:0];
//                self.scrollIndex = [NSIndexPath indexPathForRow:0 inSection:0];
//            }
//            
//            self.first_commentModel = nil;
//        }
//        
//        // 判断是否有下一页
//        if (groupModel.nextPage != 0) {
//            self.currentPage = groupModel.currentPageNo + 1;
//            self.tableView.mj_footer.hidden = NO;
//        }else{
////            self.tableView.mj_footer.hidden = YES;
//            [self.tableView.mj_footer endRefreshingWithNoMoreData];
//            
//            
//            // 展示折叠
////            self.footView.hidden = NO;
//        }
//        
//        [self.tableView reloadData];
//
////        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////            [[NSNotificationCenter defaultCenter] postNotificationName:JAPlayNotification object:nil];
////        });
//    } failure:^(NSError *error) {
//        
//        [self.tableView.mj_footer endRefreshing];
//        [self.tableView.mj_header endRefreshing];
//        
//        if (!isMore) {
//            self.requestStatus = 2;
//            [self.tableView reloadData];
//        }
//    }];
//}
//// ---------------------------
//#pragma mark - 匿名
//- (void)getMyAnonymousStatus:(NSString *)storyUserId anonymous:(BOOL)anonymous
//{
//    NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    if ([uid isEqualToString:storyUserId]) {
//        self.inputView.isAnonymous = anonymous;
//    }
//    
////    NSMutableDictionary *params = [NSMutableDictionary dictionary];
////    params[@"storyId"] = self.voiceId;
////    params[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
////    [[JAUserApiRequest shareInstance] userAnonymousStatus:params success:^(NSDictionary *result) {
////        if (result) {
////            NSDictionary *anonymousInfo = result[@"AnonymousInfo"];
////            if (anonymousInfo) {
////                self.anonymous = [[NSString stringWithFormat:@"%@",anonymousInfo[@"isAnonymous"]] boolValue];
////                self.inputView.isAnonymous = self.anonymous;
////            }
////        }
////    } failure:^(NSError *error) {
////    }];
//}
//
//#pragma mark - 发布评论和回复
//// 评论
//- (void)releaseCommentWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList finish:(void(^)())finish
//{
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];  // ------
//    params[@"categoryId"] = self.voiceModel.categoryId;                   // ------
//    params[@"typeId"] = self.voiceModel.voiceId;
//    params[@"type"] = JA_STORY_TYPE;
//    params[@"isAnonymous"] = self.inputView.anonymousStatus?@"1":nil;      // ------
//    params[@"content"] = text;// 声音描述
//    params[@"recommendType"] = self.backRecommendType.length ? self.backRecommendType : @"无法获取该属性";  // ------
//    params[@"screenName"] = self.voiceModel.sourceName;                                                   // ------
//    
//    if (audioUrl.length) {
//        params[@"audioUrl"] = audioUrl;
//        params[@"time"] = time;
//        params[@"sample"] = [JASampleHelper getSampleStringWithAllPeakLevelQueue:sample];         // ------
//        params[@"sampleZip"] = [JASampleHelper getSampleZipStringWithAllPeakLevelQueue:sample];   // ------
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
//        JAVoiceCommentModel *commentModel = [JAVoiceCommentModel mj_objectWithKeyValues:result[@"comment"]];
//        self.release_commentModel = commentModel;
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
//- (void)releaseReplyWithUrl:(NSString *)audioUrl time:(NSString *)time word:(NSString *)text sample:(NSMutableArray *)sample atList:(NSArray *)atList finish:(void(^)())finish
//{
//    JAVoiceCommentModel *model = self.needRefreshModel;//self.dataSourceArray[self.needRefreshIndex];
//
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    params[@"categoryId"] = model.categoryId;
//    params[@"storyId"] = model.typeId;
//    params[@"commentId"] = model.voiceCommendId;
//    params[@"replyUserid"] = model.userId;
//    params[@"type"] = JA_STORY_TYPE;
//    params[@"isAnonymous"] = self.inputView.anonymousStatus?@"1":nil;
//    params[@"content"] = text;// 声音描述
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
//        JAVoiceReplyModel *replyModel = [JAVoiceReplyModel mj_objectWithKeyValues:result[@"reply"]];
//        self.release_replyModel = replyModel;
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
//#pragma mark - tableView的数据源以及代理方法
//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath == self.scrollIndex && self.dataSourceArray.count) {
//        self.scrollIndex = nil;
//        cell.layer.backgroundColor = HEX_COLOR(0xF6FFF7).CGColor;
//        CABasicAnimation *animation =[CABasicAnimation animationWithKeyPath:@"backgroundColor"];
//        animation.toValue = (id)HEX_COLOR(0xffffff).CGColor;
//        animation.duration = 2.0f;
//        animation.removedOnCompletion = NO;
//        animation.fillMode = kCAFillModeForwards;
//        animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
//        [cell.layer addAnimation:animation forKey:@"changebackgroundColor"];
//    }else{
//        cell.backgroundColor = [UIColor whiteColor];
//    }
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (!self.dataSourceArray.count) {
//        return;
//    }
//    
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
//    
//    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//        [self registKeyBoard];
//        return;
//    }
//    
//    // 获取数据
//    JAVoiceCommentModel *model = self.dataSourceArray[indexPath.row];
//    //        self.needRefreshIndex = indexPath.row;  // 当前回复的那一行
//    self.needRefreshModel = self.dataSourceArray[indexPath.row];
//    
//    if (self.inputView.isHasDraft) {  // 有音频数据或者文字  直接唤起键盘
//        
//        if (self.frontIndex != indexPath || self.replyPosts == YES) { // 如果点击的是不同的cell 或者之前是回复的帖子
//            NSString *name = [NSString stringWithFormat:@"回复@%@", (model.isAnonymous ? model.anonymousName : model.userName)];
//            [self.inputView resetInputOfDraftWithPlacrHolder:name];
//        }
//        
//        self.frontIndex = indexPath;
//        [self.inputView callInputOrRecordKeyBoard];
//        
//    }else{   // 没有音频数据或者文字 添加占位文字 并唤起键盘
//        
//        NSString *name = [NSString stringWithFormat:@"回复@%@", (model.isAnonymous ? model.anonymousName : model.userName)];
//        self.inputView.placeHolderText = name;
//        self.frontIndex = indexPath;
//        [self.inputView callInputOrRecordKeyBoard];
//    }
//    
//    self.replyPosts = NO;
//    
//    
////    if (indexPath.section != self.tapIndex.section) {
////        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
////        _tapCount = 0;
////    }
////    _tapCount++;
////    self.tapIndex = indexPath;
////    if (_tapCount > 1) {
////        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(singleTap) object:nil];
////        [self doubleTap];
////    }else{
////
////        [self performSelector:@selector(singleTap) withObject:nil afterDelay:0.3];
////    }
//}
//
////- (void)singleTap
////{
////    [self resetTapCount]; // 清0
////    
////    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
////        [self.inputView registAllInput];
////        return;
////    }
////   
////    // 获取数据
////    JAVoiceCommentModel *model = self.dataSourceArray[self.tapIndex.row];
////#warning TODO 弹窗
////    [JADetailClickManager detail_clickCellPopWindowsWithType:JA_COMMENT_TYPE typeModel:model DeleteAction:^{
////        [self.dataSourceArray removeObject:model];
////        [self.tableView reloadData];
////    } storyUserId:self.storyUserId floatType:JADetailClickTypeNormal recordAction:^{
////       
////        [self.inputView callInputOrRecordKeyBoard];
////    }];
////    
////}
//
////- (void)doubleTap
////{
////    NSLog(@"双击双击");
////    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetTapCount) object:nil];
////    [self performSelector:@selector(resetTapCount) withObject:nil afterDelay:0.3];
////
////    // 获取cell
////    JACommonCommentCell *cell = [self.tableView cellForRowAtIndexPath:self.tapIndex];
////    [cell showHeardShape];
////}
////
////- (void)resetTapCount
////{
////    _tapCount = 0;
////}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
////    return self.dataSourceArray.count;
//    if (self.dataSourceArray.count) {
//        
//        return self.dataSourceArray.count;
//    }else{
//        return 1;
//    }
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    @WeakObj(self);
//    if (!self.dataSourceArray.count) {
//        
//        JAPersonBlankCell *cell = [[JAPersonBlankCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
//        cell.requestStatus = self.requestStatus;
//        cell.requestAginBlock = ^{
//            @StrongObj(self);
//            [self getVoiceCommentList:NO];
//        };
//        return cell;
//    }
//    
//    JACommonCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JACommonCommentCellID"];
//    // 跳转回复详情
//    
//    cell.jumpPersonalViewControlBlock = ^(JACommonCommentCell *cell) {    // 个人主页
//       @StrongObj(self);
//        if (cell.commentModel.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {
//            [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
//            return;
//        }
//        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
//        JAConsumer *model = [[JAConsumer alloc] init];
//        model.userId = cell.commentModel.userId;
//        model.name = cell.commentModel.userName;
//        model.image = cell.commentModel.userImage;
//        vc.personalModel = model;
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//    
//    cell.jumpReplyViewControlBlock = ^(JACommonCommentCell *cell) {    // 回复详情
//        @StrongObj(self);
//        
//        // 有音频或者文字就先移除
//        if (self.inputView.isHasDraft) {
//            [self.inputView resetInputOfDraftWithPlacrHolder:@"请输入回复内容"];
//        }
//        
//        [self registKeyBoard];
//        
//        JAVoiceReplyDetailViewController *vc = [[JAVoiceReplyDetailViewController alloc] init];
//        vc.voiceId = cell.commentModel.typeId;
//        vc.voiceCommentId = cell.commentModel.voiceCommendId;
//        vc.storyUserId = self.storyUserId;
//        vc.storyAnonymous = self.voiceModel.isAnonymous;
//        vc.refreshCommentAgreeStatus = ^(BOOL agreeStatus) {
//            cell.likeButton.selected = agreeStatus;
//            if (agreeStatus) {
//                cell.lastAgreeState = agreeStatus;
//                cell.commentModel.agreeCount = [NSString stringWithFormat:@"%ld",cell.commentModel.agreeCount.integerValue + 1];
//                [cell.likeButton setTitle:cell.commentModel.agreeCount forState:UIControlStateNormal];
//            }else{
//                cell.lastAgreeState = agreeStatus;
//                cell.commentModel.agreeCount = [NSString stringWithFormat:@"%ld",cell.commentModel.agreeCount.integerValue - 1];
//                [cell.likeButton setTitle:cell.commentModel.agreeCount forState:UIControlStateNormal];
//            }
//        };
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//
//    cell.playCommentBlock = ^(JACommonCommentCell *cell) {    // 播放评论
//       @StrongObj(self);
//        [JAVoicePlayerManager shareInstance].replyVoices = nil;
//        [JAVoicePlayerManager shareInstance].voices = nil;
//        [JAVoicePlayerManager shareInstance].commentVoices = self.dataSourceArray;
////        [JAVoicePlayerManager shareInstance].commentVoices = [@[cell.commentModel] mutableCopy];
//
//        
//        if (cell.commentModel.playState == 0) {
//            
////            [[JAVoicePlayerManager shareInstance] stop];
//            
//            cell.commentModel.playState = 1;
//            [JAVoicePlayerManager shareInstance].commentModel = cell.commentModel;
//            [JAVoicePlayerManager shareInstance].currentPlayCommentIndex = indexPath.row;
//        } else if (cell.commentModel.playState == 1) {
//            cell.commentModel.playState = 2;
//            [[JAVoicePlayerManager shareInstance] pause];
//        } else if (cell.commentModel.playState == 2) {
//            cell.commentModel.playState = 1;
//            [[JAVoicePlayerManager shareInstance] contiunePlay];
//        }
//    };
//    
//    cell.pointClickBlock = ^(JACommonCommentCell *cell) {    // 点击三个点
//        @StrongObj(self);
//        
//        if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//            [self registKeyBoard];
//        }
//        [JADetailClickManager detail_clickCellPopWindowsWithType:JA_COMMENT_TYPE typeModel:cell.commentModel DeleteAction:^{
//            [self.dataSourceArray removeObject:cell.commentModel];
//            [self.tableView reloadData];
//        } storyUserId:self.storyUserId floatType:JADetailClickTypeNoRecord recordAction:nil];
//    };
//    
//    cell.commentModel = self.dataSourceArray[indexPath.row];
//
//    // v2.6.0
//    cell.commentAtPersonBlock = ^(NSString *userName, NSArray *atList) {
//        @StrongObj(self);
//        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
//        vc.personalModel = [JADataHelper getConsumer:userName atList:atList];
//        [self.navigationController pushViewController:vc animated:YES];
//    };
//    return cell;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//    self.sectionLabel.text = [NSString stringWithFormat:@"%ld次播放",self.voiceModel.playCount.integerValue * 3];
//    
//    [self.view setNeedsLayout];
//    return self.sectionView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (!self.dataSourceArray.count) {
//        return 300;
//    }
//    JAVoiceCommentModel *model = self.dataSourceArray[indexPath.row];
//    model.floorCount = indexPath.row + 2;
//    return model.cellHeight;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//
//   return 50;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.01;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return [UIView new];
//}
//
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    if (self.inputView.isRespondStatus) {   // 如果键盘处于响应状态
//        [self registKeyBoard];
//        return;
//    }
//}
//
//// -----------------------------
//#pragma mark - 发布成功后拿到的数据
//- (void)setRelease_commentModel:(JAVoiceCommentModel *)release_commentModel
//{
//    _release_commentModel = release_commentModel;
//#warning 2.3.0 重写评论cell 添加的属性
//    release_commentModel.voiceStoryUserId = self.storyUserId;
//    release_commentModel.agreeCount = @"0";
//    release_commentModel.displayPeakLevelQueue = [JASampleHelper getDisplayPeakLevelQueue:release_commentModel.sampleZip sample:release_commentModel.sample type:JADisplayTypeComment];
//    release_commentModel.currentPeakLevelQueue = [JASampleHelper getCurrentPeakLevelQueue:release_commentModel.displayPeakLevelQueue type:JADisplayTypeComment];
//    
//    [self.dataSourceArray insertObject:release_commentModel atIndex:0];
//    
////    NSDictionary *dic = @{
////                          @"userName" : release_commentModel.isAnonymous ? release_commentModel.anonymousName : release_commentModel.userName,
////                          @"isAnonymous" : @(release_commentModel.isAnonymous)
////                          };
//
////    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionAnonymity" object:nil userInfo:dic];
//    
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        
//        [self.tableView reloadData];
//        
//        NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:0];
//        
//        [self.tableView selectRowAtIndexPath:p animated:NO scrollPosition:UITableViewScrollPositionNone];
//    });
//}
//
//- (void)setRelease_replyModel:(JAVoiceReplyModel *)release_replyModel
//{
//    _release_replyModel = release_replyModel;
//    
//    // 获取当前需要刷新的模型
//    JAVoiceCommentModel *model = self.needRefreshModel;//self.dataSourceArray[self.needRefreshIndex];
//    
//#warning 2.3.0 重写评论cell 添加的属性
//    model.refreshModel = YES;  // 刷新高度
//    
//    model.s2cReplyMsg = release_replyModel;
//    
//    model.replyCount = [NSString stringWithFormat:@"%ld",model.replyCount.integerValue + 1];
//    
////    NSDictionary *dic = @{
////                          @"userName" : release_replyModel.isAnonymous ? release_replyModel.userAnonymousName : release_replyModel.userName,
////                          @"isAnonymous" : @(release_replyModel.isAnonymous)
////                          };
//    
////    [[NSNotificationCenter defaultCenter] postNotificationName:@"actionAnonymity" object:nil userInfo:dic];
//    
//    [self.tableView reloadData];
//}
//
//// -----------------------------
//// 神策数据
//- (void)sensorsAnalyticsWithModel:(JAVoiceModel *)model mothod:(NSString *)mothod
//{
//    // 神策数据
//    // 计算时间
//    NSArray *timeArr = [model.time componentsSeparatedByString:@":"];
//    NSString *min = timeArr.firstObject;
//    NSString *sec = timeArr.lastObject;
//    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
//    
//    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//    senDic[JA_Property_ContentId] = model.voiceId;
//    senDic[JA_Property_ContentTitle] = model.content;
//    senDic[JA_Property_ContentType] = @"主帖";
////    senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[model.categoryId];
//    senDic[JA_Property_Anonymous] = @(model.isAnonymous);
//    senDic[JA_Property_RecordDuration] = @(sen_time);
//    senDic[JA_Property_PostId] = model.userId;
//    senDic[JA_Property_PostName] = model.userName;
//    senDic[JA_Property_ShareMethod] = mothod;
//    senDic[JA_Property_SourcePage] = model.sourceName;
//    senDic[JA_Property_RecommendType] = model.recommendType;
//    [JASensorsAnalyticsManager sensorsAnalytics_clickShare:senDic];
//}
//// -----------------------------
@end
