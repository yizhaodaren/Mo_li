//
//  JASignTaskView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/9/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JASignTaskView.h"
#import "XFStepView.h"
#import "JAUserApiRequest.h"
#import "JAPaddingLabel.h"
#import "JAVoicePersonApi.h"
#import "JAMoliJunTaskModel.h"
#import "JAPlatformShareManager.h"
#import "JAMoliJunRewardView.h"
#import <UIImage+GIF.h>

@interface JASignTaskView ()<PlatformShareDelegate>

@property (nonatomic, assign) BOOL signInfoSuccess;

@property (nonatomic, weak) UIView *topView;
@property (nonatomic, weak) UIImageView *imageView;  // 背景图片
@property (nonatomic, weak) UIButton *awardButton;  // 奖励按钮

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UILabel *label2;           // 今日已获得任务奖励：
@property (nonatomic, weak) UIButton *flowerButton;    // +100
@property (nonatomic, weak) UIButton *moneyButton;     // +2元

@property (nonatomic, strong) NSDictionary *packetDic;  // 红包
@property (nonatomic, strong) NSString *totayFlower;

@property (nonatomic, weak) UIImageView *moliJunImageView;  // 茉莉君任务图片
@property (nonatomic, weak) UIImageView *birdImageView;  // 有小鸟
@property (nonatomic, weak) UIImageView *noBirdImageView;  // 没有小鸟
@property (nonatomic, weak) UIImageView *calendarImgeView;  // 日历图片
@property (nonatomic, weak) UILabel *calendarLabel;  // 日历label
@property (nonatomic, weak) UIButton *bubblesButton;  // 气泡按钮
@property (nonatomic, weak) UILabel *countdownTimeLabel;  // 倒计时time
@property (nonatomic, weak) NSTimer *timer;  // 倒计时器

@property (nonatomic, strong) JAMoliJunTaskModel *moliJunModel;
@property (nonatomic, strong) NSString *moliJunCard;

@property (nonatomic, strong) JAMoliJunRewardView *moliJunView;  // 茉莉君奖励 弹窗
@end

@implementation JASignTaskView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSignTaskView];
        
        [self getMoliJunInfo];
        
//        [self getSignInfo];
        
        self.backgroundColor = HEX_COLOR(0xffffff);
    }
    return self;
}

