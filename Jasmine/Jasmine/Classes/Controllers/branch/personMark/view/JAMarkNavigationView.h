//
//  JAMarkNavigationView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMarkNavigationView : UIView
@property (nonatomic, weak) UIButton *leftButton;
@property (nonatomic, strong) NSString *titleName;
@property (nonatomic, weak) UIButton *rightButton;

@property (nonatomic, assign) CGFloat offset;

- (void)markNavBarView_changeInfoButtonToEdge:(BOOL)isEdge;
@end
