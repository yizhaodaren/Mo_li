//
//  NIMSessionTextContentView.m
//  NIMKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "NIMSessionTextContentView.h"
#import "M80AttributedLabel+NIMKit.h"
#import "NIMMessageModel.h"
#import "NIMGlobalMacro.h"
#import "NIMKitUIConfig.h"
#import "UIView+NIM.h"

@interface NIMSessionTextContentView()<M80AttributedLabelDelegate>

@end

@implementation NIMSessionTextContentView

- (instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _textLabel = [[M80AttributedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.delegate = self;
        _textLabel.numberOfLines = 0;
        _textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_textLabel];
    }
    return self;
}

- (void)refresh:(NIMMessageModel *)data{
    [super refresh:data];
    NSString *text = self.model.message.text;
    
    NIMKitBubbleConfig *config = [[NIMKitUIConfig sharedConfig] bubbleConfig:data.message];

//    self.textLabel.textColor = config.contentTextColor;
//    self.textLabel.font = config.contentTextFont;
//    [self.textLabel nim_setText:text];
    
//    NSArray *arr = data.message.remoteExt[@"connect"];
//    if (arr.count) {
//
//        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:data.message.text];
//
//        NSRange rangAll = NSMakeRange(0, data.message.text.length);
//
//        [attr addAttribute:NSKernAttributeName value:@(-0.5) range:rangAll];
//        [attr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:rangAll];
//        [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(0x454c57) range:rangAll];
//
//        for (NSInteger i = 0; i < arr.count; i++) {
//            NSDictionary *dic = arr[i];
//            NSString *string = dic[@"content"];
//
//            // 设置富文本
//            NSRange rang = [text rangeOfString:string];
//
//            [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
//
//        }
//
//        [self.textLabel nim_appendAttributedText:attr];
//    }else{
        self.textLabel.textColor = config.contentTextColor;
        self.textLabel.font = config.contentTextFont;
        [self.textLabel nim_setText:text];
//    }
}

- (NSMutableAttributedString *)attributedString:(NSString *)text word:(NSString *)keyWord
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:text];
    
    // 获取关键字的位置
    NSRange rang = [text rangeOfString:keyWord];
    
    [attr addAttribute:NSForegroundColorAttributeName value:HEX_COLOR(JA_Green) range:rang];
    
    return attr;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    UIEdgeInsets contentInsets = self.model.contentViewInsets;
    
    CGFloat tableViewWidth = self.superview.nim_width;
    CGSize contentsize         = [self.model contentSize:tableViewWidth];
    CGRect labelFrame = CGRectMake(contentInsets.left, contentInsets.top, contentsize.width, contentsize.height);
    self.textLabel.frame = labelFrame;
}

- (void)onTouchUpInside:(id)sender
{
    NIMKitEvent *event = [[NIMKitEvent alloc] init];
    event.eventName = NIMKitEventNameTapContent;
    event.messageModel = self.model;
    [self.delegate onCatchEvent:event];
}

#pragma mark - M80AttributedLabelDelegate
- (void)m80AttributedLabel:(M80AttributedLabel *)label
             clickedOnLink:(id)linkData{
    NIMKitEvent *event = [[NIMKitEvent alloc] init];
    event.eventName = NIMKitEventNameTapLabelLink;
    event.messageModel = self.model;
    event.data = linkData;
    [self.delegate onCatchEvent:event];
}

@end
