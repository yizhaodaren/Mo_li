//

//  Jasmine
//
//  Created by moli-2017 on 2017/9/8.
//  Copyright © 2017年 xujin. All rights reserved.
/*
    首页签到弹窗
 */

#import "JAHomeSignView.h"
#import "XFStepView.h"
#import "JARedPacketView.h"
#import "JAPaddingLabel.h"
#import "JAHomeFloatActivityView.h"
#import "JAPacketNotiMsgAnimateView.h"
#import "CYLTabBarController.h"
#import "JAHomeSignStepCell.h"
#import "JASignShowView.h"

#import "JAVoiceCommonApi.h"
#import "JAUserApiRequest.h"

#import "JAActivityFloatModel.h"

@interface JAHomeSignView ()

@property (nonatomic, strong) NSDictionary *packetDic;  // 红包
@property (nonatomic, strong) NSDictionary *signInfoDic;  // 签到信息
@property (nonatomic, strong) NSMutableArray *dataSourceArray;  // 数据源（根据签到信息算出来）

@property (nonatomic, weak) UIView *backView;     // 签到背景容器
@property (nonatomic, weak) UIImageView *topMiddleImageView; // 顶部图片
@property (nonatomic, weak) UIImageView *topImageView;
@property (nonatomic, weak) UILabel *signCountLabel;  // 连续签到天数
@property (nonatomic, weak) UILabel *awardFlowerLabel;  // 今日奖励花
@property (nonatomic, weak) UIImageView *awardMoneyImageView;  // 今日奖励钱
@property (nonatomic, weak) UILabel *tomorrowLabel;  // 明日奖励
@property (nonatomic, weak) UIButton *sureButton;   // 关闭/打开红包

@property (nonatomic, weak) JASignShowView *signShowView;  // 签到天数view

@end

@implementation JAHomeSignView

+ (instancetype)shareHomeSignView
{
    static JAHomeSignView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[JAHomeSignView alloc] init];
        }
    });
    return instance;
}

#pragma mark - 获取用户签到信息
- (void)homeSign_getUserSignInfo
{
    if ([JAConfigManager shareInstance].isDebug.integerValue == 1 ||
        [[JAUserInfo userInfo_getUserImfoWithKey:User_id] isEqualToString:@"7031"]) {
        self.hidden = YES;
        return;
    }
    // 请求接口获取签到信息
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    [[JAUserApiRequest shareInstance] userSignInfo:dic success:^(NSDictionary *result) {
        [JAConfigManager shareInstance].signState = [result[@"hashmap"][@"user"][@"isSign"] integerValue];
        
        if ([JAConfigManager shareInstance].signState == 0) {
            // 开始签到
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
            [[JAUserApiRequest shareInstance] userSign:dic success:^(NSDictionary *result) {
                 NSArray *arr = result[@"propertyList"];
                if (arr.count) {
                    NSDictionary *dic = arr.firstObject;
                    self.packetDic = @{
                                       @"money" : dic[@"propertyNum"],
                                       @"type" : dic[@"operationType"],
                                       @"id" : dic[@"id"]
                                       };
                }
                [self homeSign_getUserSignInfo];
            } failure:^(NSError *error) {
                self.hidden = YES;
            }];
        }else{
            
            BOOL isToday = [self checkIsToday];
            // 弹出签到
            if (!isToday) { // !isToday
                self.signInfoDic = result;  // 展示签到步数
                self.hidden = NO;
            }else{
                // 弹出活动
                [self homeSign_getActivityFloat:isToday];
            }
        }
    } failure:^(NSError *error) {
        self.hidden = YES;
    }];
}

