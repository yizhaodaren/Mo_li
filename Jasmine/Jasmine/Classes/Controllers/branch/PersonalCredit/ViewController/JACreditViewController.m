//
//  JACreditViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JACreditViewController.h"
#import "JARuleView.h"
#import "JARuleModel.h"
#import "JAUserApiRequest.h"
#import "JARuleWordModel.h"
#import "JATopRuleCell.h"
#import "JACreditRecordViewController.h"

@interface JACreditViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, weak) UIView *topView;

@property (nonatomic, weak) UIView *greenView;
@property (nonatomic, weak) UIImageView *circleImageView;
@property (nonatomic, weak) UILabel *scoreLabel;
@property (nonatomic, weak) UIButton *creditRecordButton;

@property (nonatomic, weak) UILabel *topRuleLabael;
@property (nonatomic, weak) UITableView *topTableView;

@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, weak) UILabel *ruleLabel;

@property (nonatomic, weak) JARuleView *ruleView;
@property (nonatomic, weak) JARuleView *plusView;
@property (nonatomic, weak) JARuleView *minusView;

@property (nonatomic, strong) NSArray *topArray;
@property (nonatomic, strong) NSArray *ruleArray;
@property (nonatomic, strong) NSArray *plusArray;
@property (nonatomic, strong) NSArray *minusArray;
@end

@implementation JACreditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    _topArray = [NSMutableArray array];
//    _ruleArray = [NSMutableArray array];
//    _plusArray = [NSMutableArray array];
//    _minusArray = [NSMutableArray array];
    
    [self setCenterTitle:@"我的信用分"];
    
    [self setupCreditUI];
    
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"信用";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)getData
{
    NSString *filePath = [NSString ja_getPlistFilePath:@"/CreditInfoDefault.plist"];
    NSDictionary *creditInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    if (!creditInfoDic) {
        filePath = [[NSBundle mainBundle] pathForResource:@"CreditInfoDefault.plist" ofType:nil];
        creditInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    }
    if (creditInfoDic) {
        [self setupCreditInfo:creditInfoDic];
    }
}

- (void)setupCreditInfo:(NSDictionary *)result {
    JARuleWordModel *model = [JARuleWordModel mj_objectWithKeyValues:result];
    
    self.topArray = model.listIntegralExplain;
    self.ruleArray = model.listIntegralInfoConfig;
    self.plusArray = model.listIntegralIncrease;
    self.minusArray = model.listIntegralInfoReduce;
    
    [self.topTableView reloadData];
    self.ruleView.dataArray = _ruleArray;
    self.plusView.dataArray = _plusArray;
    self.minusView.dataArray = _minusArray;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self.view setNeedsLayout];
    });
}

- (void)setupCreditUI
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:scrollView];
    
    UIView *topView = [[UIView alloc] init];
    _topView = topView;
    topView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:topView];
    
    UIView *greenView = [[UIView alloc] init];
    _greenView = greenView;
    greenView.backgroundColor = HEX_COLOR(0x54C7FC);
    [topView addSubview:greenView];
    
    UIImageView *circleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"credit_circle"]];
    _circleImageView = circleImageView;
    [greenView addSubview:circleImageView];
    
    UILabel *scoreLabel = [[UILabel alloc] init];
    _scoreLabel = scoreLabel;
    scoreLabel.text = [JAUserInfo userInfo_getUserImfoWithKey:User_score];
    scoreLabel.textColor = HEX_COLOR(0xffffff);
    scoreLabel.font = JA_MEDIUM_FONT(70);
    [circleImageView addSubview:scoreLabel];
    
    UIButton *creditRecordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _creditRecordButton = creditRecordButton;
    [creditRecordButton setTitle:@"查看信用分记录" forState:UIControlStateNormal];
    [creditRecordButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    creditRecordButton.titleLabel.font = JA_REGULAR_FONT(14);
    creditRecordButton.layer.borderColor = HEX_COLOR(0xffffff).CGColor;
    creditRecordButton.layer.borderWidth = 1;
    [creditRecordButton addTarget:self action:@selector(jumpRecordCreditVc) forControlEvents:UIControlEventTouchUpInside];
    [greenView addSubview:creditRecordButton];
    
    UILabel *topRuleLabael = [[UILabel alloc] init];
    _topRuleLabael = topRuleLabael;
    topRuleLabael.text = @"信用分规则";
    topRuleLabael.textColor = HEX_COLOR(0x4A4A4A);
    topRuleLabael.font = JA_MEDIUM_FONT(16);
    [topView addSubview:topRuleLabael];
    
    UITableView *topTableView = [[UITableView alloc] init];
    _topTableView = topTableView;
    topTableView.delegate = self;
    topTableView.dataSource = self;
    topTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [topView addSubview:topTableView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xF9F9F9);
    [scrollView addSubview:lineView];
    
    UILabel *ruleLabel = [[UILabel alloc] init];
    _ruleLabel = ruleLabel;
    ruleLabel.text = @"信用分规则";
    ruleLabel.textColor = HEX_COLOR(0x4A4A4A);
    ruleLabel.font = JA_MEDIUM_FONT(16);
    [scrollView addSubview:ruleLabel];
    
    JARuleView *ruleView = [[JARuleView alloc] ruleViewWithType:JARuleViewCellTypeLeft];
    _ruleView = ruleView;
    ruleView.refreshHeight = ^(CGFloat height) {
        [self.view setNeedsLayout];
    };
    [scrollView addSubview:ruleView];
    
    JARuleView *plusView = [[JARuleView alloc] ruleViewWithType:JARuleViewCellTypeRight];
    _plusView = plusView;
    plusView.refreshHeight = ^(CGFloat height) {
        [self.view setNeedsLayout];
    };
    [scrollView addSubview:plusView];
    
    JARuleView *minusView = [[JARuleView alloc] ruleViewWithType:JARuleViewCellTypeRight];
    _minusView = minusView;
    minusView.refreshHeight = ^(CGFloat height) {
        [self.view setNeedsLayout];
    };
    [scrollView addSubview:minusView];
    
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self caculatorFrame];
}

