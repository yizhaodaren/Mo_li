//
//  JAPersonIncomeViewController.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonIncomeViewController.h"
#import "JAPersonIncomeHeaderView.h"
#import "JAHorizontalPageView.h"
#import "SPPageMenu.h"

#import "JAIncomeDetailViewController.h"
#import "JAWithDrawViewController.h"
#import "JAPersonalSharePictureViewController.h"

#import "JAUserApiRequest.h"

@interface JAPersonIncomeViewController ()<JAHorizontalPageViewDelegate,SPPageMenuDelegate>

@property (nonatomic, strong) JAPersonIncomeHeaderView *headerView;  // 头部
@property (nonatomic, strong) JAHorizontalPageView *pageView;  // 内容
@property (nonatomic, weak) SPPageMenu *titleView;   // 标题

@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIButton *bottomButton;  // 底部按钮


// 花数 钱数  今日汇率
@property (nonatomic, strong) NSString *flowerCount;   // 可用花朵
@property (nonatomic, strong) NSString *moneyCount;   // 可提现金额

//@property (nonatomic, strong) NSString *rateMoney;   // 今日汇率
//@property (nonatomic, strong) NSString *maxMoney;    // 最低提现

// 昨日钱 = 昨日花
@property (nonatomic, strong) NSString *yesterdayMoney;
@property (nonatomic, strong) NSString *yesterdayFlower;

// 可兑换的金额
//@property (nonatomic, strong) NSString *enableMoney;  // 可兑换金钱

// 茉莉花总数
@property (nonatomic, strong) NSString *totalMoliFlowerCount;   // 茉莉花总数（审核中和可用）
// 茉莉花冻结数
//@property (nonatomic, strong) NSString *checkMoliFlowerCount;  // 审核中花朵数
// 可提金额数组
@property (nonatomic, strong) NSMutableArray *withMoneyArray;
@property (nonatomic, assign) BOOL firstWithD;

@property (nonatomic, assign) BOOL isSuccess;
@end

@implementation JAPersonIncomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _withMoneyArray = [NSMutableArray array];
    // 设置UI
    [self setupPersonIncomeViewControllerUI];
    // 布局
    [self.pageView reloadPage];
    // 获取网络请求
    [self getPersonFlowerAndMoney];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"我的收入";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
    
}

#pragma mark - UI
- (void)setupPersonIncomeViewControllerUI
{
    
    [self setCenterTitle:@"我的收入"];
    [self setNavRightTitle:@"去提现" color:HEX_COLOR(JA_Green)];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self.bottomView addSubview:self.lineView];
    
    self.bottomButton = [UIButton buttonWithType:UIButtonTypeCustom];
    NSString *expenditureM = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
    NSString *money = [NSString stringWithFormat:@"累计收入%.2f元，炫耀一下",self.moneyCount.doubleValue + expenditureM.doubleValue];
    [self.bottomButton setTitle:money forState:UIControlStateNormal];

