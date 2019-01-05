//
//  JARuleView.h
//  Jasmine
//
//  Created by moli-2017 on 2017/10/13.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JARuleViewCell.h"

@interface JARuleView : UIView
@property (nonatomic, strong) NSArray *dataArray;

- (instancetype)ruleViewWithType:(JARuleViewCellType)type;

@property (nonatomic, strong) void (^refreshHeight)(CGFloat height);
@property (nonatomic, assign) CGFloat myheight;
@end
