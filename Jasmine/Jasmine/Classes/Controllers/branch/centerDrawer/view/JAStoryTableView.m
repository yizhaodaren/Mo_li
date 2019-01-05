//
//  JAStoryTableView.m
//  Jasmine
//
//  Created by xujin on 2018/5/24.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAStoryTableView.h"
#import "JAStoryTableViewCell.h"
#import "JAFunctionToolV.h"
#import "JAStoryTableViewCell.h"
#import "JAPostDetailViewController.h"
#import "JAStoryTableViewCell+BlockHelper.h"
#import "JAPlatformShareManager.h"
#import "JAVoiceCommonApi.h"
#import "JAStoryPlayViewController.h"
#import "JAAlbumDetailViewController.h"
#import "JABottomShareView.h"
#import "JANewPlayTool.h"

#import "JACircleDetailViewController.h"
#import "JACircleEssenceStoryListViewController.h"
#import "JACircleAllStoryListViewController.h"
#import "JAAlbumDetailViewController.h"
#import "JAStoryViewController.h"
#import "JANewPersonVoiceViewController.h"
#import "JAPersonTopicNewViewController.h"
#import "JAPersonTopicHotViewController.h"
#import "JAAlbumDetailViewController.h"
#import "JANewPersonVoiceViewController.h"

@interface JAStoryTableView () <
UITableViewDelegate,
UITableViewDataSource,
PlatformShareDelegate>

@property (nonatomic, weak) UIViewController *vc;
@property (nonatomic, assign) BOOL needShare;
@property (nonatomic, strong) JANewVoiceModel *shareModel;
@property (nonatomic, weak) JAStoryTableViewCell *currentCell;
@property (nonatomic, strong) UIView *sectionHeaderView; // 个人中心、圈子详情、话题详情等页面的头部view

@end

@implementation JAStoryTableView

- (instancetype)initWithFrame:(CGRect)frame superVC:(UIViewController *)vc sectionHeaderView:(UIView *)sectionHeaderView
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.vc = vc;
        self.sectionHeaderView = sectionHeaderView;
        self.voices = [NSMutableArray new];
        
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.backgroundColor = [UIColor clearColor];
        self.dataSource = self;
        self.delegate = self;
        // iOS11以后默认开启self-sizing，导致加载更多后跳动问题
        self.estimatedRowHeight = 0;
        self.estimatedSectionHeaderHeight = 0;
        self.estimatedSectionFooterHeight = 0;
    }
    return self;
}

