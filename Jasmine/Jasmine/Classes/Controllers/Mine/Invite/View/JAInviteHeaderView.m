//
//  JAInviteHeaderView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAInviteHeaderView.h"
#import "JAPaddingLabel.h"

@interface JAInviteHeaderView ()

@property (nonatomic, weak) UIView *bottomView;
@property (nonatomic, weak) UIImageView *imageView1;
@property (nonatomic, weak) JAPaddingLabel *label1;
@property (nonatomic, weak) UIButton *button1;
@property (nonatomic, weak) UIImageView *imageView2;
@property (nonatomic, weak) JAPaddingLabel *label2;
@property (nonatomic, weak) UIButton *button2;
@property (nonatomic, weak) UIImageView *imageView3;
@property (nonatomic, weak) JAPaddingLabel *label3;
@property (nonatomic, weak) UIButton *button3;

@end

@implementation JAInviteHeaderView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHeaderViewUI];
        self.backgroundColor = HEX_COLOR(0xFEFEFE);
    }
    return self;
}

- (void)setupHeaderViewUI
{
    UIView *bottomView = [[UIView alloc] init];
    _bottomView = bottomView;
    bottomView.backgroundColor = HEX_COLOR(0xffffff);
    bottomView.layer.cornerRadius = 8;
//    bottomView.layer.masksToBounds = YES;
    bottomView.layer.shadowColor = HEX_COLOR(0xf5f5f5).CGColor;
    bottomView.layer.shadowOffset = CGSizeMake(0,0);
    bottomView.layer.shadowOpacity = 1;
    bottomView.layer.shadowRadius = 10;
    
    [self addSubview:bottomView];
    
    UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_invite_woman"]];
    _imageView1 = imageView1;
    [bottomView addSubview:imageView1];
    
    JAPaddingLabel *label1 = [[JAPaddingLabel alloc] init];
    _label1 = label1;
    label1.backgroundColor = HEX_COLOR(0xf4f4f4);
    label1.text = @"随机邀请几位女士";
    label1.numberOfLines = 2;
    label1.textColor = HEX_COLOR(0x8F8E94);
    label1.font = JA_REGULAR_FONT(11);
    label1.textAlignment = NSTextAlignmentCenter;
    label1.layer.cornerRadius = 4;
    label1.clipsToBounds = YES;
    label1.edgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    [bottomView addSubview:label1];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button1 = button1;
    [button1 addTarget:self action:@selector(inviteWoman) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button1];
    
    UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_invite_heart"]];
    _imageView2 = imageView2;
    imageView2.contentMode = UIViewContentModeCenter;
    [bottomView addSubview:imageView2];
    
    JAPaddingLabel *label2 = [[JAPaddingLabel alloc] init];
    _label2 = label2;
    label2.backgroundColor = HEX_COLOR(0xf4f4f4);
    label2.text = @"随机邀请有缘人";
    label2.numberOfLines = 2;
    label2.textColor = HEX_COLOR(0x8F8E94);
    label2.font = JA_REGULAR_FONT(11);
    label2.textAlignment = NSTextAlignmentCenter;
    label2.layer.cornerRadius = 4;
    label2.clipsToBounds = YES;
    label2.edgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    [bottomView addSubview:label2];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button2 = button2;
    [button2 addTarget:self action:@selector(inviteRandom) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button2];
    
    UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_invite_man"]];
    _imageView3 = imageView3;
    [bottomView addSubview:imageView3];
    
    JAPaddingLabel *label3 = [[JAPaddingLabel alloc] init];
    _label3 = label3;
    label3.backgroundColor = HEX_COLOR(0xf4f4f4);
    label3.text = @"随机邀请几位男士";
    label3.numberOfLines = 2;
    label3.textColor = HEX_COLOR(0x8F8E94);
    label3.font = JA_REGULAR_FONT(11);
    label3.textAlignment = NSTextAlignmentCenter;
    label3.layer.cornerRadius = 4;
    label3.clipsToBounds = YES;
    label3.edgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
    [bottomView addSubview:label3];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    _button3 = button3;
    [button3 addTarget:self action:@selector(inviteMan) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button3];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorHeaderViewFrame];
}

- (void)caculatorHeaderViewFrame
{
    self.width = JA_SCREEN_WIDTH;
    self.height = 160;
    
    self.bottomView.width = JA_SCREEN_WIDTH - 28;
    self.bottomView.height = 130;
    self.bottomView.x = 14;
    self.bottomView.y = 15;
    
    self.imageView1.width = WIDTH_ADAPTER(75);
    self.imageView1.height = WIDTH_ADAPTER(75);
    self.imageView1.x = WIDTH_ADAPTER(30);
    self.imageView1.y = 4;
    
    self.label1.width = 60;
    self.label1.height = 34;
    self.label1.y = self.imageView1.bottom + 6;
    self.label1.centerX = self.imageView1.centerX;
    
    self.button1.width = self.bottomView.width / 3.0;
    self.button1.height = self.bottomView.height;
    
    self.imageView2.width = WIDTH_ADAPTER(75);
    self.imageView2.height = WIDTH_ADAPTER(75);
    self.imageView2.x = self.imageView1.right + WIDTH_ADAPTER(35);
    self.imageView2.y = 10;
    
    self.label2.width = 60;
    self.label2.height = 34;
    self.label2.y = self.imageView2.bottom;
    self.label2.centerX = self.imageView2.centerX;
    
    self.button2.width = self.bottomView.width / 3.0;
    self.button2.height = self.bottomView.height;
    self.button2.x = self.button1.right;
    
    self.imageView3.width = WIDTH_ADAPTER(75);
    self.imageView3.height = WIDTH_ADAPTER(75);
    self.imageView3.x = self.imageView2.right + WIDTH_ADAPTER(35);
    self.imageView3.y = 4;
    
    self.label3.width = 60;
    self.label3.height = 34;
    self.label3.y = self.imageView3.bottom + 6;
    self.label3.centerX = self.imageView3.centerX;
    
    self.button3.width = self.bottomView.width / 3.0;
    self.button3.height = self.bottomView.height;
    self.button3.x = self.button2.right;
}

- (void)inviteMan
{
    if (self.randomInviteMan) {
        self.randomInviteMan();
    }
}

- (void)inviteWoman
{
    if (self.randomInviteWoman) {
        self.randomInviteWoman();
    }
}

- (void)inviteRandom
{
    if (self.randomInvite) {
        self.randomInvite();
    }
}
@end
