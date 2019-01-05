//
//  JAInputToolBar.h
//  Jasmine
//
//  Created by 刘宏亮 on 2017/12/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAGrowingTextView.h"

@class JAInputToolBar;
@protocol JAInputToolBarDelegate <NSObject>

//- (void)inputToolBarWithRecordButton:(JAInputToolBar *)toolBar;  //录制键盘-文字键盘切换按钮
//- (void)inputToolBarWithPublishButton:(JAInputToolBar *)toolBar button:(UIButton *)button; // 发布按钮
//- (void)inputToolBarWithAnonymityButton:(JAInputToolBar *)toolBar button:(UIButton *)button;

@optional

- (BOOL)textViewShouldBeginEditing;

- (void)textViewDidEndEditing;

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText;

- (void)textViewDidChange;

- (void)textViewDidChangeSelection_toolBar:(JAGrowingTextView *)growingTextView;

@end

@interface JAInputToolBar : UIView

@property (nonatomic, strong) UIButton *recordButton;     // 录音按钮
@property (nonatomic, strong) JAGrowingTextView *nim_textView;  // 文本框
//@property (nonatomic, strong) UIButton *anonymityButton;    // 匿名按钮
@property (nonatomic, strong) UIButton *publishButton;   // 发表
@property (nonatomic, strong) UIButton *atButton;   // @ button
@property (nonatomic, weak) id <JAInputToolBarDelegate> delegate;

@end
