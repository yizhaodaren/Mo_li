
//
//  JAVoiceContentView.m
//  Jasmine
//
//  Created by xujin on 2018/6/1.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAVoiceContentView.h"
#import "JADataHelper.h"
#import "NSString+JACategory.h"

@implementation JAVoiceContentView

- (instancetype)initWithSuperVC:(JAVoiceReleaseViewController *)vc
{
    self = [super init];
    if (self) {
        self.scrollView = [UIScrollView new];
        self.scrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.offset(0);
            make.height.equalTo(self.mas_height);
        }];
        
        UIView *contentView = [UIView new];
        contentView.backgroundColor = [UIColor clearColor];
        [self.scrollView addSubview:contentView];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.bottom.offset(0);
            make.width.equalTo(self.scrollView.mas_width);
            make.height.equalTo(self.scrollView.mas_height).offset(1);
        }];
        
        self.contentTextView = [BHPlaceholderTextView new];
        self.contentTextView.backgroundColor = [UIColor clearColor];
        self.contentTextView.placeholder = @"请添加声音描述，建议一两句话概况内容主题，更容易被平台推荐";
        self.contentTextView.font = JA_REGULAR_FONT(16);
        self.contentTextView.placeholderColor = HEX_COLOR(JA_BlackSubSubTitle);
        self.contentTextView.textColor = HEX_COLOR(JA_BlackTitle);
        self.contentTextView.layoutManager.allowsNonContiguousLayout = NO;
        //    self.contentTextView.maxContentLength = maxContentLength;
        [contentView addSubview:self.contentTextView];
        [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(14);
            make.left.offset(10);
            make.right.offset(-10);
            make.height.offset(40);
        }];
        self.contentTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);//设置页边距
        @WeakObj(self);
        self.contentTextView.didChangeSelection = ^(UITextView *growingTextView) {
            if (growingTextView.selectedRange.length > 0) {  // 两个光标
                if (vc.frontSelectRange.location != growingTextView.selectedRange.location) {  // 移动第一个光标
                    
                    NSArray *userHandles = [JADataHelper getRangesForUserHandles:growingTextView.text];
                    for (NSTextCheckingResult *match in userHandles)
                    {
                        NSRange matchRange = [match range];
                        if (growingTextView.selectedRange.location > matchRange.location && growingTextView.selectedRange.location < matchRange.location+matchRange.length) {
                            growingTextView.selectedRange = NSMakeRange(matchRange.location+matchRange.length, vc.frontSelectRange.location + vc.frontSelectRange.length);
                            break;
                        }
                    }
                    vc.frontSelectRange = growingTextView.selectedRange;
                }else{  // 移动第二个光标
                    
                    NSArray *userHandles = [JADataHelper getRangesForUserHandles:growingTextView.text];
                    for (NSTextCheckingResult *match in userHandles)
                    {
                        NSRange matchRange = [match range];
                        if (growingTextView.selectedRange.location + growingTextView.selectedRange.length > matchRange.location && growingTextView.selectedRange.location + growingTextView.selectedRange.length < matchRange.location+matchRange.length) {
                            growingTextView.selectedRange = NSMakeRange(growingTextView.selectedRange.location, matchRange.location+matchRange.length);
                            break;
                        }
                    }
                    vc.frontSelectRange = growingTextView.selectedRange;
                }
            }else{   // 一个光标
                
                NSArray *userHandles = [JADataHelper getRangesForUserHandles:growingTextView.text];
                for (NSTextCheckingResult *match in userHandles)
                {
                    NSRange matchRange = [match range];
                    if (growingTextView.selectedRange.location > matchRange.location && growingTextView.selectedRange.location < matchRange.location+matchRange.length) {
                        growingTextView.selectedRange = NSMakeRange(matchRange.location+matchRange.length, growingTextView.selectedRange.length);
                        break;
                    }
                }
            }
        };
        self.contentTextView.textShouldChangeBlock = ^BOOL(UITextView *textView, NSRange range, NSString *text) {
            if ([text isEqualToString:@"#"]) {
                [vc pushSearchTopicVC:YES];
            }
            if ([text isEqualToString:@"@"]) {
                if (range.length > 0) {
                    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:text];
                    [textView.textStorage replaceCharactersInRange:range withAttributedString:attributedString];
                }
                [vc pushAtPersonVC:YES];
            }
            // 如果删除的是“\b”
            NSString *subString = [textView.text substringWithRange:range];
            if ([subString isEqualToString:@"\b"]) {
                NSRange headRange = [[textView.text substringToIndex:range.location] rangeOfString:@"@" options:NSBackwardsSearch];
                if (headRange.location != NSNotFound) {
                    textView.text = [textView.text stringByReplacingCharactersInRange:NSMakeRange(headRange.location, range.location-headRange.location+1) withString:@""];
                    textView.selectedRange = NSMakeRange(headRange.location, textView.selectedRange.length);
                    return NO;
                }
            }
            if ([text isEqualToString:@"\n"]) {
                // 不允许输入换行
                return NO;
            }
            return YES;
        };
        self.contentTextView.textChangeBlock = ^(UITextView *textView) {
            @StrongObj(self);
            // 提示文字数目
            int caculaterCount = [NSString caculaterName:textView.text];
            self.wordCountL.text = [NSString stringWithFormat:@"%d/%d",caculaterCount,(int)vc.maxContentLength];
            if (caculaterCount > vc.maxContentLength) {
                self.wordCountL.textColor = [UIColor redColor];
            } else {
                self.wordCountL.textColor = HEX_COLOR(JA_BlackSubTitle);
            }
            
            // 控制发布按钮的样式
            NSString *inputContent = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (inputContent.length) {
                [vc setRightButtonEnable:YES];
            }else{
                [vc setRightButtonEnable:NO];
            }
            
            if (vc.dontChangeRange) {
                vc.dontChangeRange = NO;
            } else {
                vc.lastRange = textView.selectedRange;
            }
            // 处理#话题#
            NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:textView.text];
            [placeholder addAttribute:NSFontAttributeName
                                value:JA_REGULAR_FONT(16)
                                range:NSMakeRange(0, textView.text.length)];
            NSArray *hashtags = [JADataHelper getRangesForHashtags:textView.text];
            // Add all our ranges to the result
            for (NSTextCheckingResult *match in hashtags)
            {
                NSRange matchRange = [match range];
                [placeholder addAttribute:NSForegroundColorAttributeName
                                    value:HEX_COLOR(0x54C7FC)
                                    range:matchRange];
                [placeholder addAttribute:NSFontAttributeName
                                    value:JA_REGULAR_FONT(16)
                                    range:matchRange];
            }
            NSArray *userHandles = [JADataHelper getRangesForUserHandles:textView.text];
            // Add all our ranges to the result
            for (NSTextCheckingResult *match in userHandles)
            {
                NSRange matchRange = [match range];
                [placeholder addAttribute:NSForegroundColorAttributeName
                                    value:HEX_COLOR(0x54C7FC)
                                    range:matchRange];
                [placeholder addAttribute:NSFontAttributeName
                                    value:JA_REGULAR_FONT(16)
                                    range:matchRange];
            }
            textView.attributedText = placeholder;
            textView.selectedRange = vc.lastRange;
        };
        self.wordCountL = [UILabel new];
        self.wordCountL.backgroundColor = [UIColor clearColor];
        self.wordCountL.font = JA_REGULAR_FONT(12);
        self.wordCountL.textColor = HEX_COLOR(JA_BlackSubSubTitle);
        [contentView addSubview:self.wordCountL];
        [self.wordCountL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentTextView.mas_bottom).offset(10);
            //        make.bottom.equalTo(self.channelButton.mas_bottom);
            make.right.offset(-15);
            make.height.offset(20);
        }];
        
        JAStoryVoiceView *voiceBGView = [JAStoryVoiceView new];
        //    [voiceView.playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:voiceBGView];
        [voiceBGView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.wordCountL.mas_bottom).offset(15);
            make.left.offset(15);
            make.right.offset(-15);
            make.height.offset(50);
        }];
        self.voiceBGView = voiceBGView;
        
        self.photoScrollView = [UIScrollView new];
        self.photoScrollView.backgroundColor = [UIColor clearColor];
        self.photoScrollView.hidden = YES;
        [contentView addSubview:self.photoScrollView];
        [self.photoScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.voiceBGView.mas_bottom).offset(15);
            make.left.offset(0);
            make.width.offset(JA_SCREEN_WIDTH);
            make.height.offset(85);
        }];
        
        self.addPhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.addPhotoButton.frame = CGRectMake(15, 5, 80, 80);
        [self.addPhotoButton setImage:[UIImage imageNamed:@"release_addphoto"] forState:UIControlStateNormal];
        [self.photoScrollView addSubview:self.addPhotoButton];
    }
    return self;
}

@end
