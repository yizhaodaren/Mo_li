//
//  JAPlayWaveView.m
//  Jasmine
//
//  Created by xujin on 30/08/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAPlayWaveView.h"

@interface JAPlayWaveView ()

@property (nonatomic, strong) CALayer *firstLayer;
@property (nonatomic, strong) CALayer *secondLayer;
@property (nonatomic, strong) CALayer *thirdLayer;
@property (nonatomic, strong) CALayer *forthLayer;

@end

@implementation JAPlayWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        CALayer *aLayer = [CALayer layer];
        aLayer.frame = CGRectMake(0, 10, 2, 20);
        aLayer.backgroundColor = HEX_COLOR(JA_Green).CGColor;
        [self.layer addSublayer:aLayer];
        self.firstLayer = aLayer;
        
        CALayer *aLayer1 = [CALayer layer];
        aLayer1.frame = CGRectMake(2+3, 0, 2, 20);
        aLayer1.backgroundColor = HEX_COLOR(JA_Green).CGColor;
        [self.layer addSublayer:aLayer1];
        self.secondLayer = aLayer1;

        CALayer *aLayer2 = [CALayer layer];
        aLayer2.frame = CGRectMake(2+3+2+3, 5, 2, 20);
        aLayer2.backgroundColor = HEX_COLOR(JA_Green).CGColor;
        [self.layer addSublayer:aLayer2];
        self.thirdLayer = aLayer2;

        CALayer *aLayer3 = [CALayer layer];
        aLayer3.frame = CGRectMake(2+3+2+3+2+3, 15, 2, 20);
        aLayer3.backgroundColor = HEX_COLOR(JA_Green).CGColor;
        [self.layer addSublayer:aLayer3];
        self.forthLayer = aLayer3;
    }
    return self;
}

- (void)startAnimation {
    self.isAnimation = YES;
    
    CABasicAnimation *musicAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    musicAnimation.autoreverses = YES;
    musicAnimation.repeatCount = MAXFLOAT;
    musicAnimation.removedOnCompletion = NO;

    musicAnimation.duration = 0.35;
    musicAnimation.fromValue = @(10+self.height/2.0);
    musicAnimation.toValue = @(15+self.height/2.0);
    [self.firstLayer addAnimation:musicAnimation forKey:nil];
    
    musicAnimation.duration = 0.25;
    musicAnimation.fromValue = @(0+self.height/2.0);
    musicAnimation.toValue = @(10+self.height/2.0);
    [self.secondLayer addAnimation:musicAnimation forKey:nil];
    
    musicAnimation.duration = 0.35;
    musicAnimation.fromValue = @(5+self.height/2.0);
    musicAnimation.toValue = @(15+self.height/2.0);
    [self.thirdLayer addAnimation:musicAnimation forKey:nil];
    
    musicAnimation.duration = 0.35;
    musicAnimation.fromValue = @(15+self.height/2.0);
    musicAnimation.toValue = @(5+self.height/2.0);
    [self.forthLayer addAnimation:musicAnimation forKey:nil];

}

- (void)stopAnimation {
    self.isAnimation = NO;
    
    [self.firstLayer removeAllAnimations];
    [self.secondLayer removeAllAnimations];
    [self.thirdLayer removeAllAnimations];
    [self.forthLayer removeAllAnimations];
}

@end
