//
//  JAAlbumDetailViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAAlbumDetailViewController.h"
#import "JAStoryTableViewCell.h"
#import "JAAlbumDetailHeadView.h"
#import "JAStoryTableView.h"
#import "JACommonSectionView.h"
#import "JABottomDoubleButtonView.h"
#import "JABottomShareView.h"

#import "JAAlbumNetRequest.h"
#import "JAVoicePersonApi.h"

#import "JAPlatformShareManager.h"

#import "JAStoryPlayViewController.h"
#import "JANewPlayTool.h"

#import "JAUserActionNetRequest.h"

@interface JAAlbumDetailViewController ()<PlatformShareDelegate>
@property (nonatomic, strong) JAStoryTableView *tableView;
@property (nonatomic, strong) JACommonSectionView *sectionView;

@property (nonatomic, weak) JAAlbumDetailHeadView *headView;

@property (nonatomic, weak) JABottomDoubleButtonView *bottomView;

// 专辑model
@property (nonatomic, strong) JAAlbumModel *albumModel;

@property (nonatomic, assign) NSInteger currentPage;  // 当前页码
@property (nonatomic, assign) NSInteger currentType;  // 当前类型
@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;
@end

@implementation JAAlbumDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setCenterTitle:@"专辑详情"];
    [self setupStoryAlbumViewControllerUI];
    self.currentType = 1;  // 默认倒序
    @WeakObj(self);
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_albumStoryLisetWithMore:NO sortType:self.currentType];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        [self request_albumStoryLisetWithMore:YES sortType:self.currentType];
    }];
    self.tableView.mj_footer.hidden = YES;
    [self.tableView.mj_header beginRefreshing];
    [self request_albumInfo];
}

