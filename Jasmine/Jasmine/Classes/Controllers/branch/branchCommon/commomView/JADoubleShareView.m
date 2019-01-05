//
//  JADoubleShareView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/11.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JADoubleShareView.h"
#import "JAPlatformShareManager.h"
#import "JAVoiceCommonApi.h"
#import "JAUserApiRequest.h"

@interface JADoubleShareView ()<PlatformShareDelegate>

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *closeButton;
@property (nonatomic, weak) UIButton *awardButton;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) UIButton *sureButton;
@property (nonatomic, weak) UIButton *goShareButton;

@property (nonatomic, weak) UILabel *label1;
@property (nonatomic, strong) UIImageView *shareImageView;
@end

@implementation JADoubleShareView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    }
    return self;
}


- (void)setup
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"double_share_back"]];
    _imageView = imageView;
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"double_share_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    UIButton *awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _awardButton = awardButton;
    [awardButton setImage:[UIImage imageNamed:@"double_share_flower"] forState:UIControlStateNormal];
    [awardButton setTitle:@" +0朵花" forState:UIControlStateNormal];
    [awardButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    awardButton.titleLabel.font = JA_REGULAR_FONT(15);
    [imageView addSubview:awardButton];
    
    UILabel *label = [[UILabel alloc] init];
    _label = label;
    label.text = @"可在钱包兑换成现金";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = HEX_COLOR(0xffffff);
    label.font = JA_REGULAR_FONT(12);
    [imageView addSubview:label];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureButton = sureButton;
    [sureButton setImage:[UIImage imageNamed:@"double_share_sure"] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:sureButton];
    
    UIButton *goShareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _goShareButton = goShareButton;
    [goShareButton setTitle:@"去朋友圈晒收入奖励翻倍" forState:UIControlStateNormal];
    [goShareButton setBackgroundImage:[UIImage imageNamed:@"double_share_goTo"] forState:UIControlStateNormal];
    [goShareButton setTitleColor:HEX_COLOR(0x381568) forState:UIControlStateNormal];
    goShareButton.titleLabel.font = JA_LIGHT_FONT(14);
    [goShareButton addTarget:self action:@selector(goToSharePicture) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:goShareButton];
    
    UIImageView *shareImageView = [[UIImageView alloc] init];
    _shareImageView = shareImageView;
    shareImageView.width = JA_SCREEN_WIDTH;
    shareImageView.height = JA_SCREEN_WIDTH * 374 / 255;
//    shareImageView.image = [UIImage imageNamed:@"branch_share_picture"];
    [shareImageView ja_setImageWithURLStr:@"http://file.xsawe.top/sharetask/sharemoney-task.png"];
//    [self addSubview:shareImageView];
    
    UILabel *label1 = [[UILabel alloc] init];
    _label1 = label1;
    label1.textColor = HEX_COLOR(0xffffff);
    label1.font = JA_MEDIUM_FONT(20);
    label1.textAlignment = NSTextAlignmentCenter;
    label1.width = shareImageView.width;
    label1.height = WIDTH_ADAPTER(32);
    label1.y = WIDTH_ADAPTER(210);
    NSString *incomeM = [JAUserInfo userInfo_getUserImfoWithKey:User_IncomeMoney];
    NSString *expenditureM = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
    NSString *str = [NSString stringWithFormat:@"%.2f",incomeM.floatValue + expenditureM.floatValue];
    label1.attributedText = [self attributedString:[NSString stringWithFormat:@"赚了%@元",str] word:str];
    [shareImageView addSubview:label1];
    
    UILabel *label2 = [[UILabel alloc] init];
    label2.text = [JAUserInfo userInfo_getUserImfoWithKey:User_uuid];
    label2.textColor = HEX_COLOR(0xffffff);
    label2.font = JA_REGULAR_FONT(12);
    label2.textAlignment = NSTextAlignmentCenter;
    label2.width = shareImageView.width;
    label2.height = WIDTH_ADAPTER(17);
    label2.y = label1.bottom + WIDTH_ADAPTER(24);
    [shareImageView addSubview:label2];
    
}

