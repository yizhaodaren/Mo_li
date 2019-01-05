//
//  JAPackMyInviteViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/20.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPackMyInviteViewController.h"
#import "JAMyInviteCell.h"
#import "JAUserApiRequest.h"
#import "JAMyInviteModel.h"
#import "JAInviteGroupModel.h"
#import "JAPersonalCenterViewController.h"
#import "JAPaddingLabel.h"
#import "JAInviteFriendView.h"
#import "JACallinviteFriendGroupModel.h"
#import "JACallInviteFriendModel.h"

@interface JAPackMyInviteViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *button1;   // 徒弟进贡
@property (nonatomic, strong) UIButton *button2;    // 待唤醒徒弟

@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UILabel *label1;    // 头像
@property (nonatomic, strong) UILabel *label2;    // 昵称/ID
@property (nonatomic, strong) UILabel *label3;    // 贡献茉莉花

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) JAPaddingLabel *bottomLabel;   // 规则label
@property (nonatomic, strong) UIButton *bottomButton;  // 规则button

@property (nonatomic, strong) NSMutableArray *array1;   // 数据源1
@property (nonatomic, strong) NSMutableArray *array2;   // 数据源2

@property (nonatomic, strong) NSString *currentPage; // 请求1（贡献排行榜） 当前页码
@property (nonatomic, strong) NSString *otherCurrentPage; // 请求2（唤醒好友） 当前页码

@property (nonatomic, strong) NSString *ruleContent;
@property (nonatomic, strong) NSString *keyWords;
@property (nonatomic, strong) NSArray *keyWordArr;
@end

@implementation JAPackMyInviteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _array1 = [NSMutableArray array];
    _array2 = [NSMutableArray array];
    
    [self setupMyInviteUI];
    
    if (self.currentViewPage == 0) {
        [self getInviteFriendInfo:NO];
#warning 线上崩溃多，不用这种方式
        [self getCallFriendInfo:NO];
    }else{
        [self getCallFriendInfo:NO];
#warning 线上崩溃多，不用这种方式
        [self getInviteFriendInfo:NO];
    }
   
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self);
        if (self.currentViewPage == 0) {
            [self getInviteFriendInfo:YES];
        }else{
            [self getCallFriendInfo:YES];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.titleView.selectedItemIndex == 1) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[JA_Property_ScreenName] = @"我的邀请";
        [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    }
}

