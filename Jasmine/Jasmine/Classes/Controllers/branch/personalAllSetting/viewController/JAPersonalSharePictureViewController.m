//
//  JAPersonalSharePictureViewController.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/9.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalSharePictureViewController.h"
#import "JAPlatformShareManager.h"
#import "JAVoiceCommonApi.h"
#import "JAUserApiRequest.h"
#import "AppDelegate.h"
#import "JAVoiceCommonApi.h"
#import "JASharePictureModel.h"
#import "SDCycleScrollView.h"

@interface JAPersonalSharePictureViewController ()<PlatformShareDelegate,SDCycleScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, weak) UILabel *topLabel;
@property (nonatomic, weak) SDCycleScrollView *showImageView; // 小的imageView
@property (nonatomic, weak) UIButton *leftButton;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UILabel *bottomLabel;
@property (nonatomic, weak) UIView *linesView;
@property (nonatomic, weak) UILabel *countLabel;
@property (nonatomic, weak) UIButton *shareButton;

@property (nonatomic, weak) UIButton *frontButton;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) NSArray *pictureImages;  // 数据模型

@property (nonatomic, strong) NSString *shareMoney; // 分享的钱
@property (nonatomic, strong) NSMutableArray *imageArray;  // 图片数组
@property (nonatomic, strong) NSMutableArray *sorePictureImages; // 新的图片数组

@end

@implementation JAPersonalSharePictureViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.showImageView adjustWhenControllerViewWillAppera];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[JA_Property_ScreenName] = @"晒收入";
    [JASensorsAnalyticsManager sensorsAnalytics_browseViewPage:params];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _imageArray = [NSMutableArray array];
    _sorePictureImages = [NSMutableArray array];

    [self setup];
    
    [self setCenterTitle:@"晒收入"];
    
    // 获取最新的收入
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAUserApiRequest shareInstance] userExchangeInfo:dic success:^(NSDictionary *result) {
        NSString *incomeM = [NSString stringWithFormat:@"%.2f", [result[@"flowermoney"][@"moneyCount"] floatValue]];
        NSString *expenditureM = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
        self.shareMoney = [NSString stringWithFormat:@"%.2f",incomeM.floatValue + expenditureM.floatValue];
        // 获取模板
        [self getPictureImagesData];
    } failure:^(NSError *error) {
    }];
}

- (void)getPictureImagesData
{
    [MBProgressHUD showMessage:nil];
    
    self.pictureImages = [JAConfigManager shareInstance].shareTemplateArray;
    
    if (self.pictureImages.count) {
        
        self.countLabel.text = [NSString stringWithFormat:@"%02ld/%02ld",self.currentPage+1,self.pictureImages.count];
        [self setupLineView:self.pictureImages.count];
        
        @WeakObj(self);
        [self setupShareImage:self.pictureImages finish:^{
            @StrongObj(self);
            [MBProgressHUD hideHUD];
            self.showImageView.localizationImageNamesGroup = self.imageArray;
        }];
    }else{
        [MBProgressHUD hideHUD];
    }
    
//    [[JAVoiceCommonApi shareInstance] voice_getShareTemplate:nil success:^(NSDictionary *result) {
//
//        NSString *filePath = [NSString ja_getPlistFilePath:@"/ShareTemplateDefault.plist"];
//        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:result];
//        dictionary[@"version"] = @(0);
//        [dictionary writeToFile:filePath atomically:YES];
//
//
//        self.pictureImages = [JASharePictureModel mj_objectArrayWithKeyValuesArray:result[@"allShareFriendList"]];
//
//    } failure:^(NSError *error) {
//    }];
}