#pragma mark - 获取活动信息
- (void)homeSign_getActivityFloat:(BOOL)isToday
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"platform"] = @"IOS";
    // 获取活动弹窗数据
    [[JAVoiceCommonApi shareInstance] voice_activityFloat:dic success:^(NSDictionary *result) {
        
        // 1 解析数据
        NSArray *modelArray = [JAActivityFloatModel mj_objectArrayWithKeyValuesArray:result[@"alertList"]];
        
        // 3 如果有数据 - 启动活动弹层
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            if (!isToday) {   // 不是同一天 直接清除老的表
                // 先清除缓存 清除弹层时间
                NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
                NSString *key = [NSString stringWithFormat:@"%@_%@",uid,@"activityMaginTime"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
                [LKDBHelper clearTableData:[JAActivityFloatModel class]];
                // 3.1.1  遍历模型数组 存入库
                for (NSInteger i = 0; i < modelArray.count; i++) {

                    JAActivityFloatModel *model = modelArray[i];
                    [model saveToDB];
                }
            }else{  // 是同一天
                
                NSArray *storeActivity = [JAActivityFloatModel searchWithWhere:nil];
                // 先清除缓存
                [LKDBHelper clearTableData:[JAActivityFloatModel class]];
                
                // 3.1.2  遍历模型数组 从storeActivity中获取已经存在的模型更新状态
                for (NSInteger i = 0; i < modelArray.count; i++) {
                    
                    JAActivityFloatModel *model = modelArray[i];
                    JAActivityFloatModel *m = [self checkContainObj:model array:storeActivity];
                    if (m) {
                        model.floatState = m.floatState;
                    }
                    // 插入数据库
                    [model saveToDB];
                }
            }
            
            // 如果在间隔时间内不弹层
            JAActivityFloatModel *randomM = modelArray.firstObject;
            NSTimeInterval floatTime = [self storeTimeMargin:(randomM.time * 60.0)];
            if (!floatTime) {  // 在时间间隔内
                return;
            }else{
                // 存储弹窗时间
                NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
                NSString *key = [NSString stringWithFormat:@"%@_%@",uid,@"activityMaginTime"];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%f",floatTime] forKey:key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            
            // 3.2 开始弹窗
            // 查询数据库（权重倒序）
            NSArray *activityArr = [JAActivityFloatModel searchWithWhere:nil orderBy:@"sort desc" offset:0 count:0];
            
            JAActivityFloatModel *model = activityArr.firstObject;  // 需要弹出的model
            
            for (NSInteger i = 0; i < activityArr.count; i++) {
                
                // 查出第一条未弹状态的的activity
                JAActivityFloatModel *activityModel = activityArr[i];
                if (activityModel.floatState == 0) {
                    
                    model = activityModel;
                    
                    // 修改这个model的弹出状态 - 并更新数据库
                    activityModel.floatState = 1;
                    [activityModel updateToDB];
                    
                    // 如果是最后一条 清空库里面的所有活动状态
                    if (i == activityArr.count - 1) {
                        
                        // 把库里面所有的弹出状态重置
                        [JAActivityFloatModel updateToDBWithSet:@"floatState='0'" where:@"floatState='1'"];
                    }
                    break;
                }
            }
            
            // 回到主线程弹出
            dispatch_async(dispatch_get_main_queue(), ^{
                // 弹出model;
                if (model) {
                    [JAHomeFloatActivityView showFloatActivity:model];
                }
            });
        });
    } failure:^(NSError *error) {
       
    }];
    
    // 获取红包
    [[JAPacketNotiMsgAnimateView PacketNotiMsgAnimateView] homePage_getPacketCountAndAnimate];
}


// 检查是否是今天
- (BOOL)checkIsToday
{
    NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    
    NSString *todaysignDateKey = [NSString stringWithFormat:@"%@%@",uid,@"todaysignDate"];
    NSString *storeStr = [[NSUserDefaults standardUserDefaults] objectForKey:todaysignDateKey]; // 获取存储的本地时间
    
    NSDate *senddate=[NSDate date];  // 获取今天时间
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYY-MM-dd"];
    NSString *timeStr = [dateformatter stringFromDate:senddate];
    
    NSString *locationTodayString=[NSString stringWithFormat:@"%@-%@",uid,timeStr]; // 今天的标记
    
    if (![locationTodayString isEqualToString:storeStr]) {  // 不是同一天
        
        [[NSUserDefaults standardUserDefaults] setObject:locationTodayString forKey:todaysignDateKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return NO;
    }
    
    return YES;
}

// 存储弹层的时间
- (NSTimeInterval)storeTimeMargin:(double)marginTime
{
    // 当前时间
    NSDate *senddate=[NSDate date];
    // 当前时间戳
    NSTimeInterval timeSecond = [senddate timeIntervalSince1970];
    
    // 获取存储的本地时间戳
    NSString *uid = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    NSString *key = [NSString stringWithFormat:@"%@_%@",uid,@"activityMaginTime"];
    NSString *dateString = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
    double dateSecond = [dateString doubleValue];
    double frontSecond = dateSecond + marginTime;
    
    // 判断时间是不是超过时间间隔
    if (timeSecond >= frontSecond) {  // 超过了时间间隔
        return timeSecond;
    }
    
    return 0;
}

// 检查模型是否在数组中
- (JAActivityFloatModel *)checkContainObj:(JAActivityFloatModel *)model array:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++) {
        
        JAActivityFloatModel *m = array[i];
        if ([m.floatId isEqualToString:model.floatId]) {
            return m;
        }
    }
    return nil;
}

#pragma mark - 点击事件
- (void)sureButtonClick:(UIButton *)btn
{
    if (self.awardMoneyImageView.hidden == NO) {
        [self openPacket];
        self.hidden = YES;
    }else{
        // 3.0.2弹出活动逻辑
        [self homeSign_getActivityFloat:[self checkIsToday]];
        self.hidden = YES;
    }
}