- (void)setupMyInviteUI
{
    self.topView = [[UIView alloc] init];
    self.topView.backgroundColor = HEX_COLOR(0xF6F6F6);
    [self.view addSubview:self.topView];
    
    self.button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button1 setTitle:@"徒弟进贡榜" forState:UIControlStateNormal];
    self.button1.titleLabel.font = JA_MEDIUM_FONT(15);
    [self.button1 setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    [self.button1 setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
    [self.button1 setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xF6F6F6)] forState:UIControlStateNormal];
    [self.button1 setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0x6BD379)] forState:UIControlStateSelected];
    [self.button1 addTarget:self action:@selector(clickButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.button1];
    
    self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button2 setTitle:@"待唤醒徒弟" forState:UIControlStateNormal];
    self.button2.titleLabel.font = JA_MEDIUM_FONT(15);
    [self.button2 setTitleColor:HEX_COLOR(0x4A4A4A) forState:UIControlStateNormal];
    [self.button2 setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
    [self.button2 setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xF6F6F6)] forState:UIControlStateNormal];
    [self.button2 setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0x6BD379)] forState:UIControlStateSelected];
    [self.button2 addTarget:self action:@selector(clickButton2:) forControlEvents:UIControlEventTouchUpInside];
    [self.topView addSubview:self.button2];
    
    if (self.currentViewPage == 0) {
        self.button1.selected = YES;
    }else{
        self.button2.selected = YES;
    }
    
    self.middleView = [[UIView alloc] init];
    self.middleView.backgroundColor = HEX_COLOR(0xF6F6F6);
    [self.view addSubview:self.middleView];
    
    self.label1 = [[UILabel alloc] init];
    self.label1.text = @"头像";
    self.label1.textColor = HEX_COLOR(0x4A4A4A);
    self.label1.font = JA_REGULAR_FONT(14);
    [self.middleView addSubview:self.label1];
    
    self.label2 = [[UILabel alloc] init];
    self.label2.text = @"昵称";
    self.label2.textColor = HEX_COLOR(0x4A4A4A);
    self.label2.font = JA_REGULAR_FONT(14);
    [self.middleView addSubview:self.label2];
    
    self.label3 = [[UILabel alloc] init];
    self.label3.text = @"贡献茉莉花";
    self.label3.textColor = HEX_COLOR(0x4A4A4A);
    self.label3.font = JA_REGULAR_FONT(14);
    [self.middleView addSubview:self.label3];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[JAMyInviteCell class] forCellReuseIdentifier:@"JAMyInviteCellID_myInviteVC"];
    [self.view addSubview:self.tableView];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    
    if (self.currentViewPage == 0) {
        self.bottomView.hidden = YES;
    }else{
        self.bottomView.hidden = NO;
    }
    
    self.bottomLabel = [[JAPaddingLabel alloc] init];
    self.bottomLabel.text = @"成功唤醒徒弟后，师父得500朵茉莉花，徒弟得300朵茉莉花，唤醒徒弟越多，奖励越多！";
    self.bottomLabel.backgroundColor = HEX_COLOR(0xF6F6F6);
    self.bottomLabel.font = JA_MEDIUM_FONT(14);
    self.bottomLabel.textColor = HEX_COLOR(0x4A4A4A);
    if (iPhone4 || iPhone5) {
        self.bottomLabel.edgeInsets = UIEdgeInsetsMake(5, 5, 26, 5);
    }else{
        self.bottomLabel.edgeInsets = UIEdgeInsetsMake(14, 14, 26, 14);
    }
    self.bottomLabel.numberOfLines = 0;
    [self.bottomView addSubview:self.bottomLabel];
    
    self.bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.bottomButton setTitle:@"唤醒规则" forState:UIControlStateNormal];
    [self.bottomButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    self.bottomButton.backgroundColor = HEX_COLOR(0x6BD379);
    self.bottomButton.titleLabel.font = JA_MEDIUM_FONT(14);
    [self.bottomButton addTarget:self action:@selector(clickBottomButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.bottomButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self caculatorUIfFrame];
}

- (void)caculatorUIfFrame
{
    self.topView.width = JA_SCREEN_WIDTH - 24;
    self.topView.height = 50;
    self.topView.x = 12;
    self.topView.y = 20;
    self.topView.layer.cornerRadius = 3;
    self.topView.layer.masksToBounds = YES;
    
    self.button1.width = (self.topView.width - 10) * 0.5;
    self.button1.height = 40;
    self.button1.y = 5;
    self.button1.layer.cornerRadius = 3;
    self.button1.layer.masksToBounds = YES;
    self.button1.x = 5;
    
    self.button2.width = self.button1.width;
    self.button2.height = 40;
    self.button2.y = 5;
    self.button2.x = self.button1.right;
    self.button2.layer.cornerRadius = 3;
    self.button2.layer.masksToBounds = YES;
    
    self.middleView.width = self.topView.width;
    self.middleView.height = 30;
    self.middleView.x = self.topView.x;
    self.middleView.y = self.topView.bottom + 10;
    self.middleView.layer.cornerRadius = 3;
    self.middleView.layer.masksToBounds = YES;
    
    if (self.currentViewPage == 0) {
        
        [self.label1 sizeToFit];
        [self.label2 sizeToFit];
        [self.label3 sizeToFit];
        self.label1.x = 38;
        self.label1.centerY = self.middleView.height * 0.5;
        self.label2.x = self.label1.right + 23;
        self.label2.centerY = self.label1.centerY;
        self.label3.x = self.middleView.width - 10 - self.label3.width;
        self.label3.centerY = self.label1.centerY;
        
    }else{
        
        [self.label1 sizeToFit];
        [self.label2 sizeToFit];
        [self.label3 sizeToFit];
        self.label1.x = 13;
        self.label1.centerY = self.middleView.height * 0.5;
        self.label2.x = self.label1.right + 23;
        self.label2.centerY = self.label1.centerY;
        self.label3.x = self.middleView.width - 10 - self.label3.width;
        self.label3.centerY = self.label1.centerY;
    }
    
    self.tableView.width = JA_SCREEN_WIDTH;
    if (self.currentViewPage == 0) {
        self.tableView.height = self.view.height - self.middleView.bottom;
    }else{
        self.tableView.height = self.view.height - self.middleView.bottom - 110;
    }
    self.tableView.y = self.middleView.bottom;
    
    self.bottomView.width = JA_SCREEN_WIDTH;
    self.bottomView.height = 110;
    self.bottomView.y = self.view.height - self.bottomView.height;
    
    self.bottomLabel.width = JA_SCREEN_WIDTH - 24;
    self.bottomLabel.height = 80;
    self.bottomLabel.x = 12;
    self.bottomLabel.layer.cornerRadius = 5;
    self.bottomLabel.layer.masksToBounds = YES;
    
    self.bottomButton.width = 80;
    self.bottomButton.height = 30;
    self.bottomButton.centerX = self.bottomView.width * 0.5;
    self.bottomButton.centerY = self.bottomLabel.bottom;
    self.bottomButton.layer.cornerRadius = self.bottomButton.height * 0.5;
}

#pragma mark - 按钮的点击
- (void)clickButton1:(UIButton *)btn
{
    btn.selected = YES;
    self.button2.selected = NO;
    self.currentViewPage = 0;
    self.bottomView.hidden = YES;
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.label3.hidden = NO;
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
#warning 线上崩溃多，不用这种方式
    [self showBlankPage];
    [self.tableView reloadData];
#warning 线上崩溃多，就用这种方式
//    [self.array2 removeAllObjects];
//    [self.tableView reloadData];
//    [self getInviteFriendInfo:NO];
}

- (void)clickButton2:(UIButton *)btn
{
    btn.selected = YES;
    self.button1.selected = NO;
    self.currentViewPage = 1;
    self.bottomView.hidden = NO;
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 110, 0);
    self.label3.hidden = YES;
    [self.view layoutIfNeeded];
    [self.view setNeedsLayout];
#warning 线上崩溃多，不用这种方式
    [self showBlankPage];
    [self.tableView reloadData];
#warning 线上崩溃多，就用这种方式
//    [self.array1 removeAllObjects];
//    [self.tableView reloadData];
//    [self getCallFriendInfo:NO];
}

