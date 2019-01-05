//
//  JANewNotiSubHeaderView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/3/24.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANewNotiSubHeaderView : UIView
@property (nonatomic, strong) NSDictionary *dicModel;
@property (nonatomic, assign) NSInteger unReadCount;
@property (nonatomic, weak) UIView *lineView;
@end
