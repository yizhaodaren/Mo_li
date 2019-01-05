

//
//  JALaunchADManager.m
//  Jasmine
//
//  Created by xujin on 16/06/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JALaunchADManager.h"
#import "JAWebViewController.h"
#import "AppDelegate.h"
#import "XDLocationTool.h"
#import "JAVoiceCommonApi.h"
#import "JAActivityModel.h"
#import "JAPostDetailViewController.h"
#import "JAPersonalTaskViewController.h"
#import "JAPacketViewController.h"
#import "JACommonApi.h"
#import "JAPasteboardHelper.h"
#import "JAUserGuideView.h"

@interface JALaunchADManager ()<UITextViewDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIImageView *launchIV;//广告图
@property (nonatomic, strong) UIImageView *bottomIV;//底部图
@property (nonatomic, assign) NSInteger downCount;//倒计时长
@property (nonatomic, strong) UIButton *skipButton;//跳过按钮
@property (nonatomic, strong) JAActivityModel *banner;
@property (nonatomic, strong) id observer;

@end

@implementation JALaunchADManager

+ (void)load {
    [self shareInstance];
}

+ (instancetype)shareInstance {
    static JALaunchADManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        @WeakObj(self);
        self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            @StrongObj(self);
            [self addTopWindow];
            NSInteger isMaintain = [[JAConfigManager shareInstance].isMaintain integerValue];
            if (isMaintain == 1) {
                [self showServermaintain];
                return;
            }
            NSInteger operateStat = [[JAConfigManager shareInstance].operateStat integerValue];
            if (operateStat == 0) {
                if ([JAAPPManager isShowUserGuideLoad]) {
                    [self showUserGuideView];
                } else {
                    [self showAdView:self.window];
                    [self getBannerData];
                }
            } else {
                if (operateStat == 1 || operateStat == 2) {
                    // 更新页面
                    [self showUpdateView];
                } else {
                    [self hideAdViewWithAnimate:NO];
                }
            }
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO];
        }];
    }
    return self;
}

#pragma mark - PublicMethods
// 无网进入app后开启网络
- (void)checkNewVersion {
    [self addTopWindow];
    [self showUpdateView];
}

#pragma mark - ButtonAction
- (void)updateAction {
    NSString *versionString = [JAConfigManager shareInstance].updateUrl;
    NSInteger operateStat = [[JAConfigManager shareInstance].operateStat integerValue];
    if (versionString) {
        NSURL *versionUrl = [NSURL URLWithString:versionString];
        [[UIApplication sharedApplication]openURL:versionUrl];
    }
    if (operateStat == 1) {
        [self hideAdViewWithAnimate:NO];
    } else if (operateStat == 2) {
        //强制退出app
        sleep(0.5);
        exit(0);
    }
}

- (void)closeAction {
    [self hideAdViewWithAnimate:NO];
}

- (void)skipAction {
    [self hideAdViewWithAnimate:NO];
}

- (void)pushADDetailView {
    if (self.banner) {
        JABaseNavigationController *nav = [AppDelegateModel getBaseNavigationViewControll];
        
        if (self.banner.contentType.integerValue == 0 || self.banner.contentType.integerValue == 300) {
            JAWebViewController *vc = [[JAWebViewController alloc] init];
            vc.urlString = self.banner.url;
            vc.enterType = @"开屏广告";
            [nav pushViewController:vc animated:YES];
        }else if (self.banner.contentType.integerValue == 1 || self.banner.contentType.integerValue == 127){
            JAPostDetailViewController *vc = [[JAPostDetailViewController alloc] init];
            vc.voiceId = self.banner.url;
            [nav pushViewController:vc animated:YES];
        }else if (self.banner.contentType.integerValue == 2 || self.banner.contentType.integerValue == 114){
            JAPersonalTaskViewController *vc = [[JAPersonalTaskViewController alloc] init];
            [nav pushViewController:vc animated:YES];
        }else if (self.banner.contentType.integerValue == 3 || self.banner.contentType.integerValue == 110){
            JAPacketViewController *vc = [[JAPacketViewController alloc] init];
            [nav pushViewController:vc animated:YES];
        }
        [self hideAdViewWithAnimate:NO];
    }
}

