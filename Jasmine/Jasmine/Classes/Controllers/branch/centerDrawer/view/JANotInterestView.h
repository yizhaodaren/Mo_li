//
//  JANotInterestView.h
//  Jasmine
//
//  Created by xujin on 2018/6/27.
//  Copyright © 2018 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JANewVoiceModel.h"

@interface JANotInterestView : UIView

@property (nonatomic, strong) JANewVoiceModel *voiceModel;

+ (void)showNotInterestWithStory:(JANewVoiceModel *)voiceModel noInterestViewY:(CGFloat)noInterestViewY;
+ (void)showNotInterestWithStory:(JANewVoiceModel *)voiceModel noInterestViewY:(CGFloat)noInterestViewY finishBlock:(void(^)(NSString *reason))finishBlock;

@end
