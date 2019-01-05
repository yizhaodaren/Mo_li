//
//  JAInviteFriendView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/5.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAInviteFriendView.h"
#import "JAPlatformShareManager.h"
#import "JAUserApiRequest.h"

@interface JAInviteFriendView ()

@property (nonatomic, strong) UIView *floatView1;  // 去唤醒
@property (nonatomic, strong) UIButton *closeutton1;  // 关闭
@property (nonatomic, strong) UILabel *label1;    // 唤醒好友
@property (nonatomic, strong) UILabel *label2;  // 马上发消息唤醒Ta
@property (nonatomic, strong) UIView *view1;  // 框
@property (nonatomic, strong) UILabel *label3;  //  师父给你送来了300茉莉花，点击立即领取，限时福利！
@property (nonatomic, strong) UILabel *label4;  // 点击下面的按钮分享给
@property (nonatomic, strong) UIButton *button1;   // 微信好友
@property (nonatomic, strong) UIButton *button2;   // QQ好友

@property (nonatomic, strong) UIView *floatView2;  // 唤醒好友规则
@property (nonatomic, strong) UIButton *othercloseutton1;  // 关闭
@property (nonatomic, strong) UIImageView *imageView;  // 图片
@property (nonatomic, strong) UILabel *otherlabel1;  // 唤醒徒弟活动
@property (nonatomic, strong) UILabel *otherlabel2;  // 成功唤醒徒弟后，师父得....
@property (nonatomic, strong) UIView *otherview1;  // 框
@property (nonatomic, strong) UITextView *otherTextView;  // TextView
@property (nonatomic, strong) UIButton *otherbutton1;   // 立即参与

@end

@implementation JAInviteFriendView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFriendUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    }
    return self;
}

