//
//  JAScrollMarkView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAScrollMarkView;
@protocol JAScrollMarkViewDelegate <NSObject>
- (void)scrollMarkViewClickMarkWithIndex:(NSInteger)index scrollMarkView:(JAScrollMarkView *)markView;
@end

@interface JAScrollMarkView : UIView
@property (nonatomic, strong) NSArray *markArray;
@property (nonatomic, weak) id <JAScrollMarkViewDelegate> delegate;

// 设置位置
- (void)scrollMarkWithIndex:(NSInteger)index animate:(BOOL)animate;
@end

@interface JAMarkImageView : UIView

@end