- (void)clickBottomButton:(UIButton *)btn
{
    // 弹窗
    JAInviteFriendView *fView = [[JAInviteFriendView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    NSString *str = [NSString stringWithFormat:@"成功唤醒徒弟后，师父得%@茉莉花，徒弟得%@茉莉花，唤醒徒弟越多，奖励越多！！",self.keyWordArr.firstObject, self.keyWordArr.lastObject];
    [fView showRuleFloat:str keyWord:self.keyWordArr ruleText:self.ruleContent];
}

#pragma mark - 网络请求
- (void)getCallFriendInfo:(BOOL)isMore
{
    if (!isMore) {
        self.otherCurrentPage = @"1";
        self.tableView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"pageNum"] = self.otherCurrentPage;
    dic[@"pageSize"] = @"6";
    
    [[JAUserApiRequest shareInstance] userCallInviteFriend:dic success:^(NSDictionary *result) {
        
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!isMore) {
            [self.array2 removeAllObjects];
        }
        
        // 解析数据
        JACallinviteFriendGroupModel *groupModel = [JACallinviteFriendGroupModel mj_objectWithKeyValues:result[@"InviteRegisterList"]];
        [self.array2 addObjectsFromArray:groupModel.result];
        
        if (!isMore) {
            self.ruleContent = [NSString stringWithFormat:@"%@",result[@"resMap"][@"rule"]];
            self.keyWords = [NSString stringWithFormat:@"%@",result[@"resMap"][@"flower"]];
            if (self.keyWords.length) {
                self.keyWordArr = [self.keyWords componentsSeparatedByString:@","];
                NSString *str = [NSString stringWithFormat:@"成功唤醒徒弟后，师父得%@茉莉花，徒弟得%@茉莉花，唤醒徒弟越多，奖励越多！！",self.keyWordArr.firstObject, self.keyWordArr.lastObject];
                self.bottomLabel.text = str;
            }
        }
        
        // 判断是否有分页
        if (groupModel.nextPage != 0) {
            self.otherCurrentPage = [NSString stringWithFormat:@"%ld",groupModel.currentPageNo + 1];
            self.tableView.mj_footer.hidden = NO;    // 有更多数据的时候，展示底部
        }else{
            self.tableView.mj_footer.hidden = YES; // 没有数据的时候 隐藏底部
        }
        
        if (!isMore) {
            [self showBlankPage];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        // 结束请求
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!isMore) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRefreshAction) buttonShow:NO];
        }
    }];
}

