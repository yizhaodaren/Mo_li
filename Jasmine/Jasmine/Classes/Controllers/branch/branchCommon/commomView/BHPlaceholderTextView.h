//
//  BHPlaceholderTextView.h
//  BHMY
//
//  Created by a on 15/10/15.
//  Copyright © 2015年 马云龙. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^didChangeBlock)(UITextView *textView);
typedef void(^didChangeSelectionBlock)(UITextView *textView);
typedef BOOL(^shouldChangeBlock)(UITextView *textView, NSRange range, NSString *text);

@interface BHPlaceholderTextView : UITextView <UITextViewDelegate>
@property (copy, nonatomic) didChangeBlock textChangeBlock;
@property (copy, nonatomic) didChangeSelectionBlock didChangeSelection;
@property (copy, nonatomic) shouldChangeBlock textShouldChangeBlock;
@property (strong, nonatomic) UILabel *placeholderLabel;
// 最大输入数
@property (nonatomic, assign) NSInteger maxContentLength;
//占位字符串
@property (nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable UIColor *placeholderColor;
//允许输入字符
@property (nonatomic, assign) BOOL isContentTextViewEnable;

@end