- (void)setupSignTaskView
{
    
    UIView *topView = [[UIView alloc] init];
    _topView = topView;
    [self addSubview:topView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    imageView.image = [UIImage imageNamed:@"branch_mine_signBack"];
    imageView.clipsToBounds = YES;
    [topView addSubview:imageView];
    
    // 茉莉君背景图片
    UIImageView *moliJunImageView = [[UIImageView alloc] init];
    _moliJunImageView = moliJunImageView;
    moliJunImageView.image = [UIImage imageNamed:@"molijun_task"];
    moliJunImageView.clipsToBounds = YES;
    moliJunImageView.userInteractionEnabled = YES;
    [topView addSubview:moliJunImageView];
    
    // 茉莉君领取奖励的小鸟按钮
    UIImageView *birdImageView = [[UIImageView alloc] init];
    _birdImageView = birdImageView;
    birdImageView.hidden = YES;
    birdImageView.image = [UIImage imageNamed:@"molijun_task_bird"];
//    NSString *filePath_bird = [[NSBundle mainBundle] pathForResource:@"molijun_task_bird_ani" ofType:@"gif"];
//    NSData *imageData_bird = [NSData dataWithContentsOfFile:filePath_bird];
//    birdImageView.image = [UIImage sd_animatedGIFWithData:imageData_bird];
//    birdImageView.userInteractionEnabled = YES;
//    UITapGestureRecognizer *birdTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRewardMoliFlower)];
//    [birdImageView addGestureRecognizer:birdTap];
    [moliJunImageView addSubview:birdImageView];
    
    // 没有小鸟按钮
    UIImageView *noBirdImageView = [[UIImageView alloc] init];
    _noBirdImageView = noBirdImageView;
    noBirdImageView.image = [UIImage imageNamed:@"molijun_task_bird_no"];
    [moliJunImageView addSubview:noBirdImageView];

    // 茉莉君 日历图片
    UIImageView *calendarImgeView = [[UIImageView alloc] init];
    _calendarImgeView = calendarImgeView;
    NSArray *images = @[
                        [UIImage imageNamed:@"molijun_task_calendar_1"],
                        [UIImage imageNamed:@"molijun_task_calendar_2"],
                        ];
    calendarImgeView.animationImages = images;
    calendarImgeView.animationRepeatCount = 0;
    calendarImgeView.animationDuration = 2;
    [calendarImgeView startAnimating];
//    calendarImgeView.image = [UIImage imageNamed:@"molijun_task_calendar"];
    calendarImgeView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapCalendar = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBubblesButton)];
    [calendarImgeView addGestureRecognizer:tapCalendar];
    [moliJunImageView addSubview:calendarImgeView];
    
    // 茉莉君 日历数字（累计签到）
    UILabel *calendarLabel = [[UILabel alloc]init];
    _calendarLabel = calendarLabel;
    calendarLabel.text = @"0";
    calendarLabel.textAlignment = NSTextAlignmentCenter;
    calendarLabel.textColor = HEX_COLOR(0xF47960);
    CGAffineTransform matrix =CGAffineTransformMake(1, 0, tanf(-7 * (CGFloat)M_PI / 180), 1, 0, 0);//设置反射。倾斜角度。
    UIFontDescriptor *desc = [ UIFontDescriptor fontDescriptorWithName :[UIFont boldSystemFontOfSize:WIDTH_ADAPTER(16)].fontName matrix :matrix];
    calendarLabel.font = [UIFont fontWithDescriptor:desc size:WIDTH_ADAPTER(16)];
    [calendarImgeView addSubview:calendarLabel];
    
    // 茉莉君 累计签到 茉莉君陪伴气泡
    UIButton *bubblesButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _bubblesButton = bubblesButton;
    bubblesButton.hidden = YES;
    bubblesButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [bubblesButton setTitle:@"茉莉陪伴你已经0天了" forState:UIControlStateNormal];
    [bubblesButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
    bubblesButton.titleLabel.font = JA_REGULAR_FONT(9);
    [bubblesButton addTarget:self action:@selector(clickbubblesButton) forControlEvents:UIControlEventTouchUpInside];
    [moliJunImageView addSubview:bubblesButton];
    
    // 倒计时
//    UILabel *countdownTimeLabel = [[UILabel alloc]init];
//    _countdownTimeLabel = countdownTimeLabel;
//    countdownTimeLabel.text = @"00:00:00";
//    countdownTimeLabel.textColor = HEX_COLOR(0x7F3312);
//    countdownTimeLabel.font = JA_REGULAR_FONT(WIDTH_ADAPTER(9));
//    countdownTimeLabel.hidden = YES;
//    countdownTimeLabel.textAlignment = NSTextAlignmentCenter;
//    [moliJunImageView addSubview:countdownTimeLabel];
//    
    UIButton *awardButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _awardButton = awardButton;
    [awardButton setTitle:@"您有一份礼物,请查收" forState:UIControlStateSelected];
    [awardButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
    [awardButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0x6BD379)] forState:UIControlStateSelected];
    [awardButton setTitle:@"00:00:00" forState:UIControlStateNormal];
    [awardButton setTitleColor:HEX_COLOR(0xBCBCBC) forState:UIControlStateNormal];
    [awardButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xE1E1E1)] forState:UIControlStateNormal];
    awardButton.titleLabel.font = JA_MEDIUM_FONT(18);
    [awardButton addTarget:self action:@selector(showRewardMoliFlower) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:awardButton];
    
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    
    UILabel *label2 = [[UILabel alloc] init];
    _label2 = label2;
    label2.text = @"今日已获得任务奖励：";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = HEX_COLOR(JA_Title);
    label2.font = JA_LIGHT_FONT(12);
    [bottomView addSubview:label2];
    
    UIButton *flowerButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _flowerButton = flowerButton;
    [flowerButton setTitle:@"+0朵" forState:UIControlStateNormal];
    [flowerButton setImage:[UIImage imageNamed:@"branch_mine_flower_small"] forState:UIControlStateNormal];
    [flowerButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
    flowerButton.titleLabel.font = JA_LIGHT_FONT(12);
    flowerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [bottomView addSubview:flowerButton];
    
    UIButton *moneyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _moneyButton = moneyButton;
    [moneyButton setTitle:@"+0元" forState:UIControlStateNormal];
    [moneyButton setImage:[UIImage imageNamed:@"branch_mine_packet_small"] forState:UIControlStateNormal];
    [moneyButton setTitleColor:HEX_COLOR(JA_Title) forState:UIControlStateNormal];
    moneyButton.titleLabel.font = JA_LIGHT_FONT(12);
    moneyButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, -5);
    [bottomView addSubview:moneyButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorSignTaskFrame];
}


