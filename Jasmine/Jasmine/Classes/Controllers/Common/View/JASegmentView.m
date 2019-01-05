//
//  JASegmentView.m
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JASegmentView.h"


#define TAG_SELECT_BUTTON 100

@interface JASegmentView ()

@property (nonatomic, strong) UILabel *sliderLine;

@end

@implementation JASegmentView

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.xOffset = 10;
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews
{
    CGFloat width = self.width/4 - 10;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((width - 35)/2, self.height - 2, 12, 2)];
    label.backgroundColor = HEX_COLOR(JA_Green);
    [self addSubview:label];
    self.sliderLine = label;
    
}

- (void)setHiddenLine:(BOOL)hiddenLine
{
    _hiddenLine = hiddenLine;
    
    self.sliderLine.hidden = hiddenLine;
    
}

- (void)setTitleArray:(NSArray<NSString *> *)titleArray
{
    NSUInteger count = titleArray.count;
    
    CGFloat width = self.width/count - self.xOffset;
    
    
    CGFloat x =  (self.width - width * count)/2;
    
    self.sliderLine.x = x + (width - self.sliderLine.width)/2;
    
    for (int i = 0; i < count; i++)
    {
        NSString *title = titleArray[i];
        [self buttonWithX:x width:width title:title tag:TAG_SELECT_BUTTON + i];
        x += width;
    }
    
}


- (UIButton *)buttonWithX:(CGFloat)x  width:(CGFloat)width title:(NSString *)title tag:(NSInteger)tag
{

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(x, 0, width, self.height);
    [button setTitle:title forState:UIControlStateNormal];
    button.tag = tag;
    if (tag - TAG_SELECT_BUTTON == 0) {
        button.selected = YES;
    }
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [button setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
    [button setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateSelected];
    [button addTarget:self action:@selector(buttonResponseAction:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self addSubview:button];
    
    return button;
}
- (void)buttonResponseAction:(UIButton *)button
{
    self.selectIndex = button.tag - TAG_SELECT_BUTTON;
    if (self.selectedBlock)
    {
        self.selectedBlock(_selectIndex);
    }
}

- (void)setSelectIndex:(NSInteger)selectIndex
{
    _selectIndex = selectIndex;
    for (UIView *view in self.subviews)
    {
        if ([view isKindOfClass:[UIButton class]])
        {
            UIButton *button = (UIButton *)view;
            if (selectIndex + TAG_SELECT_BUTTON == button.tag)
            {
                button.selected = YES;
                
                [UIView animateWithDuration:0.2 animations:^{
                    self.sliderLine.x = button.x + (button.width - self.sliderLine.width)/2;
                }];
                
            }
            else
            {
                button.selected = NO;
            }
        }
    }
}
@end