- (void)setupFriendUI
{
    // 唤醒规则
    self.floatView2 = [[UIView alloc] init];
    self.floatView2.backgroundColor = [UIColor whiteColor];
    self.floatView2.hidden = YES;
    [self addSubview:self.floatView2];
    
    self.othercloseutton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.othercloseutton1 setImage:[UIImage imageNamed:@"mine_invite_close"] forState:UIControlStateNormal];
    self.othercloseutton1.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.othercloseutton1 addTarget:self action:@selector(clickCloseButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView2 addSubview:self.othercloseutton1];
    
    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invite_call_T"]];
    self.imageView.hidden = YES;
    [self addSubview:self.imageView];
    
    self.otherlabel1 = [[UILabel alloc] init];
    self.otherlabel1.text = @"唤醒徒弟活动";
    self.otherlabel1.textColor = HEX_COLOR(0xffffff);
    self.otherlabel1.font = JA_REGULAR_FONT(WIDTH_ADAPTER(20));
    [self.imageView addSubview:self.otherlabel1];
    
    self.otherlabel2 = [[UILabel alloc] init];
    self.otherlabel2.text = @" ";
    self.otherlabel2.textColor = HEX_COLOR(0x4A4A4A);
    self.otherlabel2.font = JA_REGULAR_FONT(WIDTH_ADAPTER(20));
    self.otherlabel2.numberOfLines = 0;
    [self.floatView2 addSubview:self.otherlabel2];
    
    self.otherview1 = [[UIView alloc] init];
    self.otherview1.backgroundColor = HEX_COLOR(0xF9F9F9);
    [self.floatView2 addSubview:self.otherview1];
    
    self.otherTextView = [[UITextView alloc] init];
    self.otherTextView.text = @" ";
    self.otherTextView.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.otherTextView.font = JA_REGULAR_FONT(WIDTH_ADAPTER(14));
    self.otherTextView.backgroundColor = [UIColor clearColor];
    self.otherTextView.editable = NO;
    [self.otherview1 addSubview:self.otherTextView];
    
    self.otherbutton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.otherbutton1 setTitle:@"立即参与" forState:UIControlStateNormal];
    [self.otherbutton1 setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    self.otherbutton1.backgroundColor = HEX_COLOR(JA_Green);
    self.otherbutton1.titleLabel.font = JA_REGULAR_FONT(WIDTH_ADAPTER(18));
    [self.otherbutton1 addTarget:self action:@selector(clickCloseButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView2 addSubview:self.otherbutton1];
    
    // 去唤醒
    self.floatView1 = [[UIView alloc] init];
    self.floatView1.backgroundColor = [UIColor whiteColor];
    self.floatView1.hidden = YES;
    [self addSubview:self.floatView1];
    
    self.closeutton1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeutton1 setImage:[UIImage imageNamed:@"mine_invite_close"] forState:UIControlStateNormal];
    self.closeutton1.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.closeutton1 addTarget:self action:@selector(clickCloseButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView1 addSubview:self.closeutton1];
    
    self.label1 = [[UILabel alloc] init];
    self.label1.text = @"唤醒好友";
    self.label1.textColor = HEX_COLOR(0x000000);
    self.label1.font = JA_MEDIUM_FONT(WIDTH_ADAPTER(20));
    [self.floatView1 addSubview:self.label1];
    
    self.label2 = [[UILabel alloc] init];
    self.label2.text = @"马上发消息唤醒Ta";
    self.label2.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.label2.font = JA_REGULAR_FONT(WIDTH_ADAPTER(14));
    [self.floatView1 addSubview:self.label2];
    
    self.view1 = [[UIView alloc] init];
    self.view1.backgroundColor = HEX_COLOR(0xF9F9F9);
    [self.floatView1 addSubview:self.view1];
    
    self.label3 = [[UILabel alloc] init];
    self.label3.text = @"师父给你送来了300茉莉花，点击立即领取，限时福利！";
    self.label3.textColor = HEX_COLOR(0x4A4A4A);
    self.label3.font = JA_REGULAR_FONT(WIDTH_ADAPTER(15));
    self.label3.numberOfLines = 0;
    [self.view1 addSubview:self.label3];
    
    self.label4 = [[UILabel alloc] init];
    self.label4.text = @"点击下面的按钮分享给";
    self.label4.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.label4.font = JA_REGULAR_FONT(WIDTH_ADAPTER(14));
    [self.floatView1 addSubview:self.label4];
    
    self.button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button1 setImage:[UIImage imageNamed:@"invite_call_wx"] forState:UIControlStateNormal];
    [self.button1 addTarget:self action:@selector(clickButton1:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView1 addSubview:self.button1];
    
    self.button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button2 setImage:[UIImage imageNamed:@"invite_call_qq"] forState:UIControlStateNormal];
    [self.button2 addTarget:self action:@selector(clickButton2:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView1 addSubview:self.button2];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    // 唤醒规则
    self.floatView2.width = WIDTH_ADAPTER(340);
    self.floatView2.height = WIDTH_ADAPTER(460);
    self.floatView2.centerX = self.width * 0.5;
    self.floatView2.centerY = self.height * 0.5;
    self.floatView2.layer.cornerRadius = 5;
    self.floatView2.layer.masksToBounds = YES;
    
    self.othercloseutton1.width = 16;
    self.othercloseutton1.height = 16;
    self.othercloseutton1.x = self.floatView2.width - 16 - 15;
    self.othercloseutton1.y = 15;
    
    self.imageView.width = WIDTH_ADAPTER(204);
    self.imageView.height = WIDTH_ADAPTER(50);
    self.imageView.centerX = self.width * 0.5;
    self.imageView.y = self.floatView2.y - WIDTH_ADAPTER(15);
    
    [self.otherlabel1 sizeToFit];
    self.otherlabel1.height = WIDTH_ADAPTER(28);
    self.otherlabel1.centerX = self.imageView.width * 0.5;
    self.otherlabel1.centerY = self.imageView.height * 0.5;
    
    self.otherlabel2.width = self.floatView2.width - 2 * WIDTH_ADAPTER(22);
    [self.otherlabel2 sizeToFit];
    self.otherlabel2.x = WIDTH_ADAPTER(22);
    self.otherlabel2.y = WIDTH_ADAPTER(65);
    
    self.otherview1.width = WIDTH_ADAPTER(300);
    self.otherview1.height = WIDTH_ADAPTER(200);
    self.otherview1.x = WIDTH_ADAPTER(20);
    self.otherview1.y = self.otherlabel2.bottom + WIDTH_ADAPTER(22);
    
    self.otherTextView.width = self.otherview1.width - 2 * WIDTH_ADAPTER(12);
    self.otherTextView.height = self.otherview1.height - 2 * WIDTH_ADAPTER(14);
    self.otherTextView.x = WIDTH_ADAPTER(12);
    self.otherTextView.y = WIDTH_ADAPTER(14);
    
    self.otherbutton1.width = WIDTH_ADAPTER(260);
    self.otherbutton1.height = WIDTH_ADAPTER(45);
    self.otherbutton1.centerX = self.floatView2.width * 0.5;
    self.otherbutton1.y = self.otherview1.bottom + WIDTH_ADAPTER(19);
    self.otherbutton1.layer.cornerRadius = self.otherbutton1.height * 0.5;
    
    // 去唤醒
    self.floatView1.width = WIDTH_ADAPTER(340);
    self.floatView1.height = WIDTH_ADAPTER(362);
    self.floatView1.centerX = self.width * 0.5;
    self.floatView1.centerY = self.height * 0.5;
    self.floatView1.layer.cornerRadius = 5;
    self.floatView1.layer.masksToBounds = YES;
    
    self.closeutton1.width = 16;
    self.closeutton1.height = 16;
    self.closeutton1.x = self.floatView1.width - 16 - 15;
    self.closeutton1.y = 15;
    
    [self.label1 sizeToFit];
    self.label1.height = WIDTH_ADAPTER(28);
    self.label1.centerX = self.floatView1.width * 0.5;
    self.label1.y = WIDTH_ADAPTER(35);
    
    [self.label2 sizeToFit];
    self.label2.height = WIDTH_ADAPTER(20);
    self.label2.centerX = self.label1.centerX;
    self.label2.y = self.label1.bottom + WIDTH_ADAPTER(10);
    
    self.view1.width = WIDTH_ADAPTER(280);
    self.view1.height = WIDTH_ADAPTER(120);
    self.view1.centerX = self.label1.centerX;
    self.view1.y = self.label2.bottom + WIDTH_ADAPTER(15);
    self.view1.layer.cornerRadius = 3;
    self.view1.layer.masksToBounds = YES;
    
    self.label3.width = self.view1.width - 2 * WIDTH_ADAPTER(15);
    [self.label3 sizeToFit];
    self.label3.width = self.view1.width - 2 * WIDTH_ADAPTER(15);
    self.label3.x = WIDTH_ADAPTER(15);
    self.label3.y = WIDTH_ADAPTER(13);
    
    [self.label4 sizeToFit];
    self.label4.height = WIDTH_ADAPTER(20);
    self.label4.centerX = self.label1.centerX;
    self.label4.y = self.view1.bottom + WIDTH_ADAPTER(15);
    
    self.button1.width = WIDTH_ADAPTER(130);
    self.button1.height = WIDTH_ADAPTER(45);
    self.button1.x = WIDTH_ADAPTER(30);
    self.button1.y = self.label4.bottom + WIDTH_ADAPTER(15);
    
    self.button2.width = self.button1.width;
    self.button2.height = self.button1.height;
    self.button2.x = self.button1.right + WIDTH_ADAPTER(20);
    self.button2.y = self.button1.y;
    
}

