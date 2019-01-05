//
//  JAPersonTopicNavView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/2/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPersonTopicNavView : UIView
@property (nonatomic, weak) UIButton *backButton;
@property (nonatomic, weak) UIButton *rightButton;
@property (nonatomic, weak) UILabel *shareLabel;

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shareCount;
@property (nonatomic, assign) CGFloat alphaValue;
@end
