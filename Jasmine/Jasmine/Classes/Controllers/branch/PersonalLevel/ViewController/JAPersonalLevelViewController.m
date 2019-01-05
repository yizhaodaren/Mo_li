//
//  JAPersonalLevelViewController.m
//  Jasmine
//
//  Created by xujin on 13/10/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAPersonalLevelViewController.h"
#import "JAUserApiRequest.h"
#import "JALevelModel.h"

@interface JAPrivilegeItemView : UIView

@property (nonatomic, assign) BOOL enablePrivilege;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *openButton;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) JALevelModel *data;

@end

@implementation JAPrivilegeItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor redColor];
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
//        iconImageView.backgroundColor = [UIColor greenColor];
//        iconImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:iconImageView];
        iconImageView.centerX = self.width/2.0;
        self.iconImageView = iconImageView;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.width, 17)];
//        titleLabel.backgroundColor = [UIColor greenColor];
        titleLabel.font = JA_REGULAR_FONT(12);
        titleLabel.textColor = HEX_COLOR(0x4a4a4a);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        titleLabel.centerX = self.width/2.0;
        titleLabel.top = iconImageView.bottom+6;
        self.titleLabel = titleLabel;
        
        UIButton *openButton = [UIButton buttonWithType:UIButtonTypeCustom];
        openButton.frame = CGRectMake(0, 0, 60, 20);
        openButton.titleLabel.font = JA_REGULAR_FONT(11);
        openButton.layer.cornerRadius = 2.0;
        openButton.layer.masksToBounds = YES;
        openButton.layer.borderWidth = 1.0;
        [self addSubview:openButton];
        openButton.centerX = self.width/2.0;
        openButton.top = titleLabel.bottom+10;
        self.openButton = openButton;
    }
    return self;
}

- (void)setEnablePrivilege:(BOOL)enablePrivilege {
    _enablePrivilege = enablePrivilege;
    if (enablePrivilege) {
        self.openButton.backgroundColor = HEX_COLOR(0xFFFFFA);
        self.openButton.layer.borderColor = [HEX_COLOR(0xF2EB8A) CGColor];
        [self.openButton setTitleColor:HEX_COLOR(0xD1890B) forState:UIControlStateNormal];
    } else {
        self.openButton.backgroundColor = HEX_COLOR(0xF7F7F7);
        self.openButton.layer.borderColor = [HEX_COLOR(0xD8D8D8) CGColor];
        [self.openButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
    }
}

- (void)setData:(JALevelModel *)data {
    _data = data;
    if (data) {
        [self.iconImageView ja_setImageWithURLStr:data.gradeImage];
        self.titleLabel.text = data.gradeContent;
        [self.openButton setTitle:data.gradeTitle forState:UIControlStateNormal];
        
        JALevelModel *lModel = [JAAPPManager currentLevel];
        self.enablePrivilege = (lModel.gradeNum >= data.gradeNum)?YES:NO;
    }
}

@end

@interface JAPersonalLevelViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JALevelModel *levelModel;
@property (nonatomic, strong) NSMutableArray *levels;
//@property (nonatomic, weak) UILabel *privilegeLabel; // 等级特权
@property (nonatomic, weak) UIView *privilegeView;  // 等级view
@property (nonatomic, weak) UIView *bottomContentView;  // 底部view


@end

@implementation JAPersonalLevelViewController

- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[JA_Property_ScreenName] = @"等级";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:dic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavBar];
    
    NSString *filePath = [NSString ja_getPlistFilePath:@"/LevelInfoDefault.plist"];
    NSDictionary *levelInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSArray *listGrade = levelInfoDic[@"listGrade"];
    if (!listGrade.count) {
        filePath = [[NSBundle mainBundle] pathForResource:@"LevelInfoDefault.plist" ofType:nil];
        levelInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
        listGrade = levelInfoDic[@"listGrade"];
    }
    
    NSArray *listGradeModels = [JALevelModel mj_objectArrayWithKeyValuesArray:listGrade];
    NSArray *sortArray = [listGradeModels sortedArrayUsingComparator:^NSComparisonResult(JALevelModel *obj1, JALevelModel *obj2) {
        if (obj1.gradeNum < obj2.gradeNum) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    
    
    self.levels = [sortArray mutableCopy];
    if (self.levels.count) {
        [self setupScrollView];
    } else {
        self.levels = [NSMutableArray new];
        [MBProgressHUD showMessage:nil toView:self.view];
    }
    
    [self getPersonalLevel];
}

- (void)setupNavBar {
    UIView *fakeNav = [UIView new];
    CGFloat safeHeight = 20;
    if (iPhoneX) {
        safeHeight = 20 + 24;
    }
    fakeNav.frame = CGRectMake(0, safeHeight, JA_SCREEN_WIDTH, 44);
    fakeNav.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:fakeNav];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    backButton.backgroundColor = [UIColor greenColor];
    [backButton setImage:[UIImage imageNamed:@"circle_back_black"] forState:UIControlStateNormal];
    
    backButton.frame = CGRectMake(0, 0, 44, 44);
    [backButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [fakeNav addSubview:backButton];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
//    titleLabel.backgroundColor = [UIColor greenColor];
    titleLabel.font = JA_MEDIUM_FONT(16);
    titleLabel.text = @"我的等级";
    titleLabel.textColor = HEX_COLOR(JA_BlackTitle);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [fakeNav addSubview:titleLabel];
    titleLabel.centerX = JA_SCREEN_WIDTH/2.0;
}

- (void)backAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupScrollView {
    CGFloat safeHeight = 64;
    if (iPhoneX) {
        safeHeight = 64 + 24;
    }
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, safeHeight, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-safeHeight)];
    scrollView.showsVerticalScrollIndicator = NO;
