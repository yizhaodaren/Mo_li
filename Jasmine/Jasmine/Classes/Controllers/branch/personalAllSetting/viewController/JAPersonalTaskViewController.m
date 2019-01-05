//
//  JAPersonalTaskViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalTaskViewController.h"
#import "JASignTaskView.h"
#import "JAVoicePersonApi.h"
#import "JAPersonalTaskCell.h"
#import "JATaskModel.h"
#import "JATaskGroupModel.h"
#import "JATaskRowModel.h"
#import "JAUserApiRequest.h"
#import "JAShareRegistModel.h"
#import "JAVoiceCommonApi.h"

#import "JAPlatformShareManager.h"
#import "JALoginManager.h"

#import "JAPersonalSharePictureViewController.h"
#import "JAEditInfoViewController.h"
#import "JAPacketViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAWebViewController.h"
#import "JAOpenInvitePacketViewController.h"
#import "JAAccountActionViewController.h"
#import "JAReleasePostManager.h"
#import "JATaskCheckVoiceViewController.h"

#import "CYLTabBarController.h"

typedef NS_ENUM(NSUInteger, JATaskOpenType) {
    JATaskOpenTypeEditPerson = 0,     // 编辑个人资料
    JATaskOpenTypeInvitePacket = 1,    // 邀请红包
    JATaskOpenTypeShareIncome = 2,    // 分享收入
    JATaskOpenTypeRecordStory = 3,   // 发布故事
    JATaskOpenTypeStoryList = 4,     // 首页
    JATaskOpenTypeOpenInviteCode = 5,  // 邀请
    JATaskOpenTypeOpenBindingAccount = 6,  // 绑定 - 直接绑定微信
    JATaskOpenTypeOpenCallFriend = 7,  // 唤醒好友
    JATaskOpenTypeOpenWX = 8,  // 朋友圈
    JATaskOpenTypeOpenMINI = 9,  // 微信小程序
    JATaskOpenTypeWeb = 16,  //跳h5
    
};
@interface JAPersonalTaskViewController ()<UITableViewDelegate,UITableViewDataSource,PlatformShareDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) JASignTaskView *taskView;

@property (nonatomic, strong) JATaskModel *model;

@property (nonatomic, strong) JAShareRegistModel *shareRegisetModel;

@property (nonatomic, strong) MBProgressHUD *currentProgressHUD;

@property (nonatomic, assign) NSInteger shareToType;  // 分享到的地方  1：分享邀请注册  2：分享小程序
@end

@implementation JAPersonalTaskViewController

- (void)actionLeft
{
    if ([self.fromType isEqualToString:@"web"]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setCenterTitle:@"任务"];
    
    [self setupTaskUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getPersonalTask) name:@"taskFinish_refresh" object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getPersonalTask];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"任务中心";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)setupTaskUI
{
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView = tableView;
    tableView.height = JA_SCREEN_HEIGHT - 64;
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[JAPersonalTaskCell class] forCellReuseIdentifier:@"taskCell"];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    
    JASignTaskView *taskView = [[JASignTaskView alloc] init];
    _taskView = taskView;
    taskView.height = WIDTH_ADAPTER(378);
    tableView.tableHeaderView = taskView;
}

