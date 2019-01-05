//
//  JACircleInfoViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/25.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JACircleInfoViewController.h"
#import "JACircleNetRequest.h"

#import "JACircleInfoHeadView.h"
#import "JACircleInfoView.h"

#import "JAPersonalCenterViewController.h"
#import "JAWebViewController.h"

#import "JASwitchDefine.h"

#define kRequestCount_circleAdmin 20

@interface JACircleInfoViewController ()

@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) JACircleInfoHeadView *headView;
@property (nonatomic, weak) JACircleInfoView *infoView;
@end

@implementation JACircleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _dataSourceArray = [NSMutableArray array];
    [self setCenterTitle:@"圈子资料"];
    [self setupCircleInfoViewControllerUI];
    
    
    // 网络请求
    [self request_getCircleAdmin];
}

#pragma mark - 按钮的点击
- (void)followCircle:(UIButton *)button
{
    if (button.selected) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定取消关注吗？" message:@"取消关注后将不获得本圈子的经验值,已获得的经验值将一直保存" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self request_followCircle];
        }];
        
        UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [alert addAction:action1];
        [alert addAction:action2];
        [self presentViewController:alert animated:YES completion:nil];
    }else{
        [self request_followCircle];
    }
}

- (void)CircleLevel
{
    
    JAWebViewController *vc = [[JAWebViewController alloc] init];
    NSString *urlS = @"http://www.urmoli.com/views/app/about/circleLevel.html";
#ifdef JA_TEST_HOST
   urlS = @"http://dev.portal.yourmoli.com/views/app/about/circleLevel.html";
#endif
    vc.urlString = [NSString stringWithFormat:@"%@?circleId=%@",urlS,self.circleModel.circleId];
    vc.titleString = @"我的圈子等级";
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - 网络请求
- (void)request_getCircleAdmin
{
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_circleBigAndSmallAdminWithParameter:nil circleId:self.circleModel.circleId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        JACircleAdminGroupModel *userMGroup = (JACircleAdminGroupModel *)responseModel;
        if (userMGroup.code != 10000) {
            return;
        }
        // 解析数据
        [self.dataSourceArray addObjectsFromArray:userMGroup.resBody];
        self.infoView.dataSourceArray = self.dataSourceArray;
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
    }];
}

// 关注圈子
- (void)request_followCircle
{
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    
    self.infoView.followButton.userInteractionEnabled = NO;
    // 关注圈子
    JACircleNetRequest *r = [[JACircleNetRequest alloc] initRequest_focusCircleWithParameter:nil circleId:self.circleModel.circleId];
    
    [r baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.infoView.followButton.userInteractionEnabled = YES;
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            return;
        }
        NSDictionary *dic = request.responseObject[@"resBody"];
        if ([dic[@"follow"] integerValue]) {
            self.infoView.followButton.selected = YES;
            if (self.followAndCancleCircle) {
                self.followAndCancleCircle(YES);
            }
        }else{
            self.infoView.followButton.selected = NO;
            if (self.followAndCancleCircle) {
                self.followAndCancleCircle(NO);
            }
        }
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        self.infoView.followButton.userInteractionEnabled = YES;
    }];
    
}

#pragma mark - UI
- (void)setupCircleInfoViewControllerUI
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    // 头部
    self.headView = [[JACircleInfoHeadView alloc] init];
    self.headView.width = JA_SCREEN_WIDTH;
//    self.circleModel.circleDesc = @"d大风收到发发发大水法萨芬撒飞洒发生法萨芬大法师飞洒的范德萨发生范德萨发hsjahjfhjsafhjsahfjhsdjfhajs房间爱打飞机的撒继父回家阿什顿飞机安徽福建发生纠纷静安寺倒海翻江哈几哈放大镜复活甲安徽省大姐夫";
    NSString *des = self.circleModel.circleDesc;
    // 计算高度
    CGSize maxS = CGSizeMake(JA_SCREEN_WIDTH - 30, MAXFLOAT);
    CGFloat subHeight = [des boundingRectWithSize:maxS options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : JA_REGULAR_FONT(14)} context:nil].size.height;
    self.headView.height = 135 + subHeight + 20;
    self.headView.model = self.circleModel;
    [scrollView addSubview:self.headView];
    
    JACircleInfoView *infoView = [[JACircleInfoView alloc] init];
    _infoView = infoView;
    [infoView.followButton addTarget:self action:@selector(followCircle:) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CircleLevel)];
    [infoView.middleView addGestureRecognizer:tap];
    infoView.circleModel = self.circleModel;
    [scrollView addSubview:infoView];
    [infoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.offset(self.headView.height);
    }];
}

- (void)setCircleModel:(JACircleModel *)circleModel
{
    _circleModel = circleModel;
    self.infoView.circleModel = circleModel;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self calculatorCircleInfoViewControllerFrame];
}
- (void)calculatorCircleInfoViewControllerFrame
{
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(0, self.infoView.bottom);
}

@end
