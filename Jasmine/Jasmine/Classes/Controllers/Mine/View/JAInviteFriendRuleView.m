//
//  JAInviteFriendRuleView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/1/11.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAInviteFriendRuleView.h"

@interface JAInviteFriendRuleView ()

@property (nonatomic, strong) UIView *floatView;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) UILabel *label1;  // 顶部的label
@property (nonatomic, strong) UITextView *textView;  // TextView
@end

@implementation JAInviteFriendRuleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupRuleView];
        self.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    }
    return self;
}

- (void)setupRuleView
{
    self.floatView = [[UIView alloc] init];
    self.floatView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.floatView];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setImage:[UIImage imageNamed:@"mine_invite_close"] forState:UIControlStateNormal];
    self.closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.closeButton addTarget:self action:@selector(clickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView addSubview:self.closeButton];
    
    self.topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mine_rule_icon"]];
    [self.floatView addSubview:self.topImageView];
    
    self.label1 = [[UILabel alloc] init];
    self.label1.text = @" ";
    self.label1.textColor = HEX_COLOR(0x4A4A4A);
    self.label1.font = JA_REGULAR_FONT(WIDTH_ADAPTER(14));
    self.label1.numberOfLines = 0;
    [self.floatView addSubview:self.label1];
    
    self.textView = [[UITextView alloc] init];
    self.textView.text = @" ";
    self.textView.textColor = HEX_COLOR(JA_BlackSubTitle);
    self.textView.font = JA_REGULAR_FONT(WIDTH_ADAPTER(14));
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.editable = NO;
    [self.floatView addSubview:self.textView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.width = JA_SCREEN_WIDTH;
    self.height = JA_SCREEN_HEIGHT;
    
    self.floatView.width = WIDTH_ADAPTER(340);
    self.floatView.height = WIDTH_ADAPTER(420);
    self.floatView.centerX = self.width * 0.5;
    self.floatView.centerY = self.height * 0.5;
    self.floatView.layer.cornerRadius = 5;
    self.floatView.layer.masksToBounds = YES;
    
    self.closeButton.width = 16;
    self.closeButton.height = 16;
    self.closeButton.x = self.floatView.width - 16 - 15;
    self.closeButton.y = 15;
    
    self.topImageView.width = WIDTH_ADAPTER(234);
    self.topImageView.height = WIDTH_ADAPTER(28);
    self.topImageView.centerX = self.floatView.width * 0.5;
    self.topImageView.y = WIDTH_ADAPTER(49);
    
    self.label1.width = self.floatView.width - 2 * WIDTH_ADAPTER(20);
    [self.label1 sizeToFit];
    self.label1.width = self.floatView.width - 2 * WIDTH_ADAPTER(20);
    self.label1.x = WIDTH_ADAPTER(20);
    self.label1.y = self.topImageView.bottom + WIDTH_ADAPTER(38);
    
    self.textView.width = WIDTH_ADAPTER(300);
    self.textView.height = WIDTH_ADAPTER(200);
    self.textView.x = WIDTH_ADAPTER(20);
    self.textView.y = self.label1.bottom + WIDTH_ADAPTER(20);
}


- (void)clickCloseButton:(UIButton *)btn
{
    [self removeFromSuperview];
}

- (void)showInviteRuleFloat:(NSString *)text keyWord:(NSArray *)wordArr ruleText:(NSString *)ruleText
{
    [self.label1 setAttributedText:[self attributedString:text wordArray:wordArr]];
    self.textView.text = ruleText;
    [self.label1 sizeToFit];
    [[[[UIApplication sharedApplication] delegate] window] addSubview:self];
}

- (NSMutableAttributedString *)attributedString:(NSString *)text wordArray:(NSArray *)keyWordArr
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    for (NSInteger i = 0; i < keyWordArr.count; i++) {
        
        NSString *keyWord = keyWordArr[i];
        // 获取关键字的位置
        NSRange rang = [text rangeOfString:keyWord];
        
        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0xFF7054) range:rang];
    }
    
    return attr;
}
@end
