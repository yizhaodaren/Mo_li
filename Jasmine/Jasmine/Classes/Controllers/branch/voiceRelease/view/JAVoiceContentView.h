//
//  JAVoiceContentView.h
//  Jasmine
//
//  Created by xujin on 2018/6/1.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHPlaceholderTextView.h"
#import "JAStoryVoiceView.h"
#import "JAVoiceReleaseViewController.h"

@interface JAVoiceContentView : UIView

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) BHPlaceholderTextView *contentTextView;
@property (nonatomic, strong) UILabel *wordCountL;
@property (nonatomic, strong) JAStoryVoiceView *voiceBGView;
@property (nonatomic, strong) UIScrollView *photoScrollView;// 多图滚动
@property (nonatomic, strong) UIButton *addPhotoButton; // 添加图片

- (instancetype)initWithSuperVC:(JAVoiceReleaseViewController *)vc;

@end
