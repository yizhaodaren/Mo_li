//
//  JATopSegment.h
//  Jasmine
//
//  Created by moli-2017 on 2017/5/23.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JATopSegment : UIView

@property (nonatomic, assign) int selectedSegmentIndex;
- (void)setSubViewsWithTitleArray:(NSArray *)titleArrray norTextFont:(CGFloat)norFont selTextFont:(CGFloat)selFont norColor:(UIColor *)norColor selColor:(UIColor *)selColor hidBottomLine:(BOOL)hidBottomLine callBlock:(void (^)(int index))callBlock;

@end
