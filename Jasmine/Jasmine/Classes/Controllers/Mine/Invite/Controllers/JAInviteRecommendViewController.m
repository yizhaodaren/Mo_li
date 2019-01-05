//
//  JAInviteRecommendViewController.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAInviteRecommendViewController.h"
#import "JAInviteTableViewCell.h"
#import "JAInviteModel.h"
#import "JAPersonalCenterViewController.h"
#import "JAAnswerRecommendNoneView.h"
#import "JAInviteHeaderView.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceModel.h"

@interface JAInviteRecommendViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JAAnswerRecommendNoneView *noneView;
@property (nonatomic, weak) JAInviteHeaderView *headerView;

@end

@implementation JAInviteRecommendViewController


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     // tableView
     UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - 64)];
     tableView.backgroundColor = [UIColor clearColor];
     tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
     tableView.delegate = self;
     tableView.dataSource = self;
     
     [self.view addSubview:tableView];
     self.tableView = tableView;
    
    JAInviteHeaderView *headerView = [[JAInviteHeaderView alloc] init];
    headerView.height = 160;
    _headerView = headerView;
    @WeakObj(self)
    headerView.randomInvite = ^{   // 随机邀请
        @StrongObj(self);
        [self randomInviteWithType:nil];
        [self sensorsAnalytics:@"随机邀请有缘人" personId:nil name:nil];
    };
    
    headerView.randomInviteWoman = ^{   // 随机邀请女生
        @StrongObj(self);
        [self randomInviteWithType:@"2"];
        [self sensorsAnalytics:@"随机邀请女士" personId:nil name:nil];
    };
    
    headerView.randomInviteMan = ^{    // 随机邀请男生
        @StrongObj(self);
        [self randomInviteWithType:@"1"];
        [self sensorsAnalytics:@"随机邀请男士" personId:nil name:nil];
    };
    self.tableView.tableHeaderView = headerView;
    
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getRecommendListWithLoadMore:NO];
    }];

    
    [self.view addSubview:self.noneView];
    
    [RACObserve(self.model, recommendCount) subscribeNext:^(id x) {
        @StrongObj(self)
        NSNumber *number = x;
        if (number.integerValue > 0) {
            self.noneView.hidden = YES;
            self.tableView.hidden = NO;
            [self.tableView reloadData];
        } else {
            self.noneView.hidden = NO;
            self.tableView.hidden = YES;
        }
        if (self.model.recommendNoMoreData) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer resetNoMoreData];
        }
    }];
    
    [self requestFirstPageData];
}

- (void)requestFirstPageData {
    if (self.model.recommendCount == 0) {
        [self.model getRecommendListWithLoadMore:NO success:nil failure:nil];
    }
}

#pragma mark - Network
- (void)getRecommendListWithLoadMore:(BOOL)isLoadMore {
    @WeakObj(self)
    [self.model getRecommendListWithLoadMore:isLoadMore success:^{
        @StrongObj(self)
        [self endRefreshing];
    } failure:^(NSError *error) {
        @StrongObj(self)
        [self endRefreshing];
    }];
}

- (void)endRefreshing {
  
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (void)inviteUserWithIndexPath:(NSIndexPath *)indexPath {
    @WeakObj(self)
    [self.model inviteUserWithIndexPath:indexPath type:0 success:^{
        @StrongObj(self)
        [self reloadFollowStateWithIndexPath:indexPath];
    } failure:^(NSError *error) {
        
    }];
}

- (void)reloadFollowStateWithIndexPath:(NSIndexPath *)indexPath {
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    [self.tableView endUpdates];
}

#pragma mark UITableView delegate and dataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HEIGHT_INVITE_CELL;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = HEX_COLOR(0xF9F9F9);
    view.width = JA_SCREEN_WIDTH;
    view.height = 30;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"邀请茉莉达人";
    label.textColor = HEX_COLOR(JA_Branch_Green);
    label.font = JA_MEDIUM_FONT(14);
    [label sizeToFit];
    label.x = 14;
    label.centerY = 15;
    [view addSubview:label];
    return view;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.recommendCount;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAConsumer *data = [self.model recommendDataAtIndex:indexPath.row];
    
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    vc.personalModel = data;
    [self.navigationController pushViewController:vc animated:YES];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idstring = @"JAInviteTableViewCellID";
    JAInviteTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idstring];
    if (cell == nil)
    {
     
        cell = [[JAInviteTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idstring];
    }
    JAConsumer *data = [self.model recommendDataAtIndex:indexPath.row];
    cell.data = data;
    @WeakObj(self)
    cell.controlBlock = ^(JAInviteTableViewCell *cell){
        @StrongObj(self)
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        JAConsumer *data = [self.model recommendDataAtIndex:indexPath.row];
        [self sensorsAnalytics:@"邀请茉莉达人" personId:data.userId.length ? data.userId : data.consumerId name:data.name];
        if (data.inviteStatus.length && [data.inviteStatus integerValue] > 0) {
        } else {
            [self inviteUserWithIndexPath:indexPath];
        }
    };
    

    
    return cell;
    
}


- (JAAnswerRecommendNoneView *)noneView
{
    if (_noneView == nil)
    {
        _noneView = [[JAAnswerRecommendNoneView alloc] initWithFrame:self.view.bounds];
        _noneView.backgroundColor = [UIColor clearColor];
        _noneView.hidden = YES;
        _noneView.message = @"暂时没有推荐邀请人";
        _noneView.addButton.hidden = YES;
    }
    return _noneView;
}

#pragma mark - 随机邀请
- (void)randomInviteWithType:(NSString *)type
{
    if (!IS_LOGIN) {
        
        [JAAPPManager app_modalLogin];
        
        return;
    }
    
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    if (type.length) {
        
        dic[@"sex"] = type;
    }
    
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"typeId"] = self.model.typeId;
    dic[@"type"] = @"story";
    
    [[JAVoiceCommonApi shareInstance] voice_inviteRandomWithParas:dic success:^(NSDictionary *result) {
       
        [self.view ja_makeToast:@"邀请成功"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.navigationController popViewControllerAnimated:YES];
        });
        
    } failure:^(NSError *error) {
        [self.view ja_makeToast:error.localizedDescription];
    }];
}

- (void)sensorsAnalytics:(NSString *)mothod personId:(NSString *)uid name:(NSString *)name
{
    // 神策数据
    // 计算时间
    NSArray *timeArr = [self.inviteModel.time componentsSeparatedByString:@":"];
    NSString *min = timeArr.firstObject;
    NSString *sec = timeArr.lastObject;
    NSInteger sen_time = min.integerValue * 60 + sec.integerValue;
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//    senDic[JA_Property_Category] = [JAConfigManager shareInstance].channelDic[self.inviteModel.categoryId];
    senDic[JA_Property_ContentId] = self.inviteModel.voiceId;
    senDic[JA_Property_ContentTitle] = self.inviteModel.content;
    senDic[JA_Property_Anonymous] = @(self.inviteModel.isAnonymous);
    senDic[JA_Property_RecordDuration] = @(sen_time);
    senDic[JA_Property_PostId] = self.inviteModel.userId;
    senDic[JA_Property_PostName] = self.inviteModel.userName;
    senDic[JA_Property_InvitationMethod] = mothod;
    if (uid.length) senDic[JA_Property_BeRequestedName] = name;
    if (name.length) senDic[JA_Property_BeRequestedId] = uid;
    [JASensorsAnalyticsManager sensorsAnalytics_InvitePerson:senDic];
}
@end