//    [self.bottomButton setTitle:@"茉莉花全部兑换零钱" forState:UIControlStateNormal];
    [self.bottomButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    self.bottomButton.titleLabel.font = JA_MEDIUM_FONT(16);
    self.bottomButton.backgroundColor = HEX_COLOR(0x6BD379);
//    self.bottomButton.userInteractionEnabled = NO;
    [self.bottomButton addTarget:self action:@selector(clickBottomButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.bottomButton];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.bottomView.width = JA_SCREEN_WIDTH;
    self.bottomView.height = 65;
    self.bottomView.y = self.view.height - self.bottomView.height;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 1;
    
    self.bottomButton.width = 300;
    self.bottomButton.height = 40;
    self.bottomButton.centerX = self.bottomView.width * 0.5;
    self.bottomButton.y = 10;
    self.bottomButton.layer.cornerRadius = self.bottomButton.height * 0.5;
}

#pragma mark - 按钮的点击
- (void)clickBottomButton:(UIButton *)btn
{
//    if (self.titleView.selectedItemIndex == 0) {
//
//        if (self.isSuccess == NO) {
//            [self.view ja_makeToast:@"数据初始化中，请重新操作"];
//            return;
//        }
//
//        if (self.flowerCount.integerValue <= 0) {
//            [self.view ja_makeToast:@"您没有这么多花朵数可用于兑换！"];
//            return;
//        }
//
//        if (self.enableMoney.floatValue <= 0) {
//            [self.view ja_makeToast:@"您没有这么多花朵数可用于兑换！"];
//            return;
//        }
//
//        btn.userInteractionEnabled = NO;
//
//        NSString *instroduceString = [NSString stringWithFormat:@"确定将%@朵茉莉花兑换为零钱¥%@元?",self.flowerCount,self.enableMoney];
//
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle:instroduceString message:@"" preferredStyle:UIAlertControllerStyleAlert];
//
//        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//
//            btn.userInteractionEnabled = YES;
//
//        }];
//        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//
//            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
//            dic[@"flower"] = self.flowerCount;
//            [MBProgressHUD showMessage:nil];
//
//            // 新版兑换
//            [[JAUserApiRequest shareInstance] userNewExchangeMoney:dic success:^(NSDictionary *result) {
//                [MBProgressHUD hideHUD];
//                // 神策数据
//                NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
//                senDic[JA_Property_FlowerAmount] = @([self.flowerCount integerValue]);
//                senDic[JA_Property_MoneyAmount] = @([_enableMoney doubleValue]);
//                senDic[JA_Property_TodayRate] = @([self.rateMoney doubleValue]);
//                [JASensorsAnalyticsManager sensorsAnalytics_exchangeMoney:senDic];
//
//                [self.view ja_makeToast:@"兑换成功"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshIncomeDetail" object:nil];
//                self.flowerCount = @"0";
//                self.moneyCount = [NSString stringWithFormat:@"%.2f",self.moneyCount.doubleValue + self.enableMoney.doubleValue];
//
//                // 保存用户的金钱
//                [JAUserInfo userInfo_updataUserInfoWithKey:User_IncomeMoney value:self.moneyCount];
//
//                self.enableMoney = @"0.00";
//
//                btn.backgroundColor = HEX_COLOR(0x9b9b9b);
//                btn.userInteractionEnabled = NO;
//                self.headerView.totalFlower = self.flowerCount;   // 可用茉莉花
//                self.headerView.totalMoney = self.moneyCount;     // 我的金额
//                self.headerView.enableMoney = self.enableMoney;
//
//            } failure:^(NSError *error) {
//                [MBProgressHUD hideHUD];
//                btn.userInteractionEnabled = YES;
//                NSString *str = [NSString stringWithFormat:@"%@",error];
//                if ([str containsString:@"Code=14101"]) {
//                    [self.view ja_makeToast:@"交易失败"];
//                }else if ([str containsString:@"Code=140003"]) {
//                    [self.view ja_makeToast:@"对不起，您没有这么多花朵数可用于兑换！"];
//                }else{
//                    [self.view ja_makeToast:error.localizedDescription];
//                }
//            }];
//
//        }];
//
//        [alert addAction:action1];
//        [alert addAction:action2];
//
//        [self presentViewController:alert animated:YES completion:nil];
//    }else{
//
//    }
    JAPersonalSharePictureViewController *vc = [[JAPersonalSharePictureViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)actionRight
{
    if (self.isSuccess == NO) {
        [self.view ja_makeToast:@"数据初始化中，请重新操作"];
        return;
    }
    
    if (self.moneyCount.doubleValue <= 0) {
        [self.view ja_makeToast:@"您没有这么多零钱可用于提现！"];
        return;
    }
    
    JAWithDrawViewController *vc = [[JAWithDrawViewController alloc] init];
    vc.moneyCountString = self.moneyCount;
//    vc.maxWithDrawMoney = self.maxMoney;
    vc.moneyArray = self.withMoneyArray;
    vc.isFirstWithDraw = self.firstWithD;
    @WeakObj(self);
    vc.withDrawSuccess = ^(NSString *totalM) {
        @StrongObj(self);
        if (self.firstWithD) {
            self.firstWithD = NO;
            [self.withMoneyArray removeObjectAtIndex:0];
        }
        self.moneyCount = totalM;
        self.headerView.totalMoney = self.moneyCount;
        [JAUserInfo userInfo_updataUserInfoWithKey:User_IncomeMoney value:self.moneyCount];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 网络数据
- (void)getPersonFlowerAndMoney
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"2";  // 为了兼容老版本写死了汇率 传2获取新的汇率
    [[JAUserApiRequest shareInstance] userExchangeInfo:dic success:^(NSDictionary *result) {
        
        self.isSuccess = YES;
        
        // 可用花朵
        self.flowerCount = [NSString stringWithFormat:@"%zd", [result[@"flowermoney"][@"moliFlowerCount"] integerValue]];
        // 可用金额
        self.moneyCount = [NSString stringWithFormat:@"%.2f", [result[@"flowermoney"][@"moneyCount"] floatValue]];
        // 昨日钱
        self.yesterdayMoney = [NSString stringWithFormat:@"%@", result[@"flowermoney"][@"yesterdayMoney"]];
        // 昨日花
        self.yesterdayFlower = [NSString stringWithFormat:@"%@",result[@"flowermoney"][@"yesterdayFlower"]];
        // 总花朵数
        self.totalMoliFlowerCount = [NSString stringWithFormat:@"%zd", [result[@"flowermoney"][@"totalFlowerCount"] integerValue]];
        // 审核的花朵
//        self.checkMoliFlowerCount = [NSString stringWithFormat:@"%zd", [result[@"flowermoney"][@"examineFlowerCount"] integerValue]];
        // 可提现金额数组
        
        // 数组排序 2.5.4
        NSArray *array = result[@"flowermoney"][@"arrayMoney"];
        NSArray *sortArray = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2]; //升序
        }];
        
        [self.withMoneyArray addObjectsFromArray:sortArray];
        
//        // 可提现金额的计算
//        NSString *moneyString = [NSString stringWithFormat:@"%f",self.flowerCount.floatValue * self.rateMoney.floatValue / 1000.0];
//        self.enableMoney = [moneyString substringToIndex:4];
        // 是否是首次
        NSString *isFirstWithD = [NSString stringWithFormat:@"%@",result[@"flowermoney"][@"isNewUser"]];
        self.firstWithD = isFirstWithD.boolValue;
        
        // headerView数据
        self.headerView.totalFlower = self.flowerCount;   // 可用茉莉花
        self.headerView.totalMoney = self.moneyCount;     // 我的金额
//        self.headerView.checkFlower = self.checkMoliFlowerCount; // 审核中🌺
        self.headerView.rateFlower = self.yesterdayFlower;
        self.headerView.rateMoney = self.yesterdayMoney;
        
        NSString *expenditureM = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
        NSString *money = [NSString stringWithFormat:@"累计收入%.2f元，炫耀一下",self.moneyCount.doubleValue + expenditureM.doubleValue];
        [self.bottomButton setTitle:money forState:UIControlStateNormal];

//        [self setButtonWord:self.titleView.selectedItemIndex];
        
    } failure:^(NSError *error) {
        [self.view ja_makeToast:error.localizedDescription];
        self.isSuccess = NO;
    }];
}

