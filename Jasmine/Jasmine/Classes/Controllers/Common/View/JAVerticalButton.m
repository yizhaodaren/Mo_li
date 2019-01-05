//
//  JAVerticalButton.m
//  Jasmine
//
//  Created by moli-2017 on 2017/6/10.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAVerticalButton.h"

@implementation JAVerticalButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
       [self setTitleColor:HEX_COLOR(JA_BlackSubTitle) forState:UIControlStateNormal];
        
        self.titleLabel.font = JA_REGULAR_FONT(12);
        
    }
    return self;
}

/**
 *  设置button的图片和Title label位置
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
   
    if (self.imageView) {
        
        self.imageView.width = 17;
        self.imageView.centerX = self.width * 0.5;
        self.imageView.height = self.imageView.width;
        self.imageView.contentMode = UIViewContentModeCenter;
//        self.imageView.clipsToBounds = NO;
        
        self.imageView.y = 8;
        
        [self.titleLabel sizeToFit];
        self.titleLabel.centerX = self.width * 0.5;
        self.titleLabel.y = self.imageView.bottom + 2;
    }
    
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (self.needHighlight) {
        [super setHighlighted:highlighted];
    }
    
    self.needHighlight = NO;
}


@end
