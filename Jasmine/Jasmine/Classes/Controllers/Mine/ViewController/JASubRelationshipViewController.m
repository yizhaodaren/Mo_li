
//
//  JASubRelationshipViewController.m
//  Jasmine
//
//  Created by xujin on 08/07/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASubRelationshipViewController.h"
//#import "JAStoryApi.h"
#import "SDCycleScrollView.h"
#import "JAWebViewController.h"
#import "LCActionSheet.h"

#import "JARelationshipTableViewCell.h"
#import "JAPersonalCenterViewController.h"

#import "JAVoicePersonApi.h"
#import "JAConsumer.h"
#import "JAConsumerGroupModel.h"

static NSString *const kJARelationshipCellIdentifier = @"JARelationshipTableViewCell";

@interface JASubRelationshipViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *person;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, copy) void(^updateCount)(NSInteger dataCount);

@end


@implementation JASubRelationshipViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.type == 1) {
//        NSString *str = [NSString stringWithFormat:@"%@关注的人",self.name];
        [self setCenterTitle:@"关注" color:HEX_COLOR(JA_BlackTitle)];
    }else if (self.type == 2){
//        NSString *str = [NSString stringWithFormat:@"%@的粉丝",self.name];
        [self setCenterTitle:@"粉丝" color:HEX_COLOR(JA_BlackTitle)];
    }
    self.person = [NSMutableArray array];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-64-JA_TabbarSafeBottomMargin) style:UITableViewStyleGrouped];
//    if ([self.userId isEqualToString:[JAUserInfo userInfo_getUserImfoWithKey:User_id]]) {
//    } else {
//        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-64) style:UITableViewStyleGrouped];
//    }
//    if ([self.tableView respondsToSelector:@selector(setEstimatedRowHeight:)]) {
//        [self.tableView setEstimatedRowHeight:200];
//    }
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    // iOS11以后默认开启self-sizing，导致加载更多后跳动问题
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.backgroundColor = [UIColor clearColor];
//    if (@available(iOS 11.0, *)) {
//        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//    }else {
//        self.automaticallyAdjustsScrollViewInsets = NO;
//    }
    @WeakObj(self)
    self.tableView.mj_header = [JADIYRefreshHeader headerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getDynamicDataWithLoadMore:NO];
    }];
    
    if (self.type == 0) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:@"JAFriendNotification" object:nil];
    } else if (self.type == 1) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:@"JAFollowNotification" object:nil];
    } else if (self.type == 2) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateData:) name:@"JAFanNotification" object:nil];
    }
}

- (NSString *)get_TA_Type:(NSString *)sex
{
    NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    if ([self.userId isEqualToString:uid]) {
        return @"你";
    }
    if ([sex integerValue] == 1) {
        return @"他";
    }else{
        return @"她";
    }
}

- (void)updateData:(NSNotification *)noti {
    JAConsumer *sender = (JAConsumer *)[noti object];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.type == 0) {
            // 好友,1添加2删除
            __block BOOL isHave = NO;
            if ([sender.friendType integerValue] == 1) {
                [self.person enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JAConsumer *model = (JAConsumer *)obj;
                    if ([model.userId isEqualToString:sender.userId]) {
                        isHave = YES;
                        model.friendType = sender.friendType;
                    }
                }];
                if (!isHave) {
                    [self.person addObject:sender];
                }
            } else if ([sender.friendType integerValue] == 2) {
                [self.person enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JAConsumer *model = (JAConsumer *)obj;
                    if ([model.userId isEqualToString:sender.userId]) {
                        [self.person removeObject:model];
                    }
                }];
            }
        } else if (self.type == 1) {
            // 关注,1添加2删除
            __block BOOL isHave = NO;
            if ([sender.friendType integerValue] == 1) {
                [self.person enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JAConsumer *model = (JAConsumer *)obj;
                    if ([model.userId isEqualToString:sender.userId]) {
                        isHave = YES;
                        model.friendType = sender.friendType;
                    }
                }];
                if (!isHave) {
                    [self.person addObject:sender];
                }
            } else if ([sender.friendType integerValue] == 2) {
                [self.person enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    JAConsumer *model = (JAConsumer *)obj;
                    if ([model.userId isEqualToString:sender.userId]) {
                        [self.person removeObject:model];
                    }
                }];
            }
        } else if (self.type == 2) {
            // 粉丝
            [self.person enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                JAConsumer *model = (JAConsumer *)obj;
                if ([model.userId isEqualToString:sender.userId]) {
                    model.friendType = sender.friendType;
                }
            }];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

- (void)getData:(void(^)(NSInteger dataCount))updateCount {
    self.updateCount = updateCount;
    if (!self.person.count) {
        [self getDynamicDataWithLoadMore:NO];
    } else {
        if (self.updateCount) {
            self.updateCount(self.dataCount);
        }
    }
}

