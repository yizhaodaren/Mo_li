//
//  MenuPopOverButton.m
//  Jasmine
//
//  Created by moli-2017 on 2017/8/3.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "MenuPopOverButton.h"

@implementation MenuPopOverButton

/**
 *  设置button的图片和Title label位置
 */
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    if (self.imageView) {
        
        self.imageView.width = 30;
        self.imageView.centerX = self.width * 0.5;
        self.imageView.height = self.imageView.width;
        self.imageView.contentMode = UIViewContentModeCenter;
        self.imageView.y = 3;
        [self.titleLabel sizeToFit];
        self.titleLabel.centerX = self.width * 0.5;
        self.titleLabel.y = self.imageView.bottom;
    }
    
}

@end