// 开启7天红包
- (void)openPacket
{
    if (self.packetDic == nil) {
        return;
    }
    // 传递红包类型
    JARedPacketView *packet = [[JARedPacketView alloc] init];
    packet.packetDic = self.packetDic;
    
    @WeakObj(self);
    packet.unOpenClose = ^{
        @StrongObj(self);
        // 点击了未开红包 - 弹出活动
        [self homeSign_getActivityFloat:[self checkIsToday]];
    };
    
    packet.openClose = ^(BOOL isClose) {
        @StrongObj(self);
        self.packetDic = nil;
        if (isClose) {
            // 点击了未开红包 - 弹出活动
            [self homeSign_getActivityFloat:[self checkIsToday]];
        }
    };
    [[self cyl_tabBarController].view addSubview:packet];
}

#pragma mark - 展示签到步数
- (void)setSignInfoDic:(NSDictionary *)signInfoDic
{
    _signInfoDic = signInfoDic;
    
    // 计算需要展示的天数
    NSInteger totalCount = [signInfoDic[@"hashmap"][@"user"][@"signCount"] integerValue];
    NSArray *flowerArray = signInfoDic[@"hashmap"][@"signArray"];
    if (totalCount <= 0) {
        self.hidden = YES;
        return;
    }
    
    if (totalCount % 7 == 0) {
        self.awardFlowerLabel.hidden = YES;
        self.awardMoneyImageView.hidden = NO;
    }else{
        self.awardFlowerLabel.hidden = NO;
        self.awardMoneyImageView.hidden = YES;
    }
    
    NSString *awardStringKey = nil;
    if (totalCount <= flowerArray.count) {
        awardStringKey = [NSString stringWithFormat:@"%@",flowerArray[totalCount - 1]];
    }else{
        awardStringKey = [NSString stringWithFormat:@"%@",flowerArray.lastObject];
    }
    
    NSString *awardString = [NSString stringWithFormat:@"+%@朵",awardStringKey];
    [self.awardFlowerLabel setAttributedText:[self attributedString:awardString word:awardStringKey]];
    
    self.signShowView.dayLabel1.text = [NSString stringWithFormat:@"第%ld天",totalCount];
    [self.signShowView.dayLabel1 sizeToFit];
    self.signShowView.dayLabel2.text = [NSString stringWithFormat:@"第%ld天",totalCount+1];
    [self.signShowView.dayLabel2 sizeToFit];
    self.signShowView.dayLabel3.text = [NSString stringWithFormat:@"第%ld天",totalCount+2];
    [self.signShowView.dayLabel3 sizeToFit];
    
    self.signShowView.awardLabel1.text = [self getShowInfo:totalCount flowerArray:flowerArray];
    [self.signShowView.awardLabel1 sizeToFit];
    self.signShowView.awardLabel2.text = [self getShowInfo:totalCount+1 flowerArray:flowerArray];
    [self.signShowView.awardLabel2 sizeToFit];
    self.signShowView.awardLabel3.text = [self getShowInfo:totalCount+2 flowerArray:flowerArray];
    [self.signShowView.awardLabel3 sizeToFit];

    NSString *tt = [NSString stringWithFormat:@"连续登录%ld天",totalCount];
    self.signCountLabel.text = tt;

    NSString *bottomT = [NSString stringWithFormat:@"%@",signInfoDic[@"hashmap"][@"user"][@"signInfo"]];
    if (bottomT.length && ![bottomT isEqualToString:@"(null)"]) {
        bottomT = [bottomT stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        bottomT = [bottomT stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        self.tomorrowLabel.text = bottomT;
    }
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (NSString *)getShowInfo:(NSInteger)totalCount flowerArray:(NSArray *)flowerArray
{
    NSString *awardString = nil;
    if (totalCount % 7 == 0) {
        awardString = @"+拼手气红包";
    }else if (totalCount <= flowerArray.count) {
        awardString = [NSString stringWithFormat:@"+%@朵茉莉花",flowerArray[totalCount - 1]];
    }else{
        awardString = [NSString stringWithFormat:@"+%@朵茉莉花",flowerArray.lastObject];
    }
    
    return awardString;
}

- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    [attr addAttribute:NSFontAttributeName value:JA_MEDIUM_FONT(100) range:rang];
    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xEEB85F) range:rang];
//    [attr addAttribute:NSFontAttributeName value:JA_MEDIUM_FONT(14) range:NSMakeRange(0, rang.location)];
//    [attr addAttribute:NSFontAttributeName value:JA_MEDIUM_FONT(14) range:NSMakeRange(attr.length - 1, 1)];
//
//    [attr addAttribute:NSBaselineOffsetAttributeName value:@(0.36 * (36 - 14)) range:NSMakeRange(0, rang.location)];
//    [attr addAttribute:NSBaselineOffsetAttributeName value:@(0.36 * (36 - 14)) range:NSMakeRange(attr.length - 1, 1)];
    return attr;
}

