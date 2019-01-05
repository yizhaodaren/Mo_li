//
//  JAReplyKeyBoardView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/24.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAReplyKeyBoardView.h"

@interface JAReplyKeyBoardView ()


@end

@implementation JAReplyKeyBoardView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.width = JA_SCREEN_WIDTH;
        self.height = 44 + JA_TabbarSafeBottomMargin;
        [self setupReplyKeyBoardView];
        self.backgroundColor = HEX_COLOR(0xF8F8F8);
    }
    return self;
}

- (void)setupReplyKeyBoardView
{
    UIButton *recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordButton = recordButton;
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateHighlighted];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordInput"] forState:UIControlStateSelected];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordInput"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self addSubview:recordButton];
    
    UIButton *textButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _textButton = textButton;
    [textButton setTitle:@"回复楼主" forState:UIControlStateNormal];
    [textButton setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    textButton.titleLabel.font = JA_REGULAR_FONT(14);
    textButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    textButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    [self addSubview:textButton];
    
    JAEmitterView *likeButton = [JAEmitterView buttonWithType:UIButtonTypeCustom];
    _likeButton = likeButton;
    [likeButton setImage:[UIImage imageNamed:@"v3_agree_black_nor"] forState:UIControlStateNormal];
    [likeButton setImage:[UIImage imageNamed:@"v3_agree_black_nor"] forState:UIControlStateHighlighted];
    [likeButton setImage:[UIImage imageNamed:@"branch_smallAgree_sel"] forState:UIControlStateSelected];
    [likeButton setImage:[UIImage imageNamed:@"branch_smallAgree_sel"] forState:UIControlStateSelected|UIControlStateHighlighted];
    likeButton.beginAngle = -45;
    likeButton.direction = 0;
    [self addSubview:likeButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _shareButton = shareButton;
    [shareButton setImage:[UIImage imageNamed:@"v3_share_black"] forState:UIControlStateNormal];
    [self addSubview:shareButton];
}

- (void)calculatorReplyKeyBoardView
{
    self.recordButton.width = 30;
    self.recordButton.height = 30;
    self.recordButton.x = 12;
    self.recordButton.y = 7;
    
    if (self.type == 0) {
        
        self.shareButton.width = 30;
        self.shareButton.height = 30;
        self.shareButton.x = self.width - 15 - self.shareButton.width;
        self.shareButton.centerY = self.recordButton.centerY;
    }else{
        
        self.shareButton.width = 0;
        self.shareButton.height = 0;
        self.shareButton.x = 0;
        self.shareButton.y = 0;
    }
    
    if (self.type == 0) {
        
        self.likeButton.width = 30;
        self.likeButton.height = 30;
        self.likeButton.x = self.shareButton.x - 15 - self.likeButton.width;
        self.likeButton.centerY = self.recordButton.centerY;
    }else{
        
        self.likeButton.width = 0;
        self.likeButton.height = 0;
        self.likeButton.x = 0;
        self.likeButton.y = 0;
    }
    
    if (self.type == 0) {
        self.textButton.x = self.recordButton.right + 15;
        self.textButton.width = self.likeButton.x - 15 - self.textButton.x;
        self.textButton.height = 32;
        self.textButton.centerY = self.recordButton.centerY;
    }else{
        self.textButton.x = self.recordButton.right + 15;
        self.textButton.width = self.width - 15 - self.textButton.x;
        self.textButton.height = 32;
        self.textButton.centerY = self.recordButton.centerY;
    }
    
    self.textButton.layer.cornerRadius = self.textButton.height * 0.5;
    self.textButton.layer.masksToBounds = YES;
    self.textButton.layer.borderWidth = 1;
    self.textButton.layer.borderColor = HEX_COLOR(0xededed).CGColor;
}

- (void)setType:(NSInteger)type
{
    _type = type;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorReplyKeyBoardView];
}

@end