//    scrollView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    UIImageView *headBgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -20, 227, 184)];
    headBgView.image = [UIImage imageNamed:@"level_head_bg"];
    [scrollView addSubview:headBgView];
    headBgView.centerX = JA_SCREEN_WIDTH/2.0;

    UIImageView *headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 85, 85)];
    headImageView.backgroundColor = [UIColor yellowColor];
    [headImageView ja_setImageWithURLStr:[JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl]];
    headImageView.layer.cornerRadius = 42.5;
    headImageView.layer.masksToBounds = YES;
    headImageView.layer.borderColor = [HEX_COLOR(0xFFD314) CGColor];
    headImageView.layer.borderWidth = 5.0;
    [headBgView addSubview:headImageView];
    headImageView.centerX = headBgView.width/2.0;
    headImageView.bottom = headBgView.height-32;
    
    UIImageView *levelImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 139, 32)];
    levelImageView.image = [UIImage imageNamed:@"level_titel_bg"];
    [headBgView addSubview:levelImageView];
    levelImageView.centerX = headBgView.width/2.0;
    levelImageView.bottom = headBgView.height-27;
    
    NSString *levelStr = [NSString stringWithFormat:@"%@",[JAUserInfo userInfo_getUserImfoWithKey:User_LevelId]];
    if (levelStr.length) {
        if ([levelStr isEqualToString:@"(null)"]) {
            levelStr = @"1";
        }
    } else {
        levelStr = @"1";
    }
    UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 28)];
