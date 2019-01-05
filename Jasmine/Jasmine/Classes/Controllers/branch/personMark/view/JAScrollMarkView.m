//
//  JAScrollMarkView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/17.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAScrollMarkView.h"
#import "JAMarkLineView.h"

#import "JAMarkModel.h"
#import <NSButton+WebCache.h>

@interface JAMarkImageView ()
@property (nonatomic, strong) JAMarkModel *model;
@property (nonatomic, weak) UIView *backView;
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation JAMarkImageView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupMarkImageViewUI];
    }
    return self;
}

- (void)setModel:(JAMarkModel *)model
{
    _model = model;
    if (model.crownStatus.integerValue == 1) {
        [self.imageView ja_setImageWithURLStr:model.lightImage];
        self.backView.backgroundColor = HEX_COLOR(0xDFFFBF);
        self.backView.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
        self.backView.layer.borderWidth = 2;
    }else{
        [self.imageView ja_setImageWithURLStr:model.darkImage];
        self.backView.backgroundColor = HEX_COLOR(0xE2E2E2);
        self.backView.layer.borderColor = HEX_COLOR(0xE2E2E2).CGColor;
        self.backView.layer.borderWidth = 0;
    }
}

- (void)setupMarkImageViewUI
{
    UIView *backView = [[UIView alloc] init];
    _backView = backView;
    backView.backgroundColor = HEX_COLOR(0xE2E2E2);
    backView.layer.borderColor = HEX_COLOR(0xE2E2E2).CGColor;
    backView.layer.borderWidth = 0;
    [self addSubview:backView];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:imageView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorMarkImageViewFrame];
}

- (void)calculatorMarkImageViewFrame
{
    self.backView.width = self.width;
    self.backView.height = self.height;
    self.backView.layer.cornerRadius = self.backView.height * 0.5;
    self.backView.layer.masksToBounds = YES;
    
    self.imageView.width = 32;
    self.imageView.height = 39;
    self.imageView.centerX = self.width * 0.5;
    self.imageView.centerY = self.height * 0.5;
}
@end

@interface JAScrollMarkView ()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *lineViewArray;
@property (nonatomic, strong) NSMutableArray *markImageViewArray;
@property (nonatomic, strong) NSMutableArray *markLabelArray;

@property (nonatomic, weak) UIView *pointView; // 初始的圆点view
@end
@implementation JAScrollMarkView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lineViewArray = [NSMutableArray array];
        _markImageViewArray = [NSMutableArray array];
        _markLabelArray = [NSMutableArray array];
        
        [self setupScrollMarkViewUI];
    }
    return self;
}

#pragma mark - 设置位置
// 设置位置
- (void)scrollMarkWithIndex:(NSInteger)index animate:(BOOL)animate
{
    CGFloat lineWidth = JA_SCREEN_WIDTH * 0.5 - 30 - 7;
    [self.scrollView setContentOffset:CGPointMake((index) * lineWidth - 30, 0) animated:animate];
}

#pragma mark - 点击头衔
- (void)clickMarkAction:(UIGestureRecognizer *)tap
{
    UIView *v = tap.view;
    
    if ([self.delegate respondsToSelector:@selector(scrollMarkViewClickMarkWithIndex:scrollMarkView:)]) {
        [self.delegate scrollMarkViewClickMarkWithIndex:v.tag scrollMarkView:self];
    }
    
    CGFloat lineWidth = JA_SCREEN_WIDTH * 0.5 - 30 - 7;
    [self.scrollView setContentOffset:CGPointMake((v.tag - 1) * lineWidth - 30, 0) animated:YES];
}

#pragma mark - UI
- (void)setupScrollMarkViewUI
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    _scrollView = scrollView;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.scrollEnabled = NO;
    [self addSubview:scrollView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorScrollMarkViewFrame];
}

