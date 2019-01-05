//
//  JADraftViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/22.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JADraftViewController.h"
#import "JADraftCell.h"
#import "JAReleasePostManager.h"
#import "JAVoiceReleaseViewController.h"
#import "JAVoicePlayerManager.h"
#import "JASampleHelper.h"

@interface JADraftViewController ()<UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate>

@property (nonatomic, strong) UILabel *topLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *drafts;

@end

@implementation JADraftViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"草稿箱"];
    
    self.drafts = [[[JAReleasePostManager shareInstance] getPostInDraft] mutableCopy];
    
    [self setupDraftUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgress:) name:@"JAUploadProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadState:) name:@"JAUploadState" object:nil];
    // 草稿标记已读
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [JAPostDraftModel updateToDBWithSet:@"isRead='1'" where:@{@"isRead":@(NO)}];
        // 草稿箱已读更改
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JA_DraftCountChange" object:nil];
    });
}

- (void)uploadProgress:(NSNotification *)noti {
    JAPostDraftModel *currentDraftModel = [JAReleasePostManager shareInstance].postDraftModel;
    for (JAPostDraftModel *model in self.drafts) {
        if (currentDraftModel.rowid == model.rowid) {
            model.progress = currentDraftModel.progress;
            break;
        }
    }
    [self.tableView reloadData];
}

- (void)uploadState:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        JAPostDraftModel *currentDraftModel = [JAReleasePostManager shareInstance].postDraftModel;
        for (JAPostDraftModel *model in self.drafts) {
            if (currentDraftModel.rowid == model.rowid) {
                model.uploadState = currentDraftModel.uploadState;
                // v2.5.5 还要重新赋值帖子的dataType，不然没法显示进度
                model.dataType = currentDraftModel.dataType;
                break;
            }
        }
        // v2.5.5
        BOOL isNeedRefresh = NO;
        if (currentDraftModel.uploadState == JAUploadSuccessState) {
            // 上传完成后，需删除本地草稿，需要更新数据源
            isNeedRefresh = YES;
        }
        if (currentDraftModel.dataType == 1 || currentDraftModel.dataType == 2) {
            // 重新编辑后，发布失败，标题如有变动需要更新页面
            if (currentDraftModel.uploadState == JAUploadFailState) {
                isNeedRefresh = YES;
            }
        }
        if (isNeedRefresh) {
            self.drafts = [[[JAReleasePostManager shareInstance] getPostInDraft] mutableCopy];
            [self.tableView reloadData];
        }
    });
}

