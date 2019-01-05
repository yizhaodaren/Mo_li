
//
//  JARichTextView.m
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichTextView.h"

@implementation JARichTextView

- (void)deleteBackward {
    [super deleteBackward];
    if ([self.ja_delegate respondsToSelector:@selector(ja_textViewDeleteBackward:)]) {
        [self.ja_delegate ja_textViewDeleteBackward:self];
    }
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
