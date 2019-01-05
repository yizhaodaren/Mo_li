//
//  JAMaintainView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/12/1.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAMaintainView.h"

@interface JAMaintainView ()

@property (nonatomic, weak) UIImageView *maintainImageView;
@property (nonatomic, weak) UILabel *maintainTimeLabel;
@property (nonatomic, weak) UILabel *maintainContentLabel;
@property (nonatomic, weak) UIButton *maintainButton;

@end

@implementation JAMaintainView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.4);
    }
    return self;
}

- (void)setupUI
{
    UIImageView *maintainImageView = [[UIImageView alloc] init];
    _maintainImageView = maintainImageView;
    maintainImageView.userInteractionEnabled = YES;
    maintainImageView.image = [UIImage imageNamed:@"maintain_top"];
    [self addSubview:maintainImageView];
    
    UILabel *maintainTimeLabel = [[UILabel alloc] init];
    _maintainTimeLabel = maintainTimeLabel;
    maintainTimeLabel.font = JA_LIGHT_FONT(12);
    maintainTimeLabel.textColor = HEX_COLOR(0x4A4A4A);
    maintainTimeLabel.numberOfLines = 0;
    [self.maintainImageView addSubview:maintainTimeLabel];
    
    UILabel *maintainContentLabel = [[UILabel alloc] init];
    _maintainContentLabel = maintainContentLabel;
    maintainContentLabel.font = JA_REGULAR_FONT(13);
    maintainContentLabel.textColor = HEX_COLOR(0x454C57);
    maintainContentLabel.numberOfLines = 0;
    maintainContentLabel.text = @"各位亲爱的茉友们，我们将在此期间进行系统升级维护。请在维护完成后再登录茉莉，由此给您带来的不便，敬请谅解！";
    [self.maintainImageView addSubview:maintainContentLabel];
    
    
    UIButton *maintainButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _maintainButton = maintainButton;
    [maintainButton setImage:[UIImage imageNamed:@"maintain_know"] forState:UIControlStateNormal];
    [maintainButton addTarget:self action:@selector(closeSelf:) forControlEvents:UIControlEventTouchUpInside];
    [self.maintainImageView addSubview:maintainButton];

    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorFrame];
}

- (void)caculatorFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    self.maintainImageView.width = 315;
    self.maintainImageView.height = 420;
    self.maintainImageView.centerX = JA_SCREEN_WIDTH * 0.5;
    self.maintainImageView.centerY = JA_SCREEN_HEIGHT * 0.5;
 
    self.maintainTimeLabel.width = 100;
    self.maintainTimeLabel.height = 50;
    self.maintainTimeLabel.x = 42;
    self.maintainTimeLabel.y = 93;
    
    self.maintainContentLabel.width = self.maintainImageView.width - 40;
    self.maintainContentLabel.height = 80;
    self.maintainContentLabel.x = 25;
    self.maintainContentLabel.y = 230;
    
    
    self.maintainButton.width = 150;
    self.maintainButton.height = 35;
    self.maintainButton.centerX = self.maintainImageView.width * 0.5;
    self.maintainButton.y = self.maintainImageView.height - 40 - self.maintainButton.height;
}

- (void)closeSelf:(UIButton *)btn
{
    [self removeFromSuperview];
}

+ (void)show:(NSString *)time
{
    NSString *str = [time stringByReplacingOccurrencesOfString:@" " withString:@"\n"];
    
    JAMaintainView *view = [[JAMaintainView alloc] init];
    view.maintainTimeLabel.text = [NSString stringWithFormat:@"维护时间：\n%@",str];
    
    [[[[UIApplication sharedApplication] delegate] window] addSubview:view];
}
@end
