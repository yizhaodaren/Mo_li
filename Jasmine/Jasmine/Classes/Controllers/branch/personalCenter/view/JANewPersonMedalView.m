//
//  JANewPersonMedalView.m
//  Jasmine
//
//  Created by moli-2017 on 2018/7/12.
//  Copyright © 2018年 xujin. All rights reserved.
//

#import "JANewPersonMedalView.h"
#import "JAMedalModel.h"

@interface JANewPersonMedalView ()
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *imageView1;
@property (nonatomic, weak) UIImageView *imageView2;
@property (nonatomic, weak) UIImageView *imageView3;
@property (nonatomic, weak) UIImageView *imageView4;
@property (nonatomic, weak) UIImageView *imageView5;
@property (nonatomic, weak) UIImageView *arrowImageView;
@property (nonatomic, weak) UIView *lineView;

@property (nonatomic, strong) NSMutableArray *imageViewArray;
@end
@implementation JANewPersonMedalView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _imageViewArray = [NSMutableArray array];
        [self setupNewPersonMedalViewUI];
    }
    return self;
}

- (void)setupNewPersonMedalViewUI
{
    UILabel *nameLabel = [[UILabel alloc] init];
    _nameLabel = nameLabel;
    nameLabel.text = @"荣誉勋章";
    nameLabel.textColor = HEX_COLOR(0x363636);
    nameLabel.font = JA_MEDIUM_FONT(14);
    [self addSubview:nameLabel];
    
    UIImageView *imageView1 = [[UIImageView alloc] init];
    _imageView1 = imageView1;
    [self addSubview:imageView1];
    [_imageViewArray addObject:imageView1];
    
    UIImageView *imageView2 = [[UIImageView alloc] init];
    _imageView2 = imageView2;
    [self addSubview:imageView2];
    [_imageViewArray addObject:imageView2];
    
    UIImageView *imageView3 = [[UIImageView alloc] init];
    _imageView3 = imageView3;
    [self addSubview:imageView3];
    [_imageViewArray addObject:imageView3];
    
    UIImageView *imageView4 = [[UIImageView alloc] init];
    _imageView4 = imageView4;
    [self addSubview:imageView4];
    [_imageViewArray addObject:imageView4];
    
    UIImageView *imageView5 = [[UIImageView alloc] init];
    _imageView5 = imageView5;
    [self addSubview:imageView5];
    [_imageViewArray addObject:imageView5];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"跳转按钮"]];
    _arrowImageView = arrowImageView;
    [self addSubview:arrowImageView];
    
    UIView *lineView = [[UIView alloc] init];
    _lineView = lineView;
    lineView.backgroundColor = HEX_COLOR(0xEDEDED);
    [self addSubview:lineView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self calculatorNewPersonMedalViewFrame];
}

- (void)calculatorNewPersonMedalViewFrame
{
    [self.nameLabel sizeToFit];
    self.nameLabel.x = 15;
    self.nameLabel.centerY = self.height * 0.5;
    
    self.imageView1.width = WIDTH_ADAPTER(40);
    self.imageView1.height = WIDTH_ADAPTER(30);
    self.imageView1.x = self.nameLabel.right + WIDTH_ADAPTER(15);
    self.imageView1.centerY = self.nameLabel.centerY;
    
    self.imageView2.width = WIDTH_ADAPTER(40);
    self.imageView2.height = WIDTH_ADAPTER(30);
    self.imageView2.x = self.imageView1.right + WIDTH_ADAPTER(5);
    self.imageView2.centerY = self.nameLabel.centerY;
    
    self.imageView3.width = WIDTH_ADAPTER(40);
    self.imageView3.height = WIDTH_ADAPTER(30);
    self.imageView3.x = self.imageView2.right + WIDTH_ADAPTER(5);
    self.imageView3.centerY = self.nameLabel.centerY;
    
    self.imageView4.width = WIDTH_ADAPTER(40);
    self.imageView4.height = WIDTH_ADAPTER(30);
    self.imageView4.x = self.imageView3.right + WIDTH_ADAPTER(5);
    self.imageView4.centerY = self.nameLabel.centerY;
    
    self.imageView5.width = WIDTH_ADAPTER(40);
    self.imageView5.height = WIDTH_ADAPTER(30);
    self.imageView5.x = self.imageView4.right + WIDTH_ADAPTER(5);
    self.imageView5.centerY = self.nameLabel.centerY;
    
    self.arrowImageView.width = 6;
    self.arrowImageView.height = 10;
    self.arrowImageView.x = self.width - 15 - self.arrowImageView.width;
    self.arrowImageView.centerY = self.nameLabel.centerY;
    
    self.lineView.width = self.width;
    self.lineView.height = 1;
    self.lineView.y = self.height - self.lineView.height;
}

- (void)setModel:(JAConsumer *)model
{
    _model = model;
    for (NSInteger i = 0;  i < model.medalList.count; i++) {
        if (i >= self.imageViewArray.count) {
            return;
        }
        UIImageView *imageV = self.imageViewArray[i];
        JAMedalModel *m = model.medalList[i];
        [imageV ja_setImageWithURLStr:m.getImgUrl];
        
    }
}
@end