- (void)caculatorFrame
{
    self.scrollView.frame = self.view.bounds;
    
    self.greenView.y = 0;
    self.greenView.width = JA_SCREEN_WIDTH;
    self.greenView.height = 295;
    
    self.circleImageView.centerX = self.greenView.width * 0.5;
    self.circleImageView.y = 40;
    
    [self.scoreLabel sizeToFit];
    self.scoreLabel.center = CGPointMake(self.circleImageView.width * 0.5, self.circleImageView.height * 0.5 - 15);
    
    self.creditRecordButton.width = 138;
    self.creditRecordButton.height = 25;
    self.creditRecordButton.centerX = self.greenView.width * 0.5;
    self.creditRecordButton.y = self.circleImageView.height - 24 - self.creditRecordButton.height;
    self.creditRecordButton.layer.cornerRadius = self.creditRecordButton.height * 0.5;
    
    [self.topRuleLabael sizeToFit];
    self.topRuleLabael.x = 20;
    self.topRuleLabael.y = self.greenView.bottom + 14;
    
    self.topTableView.width = JA_SCREEN_WIDTH - 28;
    self.topTableView.x = 14;
    self.topTableView.y = self.topRuleLabael.bottom + 10;
    self.topTableView.height = self.topTableView.contentSize.height;
    
    self.topView.y = 0;
    self.topView.width = JA_SCREEN_WIDTH;
    self.topView.height = self.topTableView.bottom + 15;
    
    self.lineView.width = JA_SCREEN_WIDTH;
    self.lineView.height = 10;
    self.lineView.y = self.topView.bottom;
    
    [self.ruleLabel sizeToFit];
    self.ruleLabel.x = 20;
    self.ruleLabel.y = self.lineView.bottom + 10;
    
    self.ruleView.width = JA_SCREEN_WIDTH - 30;
    self.ruleView.x = 15;
    self.ruleView.y = self.ruleLabel.bottom + 8;
    self.ruleView.height = self.ruleView.myheight;
    
    self.plusView.width = JA_SCREEN_WIDTH - 30;
    self.plusView.x = 15;
    self.plusView.y = self.ruleView.bottom + 20;
    self.plusView.height = self.plusView.myheight;
    
    self.minusView.width = JA_SCREEN_WIDTH - 30;
    self.minusView.x = 15;
    self.minusView.y = self.plusView.bottom + 20;
    self.minusView.height = self.minusView.myheight;
    
    self.scrollView.contentSize = CGSizeMake(0, self.minusView.bottom);
}

#pragma mark - delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.topArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JATopRuleCell *cell = [[JATopRuleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.ruleWordText = self.topArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 计算高度
    NSString *str = self.topArray[indexPath.row];
    
    CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 28, MAXFLOAT);
    CGFloat height = [str boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(13)} context:nil].size.height;
    
    return height+10;
}

- (void)jumpRecordCreditVc
{
    JACreditRecordViewController *vc = [[JACreditRecordViewController alloc] init];
    
    [self.navigationController pushViewController:vc animated:YES];
}
@end
