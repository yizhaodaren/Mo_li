//
//  JACommonSectionView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/28.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, JACommonSectionViewType) {
    JACommonSectionViewType_normal,   // 两个按钮
    JACommonSectionViewType_moreButton, // 三个按钮
    
};

@interface JACommonSectionView : UIView

@property (nonatomic, weak) UIButton *leftButton;    // 左边按钮
@property (nonatomic, weak) UIView *leftView;    // 左边绿色条

@property (nonatomic, weak) UIButton *middleButton;   // 中间按钮
@property (nonatomic, weak) UIView *middleView;    // 中间绿色条

@property (nonatomic, weak) UIButton *rightButton;   // 右边按钮

@property (nonatomic, weak) UIView *verticalLineView; // 垂直线

- (instancetype)initWithType:(JACommonSectionViewType)type;

- (void)commonSection_layoutView;
@end