- (void)dealloc
{
    self.dataSource = nil;
    self.delegate = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - lazyLoad
- (JAStoryTopicView *)topicView {
    if (!_topicView) {
        _topicView = [[JAStoryTopicView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, WIDTH_ADAPTER(246))];
    }
    return _topicView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.voices.count == 0 ? 1 : self.voices.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.voices.count == 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        return cell;
    }
    JANewVoiceModel *voice = self.voices[indexPath.section];
    JAStoryTableViewCell *cell;
    JAStoryTableViewCellType cellType = DefaultCellType;
    NSString *reuseIdentifierString = @"DefaultCellType";
    if (voice.storyType == 0) {
        // 音频帖
        if (voice.photos.count) {
            if (voice.photos.count == 1) {
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
        if (voice.photos.count) {
            if (voice.photos.count == 1) {
                cellType = SingleImageCellType;
                reuseIdentifierString = @"SingleImageCellType";
            } else {
                cellType = MultiImageCellType;
                reuseIdentifierString = @"MultiImageCellType";
            }
        }
    }
    cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierString];
    if (!cell) {
        cell = [[JAStoryTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:reuseIdentifierString
                                                  cellType:cellType
                                                imageCount:voice.photos.count];
    }
    cell.data = voice;
    BOOL isTimeHidden = NO;
    if ([self.vc isKindOfClass:[JAAlbumDetailViewController class]]) {
        // 专辑页隐藏时间
        isTimeHidden = YES;
    } else if ([self.vc isKindOfClass:[JAStoryViewController class]]) {
        // 推荐页隐藏时间
        isTimeHidden = ([self.model.channelId isEqualToString:@"2"])?YES:NO;
    }
    [cell hideTimeLabel:isTimeHidden];
    
    BOOL isCircleHidden = NO;
    BOOL isCircleTagHidden = YES;
    if ([self.vc isKindOfClass:[JACircleAllStoryListViewController class]] ||
        [self.vc isKindOfClass:[JACircleEssenceStoryListViewController class]]) {
        // 圈子详情内的帖子不显示圈子
        isCircleHidden = YES;
        // 圈子详情内的帖子显示圈主
        isCircleTagHidden = NO;
    }
    [cell hideCircleView:isCircleHidden];
    
    BOOL isPersonnalCenter = NO;
    if ([self.vc isKindOfClass:[JANewPersonVoiceViewController class]]) {
        //
        isPersonnalCenter = YES;
    }
    [cell hideEssenceView:!(isPersonnalCenter || isCircleHidden) isDetail:NO];
    
    [cell hideCircleTagView:isCircleTagHidden];
    
    [cell setupCommonBlockWithModel:voice superVC:self.vc];
    @WeakObj(self);
    cell.shareBlock = ^(JAStoryTableViewCell *cell) {
        @StrongObj(self);
        
        AppDelegate *appDelegate = [AppDelegate sharedInstance];
        appDelegate.shareDelegate = self;
        
        self.shareModel = voice;
        
        JABottomShareView *shareView = [[JABottomShareView alloc] initWithShareType:JABottomShareViewTypeOneLine contentType:JABottomShareOneContentTypeNormal twoContentType:JABottomShareTwoContentTypeNormal];
        @WeakObj(self);
        shareView.bottomShareClickButton = ^(JABottomShareClickType clickType, BOOL select, UIButton *button) {
            
            // 分享数+1
            cell.toolView.shareLabel.text = [NSString stringWithFormat:@"%ld",cell.data.shareCount.integerValue + 1];
            
            @StrongObj(self);
            if (clickType == JABottomShareClickTypeWX) {
                self.needShare = NO;
                [self sensorsAnalyticsWithModel:self.shareModel mothod:@"微信聊天"];
                [self shareRequestServer:NO methodType:0];
                JAShareModel *model = [[JAShareModel alloc] init];
                model.title = self.shareModel.shareMsg.shareWxContent;
                model.descripe = self.shareModel.shareMsg.shareTitle;
                model.shareUrl = self.shareModel.shareMsg.shareUrl;
                model.image = self.shareModel.shareMsg.shareImg;
                model.music = self.shareModel.audioUrl;
                [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:0];
            }else if (clickType == JABottomShareClickTypeWXSession){
                self.needShare = YES;
                [self sensorsAnalyticsWithModel:self.shareModel mothod:@"朋友圈"];
                JAShareModel *model = [[JAShareModel alloc] init];
                model.title = self.shareModel.shareMsg.shareWxContent;
                model.shareUrl = self.shareModel.shareMsg.shareUrl;
                model.image = self.shareModel.shareMsg.shareImg;
                model.music = self.shareModel.audioUrl;
                [JAPlatformShareManager wxShareMusic:WeiXinShareTypeSession shareContent:model];

            }else if (clickType == JABottomShareClickTypeQQ){
                self.needShare = NO;
                [self sensorsAnalyticsWithModel:self.shareModel mothod:@"qq"];
                [self shareRequestServer:NO methodType:0];
                JAShareModel *model = [JAShareModel new];
                model.title = self.shareModel.shareMsg.shareWxContent;
                model.descripe = self.shareModel.shareMsg.shareTitle;
                model.shareUrl = self.shareModel.shareMsg.shareUrl;
                model.image = self.shareModel.shareMsg.shareImg;
                model.music = self.shareModel.audioUrl;
                [JAPlatformShareManager qqShareMusic:QQShareTypeFriend shareContent:model];

            }else if (clickType == JABottomShareClickTypeQQZone){
                self.needShare = YES;
                [self sensorsAnalyticsWithModel:self.shareModel mothod:@"qq空间"];
                JAShareModel *model = [JAShareModel new];
                model.title = self.shareModel.shareMsg.shareWxContent;
                model.descripe = self.shareModel.shareMsg.shareTitle;
                model.shareUrl = self.shareModel.shareMsg.shareUrl;
                model.image = self.shareModel.shareMsg.shareImg;
                model.music = self.shareModel.audioUrl;
                [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:0];

            }else if (clickType == JABottomShareClickTypeWB){
                self.needShare = YES;
                [self sensorsAnalyticsWithModel:self.shareModel mothod:@"微博"];
                JAShareModel *model = [[JAShareModel alloc] init];
                model.title = self.shareModel.shareMsg.shareWBContent;
                model.shareUrl = self.shareModel.shareMsg.shareUrl;
                model.image = self.shareModel.shareMsg.shareImg;
                [JAPlatformShareManager wbShareWithshareContent:model domainType:0];
            }
            
        };
        [shareView showBottomShareView];
    };
    
    cell.moreBlock = ^(JAStoryTableViewCell *cell) {
        @StrongObj(self);
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([self.model.channelId isEqualToString:@"2"]) {
            // 推荐页面弹窗
            CGRect rect = [cell convertRect:cell.userContentView.moreButton.frame toView:[UIApplication sharedApplication].delegate.window];
//            dic = @{@"sourcePage" : @"recommend",
//                    @"noInterestViewY" : @(rect.origin.y)};
            dic[@"sourcePage"] = @"recommend";
            dic[@"noInterestViewY"] = @(rect.origin.y);
        }
        
        [JADetailClickManager detail_modalChooseWindowWithStory:cell.data standbyParameter:dic needBlock:^(NSInteger actionType) {
            
            if (actionType == 1) {  // 置顶
                cell.data.circleTop = YES;
            }else if (actionType == 2) {  // 取消置顶
                cell.data.circleTop = NO;
            }else if (actionType == 3){ // 加精华
                cell.data.essence = YES;
            }else if (actionType == 4){ // 取消加精华
                cell.data.essence = NO;
            }else if (actionType == 5){ // 收藏
                cell.data.userCollect = YES;
            }else if (actionType == 6){ // 取消收藏
                cell.data.userCollect = NO;
            }else if (actionType == 7){ // 不感兴趣
                [self.voices removeObject:cell.data];
                [self reloadData];
                
            }else if (actionType == 9){ // 删除
                [[NSNotificationCenter defaultCenter] postNotificationName:@"owner_deleteVoice" object:nil];
                [self.voices removeObject:cell.data];
                [self reloadData];
            }
        }];
    };
    
    cell.playBlock = ^(JAStoryTableViewCell *cell) {
        @StrongObj(self);
        NSInteger type = 0;
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        if ([self.vc isMemberOfClass:[JAPostDetailViewController class]]) {
            type = 2;
        }else if ([self.vc isMemberOfClass:[JAAlbumDetailViewController class]]){
            type = 3;
            JAAlbumDetailViewController *albumVc = (JAAlbumDetailViewController *)self.vc;
            [dic setValuesForKeysWithDictionary:albumVc.albumRequestDic];
            
        }else{
            type = 1;
        }
        
        [[JANewPlayTool shareNewPlayTool] playTool_playWithModel:cell.data storyList:self.voices enterType:type albumParameter:dic];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.voices.count == 0) {
        return 300;
    }
    JANewVoiceModel *voice = self.voices[indexPath.section];
    
    if ([self.vc isKindOfClass:[JACircleAllStoryListViewController class]]) {
        JACircleAllStoryListViewController *v = (JACircleAllStoryListViewController *)self.vc;
        voice.sourcePage = @"圈子详情";
        voice.sourcePageName = v.infoModel.circleName;
    }else if ([self.vc isKindOfClass:[JACircleEssenceStoryListViewController class]]){
        JACircleEssenceStoryListViewController *v = (JACircleEssenceStoryListViewController *)self.vc;
        voice.sourcePage = @"圈子详情";
        voice.sourcePageName = v.infoModel.circleName;
    }else if ([self.vc isKindOfClass:[JAPersonTopicNewViewController class]]){
        JAPersonTopicNewViewController *v = (JAPersonTopicNewViewController *)self.vc;
        voice.sourcePage = @"话题详情";
        voice.sourcePageName = v.topicTitle;
    }else if ([self.vc isKindOfClass:[JAPersonTopicHotViewController class]]){
        JAPersonTopicHotViewController *v = (JAPersonTopicHotViewController *)self.vc;
        voice.sourcePage = @"话题详情";
        voice.sourcePageName = v.topicTitle;
    }else if ([self.vc isKindOfClass:[JAAlbumDetailViewController class]]){
        JAAlbumDetailViewController *v = (JAAlbumDetailViewController *)self.vc;
        voice.sourcePage = @"专辑详情";
        voice.sourcePageName = v.albumName;
    }else if ([self.vc isKindOfClass:[JANewPersonVoiceViewController class]]){
        voice.sourcePage = @"个人主页-主帖";
    }else if ([self.model.channelId isEqualToString:@"2"]) {
        voice.sourcePage = @"首页-推荐";
    }else if ([self.model.channelId isEqualToString:@"1"]){
        voice.sourcePage = @"首页-关注";
    }else if ([self.model.channelId isEqualToString:@"3"]){
        voice.sourcePage = @"首页-最新";
    }
    
    return voice.cellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.voices.count == 0) {
        return;
    }
    JAStoryTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [self pushCommentDetailWithCell:cell isCommentClick:NO];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
    //    footerView.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.sectionHeaderView && section == 0) {
        return self.sectionHeaderView.height;
    }
    if (section == 3 && self.topicView.topics.count && [self.model.channelId isEqualToString:@"2"]) {
        // 数据流第四行插入推荐话题
        return self.topicView.height;
    }
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.sectionHeaderView && section == 0) {
        return self.sectionHeaderView;
    }
    if (section == 3 && self.topicView.topics.count && [self.model.channelId isEqualToString:@"2"]) {
        return self.topicView;
    }
    return [UIView new];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.ja_scrollDelegate && [self.ja_scrollDelegate respondsToSelector:@selector(ja_scrollViewDidScroll:)]) {
        [self.ja_scrollDelegate ja_scrollViewDidScroll:scrollView];
    }
}

