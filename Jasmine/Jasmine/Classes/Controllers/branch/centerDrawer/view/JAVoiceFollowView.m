//
//  JAVoiceFollowView.m
//  Jasmine
//
//  Created by xujin on 15/09/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAVoiceFollowView.h"
#import "JAVoiceFollowTableViewCell.h"
#import "JAVoiceApi.h"
#import "JAVoiceFollowGroupModel.h"
#import "JARecommendNetRequest.h"
#import "JAVoicePersonApi.h"
#import "JAPersonalCenterViewController.h"

static NSString *const kVoiceFollowCellIdentifier = @"JAVoiceFollowCellIdentifier";

@interface JAVoiceFollowView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray *selectedFollows;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *maskView;

@end


@implementation JAVoiceFollowView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEX_COLOR(0xf9f9f9);

        self.follows = [NSMutableArray new];
        self.selectedFollows = [NSMutableArray new];
        
//        JAVoiceFollowGroupModel *model = [JAVoiceFollowGroupModel searchSingleWithWhere:nil orderBy:nil];
//        if (model.result.count) {
//            [self.follows addObjectsFromArray:model.result];
//        }
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 50)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = JA_MEDIUM_FONT(14);
        titleLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"你和你关注人的帖子会展示在这里";
        [self addSubview:titleLabel];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 0, JA_SCREEN_WIDTH-30, 1) style:UITableViewStylePlain];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor = [UIColor whiteColor];
        self.tableView.showsVerticalScrollIndicator = NO;
        self.tableView.bounces = NO;
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        //    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0);
        self.tableView.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
        self.tableView.layer.borderWidth = 1;
        self.tableView.layer.masksToBounds = YES;
        self.tableView.layer.cornerRadius = 3.0;
        self.tableView.estimatedRowHeight = 0;
        self.tableView.estimatedSectionHeaderHeight = 0;
        self.tableView.estimatedSectionFooterHeight = 0;
        
        [self addSubview:self.tableView];
