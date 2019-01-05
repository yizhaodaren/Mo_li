//
//  JAPersonMoliContributeView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/4/10.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JAPersonMoliContributeView.h"

@interface JAPersonMoliContributeView ()

@end

@implementation JAPersonMoliContributeView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupPersonMoliContributeView];
    }
    return self;
}

- (void)setupPersonMoliContributeView
{
    self.width = JA_SCREEN_WIDTH;
    self.height = 44;
    
    UIButton *myContributeButton = [[UIButton alloc] init];
    _myContributeButton = myContributeButton;
    [myContributeButton setTitle:@"我的投稿" forState:UIControlStateNormal];
    [myContributeButton setImage:[UIImage imageNamed:@"branch_moliDiantai_myContrubute"] forState:UIControlStateNormal];
    [myContributeButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    myContributeButton.titleLabel.font = JA_REGULAR_FONT(13);
    myContributeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    myContributeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [self addSubview:myContributeButton];
    
    UIButton *contributeButton = [[UIButton alloc] init];
    _contributeButton = contributeButton;
    [contributeButton setTitle:@"去投稿" forState:UIControlStateNormal];
    [contributeButton setImage:[UIImage imageNamed:@"branch_moliDiantai_contribute"] forState:UIControlStateNormal];
    [contributeButton setTitleColor:HEX_COLOR(0xffffff) forState:UIControlStateNormal];
    contributeButton.titleLabel.font = JA_REGULAR_FONT(13);
    contributeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
    contributeButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    [self insertSubview:contributeButton atIndex:0];
    
    [self dropShadowWithOffset:CGSizeMake(0, -2)
                        radius:4
                         color:[UIColor blackColor]
                       opacity:0.1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (iPhoneX) {
        self.myContributeButton.height = self.height * 0.7;
    }else{
        self.myContributeButton.height = self.height;
    }
    self.myContributeButton.width = self.width * 0.5;
   
    self.contributeButton.width = self.width * 0.5;
    
    self.contributeButton.height = self.myContributeButton.height;
    self.contributeButton.x = self.myContributeButton.width;
}

- (void)dropShadowWithOffset:(CGSize)offset
                      radius:(CGFloat)radius
                       color:(UIColor *)color
                     opacity:(CGFloat)opacity {
    
    // Creating shadow path for better performance
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, self.bounds);
    self.layer.shadowPath = path;
    CGPathCloseSubpath(path);
    CGPathRelease(path);
    
    self.layer.shadowColor = color.CGColor;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = opacity;
    
    // Default clipsToBounds is YES, will clip off the shadow, so we disable it.
    self.clipsToBounds = NO;
}

@end
