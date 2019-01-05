//
//  JAEnterRecordView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/30.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAEnterRecordView.h"
#import "JAPaddingLabel.h"

@interface JAEnterRecordView ()

@property (nonatomic, weak) UIView *lineView;
@property (nonatomic, weak) UIImageView *voiceImageView;
@property (nonatomic, weak) JAPaddingLabel *voiceLabel;
@property (nonatomic, weak) UIButton *voiceButton;

@end

@implementation JAEnterRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupEnterRecordUI];
        self.backgroundColor = HEX_COLOR(0xF6F6F6);
    }
    return self;
}

- (void)setupEnterRecordUI
{
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:lineView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"branch_voice"]];
    _voiceImageView = imageView;
    [self addSubview:imageView];
    
    JAPaddingLabel *label = [[JAPaddingLabel alloc] init];
    _voiceLabel = label;
    label.text = @"请输入回复内容";
    label.textColor = HEX_COLOR(0xC6C6C6);
    label.font = JA_REGULAR_FONT(14);
    label.edgeInsets = UIEdgeInsetsMake(8, 10, 8, 0);
    label.layer.borderColor = HEX_COLOR(0xBDBDBD).CGColor;
    label.layer.borderWidth = 1;
    label.layer.cornerRadius = 4;
    label.layer.masksToBounds = YES;
    [self addSubview:label];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    _voiceButton = button;
    [button addTarget:self action:@selector(jumpReleaseVoiceViewControl) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    
}

- (void)caculatorEnterRecordUI
{
    self.width = JA_SCREEN_WIDTH;
    self.height = 50;
    
    self.lineView.width = self.width;
    self.lineView.height = 1;
    
    self.voiceButton.width = self.width;
    self.voiceButton.height = self.height;
    
    self.voiceImageView.x = 16;
    self.voiceImageView.centerY = self.height * 0.5;
    
    self.voiceLabel.x = self.voiceImageView.right + 11;
    self.voiceLabel.width = self.width - self.voiceLabel.x - 15;
    self.voiceLabel.height = 36;
    self.voiceLabel.centerY = self.voiceImageView.centerY;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculatorEnterRecordUI];
}

- (void)jumpReleaseVoiceViewControl
{
    if (self.jumpReleaseVoiceBlock) {
        self.jumpReleaseVoiceBlock();
    }
}
@end
