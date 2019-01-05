//
//  JAOtherPersonMedalController.m
//  Jasmine
//
//  Created by 王树超 on 2018/7/10.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAOtherPersonMedalController.h"
#import "JAMedalDetailController.h"

#import "JAMarkNavigationView.h"//导航栏
#import "JAOtherPersonMedalCollectionViewCell.h"
#import "JAMyMedalHeaderView.h"
#import "JAOtherPersonMedalController.h"
#import "JAMedalNetRequest.h"
#import "JAMedalGroupModel.h"

#import "UIImageView+LBBlurredImage.h"//模糊图片

#define NAVBAR_COLORCHANGE_POINT (-IMAGE_HEIGHT + NAV_HEIGHT*2)
#define NAV_HEIGHT 64
#define IMAGE_HEIGHT 210//背景图片高度
#define HEADERVIEW_HEIGHT 160//headerView高度
#define SCROLL_DOWN_LIMIT 70

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define LIMIT_OFFSET_Y -(IMAGE_HEIGHT + SCROLL_DOWN_LIMIT)
@interface JAOtherPersonMedalController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate>

@property(nonatomic,strong) UICollectionView *mainCollectionView;
@property (nonatomic, strong) JAMarkNavigationView *navBarView;   // 导航栏
@property(nonatomic,strong) JAMyMedalHeaderView *headerView;
@property (nonatomic, strong) UIImageView *imgView;


@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation JAOtherPersonMedalController

//隐藏NavigationBar
- (BOOL)fd_prefersNavigationBarHidden {
    return YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //请求数据
    [self getDedalList];
}


//初始化
-(void)initUI{
    self.mainCollectionView.contentInset = UIEdgeInsetsMake(IMAGE_HEIGHT , 0, 0, 0);
    
    //s
    self.headerView.layer.cornerRadius = 5;
    self.headerView.clipsToBounds = YES;
    [self.mainCollectionView addSubview:self.headerView];
    
   
    
    //设置导航栏
//    self.navBarView.alwaysShowTitle = YES;//显示标题
    self.navBarView.titleName = @"他的勋章";

}
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGFloat offsetY = scrollView.contentOffset.y + IMAGE_HEIGHT;// -44;
    //NSLog(@"%f",offsetY);
    
    // 计算导航条的隐藏
    self.navBarView.offset = offsetY;
//    if (offsetY > 0) {
//        self.navBarView.alphaValue = (offsetY) / (IMAGE_HEIGHT - 64);
//        if (self.navBarView.alphaValue >= 1) {
//            self.navBarView.alphaValue = 1.0;
//        }
//    }else{
//        self.navBarView.alphaValue = 0.0;
//    }
    
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



#pragma mark LJZ
-(UICollectionView *)mainCollectionView{
    if (!_mainCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 1;
        layout.minimumInteritemSpacing = 1;
        layout.itemSize = CGSizeMake((JA_SCREEN_WIDTH / 3.5) , (JA_SCREEN_WIDTH / 3.5) * 1.5);
        layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        
        _mainCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT) collectionViewLayout:layout];
        
        _mainCollectionView.delegate = self;
        _mainCollectionView.dataSource = self;
        _mainCollectionView.backgroundColor = [UIColor whiteColor];
        
        
        //regiterCell
        UINib *nib = [UINib nibWithNibName:@"JAOtherPersonMedalCollectionViewCell" bundle:[NSBundle mainBundle]];
        [_mainCollectionView registerNib:nib forCellWithReuseIdentifier:@"JAOtherPersonMedalCollectionViewCell"];
        //注册sectionHeader
        UINib *headerNib = [UINib nibWithNibName:@"JAOtherPersonHeaderSectionView" bundle:[NSBundle mainBundle]] ;
        [_mainCollectionView registerNib:headerNib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeader"];
        
        [_mainCollectionView addSubview:self.imgView];
        [_mainCollectionView addSubview:self.headerView];
        _mainCollectionView.showsVerticalScrollIndicator  = NO;
        [self.view addSubview:_mainCollectionView];
        
    }
    return _mainCollectionView;
}
//header头像
- (UIImageView *)imgView
{
    if (_imgView == nil) {
        _imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -IMAGE_HEIGHT, kScreenWidth, IMAGE_HEIGHT)];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
        
        [_imgView sd_setImageWithURL:[NSURL URLWithString:self.imageUrl] placeholderImage:nil];
        
