//
//  JAPlaceHolderTextView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/7/12.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPlaceHolderTextView : UITextView

@property (nonatomic, copy) NSString* placeHolder;
@property (nonatomic, assign) CGRect placeHolderFrame;
@property (nonatomic, strong) UIColor* placeHolderColor;
@property (nonatomic, assign) BOOL showPlaceHolder;
@property (nonatomic, assign) NSInteger maxInputs;///<最大输入限制，默认值为1000
@property (nonatomic, assign) BOOL debugMode;

- (void)handleTextDidChange;
- (CGFloat)measureHeight;

@end