#pragma mark - tableView
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取cell数据
    JATaskGroupModel *group = self.model.msgTaskList[indexPath.section];
    // 计算高度
    CGSize max = CGSizeMake(JA_SCREEN_WIDTH - 75 - 30 - 15, MAXFLOAT);
    JATaskRowModel *data = group.taskList[indexPath.row];
    CGFloat height = [data.taskDescription boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_LIGHT_FONT(13)} context:nil].size.height;
    
    data.unfold = !data.unfold;
    
    if (data.unfold) {
        
        data.cellHeight = 50 + 18 + height;
    }else{
        data.cellHeight = 50;
    }
    
    [self.tableView reloadData];
    
    JAPersonalTaskCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSArray *cellArr = [self.tableView visibleCells];
    if (cell == cellArr.lastObject) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.model.msgTaskList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // 获取行数
    JATaskGroupModel *group = self.model.msgTaskList[section];
    return group.taskList.count;  
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAPersonalTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell"];
    
    // 获取model
    JATaskGroupModel *group = self.model.msgTaskList[indexPath.section];
    JATaskRowModel *row = group.taskList[indexPath.row];
    
    cell.model = row;
    
    @WeakObj(self);
    cell.showAllBlock = ^(JAPersonalTaskCell *cell) {
        @StrongObj(self);
        // 计算高度
        CGSize max = CGSizeMake(JA_SCREEN_WIDTH - 75 - 30 - 15, MAXFLOAT);
        JATaskRowModel *data = cell.model;
        CGFloat height = [data.taskDescription boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_LIGHT_FONT(13)} context:nil].size.height;
        
        data.unfold = !data.unfold;
        
        if (data.unfold) {
            
            data.cellHeight = 50 + 18 + height;
        }else{
            data.cellHeight = 50;
        }
        
        [self.tableView reloadData];
        
        NSArray *cellArr = [self.tableView visibleCells];
        if (cell == cellArr.lastObject) {
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    };
    
    cell.jumpvc = ^(JAPersonalTaskCell *cell) {
        @StrongObj(self);
//        [self.navigationController popToRootViewControllerAnimated:YES];
        
        // 获取model
        JATaskRowModel *model = cell.model;
       
        if (model.taskOpenType.integerValue == JATaskOpenTypeEditPerson || model.taskOpenType.integerValue == 101) {
            
            JAEditInfoViewController *vc = [[JAEditInfoViewController alloc] init];
            JAConsumer *personalModel = [[JAConsumer alloc] init];
            personalModel.consumerId = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            personalModel.name = [JAUserInfo userInfo_getUserImfoWithKey:User_Name];
            personalModel.image = [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl];
            personalModel.address = [JAUserInfo userInfo_getUserImfoWithKey:User_Address];
            personalModel.age = [JAUserInfo userInfo_getUserImfoWithKey:User_Age];
            personalModel.sex = [JAUserInfo userInfo_getUserImfoWithKey:User_Sex];
            personalModel.constellation = [JAUserInfo userInfo_getUserImfoWithKey:User_Constellation];
            personalModel.concernUserCount = [JAUserInfo userInfo_getUserImfoWithKey:User_concernUserCount];
            personalModel.userConsernCount = [JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount];
            personalModel.agreeCount = [JAUserInfo userInfo_getUserImfoWithKey:User_agree];
            personalModel.uuid = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
            personalModel.birthdayName = [JAUserInfo userInfo_getUserImfoWithKey:User_Birthday];
            personalModel.introduce = [JAUserInfo userInfo_getUserImfoWithKey:User_Introduce];
            vc.model = personalModel;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeInvitePacket || model.taskOpenType.integerValue == 110){
            
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeShareIncome || model.taskOpenType.integerValue == 117){

            JAPersonalSharePictureViewController *vc = [[JAPersonalSharePictureViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeRecordStory || model.taskOpenType.integerValue == 122){
            if ([JAReleasePostManager shareInstance].postDraftModel.uploadState == JAUploadUploadingState) {
                [self.view ja_makeToast:@"你有帖子正在上传中，请上传完毕后再发帖"];
                return;
            }
            JAVoiceRecordViewController *vc = [[JAVoiceRecordViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeStoryList || model.taskOpenType.integerValue == 123){
            
            [[self cyl_tabBarController].selectedViewController popToRootViewControllerAnimated:NO];
            [self cyl_tabBarController].selectedIndex = 0;
            
            JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
            [vc.titleView setSelectedItemIndex:1];
//            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeOpenInviteCode || model.taskOpenType.integerValue == 113){
            
            // 判断是否可以邀请
            NSString *inviteUid = [JAUserInfo userInfo_getUserImfoWithKey:User_InviteUuid];
            if (inviteUid.length) {

                [self.view ja_makeToast:@"您已经完成该任务了"];
            }else{
                
                JAOpenInvitePacketViewController *vc = [[JAOpenInvitePacketViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeOpenBindingAccount || model.taskOpenType.integerValue == 313){
            
//            JAAccountActionViewController *vc = [[JAAccountActionViewController alloc] init];
//            [self.navigationController pushViewController:vc animated:YES];
//
            // 去绑定三方
            [[JALoginManager shareInstance] loginWithType:JALoginType_Wechat];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeOpenCallFriend || model.taskOpenType.integerValue == 112){
            
            // 唤醒好友
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            vc.type = 1;
            vc.callFriend = 1;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeOpenWX || model.taskOpenType.integerValue == 309){
            
            [self getUserShareInfoToWX];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeOpenMINI || model.taskOpenType.integerValue == 312){
            
            [self getUserShareMiniProgramToWX];
            
        }else if (model.taskOpenType.integerValue == JATaskOpenTypeWeb || model.taskOpenType.integerValue == 300){
            
            JAWebViewController *vc = [[JAWebViewController alloc] init];
            vc.urlString = model.taskOpenUrl;
            vc.enterType = @"任务中心";
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if (model.taskOpenType.integerValue == 129){
            
            JATaskCheckVoiceViewController *vc = [[JATaskCheckVoiceViewController alloc] init];
            vc.flower = [NSString stringWithFormat:@"%ld",model.taskFlower.integerValue * model.taskFinishCount.integerValue];
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 获取model
    JATaskGroupModel *group = self.model.msgTaskList[indexPath.section];
    JATaskRowModel *row = group.taskList[indexPath.row];
    
    return row.cellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    JATaskGroupModel *group = self.model.msgTaskList[section];
    
    UIView *v = [[UIView alloc] init];
//    v.backgroundColor = HEX_COLOR(0xF3F7F8);
    v.backgroundColor = HEX_COLOR(0xffffff);
    v.width = JA_SCREEN_WIDTH;
    v.height  =30;
    
    if (section == 0) {
        UIView *lineView1 = [[UIView alloc] init];
        lineView1.backgroundColor = HEX_COLOR(0xDFEFEE);
        lineView1.width = v.width;
        lineView1.height = 1;
//        [v addSubview:lineView1];
    }
    
    UIView *lineView2 = [[UIView alloc] init];
//    lineView2.backgroundColor = HEX_COLOR(0xDFEFEE);
    lineView2.backgroundColor = HEX_COLOR(JA_Line);
    lineView2.width = v.width;
    lineView2.height = 1;
    lineView2.y = v.height - lineView2.height;
    [v addSubview:lineView2];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = group.name;
    label.textColor = HEX_COLOR(JA_Branch_Green);
    label.font = JA_REGULAR_FONT(12);
    [v addSubview:label];
    [label sizeToFit];
    label.x = 15;
    label.centerY = v.height * 0.5;
    
    return v;
}

#pragma mark - 网络请求
// 获取任务
- (void)getPersonalTask
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAVoicePersonApi shareInstance] voice_taskWithPara:dic success:^(NSDictionary *result) {
        self.model = [JATaskModel mj_objectWithKeyValues:result];
        self.taskView.moneyString = self.model.money;
        self.taskView.flowerString = self.model.flower;
        
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        
    }];
}

#pragma mark - 获取分享邀请链接
- (void)getUserShareInfoToWX
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"uuid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    [[JAUserApiRequest shareInstance] userShareInviteInfo:param success:^(NSDictionary *result) {
        [self.currentProgressHUD hideAnimated:NO];
        NSDictionary *resultDic = result[@"resMap"];
        if (resultDic) {
            
            JAShareRegistModel *shareRegisetModel = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];
            
            AppDelegate *appDelegate = [AppDelegate sharedInstance];
            appDelegate.shareDelegate = self;
            self.shareToType = 1;
            
            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareRegisetModel.title;
            model.shareUrl = shareRegisetModel.url;
            model.image = shareRegisetModel.logo;
            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareContent:model domainType:1];
            
        }
    } failure:^(NSError *error) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.view ja_makeToast:@"获取分享信息失败，请重试"];
    }];
}