#pragma mark - Network
- (void)getDynamicDataWithLoadMore:(BOOL)isLoadMore {
    if (self.isRequesting) {
        return;
    }
    self.isRequesting = YES;
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer = nil;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"pageNum"] = @(self.currentPage);
    params[@"pageSize"] = @"10";
    if (self.type == 0) {
        // 好友
        params[@"type"] = @"1";
    } else if (self.type == 1) {
        // 关注
        params[@"type"] = @"0";
    } else if (self.type == 2) {
        // 粉丝
        params[@"type"] = @"2";
    }
    params[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    params[@"userId"] = self.userId;

    [[JAVoicePersonApi shareInstance] voice_personalFocusAndFansParas:params success:^(NSDictionary *result) {
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        JAConsumerGroupModel *data = [JAConsumerGroupModel mj_objectWithKeyValues:result[@"friendList"]];
        if (data.result.count) {
            if (self.updateCount) {
                self.updateCount(data.totalCount);
            }
            self.dataCount = data.totalCount;
//            dispatch_async(dispatch_get_main_queue(), ^{
//            });
            self.currentPage++;
            if (!isLoadMore) {
                [self.person removeAllObjects];
                
                    [self removeBlankPage];
                    @WeakObj(self);
                    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                        @StrongObj(self);
                        [self getDynamicDataWithLoadMore:YES];
                    }];
                
            }
            [self.person addObjectsFromArray:data.result];
        } else {
            if (isLoadMore) {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            } else {
                [self.person removeAllObjects];
            }
            if (self.updateCount) {
                self.updateCount(0);
            }
        }
        
        if (data.nextPage == 0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        } else {
            [self.tableView.mj_footer resetNoMoreData];
            
        }
        [self.tableView reloadData];
        if (!self.person.count) {
            NSString *t = nil;
            if (self.type == 0) {
                // 好友
                t = [NSString stringWithFormat:@"%@还没有好友",[self get_TA_Type:self.sex]];
            } else if (self.type == 1) {
                // 关注
                t = [NSString stringWithFormat:@"%@还没有关注任何人",[self get_TA_Type:self.sex]];
                
            } else if (self.type == 2) {
                // 粉丝
                t = [NSString stringWithFormat:@"%@还没有粉丝",[self get_TA_Type:self.sex]];
            }
            [self showBlankPageWithLocationY:0 title:t subTitle:@"" image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO];
        }
    } failure:^(NSError *error) {
        self.isRequesting = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (self.updateCount) {
            self.updateCount(0);
        }
        
        if (!isLoadMore) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO];
        }
//        [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
    }];
    
//    [[JAPersonalApi shareInstance] personal_relationshipType:self.type params:params success:^(NSDictionary *result) {
//        self.isRequesting = NO;
//        [self.tableView.mj_header endRefreshing];
//        [self.tableView.mj_footer endRefreshing];
//        JAFocusPersonGroupModel *data = [JAFocusPersonGroupModel mj_objectWithKeyValues:result[@"arraylist"]];
//        if (data.result.count) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (self.updateCount) {
//                    self.updateCount([data.totalCount integerValue]);
//                }
//                self.dataCount = [data.totalCount integerValue];
//            });
//            self.currentPage++;
//            if (!isLoadMore) {
//                [self.person removeAllObjects];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self removeBlankPage];
//                    @WeakObj(self);
//                    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//                        @StrongObj(self);
//                        [self getDynamicDataWithLoadMore:YES];
//                    }];
//                });
//            }
//            [self.person addObjectsFromArray:data.result];
//        } else {
//            if (isLoadMore) {
//                [self.tableView.mj_footer endRefreshingWithNoMoreData];
//            } else {
//                [self.person removeAllObjects];
//            }
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (self.updateCount) {
//                    self.updateCount(0);
//                }
//            });
//        }
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([data.nextPage integerValue] == 0) {
//                [self.tableView.mj_footer endRefreshingWithNoMoreData];
//            } else {
//                [self.tableView.mj_footer resetNoMoreData];
//                
//            }
//            [self.tableView reloadData];
//            if (!self.person.count) {
//                NSString *t = nil;
//                if (self.type == 0) {
//                    // 好友
//                    t = [NSString stringWithFormat:@"%@还没有好友",[self get_TA_Type:self.sex]];
//                } else if (self.type == 1) {
//                    // 关注
//                    t = [NSString stringWithFormat:@"%@还没有关注任何人",[self get_TA_Type:self.sex]];
//                    
//                } else if (self.type == 2) {
//                    // 粉丝
//                    t = [NSString stringWithFormat:@"%@还没有粉丝",[self get_TA_Type:self.sex]];
//                }
//                [self showBlankPageWithLocationY:0 title:t subTitle:@"" image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO];
//            }
//        });
//        
//        
//    } failure:^{
//        self.isRequesting = NO;
//        [self.tableView.mj_header endRefreshing];
//        [self.tableView.mj_footer endRefreshing];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.updateCount) {
//                self.updateCount(0);
//            }
//            [self showBlankPageWithLocationY:0 title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO];
//        });
//    }];
}

- (void)retryAction {
    [self removeBlankPage];
    [self.tableView.mj_header beginRefreshing];
}

- (void)followUserActionWithCell:(JARelationshipTableViewCell *)cell {
    cell.focusButton.userInteractionEnabled = NO;
    JAConsumer *data = cell.data;
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    params[@"concernId"] = data.userId;
//    params[@"concernType"] = JA_USER_TYPE;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = data.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"关注";
    senDic[JA_Property_PostId] = data.userId;
    senDic[JA_Property_PostName] = data.name;
    if (self.type == 1) {
        senDic[JA_Property_FollowMethod] = @"关注列表";

    }else if (self.type == 2){
        
        senDic[JA_Property_FollowMethod] = @"粉丝列表";
    }
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        cell.focusButton.userInteractionEnabled = YES;
        cell.focusButton.selected = YES;
        
        data.friendType = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        if (self.type == 0) {
            // 好友
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
            
        } else if (self.type == 1) {
            // 关注
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
            
        } else if (self.type == 2) {
            // 粉丝
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
        }
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = data.userId;
        dic[@"status"] = data.friendType;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
         cell.focusButton.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
    
//    [[JACommonApi shareInstance] follow:params success:^(NSDictionary *result) {
//        cell.focusButton.userInteractionEnabled = YES;
//        cell.focusButton.selected = YES;
//        
//        data.friendType = [NSString stringWithFormat:@"%@",result[@"concern"][@"friendType"]];
//
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView endUpdates];
//        
//        if (self.type == 0) {
//            // 好友
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
//
//        } else if (self.type == 1) {
//            // 关注
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
//
//        } else if (self.type == 2) {
//            // 粉丝
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
//        }
//    } failure:^(NSError *error) {
//        cell.focusButton.userInteractionEnabled = YES;
//        
//    }];
}

