//
//  JAWaveView.m
//  Jasmine
//
//  Created by 刘宏亮 on 2018/5/23.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAWaveView.h"

#define kWaveLineWidth 1
#define kWaveMarginWidth 1.5
#define kProcessColor HEX_COLOR(0x6BD379)
#define kQuiteColor HEX_COLOR(0xcdcdcd)
#define kWaveLineHeight 20 //rect.size.height
#define kWaveLineHeightScale 0.1 // 最小线高比例

@interface JAWaveView ()
@property (nonatomic, weak) UIImageView *verticalLineImageView;  // 垂直的线

@property (nonatomic, strong) NSArray *totalPointArray;
@property (nonatomic, strong) NSMutableArray *drawPointArray;

@property (nonatomic, assign) NSInteger currentBeginPoint;

@property (nonatomic, assign) NSInteger nearNumber;     // 变色的临近点

@property (nonatomic, assign) NSInteger frontBeginP;    // 作用：消除因为浮点转整型时的误差

@end

@implementation JAWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        _drawPointArray = [NSMutableArray array];
        [self setupWaveViewUI];
    }
    return self;
}

- (void)setupWaveViewUI
{
    UIImageView *verticalLineImageView = [[UIImageView alloc] init];
    _verticalLineImageView = verticalLineImageView;
    verticalLineImageView.contentMode = UIViewContentModeScaleAspectFit;
    verticalLineImageView.image = [UIImage imageNamed:@"wave_vernier"];
    [self addSubview:verticalLineImageView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.verticalLineImageView.width = 5;
    self.verticalLineImageView.height = 60;
    self.verticalLineImageView.centerY = self.height * 0.5;
    
}

- (void)wave_animateWithTotalArray:(NSArray *)array progress:(CGFloat)progress
{
    if (progress == 0) {
        self.nearNumber = 0;
    }
    self.totalPointArray = array;
    NSInteger totalCount = array.count;
    
    // 计算一屏需要展示多少个点
    NSInteger screenCount = (NSInteger)(self.width / (kWaveLineWidth + kWaveMarginWidth));
    
    // 计算一屏展示的点占总值的百分比
    CGFloat screenProgress = screenCount / (CGFloat)totalCount;
    
    // 半屏的进度值
    CGFloat halfScreenProgress = screenProgress * 0.5;
    NSInteger halfScreenCount = floor(screenCount * 0.5);
    
    // 计算取值的开始点和结束点
    NSInteger beginP = (NSInteger)(totalCount * progress);
    beginP = (beginP - halfScreenCount) > 0 ? (beginP - halfScreenCount) : 0;
    
    // 动画形式1  ---------
    if (beginP > 0 && self.frontBeginP == beginP) {
        beginP = beginP + 1;
    }
    self.frontBeginP = beginP;
    // 记录屏幕开始的进度值
    if (self.currentBeginPoint != beginP || beginP == 0) {
        self.currentBeginPoint = beginP;
    }
    // 动画形式1  ---------
    
    // 动画形式2 ----------
//    if (beginP + screenCount <= self.totalPointArray.count) {
//        if (beginP > 0 && self.frontBeginP == beginP) {
//            beginP = beginP + 1;
//        }
//        self.frontBeginP = beginP;
//
//        // 记录屏幕开始的进度值
//        if (self.currentBeginPoint != beginP || beginP == 0) {
//            self.currentBeginPoint = beginP;
//        }
//    }else{
//        beginP = self.frontBeginP;
//
//        // 记录屏幕开始的进度值
//        if (self.currentBeginPoint != beginP || beginP == 0) {
//            self.currentBeginPoint = beginP;
//        }
//    }
    // 动画形式2 ----------
    
    
    NSInteger endP = beginP + screenCount;
    
    // 根据进度值从总数组中获取需要的点数
    [self getScreenWavePointWithBeginP:beginP endP:endP];
    
    // 需要变色的临近点
    NSInteger num = 0;
    if (progress < halfScreenProgress) {
        num = floor(self.totalPointArray.count * progress);
    }else{
        num = floor(self.totalPointArray.count * progress);
        num = num - self.currentBeginPoint;
    }
    
    if (num > self.nearNumber) {
        self.nearNumber = num;
    }
    
    self.verticalLineImageView.x = self.nearNumber * (kWaveLineWidth + kWaveMarginWidth);
    
    // 开始绘制
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (!self.drawPointArray.count) {
        return;
    }
    CGFloat drawBegin = 3;
    
    // 获取上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 获取需要变色的点
    for (NSInteger i = 0; i < self.drawPointArray.count; i++) {
        
        NSString *line = self.drawPointArray[i];
        if (line.floatValue < kWaveLineHeightScale) {
            line = [NSString stringWithFormat:@"%@",@(kWaveLineHeightScale)];
        }
        NSInteger lineNumber = line.floatValue * kWaveLineHeight;  // 线高
        
        // 设置线宽
        CGContextSetLineWidth(ctx, kWaveLineWidth);
        
        if (i < self.nearNumber) {  // 变色
            CGContextSetStrokeColorWithColor(ctx, kProcessColor.CGColor);
            CGContextMoveToPoint(ctx, drawBegin, (self.height - lineNumber) * 0.5);
            CGContextAddLineToPoint(ctx, drawBegin, (self.height + lineNumber) * 0.5);
            CGContextStrokePath(ctx);
        }else{   // 不变色
            CGContextSetStrokeColorWithColor(ctx, kQuiteColor.CGColor);// 545454
            CGContextMoveToPoint(ctx, drawBegin, (self.height - lineNumber) * 0.5);
            CGContextAddLineToPoint(ctx, drawBegin, (self.height + lineNumber) * 0.5);
            CGContextStrokePath(ctx);
        }
        drawBegin += (kWaveLineWidth + kWaveMarginWidth);
    }
}

- (void)getScreenWavePointWithBeginP:(NSInteger)beginP endP:(NSInteger)endP
{
    [self.drawPointArray removeAllObjects];
    
    [self.totalPointArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx >= beginP && idx <= endP) {
            
            [self.drawPointArray addObject:obj];
        }
    }];
}

@end
