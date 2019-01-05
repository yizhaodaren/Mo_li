

//
//  JANewPlayWaveView.m
//  Jasmine
//
//  Created by xujin on 20/01/2018.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JANewPlayWaveView.h"

@interface JANewPlayWaveView()

@property (nonatomic, strong) UIImageView *leftWaveImageView;
@property (nonatomic, strong) UIImageView *rightWaveImageView;
@property (nonatomic, strong) UIView *ja_maskView;
@property (nonatomic, assign) BOOL isIncreasing;

@end

@implementation JANewPlayWaveView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.leftWaveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 23)];
        self.leftWaveImageView.image = [UIImage imageNamed:@"voice_right_wave"];
        [self addSubview:self.leftWaveImageView];
        self.leftWaveImageView.centerY = self.centerY;
        self.leftWaveImageView.left = 0;

        self.rightWaveImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 23)];
        self.rightWaveImageView.image = [UIImage imageNamed:@"voice_left_wave"];
        [self addSubview:self.rightWaveImageView];
        self.rightWaveImageView.centerY = self.centerY;
        self.rightWaveImageView.right = self.width;

        CGFloat maskViewW = self.width-35*2;
        UIView *ja_maskView = [[UIView alloc] initWithFrame:CGRectMake(35, 0, maskViewW, frame.size.height)];
        ja_maskView.backgroundColor = [UIColor whiteColor];
        self.maskView = ja_maskView;
        self.ja_maskView = ja_maskView;
    }
    return self;
}

- (void)startAnimation {
   
    if (self.ja_maskView.width >= self.width) {
        self.ja_maskView.width = self.width-35*2-12;
    } else {
        self.ja_maskView.width += 6;
        if (self.ja_maskView.width >= self.width) {
            self.ja_maskView.width = self.width-35*2-12;
        }
    }
    self.ja_maskView.centerX = self.width/2.0;

//    if (self.isIncreasing) {
//        self.ja_maskView.width += 6;
//    } else {
//        self.ja_maskView.width -= 6;
//    }
//
//    if (self.ja_maskView.width <= self.width-35*2) {
//        self.isIncreasing = YES;
//    } else if(self.ja_maskView.width >= self.width) {
//        self.isIncreasing = NO;
//    }
}

- (void)resetAnimation {
    self.ja_maskView.width = self.width-35*2-12;
    self.ja_maskView.centerX = self.width/2.0;
}

@end
