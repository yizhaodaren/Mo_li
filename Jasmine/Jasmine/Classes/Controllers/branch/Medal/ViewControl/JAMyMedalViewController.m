
//  JAMyMedalViewController.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/10.
//  Copyright © 2018年 xujin. All rights reserved.
//
#import "JAMyMedalViewController.h"
#import "UIScrollView+touch.h"
#import "JAMarkNavigationView.h"
#import "JAMyMedalTableViewCell.h"
#import "JAMyMedalHeaderView.h"
#import "JAMedalDetailController.h"
#import "JAGetMedlController.h"
#import "JAMedalNetRequest.h"
#import "JAMedalGroupModel.h"

#import "JAMedalShareManager.h"

#define NAVBAR_COLORCHANGE_POINT (-IMAGE_HEIGHT + NAV_HEIGHT*2)
#define NAV_HEIGHT 64
#define IMAGE_HEIGHT 236//背景图片高度
#define HEADERVIEW_HEIGHT 160//headerView高度
#define SCROLL_DOWN_LIMIT 70

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define LIMIT_OFFSET_Y -(IMAGE_HEIGHT + SCROLL_DOWN_LIMIT)

@interface JAMyMedalViewController ()<UITableViewDelegate,UITableViewDataSource,MyMedaLCollectionDelegate,JAGetMedalDelegate,JAMedalDetailDelegate>

@property(nonatomic,strong) UITableView *mainTableView;
@property(nonatomic,strong) JAMarkNavigationView *navBarView;   // 导航栏
@property(nonatomic,strong) JAMyMedalHeaderView *headerView;
@property(nonatomic,strong) UIImageView *imgView;

@property(nonatomic,strong)NSMutableArray *dataSourceArray;//数据源

@property(nonatomic,strong)JAGetMedlController *getMedalVC;

@property(nonatomic,copy)NSString *storyMedalRemindStr;//规则;
@property(nonnull,strong)JAMedalShareModel *sharModel;//分享


@end

@implementation JAMyMedalViewController

//隐藏NavigationBar
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.getMedalVC = [JAGetMedlController shared];
    self.getMedalVC.view.frame = CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT);
    self.getMedalVC.delegate = self;
    
    [self initUI];
    //加载勋章数据
    [self getMyDetailList];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

}
#pragma mark 网络加载勋章列表
-(void)getMyDetailList{
    
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *userid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"userID"] = userid;
    JAMedalNetRequest *request = [[JAMedalNetRequest alloc] initRequest_getMedalListWithParameter:dic userID:userid];
    [request baseNetwork_startRequestWithcompletion:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        
        [MBProgressHUD hideHUD];
        if (responseModel.code != 10000) {
            [self.view ja_makeToast:responseModel.message];
            return;
        }
        JAMedalGroupModel *model  = (JAMedalGroupModel *)responseModel;
        
        [self.dataSourceArray removeAllObjects];
        
        //按顺序添加 连续登录  邀请  创作
        [self.dataSourceArray addObject:model.dayList];
        [self.dataSourceArray addObject:model.inviteList];
        [self.dataSourceArray addObject:model.storyList];
        self.headerView.medalNum = model.medalNum;
        self.storyMedalRemindStr = model.storyMedalRemind;
        self.sharModel = model.shareMsgVO;
        
        [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:NO];
        
        //更新未读勋章数据
        [self.getMedalVC updateArrayWith:model];
        
    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
          [MBProgressHUD hideHUD];
        [self showBlankPageWithHeight:JA_SCREEN_HEIGHT - IMAGE_HEIGHT title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.mainTableView];
    }];
}
//初始化
-(void)initUI{
    
    self.mainTableView.contentInset = UIEdgeInsetsMake(IMAGE_HEIGHT , 0, 0, 0);
    self.headerView.layer.cornerRadius = 5;
    self.headerView.backgroundColor = [UIColor whiteColor];
    
    //设置阴影
    self.headerView.layer.shadowOffset = CGSizeMake(1, 1);
    self.headerView.layer.shadowOpacity = 0.8;
    self.headerView.layer.shadowColor = [UIColor grayColor].CGColor;

    
    [self.mainTableView addSubview:self.headerView];
    
    //设置导航栏
//    self.navBarView.alwaysShowTitle = YES;
    self.navBarView.titleName = @"我的勋章";
    [self.navBarView.rightButton setImage:[UIImage imageNamed:@"branch_medal_Share"] forState:UIControlStateNormal];
    [self.navBarView.rightButton setImage:[UIImage imageNamed:@"branch_medal_share_black"] forState:UIControlStateSelected];
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
   
    CGFloat offsetY = scrollView.contentOffset.y + IMAGE_HEIGHT;// -44;
    self.navBarView.offset = offsetY;
    
    if (self.navBarView.offset >= 1) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
    
    
    //限制下拉的距离
    if(offsetY < LIMIT_OFFSET_Y) {
        [scrollView setContentOffset:CGPointMake(0, LIMIT_OFFSET_Y)];
    }
    
    // 改变图片框的大小 (上滑的时候不改变)
    // 这里不能使用offsetY，因为当（offsetY < LIMIT_OFFSET_Y）的时候，y = LIMIT_OFFSET_Y 不等于 offsetY
    CGFloat newOffsetY = scrollView.contentOffset.y;
    if (newOffsetY < -IMAGE_HEIGHT)
    {
        self.imgView.frame = CGRectMake(0, newOffsetY, kScreenWidth, -newOffsetY);
    }
}
#pragma mark tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    JAMyMedalTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JAMyMedalTableViewCell"];
    cell.superController  = self.mainTableView;
    cell.delegate = self;
    cell.collectionDataArray = self.dataSourceArray[indexPath.row];
    cell.index = indexPath.row;
    cell.storyMedalRemindStr = self.storyMedalRemindStr;
    
    //解决iOS9（具体还有哪些不明确 新系统和8.1没问题）Cell事件不能触发问题
    cell.contentView.hidden = YES;
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 180;
}


