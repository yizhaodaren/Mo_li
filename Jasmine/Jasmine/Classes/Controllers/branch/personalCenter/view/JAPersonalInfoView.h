//
//  JAPersonalInfoView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/11/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAConsumer;
@interface JAPersonalInfoView : UIView

@property (nonatomic, strong) JAConsumer *model;
@property (nonatomic, strong) void(^clickIconImageBlock)(UIImage *image,UIImageView *imageView);   // 点击头像
@property (nonatomic, strong) void(^clickFocusAndFansBlock)();   // 点击关注粉丝

@property (nonatomic, assign) NSInteger moliRelationType; // 好友关系
@property (nonatomic, strong) NSString *rule;
@end
