//
//  JAMineWordView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/5/4.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAMineWordView.h"


@interface JAMineWordView ()

@property (nonatomic, weak) UILabel *countLabel;
@property (nonatomic, weak) UILabel *wordLabel;

@end

@implementation JAMineWordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMineWordView];
    }
    return self;
}

- (void)setupMineWordView
{
    UILabel *countLabel = [[UILabel alloc] init];
    _countLabel = countLabel;
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.textColor = HEX_COLOR(0x454C57);
    countLabel.font = JA_REGULAR_FONT(21);
    [self addSubview:countLabel];
    
    UILabel *wordLabel = [[UILabel alloc] init];
    _wordLabel = wordLabel;
    wordLabel.textAlignment = NSTextAlignmentCenter;
    wordLabel.textColor = HEX_COLOR(JA_BlackSubTitle);
    wordLabel.font = JA_REGULAR_FONT(13);
    [self addSubview:wordLabel];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self caculatorMineWordView];
}

- (void)caculatorMineWordView
{
    [self.countLabel sizeToFit];
    [self.wordLabel sizeToFit];
    self.countLabel.centerX = self.width * 0.5;
    self.countLabel.y = self.height * 0.5 - self.countLabel.height + 10;
    
    self.wordLabel.centerX = self.width * 0.5;
    self.wordLabel.y = self.height * 0.5 + 10;
    
    if (self.countLabel.width > self.width) {
        self.countLabel.width = self.width;
    }
    
    if (self.wordLabel.width > self.width) {
        self.wordLabel.width = self.width;
    }
}

- (void)setTopWord:(NSString *)topWord
{
    _topWord = topWord;
    self.countLabel.text = topWord;
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)setTopWordFont:(UIFont *)topWordFont
{
    _topWordFont = topWordFont;
    
    self.countLabel.font = topWordFont;
}

- (void)setTopWordColor:(UIColor *)topWordColor
{
    _topWordColor = topWordColor;
    self.countLabel.textColor = topWordColor;
}

- (void)setBottomWord:(NSString *)bottomWord
{
    _bottomWord = bottomWord;
    self.wordLabel.text = bottomWord;
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

- (void)setBottomWordFont:(UIFont *)bottomWordFont
{
    _bottomWordFont = bottomWordFont;
    self.wordLabel.font = bottomWordFont;
}

- (void)setBottomWordColor:(UIColor *)bottomWordColor
{
    _bottomWordColor = bottomWordColor;
    self.wordLabel.textColor = bottomWordColor;
}
@end
