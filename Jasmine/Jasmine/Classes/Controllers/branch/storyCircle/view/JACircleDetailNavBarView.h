//
//  JACircleDetailNavBarView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JACircleDetailNavBarView : UIView
- (void)circleDetailNavBarView_changeInfoButtonToEdge:(BOOL)isEdge;
@property (nonatomic, assign) CGFloat offset;
@property (nonatomic, strong) NSString *titleName;

@property (nonatomic, weak) UIButton *backButton;  // 返回按钮
@property (nonatomic, weak) UIButton *infoButton;     // 圈子资料按钮
@end
