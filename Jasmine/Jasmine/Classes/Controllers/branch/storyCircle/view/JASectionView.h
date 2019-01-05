//
//  JASectionView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JASectionView : UIView
@property (nonatomic, strong) NSString *name;  // 可以直接设置名字
@property (nonatomic, weak) UILabel *nameLabel; // 也可以直接修改控件
@property (nonatomic, weak) UIView *lineView;
@end
