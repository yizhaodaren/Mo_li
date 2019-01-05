//
//  JACircleDetailHeadView.h
//  Jasmine
//
//  Created by moli-2017 on 2018/5/26.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JACircleModel.h"

@class JACircleDetailHeadView;
@protocol JACircleDetailHeadViewDelegate <NSObject>
- (void)circleDetailHeadView_didSelectWithRow:(NSInteger)row headView:(JACircleDetailHeadView *)headView;
@end

@interface JACircleDetailHeadView : UIView

@property (nonatomic, weak) UIButton *focusButton;          // 关注圈子按钮

@property (nonatomic, strong) NSArray *topVoiceArray;  // 置顶帖数据源
@property (nonatomic, strong) JACircleModel *infoModel;  // 圈子信息model

@property (nonatomic, assign) CGFloat offset;

@property (nonatomic, weak) id <JACircleDetailHeadViewDelegate> delegate;
@end