- (void)calculatorScrollMarkViewFrame
{
    self.scrollView.width = self.width;
    self.scrollView.height = self.height;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, 30, 0, 30);
    
    // 计算线长
    CGFloat lineWidth = JA_SCREEN_WIDTH * 0.5 - 30 - 7;
    CGFloat lineHeight = 2;
    
    self.pointView.width = 14;
    self.pointView.height = 14;
    self.pointView.y = 47;
    
    for (NSInteger i = 0; i < self.lineViewArray.count; i++) {
        JAMarkLineView *lineV = self.lineViewArray[i];
        lineV.width = lineWidth;
        lineV.height = lineHeight;
        lineV.centerY = self.pointView.centerY;
        lineV.x = 7 + i * lineWidth;
        
        lineV.markModel = self.markArray[i];
    }
    
    for (NSInteger i = 0; i < self.markImageViewArray.count; i++) {
        UIImageView *markI = self.markImageViewArray[i];
        UILabel *markL = self.markLabelArray[i];
        markI.tag = i + 1;
        markI.width = 44;
        markI.height = 44;
        markI.centerY = self.pointView.centerY;
        markI.centerX = 7 + lineWidth * (i + 1);
//        markI.layer.cornerRadius = 22;
//        markI.layer.masksToBounds = YES;
        
        markL.tag = i + 1;
        [markL sizeToFit];
        markL.height = 38;
        markL.y = markI.bottom;
        markL.centerX = markI.centerX;
    }
    
    UIButton *lastB = self.markLabelArray.lastObject;
    
    self.scrollView.contentSize = CGSizeMake(lastB.right, 0);
}

#pragma mark - 赋值
- (void)setMarkArray:(NSArray *)markArray
{
    _markArray = markArray;
//    for (NSInteger i = 0; i < markArray.count; i++) {
//        JAMarkModel *model = markArray[i];
////        if (i == 0 ||
////            i == 1 ||
////            i == 2 ||
////            i == 3 ||
////            i == 4 ||
////            i == 5) {
////            model.crownStatus = @"1";
////            for (NSInteger j = 0 ; j < model.tasks.count ; j++) {
////                JAMarkTaskModel *m = model.tasks[j];
////                m.taskStatus = @"1";
////                if (j < 4) {
////                }
////            }
////        }
//        model.crownStatus = @"1";
//        for (NSInteger j = 0 ; j < model.tasks.count ; j++) {
//            JAMarkTaskModel *m = model.tasks[j];
//            m.taskStatus = @"1";
//            if (j < 4) {
//            }
//        }
//    }
    for (NSInteger i = 0; i < markArray.count; i++) {
        
        // 创建线
        JAMarkLineView *lineView = [[JAMarkLineView alloc] init];
        [self.scrollView addSubview:lineView];
        lineView.backgroundColor = HEX_COLOR(0xE2E2E2);
        [self.lineViewArray addObject:lineView];
    }
    
    for (NSInteger i = 0; i < markArray.count; i++) {
        JAMarkModel *model = markArray[i];
        JAMarkImageView *markImageView = [[JAMarkImageView alloc] init];
        [self.scrollView addSubview:markImageView];
        markImageView.model = model;
        [self.markImageViewArray addObject:markImageView];
        UITapGestureRecognizer *markITap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMarkAction:)];
        [markImageView addGestureRecognizer:markITap];
    }
    
    for (NSInteger i = 0; i < markArray.count; i++) {
        JAMarkModel *model = markArray[i];
        
        // 创建markLabel
        UILabel *markLabel = [[UILabel alloc] init];
        [self.scrollView addSubview:markLabel];
        markLabel.userInteractionEnabled = YES;
        markLabel.text = model.name;
        if (model.crownStatus.integerValue == 1) {
            markLabel.textColor = HEX_COLOR(0x363636);
        }else{
            markLabel.textColor = HEX_COLOR(0x9B9B9B);
        }
        markLabel.font = JA_REGULAR_FONT(13);
        [self.markLabelArray addObject:markLabel];
        UITapGestureRecognizer *markLTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMarkAction:)];
        [markLabel addGestureRecognizer:markLTap];
    }
    
    UIView *pointView = [[UIView alloc] init];
    _pointView = pointView;
    pointView.backgroundColor = HEX_COLOR(0xDFFFBF);
    pointView.layer.borderColor = HEX_COLOR(0x6BD379).CGColor;
    pointView.layer.borderWidth = 2;
    pointView.layer.cornerRadius = 7;
    pointView.layer.masksToBounds = YES;
    [self.scrollView addSubview:pointView];
    
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
@end
