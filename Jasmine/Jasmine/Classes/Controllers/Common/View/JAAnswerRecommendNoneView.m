//
//  JAAnswerRecommendNoneView.m
//  Jasmine
//
//  Created by xujin on 19/05/2017.
//  Copyright © 2017 xujin. All rights reserved.
//

#import "JAAnswerRecommendNoneView.h"

@interface JAAnswerRecommendNoneView ()


@end

@implementation JAAnswerRecommendNoneView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews
{
    
    CGFloat y = (self.height-64-44 - 30 - 30 - 19)/2;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,y, self.width, 30)];
    label.backgroundColor = [UIColor clearColor];
    label.font = JA_REGULAR_FONT(18);
    label.textColor = HEX_COLOR(0x7e8392);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"添加擅长的话题，来获取推荐问题";
    [self addSubview:label];
    self.messageLabel = label;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.width = 98;
    imageView.height = 75;
    imageView.centerX = label.centerX;
    imageView.y = label.y - 40 - imageView.height;
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((JA_SCREEN_WIDTH-80)/2.0, label.bottom + 19, 80, 30);
    [button setTitle:@"添加话题" forState:UIControlStateNormal];
    [button setTitleColor:HEX_COLOR(JA_Green) forState:UIControlStateNormal];
    button.titleLabel.font = JA_REGULAR_FONT(14);
    button.layer.cornerRadius = 4;
    button.clipsToBounds = YES;
    button.layer.borderColor = HEX_COLOR(JA_Green).CGColor;
    button.layer.borderWidth = 1;
    [self addSubview:button];
    self.addButton = button;
}
- (void)setMessage:(NSString *)message
{
    if ([message isKindOfClass:[NSString class]])
    {
        self.messageLabel.text = message;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
