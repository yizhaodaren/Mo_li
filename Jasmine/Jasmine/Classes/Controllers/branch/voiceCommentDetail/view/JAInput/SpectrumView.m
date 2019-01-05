//
//  SpectrumView.m
//  GYSpectrum
//
//  Created by 黄国裕 on 16/8/19.
//  Copyright © 2016年 黄国裕. All rights reserved.
//

#import "SpectrumView.h"

@interface SpectrumView ()

@property (nonatomic, strong) NSMutableArray * levels;
@property (nonatomic, strong) NSMutableArray * itemLineLayers;
@property (nonatomic) CGFloat itemHeight;
@property (nonatomic) CGFloat itemWidth;
@property (nonatomic) CGFloat lineWidth;//自适应


@property (nonatomic) NSUInteger numberOfItems;

@property (nonatomic) UIColor * itemColor;




@end

@implementation SpectrumView


- (id)init {
    NSLog(@"init");
    if(self = [super init]) {
        [self setup];
    }
    
    return self;
}



- (id)initWithFrame:(CGRect)frame {
    NSLog(@"initWithFrame");
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"awakeFromNib");
    [self setup];
}

- (void)setup {
    
    NSLog(@"setup");

    self.numberOfItems = 20.f;//偶数

    self.itemColor = HEX_COLOR(0x54C7FC);

    self.middleInterval = 100.f;
    
}

- (void)setMiddleInterval:(CGFloat)middleInterval
{
    _middleInterval = middleInterval;
    
    [self layoutIfNeeded];
    [self setNeedsLayout];
}

#pragma mark - layout

- (void)layoutSubviews {
    [super layoutSubviews];

    self.itemHeight = CGRectGetHeight(self.bounds);
    self.itemWidth = CGRectGetWidth(self.bounds);

    self.lineWidth = (self.itemWidth - self.middleInterval) / 2.f / self.numberOfItems;
}

#pragma mark - setter

- (void)setItemColor:(UIColor *)itemColor {
    _itemColor = itemColor;
    for (CAShapeLayer *itemLine in self.itemLineLayers) {
        itemLine.strokeColor = [self.itemColor CGColor];
    }
}

- (void)setNumberOfItems:(NSUInteger)numberOfItems {
    if (_numberOfItems == numberOfItems) {
        return;
    }
    _numberOfItems = numberOfItems;

    self.levels = [[NSMutableArray alloc]init];
    for(int i = 0 ; i < self.numberOfItems / 2 ; i++){
        [self.levels addObject:@(0)];
    }


    for (CAShapeLayer *itemLine in self.itemLineLayers) {
        [itemLine removeFromSuperlayer];
    }
    self.itemLineLayers = [NSMutableArray array];
    for(int i=0; i < numberOfItems; i++) {
        CAShapeLayer *itemLine = [CAShapeLayer layer];
        itemLine.lineCap       = kCALineCapButt;
        itemLine.lineJoin      = kCALineJoinRound;
        itemLine.strokeColor   = [[UIColor clearColor] CGColor];
        itemLine.fillColor     = [[UIColor clearColor] CGColor];
        itemLine.strokeColor   = [self.itemColor CGColor];
        itemLine.lineWidth     = self.lineWidth;

        [self.layer addSublayer:itemLine];
        [self.itemLineLayers addObject:itemLine];
    }
}

- (void)setLineWidth:(CGFloat)lineWidth {
    if (_lineWidth != lineWidth) {
        _lineWidth = lineWidth;
        for (CAShapeLayer *itemLine in self.itemLineLayers) {
            itemLine.lineWidth = lineWidth;
        }
    }
}

- (void)setLevel:(CGFloat)level {
    
//    level = (level+37.5)*3.2;

    if( level < 0 ) level = 0;
    
    [self.levels removeObjectAtIndex:self.numberOfItems/2-1];
    
    [self.levels insertObject:@(level) atIndex:0];
    
    [self updateItems];
}

#pragma mark - update

- (void)updateItems {
    //NSLog(@"updateMeters");

    UIGraphicsBeginImageContext(self.frame.size);

    int lineOffset = self.lineWidth * 2.f;

    int leftX = (self.itemWidth - self.middleInterval + self.lineWidth) / 2.f;
    int rightX = (self.itemWidth + self.middleInterval - self.lineWidth) / 2.f;


    for(int i = 0; i < self.numberOfItems / 2; i++) {

        CGFloat lineHeight = self.lineWidth + [self.levels[i] floatValue] * self.lineWidth / 2.f;
        
        CGFloat lineTop = (self.itemHeight - lineHeight) / 2.f;
        CGFloat lineBottom = (self.itemHeight + lineHeight) / 2.f;


        leftX -= lineOffset;

        UIBezierPath *linePathLeft = [UIBezierPath bezierPath];
        [linePathLeft moveToPoint:CGPointMake(leftX, lineTop)];
        [linePathLeft addLineToPoint:CGPointMake(leftX, lineBottom)];
        CAShapeLayer *itemLine2 = [self.itemLineLayers objectAtIndex:i + self.numberOfItems / 2];
        itemLine2.path = [linePathLeft CGPath];


        rightX += lineOffset;

        UIBezierPath *linePathRight = [UIBezierPath bezierPath];
        [linePathRight moveToPoint:CGPointMake(rightX, lineTop)];
        [linePathRight addLineToPoint:CGPointMake(rightX, lineBottom)];
        CAShapeLayer *itemLine = [self.itemLineLayers objectAtIndex:i];
        itemLine.path = [linePathRight CGPath];
    }
    
    UIGraphicsEndImageContext();
}


@end