- (void)setupShareImage:(NSArray <JASharePictureModel *> *)array finish:(void(^)())finish
{
    [self.imageArray removeAllObjects];
    
    for (NSInteger i = 0; i < array.count; i++) {
        JASharePictureModel *model = array[i];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.width = JA_SCREEN_WIDTH;
        imageView.height = JA_SCREEN_WIDTH * 374 / 255;
        
        UILabel *label1 = [[UILabel alloc] init];
        
        label1.textColor = HEX_COLOR(0xffffff);
        label1.font = JA_MEDIUM_FONT(20);
        label1.textAlignment = NSTextAlignmentCenter;
        label1.width = imageView.width;
        label1.height = WIDTH_ADAPTER(32);
        label1.y = WIDTH_ADAPTER(210);
        label1.attributedText = [self attributedString:[NSString stringWithFormat:@"赚了%@元",self.shareMoney] word:self.shareMoney];
        [imageView addSubview:label1];
        
        UILabel *label2 = [[UILabel alloc] init];
        
        label2.text = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
        label2.textColor = HEX_COLOR(0xffffff);
        label2.font = JA_REGULAR_FONT(12);
        label2.textAlignment = NSTextAlignmentCenter;
        label2.width = imageView.width;
        label2.height = WIDTH_ADAPTER(17);
        label2.y = label1.bottom + WIDTH_ADAPTER(25);
        [imageView addSubview:label2];
        
        if (model.type.integerValue == 1) {
            
            label1.hidden = NO;
            label2.hidden = NO;
        }else{
            
            label1.hidden = YES;
            label2.hidden = YES;
        }
        
        @WeakObj(self);
        [imageView ja_setImageWithURLStr:model.image placeholderImage:nil completed:^(UIImage *image, NSError *error) {
            @StrongObj(self);
            UIImage *shareImage = [self screenShotView:imageView];
//            [self.imageArray addObject:shareImage];
            NSInteger count = self.imageArray.count + 1;
            NSInteger index = arc4random() % count;
            [self.imageArray insertObject:shareImage atIndex:index];
            [self.sorePictureImages insertObject:model atIndex:index];
            
            if (self.imageArray.count == array.count) {
                if (finish) {
                    finish();
                }
            }
            
        }];
    }
}

- (void)setup
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    scrollView.frame = self.view.bounds;
    scrollView.height = self.view.height - 64;
    [self.view addSubview:scrollView];
    
    UILabel *topLabel = [[UILabel alloc] init];
    _topLabel = topLabel;
    topLabel.text = @"创新短音频生活情感交流平台";
    topLabel.textColor = HEX_COLOR(0x4A4A4A);
    topLabel.font = JA_REGULAR_FONT(17);
    topLabel.width = self.view.width;
    topLabel.height = 0;
    topLabel.y = WIDTH_ADAPTER(20);
    topLabel.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:topLabel];
    [scrollView addSubview:topLabel];
  
    SDCycleScrollView *showImageView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(self.view.width * 0.5 - WIDTH_ADAPTER(255) * 0.5, topLabel.bottom + WIDTH_ADAPTER(10), WIDTH_ADAPTER(255), WIDTH_ADAPTER(374)) delegate:self placeholderImage:[UIImage imageWithColor:HEX_COLOR(0xffffff)]];
    _showImageView = showImageView;
    self.showImageView.backgroundColor = [UIColor whiteColor];
    self.showImageView.showPageControl = NO;
    self.showImageView.autoScroll = NO;
