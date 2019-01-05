//
//  UIButton+ReversalAnimation.m
//  AnimationBtnDemo
//
//  Created by Seven on 7/29/15.
//  Copyright (c) 2015 Seven. All rights reserved.
//

#import "UIButton+ReversalAnimation.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>


static const void *ReversalAnimationKey = &ReversalAnimationKey;

@implementation UIButton (ReversalAnimation)

@dynamic changeImgBlock;


- (void)reversalBtnWithDuration:(CGFloat)duration
{
    NSLock *theLock = [[NSLock alloc] init];
    [theLock lock];
    CAKeyframeAnimation *reversalAnimation = [CAKeyframeAnimation animation];
    reversalAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,1,0)],
                                 [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI / 3, 0,1,0)],
                                 [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI * 2 / 3, 0,1,0)],
                                 [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI, 0,1,0)],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI * 4 / 3, 0,1,0)],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI * 5 / 3 , 0,1,0)],[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI * 2, 0,1,0)]];
    reversalAnimation.timingFunction =  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    reversalAnimation.cumulative = YES;
    reversalAnimation.duration = duration;
    reversalAnimation.removedOnCompletion = YES;
    reversalAnimation.delegate = self;
    
    
    [self.layer addAnimation:reversalAnimation forKey:@"transform"];
    [theLock unlock];
    

}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
        if (self.changeImgBlock) {
            self.changeImgBlock();
        }
}

- (void)changeTheImgWithBlock:(ChangeBtnImgBlock)block
{
    self.changeImgBlock = block;
}
- (void)verticalImageAndTitle:(CGFloat)spacing
{
    self.titleLabel.backgroundColor = [UIColor greenColor];
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    CGSize textSize = [self.titleLabel sizeThatFits:CGSizeMake(self.frame.size.width, self.frame.size.height/2)];
    
    CGSize frameSize = CGSizeMake(ceilf(textSize.width), ceilf(textSize.height));
    if (titleSize.width + 0.5 < frameSize.width)
    {
        titleSize.width = frameSize.width;
    }
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    self.titleEdgeInsets = UIEdgeInsetsMake(0, - imageSize.width, - (totalHeight - titleSize.height), 0);
    
}

// runtime 关联get,set方法
- (ChangeBtnImgBlock)changeImgBlock
{
    return objc_getAssociatedObject(self, ReversalAnimationKey);
}

- (void)setChangeImgBlock:(ChangeBtnImgBlock)changeImgBlock
{
    objc_setAssociatedObject(self, ReversalAnimationKey, changeImgBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}



@end
