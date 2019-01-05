//
//  JAVoiceNotiAgreeViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/12.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVoiceNotiAgreeViewController.h"

#import "JAVoiceAgreeCell.h"
#import "JAPersonalCenterViewController.h"
#import "JAPostDetailViewController.h"
#import "JAVoiceRecordViewController.h"
#import "JAVoiceCommonApi.h"
#import "JAVoiceReplyDetailViewController.h"

#define Kcount 20
@interface JAVoiceNotiAgreeViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;   // 数据源

@property (nonatomic, assign) NSInteger lastCount;   // 数据库分页标识
@property (nonatomic, assign) int allCount;
@end

static NSString *VoiceAgreeCellID = @"JAVoiceAgreeCellID";

@implementation JAVoiceNotiAgreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self getNoti:NO type:@"action"];
    
    [self setCenterTitle:@"喜欢"];
    
    // 置为已读 2.6.0添加，现在一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeNoti_Agree];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(redPointArrive) name:@"redPointArrive" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiAgreeArrive) name:@"Noti_Agree_Arrive" object:nil];
}

- (void)notiAgreeArrive
{
    // 刷新数据源
    NSDictionary *dic = @{@"operation" : @"action"};
    NSArray *lastDataSource = [JANotiModel searchWithWhere:dic orderBy:@"time desc" offset:0 count:1];
    JANotiModel *lastModel = lastDataSource.firstObject;
    JANotiModel *model = self.dataSourceArray.firstObject;
    
    if (lastModel.rowid != model.rowid) {
        [self.dataSourceArray insertObject:lastModel atIndex:0];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self showBlankPage];
    });
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 置为已读 2.6.0添加，现在一进入界面就重置红点
    [JARedPointManager resetNewRedPointArrive:JARedPointTypeNoti_Agree];
}

- (void)redPointArrive
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 重置红点
        if ([self.view isDisplayedInScreen]) {
            [JARedPointManager resetNewRedPointArrive:JARedPointTypeNoti_Agree];
        }
    });
   
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI
{
    // tableView
    CGFloat safeHeight = 64;
    if (iPhoneX) {
        safeHeight = 64 + 24 + 34;
    }
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height - safeHeight)];
    
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:tableView];
    self.tableView = tableView;
    [tableView registerClass:[JAVoiceAgreeCell class] forCellReuseIdentifier:VoiceAgreeCellID];
    
    @WeakObj(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @StrongObj(self)
        [self getNoti:YES type:@"action"];
    }];
    
}

// 获取评论的通知
- (void)getNoti:(BOOL)isMore type:(NSString *)type
{
    if (!isMore) {   // 不是加载更多
        self.lastCount = 0;
        self.tableView.mj_footer.hidden = YES; // 先隐藏底部
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSDictionary *dic = @{@"operation" : type};
        if (!isMore) {
            [self.dataSourceArray removeAllObjects];
            
            self.dataSourceArray = [JANotiModel searchWithWhere:dic orderBy:@"time desc" offset:0 count:Kcount];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.dataSourceArray.count == Kcount) {
                    self.tableView.mj_footer.hidden = NO;
                    
                    self.lastCount += Kcount;
                }else{
                    self.tableView.mj_footer.hidden = YES;
                }
                
                [self showBlankPage];
            });
            
        }else{
            NSMutableArray *arr = [JANotiModel searchWithWhere:dic orderBy:@"time desc" offset:self.lastCount count:Kcount];
            [self.dataSourceArray addObjectsFromArray:arr];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (self.dataSourceArray.count == self.lastCount + Kcount) {
                    self.tableView.mj_footer.hidden = NO;
                    
                    self.lastCount += Kcount;
                }else{
                    self.tableView.mj_footer.hidden = YES;
                }
            });
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_footer endRefreshing];
            
            [self.tableView reloadData];
        });
    });
}

#pragma mark UITableView delegate and dataSource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JANotiModel *model = self.dataSourceArray[indexPath.row];
    
    return model.cellHeight;
    
    
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSourceArray.count;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    JANotiModel *data = self.dataSourceArray[indexPath.row];
    // 更新数据库
    if (data.readState == NO) {
        data.readState = YES; // 已读
        [data updateToDB];
    }
    
    JAVoiceAgreeCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.model = data;
    
    // 获取数据类型 - 跳转对应的界面
//    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:branchNewNotiAgree];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 获取数据类型 - 跳转对应的界面
    if ([data.content.type isEqualToString:@"story"]) { // 攒了帖子
        
        // 跳转帖子详情
        JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
        vc.voiceId = data.content.storyId;
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        // 跳转评论详情
        JAVoiceReplyDetailViewController *vc = [[JAVoiceReplyDetailViewController alloc] init];
        vc.voiceId = data.content.storyId;
        vc.voiceCommentId = data.content.typeId;
        vc.hasRightButton = YES;
        vc.storyUserId = data.content.storyUserId;
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 获取数据
    JANotiModel *model = self.dataSourceArray[indexPath.row];
    @WeakObj(self);
    JAVoiceAgreeCell *cell = [tableView dequeueReusableCellWithIdentifier:VoiceAgreeCellID];
    cell.model = model;
    cell.jumpPersonalCenterBlock = ^(JAVoiceAgreeCell *cell) {
        
        @StrongObj(self);
        if (cell.model.user.isAnonymous && [JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue != JAPOWER) {   // 匿名则退出
            [self.view ja_makeToast:@"该用户已匿名，昵称由系统随机生成"];
            return ;
        }
        
        JAPersonalCenterViewController *vc = [[JAPersonalCenterViewController alloc] init];
        JAConsumer *model = [[JAConsumer alloc] init];
        model.userId = cell.model.user.userId;
        model.name = cell.model.user.nick;
        model.image = cell.model.user.img;
        vc.personalModel = model;
        [self.navigationController pushViewController:vc animated:YES];
    };
    return cell;
    
    
}

// 展示空白页
- (void)showBlankPage
{
    if (self.dataSourceArray.count) {
        [self removeBlankPage];
    }else{
        NSString *t = @"你还没有收到新喜欢";
        NSString *st = @"";
        
        [self showBlankPageWithLocationY:53 title:t subTitle:st image:@"blank_notification" buttonTitle:nil selector:nil buttonShow:NO];
        
    }
    
}

#pragma mark - 2.6.0后这个作为主控制器后 添加这个类型(这个返回清空new标签数据)
- (void)actionLeft
{
    [super actionLeft];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"operation"] = @"action";
        
        //        NSString *searchStr = [NSString stringWithFormat:@"(playState!=0 or playReplyState!=0 or playCommentState!=0 or readState=NO) and %@",dic];
        
        NSArray *arr = [JANotiModel searchWithWhere:dic];
        //        NSArray *arr = [JANotiModel searchWithWhere:nil];
        
        for (JANotiModel *data in arr) {
            
            data.readState = YES;
            data.playState = 0;
            data.playReplyState = 0;
            data.playCommentState = 0;
            [data updateToDB];
        }
    });
    
}

@end