- (void)caculatorSignTaskFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = WIDTH_ADAPTER(378);
    
    self.topView.width = JA_SCREEN_WIDTH;
    self.topView.height = WIDTH_ADAPTER(370);
    
    self.imageView.frame = self.topView.bounds;
    
    // 茉莉君背景图片
    self.moliJunImageView.width = self.topView.width;
    self.moliJunImageView.height = WIDTH_ADAPTER(275);
    
    // 茉莉君领取奖励的小鸟按钮
    self.birdImageView.width = WIDTH_ADAPTER(85);
    self.birdImageView.height = WIDTH_ADAPTER(167);
    self.birdImageView.x = self.moliJunImageView.width - self.birdImageView.width;
    
    self.noBirdImageView.width = WIDTH_ADAPTER(85);
    self.noBirdImageView.height = WIDTH_ADAPTER(167);
    self.noBirdImageView.x = self.moliJunImageView.width - self.noBirdImageView.width;
    
    // 茉莉君 日历图片
    self.calendarImgeView.width = WIDTH_ADAPTER(150);
    self.calendarImgeView.height = WIDTH_ADAPTER(60);
    
    // 茉莉君 日历数字（累计签到）
    self.calendarLabel.width = WIDTH_ADAPTER(40);
    self.calendarLabel.height = WIDTH_ADAPTER(30);
    self.calendarLabel.centerX = WIDTH_ADAPTER(62);
    self.calendarLabel.centerY = WIDTH_ADAPTER(38);


    // 茉莉君 累计签到 茉莉君陪伴气泡
    self.bubblesButton.width = 150;
    self.bubblesButton.height = 9;
    self.bubblesButton.x = 18;
    self.bubblesButton.y = self.calendarImgeView.bottom;
    
    // 倒计时
    self.countdownTimeLabel.width = WIDTH_ADAPTER(45);
    self.countdownTimeLabel.height = WIDTH_ADAPTER(13);
    self.countdownTimeLabel.centerX = self.moliJunImageView.width - WIDTH_ADAPTER(21) - self.countdownTimeLabel.width * 0.5;
    self.countdownTimeLabel.y = WIDTH_ADAPTER(64);
    
    self.awardButton.width = WIDTH_ADAPTER(300);
    self.awardButton.height = WIDTH_ADAPTER(40);
    self.awardButton.centerX = self.topView.width * 0.5;
    self.awardButton.y = self.moliJunImageView.bottom + 10;
    self.awardButton.layer.cornerRadius = self.awardButton.height * 0.5;
    self.awardButton.layer.masksToBounds = YES;
    
    self.bottomView.width = JA_SCREEN_WIDTH;
    self.bottomView.height = WIDTH_ADAPTER(20);
    self.bottomView.y = self.height - self.bottomView.height;
    
    [self.label2 sizeToFit];
    self.label2.centerY = self.bottomView.height * 0.5;
    self.label2.x = 15;
    
    [self.flowerButton sizeToFit];
    self.flowerButton.centerY = self.label2.centerY;
    self.flowerButton.x = self.label2.right + 2;
    
    [self.moneyButton sizeToFit];
    self.moneyButton.centerY = self.flowerButton.centerY;
    self.moneyButton.x = self.flowerButton.right + 20;
}

- (JAMoliJunRewardView *)moliJunView
{
    if (_moliJunView == nil) {
        
        _moliJunView = [[JAMoliJunRewardView alloc] init];
        [_moliJunView.receiveButton addTarget:self action:@selector(receiveMoliJunReward:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _moliJunView;
}
#pragma mark - 定时器
- (NSTimer *)timer
{
    if (_timer == nil) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(animiateCountDownTime) userInfo:nil repeats:YES];
    }

    return _timer;
}

- (void)invalidateTime
{
    [self.timer invalidate];
    self.timer = nil;
}

- (void)animiateCountDownTime
{
    NSString *text = [self getRefreshDate:self.moliJunModel.receiveTime.doubleValue];
    if (text.length) {
        self.countdownTimeLabel.hidden = NO;
        self.countdownTimeLabel.text = text;
        [self.awardButton setTitle:text forState:UIControlStateNormal];
    }else{
        [self.timer invalidate];
        self.timer = nil;
        self.countdownTimeLabel.hidden = NO;
        self.countdownTimeLabel.text = @"查 收";
        self.awardButton.selected = YES;
        // 刷新茉莉君界面
        [self getMoliJunInfo];
    }
}

#pragma mark - 领取茉莉君奖励
- (void)receiveMoliJunReward:(UIButton *)button
{
    self.moliJunView.receiveButton.userInteractionEnabled = NO;
    // 设置代理
    AppDelegate *appDelegate = [AppDelegate sharedInstance];
    appDelegate.shareDelegate = self;
    [JAPlatformShareManager wxShare:WeiXinShareTypeSession shareImageWithUrlString:self.moliJunCard];
    
}

#pragma mark - 展示茉莉君的奖励 分享双倍
- (void)showRewardMoliFlower
{
    if (self.awardButton.selected == NO) {
        return;
    }
    [MBProgressHUD showMessage:nil];
    self.birdImageView.userInteractionEnabled = NO;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"type"] = @"0";
    [[JAVoicePersonApi shareInstance] voice_getMoliJunReward:dic success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        // 展示奖励弹窗
        self.moliJunView.flower = self.moliJunModel.flower;
        [[UIApplication sharedApplication].delegate.window addSubview:self.moliJunView];
        
        // 领取成功
        [self getMoliJunInfo];
        
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        self.birdImageView.userInteractionEnabled = YES;
        [[UIApplication sharedApplication].delegate.window ja_makeToast:error.localizedDescription];
    }];
    
}