#pragma mark - JAHorizontalPageView代理
- (NSInteger)numberOfSectionPageView:(JAHorizontalPageView *)view   // 返回几个控制器
{
    return 2;
}

- (UIScrollView *)horizontalPageView:(JAHorizontalPageView *)pageView viewAtIndex:(NSInteger)index   // 返回每个控制器的view
{
    if (index == 0) {
        JAIncomeDetailViewController *vc = [JAIncomeDetailViewController new];
        vc.incomeType = @"flower";
        vc.pageMenu = self.titleView;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }else{
        
        JAIncomeDetailViewController *vc = [[JAIncomeDetailViewController alloc]init];
        vc.incomeType = @"money";
        vc.pageMenu = self.titleView;
        [self addChildViewController:vc];
        return (UIScrollView *)vc.view;
    }
}

- (UIView *)headerViewInPageView:(JAHorizontalPageView *)pageView     // 返回头部
{
    self.headerView = [[JAPersonIncomeHeaderView alloc] init];
    
    SPPageMenu *pageMenu = [SPPageMenu pageMenuWithFrame:CGRectMake(0, 195, JA_SCREEN_WIDTH, 40) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
    pageMenu.permutationWay = SPPageMenuPermutationWayNotScrollAdaptContent;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        pageMenu.delegate = self;
    });
    pageMenu.itemTitleFont = JA_MEDIUM_FONT(16);
    pageMenu.selectedItemTitleColor = HEX_COLOR(0x373C43);
    pageMenu.unSelectedItemTitleColor = HEX_COLOR(0x373C43);
    pageMenu.tracker.backgroundColor = HEX_COLOR(JA_Green);
    self.titleView = pageMenu;
    [self.headerView addSubview:pageMenu];
    self.titleView.bridgeScrollView = (UIScrollView *)self.pageView.horizontalCollectionView;
    NSArray *titleArr = @[@"茉莉花",@"零钱"];
    [self.titleView setItems:titleArr selectedItemIndex:0];
    
    return self.headerView;
}