//    levelLabel.backgroundColor = [UIColor greenColor];
    levelLabel.font = JA_MEDIUM_FONT(16);
    levelLabel.text = [NSString stringWithFormat:@"Lv%@",levelStr];
    levelLabel.textColor = HEX_COLOR(0xffffff);
    levelLabel.textAlignment = NSTextAlignmentCenter;
    [levelImageView addSubview:levelLabel];
    levelLabel.centerX = levelImageView.width/2.0;
    levelLabel.bottom = levelImageView.height;
    
    UILabel *epLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 18)];
    epLabel.font = JA_REGULAR_FONT(13);
    epLabel.text = @"0/0经验值";
    epLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    epLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:epLabel];
    epLabel.centerX = JA_SCREEN_WIDTH/2.0;
    epLabel.top = headBgView.bottom+14;
    
    NSString *currentEP = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelScore];
    NSString *nextLevelEP = [JAUserInfo userInfo_getUserImfoWithKey:User_TopScore];
    epLabel.text = [NSString stringWithFormat:@"%@/%@经验值",currentEP,nextLevelEP];
    
    UIView *progressBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH_ADAPTER(282), 9)];
    progressBgView.layer.cornerRadius = 4.5;
    progressBgView.layer.masksToBounds = YES;
    progressBgView.layer.borderColor = [HEX_COLOR(0xFC7A56) CGColor];
    progressBgView.layer.borderWidth = 1.0;
    [scrollView addSubview:progressBgView];
    progressBgView.centerX = JA_SCREEN_WIDTH/2.0;
    progressBgView.top = epLabel.bottom+4;
    
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(5, 0, 3, 3)];
    progressView.backgroundColor = HEX_COLOR(0xFC7A56);
    progressView.layer.cornerRadius = 1.5;
    progressView.layer.masksToBounds = YES;
    [progressBgView addSubview:progressView];
    progressView.centerY = progressBgView.height/2.0;
    
    // 赋值进度
    CGFloat progress = [currentEP floatValue] / [nextLevelEP floatValue];
    if (isnan(progress)) {
        progress = 0.0;
    }
    progress = floor(progress*100)/100.0;
    progressView.width = (WIDTH_ADAPTER(282)-10) * progress;
    if (progressView.width < 3) {
        progressView.width = 3;
    }

    UILabel *privilegeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    //    titleLabel.backgroundColor = [UIColor greenColor];
    privilegeLabel.font = JA_MEDIUM_FONT(17);
    privilegeLabel.text = @"等级特权";
    privilegeLabel.textColor = HEX_COLOR(0x4A4A4A);
    privilegeLabel.textAlignment = NSTextAlignmentCenter;
    [scrollView addSubview:privilegeLabel];
    privilegeLabel.centerX = JA_SCREEN_WIDTH/2.0;
    privilegeLabel.top = progressBgView.bottom+48;
    
    UIView *privilegeView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 0)];
    _privilegeView = privilegeView;
//    privilegeView.backgroundColor = [UIColor grayColor];
    [scrollView addSubview:privilegeView];
    privilegeView.top = privilegeLabel.bottom+48;

    CGFloat padding = WIDTH_ADAPTER(30);
    CGFloat itemW = (JA_SCREEN_WIDTH - padding * (3 + 1)) / 3;
    CGFloat itemH = 97;
    CGFloat maxOffY = 0;
    for (int i=0; i<self.levels.count; i++) {
        JALevelModel *levelModel = self.levels[i];
        
        JAPrivilegeItemView *itemView = [[JAPrivilegeItemView alloc] initWithFrame:CGRectMake(padding+i%3*(itemW+padding), i/3*(itemH+40), itemW, itemH)];
        [privilegeView addSubview:itemView];
        itemView.data = levelModel;
        
        maxOffY = itemView.bottom;
    }
    privilegeView.height = maxOffY;
    
    UIView *bottomContentView = [[UIView alloc] init];
    _bottomContentView = bottomContentView;
    bottomContentView.width = JA_SCREEN_WIDTH;
    bottomContentView.y = privilegeView.bottom+60;
    [scrollView addSubview:bottomContentView];
    
    UILabel *noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 24)];
    noticeLabel.font = JA_MEDIUM_FONT(17);
    noticeLabel.text = @"快速升级";
    noticeLabel.textColor = HEX_COLOR(0x4A4A4A);
    noticeLabel.textAlignment = NSTextAlignmentCenter;
//    [scrollView addSubview:noticeLabel];
    [bottomContentView addSubview:noticeLabel];
    noticeLabel.centerX = JA_SCREEN_WIDTH/2.0;
//    noticeLabel.top = privilegeView.bottom+60;
    
    
    UIImageView *fastImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 244, 257)];
    fastImageView.image = [UIImage imageNamed:@"level_fast"];
//    [scrollView addSubview:fastImageView];
    [bottomContentView addSubview:fastImageView];
    fastImageView.centerX = JA_SCREEN_WIDTH/2.0;
    fastImageView.top = noticeLabel.bottom+35;
    
    UIView *fastNoticeView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, JA_SCREEN_WIDTH-30, 0)];
    fastNoticeView.backgroundColor = HEX_COLOR(0xF4FCFF);
    fastNoticeView.layer.cornerRadius = 5.0;
    fastNoticeView.layer.masksToBounds = YES;
    fastNoticeView.layer.borderColor = [HEX_COLOR(0xDEF5FE) CGColor];
    fastNoticeView.layer.borderWidth = 1.0;