//    [self.view addSubview:showImageView];
    [scrollView addSubview:showImageView];
    
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _leftButton = leftButton;
    [leftButton setImage:[UIImage imageNamed:@"share_button_left"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(clickLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.width = (JA_SCREEN_WIDTH - showImageView.width) * 0.5;
    leftButton.height = 23;
    leftButton.centerY = showImageView.centerY;
//    [self.view addSubview:leftButton];
    [scrollView addSubview:leftButton];
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton = rightButton;
    [rightButton setImage:[UIImage imageNamed:@"share_button_right"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(clickRightButton:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.width = (JA_SCREEN_WIDTH - showImageView.width) * 0.5;
    rightButton.height = 23;
    rightButton.centerY = showImageView.centerY;
    rightButton.x = showImageView.right;
//    [self.view addSubview:rightButton];
    [scrollView addSubview:rightButton];
    
    UILabel *countLabel = [[UILabel alloc] init];
    _countLabel = countLabel;
    countLabel.text = @" ";
    countLabel.textColor = HEX_COLOR(0x4A4A4A);
    countLabel.font = JA_MEDIUM_FONT(12);
    countLabel.width = 50;
    countLabel.height = 17;
    countLabel.x = showImageView.right - countLabel.width;
    countLabel.y = showImageView.bottom + WIDTH_ADAPTER(10);
    countLabel.textAlignment = NSTextAlignmentRight;
//    [self.view addSubview:countLabel];
    [scrollView addSubview:countLabel];
    
    UIView *linesView = [[UIView alloc] init];
    _linesView = linesView;
    linesView.width = countLabel.x - showImageView.x;
    linesView.height = countLabel.height;
    linesView.y = countLabel.y;
    linesView.x = showImageView.x;
//    [self.view addSubview:linesView];
    [scrollView addSubview:linesView];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton = shareButton;
    [shareButton setImage:[UIImage imageNamed:@"share_button_nor"] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"share_button_hight"] forState:UIControlStateHighlighted];
    shareButton.width = WIDTH_ADAPTER(300);
    shareButton.height = WIDTH_ADAPTER(60);
    shareButton.y = self.linesView.bottom + WIDTH_ADAPTER(25);
    shareButton.centerX = self.view.width * 0.5;
    [shareButton addTarget:self action:@selector(sharePicture) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:shareButton];
    [scrollView addSubview:shareButton];
    
    UILabel *bottomLabel = [[UILabel alloc] init];
    _bottomLabel = bottomLabel;
    bottomLabel.text = @"每天首次晒图朋友圈获得翻倍奖励\n需要分享至微信朋友圈当朋友们看到后才能拿到奖励";
    bottomLabel.textColor = HEX_COLOR(0x4A4A4A);
    bottomLabel.font = JA_REGULAR_FONT(13);
    bottomLabel.textAlignment = NSTextAlignmentCenter;
    bottomLabel.numberOfLines = 0;
    [bottomLabel sizeToFit];
    bottomLabel.width = self.view.width;
    bottomLabel.y = self.shareButton.bottom + WIDTH_ADAPTER(15);
//    [self.view addSubview:bottomLabel];
    [scrollView addSubview:bottomLabel];
    
    if (iPhone4) {
        scrollView.contentSize = CGSizeMake(0, bottomLabel.bottom);
        scrollView.scrollEnabled = YES;
    }else{
        scrollView.scrollEnabled = NO;
    }
}

// 创建横线
- (void)setupLineView:(NSInteger)count
{
    CGFloat margin = 5;
    for (NSInteger i = 0; i < count; i++) {
        
        UIButton *line = [UIButton buttonWithType:UIButtonTypeCustom];
        [line setImage:[UIImage imageWithColor:HEX_COLOR(0xEBEBEB) size:CGSizeMake(20, 2)] forState:UIControlStateNormal];
        [line setImage:[UIImage imageWithColor:HEX_COLOR(0x4A4A4A) size:CGSizeMake(20, 2)] forState:UIControlStateSelected];
        line.width = 20;
        line.height = 2;
        line.centerY = self.linesView.height * 0.5;
        line.x = (line.width + margin) * i;
        [self.linesView addSubview:line];
        
        if (i == 0) {
            line.selected = YES;
            self.frontButton = line;
            self.currentPage = 0;
        }
    }
}

#pragma mark - 按钮点击
// 点击左边按钮
- (void)clickLeftButton:(UIButton *)btn
{
    if (self.imageArray.count) {
        int indexP = [self.showImageView currentIndex];
        [self.showImageView scrollToIndex:indexP - 1];
    }
}

// 点击右边按钮
- (void)clickRightButton:(UIButton *)btn
{
    if (self.imageArray.count) {
        
        int indexP = [self.showImageView currentIndex];
        [self.showImageView scrollToIndex:indexP + 1];
    }
}

// 图片滚动
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didScrollToIndex:(NSInteger)index
{
    self.frontButton.selected = NO;
    UIButton *lineButton = (UIButton *)self.linesView.subviews[index];
    lineButton.selected = YES;
    self.frontButton = lineButton;
    self.countLabel.text = [NSString stringWithFormat:@"%02ld/%02ld",index+1,self.pictureImages.count];
    self.currentPage = index;
}

// 分享
- (void)sharePicture
{
    if (self.imageArray.count) {
        
        [self sensorsAnalyticsWithShareMoney:self.sorePictureImages[self.currentPage]];
        
        AppDelegate *appDelegate = [AppDelegate sharedInstance];
        appDelegate.shareDelegate = self;
        // 生产图
        UIImage *shareImage = self.imageArray[self.currentPage];
        [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareImage:shareImage];
    }
}
- (void)qqShare:(NSString *)error {
    
}

- (void)wbShare:(int)code {
    
}

- (void)wxShare:(int)code   // 分享收入 成功后才算完成任务
{
    if (code == 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"type"] = @"0";
        [[JAVoiceCommonApi shareInstance] voice_appShareIncomeWithParas:dic success:^(NSDictionary *result) {
            
        } failure:^(NSError *error) {
            
        }];
    }else if (code == -1) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信未识别的错误类型，请重试"];
    }else if (code == -2) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享取消"];
    }else if (code == -3) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享发送失败，请重试"];
    }else if (code == -4) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"授权失败，请重试"];
    }else if (code == -5) {
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"微信不支持"];
    }else{
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

-(UIImage *)screenShotView:(UIView *)view{
    UIImage *imageRet;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageRet;
}


- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xF8E81C) range:rang];
    [attr addAttribute:NSFontAttributeName value:JA_MEDIUM_FONT(26) range:rang];
    
    return attr;
}

// 神策数据
- (void)sensorsAnalyticsWithShareMoney:(JASharePictureModel *)model
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_ShareButton] = @"直接晒收入";
    senDic[JA_Property_ImageUrl] = model.image;
    senDic[JA_Property_SerialNumber] = @(self.currentPage + 1);
    [JASensorsAnalyticsManager sensorsAnalytics_clickShareMoney:senDic];
}
@end
