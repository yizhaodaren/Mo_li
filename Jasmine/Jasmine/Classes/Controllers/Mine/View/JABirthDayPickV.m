//
//  JABirthDayPickV.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/24.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JABirthDayPickV.h"
@interface JABirthDayPickV ()

@property (nonatomic, strong) UIButton *backgroundView;

// 原来是weak
@property (nonatomic, strong) UIDatePicker *pickV;
@end

@implementation JABirthDayPickV
//static NSDate *birthDay;
- (void) show{
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (!window){
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    _backgroundView = [UIButton buttonWithType:UIButtonTypeCustom];
    _backgroundView.frame = window.bounds;
    [_backgroundView addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    _backgroundView.backgroundColor =  [[UIColor blackColor] colorWithAlphaComponent:0.35];
    [window addSubview:_backgroundView];
    
    [_backgroundView addSubview:self];
    
}

- (void) close{
    [_backgroundView removeFromSuperview];
    _backgroundView = nil;
}

- (void)support{
    [self close];
}

- (void)slander{
    [self close];
}

- (void) onBackButton{
    if (self.birthdayBlock!=NULL) {
        self.birthdayBlock(_birthDay);
    }
    [self close];
}


- (instancetype)birthDayPickV{
    JABirthDayPickV *view = [[JABirthDayPickV alloc] initWithFrame:CGRectMake(0, JA_SCREEN_HEIGHT-153, JA_SCREEN_WIDTH, 148.5)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIDatePicker *pickV = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 100)];
    [pickV addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
    pickV.maximumDate = [self getMaxDate];
    view.pickV = pickV;
    pickV.datePickerMode = UIDatePickerModeDate;
    pickV.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    [view addSubview:pickV];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100, JA_SCREEN_WIDTH, 5)];
    line.backgroundColor = HEX_COLOR(JA_BoardLineColor);
    [view addSubview:line];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, line.bottom, JA_SCREEN_WIDTH, 48)];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelBtn setTitle:@"确认" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:HEX_COLOR(0x444444) forState:UIControlStateNormal];
    [cancelBtn addTarget:view action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:cancelBtn];
    
    return view;

}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UIDatePicker *pickV = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, JA_SCREEN_WIDTH, 100)];
        [pickV addTarget:self action:@selector(dateChange:) forControlEvents:UIControlEventValueChanged];
        pickV.maximumDate = [self getMaxDate];
        self.pickV = pickV;
        pickV.datePickerMode = UIDatePickerModeDate;
        pickV.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [self addSubview:pickV];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 100, JA_SCREEN_WIDTH, 5)];
        line.backgroundColor = HEX_COLOR(JA_BoardLineColor);
        [self addSubview:line];
        
        UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, line.bottom, JA_SCREEN_WIDTH, 48)];
        cancelBtn.backgroundColor = [UIColor whiteColor];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [cancelBtn setTitle:@"确认" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:HEX_COLOR(0x444444) forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(onBackButton) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cancelBtn];
        
    }
    return self;
}

- (void)dateChange:(UIDatePicker *)pick
{
    _birthDay = pick.date;
}

- (void)setMinimumDate:(NSDate *)minimumDate
{
    _minimumDate = minimumDate;
    
    self.pickV.minimumDate = minimumDate;
}


- (NSDate *)getMaxDate
{
    NSDate * date = [NSDate date];
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSTimeInterval time = 12.0 * 365 * 24 * 60 * 60;//80年的秒数
    
    NSDate * lastYear = [date dateByAddingTimeInterval:-time];
    
    return lastYear;
}

@end
