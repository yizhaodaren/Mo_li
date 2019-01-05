//
//  JAStoryPlayViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/6/2.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAStoryPlayViewController.h"
#import "CYLTabBarController.h"
#import "JAPostDetailViewController.h"

#import "JAPlayHeadView.h"
#import "JAPlayBottomView.h"
#import "JAPlayListCell.h"

#import "JANewPlayTool.h"

#import "JASlider.h"

#define kPlayVCSwitch_new 1

@interface JAStoryPlayViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *storyArray;  // 当前的播放列表
@property (nonatomic, assign) NSInteger playIndex;  // 当前播放的index

@property (nonatomic, weak) UIImageView *tableBackImaeView;  // 列表的背景

@property (nonatomic, weak) UIButton *backButton;   // modal 消失按钮
@property (nonatomic, weak) UILabel *titleLabel;   // 标题

@property (nonatomic, weak) JAPlayHeadView *headView;  // 头部详情view

@property (nonatomic, weak) UITableView *tableView; // 列表

@property (nonatomic, weak) JAPlayBottomView *playView;  // 底部播放view

// 进入方式
@property (nonatomic, assign) NSInteger enterType;

@property (nonatomic, strong) JANewPlayTool *player;

// 触摸了slider
@property (nonatomic, assign) BOOL touchSlider;

@end

@implementation JAStoryPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _storyArray = [NSMutableArray array];
    [self setupStoryPlayViewControllerUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playStatus_refreshUI) name:@"STKAudioPlayer_status" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playProcess_refreshUI) name:@"STKAudioPlayer_process" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playFinish_refreshUI) name:@"STKAudioPlayer_finish" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playListUpdate_refreshUI) name:@"STKAudioPlayer_listupdate" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(listOrderupdate_refreshUI) name:@"STKAudioPlayer_listOrderupdate" object:nil];
    
    
    self.player = [JANewPlayTool shareNewPlayTool];
 
    // 从播放器拉取当前的列表，及播放的index数据
    [self getListFromPlayTool];
    
    if (kPlayVCSwitch_new) { // 新版逻辑
        @WeakObj(self);
        MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingBlock:^{
            @StrongObj(self);
            [self.player playTool_getAlbumMusicListWithSort];
        }];
        [header setTitle:@"加载更多" forState:MJRefreshStateIdle];
        NSMutableArray *refreshingImages = [NSMutableArray array];
        for (NSInteger i = 0; i < 8; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"playwave_%ld",i+1]];
            [refreshingImages addObject:image];
        }
        [header setImages:refreshingImages forState:MJRefreshStateRefreshing];
        
        header.lastUpdatedTimeLabel.hidden = YES;
        self.tableView.mj_header = header;
        
        MJRefreshAutoGifFooter *footer = [MJRefreshAutoGifFooter footerWithRefreshingBlock:^{
            @StrongObj(self);
            [self.player playTool_getAlbumMusicListWithSort];
        }];
        [footer setTitle:@"加载更多" forState:MJRefreshStateIdle];
        NSMutableArray *foot_refreshingImages = [NSMutableArray array];
        for (NSInteger i = 0; i < 8; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"playwave_%ld",i+1]];
            [foot_refreshingImages addObject:image];
        }
        [footer setImages:foot_refreshingImages forState:MJRefreshStateRefreshing];
        footer.refreshingTitleHidden = YES;
        self.tableView.mj_footer = footer;
        
        if (self.player.enterType != 3) {
            self.tableView.mj_footer.hidden = YES;
            self.tableView.mj_header.hidden = YES;
        }else{
            if (self.player.playOrder_zheng) {
                self.tableView.mj_footer.hidden = NO;
                self.tableView.mj_header.hidden = YES;
            }else{
                self.tableView.mj_header.hidden = NO;
                self.tableView.mj_footer.hidden = YES;
            }
        }
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 从播放器拉取当前的列表，及播放的index数据
- (void)getListFromPlayTool
{
    // 播放器的列表没值 直接return
    if (self.player.musicList.count == 0) {
        return;
    }
    /*
     1、获取播放器列表
     2、获取播放的index （这个以播放器为准，有一种可能是，这个可能被赋值了，但是播放器又自动切换下一条了）
     */

    [self.storyArray addObjectsFromArray:self.player.musicList];
    // 刷新头部
    self.headView.storyModel = self.player.currentMusic;
    
    // 刷新底部
    self.playView.totalTimeLabel.text = self.player.currentMusic.time;
    self.playView.orderButton.selected = !self.player.playOrder_zheng;
    self.playView.playButton.selected = (self.player.playType == 1 || self.player.playType == 3);
    
    [self.tableView reloadData];
    
    if (self.player.currentIndex >= 0 && self.player.playType != 0) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:self.player.currentIndex inSection:0];
        [self.tableView selectRowAtIndexPath:indexP animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

#pragma mark - 播放通知的监听
- (void)playStatus_refreshUI
{
    [self refreshUIWithModelAndcurrentIndexAndplayStatus];
}

- (void)playProcess_refreshUI
{
    if (!self.touchSlider) {
        self.playView.slider.value = self.player.currentDuration / self.player.totalDuration;
    }
    self.playView.beginTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)self.player.currentDuration / 60 , (NSInteger)self.player.currentDuration % 60];
}

