//
//  JABirthDayPickV.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/24.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JABirthDayPickV : UIView

@property(nonatomic, copy) void (^birthdayBlock)(NSDate *birthday);
@property (nonatomic, strong) NSDate *minimumDate;
@property (nonatomic, strong) NSDate *birthDay;
- (instancetype)birthDayPickV;
- (void)show;
- (void)close;

@end