- (void)getInviteFriendInfo:(BOOL)isMore
{
    if (!isMore) {
        self.currentPage = @"1";
        self.tableView.mj_footer.hidden = YES;
    }
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"pageNum"] = self.currentPage;
    dic[@"pageSize"] = @"10";
    
    [[JAUserApiRequest shareInstance] userInviteRecord:dic success:^(NSDictionary *result) {
       
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!isMore) {
            [self.array1 removeAllObjects];
        }
        
        // 解析数据
        JAInviteGroupModel *groupModel = [JAInviteGroupModel mj_objectWithKeyValues:result[@"InviteRegisterList"]];
        [self.array1 addObjectsFromArray:groupModel.result];
        
        // 判断是否有分页
        if (groupModel.nextPage != 0) {
            self.currentPage = [NSString stringWithFormat:@"%ld",groupModel.currentPageNo + 1];
            self.tableView.mj_footer.hidden = NO;    // 有更多数据的时候，展示底部
        }else{
            self.tableView.mj_footer.hidden = YES; // 没有数据的时候 隐藏底部
        }
        
        if (!isMore) {
            [self showBlankPage];
        }
        [self.tableView reloadData];
        
    } failure:^(NSError *error) {
        
        // 结束请求
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        
        if (!isMore) {
            [self showBlankPageWithLocationY:0 title:@"网络请求失败,请点击重试" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:@selector(againRefreshAction) buttonShow:NO];
        }
    }];
}

- (void)againRefreshAction {
    [self removeBlankPage];
    if (self.currentViewPage == 0) {
        [self getInviteFriendInfo:NO];
    }else{
        [self getCallFriendInfo:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.currentViewPage == 0) {
        return self.array1.count;
    }else{
        return self.array2.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.currentViewPage == 0) {
        JAMyInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAMyInviteCellID_myInviteVC"];
        cell.cellType = self.currentViewPage;
        JAMyInviteModel *model = self.array1[indexPath.row];
        model.ranking = indexPath.row;
        cell.model = model;
        @WeakObj(self);
        cell.jumpPersonBlock = ^(JAMyInviteCell *cell) {
            @StrongObj(self);
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            model.userId = cell.model.userId;
            model.name = cell.model.userName;
            model.image = cell.model.userImage;
            vc.personalModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        return cell;
    }else{
        JAMyInviteCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAMyInviteCellID_myInviteVC"];
        cell.cellType = self.currentViewPage;
        cell.callFriendModel = self.array2[indexPath.row];
        @WeakObj(self);
        cell.jumpPersonBlock = ^(JAMyInviteCell *cell) {
            @StrongObj(self);
            JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
            JAConsumer *model = [[JAConsumer alloc] init];
            model.userId = cell.callFriendModel.userId;
            model.name = cell.callFriendModel.userName;
            model.image = cell.callFriendModel.userImage;
            vc.personalModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        };
        
        cell.callPersonBlock = ^(JAMyInviteCell *cell) {
            JAInviteFriendView *fView = [[JAInviteFriendView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
            fView.callModel = cell.callFriendModel;
            [fView showCallFloat:cell.callFriendModel.title];
            
        };
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


// 展示空白页
- (void)showBlankPage
{
    if (self.currentViewPage == 0) {
        [self removeBlankPage];
        if (self.array1.count) {
            [self removeBlankPage];
        }else{
            NSString *t = @"您还没有邀请记录";
            NSString *st = @"";
            [self showBlankPageWithLocationY:self.tableView.y title:t subTitle:st image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }else{
        [self removeBlankPage];
        if (self.array2.count) {
            [self removeBlankPage];
        }else{
            NSString *t = @"你还没有可唤醒的徒弟";
            NSString *st = @"";
            [self showBlankPageWithLocationY:self.tableView.y title:t subTitle:st image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO];
        }
    }
    
}

- (void)setCallFriendType:(NSInteger)callFriendType
{
    _callFriendType = callFriendType;
    
    [self clickButton2:self.button2];
}
//
///** 直接传入精度丢失有问题的Double类型*/
//- (NSString *)decimalNumberWithDouble:(double)conversionValue{
//    NSString *doubleString        = [NSString stringWithFormat:@"%lf", conversionValue];
//    NSDecimalNumber *decNumber    = [NSDecimalNumber decimalNumberWithString:doubleString];
//    return [decNumber stringValue];
//}

@end