#pragma mark - Network
//请求广告数据
- (void)getBannerData {
    NSString *filepath = [NSString ja_getPlistFilePath:@"/LaunchBanner.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filepath];
    [self setBannerList:dict];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    params[@"type"] = @"1";
//    params[@"platform"] = @"IOS";
    [[JAVoiceCommonApi shareInstance] voice_getLaunchBanner:params success:^(NSDictionary *result) {
        NSArray *arrayList = result[@"advertisementList"];
        if (arrayList.count) {
            NSDictionary *dict = arrayList.lastObject;
            JAActivityModel *banner = [JAActivityModel mj_objectWithKeyValues:dict];
            if (banner && banner.image) {
                [[SDWebImageManager sharedManager] diskImageExistsForURL:[NSURL URLWithString:banner.image] completion:^(BOOL isInCache) {
                    if(isInCache) {
                        //                    NSString*cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:banner.image]];
                        //                    if(cacheImageKey.length) {
                        //                        NSString*cacheImagePath = [[SDImageCache sharedImageCache]defaultCachePathForKey:cacheImageKey];
                        //                        if(cacheImagePath.length) {
                        //                            imageData = [NSData dataWithContentsOfFile:cacheImagePath];
                        //                        }
                        //                    }
                    } else {
                        // 下载图片
                        SDWebImageManager *manager = [SDWebImageManager sharedManager];
                        [manager.imageDownloader downloadImageWithURL:[NSURL URLWithString:banner.image] options:SDWebImageDownloaderContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished) {
                            NSString*cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:banner.image]];
                            if (image && cacheImageKey) {
                                [[SDImageCache sharedImageCache] storeImage:image forKey:cacheImageKey toDisk:YES completion:nil];
                            }
                        }];
                    }
                }];
            }
            [dict writeToFile:filepath atomically:YES];
        } else {
            NSFileManager* fileManager=[NSFileManager defaultManager];
            BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filepath];
            if (blHave) {
                [fileManager removeItemAtPath:filepath error:nil];
            }
        }
    } failure:^(NSError *error) {
    }];
}

- (void)setBannerList:(NSDictionary *)dict {
    JAActivityModel *banner = [JAActivityModel mj_objectWithKeyValues:dict];
    if (banner && ![NSString isExpried:banner.endTime]) {
        // 未过期的banner
        self.banner = banner;
        // 加载本地图片
        NSString*cacheImageKey = [[SDWebImageManager sharedManager] cacheKeyForURL:[NSURL URLWithString:banner.image]];
        if(cacheImageKey.length) {
            NSString*cacheImagePath = [[SDImageCache sharedImageCache] defaultCachePathForKey:cacheImageKey];
            if(cacheImagePath.length) {
                NSData *data = [NSData dataWithContentsOfFile:cacheImagePath];
                if (data) {
                    self.bottomIV.image = [UIImage imageWithData:data];
                    self.bottomIV.alpha = 0.0;
                    [UIView animateWithDuration:0.3 animations:^{
                        self.bottomIV.alpha = 1.0;
                    } completion:nil];
                    self.skipButton.hidden = NO;
                    [self timer];
                    return;
                }
            }
        }
    }
    [self hideAdViewWithAnimate:YES];
}

#pragma mark - Dealloc
- (void)hideAdViewWithAnimate:(BOOL)aniamte {
    if (aniamte) {
        [UIView animateWithDuration:0.5 animations:^{
            self.window.alpha = 0;
        } completion:^(BOOL finished) {
            [self deallocWindow];
        }];
    } else {
        [self deallocWindow];
    }
}