- (void)playFinish_refreshUI
{
    self.playView.slider.value = 0.0;
    self.playView.beginTimeLabel.text = @"00:00";
    
    if (self.player.currentIndex >= 0) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:self.player.currentIndex inSection:0];
        [self.tableView deselectRowAtIndexPath:indexP animated:NO];
    }
}

- (void)playListUpdate_refreshUI
{
    if (self.storyArray.count == self.player.musicList.count && self.player.enterType == 3) {
        [self.view ja_makeToast:@"没有更多帖子了"];
    }
    [self listOrderupdate_refreshUI];

}

- (void)listOrderupdate_refreshUI
{
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
    [self.storyArray removeAllObjects];
    [self.storyArray addObjectsFromArray:self.player.musicList];
    [self.tableView reloadData];
    // 刷新cell
    if (self.player.currentIndex >= 0 && self.player.playType != 0) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:self.player.currentIndex inSection:0];
        [self.tableView selectRowAtIndexPath:indexP animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

#pragma mark - 刷新UI
- (void)refreshUIWithModelAndcurrentIndexAndplayStatus
{
    // 刷新头部
    if (![self.headView.storyModel.storyId isEqualToString:self.player.currentMusic.storyId]) {
        self.headView.storyModel = self.player.currentMusic;
    }
    
    // 刷新cell
    if (self.player.currentIndex >= 0 && self.player.playType != 0) {
        NSIndexPath *indexP = [NSIndexPath indexPathForRow:self.player.currentIndex inSection:0];
        [self.tableView selectRowAtIndexPath:indexP animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
    
    // 刷新底部
    if (self.player.playType == 0) {
        self.playView.playButton.selected = NO;
    }else if (self.player.playType == 1){
        self.playView.playButton.selected = YES;
    }else if (self.player.playType == 2){
        [self.playView.playButton setTitle:@"加载中" forState:UIControlStateNormal];
    }
    
    if (self.player.totalDuration > 0) {
        self.playView.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)self.player.totalDuration / 60 , (NSInteger)self.player.totalDuration % 60];
    }
}


#pragma mark - 按钮的点击事件
- (void)dismissBack   // 返回按钮
{
    // 根据类型返回
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 跳转详情
- (void)jumpStoryDetail
{
    if (self.enterType == 4) {
        return;
    }
    JANewVoiceModel *model = self.headView.storyModel;
    
    if (model.storyId.integerValue < 0) {  // 投稿界面
        return;
    }
    
    // 根据类型返回
    [self dismissViewControllerAnimated:YES completion:^{
        
        JABaseViewController *vc = (JABaseViewController *)[self currentViewController];
        
        if ([vc isMemberOfClass:[JAPostDetailViewController class]]) {
            JAPostDetailViewController *detaiVc = (JAPostDetailViewController *)vc;
            detaiVc.musicList = [self.player.musicList copy];
            detaiVc.sourcePage = self.player.currentMusic.sourcePage;
            detaiVc.sourcePageName = self.player.currentMusic.sourcePageName;
            // 直接刷新界面
            [detaiVc postDetail_refreshViewWithId:model.storyId];
        }else{
            // 跳转详情
            JAPostDetailViewController *detaiVc = [[JAPostDetailViewController alloc] init];
            detaiVc.voiceId = model.storyId;
            detaiVc.sourcePage = self.player.currentMusic.sourcePage;
            detaiVc.sourcePageName = self.player.currentMusic.sourcePageName;
            detaiVc.musicList = [self.player.musicList copy];
            [vc.navigationController pushViewController:detaiVc animated:YES];
        }
    }];
}

// 点击播放顺序
- (void)playView_clickOrder:(UIButton *)button
{
    button.selected = !button.selected;
    [self.player playTool_playSortWithOrder:!button.selected];
    
    if (kPlayVCSwitch_new) { // 新版逻辑
        if (self.player.enterType != 3) {
            self.tableView.mj_footer.hidden = YES;
            self.tableView.mj_header.hidden = YES;
        }else{
            if (self.player.playOrder_zheng) {
                self.tableView.mj_footer.hidden = NO;
                self.tableView.mj_header.hidden = YES;
            }else{
                self.tableView.mj_header.hidden = NO;
                self.tableView.mj_footer.hidden = YES;
            }
        }
    }
}

// 点击上一首
- (void)playView_clickFrontMusic:(UIButton *)button
{
    [self.player playTool_playFrontMusic];
}

// 点击下一首
- (void)playView_clickNextMusic:(UIButton *)button
{
    [self.player playTool_playNextMusic];
}

// 点击播放
- (void)playView_clickPlayMusic:(UIButton *)button
{
    button.selected = !button.selected;
    [self.player playTool_playWithMusics:self.player.musicList index:self.player.currentIndex];
}

// 拖动进度条
- (void)playView_dragSlider:(JASlider *)slider
{
    self.touchSlider = NO;
    double second = [NSString getSeconds:self.player.currentMusic.time];
    [self.player playTool_seetValue:second * slider.value];
}

- (void)playView_downSlider:(JASlider *)slider
{
    self.touchSlider = YES;
}

#pragma mark - tableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取帖子 播放当前帖子
    [self.player playTool_playWithMusics:self.player.musicList index:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.storyArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JANewVoiceModel *model = self.storyArray[indexPath.row];
    JAPlayListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAPlayListCell_id"];
    cell.storyModel = model;
    return cell;
}

#pragma mark - UI
- (void)setupStoryPlayViewControllerUI
{
    UIImageView *tableBackImaeView = [[UIImageView alloc] init];
    _tableBackImaeView = tableBackImaeView;
    tableBackImaeView.image = [UIImage imageNamed:@"playList_back"];
    tableBackImaeView.backgroundColor = HEX_COLOR(0xededed);
    tableBackImaeView.userInteractionEnabled = YES;
    tableBackImaeView.clipsToBounds = YES;
    [self.view addSubview:tableBackImaeView];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backButton = backButton;
    [backButton setImage:[UIImage imageNamed:@"musicList_back"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(dismissBack) forControlEvents:UIControlEventTouchUpInside];
    [tableBackImaeView addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    _titleLabel = titleLabel;
    titleLabel.text = @"播放列表";
    titleLabel.textColor = HEX_COLOR(0xffffff);
    titleLabel.font = JA_REGULAR_FONT(18);
    [tableBackImaeView addSubview:titleLabel];
    
    JAPlayHeadView *headView = [[JAPlayHeadView alloc] init];
    _headView = headView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpStoryDetail)];
    [headView addGestureRecognizer:tap];
    [tableBackImaeView addSubview:headView];
    
    UITableView *tableView = [[UITableView alloc] init];
    _tableView = tableView;
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.estimatedRowHeight =0;
    tableView.estimatedSectionHeaderHeight =0;
    tableView.estimatedSectionFooterHeight =0;
    [tableView registerClass:[JAPlayListCell class] forCellReuseIdentifier:@"JAPlayListCell_id"];
    [tableBackImaeView addSubview:tableView];
    
    JAPlayBottomView *playView = [[JAPlayBottomView alloc] init];
    _playView = playView;
    [playView.playButton addTarget:self action:@selector(playView_clickPlayMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView.frontButton addTarget:self action:@selector(playView_clickFrontMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView.nextButton addTarget:self action:@selector(playView_clickNextMusic:) forControlEvents:UIControlEventTouchUpInside];
    [playView.orderButton addTarget:self action:@selector(playView_clickOrder:) forControlEvents:UIControlEventTouchUpInside];
    [playView.infoButton addTarget:self action:@selector(jumpStoryDetail) forControlEvents:UIControlEventTouchUpInside];
    [playView.slider addTarget:self action:@selector(playView_dragSlider:) forControlEvents:UIControlEventValueChanged];
    [playView.slider addTarget:self action:@selector(playView_downSlider:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:playView];
    
    [self calculatorStoryPlayViewControllerFrame];
}


- (void)calculatorStoryPlayViewControllerFrame
{
    self.playView.width = JA_SCREEN_WIDTH;
    self.playView.height = 150;
    self.playView.y = self.view.height - self.playView.height;
    
    self.tableBackImaeView.width = JA_SCREEN_WIDTH;
    self.tableBackImaeView.height = self.view.height - self.playView.height;
    
    self.backButton.width = 22;
    self.backButton.height = 44;
    self.backButton.x = 10;
    self.backButton.y = JA_StatusBarAndNavigationBarHeight - 44;
    self.backButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    
    [self.titleLabel sizeToFit];
    self.titleLabel.centerX = self.tableBackImaeView.width * 0.5;
    self.titleLabel.centerY = self.backButton.centerY;
    
    self.headView.width = JA_SCREEN_WIDTH;
    self.headView.height = 95;
    self.headView.y = self.backButton.bottom;
    
    self.tableView.width = JA_SCREEN_WIDTH;
    self.tableView.height = self.tableBackImaeView.height - self.headView.bottom;
    self.tableView.y = self.headView.bottom;
}

- (UIViewController *) findBestViewController:(UIViewController *)vc {
    if (vc.presentedViewController) {
        // Return presented view controller
        return [self findBestViewController:vc.presentedViewController];
    } else if ([vc isKindOfClass:[UISplitViewController class]]) {
        // Return right hand side
        UISplitViewController* svc = (UISplitViewController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.viewControllers.lastObject];
        else
            return vc;
    } else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController* svc = (UINavigationController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.topViewController];
        else
            return vc;
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController* svc = (UITabBarController*) vc;
        if (svc.viewControllers.count > 0)
            return [self findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

- (UIViewController *) currentViewController {
     MMDrawerController *vc = (MMDrawerController *)[AppDelegate sharedInstance].window.rootViewController;
    JABaseNavigationController *nav = (JABaseNavigationController *)vc.centerViewController;
    CYLTabBarController *tab = (CYLTabBarController *)nav.childViewControllers.firstObject;
    return [self findBestViewController:tab];
}
@end
