//
//  JATopSegment.m
//  Jasmine
//
//  Created by moli-2017 on 2017/5/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JATopSegment.h"
@interface JATopSegment()
@property (nonatomic, copy) void (^callBlock)(int);
@property (nonatomic, weak) UIButton *selectedBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, assign) CGFloat btnWidth;
@property (nonatomic, assign) CGFloat selFont;
@property (nonatomic, assign) CGFloat norFont;
@property (nonatomic, assign) BOOL isFirst;
@end

@implementation JATopSegment

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

#pragma mark - 3.0 Custom Method
- (void)setSubViewsWithTitleArray:(NSArray *)titleArrray norTextFont:(CGFloat)norFont selTextFont:(CGFloat)selFont norColor:(UIColor *)norColor selColor:(UIColor *)selColor hidBottomLine:(BOOL)hidBottomLine callBlock:(void (^)(int))callBlock {
    _isFirst = YES;
    self.callBlock = callBlock;
    self.norFont = norFont;
    self.selFont = selFont;
    
    self.btnWidth = self.width/(titleArrray.count+1);
    int i = 0;
    for (NSString *title in titleArrray) {
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.btnWidth * (i+.5), 0, self.btnWidth, self.height)];
        [button setTitle:title forState:UIControlStateNormal];
        [button setTitleColor:norColor forState:UIControlStateNormal];
        [button setTitleColor:selColor forState:UIControlStateSelected];
        [button.titleLabel setFont:[UIFont systemFontOfSize:norFont]];
        button.tag = 10000+i;
        if (button.tag == 10000) {
            self.selectedBtn = button;
            button.selected = YES;
            [self.selectedBtn.titleLabel setFont:[UIFont systemFontOfSize:selFont]];
        }
        i++;
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    
    [self addSubview:self.lineView];
    self.lineView.frame = CGRectMake(0, 0, 12, 2);
    self.lineView.backgroundColor = HEX_COLOR(JA_Green);
    self.lineView.center = CGPointMake(self.btnWidth, self.height-1);
    self.lineView.hidden = hidBottomLine;
    
    [self layoutIfNeeded];
}

- (void)btnClick:(UIButton *)sender {
    self.selectedSegmentIndex = (int)sender.tag - 10000;
    if (self.callBlock) {
        self.callBlock((int)sender.tag-10000);
    }
}

- (void)setButtonColorAndFont:(UIButton *)button {
    self.selectedBtn.selected = NO;
    CGFloat time = _isFirst ? 0 : 0.2;
    [UIView animateWithDuration:time animations:^{
        [self.selectedBtn.titleLabel setFont:[UIFont systemFontOfSize:self.norFont]];
        button.titleLabel.font = [UIFont systemFontOfSize:self.selFont];
        self.lineView.center = CGPointMake(self.btnWidth * (button.tag-10000+1), self.height-2);
    }];
    button.selected = YES;
    self.selectedBtn = button;
    _isFirst = NO;
}


#pragma mark - 1.0 Getter And Setter
- (void)setSelectedSegmentIndex:(int)selectedSegmentIndex {
    _selectedSegmentIndex = selectedSegmentIndex;
    
    UIButton *button = (UIButton *)[self viewWithTag:selectedSegmentIndex+10000];
    [self setButtonColorAndFont:button];
    [self layoutIfNeeded];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.hidden = YES;
    }
    return _lineView;
}
@end