- (void)deallocWindow {
    self.adState = 1; // 展示完毕
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JALaunchADDismiss" object:nil];
    
    // 第一次启动获取经纬度
    // 获取权限
    [[XDLocationTool sharedXDLocationTool] getCurrentLocation:^(CLLocation *location, CLPlacemark *pl, NSString *error) {
        if (location) {
            [JAConfigManager shareInstance].location = location;
            if (pl) {
                //获取城市
                NSString *city = pl.locality;
                if (!city) {
                    //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                    city = pl.administrativeArea;
                }
                [JAConfigManager shareInstance].city = city;
                NSString *province = pl.administrativeArea;
                if (!province) {
                    //四大直辖市的城市信息无法通过administrativeArea获得只能通过locality来获得
                    province = pl.locality;
                }
                [JAConfigManager shareInstance].province = province;
                [JAConfigManager shareInstance].area = pl.subLocality;
                
                // 首次启动
                if (![JAAPPManager isFirstStartApp]) {  // 首次启动
                    if (city) {
                        [[[SensorsAnalyticsSDK sharedInstance] people] set:@"$city" to:city];
                    }
                    if (province) {
                        [[[SensorsAnalyticsSDK sharedInstance] people] set:@"$province" to:province];
                    }
                    
                }
            }

        } else {
//            CLLocation *location = [CLLocation new];
//            [JAConfigManager shareInstance].location = location;
        }
        
        [JAAPPManager appFirstStart];  // 启动设置第一次启动
    }];
    
    // 处理pasteboard
    [JAPasteboardHelper handleActiviey];
    
    // 清理资源
    [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
    
    [self.window.subviews.copy enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    self.banner = nil;
    self.launchIV = nil;
    self.bottomIV = nil;
    self.skipButton = nil;
    self.window.hidden = YES;
    self.window = nil;
}

#pragma mark - dispatch_time
//开始倒计时
- (void)timer
{
    [self.skipButton setTitle:[NSString stringWithFormat:@"跳过 %ld",(long)self.downCount] forState:UIControlStateNormal];
    if (self.downCount <= 0) {
        self.skipButton.hidden = YES;
        [self hideAdViewWithAnimate:YES];
    } else {
        self.downCount --;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self timer];
        });
    }
}

#pragma mark - UITextVieDelegate

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return NO;
}

#pragma mark - SetupUI
//添加window
- (void)addTopWindow {
    if (!self.window) {
        UIWindow *window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        window.rootViewController = [UIViewController new];
        window.rootViewController.view.backgroundColor = [UIColor clearColor];
        window.windowLevel = UIWindowLevelStatusBar+1;
        window.hidden = NO;
        self.window = window;
    }
}

//添加引导页view
- (void)showUserGuideView {
    JAUserGuideView *guideView = [JAUserGuideView new];
    [self.window addSubview:guideView];
    [guideView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.window);
    }];
    [guideView.closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    [guideView.skipButton addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
}

//添加广告view
- (void)showAdView:(UIWindow *)window {
    //ad背景
    self.launchIV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    self.launchIV.userInteractionEnabled = YES;
    //    self.launchIV.backgroundColor = [UIColor redColor];
    self.launchIV.image = [self getLaunchImage];
    [window addSubview:self.launchIV];
    
    //底部图片
    self.bottomIV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT-112-JA_TabbarSafeBottomMargin)];
    self.bottomIV.contentMode = UIViewContentModeScaleAspectFill;
    self.bottomIV.clipsToBounds = YES;
    self.bottomIV.userInteractionEnabled = YES;
    [window addSubview:self.bottomIV];
    
    //添加点击事件
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pushADDetailView)];
    [self.bottomIV addGestureRecognizer:tapGesture];
    
    //跳过按钮
    self.downCount = 3;
    self.skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.skipButton.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    self.skipButton.frame = CGRectMake(JA_SCREEN_WIDTH - 66, 35, 50, 30);
    self.skipButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.skipButton setTitle:[NSString stringWithFormat:@"跳过 %zd",self.downCount] forState:UIControlStateNormal];
    [self.skipButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.skipButton addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    self.skipButton.layer.cornerRadius = 5.0f;
    self.skipButton.layer.masksToBounds = YES;
    self.skipButton.hidden = YES;
    //    self.skipButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [window addSubview:self.skipButton];
}