#pragma mark - 分享监听
- (void)qqShare:(NSString *)error
{
}
- (void)wbShare:(int)code
{
}
- (void)wxShare:(int)code   // 分享收入 成功后才算完成任务
{
    if (code == 0) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"分享成功"];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
        dic[@"type"] = @"1";
        [[JAVoicePersonApi shareInstance] voice_getMoliJunReward:dic success:^(NSDictionary *result) {
            [self.moliJunView removeFromSuperview];
        } failure:^(NSError *error) {
            self.moliJunView.receiveButton.userInteractionEnabled = YES;
            [[UIApplication sharedApplication].delegate.window ja_makeToast:@"服务器开小差了，请重新分享"];
        }];
    }else
    {
        self.moliJunView.receiveButton.userInteractionEnabled = YES;
        if (code == -1) {
            
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
}

#pragma mark - 倒计时
- (NSString *)getRefreshDate:(CGFloat)timeDouble
{
    timeDouble = timeDouble/1000.0;   // 服务器 秒
    NSTimeInterval now = [[NSDate date]timeIntervalSince1970];  // 当前时间 秒
    double time = now - timeDouble;  // 两者时间差
    
    double totleTime = 4 * 60 * 60;  // 测试服 30
    
    double residueTime = totleTime - time;
    
    if (residueTime > 0) {
        //format of hour
        NSString *str_hour = [NSString stringWithFormat:@"%02ld",(NSInteger)residueTime/3600];
        //format of minute
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",((NSInteger)residueTime%3600)/60];
        //format of second
        NSString *str_second = [NSString stringWithFormat:@"%02ld",(NSInteger)residueTime%60];
        //format of time
        NSString *str = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];

        return str;
    }else{
        return nil;
    }
}

//隐藏累计签到气泡
- (void)clickbubblesButton
{
    self.bubblesButton.hidden = YES;
}
//展示累计签到气泡
- (void)showBubblesButton
{
    self.bubblesButton.hidden = !self.bubblesButton.hidden;
}

#pragma mark - 获取网络请求
- (void)getMoliJunInfo
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    [[JAVoicePersonApi shareInstance] voice_getMoliJunTask:dic success:^(NSDictionary *result) {

        JAMoliJunTaskModel *model = [JAMoliJunTaskModel mj_objectWithKeyValues:result];
        self.moliJunModel = model;
        if (!self.moliJunCard.length) {
            self.moliJunCard = self.moliJunModel.postcard;
        }
        self.calendarLabel.text = [NSString stringWithFormat:@"%@",model.activecount];
        
        NSString *str = [NSString stringWithFormat:@"茉莉陪伴你已经%@天了",model.activecount];
        [self.bubblesButton setTitle:str forState:UIControlStateNormal];
        [self.moliJunImageView ja_setImageWithURLStr:model.onhook.image placeholder:[UIImage imageNamed:@"molijun_task"]];
        if (model.onhook.onhookId.integerValue == 4) {
            [self timer]; // 旅行中开启定时器
            self.birdImageView.hidden = YES;
            self.noBirdImageView.hidden = NO;
            self.awardButton.selected = NO;
        }else{
            self.birdImageView.userInteractionEnabled = YES;
            self.birdImageView.hidden = NO;
            self.noBirdImageView.hidden = YES;
            [self.timer invalidate];
            self.timer = nil;
            self.countdownTimeLabel.hidden = NO;
            self.countdownTimeLabel.text = @"查 收";
            self.awardButton.selected = YES;
        }
    } failure:^(NSError *error) {
        
    }];
}

- (void)setFlowerString:(NSString *)flowerString
{
    _flowerString = flowerString;
    [self.flowerButton setTitle:[NSString stringWithFormat:@"+%@朵",flowerString] forState:UIControlStateNormal];
    [self.flowerButton sizeToFit];
}

- (void)setMoneyString:(NSString *)moneyString
{
    _moneyString = moneyString;
    [self.moneyButton setTitle:[NSString stringWithFormat:@"+%@元",moneyString] forState:UIControlStateNormal];
    [self.moneyButton sizeToFit];
}
@end
