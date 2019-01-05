//
//  JACircleInfoView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/6/27.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACircleInfoView : UIView
@property (nonatomic, strong) NSArray *dataSourceArray;
@property (nonatomic, weak) UIButton *followButton;
@property (nonatomic, weak) UIView *middleView;
@property (nonatomic, strong) JACircleModel *circleModel;
@end
