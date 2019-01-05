//
//  JAInputToolBar.m
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAInputToolBar.h"

@interface JAInputToolBar ()<JAGrowingTextViewDelegate>

@property (nonatomic, strong) UIView *lineView1;
@property (nonatomic, strong) UIView *contentTextView;    // 文本框的外层
@property (nonatomic, strong) UIView *lineView2;
@end

@implementation JAInputToolBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInputToolBarUI];
        [self caculatorInputToolBarFrame];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFrame
{
    [self caculatorInputToolBarFrame];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JAToolBarDidChangeFrameNotification" object:nil];
}

- (void)setupInputToolBarUI
{
    self.lineView1 = [[UIView alloc] init];
    self.lineView1.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:self.lineView1];
    
    self.recordButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_record"] forState:UIControlStateHighlighted];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordInput"] forState:UIControlStateSelected];
    [self.recordButton setImage:[UIImage imageNamed:@"branch_detail_recordInput"] forState:UIControlStateSelected | UIControlStateHighlighted];
    [self addSubview:self.recordButton];
    
    self.contentTextView = [[UIView alloc] init];
    self.contentTextView.layer.borderColor = HEX_COLOR(JA_Line).CGColor;
    self.contentTextView.layer.borderWidth = 1;
    self.contentTextView.layer.cornerRadius = 17.5;
    self.contentTextView.layer.masksToBounds = YES;
    self.contentTextView.backgroundColor = HEX_COLOR(0xFAFBFB);
    [self addSubview:self.contentTextView];
    
    self.atButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.atButton.imageEdgeInsets = UIEdgeInsetsMake(0, -3, 0, 3);
    [self.atButton setImage:[UIImage imageNamed:@"release_at"] forState:UIControlStateNormal];
    [self.atButton setImage:[UIImage imageNamed:@"release_at"] forState:UIControlStateSelected];
    [self.contentTextView addSubview:self.atButton];
    
    self.nim_textView = [[JAGrowingTextView alloc] initWithFrame:CGRectZero];
    self.nim_textView.font = JA_REGULAR_FONT(15);
    self.nim_textView.maxNumberOfLines = 4;
    self.nim_textView.minNumberOfLines = 1;
//    self.nim_textView.maxNumberOfWords = JA_ReplyInput_words;
    self.nim_textView.textColor = HEX_COLOR(JA_Three_Title);
    self.nim_textView.backgroundColor = [UIColor clearColor];
    self.nim_textView.size = [self.nim_textView intrinsicContentSize];
    self.nim_textView.textViewDelegate = self;
    self.nim_textView.returnKeyType = UIReturnKeySend;
    NSString *placeHolder = @"请输入回复内容";
    NSMutableAttributedString *place = [[NSMutableAttributedString alloc] initWithString:placeHolder];
    [place addAttributes:@{NSFontAttributeName : JA_REGULAR_FONT(15), NSForegroundColorAttributeName : HEX_COLOR(0xCACACA)} range:[placeHolder rangeOfString:placeHolder]];
    self.nim_textView.placeholderAttributedText = place;
    [self.contentTextView addSubview:self.nim_textView];
    
    self.publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.publishButton setTitle:@"发送" forState:UIControlStateNormal];
    self.publishButton.titleLabel.font = JA_MEDIUM_FONT(14);
    [self.publishButton setTitleColor:HEX_COLOR(0x9B9B9B) forState:UIControlStateNormal];
    [self.publishButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateSelected];
//    [self.publishButton setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateSelected];
    [self.publishButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(0xEDECEC)] forState:UIControlStateNormal];
    [self.publishButton setBackgroundImage:[UIImage imageWithColor:HEX_COLOR(JA_Green)] forState:UIControlStateSelected];
    [self addSubview:self.publishButton];
    
    self.lineView2 = [[UIView alloc] init];
    self.lineView2.backgroundColor = HEX_COLOR(JA_Line);
    [self addSubview:self.lineView2];
}

//- (void)customKeyBoardView:(JAGrowingTextView *)textView
//{
//    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 40)];
//    customView.backgroundColor = [UIColor redColor];
//    textView.textViewInputAccessoryView = customView;
//}

- (void)caculatorInputToolBarFrame
{
    self.width = JA_SCREEN_WIDTH;
    
    self.height = self.nim_textView.height + 15;
    
    self.lineView1.width = JA_SCREEN_WIDTH;
    self.lineView1.height = 1;
    
    self.recordButton.width = 40;
    self.recordButton.height = 50;
    self.recordButton.x = 5;
    self.recordButton.centerY = self.height * 0.5;
    
    self.publishButton.width = 64;
    self.publishButton.height = 30;
    self.publishButton.x = JA_SCREEN_WIDTH - self.publishButton.width - 15;
    self.publishButton.centerY = self.height * 0.5;
    self.publishButton.layer.cornerRadius = self.publishButton.height * 0.5;
    self.publishButton.layer.masksToBounds = YES;
    
    self.contentTextView.width = self.publishButton.x - self.recordButton.right - 20;
    self.contentTextView.x = self.recordButton.right + 10;
    self.contentTextView.y = 8;
    
    self.nim_textView.width = self.contentTextView.width - 60;
    self.nim_textView.x = 17.5;
    self.nim_textView.y = 0;
    
    self.contentTextView.height = self.nim_textView.height;
    
    self.atButton.width = 40;
    self.atButton.height = 50;
    self.atButton.x = self.contentTextView.width - self.atButton.width;
    self.atButton.centerY = self.contentTextView.height * 0.5;
    
    self.lineView2.width = JA_SCREEN_WIDTH;
    self.lineView2.height = 1;
    self.lineView2.y = self.height - 1;
    
}


#pragma mark - NIMGrowingTextViewDelegate
- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText
{
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(shouldChangeTextInRange:replacementText:)]) {
        should = [self.delegate shouldChangeTextInRange:range replacementText:replacementText];
    }
    return should;
}

- (void)textViewDidChangeSelection:(JAGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidChangeSelection_toolBar:)]) {
        [self.delegate textViewDidChangeSelection_toolBar:growingTextView];
    }
}

- (BOOL)textViewShouldBeginEditing:(JAGrowingTextView *)growingTextView
{
    BOOL should = YES;
    if ([self.delegate respondsToSelector:@selector(textViewShouldBeginEditing)]) {
        should = [self.delegate textViewShouldBeginEditing];
    }
    return should;
}

- (void)textViewDidEndEditing:(JAGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidEndEditing)]) {
        [self.delegate textViewDidEndEditing];
    }
}


- (void)textViewDidChange:(JAGrowingTextView *)growingTextView
{
    if ([self.delegate respondsToSelector:@selector(textViewDidChange)]) {
        [self.delegate textViewDidChange];
    }
}

- (void)didChangeHeight:(CGFloat)height
{
    [self updateFrame];
}


@end