//    [scrollView addSubview:fastNoticeView];
    [bottomContentView addSubview:fastNoticeView];
    fastNoticeView.top = fastImageView.bottom+25;
    
    NSArray *titles = @[
                        @"·每日签到   签到获得经验，连续签到越多奖励越高",
                        @"·分享帖子 / 晒收入   分享帖子或朋友圈晒收入，获得更多经验",
                        @"·发布主帖／回复   发表帖子和回复被审核通过获得经验",
                        @"·收听帖子／回复   每天收听帖子回复越多经验越高",
                        @"·收到回复   你的帖子回复越多经验越高"];
    CGFloat offseY = 20;
    for (int i=0; i<titles.count; i++) {
        NSString *titleStr = titles[i];
        UILabel *titleLabel = [UILabel new];
        titleLabel.frame = CGRectMake(5, offseY, JA_SCREEN_WIDTH-30-10, 17);
        titleLabel.font = JA_REGULAR_FONT(12);
        titleLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
        titleLabel.numberOfLines = 0;
        [fastNoticeView addSubview:titleLabel];
        titleLabel.text = titleStr;
        [titleLabel sizeToFit];
        
        NSRange range = [titleStr rangeOfString:@"   "];
        NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
        [attributedStr addAttribute:NSForegroundColorAttributeName
                              value:HEX_COLOR(0x4A4A4A)
                              range:NSMakeRange(0, range.location+1)];
        titleLabel.attributedText = attributedStr;
        
        offseY = titleLabel.bottom+17;
    }
    fastNoticeView.height = offseY;
    bottomContentView.height = fastNoticeView.bottom;
    scrollView.contentSize = CGSizeMake(JA_SCREEN_WIDTH, bottomContentView.bottom+18);
}

#pragma mark - 获取个人的等级信息
- (void)getPersonalLevel
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"1";
    dic[@"levelId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_LevelId];
    [[JAUserApiRequest shareInstance] userLevelList:dic success:^(NSDictionary *result) {
        NSArray *listGrade = [JALevelModel mj_objectArrayWithKeyValuesArray:result[@"listGrade"]];
        if (listGrade.count) {
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"rightsType='story'"];
//            NSArray *leftArray = [listGrade filteredArrayUsingPredicate:predicate];
//            NSArray *sortArray = [leftArray sortedArrayUsingComparator:^NSComparisonResult(JALevelModel *obj1, JALevelModel *obj2) {
//                if (obj1.gradeNum < obj2.gradeNum) {
//                    return NSOrderedAscending;
//                }
//                return NSOrderedDescending;
//            }];
//
//            self.levels = [sortArray mutableCopy];
            
            NSArray *listGradeModels = [JALevelModel mj_objectArrayWithKeyValuesArray:listGrade];
            NSArray *sortArray = [listGradeModels sortedArrayUsingComparator:^NSComparisonResult(JALevelModel *obj1, JALevelModel *obj2) {
                if (obj1.gradeNum < obj2.gradeNum) {
                    return NSOrderedAscending;
                }
                return NSOrderedDescending;
            }];
            
            self.levels = [sortArray mutableCopy];
            
            // 刷新界面
            [self refreshPrivilegeView];
        }
    } failure:^(NSError *error) {
    }];
}

- (void)refreshPrivilegeView
{
    
    [self.privilegeView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat padding = WIDTH_ADAPTER(30);
    CGFloat itemW = (JA_SCREEN_WIDTH - padding * (3 + 1)) / 3;
    CGFloat itemH = 97;
    CGFloat maxOffY = 0;
    for (int i=0; i<self.levels.count; i++) {
        JALevelModel *levelModel = self.levels[i];
        
        JAPrivilegeItemView *itemView = [[JAPrivilegeItemView alloc] initWithFrame:CGRectMake(padding+i%3*(itemW+padding), i/3*(itemH+40), itemW, itemH)];
        [self.privilegeView addSubview:itemView];
        itemView.data = levelModel;
        
        maxOffY = itemView.bottom;
    }
    self.privilegeView.height = maxOffY;
    self.bottomContentView.y = self.privilegeView.bottom+60;
    self.scrollView.contentSize = CGSizeMake(JA_SCREEN_WIDTH, self.bottomContentView.bottom+18);
}

@end