- (CGFloat)headerHeightInPageView:(JAHorizontalPageView *)pageView    // 返回头部高度
{
    return 235;
}

- (CGFloat)topHeightInPageView:(JAHorizontalPageView *)pageView
{
    return 40;
}

- (void)horizontalPageView:(JAHorizontalPageView *)pageView scrollTopOffset:(CGFloat)offset   // 滚动的偏移量
{
    
}

#pragma mark - 代理
- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    [self.pageView scrollToIndex:toIndex];
    
//    [self setButtonWord:toIndex];
}

//- (void)setButtonWord:(NSInteger)toIndex
//{
//    if (toIndex == 0) {
//        [self.bottomButton setTitle:@"茉莉花全部兑换零钱" forState:UIControlStateNormal];
//        if (self.flowerCount.doubleValue <= 0 || self.enableMoney.doubleValue <= 0) {
//            self.bottomButton.userInteractionEnabled = NO;
//            self.bottomButton.backgroundColor = HEX_COLOR(0x9b9b9b);
//        }else{
//            self.bottomButton.userInteractionEnabled = YES;
//            self.bottomButton.backgroundColor = HEX_COLOR(0x6BD379);
//        }
//    }else{
//        NSString *expenditureM = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
//        NSString *money = [NSString stringWithFormat:@"累计收入%.2f元，炫耀一下",self.moneyCount.doubleValue + expenditureM.doubleValue];
//        [self.bottomButton setTitle:money forState:UIControlStateNormal];
//        self.bottomButton.userInteractionEnabled = YES;
//        self.bottomButton.backgroundColor = HEX_COLOR(0x6BD379);
//    }
//}

#pragma mark - JAHorizontalPageView懒加载
- (JAHorizontalPageView *)pageView
{
    if (_pageView == nil) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGFloat h = JA_StatusBarAndNavigationBarHeight;
      
        _pageView = [[JAHorizontalPageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height - 65 - h) delegate:self];
//        _pageView.needHeadGestures = YES;
        _pageView.hasNavigator = YES;
        [self.view addSubview:_pageView];
    }
    
    return _pageView;
}

- (void)jumpRightPage:(NSInteger)pageNum
{
    self.titleView.selectedItemIndex = pageNum;
}
@end
