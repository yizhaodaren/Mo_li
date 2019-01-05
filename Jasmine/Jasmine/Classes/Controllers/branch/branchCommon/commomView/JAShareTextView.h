//
//  JAShareTextView.h
//  Jasmine
//
//  Created by xujin on 15/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAShareTextView : UITextView

@property (nonatomic, copy) NSString *myPlaceholder;  //文字

@property (nonatomic, strong) UIColor *myPlaceholderColor; //文字颜色

@property (nonatomic, assign) NSInteger maxContentLength;
@property (nonatomic, copy) void(^textChangeBlock)(UITextView *textView);

@end