- (void)caculator
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    self.imageView.centerX = self.width * 0.5;
    self.imageView.centerY = self.height * 0.5 - 30;
    
    self.closeButton.width = 50;
    self.closeButton.height = 50;
    self.closeButton.x = self.imageView.x;
    self.closeButton.y = self.imageView.y - 50;
    
    self.awardButton.width = self.imageView.width;
    self.awardButton.height = 33;
    self.awardButton.y = 140;
    
    self.label.width = self.imageView.width;
    self.label.height = 15;
    self.label.y = self.awardButton.bottom + 5;
    
    self.sureButton.width = 100;
    self.sureButton.height = 36;
    self.sureButton.centerX = self.imageView.width * 0.5;
    self.sureButton.y = self.label.bottom + 5;
    
    self.goShareButton.width = 220;
    self.goShareButton.height = 50;
    self.goShareButton.centerX = self.imageView.centerX;
    self.goShareButton.y = self.imageView.bottom;
    self.goShareButton.titleEdgeInsets = UIEdgeInsetsMake(0, -3, 3, 0);
    
}

- (void)setMethodType:(NSInteger)methodType
{
    _methodType = methodType;
    
    if (methodType == 1) {
        [self.goShareButton setTitle:@"去朋友圈晒收入奖励翻倍" forState:UIControlStateNormal];
    }else{
        [self.goShareButton setTitle:@"去QQ空间晒收入奖励翻倍" forState:UIControlStateNormal];
    }
}


- (void)setFlower:(NSInteger)flower
{
    _flower = flower;
    
    [self.awardButton setTitle:[NSString stringWithFormat:@" +%ld朵花",flower] forState:UIControlStateNormal];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculator];
}


- (void)closeSelf
{
    [self removeFromSuperview];
}


- (void)goToSharePicture   // 双倍分享
{
    if (self.shareImageView.image == nil) {
        [[UIApplication sharedApplication].delegate.window ja_makeToast:@"图片获取失败"];
        [self closeSelf];
        return;
    }
    
    [self sensorsAnalyticsWithShareMoney];
    // 设置代理
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    appDelegate.shareDelegate = self;
    
    // 获取最新的收入
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAUserApiRequest shareInstance] userExchangeInfo:dic success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        NSString *incomeM = [NSString stringWithFormat:@"%.2f", [result[@"flowermoney"][@"moneyCount"] floatValue]];
        NSString *expenditureM = [JAUserInfo userInfo_getUserImfoWithKey:User_expenditureMoney];
        NSString *str = [NSString stringWithFormat:@"%.2f",incomeM.floatValue + expenditureM.floatValue];
        self.label1.attributedText = [self attributedString:[NSString stringWithFormat:@"赚了%@元",str] word:str];
        
        // 生产图
        UIImage *shareImage = [self screenShotView:self.shareImageView];
        
        if (self.methodType == 1) {
            
            [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareImage:shareImage];
        }else{
            [JAPlatformShareManager qqShare:QQShareTypeZone shareImage:shareImage];
        }
        
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
         [self closeSelf];
    }];
    
}

- (void)wbShare:(int)code{}

- (void)qqShare:(NSString *)error
{
    [self closeSelf];
    
    if (error == nil) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"type"] = @"1";
        [[JAVoiceCommonApi shareInstance] voice_appShareIncomeWithParas:dic success:^(NSDictionary *result) {
            
        } failure:^(NSError *error) {
            
        }];
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
    }else{
        
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享失败"];
    }
}

- (void)wxShare:(int)code   // 分享收入 成功后才算完成任务
{
    [self closeSelf];
    if (code == 0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"type"] = @"1";
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
- (void)sensorsAnalyticsWithShareMoney
{
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_ShareButton] = @"分享翻倍";
    senDic[JA_Property_ImageUrl] = @"http://moli2017.oss-cn-zhangjiakou.aliyuncs.com/file/share001.png";
    senDic[JA_Property_SerialNumber] = @(1);
    [JASensorsAnalyticsManager sensorsAnalytics_clickShareMoney:senDic];
}
@end
