//
//  UIButton+ReversalAnimation.h
//  AnimationBtnDemo
//
//  Created by Seven on 7/29/15.
//  Copyright (c) 2015 Seven. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ChangeBtnImgBlock) ();

@interface UIButton (ReversalAnimation)<CAAnimationDelegate>

@property (nonatomic, copy) ChangeBtnImgBlock changeImgBlock;

- (void)reversalBtnWithDuration:(CGFloat)duration;
- (void)changeTheImgWithBlock:(ChangeBtnImgBlock)block;
- (void)verticalImageAndTitle:(CGFloat)spacing;
@end
