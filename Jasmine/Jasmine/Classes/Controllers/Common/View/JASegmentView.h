//
//  JASegmentView.h
//  Jasmine
//
//  Created by xujin on 20/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASegmentView : UIView

@property (nonatomic, copy) void (^selectedBlock)(NSUInteger index);

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) NSArray <NSString *> *titleArray;

@property (nonatomic, assign) CGFloat xOffset;

@property (nonatomic, assign) BOOL hiddenLine;
@end