- (void)cancelFollowUserAgreeActionWithCell:(JARelationshipTableViewCell *)cell {
    cell.focusButton.userInteractionEnabled = NO;
    
    JAConsumer *data = cell.data;
//    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"id"] = data.;
//    params[@"deleted"] = @"1";
//    params[@"userId"] =[JAUserInfo userInfo_getUserImfoWithKey:User_id];
//    params[@"concernId"] = data.userId;
//    params[@"concernType"] = JA_USER_TYPE;

    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"concernId"] = data.userId;
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_BindingType] = @"取消关注";
    senDic[JA_Property_PostId] = data.userId;
    senDic[JA_Property_PostName] = data.name;
    if (self.type == 1) {
        senDic[JA_Property_FollowMethod] = @"关注列表";
        
    }else if (self.type == 2){
        
        senDic[JA_Property_FollowMethod] = @"粉丝列表";
    }
    [JASensorsAnalyticsManager sensorsAnalytics_followPerson:senDic];
    
    [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
        cell.focusButton.userInteractionEnabled = YES;
        cell.focusButton.selected = NO;
        
        data.friendType = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.tableView beginUpdates];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView endUpdates];
        
        if (self.type == 0) {
            // 好友
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
            
        } else if (self.type == 1) {
            // 关注
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
            
        } else if (self.type == 2) {
            // 粉丝
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
        }
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = data.userId;
        dic[@"status"] = data.friendType;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];

    } failure:^(NSError *error) {
       cell.focusButton.userInteractionEnabled = YES;
    }];
    
//    [[JACommonApi shareInstance] cancelFollow:params success:^(NSDictionary *result) {
//        cell.focusButton.userInteractionEnabled = YES;
//        cell.focusButton.selected = NO;
//        
//        data.friendType = [NSString stringWithFormat:@"%@",result[@"concern"][@"friendType"]];
//
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//        [self.tableView beginUpdates];
//        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        [self.tableView endUpdates];
//        
//        if (self.type == 0) {
//            // 好友
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
//            
//        } else if (self.type == 1) {
//            // 关注
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFanNotification" object:data];
//            
//        } else if (self.type == 2) {
//            // 粉丝
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFriendNotification" object:data];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"JAFollowNotification" object:data];
//        }
//
//    } failure:^(NSError *error) {
//        cell.focusButton.userInteractionEnabled = YES;
//    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.person.count;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

#pragma mark - UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JARelationshipTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kJARelationshipCellIdentifier];
    if (!cell) {
        cell = [[JARelationshipTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kJARelationshipCellIdentifier isFriend:(self.type == 0?YES:NO)];
    }
    cell.data = self.person[indexPath.section];
    @WeakObj(self);
    cell.focusActionBlock = ^(JARelationshipTableViewCell *cell) {
        @StrongObj(self);
        if ([cell.data.friendType integerValue] == 2) {
            [self followUserActionWithCell:cell];
        } else {
            [self cancelFollowUserAgreeActionWithCell:cell];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [UIView new];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return [UIView new];
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UIView *headerView = [UIView new];
//    headerView.backgroundColor = HEX_COLOR(JA_BoardLineColor);
//    return headerView;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (!IS_LOGIN) {
//        [JAAPPManager app_modalLogin];
//        return;
//    }
    JAConsumer *info = self.person[indexPath.section];
//    JAPersonzoneVC *vc = [[JAPersonzoneVC alloc] init];
//    vc.userUid = info.userId;
//    vc.userInfo = info.userMsg;
    JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
    vc.personalModel = info;
    [self.navigationController pushViewController:vc animated:YES];
}

@end