//获取启动图
- (UIImage *)getLaunchImage {
    //    //获取启动图片
    //    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    //    //横屏请设置成 @"Landscape"
    //    NSString *viewOrientation = @"Portrait";
    //    NSString *launchImageName = nil;
    //    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    //    for (NSDictionary* dict in imagesDict) {
    //        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
    //        if (CGSizeEqualToSize(imageSize, viewSize) &&
    //            [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]]) {
    //            launchImageName = dict[@"UILaunchImageName"];
    //        }
    //    }
    //上面方式获取的图片与实际图不符，故不适用
    NSString *launchImageName = @"Default-568h";
    if (iPhone4) {
        launchImageName = @"Default-480h";
    } else if (iPhone5) {
        launchImageName = @"Default-568h";
    } else if (iPhone6) {
        launchImageName = @"Default-667h";
    } else if (iPhone6Plus) {
        launchImageName = @"Default-736h";
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:launchImageName ofType:@"png"];
    UIImage * launchImage = [UIImage imageWithContentsOfFile:filePath];
    return launchImage;
    // 优化内存，加载一次性的大图，使用imageWithContentsOfFile
    //    return [JALaunchADManager getTheLaunchImage];
}

+ (UIImage *)getTheLaunchImage
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = nil;
    if (([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortraitUpsideDown) || ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationPortrait)) {
        viewOrientation = @"Portrait";
    } else {
        viewOrientation = @"Landscape";
    }
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
        }
    }
    if (launchImage.length) {
        return [UIImage imageNamed:launchImage];
    }
    return nil;
}