//        _imgView.image = [self imageWithImageSimple:_imgView.image scaledToSize:CGSizeMake(kScreenWidth, IMAGE_HEIGHT+SCROLL_DOWN_LIMIT)];
//        
        // 20 左右 R  模糊图片
        [_imgView setImageToBlur:_imgView.image blurRadius:10 completionBlock:nil];

    }
    return _imgView;
}
-(JAMyMedalHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[[NSBundle mainBundle]loadNibNamed:@"JAMyMedalHeaderView" owner:self options:nil] firstObject];
        _headerView.frame = CGRectMake(15, - HEADERVIEW_HEIGHT -10, JA_SCREEN_WIDTH - 30, HEADERVIEW_HEIGHT);
        _headerView.titleLable.textColor = [UIColor whiteColor];
        _headerView.backgroundColor = [UIColor clearColor];
        NSURL *url = [NSURL URLWithString:self.imageUrl];
        
        [_headerView.headerImageView sd_setImageWithURL:url placeholderImage:[UIImage imageNamed:@"bg_man"]];
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
-(NSMutableArray *)dataSourceArray{
    if (!_dataSourceArray) {
        _dataSourceArray = [NSMutableArray array];
    }
    return _dataSourceArray;
}
//自定义导航栏
- (JAMarkNavigationView *)navBarView
{
   if (_navBarView == nil) {
        JAMarkNavigationView *navBarView = [[JAMarkNavigationView alloc] init];
        _navBarView = navBarView;
        navBarView.backgroundColor = [UIColor clearColor];
        [navBarView.leftButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
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
#pragma mark collectionViewDelegate
- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    JAOtherPersonMedalCollectionViewCell *cell = [_mainCollectionView dequeueReusableCellWithReuseIdentifier:@"JAOtherPersonMedalCollectionViewCell" forIndexPath:indexPath];

    JAMedalModel *model = self.dataSourceArray[indexPath.row];
    if ([model.status isEqualToString:@"2"]) {
       self.headerView.titleLable.text = model.medalName;
    }
    cell.medalModel = model;
    return cell;
}
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;
{
    return 1;
}
- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataSourceArray.count;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(JA_SCREEN_WIDTH, 30);
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"collectionHeader" forIndexPath:indexPath];
        return view;
    }else{
        return nil;
    }
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    JAMedalModel *model = self.dataSourceArray[indexPath.row];
    
    JAMedalDetailController *vc = [[JAMedalDetailController alloc] init];
    vc.medalUserID = self.userid;
    vc.medalID = model.medalId;
    vc.statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [self presentViewController:vc animated:YES completion:nil];
}
#pragma mark 网络加载勋章列表
-(void)getDedalList{
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    NSString *userid = self.userid;
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
        [self.dataSourceArray addObjectsFromArray:model.dayList];
        [self.dataSourceArray addObjectsFromArray:model.inviteList];
        [self.dataSourceArray addObjectsFromArray:model.storyList];
        self.headerView.medalNum = model.medalNum;
       
        //找到未获得的勋章
        NSMutableArray *array = [NSMutableArray array];
        [self.dataSourceArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JAMedalModel *model = (JAMedalModel *)obj;
            if ([model.status isEqualToString:@"3"]) {
                [array addObject:model];
            }
        }];
        //移除未获得的勋章
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            JAMedalModel *model = (JAMedalModel *)obj;
            [self.dataSourceArray removeObject:model];
        }];
        //排序
        NSArray * sortArray = [self.dataSourceArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSComparisonResult result = [obj1 compareParkInfo:obj2];
            return result;
        }];
        self.dataSourceArray = [NSMutableArray arrayWithArray:sortArray];
        
        //如果没有勋章
        if (self.dataSourceArray.count < 1) {
          [self showBlankPageWithHeight:JA_SCREEN_HEIGHT - JA_NavigationBarHeight - IMAGE_HEIGHT title:@"他还没获得勋章" subTitle:@"" image:@"blank_nobody" buttonTitle:nil selector:nil buttonShow:NO superView:self.mainCollectionView];
        }else{
             [self.mainCollectionView reloadData];
        }

    } failure:^(__kindof JANewBaseNetRequest *request, JANetBaseModel *responseModel) {
        [MBProgressHUD hideHUD];
        
        [self showBlankPageWithHeight:JA_SCREEN_HEIGHT - JA_NavigationBarHeight - IMAGE_HEIGHT title:@"网络请求失败" subTitle:@"" image:@"blank_fail" buttonTitle:nil selector:nil buttonShow:NO superView:self.mainCollectionView];
        
    }];
}

@end



