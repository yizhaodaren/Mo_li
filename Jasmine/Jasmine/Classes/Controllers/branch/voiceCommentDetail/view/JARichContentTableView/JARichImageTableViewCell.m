//
//  JARichImageTableViewCell.m
//  Jasmine
//
//  Created by xujin on 2018/6/9.
//  Copyright © 2018 xujin. All rights reserved.
//

#import "JARichImageTableViewCell.h"
#import "KNPhotoBrower.h"

@interface JARichImageTableViewCell () <KNPhotoBrowerDelegate>

@property (nonatomic, strong) UIImageView *imageContentView;

@end

@implementation JARichImageTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UIImageView *imageContentView = [UIImageView new];
        imageContentView.userInteractionEnabled = YES;
        [self.contentView addSubview:imageContentView];
        self.imageContentView = imageContentView;
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBigPicture:)];
        [self.imageContentView addGestureRecognizer:tap1];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageContentView.x = 15;
    self.imageContentView.layer.cornerRadius = 3;
    self.imageContentView.layer.masksToBounds = YES;
}

- (void)setData:(JARichImageModel *)data {
    _data = data;
    if (data) {
        CGFloat tempWidth = data.imageSize.width / (JA_SCREEN_WIDTH-30);
        CGFloat w = data.imageSize.width / tempWidth;
        CGFloat h = data.imageSize.height / tempWidth;
        NSString *url = [data.remoteImageUrlString ja_getFitImageStringWidth:w height:h];
        [self.imageContentView ja_setImageWithURLStr:url];
        
        self.imageContentView.width = w;
        self.imageContentView.height = h;
    }
}

- (void)showBigPicture:(UIGestureRecognizer *)tap {
    if (self.showBigPicture) {
        self.showBigPicture();
    }
    UIImageView *imageV = (UIImageView *)tap.view;
    KNPhotoItems *items = [[KNPhotoItems alloc] init];
    items.url = self.data.remoteImageUrlString;
    
    KNPhotoBrower *photoBrower = [[KNPhotoBrower alloc] init];
    if ([JAUserInfo userInfo_getUserImfoWithKey:User_Admin].integerValue == JAPOWER) {
        photoBrower.actionSheetArr =  [@[@"删除",@"保存"] copy];
    }else{
        photoBrower.actionSheetArr =  [@[@"保存"] copy];
    }
    [photoBrower setIsNeedRightTopBtn:YES];
    [photoBrower setIsNeedPictureLongPress:YES];
    photoBrower.itemsArr = @[items];
    photoBrower.currentIndex = imageV.tag;
    [photoBrower present];
    [photoBrower setDelegate:self];
}

@end