#pragma mark LJZ
-(NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray array];
    }
    return _dataSourceArray;
}
-(UITableView *)mainTableView{
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,0,JA_SCREEN_WIDTH,JA_SCREEN_HEIGHT) style:UITableViewStylePlain];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        
        UINib *nib = [UINib nibWithNibName:@"JAMyMedalTableViewCell" bundle:[NSBundle mainBundle]];
        [_mainTableView registerNib:nib forCellReuseIdentifier:@"JAMyMedalTableViewCell"];
        _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        
        _mainTableView.showsVerticalScrollIndicator = NO;
        [_mainTableView addSubview:self.imgView];
        [_mainTableView addSubview:self.headerView];
        _mainTableView.backgroundColor = HEX_COLOR(0xF9F9F9);
        [self.view addSubview:_mainTableView];
        
    }
    return _mainTableView;
}
//header头像
- (UIImageView *)imgView
{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -IMAGE_HEIGHT, kScreenWidth, IMAGE_HEIGHT)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        
        _imgView.image =[UIImage imageNamed:@"branch_myMedal_bg"];
//        _imgView.image = [self imageWithImageSimple:[UIImage imageNamed:@"branch_myMedal_bg"] scaledToSize:CGSizeMake(kScreenWidth, IMAGE_HEIGHT+SCROLL_DOWN_LIMIT)];

    }
    return _imgView;
}
-(JAMyMedalHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle]loadNibNamed:@"JAMyMedalHeaderView" owner:self options:nil] firstObject];
         _headerView.frame = CGRectMake(15, - HEADERVIEW_HEIGHT -10, JA_SCREEN_WIDTH - 30, HEADERVIEW_HEIGHT);
     
        //设置头像
       if ([JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl]) {
            [_headerView.headerImageView sd_setImageWithURL:[NSURL URLWithString:
                                                             [JAUserInfo userInfo_getUserImfoWithKey:User_ImageUrl]] placeholderImage:nil];
        }else{
           [_headerView.headerImageView sd_setImageWithURL:[NSURL URLWithString:@"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/user/userboy_01.png"] placeholderImage:nil];
        }
    
        
    }
    return _headerView;
}

- (UIImage *)imageWithImageSimple:(UIImage *)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext(CGSizeMake(newSize.width*2, newSize.height*2));
    [image drawInRect:CGRectMake (0, 0, newSize.width*2, newSize.height*2)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
//自定义导航栏
- (JAMarkNavigationView *)navBarView
{
    if (_navBarView == nil) {
        JAMarkNavigationView *navBarView = [[JAMarkNavigationView alloc] init];
        _navBarView = navBarView;
        [_navBarView markNavBarView_changeInfoButtonToEdge:YES];
        navBarView.backgroundColor = [UIColor clearColor];
        [navBarView.leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [navBarView.rightButton addTarget:self action:@selector(rightClick) forControlEvents:UIControlEventTouchUpInside];
        navBarView.hidden = NO;
     
        [self.view addSubview:navBarView];
    }

    return _navBarView;
}
//返回按钮
-(void)back{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    [self.navigationController popViewControllerAnimated:YES];
}
//rightItem事件
-(void)rightClick{
    [[JAMedalShareManager instance] shareWith:self.sharModel domainType:6];
}
//主线程geng新UI
-(void)updateUI{
      [self updateMedalNameWith:[JAUserInfo userInfo_getUserImfoWithKey:User_Name]];
      [self.mainTableView reloadData];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    NSNotification *notification =[NSNotification notificationWithName:@"removeJFDview" object:nil userInfo:nil];
    //通知中心 发送 通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
}
#pragma mark MyMedaLCollectionDelegate

-(void)MyMedaLCollection:(UICollectionView *)collectionView didSelectRowAtIndexPath:(NSIndexPath *)indexPath medal:(JAMedalModel *)Medal{
    JAMedalDetailController *vc = [[JAMedalDetailController alloc] init];
      vc.medalUserID = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
      vc.medalID = Medal.medalId;
      vc.delegate = self;
      vc.isMySelfMedal= YES;
      vc.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [self presentViewController:vc animated:YES completion:nil];
}
//跟新勋章名称
-(void)updateMedalNameWith:(NSString *)medalName{
    self.headerView.titleLable.text = medalName;
}
#pragma mark JAGetMedalDelegate
- (void)showNextMedal {
    [self.view addSubview:self.getMedalVC.view];
    [self.getMedalVC showAnimation:YES];
}
#pragma mark JAMedalDetailDelegate
-(void)refreshMedalList{
    [self getMyDetailList];
}

@end
