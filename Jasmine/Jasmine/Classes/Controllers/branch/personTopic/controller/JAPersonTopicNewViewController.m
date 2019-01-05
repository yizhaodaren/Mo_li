//
//  JAPersonTopicNewViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonTopicNewViewController.h"

#import "JAStoryTableView.h"
#import "JATopicNetRequest.h"

@interface JAPersonTopicNewViewController ()

@property (nonatomic, strong) JAStoryTableView *tableView;

@property (nonatomic, assign) NSInteger currentPage;


@end


static NSString *topicNewCellID = @"topicNewCellID";

@implementation JAPersonTopicNewViewController

- (void)loadView{
    self.tableView = [[JAStoryTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT) superVC:self sectionHeaderView:nil];
    self.view = self.tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getReleaseVoiceModel:) name:@"refreshVoiceModel" object:nil];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_getTopicVoiceNewListWithMore:YES];
    }];
    self.tableView.mj_footer.hidden = YES;
    
    [self request_getTopicVoiceNewListWithMore:NO];
}

// 发布成功插入帖子
- (void)getReleaseVoiceModel:(NSNotification *)noti
{
    NSDictionary *dic = (NSDictionary *)noti.object;
    if (!dic) {
        return;
    }
    JANewVoiceModel *release_voiceModel = (JANewVoiceModel *)dic[@"data"];
    if (release_voiceModel && [release_voiceModel.content containsString:self.topicTitle]) {
        [self.tableView.voices insertObject:release_voiceModel atIndex:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showBlankPage];
            [self.tableView reloadData];
            NSIndexPath *p = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.tableView selectRowAtIndexPath:p animated:NO scrollPosition:UITableViewScrollPositionNone];
        });
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - 网络请求
- (void)request_getTopicVoiceNewListWithMore:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
        [self sensorsAnalyticsWithMethod:@"下拉刷新"];
    }else{
        [self sensorsAnalyticsWithMethod:@"上滑刷新"];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    dic[@"type"] = @(0);
    dic[@"title"] = self.topicTitle;
    JATopicNetRequest *r = [[JATopicNetRequest alloc] initRequest_topicListWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        
        if (model.code != 10000) {
            if (!self.tableView.voices.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                CGFloat height = 400;
                [self showBlankPageWithHeight:height title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
            }
            return;
        }
        
        if (!isMore) {
            [self.tableView.voices removeAllObjects];
        }
        
        // 添加数据
        [self.tableView.voices addObjectsFromArray:model.resBody];
        
        if (!isMore) {
            [self showBlankPage];  // 空数据
        }
        
        if (self.tableView.voices.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.tableView.mj_footer endRefreshing];
        CGFloat height = 400;
        if (self.tableView.voices.count == 0) {
            [self showBlankPageWithHeight:height title:@"网络请求异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
        }
    }];
}

// 展示空白页
- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
    }else{
        
        NSString *t = @"暂无主帖，快来参与讨论吧！";
        NSString *st = @"";
        CGFloat height = 400;
        [self showBlankPageWithHeight:height title:t subTitle:st image:@"blank_norelease" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
    }
}

- (void)sensorsAnalyticsWithMethod:(NSString *)mothod
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"话题详情";
    params[JA_Property_ReloadMethod] = mothod;
    params[JA_Property_ContentName] = self.topicTitle;
    [JASensorsAnalyticsManager sensorsAnalytics_homeRefresh:params];
}

//- (void)shareRequestServer   // 分享接口
//{
//    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//
//    dic[@"dataType"] = @"story";
//    dic[@"type"] = @"share";
//    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    dic[@"categoryId"] = self.shareModel.categoryId;
//    dic[@"typeId"] = self.shareModel.voiceId;
//
//    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:^(NSDictionary *result) {
//
//        //        NSLog(@"%@",result);
//
//    } failure:^(NSError *error) {
//        NSLog(@"%@",error);
//    }];
//}
//
//#pragma mark - delegate
//- (void)qqShare:(NSString *)error
//{
//    if (self.needShare == NO) {
//        return;
//    }
//    self.needShare = NO;
//    if (error == nil) {
//        [self shareRequestServer];
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
//    }else{
//
//        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
//    }
//}
//
///*
// WXSuccess           = 0,    < 成功
// WXErrCodeCommon     = -1,    普通错误类型
// WXErrCodeUserCancel = -2,   用户点击取消并返回
// WXErrCodeSentFail   = -3,    发送失败
// WXErrCodeAuthDeny   = -4,    授权失败
// WXErrCodeUnsupport  = -5,    微信不支持
// */
//- (void)wxShare:(int)code
//{
//    if (self.needShare == NO) {
//        return;
//    }
//    self.needShare = NO;
//    if (code == 0) {
//        [self shareRequestServer];
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
///*
// WeiboSDKResponseStatusCodeSuccess               = 0,//成功
// WeiboSDKResponseStatusCodeUserCancel            = -1,//用户取消发送
// WeiboSDKResponseStatusCodeSentFail              = -2,//发送失败
// WeiboSDKResponseStatusCodeAuthDeny              = -3,//授权失败
// WeiboSDKResponseStatusCodeUserCancelInstall     = -4,//用户取消安装微博客户端
// WeiboSDKResponseStatusCodePayFail               = -5,//支付失败
// WeiboSDKResponseStatusCodeShareInSDKFailed      = -8,//分享失败 详情见response UserInfo
// WeiboSDKResponseStatusCodeUnsupport             = -99,//不支持的请求
// WeiboSDKResponseStatusCodeUnknown
// */
//
//- (void)wbShare:(int)code
//{
//    if (self.needShare == NO) {
//        return;
//    }
//    self.needShare = NO;
//    if (code == 0) {
//        [self shareRequestServer];
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
@end