#pragma mark - 获取分享小程序的分享链接
- (void)getUserShareMiniProgramToWX
{
    self.currentProgressHUD = [MBProgressHUD showMessage:nil toView:self.view];

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"type"] = @"samll_routine_configuration";
    // 获取分享小程序的网络请求
    [[JAUserApiRequest shareInstance] userShareMiniInfo:param success:^(NSDictionary *result) {
        [self.currentProgressHUD hideAnimated:NO];
        NSDictionary *resultDic = result[@"resMap"];
        if (resultDic) {

            JAShareRegistModel *shareRegisetModel = [JAShareRegistModel mj_objectWithKeyValues:result[@"resMap"]];

            AppDelegate *appDelegate = [AppDelegate sharedInstance];
            appDelegate.shareDelegate = self;
            self.shareToType = 2;

            JAShareModel *model = [[JAShareModel alloc] init];
            model.title = shareRegisetModel.title;
            model.descripe = shareRegisetModel.content;
            model.shareUrl = shareRegisetModel.url;
            model.image = shareRegisetModel.logo;
            model.miniProgramId = shareRegisetModel.miniProgramId;
            model.miniProgramPath = shareRegisetModel.miniProgramPath;
            [JAPlatformShareManager wxShareMiniProgram:WeiXinShareTypeTimeline shareContent:model domainType:1];
            
            // 点了分享就算 - 分享小程序成功
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = @"1";
            [[JAVoiceCommonApi shareInstance] voice_appShareRegistTaskWithParas:dic success:^(NSDictionary *result) {
                
            } failure:^(NSError *error) {
                
            }];

        }
    } failure:^(NSError *error) {
        [self.currentProgressHUD hideAnimated:NO];
        [self.view ja_makeToast:@"获取分享信息失败，请重试"];
    }];
}

- (void)qqShare:(NSString *)error {
    
}

- (void)wbShare:(int)code {
    
}

- (void)wxShare:(int)code   // 分享邀请链接 成功后才算完成任务
{
    if (code == 0) {
        // 分享邀请链接成功的回调
        if (self.shareToType == 1) {
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            dic[@"type"] = @"0";
            [[JAVoiceCommonApi shareInstance] voice_appShareRegistTaskWithParas:dic success:^(NSDictionary *result) {
                [self getPersonalTask];
            } failure:^(NSError *error) {
                
            }];
        }
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

- (void)dealloc
{
    [self.taskView invalidateTime];
}

@end