#pragma mark - PlatformShareDelegate
- (void)qqShare:(NSString *)error
{
    if (self.needShare == NO) {
        return;
    }
    self.needShare = NO;
    if (error == nil) {
        [self shareRequestServer:YES methodType:2];  // 2.6.0 分享到QQ空间 也是完成任务
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wxShare:(int)code
{
    if (self.needShare == NO) {
        return;
    }
    self.needShare = NO;
    if (code == 0) {
        [self shareRequestServer:YES methodType:1];
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

- (void)wbShare:(int)code
{
    if (self.needShare == NO) {
        return;
    }
    self.needShare = NO;
    if (code == 0) {
        [self shareRequestServer:NO methodType:0];
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

#pragma mark - PrivateMethods

- (void)pushCommentDetailWithCell:(JAStoryTableViewCell *)cell isCommentClick:(BOOL)isCommentClick {

    JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
    if ([self.vc isKindOfClass:[JACircleAllStoryListViewController class]] ||
        [self.vc isKindOfClass:[JACircleEssenceStoryListViewController class]]) {
        vc.enterType = 1;
    }
    
    vc.sourcePage = cell.data.sourcePage;
    vc.sourcePageName = cell.data.sourcePageName;
    
    vc.voiceId = cell.data.storyId;
    vc.backSourceName = cell.data.sourceName;
    vc.backRecommendType = cell.data.recommendType;
    if ([self.model.channelId isEqualToString:@"2"]) {
        vc.channelId = self.model.channelId;
    }
    vc.refreshAgreeStatus = ^(BOOL agreeStatus) {
        cell.toolView.agreeButton.selected = agreeStatus;
        cell.lastAgreeState = agreeStatus;
        if (agreeStatus) {
            cell.data.agreeCount = [NSString stringWithFormat:@"%ld",cell.data.agreeCount.integerValue + 1];
        }else{
            cell.data.agreeCount = [NSString stringWithFormat:@"%ld",cell.data.agreeCount.integerValue - 1];
        }
        cell.toolView.agreeLabel.text = [NSString convertCountStr:cell.data.agreeCount];
    };
    
    vc.refreshCommentCount = ^(BOOL deleteComment) {
      
        if (deleteComment) {
            cell.data.commentCount = [NSString stringWithFormat:@"%ld",cell.data.commentCount.integerValue - 1];
        }else{
            cell.data.commentCount = [NSString stringWithFormat:@"%ld",cell.data.commentCount.integerValue + 1];
        }
        cell.toolView.commentLabel.text = [NSString convertCountStr:cell.data.commentCount];
    };
    
    vc.musicList = self.voices;
    [self.vc.navigationController pushViewController:vc animated:YES];

}

//shareNetWork
- (void)shareRequestServer:(BOOL)isSession_task methodType:(NSInteger)type //type 完成任务弹双倍时的类型 0 不需要完成任务 1 微信完成任务 2 QQ完成任务  // 分享接口
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"dataType"] = @"story";
    dic[@"type"] = @"share";
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"typeId"] = self.shareModel.storyId;
    if ([self.model.channelId isEqualToString:@"2"] && isSession_task) {
        dic[@"categoryTypeId"] = self.model.channelId;
        [JAConfigManager shareInstance].doubleFloatType = type;
    }
    [[JAVoiceCommonApi shareInstance] voice_appCommonWithParas:dic success:^(NSDictionary *result) {
        
    } failure:^(NSError *error) {
        
    }];
}

// 神策数据
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
    senDic[JA_Property_SourcePage] = model.sourcePage;
    senDic[JA_Property_SourcePageName] = model.sourcePageName;
    [JASensorsAnalyticsManager sensorsAnalytics_clickShare:senDic];
}

@end
