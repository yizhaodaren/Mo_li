//
//  JAInviteFriendViewController.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAInviteFriendViewController.h"
#import "JAInviteTableViewCell.h"
#import "JAInviteModel.h"
#import "JAAnswerRecommendNoneView.h"
#import "JAPersonalCenterViewController.h"
#import "JAVoiceModel.h"

@interface JAInviteFriendViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JAAnswerRecommendNoneView *noneView;

@end

@implementation JAInviteFriendViewController


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
    
    @WeakObj(self)
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getFriendListWithLoadMore:NO];
    }];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getFriendListWithLoadMore:YES];
    }];
    
    [self.view addSubview:self.noneView];
    
    [RACObserve(self.model, friendCount) subscribeNext:^(id x) {
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
        if (self.model.friendNoMoreData) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer resetNoMoreData];
        }
    }];
    
    [self requestFirstPageData];
}

- (void)requestFirstPageData {
    if (self.model.friendCount == 0) {
        [self.model getFriendListWithLoadMore:NO success:nil failure:nil];
    }
}

#pragma mark - Network
- (void)getFriendListWithLoadMore:(BOOL)isLoadMore {
    @WeakObj(self)
    [self.model getFriendListWithLoadMore:isLoadMore success:^{
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
    [self.model inviteUserWithIndexPath:indexPath type:1 success:^{
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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.model.friendCount;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAConsumer *data = [self.model friendDataAtIndex:indexPath.row];
    
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
    @WeakObj(self)
    cell.controlBlock = ^(JAInviteTableViewCell *cell){
        @StrongObj(self)
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        JAConsumer *data = [self.model friendDataAtIndex:indexPath.row];
        [self sensorsAnalytics:@"邀请关注的人" personId:data.userId.length ? data.userId : data.consumerId name:data.name];
        if (data.inviteStatus.length && [data.inviteStatus integerValue] > 0) {
        } else {
            [self inviteUserWithIndexPath:indexPath];
        }
    };
    JAConsumer *data = [self.model friendDataAtIndex:indexPath.row];
    cell.data = data;
    return cell;
}

- (JAAnswerRecommendNoneView *)noneView
{
    if (_noneView == nil)
    {
        _noneView = [[JAAnswerRecommendNoneView alloc] initWithFrame:self.view.bounds];
        _noneView.backgroundColor = [UIColor clearColor];
        _noneView.hidden = YES;
        _noneView.message = @"你还没有关注任何人";
        _noneView.messageLabel.textColor = HEX_COLOR(0x7e8392);
        _noneView.messageLabel.font = [UIFont systemFontOfSize:18];

        _noneView.addButton.hidden = YES;
    }
    return _noneView;
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
