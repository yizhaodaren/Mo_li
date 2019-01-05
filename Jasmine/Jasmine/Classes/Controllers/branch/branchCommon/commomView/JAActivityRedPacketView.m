//
//  JAActivityRedPacketView.m
//  Jasmine
//
//  Created by xujin on 2018/4/8.
//  Copyright © 2018 xujin. All rights reserved.
/*
    活动红包（口令）
 */

#import "JAActivityRedPacketView.h"
#import "JAUserApiRequest.h"

@interface JAActivityRedPacketView()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *redPacketView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;
@property (nonatomic, strong) UILabel *moneyTitleLabel;
@property (nonatomic, strong) UIButton *getButton;

@property (nonatomic, strong) JACommandModel *data;

@end


@implementation JAActivityRedPacketView

+ (void)showActivity:(JACommandModel *)data {
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    [backView addSubview:maskView];
    
    JAActivityRedPacketView *view = [[JAActivityRedPacketView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    view.data = data;
    view.closeBlock = ^{
        [backView removeFromSuperview];
    };
    [backView addSubview:view];
    
    JACenterDrawerViewController *vc = [AppDelegateModel getCenterMenuViewController];
    [vc.view addSubview:backView];
    
    // 第一步：将view宽高缩至无限小（点）
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity,
                                            CGFLOAT_MIN, CGFLOAT_MIN);
    [UIView animateWithDuration:0.3
                     animations:^{
                         // 第二步： 以动画的形式将view慢慢放大至原始大小的1.2倍
                         view.transform =
                         CGAffineTransformScale(CGAffineTransformIdentity, 1.2, 1.2);
                         maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.2
                                          animations:^{
                                              // 第三步： 以动画的形式将view恢复至原始大小
                                              view.transform = CGAffineTransformIdentity;
                                          }];
                     }];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *maskView = [UIView new];
//        maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self addSubview:maskView];
        self.maskView = maskView;
        
        UIImageView *redPacketView = [UIImageView new];
        redPacketView.image = [UIImage imageNamed:@"activity_redpacket"];
        redPacketView.userInteractionEnabled = YES;
        [self addSubview:redPacketView];
        self.redPacketView = redPacketView;
        
        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"activity_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeButton];
        self.closeButton = closeButton;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = JA_REGULAR_FONT(32);
        titleLabel.textColor = HEX_COLOR(0xFFE8AC);
        titleLabel.text = @"恭喜你";
        [self.redPacketView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        [self.titleLabel sizeToFit];
        
        UILabel *subTitleLabel = [UILabel new];
        subTitleLabel.font = JA_REGULAR_FONT(20);
        subTitleLabel.textColor = HEX_COLOR(0xFFE8AC);
        subTitleLabel.textAlignment = NSTextAlignmentCenter;
//        subTitleLabel.text = @"在“微信答题王”中获得";
        subTitleLabel.adjustsFontSizeToFitWidth = YES;
        [self.redPacketView addSubview:subTitleLabel];
        self.subTitleLabel = subTitleLabel;
//        [self.subTitleLabel sizeToFit];
        
        UILabel *moneyTitleLabel = [UILabel new];
        moneyTitleLabel.font = JA_REGULAR_FONT(43);
        moneyTitleLabel.textColor = HEX_COLOR(0xFFFFFF);
//        moneyTitleLabel.text = @"3.5元";
        [self.redPacketView addSubview:moneyTitleLabel];
        self.moneyTitleLabel = moneyTitleLabel;
//        [self.moneyTitleLabel sizeToFit];
        
        UIButton *getButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [getButton setImage:[UIImage imageNamed:@"activity_get"] forState:UIControlStateNormal];
        [getButton addTarget:self action:@selector(getButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.redPacketView addSubview:getButton];
        self.getButton = getButton;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess) name:LOGINSUCCESS object:nil];
    }
    return self;
}

- (void)closeButtonAction {
    if (self.closeBlock) {
        self.closeBlock();
    }
}

- (void)getButtonAction:(UIButton *)sender {
    if (!IS_LOGIN) {
        [JAAPPManager app_modalLogin];
        return;
    }
    [self loginSuccess];
}

- (void)loginSuccess {
    self.getButton.userInteractionEnabled = NO;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    dic[@"userId"] = [JAUserInfo userInfo_getUserImfoWithKey:User_id];
    dic[@"command"] = self.data.command;
    [[JAUserApiRequest shareInstance] userUpdateComand:dic success:^(NSDictionary *result) {
        self.getButton.userInteractionEnabled = YES;
        if (self.closeBlock) {
            self.closeBlock();
        }
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:@"领取成功，请到我的收入中查看"];
    } failure:^(NSError *error) {
        self.getButton.userInteractionEnabled = YES;
        if (self.closeBlock) {
            self.closeBlock();
        }
        [[[[UIApplication sharedApplication] delegate] window] ja_makeToast:error.localizedDescription];
    }];
}

- (void)setData:(JACommandModel *)data {
    _data = data;
    if (_data) {
        self.subTitleLabel.text = data.titleContent;
        [self.subTitleLabel sizeToFit];
        NSString *moneyTypeStr = @"花";
        if (data.moneyType == 1) {
            moneyTypeStr = @"元";
        }
        self.moneyTitleLabel.text = [NSString stringWithFormat:@"%@%@", data.moneyCount, moneyTypeStr];
        [self.moneyTitleLabel sizeToFit];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskView.width = self.width;
    self.maskView.height = self.height;
    
    self.redPacketView.width = WIDTH_ADAPTER(280);
    self.redPacketView.height = WIDTH_ADAPTER(360);
    self.redPacketView.centerX = self.centerX;
    self.redPacketView.centerY = self.centerY;
    
    self.closeButton.width = WIDTH_ADAPTER(38);
    self.closeButton.height = WIDTH_ADAPTER(38);
    self.closeButton.right = self.redPacketView.right;
    self.closeButton.bottom = self.redPacketView.y - WIDTH_ADAPTER(20);
    
    self.getButton.width = WIDTH_ADAPTER(280);
    self.getButton.height = WIDTH_ADAPTER(70);
    self.getButton.bottom = self.redPacketView.height - WIDTH_ADAPTER(17);
    
    self.moneyTitleLabel.centerX = self.redPacketView.width/2.0;
    self.moneyTitleLabel.bottom = self.getButton.y - WIDTH_ADAPTER(20);
    
    self.titleLabel.centerX = self.redPacketView.width/2.0;
    self.titleLabel.y = WIDTH_ADAPTER(105);
    
    self.subTitleLabel.width = WIDTH_ADAPTER(280) - 20;
    self.subTitleLabel.centerX = self.redPacketView.width/2.0;
    self.subTitleLabel.y = self.titleLabel.bottom+WIDTH_ADAPTER(10);
}

@end
