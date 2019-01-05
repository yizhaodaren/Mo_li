//
//  JANotInterestView.m
//  Jasmine
//
//  Created by xujin on 2018/6/27.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JANotInterestView.h"
#import "JAVoicePersonApi.h"

@interface JANotInterestView ()

@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UIImageView *contentView;
@property (nonatomic, assign) CGFloat noInterestViewY;
@property (nonatomic, copy) void(^selectBlock)(NSString *reason);

@end

@implementation JANotInterestView

+ (void)showNotInterestWithStory:(JANewVoiceModel *)voiceModel noInterestViewY:(CGFloat)noInterestViewY {
    [self showNotInterestWithStory:voiceModel noInterestViewY:noInterestViewY finishBlock:nil];
}

+ (void)showNotInterestWithStory:(JANewVoiceModel *)voiceModel noInterestViewY:(CGFloat)noInterestViewY finishBlock:(void(^)(NSString *reason))finishBlock {
    JANotInterestView *view = [[JANotInterestView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, JA_SCREEN_HEIGHT)];
    view.noInterestViewY = noInterestViewY;
    view.voiceModel = voiceModel;
    view.selectBlock = finishBlock;
    [[[[UIApplication sharedApplication] delegate] window] addSubview:view];
    [UIView animateWithDuration:0.3 animations:^{
        view.maskView.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *maskView = [UIView new];
        [self addSubview:maskView];
        self.maskView = maskView;
        self.maskView.frame = self.bounds;
        [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeButtonAction)]];
    }
    return self;
}

- (UIButton *)createButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = JA_REGULAR_FONT(14);
    button.layer.cornerRadius = 13;
    button.layer.masksToBounds = YES;
    button.layer.borderColor = [HEX_COLOR(JA_Line) CGColor];
    button.layer.borderWidth = 1;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:HEX_COLOR(0x545454) forState:UIControlStateNormal];
    return button;
}

- (void)setVoiceModel:(JANewVoiceModel *)voiceModel {
    _voiceModel = voiceModel;
    if (voiceModel) {
        UIImageView *contentView = [UIImageView new];
        contentView.userInteractionEnabled = YES;
        [self addSubview:contentView];
        self.contentView = contentView;
        self.contentView.x = 15;
        self.contentView.width = self.width-30;
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.font = JA_MEDIUM_FONT(17);
        titleLabel.textColor = HEX_COLOR(JA_BlackTitle);
        titleLabel.text = @"选择理由，精准屏蔽";
        [contentView addSubview:titleLabel];
        [titleLabel sizeToFit];
        titleLabel.x = (contentView.width-titleLabel.width)/2.0;
        titleLabel.y = 30;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(10, titleLabel.bottom+15, self.contentView.width-20, 1)];
        lineView.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [contentView addSubview:lineView];
        
        UIButton *seeButton = [self createButtonWithTitle:@"看过了"];
        [seeButton addTarget:self action:@selector(seeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:seeButton];
        seeButton.frame = CGRectMake(10, lineView.bottom+15, 70, 26);
        
        UIButton *boredButton = [self createButtonWithTitle:@"内容太水"];
        [boredButton addTarget:self action:@selector(boredButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:boredButton];
        boredButton.frame = CGRectMake(seeButton.right+10, lineView.bottom+15, 80, 26);
        
        NSString *titleStr = [NSString stringWithFormat:@"不想看：%@类帖子", self.voiceModel.labelName.length?self.voiceModel.labelName:@"该"];
        UIButton *dislikeButton = [self createButtonWithTitle:titleStr];
        [dislikeButton addTarget:self action:@selector(dislikeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:dislikeButton];
        CGFloat buttonWidth = [titleStr sizeOfStringWithFont:dislikeButton.titleLabel.font maxSize:CGSizeMake(contentView.width-20-30, 30)].width;
        if (buttonWidth+boredButton.right+10>contentView.width-10) {
            dislikeButton.frame = CGRectMake(10, seeButton.bottom+10, buttonWidth+24, 26);
            self.contentView.height = 130+26+15;
        } else {
            dislikeButton.frame = CGRectMake(boredButton.right+10, lineView.bottom+15, buttonWidth+24, 26);
            self.contentView.height = 130;
        }
        dislikeButton.hidden = self.voiceModel.labelName.length?NO:YES;
        
        if (self.noInterestViewY+30+self.contentView.height > JA_SCREEN_HEIGHT-JA_TabbarHeight) {
            self.contentView.height += 10;
            self.contentView.y = self.noInterestViewY+20-self.contentView.height;
            contentView.image = [UIImage imageNamed:@"voice_black_down"];
        } else {
            self.contentView.y = self.noInterestViewY+30;
            contentView.image = [UIImage imageNamed:@"voice_black_up"];
        }
    }
}

- (void)closeButtonAction {
//    if (self.selectBlock) {
//        self.selectBlock(@"看过了");
//    }
    [self removeFromSuperview];
}

- (void)seeButtonAction:(UIButton *)sender {
    sender.enabled = NO;
    if (self.selectBlock) {
        self.selectBlock(sender.titleLabel.text);
    }
    [self removeFromSuperview];
}

- (void)boredButtonAction:(UIButton *)sender {
    sender.enabled = NO;
    if (self.selectBlock) {
        self.selectBlock(sender.titleLabel.text);
    }
    [self removeFromSuperview];
}

- (void)dislikeButtonAction:(UIButton *)sender {
    sender.enabled = NO;
    if (self.selectBlock) {
        self.selectBlock(self.voiceModel.labelName);
    }
    [self removeFromSuperview];
}

@end