#pragma mark - 网络请求
// 专辑 - 帖子列表
- (void)request_albumStoryLisetWithMore:(BOOL)isMore sortType:(NSInteger)type // 0 默认 1 降序
{
    if (!isMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
        self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
        [self sensorsAnalyticsWithMethod:@"下拉刷新"];
    }else{
        [self sensorsAnalyticsWithMethod:@"上滑刷新"];
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @(6);
    dic[@"orderType"] = @(type);  // 0 默认 1 降序
    JAAlbumNetRequest *r = [[JAAlbumNetRequest alloc] initRequest_albumStoryListWithParameter:dic subjectId:self.subjectId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.tableView.mj_footer endRefreshing];
        [self.tableView.mj_header endRefreshing];
        
        JANewVoiceGroupModel *model = (JANewVoiceGroupModel *)responseModel;
        if (model.code != 10000) {
            if (!self.tableView.voices.count) {
                [self.view ja_makeToast:model.message]; // 失败原因
                [self showBlankPageWithLocationY:0 title:@"服务器异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
            }
            return;
        }
        
        if (!isMore) {
            [self.tableView.voices removeAllObjects];
            NSString *str = [NSString stringWithFormat:@"已收录%ld位茉友故事",responseModel.total];
            [self.sectionView.leftButton setTitle:str forState:UIControlStateNormal];
            [self.sectionView.leftButton sizeToFit];
        }
        
        // 添加数据
        [self.tableView.voices addObjectsFromArray:model.resBody];
        
        if (!isMore) {
            [self showBlankPage];  // 空数据
        }
        
        if (self.tableView.voices.count >= model.total) {
            self.tableView.mj_footer.hidden = YES;
            self.currentPage += 1;
        }else{
            self.tableView.mj_footer.hidden = NO;
            self.currentPage += 1;
        }
        
        [self.tableView reloadData];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [self.currentProgressHUD hideAnimated:NO];
        if (self.tableView.voices.count == 0) {
            [self showBlankPageWithLocationY:0 title:@"网络请求异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }];
}

// 专辑详情
- (void)request_albumInfo
{
    JAAlbumNetRequest *r = [[JAAlbumNetRequest alloc] initRequest_albumInfoWithParameter:nil subjectId:self.subjectId];
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        JAAlbumModel *model = (JAAlbumModel *)responseModel;
        
        if (model.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            return;
        }
        self.albumModel = model;
        NSString *des = model.subjectDesc;
        // 计算高度
        CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 113 - 50, MAXFLOAT);
        CGFloat subHeight = [des boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(14)} context:nil].size.height;
        if (subHeight + 60 > 110) {  // 110 是图像的底部
            self.headView.height = subHeight + 60 + 15 + 55 + 10; // 60 是detailLabel 的 Y 值
        }else{
            self.headView.height = 110 + 15 + 55 + 10;
        }
        self.headView.model = model;
        self.tableView.tableHeaderView = self.headView;
        self.bottomView.leftButton.selected = model.isCollect;
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

#pragma mark - 按钮的点击
// 播放全部
- (void)playAllStoryList
{
    // 获取播放当前专辑
    if (!self.tableView.voices.count) {
        [self.view ja_makeToast:@"暂无帖子"];
        return;
    }
    [[JANewPlayTool shareNewPlayTool] playTool_resetPlayTool];
    NSInteger type = 3;
    [[JANewPlayTool shareNewPlayTool] playTool_playWithModel:self.tableView.voices.firstObject storyList:self.tableView.voices enterType:type albumParameter:self.albumRequestDic];
}
- (void)clickCollectAlbum:(UIButton *)button
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    button.userInteractionEnabled = NO;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"typeId"] = self.subjectId;
    dic[@"type"] = @"subject";
    
    JAUserActionNetRequest *r = [[JAUserActionNetRequest alloc] initRequest_userCollectWithParameter:dic];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        button.userInteractionEnabled = YES;
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            return;
        }
        NSInteger isCollent = [request.responseObject[@"resBody"][@"isCollent"] integerValue];
        if (isCollent) {
            button.selected = YES;
            // 获取收藏数 + 1
            NSInteger collect = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount].integerValue;
            collect = collect + 1;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_collentCount value:[NSString stringWithFormat:@"%ld",collect]];
        }else{
            button.selected = NO;
            // 获取收藏数 - 1
            NSInteger collect = [JAUserInfo userInfo_getUserImfoWithKey:User_collentCount].integerValue;
            collect = collect - 1 > 0 ? (collect - 1) : 0;
            [JAUserInfo userInfo_updataUserInfoWithKey:User_collentCount value:[NSString stringWithFormat:@"%ld",collect]];
        }
        
        [button sizeToFit];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        button.userInteractionEnabled = YES;
        [self.view ja_makeToast:@"网络异常，稍后再试"];
    }];
}

- (void)clickShareAlbum:(UIButton *)button  // 分享按钮
{
    if (!self.albumModel.subjectId.length) {
        [self.view ja_makeToast:@"专辑信息获取失败"];
        return;
    }
    
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    appDelegate.shareDelegate = self;
    
    JABottomShareView *shareView = [[JABottomShareView alloc] initWithShareType:JABottomShareViewTypeOneLine contentType:JABottomShareOneContentTypeNormal twoContentType:JABottomShareTwoContentTypeNormal];
    @WeakObj(self);
    shareView.bottomShareClickButton = ^(JABottomShareClickType clickType, BOOL select, UIButton *button) {
        @StrongObj(self);
        if (clickType == JABottomShareClickTypeWX) {
        
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.albumModel.shareMsg.shareWxContent;
            model.descripe = self.albumModel.shareMsg.shareTitle;
            model.shareUrl = self.albumModel.shareMsg.shareUrl;
            model.image = self.albumModel.shareMsg.shareImg;
            
            [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:5];
        }else if (clickType == JABottomShareClickTypeWXSession){
           
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.albumModel.shareMsg.shareWxContent;
            model.shareUrl = self.albumModel.shareMsg.shareUrl;
            model.image = self.albumModel.shareMsg.shareImg;
            
            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:5];
        }else if (clickType == JABottomShareClickTypeQQ){
          
            JAShareModel *model = [JAShareModel new];
            model.title = self.albumModel.shareMsg.shareWxContent;
            model.descripe = self.albumModel.shareMsg.shareTitle;
            model.shareUrl = self.albumModel.shareMsg.shareUrl;
            model.image = self.albumModel.shareMsg.shareImg;
            
            [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:5];
            
        }else if (clickType == JABottomShareClickTypeQQZone){
            
            JAShareModel *model = [JAShareModel new];
            model.title = self.albumModel.shareMsg.shareWxContent;
            model.descripe = self.albumModel.shareMsg.shareTitle;
            model.shareUrl = self.albumModel.shareMsg.shareUrl;
            model.image = self.albumModel.shareMsg.shareImg;
            
            [JAPlatformShareManager qqShare:QQShareTypeZone shareContent:model domainType:5];
            
        }else if (clickType == JABottomShareClickTypeWB){
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = self.albumModel.shareMsg.shareWBContent;
            model.shareUrl = self.albumModel.shareMsg.shareUrl;
            model.image = self.albumModel.shareMsg.shareImg;
            [JAPlatformShareManager wbShareWithshareContent:model domainType:5];
        }
        
    };
    [shareView showBottomShareView];
}

