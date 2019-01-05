//
//  XFStepView.m
//  SCPay
//
//  Created by weihongfang on 2017/6/26.
//  Copyright © 2017年 weihongfang. All rights reserved.
//

#import "XFStepView.h"
#import "JASignAwardView.h"

@interface XFStepView()

@property (nonatomic, retain)NSArray * _Nonnull titles;

@property (nonatomic, strong)UIView *lineUndo;
@property (nonatomic, strong)UIView *lineDone;

@property (nonatomic, retain)NSMutableArray *cricleMarks;
@property (nonatomic, retain)NSMutableArray *titleLabels;
@property (nonatomic, retain)NSMutableArray *awardButtons;  // 奖励button


@end


@implementation XFStepView

- (instancetype)initWithFrame:(CGRect)frame Titles:(nonnull NSArray *)titles
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _stepIndex = -1;
        
        _titles = titles;
        
        _lineUndo = [[UIView alloc]init];
        _lineUndo.backgroundColor = HEX_COLOR(0x454C57);
        [self addSubview:_lineUndo];
        
        _lineDone = [[UIView alloc]init];
        _lineDone.backgroundColor = HEX_COLOR(0x6BD379);
        [self addSubview:_lineDone];
        
        for (NSString *title in _titles)
        {
            UILabel *lbl = [[UILabel alloc]init];
            lbl.text = title;
            lbl.textColor = HEX_COLOR(0x4A4A4A);
            lbl.font = JA_REGULAR_FONT(12);
            lbl.textAlignment = NSTextAlignmentCenter;
            [self addSubview:lbl];
            [self.titleLabels addObject:lbl];
            
            UIView *cricle = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 12, 12)];
            cricle.backgroundColor = [UIColor whiteColor];
            cricle.layer.cornerRadius = 12.0f / 2;
            cricle.layer.borderColor = HEX_COLOR(0x454C57).CGColor;
            cricle.layer.borderWidth = 2;
            [self addSubview:cricle];
            [self.cricleMarks addObject:cricle];
            
            JASignAwardView *award = [[JASignAwardView alloc] init];
            award.select = NO;
            [self addSubview:award];
            [self.awardButtons addObject:award];
        }
        
    }
    return self;
}

#pragma mark - method

- (void)layoutSubviews
{
    NSInteger perWidth = self.frame.size.width / self.titles.count;
    
    _lineUndo.frame = CGRectMake(0, 0, self.frame.size.width - perWidth, 2);
    _lineUndo.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height * 0.5 + 10);
    
    CGFloat startX = _lineUndo.frame.origin.x;
    
    for (int i = 0; i < _titles.count; i++)
    {
        UIView *cricle = [_cricleMarks objectAtIndex:i];
        if (cricle != nil)
        {
            cricle.center = CGPointMake(i * perWidth + startX, _lineUndo.center.y);
        }
        
        UILabel *lbl = [_titleLabels objectAtIndex:i];
        if (lbl != nil)
        {
            lbl.frame = CGRectMake(perWidth * i, _lineUndo.bottom + 9, self.frame.size.width / _titles.count, 17);
        }
        
        JASignAwardView *award = [_awardButtons objectAtIndex:i];
        if (award != nil) {
            
            award.centerX = cricle.centerX;
            award.y = _lineUndo.y - 3 - award.height;
        }
    }
    
    self.stepIndex = _stepIndex;
}

- (NSMutableArray *)cricleMarks
{
    if (_cricleMarks == nil)
    {
        _cricleMarks = [NSMutableArray arrayWithCapacity:self.titles.count];
    }
    return _cricleMarks;
}

- (NSMutableArray *)titleLabels
{
    if (_titleLabels == nil)
    {
        _titleLabels = [NSMutableArray arrayWithCapacity:self.titles.count];
    }
    return _titleLabels;
}

- (NSMutableArray *)awardButtons
{
    if (_awardButtons == nil) {
        
        _awardButtons = [NSMutableArray arrayWithCapacity:self.titles.count];
    }
    
    return _awardButtons;
}


- (void)setDayTitleArray:(NSArray *)dayTitleArray
{
    _dayTitleArray = dayTitleArray;
    _titles = dayTitleArray;
    
    for (NSInteger i = 0; i < self.titleLabels.count; i++) {
        UILabel *label = self.titleLabels[i];
        
        label.text = [NSString stringWithFormat:@"%@天",dayTitleArray[i]];
       
    }
}

- (void)setFlowerArrays:(NSArray *)flowerArrays
{
    _flowerArrays = flowerArrays;
    
    for (NSInteger i = 0; i < self.flowerArrays.count; i++) {
        JASignAwardView *award = self.awardButtons[i];
        
        NSString *str = [NSString stringWithFormat:@"%@",self.flowerArrays[i]];
        award.flowerCountString = str;
        if ([str isEqualToString:@"红包"]) {
            award.isPacket = YES;
        }else{
            award.isPacket = NO;
        }
    }
    
}

#pragma mark - public method

- (void)setStepIndex:(int)stepIndex
{
    if (stepIndex >= 0 && stepIndex < self.titles.count)
    {
        _stepIndex = stepIndex;
        
        _lineDone.hidden = NO;   // 方案2
        
        CGFloat perWidth = self.frame.size.width / _titles.count;

        _lineDone.frame = CGRectMake(_lineUndo.frame.origin.x, _lineUndo.frame.origin.y, perWidth * _stepIndex, _lineUndo.frame.size.height);
        
        for (int i = 0; i < _titles.count; i++)
        {
            UIView *cricle = [_cricleMarks objectAtIndex:i];
            if (cricle != nil)
            {
                if (i <= _stepIndex)
                {
                    cricle.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
                    
                }
                else
                {
                    cricle.layer.borderColor = HEX_COLOR(0x454C57).CGColor;
                }
            }
            
            UILabel *lbl = [_titleLabels objectAtIndex:i];
            if (lbl != nil)
            {
                if (i <= stepIndex)
                {
                    lbl.textColor = HEX_COLOR(0x4A4A4A);
                }
                else
                {
                    lbl.textColor = HEX_COLOR(0x4A4A4A);
                }
            }
            
            JASignAwardView *award = [_awardButtons objectAtIndex:i];
            
            if (award != nil) {
                
                if (i == stepIndex) {
                    award.select = YES;
                }else{
                    award.select = NO;
                }
            }
        }
    }
    else{   // 方案2
        
        // 还原
        _lineDone.hidden = YES;
        
        for (int i = 0; i < _titles.count; i++)
        {
            UIView *cricle = [_cricleMarks objectAtIndex:i];
            if (cricle != nil)
            {
                cricle.layer.borderColor = HEX_COLOR(0x454C57).CGColor;
            }
            
            JASignAwardView *award = [_awardButtons objectAtIndex:i];
            
            if (award != nil) {
                award.select = NO;
            }
        }
    }
}

- (void)setStepIndex:(int)stepIndex Animation:(BOOL)animation
{
    if (stepIndex >= 0 && stepIndex < self.titles.count)
    {
        if (animation)
        {
            [UIView animateWithDuration:0.5 animations:^{
                self.stepIndex = stepIndex;
            }];
        }
        else
        {
            self.stepIndex = stepIndex;
        }
    }
}


@end
