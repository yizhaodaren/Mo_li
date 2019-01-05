//
//  JAMessageRedButton.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/3.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAMessageRedButton.h"

@interface JAMessageRedButton ()

@property (nonatomic, weak) UIView *redView;

@end

@implementation JAMessageRedButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIView *redView = [[UIView alloc] init];
        _redView = redView;
        redView.hidden = YES;
        redView.backgroundColor = HEX_COLOR(0xFF3B30);
        [self addSubview:redView];
        
        self.titleLabel.font = JA_REGULAR_FONT(16);
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.redView.x = self.titleLabel.right;
    self.redView.y = self.titleLabel.top - 1;
    self.redView.width = 6;
    self.redView.height = 6;
    self.redView.layer.cornerRadius = self.redView.height * 0.5;
    self.redView.clipsToBounds = YES;
}


- (void)setShowRed:(BOOL)showRed
{
    _showRed = showRed;
    if (showRed) {
        self.redView.hidden = NO;
    }else{
        self.redView.hidden = YES;
    }
}
@end