- (void)setupDraftUI
{
    self.topLabel = [[UILabel alloc] init];
    self.topLabel.text = @"你的草稿在卸载茉莉后会消失，请及时发布!";
    self.topLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.topLabel.font = JA_REGULAR_FONT(13);
    self.topLabel.backgroundColor = HEX_COLOR(0xEDEDED);
    self.topLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.topLabel];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[JADraftCell class] forCellReuseIdentifier:@"DraftVC_DraftCell"];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.topLabel.width = JA_SCREEN_WIDTH;
    self.topLabel.height = 25;
    
    self.tableView.width = JA_SCREEN_WIDTH;
    self.tableView.height = self.view.height - self.topLabel.height;
    self.tableView.y = self.topLabel.bottom;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    [self showBlankPage];
    return self.drafts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JADraftCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DraftVC_DraftCell"];
    JAPostDraftModel *draftModel = self.drafts[indexPath.row];
    cell.data = draftModel;
    @WeakObj(self);
    cell.playBlock = ^(JADraftCell *cell) {
        @StrongObj(self);
        NSInteger type = 4; // 草稿箱播放
        
        JANewVoiceModel *voiceModel = [JANewVoiceModel new];
        voiceModel.storyId = cell.data.draftId.length?cell.data.draftId:[NSString stringWithFormat:@"%d",(int)cell.data.rowid];
        NSString *audioUrl = [NSHomeDirectory() stringByAppendingPathComponent:cell.data.localAudioUrl];
        voiceModel.audioUrl = audioUrl;
        voiceModel.time = cell.data.time;
        NSString *title = @"标题为空";
        if (cell.data.storyType == 0) {
            if (cell.data.content.length) {
                title = cell.data.content;
            }
        } else if (cell.data.storyType == 1) {
            if (cell.data.titleModel.textContent.length) {
                title = cell.data.titleModel.textContent;
            }
        }
        voiceModel.content = title;
        JALightUserModel *user = [JALightUserModel new];
        user.userName = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
        voiceModel.user = user;
        
        NSMutableArray *storyList = [NSMutableArray new];
        [self.drafts enumerateObjectsUsingBlock:^(JAPostDraftModel *obj, NSUInteger idx, BOOL *stop) {
            if (obj.storyType == 0) {
                JANewVoiceModel *voiceModel = [JANewVoiceModel new];
                voiceModel.storyId = obj.draftId.length?obj.draftId:[NSString stringWithFormat:@"%d",(int)obj.rowid];
                NSString *audioUrl = [NSHomeDirectory() stringByAppendingPathComponent:obj.localAudioUrl];
                voiceModel.audioUrl = audioUrl;
                voiceModel.time = obj.time;
                NSString *title = @"标题为空";
                if (obj.storyType == 0) {
                    if (obj.content.length) {
                        title = obj.content;
                    }
                } else if (obj.storyType == 1) {
                    if (obj.titleModel.textContent.length) {
                        title = obj.titleModel.textContent;
                    }
                }
                voiceModel.content = title;
                JALightUserModel *user = [JALightUserModel new];
                user.userName = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
                voiceModel.user = user;
                
                [storyList addObject:voiceModel];
            }
        }];
        [[JANewPlayTool shareNewPlayTool] playTool_playWithModel:voiceModel storyList:storyList enterType:type albumParameter:nil];
    };
    cell.reuploadBlock = ^(JADraftCell *cell) {
        @StrongObj(self);
        if (cell.data.dataType == 0) {
            if (![JAAPPManager isConnect]) {
                [[UIApplication sharedApplication].delegate.window ja_makeToast:@"请检查您的网络！"];
                return;
            }
            if ([JAReleasePostManager shareInstance].postDraftModel.uploadState == JAUploadUploadingState) {
                [self.view ja_makeToast:@"你有帖子正在上传中，请上传完毕后再发帖"];
                return;
            }
            [[JAReleasePostManager shareInstance] asyncReleasePost:draftModel method:0];
        } else if (cell.data.dataType == 1 || cell.data.dataType == 2) {
            // 重新编辑草稿（匿名状态、描述、位置信息、波形图、图片）
            JAVoiceReleaseViewController *vc = [JAVoiceReleaseViewController new];
            // 公共参数
            vc.postDraftModel = draftModel;
            vc.storyType = cell.data.storyType;
            vc.fromType = 7;
            vc.isAnonymous = [cell.data.isAnonymous boolValue];
            vc.city = cell.data.city;
            if (cell.data.circle.circleId.length && cell.data.circle.circleName.length) {
                JACircleModel *circleModle = [JACircleModel new];
                circleModle.circleId = cell.data.circle.circleId;
                circleModle.circleName = cell.data.circle.circleName;
                vc.circleModel = circleModle;
            }
            if (vc.storyType == 0) {
                // 音频相关
                vc.time = [NSString getSeconds:cell.data.time];
                vc.content = cell.data.content;
                vc.localAudioUrl = cell.data.localAudioUrl;
                vc.imageInfoArray = cell.data.imageInfoArray;
                vc.allPeakLevelQueue = [JASampleHelper getAllPeakLevelQueueWithSampleZip:cell.data.sampleZip];
            } else if (vc.storyType == 1) {
                // 图文贴
                JARichTitleModel *titleModel = [JARichTitleModel new];
                titleModel.titleContentHeight = cell.data.titleModel.titleContentHeight;
                titleModel.textContent = cell.data.titleModel.textContent;
                vc.titleModel = titleModel;
                if (cell.data.richContentModels.count) {
                    NSMutableArray *datas = [[NSMutableArray alloc] initWithArray:cell.data.richContentModels copyItems:YES];
                    vc.richContentModels = datas;
                }
            }
            [self.navigationController pushViewController:vc animated:YES];
        } else {
        }
    };
    cell.deleteBlock = ^(JADraftCell *cell) {
        @StrongObj(self);
        [self showAlertViewWithTitle:@"确定要删除吗？" subTitle:nil completion:^(BOOL complete) {
            if (complete) {
                [MBProgressHUD showMessage:nil];
                [[JAReleasePostManager shareInstance] removeDraft:draftModel];
                [self.drafts removeObject:draftModel];
                [self.tableView reloadData];
                [MBProgressHUD hideHUD];
                [self.view ja_makeToast:@"删除成功"];
            }
        }];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

// 展示空白页
- (void)showBlankPage
{
    if (self.drafts.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有草稿";
        NSString *st = @"";
        [self showBlankPageWithLocationY:0 title:t subTitle:st image:@"blank_nodraft" buttonTitle:nil selector:nil buttonShow:NO];
    }
}
@end
