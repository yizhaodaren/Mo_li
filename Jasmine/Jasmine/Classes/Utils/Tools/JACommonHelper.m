//
//  JACommonHelper.m
//  Jasmine
//
//  Created by xujin on 2018/6/14.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JACommonHelper.h"

@implementation JACommonHelper

+ (CGSize)getListImageSize:(CGSize)originalSize {
    return [self reSize:originalSize maxSize:CGSizeMake(JA_SCREEN_WIDTH*0.6, JA_SCREEN_WIDTH*0.6)];
}

+ (CGSize)reSize:(CGSize)originalSize maxSize:(CGSize)maxSize {
    CGSize imageSize = originalSize;
    CGFloat imageW = imageSize.width;
    CGFloat imageH = imageSize.height;
    CGFloat tempWidth = imageSize.width / maxSize.width;
    CGFloat tempHeight = imageSize.height / maxSize.height;
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        imageW = imageSize.width / tempWidth;
        imageH = imageSize.height / tempWidth;
    } else if (tempHeight >= 1.0 && tempWidth <= tempHeight){
        imageW = imageSize.width / tempHeight;
        imageH = imageSize.height / tempHeight;
    }
    return CGSizeMake(imageW, imageH);
}

@end
