//
//  BHPlaceholderTextView.m
//  BHMY
//
//  Created by a on 15/10/15.
//  Copyright © 2015年 . All rights reserved.
//

#import "BHPlaceholderTextView.h"

@implementation BHPlaceholderTextView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.isContentTextViewEnable = YES;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.isContentTextViewEnable = YES;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.isContentTextViewEnable = YES;
}

- (void)setupPlaceholderLabel {
    
    if (_placeholder) {
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        NSAttributedString *attributedString = [[NSAttributedString alloc]initWithString:_placeholder attributes:@{
                                                                                                                   NSFontAttributeName:[UIFont systemFontOfSize:15],
                                                                                                                   NSParagraphStyleAttributeName:paragraphStyle}];
        //计算高度 NSStringDrawingUsesLineFragmentOrigin
        CGFloat height = [attributedString boundingRectWithSize:CGSizeMake(JA_SCREEN_WIDTH - 35, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height;
        
        if (self.placeholderLabel == nil) {
            self.placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, JA_SCREEN_WIDTH - 35, height)];
            self.placeholderLabel.numberOfLines = 0;
            self.placeholderLabel.textColor = [UIColor grayColor];
//            self.font = [[BHFont sharedObject] bhFont5];
//            self.placeholderLabel.textColor = [UIColor colorWithHexString:@"#cccccc"];
            [self addSubview:self.placeholderLabel];
            //设置代理
            
        }
        self.placeholderLabel.attributedText = attributedString;
    }
    self.delegate = self;
}


- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [self setupPlaceholderLabel];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    self.placeholderLabel.textColor = placeholderColor;
}

// v2.5.4 直接赋值，不能触发回调
- (void)setText:(NSString *)text {
    [super setText:text];
    [self textViewDidChange:self];
}

- (void)textViewDidChangeSelection:(UITextView *)textView{
    if (self.didChangeSelection) {
        self.didChangeSelection(textView);
    }
}

- (void)textViewDidChange:(UITextView *)textView {
    self.placeholderLabel.hidden = textView.text.length >0;
    self.isContentTextViewEnable = YES;
    
    NSString *lang = [[UIApplication sharedApplication] textInputMode].primaryLanguage;
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        //获取高亮部分
        UITextRange *selectedRange = [textView markedTextRange];
        UITextPosition *position = [textView positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (textView.text.length > self.maxContentLength) {
                self.text = [self.text substringToIndex:self.maxContentLength];
                self.isContentTextViewEnable = NO;
            }
            if (self.textChangeBlock) {
                self.textChangeBlock(self);
            }
        }else{//有高亮选择的字符串，则暂不对文字进行统计和限制
            
        }
    } else {
        if (textView.text.length > self.maxContentLength) {
            self.text = [self.text substringToIndex:self.maxContentLength];
            self.isContentTextViewEnable = NO;
        }
        if (self.textChangeBlock) {
            self.textChangeBlock(self);
        }
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if (self.textShouldChangeBlock) {
        return self.textShouldChangeBlock(self, range, text);
    } else {
        if ([text isEqualToString:@""]) {
            return YES;
        }else{
            return self.isContentTextViewEnable;
        }
    }
}

- (NSInteger)maxContentLength {
    if (!_maxContentLength) {
        return ULONG_MAX;
    }
    return _maxContentLength;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action ==@selector(copy:) ||
       
       action ==@selector(selectAll:)||
       
       action ==@selector(cut:)||
       
       action ==@selector(select:)||
       
       action ==@selector(paste:)) {
        
        return[super canPerformAction:action withSender:sender];
    }
    return NO;
}

-(void)copy:(id)sender{
    
    [super copy:sender];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    if ([pasteboard.string containsString:@"\b"]) {
        pasteboard.string = [pasteboard.string stringByReplacingOccurrencesOfString:@"\b" withString:@""];
    }
}

- (void)cut:(id)sender
{
    [super cut:sender];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    if ([pasteboard.string containsString:@"\b"]) {
        pasteboard.string = [pasteboard.string stringByReplacingOccurrencesOfString:@"\b" withString:@""];
    }
}


@end
