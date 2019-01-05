
//
//  UIImage+JACategory.m
//  Jasmine
//
//  Created by xujin on 2018/6/6.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "UIImage+JACategory.h"

@implementation UIImage (JACategory)

- (UIImage *)ja_getScaleImage {
    CGSize newSize = CGSizeMake(self.size.width, self.size.height);
    CGFloat tempHeight = newSize.height / WIDTH_ADAPTER(390);
    CGFloat tempWidth = newSize.width / WIDTH_ADAPTER(280);
    if (tempHeight <= 1.0 && tempWidth <= 1.0) {
        return self;
    }
    if (tempWidth > 1.0 && tempWidth > tempHeight) {
        newSize = CGSizeMake(self.size.width / tempWidth, self.size.height / tempWidth);
    }
    else if (tempHeight >= 1.0 && tempWidth <= tempHeight){
        newSize = CGSizeMake(self.size.width / tempHeight, self.size.height / tempHeight);
    }
    NSInteger width = (NSInteger)newSize.width;
    NSInteger height = (NSInteger)newSize.height;
    UIGraphicsBeginImageContextWithOptions(newSize, NO, [[UIScreen mainScreen] scale]);
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [self drawInRect:CGRectMake(0,0,width,height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

@end
