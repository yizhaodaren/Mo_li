//
//  JAWordButton.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/6.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAWordButton.h"

@interface JAWordButton ()
@property (nonatomic, weak) UILabel *countLabel;
@property (nonatomic, weak) UILabel *nameLabel;
@end

@implementation JAWordButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UILabel *countL = [[UILabel alloc] init];
    countL.text = @"0";
    countL.textColor = HEX_COLOR(JA_BlackTitle);
    countL.font = JA_REGULAR_FONT(21);
    _countLabel = countL;
    [self addSubview:countL];
    
    UILabel *nameL = [[UILabel alloc] init];
    nameL.text = @"";
    nameL.textColor = HEX_COLOR(JA_BlackSubTitle);
    nameL.font = JA_REGULAR_FONT(12);
    _nameLabel = nameL;
    [self addSubview:nameL];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickButton:)];
    [self addGestureRecognizer:tap];
}

- (void)clickButton:(UITapGestureRecognizer *)tap
{
    if (self.clickButton) {
        self.clickButton();
    }
}

- (void)caculater:(CGFloat)scale
{
    [self.countLabel sizeToFit];
    self.countLabel.height = 29;
    self.countLabel.centerX = self.width * 0.5;
    self.countLabel.y = self.height * 0.5 - 0.5 - self.countLabel.height;
    
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 17;
    self.nameLabel.centerX = self.countLabel.centerX;
    self.nameLabel.y = self.height * 0.5 + 0.5;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self caculater:[self getScale]];
    
    
}

- (void)setCountString:(NSString *)countString
{
    _countString = countString;
    
    self.countLabel.text = countString;
    
    [self setNeedsLayout];
}

- (void)setNameString:(NSString *)nameString
{
    _nameString = nameString;
    
    self.nameLabel.text = nameString;
   [self setNeedsLayout];
}


- (CGFloat)getScale
{
    if ([UIScreen mainScreen].bounds.size.width == 375) {
        
        return 1;
    }else if ([UIScreen mainScreen].bounds.size.width == 414){
        return 414/375.0;
    }else{
        return 320 / 375.0;
    }
}
@end