// 添加更新view
- (void)showUpdateView {
    UIView *maskView = [UIView new];
    maskView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.3);
    [self.window addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.window);
    }];
    
    UIImageView *updateBGView = [UIImageView new];
    updateBGView.userInteractionEnabled = YES;
    updateBGView.image = [UIImage imageNamed:@"update_bg"];
    [self.window addSubview:updateBGView];
    [updateBGView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.window.mas_centerX);
        make.centerY.equalTo(self.window.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(WIDTH_ADAPTER(300), WIDTH_ADAPTER(400)));
    }];
    
    UILabel *newVersionLabel = [UILabel new];
    newVersionLabel.font = JA_MEDIUM_FONT(20);
    newVersionLabel.text = @"发现新版本";
    newVersionLabel.textColor = [UIColor whiteColor];
    [updateBGView addSubview:newVersionLabel];
    [newVersionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(WIDTH_ADAPTER(40));
        make.left.offset(WIDTH_ADAPTER(15));
        make.height.offset(30);
    }];
    
    UILabel *versionLabel = [UILabel new];
    versionLabel.font = JA_MEDIUM_FONT(14);
    versionLabel.text =  [JAConfigManager shareInstance].updateVersion;
    versionLabel.textColor = [UIColor whiteColor];
    newVersionLabel.textColor = [UIColor whiteColor];
    [updateBGView addSubview:versionLabel];
    [versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(newVersionLabel.mas_bottom).offset(2);
        make.left.offset(WIDTH_ADAPTER(15));
        make.height.offset(20);
    }];
    
    UITextView *updateInfoTV = [UITextView new];
    updateInfoTV.delegate = self;
    updateInfoTV.font = JA_REGULAR_FONT(14);
    //    updateInfoTV.text = [JAConfigManager shareInstance].updateContent;
    updateInfoTV.textColor = HEX_COLOR(0x444444);
    [updateBGView addSubview:updateInfoTV];
    [updateInfoTV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(versionLabel.mas_bottom).offset(WIDTH_ADAPTER(45));
        make.left.offset(WIDTH_ADAPTER(18));
        make.right.offset(-WIDTH_ADAPTER(14));
        make.height.offset(WIDTH_ADAPTER(190));
    }];
    
    NSString *detailString = [JAConfigManager shareInstance].updateContent;
    NSMutableAttributedString *finalStr = [[NSMutableAttributedString alloc] initWithString:detailString];
    [finalStr addAttribute:NSFontAttributeName value:updateInfoTV.font range:NSMakeRange(0, detailString.length)];
    [finalStr addAttribute:NSForegroundColorAttributeName value:updateInfoTV.textColor range:NSMakeRange(0, detailString.length)];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init]; [paragraphStyle setLineSpacing:6];
    [finalStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [detailString length])];
    updateInfoTV.attributedText = finalStr;
    
    UIButton *updateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    updateButton.titleLabel.font = JA_REGULAR_FONT(18);
    [updateButton setTitle:@"立即更新" forState:UIControlStateNormal];
    [updateButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
    [updateButton addTarget:self action:@selector(updateAction) forControlEvents:UIControlEventTouchUpInside];
    [updateBGView addSubview:updateButton];
    [updateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.offset(0);
        make.bottom.offset(0);
        make.height.offset(WIDTH_ADAPTER(50));
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [updateBGView addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(updateButton.mas_top);
        make.left.right.offset(0);
        make.height.offset(1);
    }];
    
    NSInteger operateStat = [[JAConfigManager shareInstance].operateStat integerValue];
    // 强更不需要展示关闭按钮
    if (operateStat == 1) {
        UIView *vLineView = [UIView new];
        vLineView.backgroundColor = HEX_COLOR(JA_Line);
        [self.window addSubview:vLineView];
        [vLineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.offset(-WIDTH_ADAPTER(50));
            make.bottom.equalTo(updateBGView.mas_top);
            make.width.offset(2);
            make.height.offset(WIDTH_ADAPTER(30));
        }];
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"update_close_btn"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
        closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
        [self.window addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(vLineView.mas_centerX);
            make.bottom.equalTo(vLineView.mas_top);
        }];
    }
}

// 服务器维护中
- (void)showServermaintain {
    [self addTopWindow];
    
    UIImageView *serverIV = [[UIImageView alloc] initWithFrame:self.window.bounds];
    serverIV.backgroundColor = [UIColor whiteColor];
    serverIV.contentMode = UIViewContentModeCenter;
    serverIV.image = [UIImage imageNamed:@"servermaintain"];
    
    NSString *startTime = [JAConfigManager shareInstance].maintainDate;
    NSString *endTime = [JAConfigManager shareInstance].maintainEndDate;
    startTime = [NSString timeAndDateToString:startTime];
    endTime = [NSString timeAndDateToString:endTime];
    if (startTime.length && endTime.length) {
        UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0.75*self.window.height, self.window.width, 14)];
        noticeL.text = @"维护时间";
        noticeL.textAlignment = NSTextAlignmentCenter;
        noticeL.textColor = HEX_COLOR(0x4A4A4A);
        noticeL.font = JA_LIGHT_FONT(12);
        [serverIV addSubview:noticeL];
        
        UILabel *maintainTimeL = [[UILabel alloc] initWithFrame:CGRectMake(0, noticeL.bottom+10, self.window.width, 14)];
        maintainTimeL.text = [NSString stringWithFormat:@"%@ - %@",startTime,endTime];
        maintainTimeL.textAlignment = NSTextAlignmentCenter;
        maintainTimeL.textColor = HEX_COLOR(0x4A4A4A);
        maintainTimeL.font = JA_LIGHT_FONT(12);
        [serverIV addSubview:maintainTimeL];
    }
    
    [self.window addSubview:serverIV];
}

@end