#pragma mark - 分享回调
- (void)wxShare:(int)code
{
    if (code == 0) {
        
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
    if (error == nil) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wbShare:(int)code
{
    if (code == 0) {
        
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

#pragma mark - UI
- (void)setupStoryAlbumViewControllerUI
{
    self.tableView = [[JAStoryTableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0) superVC:self sectionHeaderView:self.sectionView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.tableView.estimatedRowHeight =0;
    self.tableView.estimatedSectionHeaderHeight =0;
    self.tableView.estimatedSectionFooterHeight =0;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.tableView];
    
    JAAlbumDetailHeadView *headView = [[JAAlbumDetailHeadView alloc] init];
    _headView = headView;
    headView.width = JA_SCREEN_WIDTH;
    headView.height = 190;
    [headView.playButton addTarget:self action:@selector(playAllStoryList) forControlEvents:UIControlEventTouchUpInside];
    [headView.collectButton addTarget:self action:@selector(clickCollectAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [headView.shareButton addTarget:self action:@selector(clickShareAlbum:) forControlEvents:UIControlEventTouchUpInside];

    self.tableView.tableHeaderView = headView;
    
//    JABottomDoubleButtonView *bottomView = [[JABottomDoubleButtonView alloc] init];
//    _bottomView = bottomView;
//    [bottomView.leftButton setTitle:@"收藏" forState:UIControlStateNormal];
//    [bottomView.leftButton setTitle:@"已收藏" forState:UIControlStateSelected];
//    [bottomView.leftButton setTitle:@"已收藏" forState:UIControlStateSelected | UIControlStateHighlighted];
//    [bottomView.leftButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
//    bottomView.leftButton.titleLabel.font = JA_REGULAR_FONT(16);
//    [bottomView.leftButton setImage:[UIImage imageNamed:@"album_collect_un"] forState:UIControlStateNormal];
//    [bottomView.leftButton setImage:[UIImage imageNamed:@"album_collected"] forState:UIControlStateSelected];
//    [bottomView.leftButton setImage:[UIImage imageNamed:@"album_collected"] forState:UIControlStateSelected | UIControlStateHighlighted];
//    [bottomView.leftButton setButtonImageTitleStyle:ButtonImageTitleStyleDefault padding:5];
//    [bottomView.leftButton addTarget:self action:@selector(clickCollectAlbum:) forControlEvents:UIControlEventTouchUpInside];
//
//    [bottomView.rightButton setTitle:@"分享" forState:UIControlStateNormal];
//    [bottomView.rightButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
//    bottomView.rightButton.titleLabel.font = JA_REGULAR_FONT(16);
//    [bottomView.rightButton setImage:[UIImage imageNamed:@"recommend_share"] forState:UIControlStateNormal];
//    [bottomView.rightButton setButtonImageTitleStyle:ButtonImageTitleStyleDefault padding:5];
//    [bottomView.rightButton addTarget:self action:@selector(clickShareAlbum:) forControlEvents:UIControlEventTouchUpInside];
//
//    bottomView.backgroundColor = HEX_COLOR(0xf9f9f9);
//    [self.view addSubview:bottomView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorStoryAlbumViewControllerFrame];
}

- (void)calculatorStoryAlbumViewControllerFrame
{
//    self.bottomView.height = 44 + JA_TabbarSafeBottomMargin;
//    self.bottomView.width = JA_SCREEN_WIDTH;
//    self.bottomView.y = self.view.height - self.bottomView.height;
    
    self.tableView.frame = self.view.bounds;
//    self.tableView.height = self.view.height - self.bottomView.height;
    
}

#pragma mark - 懒加载
- (JACommonSectionView *)sectionView
{
    if (_sectionView == nil) {
        
        _sectionView = [[JACommonSectionView alloc] initWithType:JACommonSectionViewType_normal];
        _sectionView.width = JA_SCREEN_WIDTH;
        _sectionView.height = 40;
        _sectionView.backgroundColor = [UIColor whiteColor];
        
        [_sectionView.leftButton setTitle:@"已收录0位茉友故事" forState:UIControlStateNormal];
        [_sectionView.leftButton setTitleColor:HEX_COLOR(0x363636) forState:UIControlStateNormal];
        _sectionView.leftButton.titleLabel.font = JA_MEDIUM_FONT(14);
        
        [_sectionView.rightButton setImage:[UIImage imageNamed:@"album_sort_sel"] forState:UIControlStateNormal];
        [_sectionView.rightButton setImage:[UIImage imageNamed:@"album_sort"] forState:UIControlStateSelected];
        [_sectionView.rightButton setTitle:@"收录时间倒序" forState:UIControlStateNormal];
        [_sectionView.rightButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
        _sectionView.rightButton.titleLabel.font = JA_REGULAR_FONT(13);
        [_sectionView.rightButton addTarget:self action:@selector(clickSectionRightButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [_sectionView commonSection_layoutView];
    }
    return _sectionView;
}

- (void)clickSectionRightButton:(UIButton *)btn
{
    btn.selected = !btn.selected;
    self.currentType = btn.selected ? 0 : 1;
    if (btn.selected) {
        [btn setTitle:@"收录时间正序" forState:UIControlStateNormal];
    }else{
        [btn setTitle:@"收录时间倒序" forState:UIControlStateNormal];
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(requestWithSort) object:self];
    
    [self performSelector:@selector(requestWithSort) withObject:self afterDelay:0.3];
    
}
- (void)requestWithSort
{
    [self request_albumStoryLisetWithMore:NO sortType:self.currentType];
}

// 展示空白页
- (void)showBlankPage
{
    if (self.tableView.voices.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"还没有相关帖子";
        NSString *st = @"";
        [self showBlankPageWithLocationY:self.headView.height title:t subTitle:st image:@"blank_searchnoresult" buttonTitle:nil selector:nil buttonShow:NO superView:self.tableView];
    }
}

// 获取当前请求专辑帖子列表的参数
- (NSDictionary *)albumRequestDic
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"currentPage"] = @(self.currentPage);
    dic[@"orderType"] = @(self.currentType);
    dic[@"subjectId"] = self.subjectId;
    return dic;
}

- (NSString *)albumName
{
    return self.albumModel.subjectName;
}

- (void)sensorsAnalyticsWithMethod:(NSString *)mothod
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"专辑详情";
    params[JA_Property_ReloadMethod] = mothod;
    params[JA_Property_ContentName] = self.albumName;
    [JASensorsAnalyticsManager sensorsAnalytics_homeRefresh:params];   
}
@end
