//
//  JANewPersonRelationView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JANewPersonRelationView : UIView
@property (nonatomic, strong) JAConsumer *model;  // 个人信息

@property (nonatomic, weak) UILabel *followLabel; // 关注
@property (nonatomic, weak) UILabel *fansLabel;   // 粉丝
@end