#pragma mark - UI
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHomeSignUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    }
    return self;
}

- (void)setupHomeSignUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    [self addSubview:backView];
    
    JASignShowView *signShowView = [[JASignShowView alloc] init];
    _signShowView = signShowView;
    signShowView.backgroundColor = HEX_COLOR(0xffffff);
    [backView addSubview:signShowView];
    
    UIImageView *topImageView = [[UIImageView alloc] init];
    _topImageView = topImageView;
    topImageView.backgroundColor = HEX_COLOR(0xE8F9E5);
    [backView addSubview:topImageView];
    
    UILabel *signCountLabel = [[UILabel alloc] init];
    _signCountLabel = signCountLabel;
    signCountLabel.text = @"连续登录1天";
    signCountLabel.textColor = HEX_COLOR(0x009465);
    signCountLabel.font= JA_REGULAR_FONT(24);
    signCountLabel.textAlignment = NSTextAlignmentRight;
    [backView addSubview:signCountLabel];
    
    UILabel *awardFlowerLabel = [[UILabel alloc] init];
    _awardFlowerLabel = awardFlowerLabel;
    awardFlowerLabel.text = @" ";
    awardFlowerLabel.textColor = HEX_COLOR(0x009465);
    awardFlowerLabel.font = JA_MEDIUM_FONT(24);
    [backView addSubview:awardFlowerLabel];
    
    UIImageView *awardMoneyImageView = [[UIImageView alloc] init];
    _awardMoneyImageView = awardMoneyImageView;
    awardMoneyImageView.image = [UIImage imageNamed:@"branch_home_signTopPacket"];
    [backView addSubview:awardMoneyImageView];
    
    UILabel *tomorrowLabel = [[UILabel alloc] init];
    _tomorrowLabel = tomorrowLabel;
    tomorrowLabel.text = @"明天登录获得0朵茉莉花";
    tomorrowLabel.textColor = HEX_COLOR(0x009268);
    tomorrowLabel.font= JA_REGULAR_FONT(14);
    tomorrowLabel.textAlignment = NSTextAlignmentCenter;
    [backView addSubview:tomorrowLabel];
    
    UIImageView *topMiddleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_home_signTop"]];
    _topMiddleImageView = topMiddleImageView;
    [self addSubview:topMiddleImageView];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _sureButton = sureButton;
    [sureButton setImage:[UIImage imageNamed:@"activity_float_close"] forState:UIControlStateNormal];
    [sureButton addTarget:self action:@selector(sureButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:sureButton];
    
    self.hidden = YES;
    [[self cyl_tabBarController].view addSubview:self];
    self.dataSourceArray = [NSMutableArray array];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorHomeSignFrame];
}

- (void)caculatorHomeSignFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    self.backView.width = 300;
    self.backView.height = 280 + 119;
    self.backView.centerX = self.width * 0.5;
    self.backView.centerY = self.height * 0.5;
    
    self.topImageView.width = self.backView.width;
    self.topImageView.height = 280;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.topImageView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.topImageView.bounds;
    maskLayer.path = maskPath.CGPath;
    self.topImageView.layer.mask = maskLayer;
    
    [self.signCountLabel sizeToFit];
    self.signCountLabel.height = 33;
    self.signCountLabel.centerX = self.backView.width * 0.5;
    self.signCountLabel.y = 58;
    
    [self.awardFlowerLabel sizeToFit];
    self.awardFlowerLabel.height = 109;
    self.awardFlowerLabel.centerX = self.backView.width * 0.5;
    self.awardFlowerLabel.y = self.signCountLabel.bottom + 15;
    
    self.awardMoneyImageView.width = 83;
    self.awardMoneyImageView.height = 109;
    self.awardMoneyImageView.centerX = self.backView.width * 0.5;
    self.awardMoneyImageView.y = self.signCountLabel.bottom + 15;
    
    self.tomorrowLabel.width = self.backView.width;
    self.tomorrowLabel.height = 20;
    self.tomorrowLabel.y = self.awardFlowerLabel.bottom + 20;
    
    self.signShowView.width = self.backView.width;
    self.signShowView.height = 130;
    self.signShowView.y = self.topImageView.bottom - 10;
    self.signShowView.layer.cornerRadius = 10;
    self.signShowView.layer.masksToBounds = YES;
    
    self.sureButton.width = 40;
    self.sureButton.height = 40;
    self.sureButton.x = self.backView.right - self.sureButton.width;
    self.sureButton.y = self.backView.y - 23 - self.sureButton.height;
    
    self.topMiddleImageView.width = 122;
    self.topMiddleImageView.height = 92;
    self.topMiddleImageView.centerX = self.width * 0.5;
    self.topMiddleImageView.centerY = self.backView.y - 10;
}

@end
