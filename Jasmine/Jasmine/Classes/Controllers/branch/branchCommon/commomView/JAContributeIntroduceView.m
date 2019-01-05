//
//  JAContributeIntroduceView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/4/10.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAContributeIntroduceView.h"

@interface JAContributeIntroduceView ()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, weak) UIButton *knowButton;
@property (nonatomic, weak) UIButton *closeButton;

@property (nonatomic, assign) NSInteger loopCount;
@property (nonatomic, strong) NSString *ruleContent;
@end

@implementation JAContributeIntroduceView

+ (void)showContributeViewWithLoopCount:(NSInteger)count text:(NSString *)ruleString
{
    if (!ruleString.length) {
        return;
    }
    JAContributeIntroduceView *v = [[JAContributeIntroduceView alloc] init];
    v.loopCount = count;
    v.ruleContent = ruleString;
    
    if (count > 0) {
    
        BOOL show = [[NSUserDefaults standardUserDefaults] boolForKey:@"ContributeIntroduceView_first"];
        if (!show) {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"ContributeIntroduceView_first"];
            [[UIApplication sharedApplication].delegate.window addSubview:v];
        }
    }else{
        
        [[UIApplication sharedApplication].delegate.window addSubview:v];
    }
    
}

- (void)setRuleContent:(NSString *)ruleContent
{
    _ruleContent = ruleContent;
    
    self.textView.text = ruleContent;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
        [self setupContributeIntroduceView];
    }
    return self;
}

- (void)setupContributeIntroduceView
{
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _closeButton = closeButton;
    [closeButton setImage:[UIImage imageNamed:@"branch_moliDiantai_close"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(closeSelf:) forControlEvents:UIControlEventTouchUpInside];
//    [self addSubview:closeButton];
    
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = HEX_COLOR(0xffffff);
    backView.layer.cornerRadius = 10;
    backView.layer.masksToBounds = YES;
    [self addSubview:backView];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_moliDiantai_topIcon"]];
    _iconImageView = iconImageView;
    [self addSubview:iconImageView];
    
    UITextView *textView = [[UITextView alloc] init];
    _textView = textView;
    textView.text = @" ";
    textView.textColor = HEX_COLOR(0x4A4A4A);
    textView.font = JA_MEDIUM_FONT(17);
    textView.backgroundColor = [UIColor clearColor];
    textView.editable = NO;
    [backView addSubview:self.textView];
    
    UIButton *knowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _knowButton = knowButton;
    [knowButton setTitle:@"知道了" forState:UIControlStateNormal];
    [knowButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    knowButton.titleLabel.font = JA_MEDIUM_FONT(18);
    knowButton.backgroundColor = HEX_COLOR(JA_Green);
    knowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [knowButton addTarget:self action:@selector(closeSelf:) forControlEvents:UIControlEventTouchUpInside];
    [backView addSubview:knowButton];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorContributeIntroduceView];
}

- (void)caculatorContributeIntroduceView
{
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    self.backView.width = 280;
    self.backView.height = 358;
    self.backView.centerX = self.width * 0.5;
    self.backView.centerY = self.height * 0.5 + 20;
    
    self.iconImageView.width = 80;
    self.iconImageView.height = 80;
    self.iconImageView.centerX = self.backView.centerX;
    self.iconImageView.y = self.backView.y - 20;
    
    self.closeButton.width = 40;
    self.closeButton.height = 40;
    self.closeButton.x = self.backView.right - self.closeButton.width + 2;
    self.closeButton.y = self.iconImageView.y - self.closeButton.height + 4;
    
    self.textView.width = self.backView.width - 50;
    self.textView.height = 168;
    self.textView.x = 25;
    self.textView.y = 80;
    
    self.knowButton.width = 160;
    self.knowButton.height = 50;
    self.knowButton.centerX = self.backView.width * 0.5;
    self.knowButton.y = self.textView.bottom + 30;
    self.knowButton.layer.cornerRadius = self.knowButton.height * 0.5;
    self.knowButton.layer.masksToBounds = YES;
}

- (void)closeSelf:(UIButton *)btn
{
    [self removeFromSuperview];
}
@end
