//
//  JAGetMedlController.h
//  Jasmine
//
//  Created by 王树超 on 2018/7/13.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAMedalGroupModel.h"


@protocol JAGetMedalDelegate<NSObject>

@required
-(void)showNextMedal;//展示下一个未读的勋章
-(void)refreshMedalList;
@end

@interface JAGetMedlController : UIViewController
@property(nonatomic,assign)id<JAGetMedalDelegate> delegate;

+(instancetype)shared;

//更新数据
-(void)updateArrayWith:(JAMedalGroupModel *)model;

//动画
- (void)showAnimation:(BOOL)isAnimation;
- (void)dismissForAnimated:(BOOL)animated;
@end