#pragma mark - 按钮的点击
- (void)clickButton1:(UIButton *)btn   // 微信好友
{
    if (!self.callModel) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"获取分享信息失败,请稍后再试"];
        return;
    }
    
    [self insertCallRecord:^{
        
        [self sensorsAnalyticsInviteFriend:@"微信"];
        JAShareModel *model = [[JAShareModel alloc] init];
        model.title = self.callModel.title;
        model.descripe = self.callModel.content;
        model.shareUrl = self.callModel.shareUrl;
        model.image = self.callModel.logo;
        
        [JAPlatformShareManager wxShare:WeiXinShareTypeTimeline shareContent:model domainType:3];
        
    } faile:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
    
    [self removeFromSuperview];
}
- (void)clickButton2:(UIButton *)btn   // qq好友
{
    
    if (!self.callModel) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"获取分享信息失败,请稍后再试"];
        return;
    }
    
    [self insertCallRecord:^{
        [self sensorsAnalyticsInviteFriend:@"qq"];
        JAShareModel *model = [JAShareModel new];
        model.title = self.callModel.title;
        model.descripe = self.callModel.content;
        model.shareUrl = self.callModel.shareUrl;
        model.image = self.callModel.logo;
        
        [JAPlatformShareManager qqShare:QQShareTypeFriend shareContent:model domainType:3];
    } faile:^(NSError *error) {
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
    
    [self removeFromSuperview];
}

- (void)clickCloseButton1:(UIButton *)btn
{
    [self removeFromSuperview];
}

- (void)showCallFloat:(NSString *)text
{
    self.label3.text = text;
    [self.label3 sizeToFit];
    self.floatView1.hidden = NO;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}
- (void)showRuleFloat:(NSString *)text keyWord:(NSArray *)wordArr ruleText:(NSString *)ruleText
{
    [self.otherlabel2 setAttributedText:[self attributedString:text wordArray:wordArr]];
    self.otherTextView.text = ruleText;
    [self.otherlabel2 sizeToFit];
    self.floatView2.hidden = NO;
    self.imageView.hidden = NO;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}

- (NSMutableAttributedString *)attributedString:(NSString *)text wordArray:(NSArray *)keyWordArr
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    for (NSInteger i = 0; i < keyWordArr.count; i++) {
        
        NSString *keyWord = keyWordArr[i];
        // 获取关键字的位置
        NSRange rang = [text rangeOfString:keyWord];
        
        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
    }
    
    return attr;
}

- (void)sensorsAnalyticsInviteFriend:(NSString *)mothod
{
    // 神策数据
    NSMutableDictionary *senDic = [NSMutableDictionary dictionary];
    senDic[JA_Property_WakeUpMethod] = mothod;
    [JASensorsAnalyticsManager sensorsAnalytics_callFriend:senDic];
}

// 插入唤醒记录
- (void)insertCallRecord:(void(^)())finish faile:(void(^)(NSError *error))faile
{
    [MBProgressHUD showMessage:nil];
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"awakenUserId"] = self.callModel.userId;
    [[JAUserApiRequest shareInstance] userCallInviteFriendAction:dic success:^(NSDictionary *result) {
        [MBProgressHUD hideHUD];
        if (finish) {
            finish();
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUD];
        if (faile) {
            faile(error);
        }
    }];
}
@end