//        @WeakObj(self)
//        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//            @StrongObj(self);
//            [self getVoiceListWithLoadMore:YES];
//        }];
//        self.tableView.mj_footer.hidden = YES;
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 77)];
        bottomView.backgroundColor = [UIColor clearColor];
        [self addSubview:bottomView];
        self.bottomView = bottomView;
        
        UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        changeButton.titleLabel.font = JA_REGULAR_FONT(16);
        [changeButton setTitle:@"换一批" forState:UIControlStateNormal];
        [changeButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
        [changeButton addTarget:self action:@selector(changeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        changeButton.layer.masksToBounds = YES;
        changeButton.layer.cornerRadius = 3.0;
        changeButton.layer.borderColor = [HEX_COLOR(JA_Green) CGColor];
        changeButton.layer.borderWidth = 1;
        [bottomView addSubview:changeButton];
        changeButton.width = WIDTH_ADAPTER(140);
        changeButton.height = WIDTH_ADAPTER(36);
        changeButton.centerX = (bottomView.width-changeButton.width)/2.0-WIDTH_ADAPTER(12);
        changeButton.centerY = bottomView.height/2.0;
        
        UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.backgroundColor = HEX_COLOR(0xe2e2e2);
        selectButton.titleLabel.font = JA_REGULAR_FONT(16);
        [selectButton setTitle:@"选好了" forState:UIControlStateNormal];
        [selectButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
        [selectButton addTarget:self action:@selector(selectButtonAction) forControlEvents:UIControlEventTouchUpInside];
        selectButton.layer.masksToBounds = YES;
        selectButton.layer.cornerRadius = 3.0;
        [bottomView addSubview:selectButton];
        selectButton.width = WIDTH_ADAPTER(140);
        selectButton.height = WIDTH_ADAPTER(36);
        selectButton.centerX = (bottomView.width+changeButton.width)/2.0+WIDTH_ADAPTER(12);
        selectButton.centerY = bottomView.height/2.0;
        selectButton.enabled = NO;
        self.selectButton = selectButton;
        
        self.maskView = [UIView new];
        self.maskView.backgroundColor = HEX_COLOR(0xf9f9f9);
        [self addSubview:_maskView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.maskView.width = self.width;
    self.maskView.height = self.height;
    
    if (self.height-50-77 > 420) {
        self.tableView.height = 420;
    } else {
        self.tableView.height = self.height-50-77;
    }
    self.tableView.width = JA_SCREEN_WIDTH-30;
    self.tableView.x = 15;
    self.tableView.y = 50;
    self.bottomView.y = self.tableView.bottom;
}

- (void)getFollowData {
    if (self.follows.count) {
        return;
    }
    [self getVoiceListWithLoadMore:NO];
}

- (void)changeButtonAction {
    [self getVoiceListWithLoadMore:YES];
}

- (void)selectButtonAction {
    if (self.followSuccess) {
        self.followSuccess();
    }
}

- (void)retryAction {
    [self getVoiceListWithLoadMore:NO];
}

#pragma mark - Network
- (void)getVoiceListWithLoadMore:(BOOL)isLoadMore {
    if (self.isRequesting) {
        return;
    }
    if (!isLoadMore) {
        self.currentPage = 1;
        self.tableView.mj_footer.hidden = YES;
    }
    [MBProgressHUD showMessage:nil];
    // 开始请求
    self.isRequesting = YES;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"pageNum"] = @(self.currentPage);
    dic[@"pageSize"] = @"6";
    if(IS_LOGIN) dic[@"uid"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    JARecommendNetRequest *request = [[JARecommendNetRequest alloc] initRequest_peopleListWithParameter:dic];
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [MBProgressHUD hideHUD];
        self.isRequesting = NO;
        self.maskView.hidden = YES;
        if (responseModel.code != 10000) {
            return;
        }
        JAVoiceFollowGroupModel *groupModel = (JAVoiceFollowGroupModel *)responseModel;
        if (groupModel.resBody.count) {
            self.currentPage++;
            [self.follows removeAllObjects];
            [self.follows addObjectsFromArray:groupModel.resBody];
            [self.tableView reloadData];

            if (self.tableView.contentSize.height <= self.height-50-77) {
                self.tableView.height = self.tableView.contentSize.height;
            } else {
                self.tableView.height = self.height-50-77;
            }
            if (groupModel.resBody.count <6) {
                self.currentPage = 1;
            }
        }
        [[AppDelegateModel getCenterMenuViewController] removeBlankPage];
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [MBProgressHUD hideHUD];
        self.isRequesting = NO;
        [[AppDelegateModel getCenterMenuViewController] showBlankPageWithLocationY:0 title:@"网络请求异常" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(retryAction) buttonShow:NO superView:self];
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.follows.count;
}

#pragma mark - UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JAVoiceFollowModel *follow = self.follows[indexPath.row];
    JAVoiceFollowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVoiceFollowCellIdentifier];
    if (!cell) {
        cell = [[JAVoiceFollowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVoiceFollowCellIdentifier];
    }
    cell.data = follow;
    @WeakObj(self);
    cell.followBlock = ^(JAVoiceFollowTableViewCell *cell) {
        @StrongObj(self);
        [self focusCustomer:cell.focusButton followModel:cell.data];
    };
    cell.headActionBlock = ^(JAVoiceFollowTableViewCell *cell) {
        @StrongObj(self);
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.data.userId;
        model.name = cell.data.name;
        model.image = cell.data.image;
        vc.personalModel = model;
        [self.vc.navigationController pushViewController:vc animated:YES];
    };
    cell.followCountBlock = ^(void){
        @StrongObj(self);
        NSInteger focusCount = [[JAUserInfo userInfo_getUserImfoWithKey:User_userConsernCount] integerValue];
        if (focusCount) {
            self.selectButton.backgroundColor = HEX_COLOR(JA_Green);
            self.selectButton.enabled = YES;
        } else {
            self.selectButton.backgroundColor = HEX_COLOR(0xe2e2e2);
            self.selectButton.enabled = NO;
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    JAVoiceFollowModel *follow = self.follows[indexPath.row];
//    follow.isSelected = !follow.isSelected;
//    if (follow.isSelected) {
//        [self.selectedFollows addObject:follow];
//    } else {
//        [self.selectedFollows removeObject:follow];
//    }
//    [self.tableView reloadData];
//    [self.followButton setTitle:[NSString stringWithFormat:@"关注所选%d人，开启频道",(int)self.selectedFollows.count] forState:UIControlStateNormal];
//}


// 关注取消人
- (void)focusCustomer:(UIButton *)focusButton followModel:(JAVoiceFollowModel *)followModel
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    focusButton.userInteractionEnabled = NO;
    if (focusButton.selected) {
        
        // 取消关注
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"concernId"] = followModel.userId;
     
        [[JAVoicePersonApi shareInstance] voice_personalCancleFocusUseroWithParas:dic success:^(NSDictionary *result) {
            
            NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
            followModel.friendType = type;
            focusButton.userInteractionEnabled = YES;
            focusButton.selected = NO;
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"id"] = followModel.userId;
            dic[@"status"] = type;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusFalse" object:dic];
            
        } failure:^(NSError *error) {
            focusButton.userInteractionEnabled = YES;
            [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
        }];
        
        return;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"concernId"] = followModel.userId;
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAVoicePersonApi shareInstance] voice_personalFocusUserWithParas:dic success:^(NSDictionary *result) {
        
        NSString *type = [NSString stringWithFormat:@"%@",result[@"friend"][@"friendType"]];
        followModel.friendType = type;
        focusButton.userInteractionEnabled = YES;
        focusButton.selected = YES;
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"id"] = followModel.userId;
        dic[@"status"] = type;
        [[NSNotificationCenter defaultCenter] postNotificationName:@"searchRefreshFocusStatusTrue" object:dic];
        
    } failure:^(NSError *error) {
        focusButton.userInteractionEnabled = YES;
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

@end
