//
//  JAPersonalTopImageView.m
//  Jasmine
//
//  Created by moli-2017 on 2017/7/7.
//  Copyright © 2017年 xujin. All rights reserved.
//

#import "JAPersonalTopImageView.h"

@interface JAPersonalTopImageView ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIView *vv;

@end

@implementation JAPersonalTopImageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupTopImageView];
//        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setupTopImageView
{
    
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    imageView.image = [UIImage imageNamed:@"bg_man"];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    UIView *vv = [[UIView alloc] initWithFrame:imageView.bounds];
    _vv = vv;
    vv.backgroundColor = HEX_COLOR_ALPHA(0x000000, 0.5);
    [imageView addSubview:vv];
    [self addSubview:imageView];
    
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    self.vv.frame = self.imageView.bounds;
}

- (void)setImageName:(NSString *)imageName
{
    _imageName = imageName;
    
    if ([imageName hasPrefix:@"http://"] || [imageName hasPrefix:@"https://"]) {
        
        [self.imageView ja_setImageWithURLStr:imageName];
    }else{
        
        self.imageView.image = [UIImage imageNamed:imageName];
    }
    
}

@end
