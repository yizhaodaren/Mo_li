//
//  JAGlobalPlayView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/8/29.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAGlobalPlayView : UIView

@property (nonatomic, assign) CGFloat layoutY;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, copy) NSString *userId; //匿名userId为空
@property (nonatomic, copy) NSString *voiceId;// 只用于第一次，播放条跳转使用

@property (nonatomic, copy) void(^showVoiceDetail)(void);
@property (nonatomic, copy) void(^personalCenter)(NSString *userId);

- (void)setUserHeadImage:(NSString *)imageName isAnonymous:(BOOL)isAnonymous;

@end
