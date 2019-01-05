//
//  JARichTextView.h
//  Jasmine
//
//  Created by xujin on 2018/6/5.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JAPlaceHolderTextView.h"

@class JARichTextView;

@protocol JARichTextViewDelegate <NSObject>

@optional
- (void)ja_textViewDeleteBackward:(JARichTextView *)textView;

@end

@interface JARichTextView : JAPlaceHolderTextView

@property(nonatomic, weak) id<JARichTextViewDelegate> ja_delegate;

@end
